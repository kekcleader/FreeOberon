# Crossplatform Pipe Support
This tiny library is created for crossplatform pipe support. It is needed by the virtual terminal of Free Oberon.
When a program is being run in the IDE, Free Oberon creates a child process and attaches a pipe to its stdin and stdout. This way a program may run both in real terminal and inside Free Oberon IDE.

When you run `make -f Makefile_linux` or `make -f Makefile_win32`, one of the two files is automatically selected for compilation: `term_win32.c` or `term_linux.c`:
* `term_linux.c` is a GNU/Linux version (tested on Debian), it uses fork, dup2, execl, fcntl and waitpid.
* `term_win.c` is a Windows version, it uses WinAPI (CreateNamedPipeA and other functions).

The source code of Free Oberon includes an Oberon binding for this library (Term.Mod) and uses it in a cross-platform way.
