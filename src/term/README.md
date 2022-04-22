# Crossplatform Pipe Support

This tiny library is created for crossplatform pipe support. It is needed
by the virtual terminal of Free Oberon. When a program is being run in
the IDE, Free Oberon creates a child process and attaches a pipe to its
stdin and stdout. This way a program may run both in real terminal and
inside Free Oberon IDE, which itself acts as a terminal emulator.

When you run `./make.sh` or `make.bat` in directory `src`, one of
the two files is automatically selected for compilation: `term_win32.c`
or `term_linux.c`:
* `term_linux.c` is a GNU/Linux version (tested on Debian), it uses fork,
  dup2, execl, fcntl and waitpid.
* `term_win32.c` is a Windows version, it uses WinAPI (CreateNamedPipeA and
  other functions).

The source code of Free Oberon includes an Oberon binding for this library
(Term.Mod), the binding is used as a cross-platform module.
