@ECHO OFF
REM This script is run by Free Oberon on Windows. Current directory of the
REM script will be where FreeOberon.exe is located.
CD bin >nul 2>&1
SET CURDIR=%~dp0
SET PATH=%CURDIR%voc\bin;%CURDIR%mingw32\bin;%PATH%
ECHO ON
@CALL voc -OC -cfF %2 ..\Programs\%1
@SET MYEXITCODE=%ERRORLEVEL%
@ECHO OFF
EXIT /b %MYEXITCODE%
