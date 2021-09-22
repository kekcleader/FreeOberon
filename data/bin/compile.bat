@ECHO OFF
REM This script is automatically run by Free Oberon on Windows
REM for each compiled module. The initial current directory of
REM the script is where FreeOberon executable is located.
REM You are free to edit this file to adjust the process.

CD bin >nul 2>&1
SET CURDIR=%~dp0
SET OFRDIR=%CURDIR%OfrontPlus\Target\Win64
SET PATH=%OFRDIR%;%CURDIR%mingw32\bin;%PATH%
SET OBERON=.;%CURDIR%..\..\src;%OFRDIR%\Lib\Sym
SET OFR=ofront+ -s -88 -7w

ECHO ON
@%OFR% %2 ..\Programs\%1
@SET RETCODE=%ERRORLEVEL%
@ECHO OFF
EXIT /b %RETCODE%
