### Building the Oberon compiler and libraries on a Windows system

This approach is for Windows systems using
 - Cygwin (with or without mingw)
 - Microsoft Visual C

Building on Bash on Ubuntu on Windows (aka Windows Subsystem for Linux) is the same as building on Ubuntu,
for which see [**Installation**](/doc/Installation.md).

### Building and installing with Cygwin

Cygwin comes in 32 bit and 64 bit flavours, and both may be installed on a 64 bit system. On such a dual system, Oberon may be built and installed in both Cygwins.


#### 1. Install pre-requisites

The build process has the following pre-requisites:

  - gcc (or clang) compiler
  - static libraries for the chosen compiler
  - git
  - make
  - diff

To install these, run the Cygwin setup program (setup-x86.exe or setup-x86_64.exe as appropriate), work
your way through the initaial questions until you reach the 'Select packages' page, and make sure the
following packages are selected:

| Section       | Package    |
| ---           | ---        |
| devel         | binutils   |
| devel         | git        |
| devel         | gcc-core   |
| devel         | make       |
| utils         | diffutils  |

Click next and continue to the end of setup.

#### 2. Clone the Oberon compiler repository

Create and change to a directory in which to make the compiler and clone with this command:

`git clone https://github.com/vishaps/voc`

This will create a subdirectory 'voc' including the following files and directories:

| Name       | Content                                                                                    |
| ---        | ---                                                                                        |
| src/       | Compiler and library source, build tools and tests.                                        |
| bootstrap/ | Pre-generated C source for the compiler targetting the 5 distinct build models needed.     |
| doc/       | Documents (including this one).                                                            |
| makefile   | Makefile for all BSD- and Linux- like environments. Includes tests.                        |
| make.cmd   | Makefile specifically for native Microsoft C builds. No tests.                             |

#### 3. Build and install the Oberon compiler and library


```
cd voc
[sudo] make full
```

The makefile will:

 - Compile and run a C program that determines your C compiler and OS's configuration and creates
   the files Configuration.Make and Configuration.Mod.
 - C Compile the bootstrap C sources to generate an interim Oberon compiler for your configuration.
 - Use the interim compiler to compile the src/compiler and src/runtime directories and statically
   link the final Oberon compiler. This compiler is then used for the remaining steps.
 - Build the .sym file browser command `showdef`.
 - Build all the libraries in -O2 mode, and a subset in -OC mode.
 - Install the compiler and libraries by copying them to an appropriate location for your OS.
 - Run a set of confidence tests.


### Build using mingw under cygwin

### Build using Microsft C



#### Installation directories:

If it succeeds the makefile will end with instructions on how to set your path variable so that the
compiler (voc) is found.

The installation will be found at:

| Built with      | Install dir                            |
| --------------- | -------------------------------------- |
| cygwin          | /opt/voc                               |
| cygwin + mingw  | %PROGRAMFILES%/voc                     |
| MSC             | %PROGRAMFILES%/voc                     |

The installation directory contains:

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

User Oberon programs may be compiled using the -O2 (default) or -OC elementary type models. The elementary
types are as follows:

| Model         | 8 bit types | 16 bit types | 32 bit types        | 64 bit types        |
| ---           | ----        | ---          | ---                 | ---                 |
| -O2 (default) | `SHORTINT`  | `INTEGER`    | `LONGINT` and `SET` | `HUGEINT`           |
| -OC           | `BYTE`      | `SHORTINT`   | `INTEGER`           | `LONGINT` and `SET` |

Of course the size of pointer types is fixed by the OS.

The SYSTEM module has been updated to ease the development of platform independent code, with new
types such as `SYSTEM.INT8`, `SYSTEM.INT16`, `SYSTEM.INT32`, `SYSTEM.INT64` and `SYSTEM.ADDRESS`.

For more details, see [**Features**](doc/Features.md).

----

----

The size of compiler built is determined by the C compiler that runs, which is in turn determined by
the shell or command prompt configuration you are running under.

The following type sizes follow the built compiler size:

