## Building and installation summary

The Oberon compiler and libraries may be built and installed on Linux based, BSD based or Windows based systems.

### Windows systems

Bulding on Windows is not so simple largely because there is more than one way to do it:

  -  Install the cygwin project and use Windows from the cygwin bash shell rather like Linux.
     With the pre-requisites installed using the cygwin setup.exe gui tool, clone and run make
     as on Linux.
     This builds a compiler that is dependent on the cygwin environment, and which compiles
     Oberon programs to binaries that are themselves dependent on the cygwin environment.

  -  Install the cygwin project and the mingw compiler. The Oberon compiler this builds is
     still dependent on the cygwin environment, but programs built with this compiler are
     Windows binaries dependent only on standard Microsoft APIs and libraries.

  -  Use the Windows 10 Bash on Ubuntu on Windows (aka WSL - Windows Subsystem for Linux).
     The Oberon compiler can be built in the WSL using exactly the same procedure
     as on a normal Ubuntu environment, and the resulting compiler and user programs will run
     within the Windows subsystem for Linux.

  -  Build with the Microsoft C compiler generating native windows binaries. A make.cmd script
     is provided which has been developed for and tested with the free 'Visual C++ build tools'
     available at http://landinghub.visualstudio.com/visual-cpp-build-tools.

For full details about building with Cygwin or native Microsoft C environments see [**Cygwin and MSC Installation**](/doc/Winstallation.md)


### Building the Oberon compiler and libraries on a Linux or BSD based system

This approach is for
 - All Linux based systems
   - includes Android (specifically termux on Android)
   - includes Windows subsystem for Linux (aka Bash on Ubuntu on Windows)
 - All BSD based systems
   - includes macOS (Darwin)


#### 1. Install pre-requisites

The build process has the following pre-requisites:

  - gcc (or clang) compiler
  - static libraries for the chosen compiler
  - git
  - make
  - diff

Example pre-requisite installation commands:

| Platform               | Pre-requisite installation                                                    |
| ---------              | ------------                                                                  |
| Debian/Ubuntu/Mint ... | `apt-get install git`                                                         |
| Fedora/RHEL/CentOS ... | `yum install git gcc glibc-static` (`dnf` instead of `yum` on recent Fedoras) |
| FreeBSD/NetBSD         | `pkg install git`                                                             |
| OpenBSD                | `pkg_add git gcc`                                                             |
| OpenSUSE               | `zypper install gcc git-core make glibc-devel-static`                         |

On Mac OS (Darwin) just type the git command. OS/X will tell you that it is not installed and ask if you want to install it (say yes). Note that Darwin builds always use clang, the OS will redirect attempts to use gcc to clang.


#### 2. Clone the Oberon compiler repository

Create and change to a directory in which to make the compiler and clone with this command:

`git clone https://github.com/vishaps/voc`

This will create a subdirectory 'voc' which includes the following files and directories:

| Name       | Content                                                                                    |
| ---        | ---                                                                                        |
| src/       | Compiler and library source, build tools and tests.                                        |
| bootstrap/ | Pre-generated C source for the compiler targetting the 5 distinct build models needed.     |
| doc/       | Documents (including this one).                                                            |
| makefile   | Makefile for all BSD- and Linux- like environments. Includes tests.                        |
| make.cmd   | Makefile specifically for native Microsoft C builds. No tests.                             |


#### 3. Build the Oberon compiler and library

```
cd voc
make full
```

The makefile will:

 - Compile and run a C program that determines your C compiler and OS's configuration and creates
   the files Configuration.Make and Configuration.Mod.
 - C Compile the bootstrap C sources to generate an interim Oberon compiler for your configuration.
 - Use the interim compiler to compile the src/compiler and src/runtime directories and statically
   link the final Oberon compiler. This compiler is then used for the remaining steps.
 - Build the .sym file browser command `showdef`.
 - Build all the libraries in -O2 mode, and a subset in -OC mode.
 - Create an installation directory structure local to your copy of the repository.
 - Run a set of confidence tests.

The makefile will use either gcc or clang, whichever is installed. If you have both installed you can specify which to use by running either `export CC=gcc` or `export CC=clang` before the `make full` command.


#### Installation directories:

If the makefile succeeds it will end with instructions on how to set your path variable so that the
compiler (voc) is found.


#### Installing to system directories

You may optionally install to system directories such as /opt or /usr/local/share.

First be sure to have completed `make full` successfully.

Then from a root prompt, or using sudo, run `make install`

The installation will be made to:

| System                       | Install dir                            |
| -----------------------      | -------------------------------------- |
| All types of Linux           | /opt/voc                               |
| BSD (including Darwin)       | /usr/local/share/voc                   |
| Termux (android)             | /data/data/com.termux/files/opt/voc    |

As with `make full`, `make install` will exit with instructions on how to set
your PATH.


#### Installation directory contentains:

| Directory      | Content                                            |
| ---            | ---                                                |
| bin/           | Compiler and symbol file browser command binaries. |
| lib/           | Static and dynamic link libraries for all (-O2 and -OC) type models. |
| 2/include/     | C compiler header files for -O2 modules |
| 2/sym/         | .sym files for -O2 modules              |
| C/include/     | C compiler header files for -OC modules |
| C/sym/         | .sym files for -OC modules              |



### 32 and 64 bit

The compiler may be built on both 32 bit and 64 bit systems.

Oberon programs may be compiled using the -O2 (default) or -OC elementary type models. The elementary
types are as follows:

| Model         | 8 bit      | 16 bit     | 32 bit              | 64 bit              |
| ---           | ----       | ---        | ---                 | ---                 |
| -O2 (default) | `SHORTINT` | `INTEGER`  | `LONGINT` and `SET` | `HUGEINT`           |
| -OC           | `BYTE`     | `SHORTINT` | `INTEGER`           | `LONGINT` and `SET` |

A convention of many Oberon compilers has been that LONGINT is a suitable integer type for
manipulating addresses. However since the size of pointer types is fixed by the OS and we
support both 32 and 64 bit operating systems, LONGINT is not always sufficient for us.

Accordingly, the SYSTEM module has been updated to ease the development of platform independent
code, with new types such as `SYSTEM.INT8`, `SYSTEM.INT16`, `SYSTEM.INT32`, `SYSTEM.INT64`
and `SYSTEM.ADDRESS`.

For details, see [**Features**](/doc/Features.md).
