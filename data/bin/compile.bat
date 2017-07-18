@ECHO OFF
REM This script is run by Free Oberon on Windows.
REM Current directory of the script will be where
REM FreeOberon.exe is located.
REM This particular script is for graphical programs.
CD bin >nul 2>&1
@DEL /s %~n1.exe >nul 2>&1
SET CURDIR=%~dp0
SET PATH=%CURDIR%voc\bin;%CURDIR%mingw32\bin;%PATH%
ECHO ON
@CALL voc -OC -cfFm ..\Programs\%1
@SET MYEXITCODE=%ERRORLEVEL%
@ECHO OFF
IF "%MYEXITCODE%"=="0" GOTO OK1
GOTO END1
:OK1
gcc -fPIC -g -I "%CURDIR%voc/C/include" -o %~n1.exe %~n1.o "%CURDIR%voc/lib/Graph.o" "%CURDIR%voc/lib/SDL2.o" -L"%CURDIR%voc/lib" -lvoc-OC -w -Wl,-subsystem,windows -lmingw32 -lSDL2main -lSDL2 -lSDL2_image
SET MYEXITCODE=%ERRORLEVEL%
:END1
EXIT /b %MYEXITCODE%
