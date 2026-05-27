@ECHO OFF
REM This script is run by Free Oberon on Windows
REM to link a graphics program.
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

REM Put all args from 2nd upto --linker-libs to FILES, put others in FLAGS
REM Also handle --variant Module:Variant arguments
SHIFT
SET FILES=
SET VARIANT_OBJ=
:START
IF [%1] == [] GOTO FINISH
IF [%1] == [--linker-libs] GOTO FLAGSLOOP
IF [%1] == [--variant] GOTO VARIANTARG
SET FILES=%FILES% %1
SHIFT
GOTO START
:VARIANTARG
SHIFT
REM Parse Module:Variant from %1
FOR /F "tokens=1,2 delims=:" %%A IN ("%1") DO (
  IF EXIST "%FOBDIR%\Data\bin\Variants\%%A\%%B\%%A.o" (
    SET VARIANT_OBJ=%VARIANT_OBJ% %FOBDIR%\Data\bin\Variants\%%A\%%B\%%A.o
  )
)
SHIFT
GOTO START
:FLAGSLOOP
SHIFT
SET FLAGS=
:START2
IF [%1] == [] GOTO FINISH
SET FLAGS=%FLAGS% %1
SHIFT
GOTO START2
:FINISH
REM END: Put all FILES and FLAGS
ECHO ON

@DEL /s %~n1.exe >nul 2>&1

@%CC% -O0 -fno-exceptions ^
  -I %FOBDIR%\src ^
  -I %OFRDIR%\Mod\Lib ^
  -I %OFRTAR%\Lib\Obj ^
  %ONAME%.c -o %ONAME%.exe ^
  %FILES% ^
  %VARIANT_OBJ% ^
  %FOBDIR%\Data\bin\FreeOberon.a ^
  %OFRTAR%\Lib\Ofront.a ^
  -I..\Data\bin\mingw32\include ^
  -Wl,-e_WinMain@16 -nostartfiles ^
  %OFRDIR%\Mod\Lib\crt1.c ^
  %FLAGS%

@SET RETCODE=%ERRORLEVEL%

@CD ..
@EXIT /b %RETCODE%
