@ECHO OFF
SET PROG=FreeOberon
SET OFRDIR=C:\prg\OfrontPlus\Target\Win64
SET GCCDIR=C:\prg\mingw-w64\mingw64\bin
SET PATH=%GCCDIR%;%OFRDIR%;%PATH%
REM SET SDL2Opts=-w -Wl,-subsystem,windows -lmingw32 -lSDL2main -lSDL2
SET SDL2Opts=-lmingw32 -lSDL2main -lSDL2
SET OFR=ofront+ -88 -C -s
SET OBERON=.;%OFRDIR%\Lib\Sym
SET CC=gcc
SET AR=ar
SET CCFULL=%CC% -g3 -O0 -fno-exceptions -I %OFRDIR%\..\..\Mod\Lib -I %OFRDIR%\Lib\Obj

ECHO ON
%OFR% Config_win32.Mod
%OFR% Int.Mod
%OFR% -i SDL2.Mod
%OFR% Graph.Mod
%OFR% Terminal.Mod
%OFR% Term.Mod
%OFR% OV.Mod
%OFR% EditorText.Mod
%OFR% Editor.Mod
%OFR% -m FreeOberon.Mod

windres resources.rc resources.o

REM                        -O0 change to -Os (?)   add -s (?)

%CCFULL% -c Int.c
%CCFULL% -c SDL2.c
%CCFULL% -c Graph.c
%AR% -crs ..\data\bin\libFreeOberon.a Int.o SDL2.o Graph.o

%CCFULL% Config.c term\term_win32.c Int.o SDL2.o Graph.o Term.c Terminal.c OV.c EditorText.c Editor.c %PROG%.c resources.o -o ..\%PROG%.exe %OFRDIR%\Lib\Ofront.a %SDL2Opts% -lSDL2_image
