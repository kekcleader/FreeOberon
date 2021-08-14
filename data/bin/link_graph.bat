@ECHO OFF
REM This script is run by Free Oberon on Windows. Current directory of the
REM script will be where FreeOberon.exe is located. This particular script
REM is for graphical programs.

CD bin >nul 2>&1
@DEL /s %~n1.exe >nul 2>&1
SET CURDIR=%~dp0
SET ONAME=%~n1
SET OFRDIR=%CURDIR%OfrontPlus\Target\Win64
SET PATH=%OFRDIR%;%CURDIR%mingw64\bin;%PATH%
SET CC=gcc
REM SET SDL2Opts=-w -Wl,-subsystem,windows -lmingw32 -lSDL2main -lSDL2
SET SDL2Opts=-lmingw32 -lSDL2main -lSDL2

REM Put all arguments starting from 2nd to ARGS.
SHIFT
SET ARGS=%1
SHIFT
:START
IF [%1] == [] GOTO FINISH
SET ARGS=%ARGS% %1
SHIFT
GOTO START
:FINISH
REM END Put all ARGS.
ECHO ON

%CC% -g3 -O0 -fno-exceptions ^
  -I %OFRDIR%\..\..\Mod\Lib ^
  -I %OFRDIR%\Lib\Obj ^
  %ONAME%.c -o %ONAME%.exe ^
  %ARGS%^
  %CURDIR%libFreeOberon.a ^
  %OFRDIR%\Lib\Ofront.a ^
  %SDL2Opts% -lSDL2_image
@SET RETCODE=%ERRORLEVEL%

@EXIT /b %RETCODE%
