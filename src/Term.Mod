MODULE Term;
(* Copyright 2017-2025 Arthur Yefimov

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
*)
IMPORT SYSTEM;
(** Crossplatform Pipe Support
     This tiny library is created for crossplatform pipe support. It is needed
    by the virtual terminal of Free Oberon. When a program is being run in
    the IDE, Free Oberon creates a child process and attaches a pipe to its
    stdin and stdout. This way a program may run both in real terminal and
    inside Free Oberon IDE, which itself acts as a terminal emulator.
     When you run `./make.sh` or `make.bat` in directory `src`, one of
    the two files is automatically selected for compilation: `term_win32.c`
    or `term_linux.c`:
     - `term_linux.c` is a GNU/Linux version (tested on Debian, Ubuntu, Mint),
    it uses fork, dup2, execl, fcntl and waitpid.
     - `term_win32.c` is a Windows version, it uses WinAPI (CreateNamedPipeA
    and other functions).
     Term.Mod is an Oberon binding for this library, the binding is used
    as a cross-platform module. *)

TYPE CHAR8* = SHORTCHAR;

PROCEDURE -AAIncludeTermh* '#include "term/term.h"';

(** Starts a process with the given path to the executable.
    Returns TRUE process has been started successfully *)
PROCEDURE -StartProcess*
  (cmd: ARRAY OF CHAR8): BOOLEAN
  "StartProcessIn(cmd, (char *)0)";

(** Starts a process with the path `cmd` to the executable, but
    starts it from a directory `dir`. Returns TRUE on success *)
PROCEDURE -StartProcessIn*
  (cmd, dir: ARRAY OF CHAR8): BOOLEAN
  "StartProcessIn(cmd, dir)";

(** Returns TRUE if the process has finished. In this case puts in `err`
    the exit code of the process *)
PROCEDURE -ProcessFinished*(VAR err: INTEGER): BOOLEAN
  "ProcessFinished(err)";

(** Writes `len` 1-byte characters (bytes) from `buf` to the standard
    input pipe of the started process.
     The process must first have been started with StartProcess or
    StartProcessIn *)
PROCEDURE -WriteToProcess*
  (buf: ARRAY OF CHAR8; len: INTEGER)
  "WriteToProcess(buf, len)";

(** Reads at most `limit` 1-byte characters (bytes) from the standard output
    pipe of the started process to `buf`, puts in `len` the number of
    1-byte characters read. Does not add 0X in the end of `buf`.
     The process must first have been started with StartProcess or
    StartProcessIn *)
PROCEDURE -ReadFromProcess*
  (VAR buf: ARRAY OF CHAR8; VAR len: INTEGER; limit: INTEGER)
  "ReadFromProcess(buf, len, limit)";

(** Starts a process with the given path `cmd` to the executable, waits for
    it to finish and puts its output (as bytes, converted to 1-byte-wide
    SHORTCHARs) to `buf`, using at most `len` space. Puts in `err` the
    exit code of the finished process. Does not add 0X in the end of `buf`.
     Returns 1 on success, 0 on failure. *)
PROCEDURE -RunProcess*
  (cmd: ARRAY OF CHAR8; VAR buf: ARRAY OF CHAR8;
  limit: INTEGER; VAR len, err: INTEGER): INTEGER
  "(int)RunProcessIn((char *)cmd, (char *)0, (char *)buf, limit, len, err)";

(** Starts a process with the given path `cmd` to the executable
    in the directory `dir`, waits for
    it to finish and puts its output (as bytes, converted to 1-byte-wide
    SHORTCHARs) to `buf`, using at most `len` space. Puts in `err` the
    exit code of the finished process. Does not add 0X in the end of `buf`.
     Returns 1 on success, 0 on failure.
     On Unix/Linux `dir` is ignored *)
PROCEDURE -RunProcessIn*
  (cmd, dir: ARRAY OF CHAR8; VAR buf: ARRAY OF CHAR8;
  limit: INTEGER; VAR len, err: INTEGER): INTEGER
  "(int)RunProcessIn((char *)cmd, (char *)dir, (char *)buf, limit, len, err)";

(** Puts in `result` the full path to the executable `filename` if it is
    found in the PATH environment variable. Uses SearchPath WINAPI call
    on Windows. Returns 1 on success, 0 on failure.
     On Unix/Linux just copies filename to result and returns 1 *)
PROCEDURE -SearchPath*
  (filename: ARRAY OF CHAR8; VAR result: ARRAY OF CHAR8): LONGINT
  "(int)MySearchPath((char *)filename, (char *)result, result__len)";

END Term.
