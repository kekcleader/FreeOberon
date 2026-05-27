MODULE [foreign] TermVT;
(** Low-level VT100 terminal I/O. Wraps POSIX functions from term/termvt.c *)
IMPORT SYSTEM;

TYPE CHAR8* = SHORTCHAR;

(** Initialize terminal: enter raw mode, install SIGWINCH handler.
    Returns 0 on success, -1 on error. *)
PROCEDURE Init* ["termvt_init"] (): INTEGER;

(** Restore terminal to original state.
    Returns 0 on success, -1 on error. *)
PROCEDURE Close* ["termvt_close"] (): INTEGER;

(** Get terminal size in columns and rows.
    Returns 0 on success, -1 on error. *)
PROCEDURE Size* ["termvt_size"] (VAR cols, rows: INTEGER): INTEGER;

(** Write `len` bytes from `buf` to the terminal.
    Returns number of bytes written, or -1 on error. *)
PROCEDURE Write* ["termvt_write"] (buf: ARRAY OF CHAR8; len: INTEGER): INTEGER;

(** Wait for input with timeout (milliseconds).
    -1 = block forever, 0 = non-blocking.
    Returns: 1 = data ready, 0 = timeout, -1 = error, -2 = SIGWINCH *)
PROCEDURE Poll* ["termvt_poll"] (timeout_ms: INTEGER): INTEGER;

(** Read available bytes from terminal into buf[begin..end-1]. Non-blocking after Poll.
    Returns number of bytes read, 0 if nothing, -1 on error. *)
PROCEDURE Read* ["termvt_read"] (VAR buf: ARRAY OF CHAR8; begin, end: INTEGER): INTEGER;

END TermVT.
