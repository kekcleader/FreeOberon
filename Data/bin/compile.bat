@ECHO OFF
REM This script is automatically run by Free Oberon on Windows
REM for each compiled module. The initial current directory of
REM the script is where FreeOberon executable is located.
REM You are free to edit this file to adjust the process.

REM Set DIR = directory of this script






SET DIR=%~dp0

SET FNAME=%1

REM If "C:Dir\Dir2"-style relative path given
IF NOT "%FNAME:~1,1%"==":" GOTO ENDIF1
IF "%FNAME:~2,1%"=="\" GOTO ENDIF1
  SET FNAME=%FNAME:~0,2%..\%FNAME:~2%
  GOTO ENDIF2
:ENDIF1
REM Else if not "\" or "C:\"-style absolute path
IF "%FNAME:~0,1%"=="\" GOTO ENDIF2
IF "%FNAME:~1,2%"==":\" GOTO ENDIF2
  SET FNAME=..\%FNAME%
:ENDIF2

IF NOT EXIST _Build MD _Build
CD _Build || EXIT /b 407

SET OFRDIR=%DIR%OfrontPlus\Target\Win32
SET PATH=%OFRDIR%;%PATH%
SET OBERON=.;%DIR%..\..\src;%OFRDIR%\Lib\Sym
SET OFR=ofront+ -s -48 -7w

ECHO ON
@%OFR% %2 %FNAME%
@SET RETCODE=%ERRORLEVEL%
@ECHO OFF
CD ..
EXIT /b %RETCODE%
