@ECHO OFF
SET PROG=FreeOberon
SET OFRDIR=..\data\bin\OfrontPlus\Target\Win64
SET GCCDIR=..\data\bin\mingw-w64\mingw64\bin
SET PATH=%GCCDIR%;%OFRDIR%;%PATH%
SET OBERON=.;%OFRDIR%\Lib\Sym
REM SET SDL2Opts=-w -Wl,-subsystem,windows -lmingw32 -lSDL2main -lSDL2
SET SDL2Opts=-lmingw32 -lSDL2main -lSDL2
SET OFR=ofront+ -s -88
SET CC=gcc
SET AR=ar
SET CCFULL=%CC% -g3 -O0 -fno-exceptions -I %OFRDIR%\..\..\Mod\Lib -I %OFRDIR%\Lib\Obj

ECHO ON
%OFR% -C Config_win32.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C Int.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7 StrList.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7 Dir.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C -i SDL2.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C Graph.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C Terminal.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C Term.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C OV.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C EditorText.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C Editor.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -C -m FreeOberon.Mod
@IF ERRORLEVEL 1 GOTO ERR
windres resources.rc resources.o
@REM                        -O0 change to -Os (?)   add -s (?)
%CCFULL% -c Int.c
%CCFULL% -c StrList.c
%CCFULL% -c Dir.c
%CCFULL% -c SDL2.c
%CCFULL% -c Graph.c
%AR% -crs ..\data\bin\libFreeOberon.a Int.o StrList.o Dir.o SDL2.o Graph.o

%CCFULL% Config.c term\term_win32.c ^
  Int.o StrList.o Dir.o SDL2.o Graph.o ^
  Term.c Terminal.c OV.c EditorText.c Editor.c ^
  %PROG%.c -o ..\%PROG%.exe resources.o ^
  %OFRDIR%\Lib\Ofront.a ^
  %SDL2Opts% -lSDL2_image

@GOTO QUIT
:ERR
@EXIT/B 1
:QUIT
