@ECHO OFF
REM This script is run by Free Oberon on Windows
REM to link a console program.
REM When it is being run, the current directory
REM must be the root directory of Free Oberon.


REM Set DIR = directory of this script





SET DIR=%~dp0

CD _Build >nul 2>&1


SET ONAME=%~n1
SET GCCDIR=%DIR%mingw32\bin
SET FOBDIR=%DIR%..\..
SET OFRDIR=%DIR%OfrontPlus
SET OFRTAR=%OFRDIR%\Target\Win32
SET PATH=%OFRTAR%;%GCCDIR%;%PATH%
SET CC=gcc

REM Put all arguments starting from the 2nd to ARGS
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

@DEL /s %~n1.exe >nul 2>&1

@%CC% -O0 -fno-exceptions ^
  -I %FOBDIR%\src ^
  -I %OFRDIR%\Mod\Lib ^
  -I %OFRTAR%\Lib\Obj ^
  %ONAME%.c -o %ONAME%.exe ^
  %ARGS% ^
  %FOBDIR%\Data\bin\FreeOberon.a ^
  %OFRTAR%\Lib\Ofront.a ^
  -Wl,-e_WinMain@16 -nostartfiles ^
  %OFRDIR%\Mod\Lib\crt1.c

@SET RETCODE=%ERRORLEVEL%

@CD ..
@EXIT /b %RETCODE%
