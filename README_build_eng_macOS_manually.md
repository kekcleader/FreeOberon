# How to download, compile and install FreeOberon on macOS

This is a step by step instruction how to get, compile and run FreeOberon.

<img width="320" alt="Screenshot 2025-05-19 at 14 53 04" src="https://github.com/user-attachments/assets/3178d428-3449-4729-8f67-dec19c4f963a" />

![Screenshot 2025-05-19 at 15 15 37](https://github.com/user-attachments/assets/ac5287bd-4920-40fc-9ad0-fcc8bb0d097e)


- FreeOberon (FreeOberon) is a frontend with a text editor like Turbo Pascal for DOS
- ofront+ (OfrontPlus) is a Oberon to C source code translator
- OfrontPlus bootstrap (OfrontPlus-bootstrap) - some lowlevel bootstrap code differs for every target machine


## Step 1 - Requirements

Make sure you have the following packages installed.

### Install Allegro5

```
% brew install allegro
```
(If you do not have brew, install it, see https://brew.sh )

For more details about Allegro5, see https://github.com/liballeg/allegro5

If you are not sure if you have Allegro alredy installed.
```
% brew info allegro
==> allegro: stable 5.2.10.1 (bottled), HEAD
C/C++ multimedia library for cross-platform game development
https://liballeg.org/
Installed
...
```



## Step 2 - Create a working folder

Open Terminal and create a working folder.

For example:

```
% mkdir FreeOberon
% cd FreeOberon
```


## Step 3 - Download FreeOberon, ofront+ and OfrontPlus-bootstrap

Choose Button Code, then Download ZIP.

- Download zip FreeOberon, https://github.com/kekcleader/FreeOberon
- Download zip ofront+, https://github.com/Oleg-N-Cher/OfrontPlus
- Download zip https://github.com/Oleg-N-Cher/OfrontPlus-bootstrap

Place all zip files into your working folder.



## Step 4 - Unpack

- macOS, open Finder, double click zip for every zip you downloaded before.

Now you should have the follwing folder structure:

```
FreeOberon-main/
OfrontPlus-master/
OfrontPlus-bootstrap-master/

FreeOberon-main.zip
OfrontPlus-bootstrap-master.zip
OfrontPlus-master.zip
```



## Step 5 - Copy bootstrap unix-88 to FreeOberon
```
% cp ./OfrontPlus-bootstrap-master/unix-88/*  ./OfrontPlus-master/Target/macOS/Obj
% cp ./OfrontPlus-bootstrap-master/unix-88/*  ./OfrontPlus-master/Target/macOS/Lib/Obj
```

## Step 6 - compile libOfront

```
% cd ./OfrontPlus-master/Target/macOS/Lib/Bin
% ./cc
```

This creates
```
OfrontPlus-master/Target/macOS/Lib/libOfront.a
```


Go back to your WORKING folder:

```
cd ../../../../..
```





## Step 7 - compile ofront+ and tools


```
% cd ./OfrontPlus-master/Target/macOS/Bin
% ./cc
```


This will create:

```
./Target/macOS/graphviz
./Target/macOS/ocat
./Target/macOS/odc2txt
./Target/macOS/oef
./Target/macOS/ofront+
./Target/macOS/omake
./Target/macOS/showdef
```


Go back to your WORKING folder:

```
cd ../../../..
```




## Step 8 - check if ofront+ is working

Check if the new ofront+ is working with

```
% ./OfrontPlus-master/Target/macOS/ofront+
```

It should display something like this:

```
Ofront+ (TM) - Oberon family of languages to C Translator v1.0
Copyright (c) Software Templ OG, 1995-2020 & VEDAsoft Oberon Club, 2013-2025

  command = "ofront+" options {file options}.
  options = ["-" {option} ].
  option  = "m" | "s" | "e" | "i" | "r" | "x" | "a" | "p" | "t" | "f" | "d"
            [ "1" | "2" | "C" | "7" | "3" ]    [ "21" |"44" |"48" | "88" ].
       "m": generate a main module                                  (off)
       "s": allow changing the symbol file                          (off)
       "e": allow extending the module interface                    (off)
       "i": include header and body prefix files (Module.h0/.c0)    (off)
       "r": check value ranges                                      (off)
       "x": check array indices                                      (on)
       "a": check assertions                                         (on)
       "p": pointer initialization                                   (on)
       "t": check type guards                                        (on)
       "f": allow "proper FOR" (concept by Oleg Komlev)             (off)
       "d": translate a module into dynamic library (.dll/.so)      (off)
       "w": UTF-8 to UCS-2 wide character transcoding enabled       (off)
  "1": Oberon "2": Oberon-2 "C": Component Pascal "7": Oberon-07 "3": Oberon-3
  "21": 16-bit addresses, SIZE(SET) = 1 byte (e.g. Zilog Z80 CPU)
  "44": 32-bit addresses, 32-bit alignment (32-bit UNIX/Linux on x86)
  "48": 32-bit addresses, 64-bit alignment (32-bit Windows, 32-bit Linux/ARMv7)
  "88": 64-bit addresses, 64-bit alignment (64-bit platforms)
```








## Step 9 - Put OfontPlus in place to FreeOberon


Rename old folder for backup:

```
% mv FreeOberon-main/Data/bin/OfrontPlus  FreeOberon-main/Data/bin/OfrontPlus-NOT-USED
```

Copy the wohle OfrontPlus-master to your FreeOberbon OfrontPlus folder:

```
% cp -R ./OfrontPlus-master/  ./FreeOberon-main/Data/bin/OfrontPlus
```






## Step 10 - compile if ofront+ Lib/Bin

```
% cd ./FreeOberon-main/Data/bin/OfrontPlus/Target/macOS/Lib/Bin
% ./build
```

Output:

```
Heap.cp  translating Heap  new symbol file    20010    
Platform.Unix.cp  translating Platform  new symbol file    23040    
Console.cp  translating Console  new symbol file    4907    
Kernel.cp  translating Kernel  new symbol file    4968    
CmdArgs.Unix.cp  translating CmdArgs  new symbol file    4060    
Math.cp  translating Math  new symbol file    21309    
MathL.cp  translating MathL  new symbol file    21743    
Reals.cp  translating Reals  new symbol file    10584    
Strings.cp  translating Strings  new symbol file    11155    
Files.cp  translating Files  new symbol file    35070    
Modules.cp  translating Modules  new symbol file    3365    
Texts.cp  translating Texts  new symbol file    56426    
Oberon.cp  translating Oberon  new symbol file    3062    
ecoBigSets.cp  translating ecoBigSets  new symbol file    6307    
ecoBuffer.cp  translating ecoBuffer  new symbol file    1303    
ecoListen.cp  translating ecoListen  new symbol file    3277    
ecoLists.cp  translating ecoLists  new symbol file    12453    
ecoParser.cp  translating ecoParser  new symbol file    21057    
ecoVector.cp  translating ecoVector  new symbol file    8679    
Zlib.ob2  translating Zlib  new symbol file    2463    
ZlibBuffers.ob2  translating ZlibBuffers  new symbol file    6540    
ZlibDeflate.ob2  translating ZlibDeflate  new symbol file    69756    
ZlibInflate.ob2  translating ZlibInflate  new symbol file    54967    
ZlibReaders.ob2  translating ZlibReaders  new symbol file    4659    
ZlibWriters.ob2  translating ZlibWriters  new symbol file    6290    
Zip.ob2  translating Zip  new symbol file    25496    
oo2cAscii.cp  translating oo2cAscii  new symbol file    240    
oo2cConvTypes.cp  translating oo2cConvTypes  new symbol file    629    
oo2cLongStrings.cp  translating oo2cLongStrings  new symbol file    18119    
oo2cRandomNumbers.cp  translating oo2cRandomNumbers  new symbol file    1753    
oo2cStrings.cp  translating oo2cStrings  new symbol file    16056    
powStrings.cp  translating powStrings  new symbol file    20381    
SDL2.cp  translating SDL2  new symbol file    7748    
SDL2mixer.cp  translating SDL2mixer  new symbol file    3963    
SQLite.cp  translating SQLite  new symbol file    1035    
Out.cp  translating Out  new symbol file    11490    
In.cp  translating In  new symbol file    5689    
Graph.cp  translating Graph  new symbol file    56349    
Sound.cp  translating Sound  new symbol file    1585    
Turtle.cp  translating Turtle  new symbol file    5127    
libCurl.cp  translating libCurl  new symbol file    662    
NetHttp.cp  translating NetHttp  new symbol file    3921    
arArgs.ob2  translating arArgs  new symbol file    810    
arC.ob2  translating arC  new symbol file    41    
arCFormat.ob2  translating arCFormat  new symbol file    664    
arChar.ob2  translating arChar  new symbol file    1104    
arCString.ob2  translating arCString  new symbol file    1281    
arDir.ob2  translating arDir  new symbol file    2419    
arMath.ob2  translating arMath  new symbol file    1518    
arSize.ob2  translating arSize  new symbol file    1884    
arStrings.ob2  translating arStrings  new symbol file    7951    
arStringList.ob2  translating arStringList  new symbol file    4611    
arStringAssoc.ob2  translating arStringAssoc  new symbol file    4719    
arText.ob2  translating arText  new symbol file    15330    
arStream.ob2  translating arStream  new symbol file    4777    
arFile.ob2  translating arFile  new symbol file    8089    
arOut.ob2  translating arOut  new symbol file    2562    
arPath.ob2  translating arPath  new symbol file    1887    
arPattern.ob2  translating arPattern  new symbol file    11486    
arErr.ob2  translating arErr  new symbol file    2562    
arConfiguration.ob2  translating arConfiguration  new symbol file    28120    
arValue.ob2  translating arValue  new symbol file    57887    
arFormat.ob2  translating arFormat  new symbol file    11379    
arJSON.ob2  translating arJSON  new symbol file    11239    
bbLinLibc.cp  translating bbLinLibc  new symbol file    6323    
bbLinLibW.cp  translating bbLinLibW  new symbol file    2200    
bbKernel.Unix.cp  translating bbKernel  new symbol file    10413    
bbMath.cp  translating bbMath  new symbol file    16473    
bbStrings.cp  translating bbStrings  new symbol file    41850    
```


Back to working folder:

```
% cd ../../../../../../../..
```



Build OfrontPlus bin:


```
% cd ./FreeOberon-main/Data/bin/OfrontPlus/Target/macOS/Bin
% ./build
```

Output:

```
OfrontErrors.cp  translating OfrontErrors  new symbol file    19678    
OfrontOPM.cmdln.cp  translating OfrontOPM  new symbol file    42996    
OfrontOPS.cp  translating OfrontOPS  new symbol file    28147    
OfrontOPT.cp  translating OfrontOPT  new symbol file    107556    
OfrontOPB.cp  translating OfrontOPB  new symbol file    126989    
OfrontOPP.cp  translating OfrontOPP  new symbol file    122247    
OfrontOPC.cp  translating OfrontOPC  new symbol file    95485    
OfrontOPV.cp  translating OfrontOPV  new symbol file    77696    
BrowserCmd.cp  translating BrowserCmd  main program    30742    
ImportGraph.cp  translating ImportGraph  main program    19081    
OCatCmd.cp  translating OCatCmd  main program    1777    
OfrontCmd.cp  translating OfrontCmd  main program    3229    
OdcToText.ob3  translating OdcToText  main program    14612    
OEF.ob2  translating OEF  main program    10709    
OMake.ob2  translating OMake  main program    26579    
```



This creates updates also a new libOftront.a

```
./macOS/Lib/libOfront.a
```


Back to working folder:

```
cd ../../../../../../..
```



## Step 11 - compile FreeOberon


```
% cd FreeOberon-main

% bash ./install.sh
```


```
  This script will install Free Oberon.

Free Oberon dependencies are:
 * Allegro5 - for the module Graph and the graphical IDE
 * Git - to download Ofront+
 * GCC - to compile the generated C-code

You can find the information on how to install the dependencies
in the README.md file.

Debian / Ubuntu / Linux Mint etc.:
  sudo apt-get update
  sudo apt-get install -y git gcc libc-dev liballegro5-dev liballegro-image5-dev liballegro-audio5-dev liballegro-acodec5-dev
or, if sudo is not installed (on Debian):
  su
  apt-get update
  apt-get install -y git gcc libc-dev liballegro5-dev liballegro-image5-dev liballegro-audio5-dev liballegro-acodec5-dev

Fedora:
  sudo dnf install -y git gcc glibc-devel allegro5-devel allegro5-addon-image allegro5-addon-audio allegro5-addon-acodec allegro5-devel allegro5-addon-image-devel allegro5-addon-audio-devel allegro5-addon-acodec-devel

Arch Linux:
  sudo pacman -Sy git gcc pkgconf glibc allegro

openSUSE:
  sudo zypper install -y git gcc glibc-devel liballegro5_2-devel liballegro_audio5_2-devel liballegro_image5_2-devel liballegro_primitives5_2-devel liballegro_dialog5_2-devel liballegro_acodec5_2-devel liballegro_acodec5_2-devel liballegro_font5_2-devel

  Are the dependencies installed? [y/n] y


  Downloading Ofront+...
  ~~~~~~~~~~~~~~~~~~~~~~
  Ofront+ already present.
  If there are errors in installation process, delete Data/bin/OfrontPlus

  Building Ofront+...
  ~~~~~~~~~~~~~~~~~~~
OfrontErrors.cp  translating OfrontErrors    19678    
OfrontOPM.cmdln.cp  translating OfrontOPM    42996    
OfrontOPS.cp  translating OfrontOPS    28147    
OfrontOPT.cp  translating OfrontOPT    107556    
OfrontOPB.cp  translating OfrontOPB    126989    
OfrontOPP.cp  translating OfrontOPP    122247    
OfrontOPC.cp  translating OfrontOPC    95485    
OfrontOPV.cp  translating OfrontOPV    77696    
BrowserCmd.cp  translating BrowserCmd  main program    30742    
ImportGraph.cp  translating ImportGraph  main program    19081    
OCatCmd.cp  translating OCatCmd  main program    1777    
OfrontCmd.cp  translating OfrontCmd  main program    3229    
OdcToText.ob3  translating OdcToText  main program    14612    
OEF.ob2  translating OEF  main program    10709    
OMake.ob2  translating OMake  main program    26579    

  Building Free Oberon...
  ~~~~~~~~~~~~~~~~~~~~~~~
Config.Mod  translating Config  new symbol file    521    
Func.Mod  translating Func  new symbol file    483    
Utf8.Mod  translating Utf8  new symbol file    5825    
Strings.Mod  translating Strings  new symbol file    7897    
Reals.Mod  translating Reals  new symbol file    15180    
Int.Mod  translating Int  new symbol file    3052    
Time.Mod  translating Time  new symbol file    2640    
In.Mod  translating In  new symbol file    8553    
Out.Mod  translating Out  new symbol file    5624    
Debug.Mod  translating Debug  new symbol file    1735    
Args.Mod  translating Args  new symbol file    1250    
Env.Mod  translating Env  new symbol file    7266    
Files.Mod  translating Files  new symbol file    40029    
Texts.Mod  translating Texts  new symbol file    23418    
Random.Mod  translating Random  new symbol file    1708    
StrList.Mod  translating StrList  new symbol file    4534    
Dir.Mod  translating Dir  new symbol file    5624    
Allegro5.Mod  translating Allegro5  new symbol file    15576    
Graph.Mod  translating Graph  new symbol file    77947    
Sound.Mod  translating Sound  new symbol file    2750    
TermBox.Mod  translating TermBox  new symbol file    32464    
Term.Mod  translating Term  new symbol file    1074    
OV.Mod  translating OV  new symbol file    90505    
FoStrings.Mod  translating FoStrings  new symbol file    6937    
EditorText.Mod  translating EditorText  new symbol file    28820    
Editor.Mod  translating Editor  new symbol file    66519    
Builder.Mod  translating Builder  new symbol file    36655    
FreeOberon.Mod  translating FreeOberon  main program    62964    
Fob.Mod  translating Fob  main program    4846    
FreeOberon.c:454:9: warning: passing arguments to 'ProcessFinished' without a prototype is deprecated in all versions of C and is not supported in C2x [-Wdeprecated-non-prototype]
  454 |     if (Term_ProcessFinished(&err)) {
      |         ^
./Term.oh:14:51: note: expanded from macro 'Term_ProcessFinished'
   14 | #define Term_ProcessFinished(err)  ProcessFinished(err)
      |                                                   ^
FreeOberon.c:492:23: warning: passing 'CHAR[2048]' (aka 'unsigned char[2048]') to parameter of type 'char *' converts between pointers to integer types where one is of the unique plain 'char' type and the other is not [-Wpointer-sign]
  492 |   Term_WriteToProcess(buf, 2048, bufLen);
      |                       ^~~
./Term.oh:21:65: note: expanded from macro 'Term_WriteToProcess'
   21 | #define Term_WriteToProcess(buf, buf__len, len)  WriteToProcess(buf, len)
      |                                                                 ^~~
./term/term.h:6:26: note: passing argument to parameter 'buf' here
    6 | int WriteToProcess(char *buf, int len);
      |                          ^
FreeOberon.c:523:29: warning: passing 'CHAR[2]' (aka 'unsigned char[2]') to parameter of type 'char *' converts between pointers to integer types where one is of the unique plain 'char' type and the other is not [-Wpointer-sign]
  523 |         Term_WriteToProcess(buf, 2, 1);
      |                             ^~~
./Term.oh:21:65: note: expanded from macro 'Term_WriteToProcess'
   21 | #define Term_WriteToProcess(buf, buf__len, len)  WriteToProcess(buf, len)
      |                                                                 ^~~
./term/term.h:6:26: note: passing argument to parameter 'buf' here
    6 | int WriteToProcess(char *buf, int len);
      |                          ^
FreeOberon.c:603:27: warning: passing 'CHAR[2048]' (aka 'unsigned char[2048]') to parameter of type 'char *' converts between pointers to integer types where one is of the unique plain 'char' type and the other is not [-Wpointer-sign]
  603 |   if (Term_StartProcessIn(s, 2048, d, 2048)) {
      |                           ^
./Term.oh:20:75: note: expanded from macro 'Term_StartProcessIn'
   20 | #define Term_StartProcessIn(cmd, cmd__len, dir, dir__len)  StartProcessIn(cmd, dir)
      |                                                                           ^~~
./term/term.h:4:26: note: passing argument to parameter 'process' here
    4 | int StartProcessIn(char *process, char *dir);
      |                          ^
FreeOberon.c:603:36: warning: passing 'CHAR[2048]' (aka 'unsigned char[2048]') to parameter of type 'char *' converts between pointers to integer types where one is of the unique plain 'char' type and the other is not [-Wpointer-sign]
  603 |   if (Term_StartProcessIn(s, 2048, d, 2048)) {
      |                                    ^
./Term.oh:20:80: note: expanded from macro 'Term_StartProcessIn'
   20 | #define Term_StartProcessIn(cmd, cmd__len, dir, dir__len)  StartProcessIn(cmd, dir)
      |                                                                                ^~~
./term/term.h:4:41: note: passing argument to parameter 'dir' here
    4 | int StartProcessIn(char *process, char *dir);
      |                                         ^
5 warnings generated.

  Done building Free Oberon
  ~~~~~~~~~~~~~~~~~~~~~~~~~

  Free Oberon is installed. You can now run: ./FreeOberon
  Add the following line to ~/.bashrc to use the command fob:
  export PATH=/Volumes/Apps/Emulators/FreeOberon--2025-04apr-29/FreeOberon-main:$PATH
  To run Free Oberon IDE in a specific language, type ./FreeOberon --lang ru
  To run Free Oberon IDE in a a window, type ./FreeOberon --window
```



Add the following line to ~/.bashrc to use the command fob:
```
export PATH=/Volumes/Apps/Emulators/FreeOberon--2025-04apr-29/FreeOberon-main:$PATH
```

```
% export PATH=/Volumes/Apps/Emulators/FreeOberon/FreeOberon--2025-05may-19-3--manually/FreeOberon-main:$PATH
```

% ./fob
```
Free Oberon Compiler version 1.1.0-alpha.8
Copyright (c) 2017-2025 by Arthur Yefimov and others.
Fob uses Ofront+ and GCC (MinGW).

Usage:
  fob sourceFile
  fob --lang ru sourceFile

Please specify a single file name - the main module source
```




## run examples and FreeOberon IDE



```
% ./fob ./Programs/Examples/DirTest.Mod
```

```
% ./DirTest
[.]
[..]
[Programs]
[_Build]
[Data]
...
```


```
./fob ./Programs/Examples/FlyingDot.Mod 
./FlyingDot
```


Run FreeOberon IDE

```
./FreeOberon
```

Menu File, Load ./Examples/Mandelbrot.Mod
Menu Compile, Compile
Be patient, it will calculate Mandelbrot set afer a few seconds and shows:


Depending on your graphics you need to adjust it.

Change:
```
BEGIN G.Settings(320, 200, {G.exact});
```
To 2048, 1152 for example.

Or use fullscreen:
```
G.Settings(0, 0, {G.fullscreen});
```
Or use windowing monde:
```
G.Settings(640, 480, {G.exact, G.window});
```

<img width="320" alt="Screenshot 2025-05-19 at 14 53 04" src="https://github.com/user-attachments/assets/a3c30d8b-58f5-4896-8170-5bb005697495" />

<img width="320" alt="Screenshot 2025-05-19 at 14 58 39" src="https://github.com/user-attachments/assets/887b8274-4e16-4058-8a21-07e846279302" />

<img width="320" alt="Screenshot 2025-05-19 at 14 58 52" src="https://github.com/user-attachments/assets/cc3a5ec4-7fee-47ac-992a-476129ef60b5" />

