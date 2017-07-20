![Free Oberon screenshot](http://freeoberon.su/images/freeoberon.png)

# Free Oberon
* Version 0.1.0
* Riga, July 20, 2017
* Website: [freeoberon.su](http://freeoberon.su)

# Installation

## 1.1. Installation under OS GNU/Linux.
1. Download Free Oberon source code from [freeoberon.su](http://freeoberon.su) in tar.gz format or from the GitHub repo. Note that the archive with the version for Windows is also suitable, because it contains the source code. Extract the archive to your home directory or to another location on the disk. (This tutorial will assume the files are extracted to the home directory.)
2. Using the terminal or in any other way, install the following software packages on your system:
  * libsdl2-dev
  * libsdl2-image-dev
  * binutils
  * gcc
  * make
  * git (optionally)

  The names of the packages are given in accordance with their name in the Debian GNU/Linux operating system. They are suitable for users of Ubuntu, Linux Mint, Raspbian and other distributions.
  To install them, run the following command:
  ```
  apt-get install -y libsdl2-dev libsdl2-image-dev binutils gcc make git
  ```
  (This command must be executed with superuser privileges, that is, you must first run `su` and enter the password.)
  On OS Fedora, Red Hat, CentOS and others, the command and package names will differ:
  ```
  sudo yum install SDL2-devel SDL2_image-devel binutils gcc make git    (not tested!)
  ```
3. Using the terminal, enter the following directory:
  ```
  cd ~/FreeOberon/data/bin/voc/src
  ```
  where a modified version of Vishap Oberon Compiler is located.
4. Compile Vishap Oberon Compiler:
  ```
  make full
  ```
5. If the compilation was successful, get the superuser's rights (by typing `su` or by prepending the following command with `sudo`), and run:
  ```
  make install
  ```
  VOC files will be installed in `/opt/voc`.
6. Open file `~/.bashrc` and append the following line to the end:
  ```
  export PATH="/opt/voc/bin:$PATH"
  ```
  This is necessary so that you can run `voc` from the command line (and so that Free Oberon could do it).
7. In the terminal, go to the `FreeOberon/src` directory:
  ```
  cd ~/FreeOberon/src
  ```
8. Compile Free Oberon:
  ```
  make -f Makefile_linux
  ```
9. Run the following command to copy Graph and SDL2 modules to VOC:
  ```
  make -f Makefile_linux install
  ```
10. (optional) Add this line to the end of file `~/.bashrc`:
  ```
  alias fo='cd ~/FreeOberon;./FreeOberon'
  ```
  so that Free Oberon could be executed with the `fo` command.

## 1.2. Installation under Windows.

Download the setup porgram in EXE format from [freeoberon.su](http://freeoberon.su), run it and follow the instructions.

Alternatively, you can download a ZIP-archive, extract it to any place on disk and create a desktop shortcut.

Note. If you want to recompile a version of Free Oberon under Windows from the source code yourself, refer to Appendix A of the Free Oberon documentation on [freeoberon.su](http://freeoberon.su).

# Usage

Run Free Oberon and type in an Oberon program (or open an example program `Book.Mod`), then save it and press `F9` to compile and run the program.
The module source codes are saved in subdirectory `Programs` and the executable files are saved in `bin`. `data/bin/compile.sh` and `data\bin\compile.bat` are used to compile a program on GNU/Linux and Windows accordingly.
