/* Copyright 2017-2022 Arthur Yefimov

This file is part of Free Oberon.

Free Oberon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Free Oberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Free Oberon.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
//#include <wait.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#ifdef __APPLE__
#include <util.h>
#else
#include <pty.h>
#endif

#define BUFSIZE 4096

extern void exit(int);

int p[2], q[2];
pid_t pid;

/* ================== PTY pass-through ================== */

static volatile sig_atomic_t pass_sigwinch = 0;

static void pass_sigwinch_handler(int sig) {
  (void)sig;
  pass_sigwinch = 1;
}

static void propagate_winsize(int pty_master) {
  struct winsize ws;
  if (ioctl(STDIN_FILENO, TIOCGWINSZ, &ws) == 0)
    ioctl(pty_master, TIOCSWINSZ, &ws);
}

/* Run `process` in a PTY and forward I/O transparently until it exits.
   Prints "Press any key..." after the child exits.
   Returns 1 on success, 0 on failure. */
int StartProcessInPassthrough(char *process, char *dir) {
  int master_fd, slave_fd;
  struct winsize ws;
  pid_t child_pid;
  struct termios orig_t, raw_t;
  struct sigaction sa, old_sa;
  char buf[4096];
  int n, done;
  char cmd[600];
  int i, j;

  if (!isatty(STDIN_FILENO)) return 0;

  memset(&ws, 0, sizeof(ws));
  ioctl(STDIN_FILENO, TIOCGWINSZ, &ws);

  if (openpty(&master_fd, &slave_fd, NULL, NULL, &ws) < 0) return 0;

  child_pid = fork();
  if (child_pid < 0) {
    close(master_fd); close(slave_fd);
    return 0;
  }

  if (child_pid == 0) {
    /* Child process */
    close(master_fd);
    setsid();
    if (ioctl(slave_fd, TIOCSCTTY, 0) < 0) { /* ignore */ }
    dup2(slave_fd, STDIN_FILENO);
    dup2(slave_fd, STDOUT_FILENO);
    dup2(slave_fd, STDERR_FILENO);
    if (slave_fd > STDERR_FILENO) close(slave_fd);

    if (dir && dir[0] != '\0') {
      if (process && process[0] != '/') {
        if (getcwd(cmd, 256) != NULL) {
          i = 0;
          while (cmd[i]) i++;
          if (i && cmd[i - 1] != '/') { cmd[i] = '/'; i++; cmd[i] = '\0'; }
          j = 0;
          while (process[j]) { cmd[i] = process[j]; i++; j++; }
          cmd[i] = '\0';
          process = cmd;
        }
      }
      if (chdir(dir) != 0) { /* ignore */ }
    }

    execl(process, process, (char *)NULL);
    perror("execl");
    exit(1);
  }

  /* Parent: transparent forwarding */
  close(slave_fd);

  /* Save terminal state, enter raw mode */
  tcgetattr(STDIN_FILENO, &orig_t);
  raw_t = orig_t;
  raw_t.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  raw_t.c_oflag &= ~(OPOST);
  raw_t.c_cflag |= CS8;
  raw_t.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
  raw_t.c_cc[VMIN] = 0;
  raw_t.c_cc[VTIME] = 0;
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw_t);

  /* Install SIGWINCH handler to propagate terminal resize to the child */
  memset(&sa, 0, sizeof(sa));
  sa.sa_handler = pass_sigwinch_handler;
  sa.sa_flags = SA_RESTART;
  sigemptyset(&sa.sa_mask);
  sigaction(SIGWINCH, &sa, &old_sa);
  pass_sigwinch = 0;
  signal(SIGPIPE, SIG_IGN);

  done = 0;
  while (!done) {
    int status;
    fd_set rfds;
    int nfds;
    struct timeval tv;

    if (pass_sigwinch) {
      pass_sigwinch = 0;
      propagate_winsize(master_fd);
    }

    FD_ZERO(&rfds);
    FD_SET(STDIN_FILENO, &rfds);
    FD_SET(master_fd, &rfds);
    nfds = (STDIN_FILENO > master_fd ? STDIN_FILENO : master_fd) + 1;
    tv.tv_sec = 0; tv.tv_usec = 50000;

    if (select(nfds, &rfds, NULL, NULL, &tv) < 0) {
      if (errno == EINTR) continue;
      break;
    }

    if (FD_ISSET(STDIN_FILENO, &rfds)) {
      n = read(STDIN_FILENO, buf, sizeof(buf));
      if (n > 0) write(master_fd, buf, n);
    }
    if (FD_ISSET(master_fd, &rfds)) {
      n = read(master_fd, buf, sizeof(buf));
      if (n > 0) {
        write(STDOUT_FILENO, buf, n);
      } else if (n < 0 && errno != EAGAIN && errno != EINTR) {
        done = 1; /* EIO: child closed its end of the PTY */
      }
    }

    if (waitpid(child_pid, &status, WNOHANG) > 0)
      done = 1;
  }

  /* Drain any remaining buffered output */
  {
    int flags = fcntl(master_fd, F_GETFL);
    fcntl(master_fd, F_SETFL, flags | O_NONBLOCK);
    while ((n = read(master_fd, buf, sizeof(buf))) > 0)
      write(STDOUT_FILENO, buf, n);
  }

  /* Restore SIGWINCH and terminal */
  sigaction(SIGWINCH, &old_sa, NULL);
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_t);

  /* Reap child */
  { int status; waitpid(child_pid, &status, 0); }

  close(master_fd);

  /* "Press any key" prompt while still on the normal screen */
  {
    struct termios raw2;
    tcgetattr(STDIN_FILENO, &orig_t);
    raw2 = orig_t;
    raw2.c_lflag &= ~(ICANON | ECHO);
    raw2.c_cc[VMIN] = 1;
    raw2.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw2);
    write(STDOUT_FILENO, "\r\nPress any key to return to Free Oberon...", 43);
    read(STDIN_FILENO, buf, 1);
    write(STDOUT_FILENO, "\r\n", 2);
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_t);
  }

  return 1;
}


