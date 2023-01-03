@ECHO OFF
SET PROG1=FreeOberon
SET PROG2=fob
SET OFRDIR=..\Data\bin\OfrontPlus\Target\Win32
SET GCCDIR=C:\prg\mingw32\bin
REM SET GCCDIR=..\Data\bin\mingw32\bin
SET PATH=%GCCDIR%;%OFRDIR%;%PATH%
SET OBERON=.;%OFRDIR%\Lib\Sym


SET OFR=ofront+ -s -48
SET CC=gcc
SET AR=ar
SET CCFULL=%CC% -O3 -fno-exceptions -I %OFRDIR%\..\..\Mod\Lib -I %OFRDIR%\Lib\Obj

ECHO ON
%OFR% -Cw Config.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Func.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Utf8.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Strings.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Reals.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Int.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw In.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Out.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Debug.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Args.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Env.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Files.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Texts.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Random.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w StrList.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Dir.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Allegro5.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Graph.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w TermBox.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Term.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w OV.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w FoStrings.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw EditorText.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Editor.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cw Builder.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -Cwm FreeOberon.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7wm Fob.Mod
@IF ERRORLEVEL 1 GOTO ERR
windres resources.rc resources.o
@IF ERRORLEVEL 1 GOTO ERR

%CCFULL% -c Utf8.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Strings.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Reals.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Int.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c In.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Out.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Args.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Env.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Files.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Texts.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Random.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c StrList.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Dir.c -I..\Data\bin\mingw32\include
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c Graph.c
@IF ERRORLEVEL 1 GOTO ERR
%CCFULL% -c TermBox.c
@IF ERRORLEVEL 1 GOTO ERR

%AR% -crs ..\Data\bin\FreeOberon.a ^
  Utf8.o Strings.o Reals.o Int.o In.o Out.o Args.o Env.o ^
  Files.o Texts.o Random.o ^
  StrList.o Dir.o Graph.o TermBox.o
@IF ERRORLEVEL 1 GOTO ERR

%CCFULL% -o ..\%PROG1%.exe resources.o ^
  Graph.c TermBox.c ^
  Config.c Func.c Debug.c term\term_win32.c ^
  Term.c OV.c FoStrings.c EditorText.c Editor.c Builder.c ^
  FreeOberon.c ^
  ..\Data\bin\FreeOberon.a ^
  %OFRDIR%\Lib\Ofront.a ^
  -lallegro -lallegro_primitives -lallegro_image ^
  -I..\Data\bin\mingw32\include ^
  -Wl,-e_WinMain@16 ^
  -nostartfiles %OFRDIR%\..\..\Mod\Lib\crt1.c ^
  -Wl,-subsystem,windows

%CCFULL% -o ..\%PROG2%.exe ^
  FoStrings.c Builder.c ^
  Term.c term/term_win32.c ^
  Config.c Func.c Debug.c Fob.c ^
  ..\Data\bin\FreeOberon.a ^
  %OFRDIR%\Lib\Ofront.a ^
  -I..\Data\bin\mingw32\include ^
  -Wl,-e_WinMain@16 ^
  -nostartfiles %OFRDIR%\..\..\Mod\Lib\crt1.c

@GOTO QUIT
:ERR
@EXIT/B 1
:QUIT
