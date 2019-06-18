@ECHO OFF
REM This script is run by Free Oberon on Windows. Current directory of the
REM script will be where FreeOberon.exe is located. This
REM particular script is for console programs.
CD bin >nul 2>&1
@DEL /s %~n1.exe >nul 2>&1
SET CURDIR=%~dp0
SET PATH=%CURDIR%voc\bin;%CURDIR%mingw32\bin;%PATH%
ECHO ON
gcc -fPIC -g -I "%CURDIR%voc/C/include" -o %~n1.exe %~n1.o -L"%CURDIR%voc/lib" -lvoc-OC -lmingw32
SET MYEXITCODE=%ERRORLEVEL%
EXIT /b %MYEXITCODE%
