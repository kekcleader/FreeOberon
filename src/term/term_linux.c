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
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
//#include <wait.h>
#include <sys/wait.h>

#define BUFSIZE 4096

extern void exit(int);

int p[2], q[2];
pid_t pid;

int StartProcessIn(char *process, char *dir) {
  char cmd[600];
  int success = 0;
  int i, j;

      // Ignore SIGPIPE in case of a write to a broken pipe
      if (signal(SIGPIPE, SIG_IGN) == SIG_ERR) {
        puts("Could not ignore SIGPIPE signal.");
      }

  if ((pipe(p) == -1) || (pipe(q) == -1)) {
    perror("StartProcessIn: Could not create pipes");
  } else {
    pid = fork();
    if (pid == -1) { // fork() error
      perror("StartProcessIn: Could not fork().");
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
        if (getcwd(cmd, 256) == NULL) {
          perror("StartProcessIn: Could not getcdw()");
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
        if (chdir(dir) != 0) {
          perror("StartProcessIn: Could not chdir() in child process");
        }
        process = &cmd[0];
      }
      if (execl(process, process, (char*)NULL)) {
        puts("Could not run program.");
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

int StartProcess(char *process) {
  return StartProcessIn(process, (char *)NULL);
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

int RunProcess(char *cmd, char *buf, int limit, int *len, int *err) {
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
