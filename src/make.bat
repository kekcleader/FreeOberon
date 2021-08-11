@SET PROG=FreeOberon
@SET OFRDIR=C:\prg\OfrontPlus\Target\Win64
@REM SET SDL2Opts=-w -Wl,-subsystem,windows -lmingw32 -lSDL2main -lSDL2
@SET SDL2Opts=-lmingw32 -lSDL2main -lSDL2
@SET OFR=ofront+ -88 -C -s

%OFR% Config_win32.Mod
%OFR% Int.Mod
%OFR% -i SDL2.Mod
%OFR% Graph.Mod
%OFR% Terminal.Mod
%OFR% Term.Mod
%OFR% OV.Mod
%OFR% EditorText.Mod
%OFR% Editor.Mod
%OFR% -m FreeOberon.Mod

windres resources.rc resources.o

REM                        -O0 change to -Os (?)   add -s (?)
gcc -g3 -O0 -fno-exceptions -I %OFRDIR%\..\..\Mod\Lib -I %OFRDIR%\Lib\Obj Config.c term\term_win32.c Int.c SDL2.c Graph.c Term.c Terminal.c OV.c EditorText.c Editor.c %PROG%.c resources.o -o ..\%PROG%.exe %OFRDIR%\Lib\Ofront.a %SDL2Opts% -lSDL2_image