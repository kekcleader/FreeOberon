@ECHO OFF
SET PROG=GTest
SET OFRDIR=..\Data\bin\OfrontPlus\Target\Win32
SET GCCDIR=C:\mingw-w64\i686\mingw32\bin
SET PATH=%GCCDIR%;%OFRDIR%;%PATH%
SET OBERON=.;%OFRDIR%\Lib\Sym


SET OFR=ofront+ -s -48
SET CC=gcc
SET AR=ar
SET CCFULL=%CC% -g3 -O0 -fno-exceptions -I %OFRDIR%\..\..\Mod\Lib -I %OFRDIR%\Lib\Obj

ECHO ON
%OFR% -7w Allegro5.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7w Graph.Mod
@IF ERRORLEVEL 1 GOTO ERR
%OFR% -7wm GTest.Mod
@IF ERRORLEVEL 1 GOTO ERR

%CCFULL% -o ..\%PROG%.exe resources.o ^
  Graph.c ^
  %PROG%.c ^
  ..\Data\bin\FreeOberon.a ^
  %OFRDIR%\Lib\Ofront.a ^
  -lallegro -lallegro_primitives -lallegro_image

@GOTO QUIT
:ERR
@EXIT/B 1
:QUIT
