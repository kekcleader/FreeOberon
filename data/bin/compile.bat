@ECHO OFF
REM This script is run by Free Oberon on Windows. Current directory of the
REM script will be where FreeOberon.exe is located.
CD bin >nul 2>&1
SET CURDIR=%~dp0
SET OFRDIR=%CURDIR%OfrontPlus\Target\Win64
SET PATH=%OFRDIR%;%CURDIR%mingw32\bin;%PATH%
SET OBERON=.;%OFRDIR%\Lib\Sym
SET OFR=ofront+ -88 -C -s

ECHO ON
%OFR% %2 ..\Programs\%1
@SET RETCODE=%ERRORLEVEL%
@ECHO OFF
EXIT /b %RETCODE%
