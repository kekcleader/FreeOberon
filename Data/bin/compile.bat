@ECHO OFF
REM This script is automatically run by Free Oberon on Windows
REM for each compiled module. The initial current directory of
REM the script is where FreeOberon executable is located.
REM You are free to edit this file to adjust the process.

REM Set DIR = directory of this script






SET DIR=%~dp0

SET FNAME=%1

IF "%NFAME:~0,1%"=="\" GOTO ENDIF1
  SET FNAME=..\%FNAME%
:ENDIF1

IF NOT EXIST _Build MD _Build
CD _Build

SET OFRDIR=%DIR%OfrontPlus\Target\Win32
SET PATH=%OFRDIR%;%PATH%
SET OBERON=.;%DIR%..\..\src;%OFRDIR%\Lib\Sym
SET OFR=ofront+ -s -88 -7w

ECHO ON
@%OFR% %2 %FNAME%
@SET RETCODE=%ERRORLEVEL%
@ECHO OFF
@CD ..
EXIT /b %RETCODE%
