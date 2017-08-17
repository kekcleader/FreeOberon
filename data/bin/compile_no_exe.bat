@ECHO OFF
REM This script is run by Free Oberon on Windows.
REM Current directory of the script will be where
REM FreeOberon.exe is located.
REM This particular script is for compilation with no executable.
CD bin >nul 2>&1
@DEL /s %~n1.exe >nul 2>&1
SET CURDIR=%~dp0
SET PATH=%CURDIR%voc\bin;%CURDIR%mingw32\bin;%PATH%
ECHO ON
@CALL voc -OC -cfFm ..\Programs\%1
@SET MYEXITCODE=%ERRORLEVEL%
@ECHO OFF
EXIT /b %MYEXITCODE%
