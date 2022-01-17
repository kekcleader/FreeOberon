@ECHO OFF
REM This script is run by Free Oberon on Windows. Current directory of the
REM script will be where FreeOberon.exe is located. This particular script
REM is for graphical programs.

CD bin >nul 2>&1
@DEL /s %~n1.exe >nul 2>&1
SET CURDIR=%~dp0
SET ONAME=%~n1
SET OFRDIR=%CURDIR%OfrontPlus\Target\Win32
SET PATH=%OFRDIR%;%CURDIR%mingw32\bin;%PATH%
ECHO %OFRDIR%;%CURDIR%mingw32\bin;%%PATH
SET CC=gcc

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
  -I %CURDIR%..\..\src ^
  -I %OFRDIR%\..\..\Mod\Lib ^
  -I %OFRDIR%\Lib\Obj ^
  %ONAME%.c -o %ONAME%.exe ^
  %ARGS%^
  %CURDIR%FreeOberon.a ^
  %OFRDIR%\Lib\Ofront.a
@SET RETCODE=%ERRORLEVEL%

@EXIT /b %RETCODE%
