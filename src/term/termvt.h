/* termvt.h — Low-level VT100 terminal I/O for TermBox (POSIX) */

#ifndef TERMVT_H
#define TERMVT_H

/* Initialize terminal: save original termios, enter raw mode,
   install SIGWINCH handler.
   Returns 0 on success, -1 on error. */
int termvt_init(void);

/* Restore terminal to original state.
   Returns 0 on success, -1 on error. */
int termvt_close(void);

/* Get terminal size in columns and rows.
   Returns 0 on success, -1 on error. */
int termvt_size(int *cols, int *rows);

/* Write `len` bytes from `buf` to the terminal.
   buf_len is the Ofront+ hidden array-length parameter (ignored).
   Returns number of bytes written, or -1 on error. */
int termvt_write(const char *buf, int buf_len, int len);

/* Wait for input with timeout.
   timeout_ms: milliseconds to wait (-1 = block forever, 0 = non-blocking).
   Returns:  1 if data is available to read,
             0 on timeout,
            -1 on error,
            -2 on SIGWINCH (terminal resized). */
int termvt_poll(int timeout_ms);

/* Read available bytes from the terminal (non-blocking after poll).
   buf: buffer to read into.
   buf_len is the Ofront+ hidden array-length parameter (ignored).
   begin: inclusive, start writing at buf[begin].
   end: exclusive, read at most end-begin bytes.
   Returns number of bytes read, 0 if nothing available, -1 on error. */
int termvt_read(char *buf, int buf_len, int begin, int end);

#endif /* TERMVT_H */