int StartProcessIn(char *process, char *dir) {
  char cmd[600];
  int success = 0;
  int i, j;

  // Ignore SIGPIPE in case of a write to a broken pipe
  if (signal(SIGPIPE, SIG_IGN) == SIG_ERR) {
    perror("StartProcessIn: Could not ignore SIGPIPE signal");
  }

  if ((pipe(p) == -1) || (pipe(q) == -1)) {
    perror("StartProcessIn: Could not create pipes");
  } else {
    pid = fork();
    if (pid == -1) { // fork() error
      perror("StartProcessIn: Could not fork()");
    } else if (pid == 0) { // Child process
      if (dup2(q[0], 0/*stdin*/) == -1) {
        perror("StartProcessIn: Could not dup2(stdin) in child process");
      }
      if (dup2(p[1], 1/*stdout*/) == -1) {
        perror("StartProcessIn: Could not dup2(stdout) in child process");
      }
      close(q[1]);
      close(p[0]);
      if (dir && dir[0] != '\0') {
        if (process && process[0] != '/') {
          if (getcwd(cmd, 256) == NULL) {
            perror("StartProcessIn: Could not getcwd()");
          }
          i = 0;
          while (cmd[i]) i++;
          if (i && cmd[i - 1] != '/') {
            cmd[i] = '/';
            i++;
            cmd[i] = '\0';
          }
          j = 0;
          while (process[j]) { cmd[i] = process[j]; i++; j++; }
          cmd[i] = '\0';
          process = &cmd[0];
        }
        if (chdir(dir) != 0) {
          perror("StartProcessIn: Could not chdir() in child process");
        }
      }
      if (execl(process, process, (char*)NULL)) {
        perror("StartProcess: Could not execl()");
        exit(0);
      }
      /*
      // Ignore SIGPIPE in case of a write to a broken pipe
      if (signal(SIGPIPE, SIG_IGN) == SIG_ERR) {
        puts("Could not ignore SIGPIPE signal.");
      }
      */
    } else { // Parent process
      close(q[0]);
      close(p[1]);
      fcntl(p[0], F_SETFL, O_NONBLOCK);
    }
    success = 1;
  }
  return success;
}

int ProcessFinished(int *err) {
  int status;
  pid_t result = waitpid(pid, &status, WNOHANG|WUNTRACED);
  if (result != 0) {
    if (WIFSIGNALED(status)) { //!FIXME returns 8 on error 136 for some reason
      *err = WTERMSIG(status);
    } else if (WIFEXITED(status)) {
      *err = WEXITSTATUS(status);
    } else if (WIFSTOPPED(status)) {
      *err = WSTOPSIG(status);
    } else {
      *err = 44;
    }
  } else {
    *err = 0;
  }
  return result != 0;
}

void WriteToProcess(char *buf, int len) {
  ssize_t res;
  do {
    res = write(q[1], buf, len);
  } while (res != -1 && res < len);
  if (res == -1) {
    perror("WriteToProcess: write failed");
  }
}

void ReadFromProcess(char *buf, int *len, int limit) {
  *len = read(p[0], buf, limit);
  if (*len < 0) *len = 0;
}

/* !FIXME dir is ignored now*/
int RunProcessIn(char *cmd, char *dir, char *buf, int limit, int *len, int *err) {
  int success = 0;
  *err = 0;
  FILE *F;
  F = popen(cmd, "r");
  if (F != NULL) {
    int n, i = 0;
    n = fgetc(F);
    while ((n >= 0) && (i < limit)) {
      buf[i++] = (char)n;
      n = fgetc(F);
    }
    *len = i;
    int ex_code = pclose(F);
    *err = WEXITSTATUS(ex_code);
    if (!*err) success = 1;
  }
  return success;
}

int MySearchPath(char *filename, char* result, int limit) {
  //!FIXME check this code
  int i = 0;
  while ((i < limit - 1) && filename[i]) {
    result[i] = filename[i];
    i++;
  }
  result[i] = '\0';
  return !filename[i];
}