| Types          | 32 bit builds | 64 bit builds |
| -----          | ------------- | ------------- |
| INTEGER        | 16 bit        | 32 bit        |
| LONGINT, SET   | 32 bit        | 64 bit        |

Note that many library modules have been written with the assumption that INTEGER
is 16 bit and LONGINT 32 bit, therefore they will only work in 32 bit builds.

#### Which compiler? (gcc vs clang)

By default make uses the compiler defined in variable CC. This can be overriden by running 'export CC=gcc' or 'export CC=clang' from the command line before running make.

*Note*: be sure to run 'make clean' any time you change the value of CC. Otherwise directories will be mixed up.

*Note*: Darwin (MAC OS/X) redirects gcc to clang, so specifying CC=gcc still builds clang binaries under Darwin.


#### Building on Windows

There are three ways to build on Windows:

| Type               | How to build                                             | Compiled binary uses: |
| -----------        | -------                                                  | --------------------- |
| cygwin             | Use 'make' from cygwin bash shell.                       | cygwin.dll            |
| mingw under cygwin | Set CC for mingw then use 'make' from cygwin bash shell. | Win32 API             |
| Visual C           | Use 'make.cmd' from Visual C command prompt.             | Win32 API             |

##### mingw on cygwin

To use mingw, install the correct sized package and export CC= the compiler name:

 - For 32 bit cygwin

   - use setup-x86.exe to add the package mingw64-i686-gcc-core.
   - run 'export CC=i686-w64-mingw32-gcc' then 'make full'

 - For 64 bit cygwin

   - use setup-x86\_64.exe to add the package mingw64-x86\_64-gcc-core.
   - run 'export CC=x86_64-w64-mingw32-gcc' then 'make full'

(*Note*: Don't be put off by the name 'mingw64' in the 32 bit package.)

##### Microsoft Visual C compiler

Use the free command line Visual C++ compiler. At the time of writing it can be
downloaded here:

  http://landinghub.visualstudio.com/visual-cpp-build-tools

For example (Windows 10):

Start an adminstrator command prompt from the start button as follows:

    Start / All apps / Visual C++ Build Tools

Right click on

    Visual C++ 2015 x86 Native Build Tools Command Prompt

or

    Visual C++ 2015 x64 Native Build Tools Command Prompt

And select

    More / Administrative Command Prompt

#### How make adapts to each platform

On all platforms other than Visual C on Windows, make runs from a bash shell,
using makefile in the enlistment root, and vishap.make in the src/tools/make
directory.

For Visual C only, there is a slightly cut down implementation of the same
functionality in the file 'make.cmd' in the enlistment root.

In all cases src/tools/make/configure.c is executed to determine all
platform dependent parameters: it generates two files:

 - Configuration.Make: a set of environment variables included by the makefile
 - Configuration.Mod: An Oberon MODULE containing just configuraton constants.

The following examples correspond to a 32 bit Ubuntu build using GCC:

Configuration.Make:

    OLANGDIR=/home/dave/projects/oberon/olang
    COMPILER=gcc
    OS=ubuntu
    VERSION=1.2
    ONAME=voc
    DATAMODEL=ILP32
    INTSIZE=2
    ADRSIZE=4
    ALIGNMENT=4
    INSTALLDIR=/opt/voc
    PLATFORM=unix
    BINEXT=
    COMPILE=gcc -fPIC -g
    STATICLINK=-static
    LDCONFIG=if echo "/opt/voc/lib" >/etc/ld.so.conf.d/libvoc.conf; then ldconfig; fi

Configuration.Mod:

    MODULE Configuration;
    CONST
      name*        = 'voc';
      versionLong* = '1.2 [2016/06/11] for gcc ILP32 on ubuntu';
      intsize*     = 2;
      addressSize* = 4;
      alignment*   = 4;
      objext*      = '.o';
      objflag*     = ' -o ';
      linkflags*   = ' -L"';
      libspec*     = ' -l voc';
      compile*     = 'gcc -fPIC -g';
      dataModel*   = 'ILP32';
      installdir*  = '/opt/voc';
      staticLink*  = '-static';
    END Configuration.
