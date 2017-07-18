# Free Oberon
Version 0.1.0

Riga, July 18, 2017

Website: [freeoberon.su](http://freeoberon.su)

# Installation

## 1.1. Installation under OS GNU/Linux.
1. Download Free Oberon source code from this repo or from [freeoberon.su](http://freeoberon.su). The archive with the version for Windows OS is suitable, because it also contains the source codes. Unzip the archive to your home directory or to another location on the disk.
2. Using the terminal or in any other way, install the following software packages on your system:
  * libsdl2-dev
  * libsdl2-image-dev
  * binutils
  * gcc
  * make
  * git (optionally)

  The names of the packages are given in accordance with their name in the Debian GNU/Linux operating system. They are suitable for users of Ubuntu, Linux Mint, Raspbian and some other distributions.
  To install them, run the following command:
  ```
  apt-get install -y libsdl2-dev libsdl2-image-dev binutils gcc make git
  ```
  (This command must be executed with superuser privileges, that is, you must first run su and enter the password.)
  On OS Fedora, Red Hat, CentOS and others, the command and package names will differ:
  ```
  sudo yum install SDL2-devel SDL2_image-devel binutils gcc make git    (not tested!)
  ```
3. Using the terminal, enter the following directory:
  ```
  cd FreeOberon/data/bin/voc
  ```
  Here is a modified version of the VOC compiler.
4. Run the Vishap Oberon Compiler compilation:
  ```
  make full
  ```
5. If the compilation was successful, get the superuser's rights (by the command `su` or by assigning `sudo`), and then run:
  M ake install
  The VOC compiler files will be installed in `/opt/voc`.
6. Open the file `~/.bashrc` and add the following line to the end:
  ```
  export PATH="/opt/voc/bin:$PATH"
  ```
  This is necessary so that you can run "voc" from the command line (and that Free Oberon can do it).
7. In the terminal, go to the `FreeOberon/src` directory:
  ```
  cd FreeOberon/src
  ```
8. Compile Free Oberon:
  ```
  make -f Makefile_linux
  ```
9. (optional) Add the line `~/.bashrc` to the end of the file:
  ```
  alias fo='cd ~/FreeOberon;./ FreeOberon'
  ```
  So that Free Oberon can be run with the `fo` command.
## 1.2. Installation under Windows.
1. Download the ZIP-archive containing the version of Free Oberon for Windows, from the site freeoberon.su and unpack it somewhere on the disk.
2. (optional) Create a shortcut "Free Oberon" on the desktop, which points to `FreeOberon.exe`.
3. Run the FreeOberon.exe file (by shortcut or directly).

Note. If you want to compile a version of Free Oberon under Windows from the source code yourself, refer to Appendix A of the documentation on <http://freeoberon.su>.

Note. On GNU/Linux it may be required to run `chmod +x data/bin/compile.sh`.

# Usage

Run Free Oberon and type in an Oberon program (or open an example program `Book.Mod`), then save it and press `F9` to compile and run the program.
The module source codes are saved in subdirectory `Programs` and the executable files are saved in `bin`. `data/bin/compile.sh` and `data\bin\compile.bat` are used to compile a program on GNU/Linux and Windows accordingly.
