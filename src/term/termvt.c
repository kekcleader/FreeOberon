/* termvt.c — Low-level VT100 terminal I/O for TermBox (POSIX) */

#include "termvt.h"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <termios.h>
#include <unistd.h>

static struct termios orig_termios;
static int            orig_saved = 0;
static int            tty_fd     = -1;
static volatile sig_atomic_t got_sigwinch = 0;

static void sigwinch_handler(int sig) {
  (void)sig;
  got_sigwinch = 1;
}

/* Emergency cleanup: restore terminal and re-raise the signal */
static void fatal_signal_handler(int sig) {
  static const char mouse_off[] = "\033[?1006l\033[?1002l\033[?1000l";

  termvt_close();
  /* Reset escape sequences that TermBox may have left active */
  write(STDOUT_FILENO, mouse_off, sizeof(mouse_off) - 1); /* mouse off */
  write(STDOUT_FILENO, "\033[0m", 4);      /* reset colors */
  write(STDOUT_FILENO, "\033[?25h", 6);    /* show cursor */
  write(STDOUT_FILENO, "\033[?1049l", 8);  /* exit alt screen */
  signal(sig, SIG_DFL);
  raise(sig);
}

static void atexit_cleanup(void) {
  if (orig_saved) termvt_close();
}

int termvt_init(void) {
  struct termios raw;
  struct sigaction sa;

  /* Use STDIN if it's a tty, otherwise try /dev/tty */
  if (isatty(STDIN_FILENO)) {
    tty_fd = STDIN_FILENO;
  } else {
    tty_fd = open("/dev/tty", O_RDWR);
    if (tty_fd < 0) return -1;
  }

  /* Save original terminal attributes */
  if (tcgetattr(tty_fd, &orig_termios) < 0) return -1;
  orig_saved = 1;

  /* Enter raw mode */
  raw = orig_termios;
  raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  raw.c_oflag &= ~(OPOST);
  raw.c_cflag |= (CS8);
  raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
  raw.c_cc[VMIN]  = 0;
  raw.c_cc[VTIME] = 0;

  if (tcsetattr(tty_fd, TCSAFLUSH, &raw) < 0) return -1;

  /* Install SIGWINCH handler */
  memset(&sa, 0, sizeof(sa));
  sa.sa_handler = sigwinch_handler;
  sa.sa_flags = SA_RESTART;
  sigemptyset(&sa.sa_mask);
  sigaction(SIGWINCH, &sa, NULL);

  /* Install fatal signal handlers to restore terminal on crash */
  signal(SIGINT,  fatal_signal_handler);
  signal(SIGTERM, fatal_signal_handler);
  signal(SIGSEGV, fatal_signal_handler);
  signal(SIGABRT, fatal_signal_handler);

  /* Also restore terminal on normal exit (in case Close is not called) */
  atexit(atexit_cleanup);

  return 0;
}

int termvt_close(void) {
  int result = 0;

  /* Restore original terminal attributes */
  if (orig_saved && tty_fd >= 0) {
    if (tcsetattr(tty_fd, TCSAFLUSH, &orig_termios) < 0)
      result = -1;
  }

  /* Restore default SIGWINCH handler */
  signal(SIGWINCH, SIG_DFL);

  /* Close tty_fd if we opened it separately */
  if (tty_fd >= 0 && tty_fd != STDIN_FILENO) {
    close(tty_fd);
  }
  tty_fd = -1;
  orig_saved = 0;

  return result;
}

int termvt_size(int *cols, int *rows) {
  struct winsize ws;
  if (ioctl(tty_fd >= 0 ? tty_fd : STDOUT_FILENO, TIOCGWINSZ, &ws) < 0)
    return -1;
  *cols = ws.ws_col;
  *rows = ws.ws_row;
  return 0;
}

int termvt_write(const char *buf, int buf_len, int len) {
  int fd, written, n;
  (void)buf_len; /* Ofront+ hidden array-length parameter */
  /* Write to stdout for output (even if tty_fd is stdin) */
  fd = (tty_fd >= 0 && tty_fd != STDIN_FILENO) ? tty_fd : STDOUT_FILENO;
  written = 0;
  while (written < len) {
    n = write(fd, buf + written, len - written);
    if (n < 0) {
      if (errno == EINTR) continue;
      return -1;
    }
    written += n;
  }
  return written;
}

int termvt_poll(int timeout_ms) {
  fd_set fds;
  struct timeval tv, *tvp;
  int ret, rfd;

  /* Check for pending SIGWINCH first */
  if (got_sigwinch) {
    got_sigwinch = 0;
    return -2;
  }

  rfd = (tty_fd >= 0) ? tty_fd : STDIN_FILENO;

  FD_ZERO(&fds);
  FD_SET(rfd, &fds);

  if (timeout_ms < 0) {
    tvp = NULL; /* block forever */
  } else {
    tv.tv_sec  = timeout_ms / 1000;
    tv.tv_usec = (timeout_ms % 1000) * 1000;
    tvp = &tv;
  }

  ret = select(rfd + 1, &fds, NULL, NULL, tvp);

  if (ret < 0) {
    if (errno == EINTR) {
      /* Likely SIGWINCH */
      if (got_sigwinch) {
        got_sigwinch = 0;
        return -2;
      }
      return 0; /* interrupted but not SIGWINCH */
    }
    return -1;
  }

  if (ret == 0) return 0; /* timeout */

  return 1; /* data available */
}

// begin inclusive, end exclusive
int termvt_read(char *buf, int buf_len, int begin, int end) {
  int rfd, n;
  (void)buf_len; /* Ofront+ hidden array-length parameter */

  rfd = (tty_fd >= 0) ? tty_fd : STDIN_FILENO;

  n = read(rfd, buf + begin, end - begin);
  if (n < 0) {
    if (errno == EAGAIN || errno == EWOULDBLOCK) return 0;
    if (errno == EINTR) return 0;
    return -1;
  }
  return n;
}
