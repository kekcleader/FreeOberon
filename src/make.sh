PROG="FreeOberon"
OFRDIR="$OBPATH"
SDL2Opts="-lSDL2"
OFR="ofront+ -88 -C -s"
export OBERON=.:$OBPATH/Lib/Sym:$OBPATH/Sym

$OFR Config_linux.Mod
$OFR Int.Mod
$OFR -i SDL2.Mod
$OFR Graph.Mod
$OFR Terminal.Mod
$OFR Term.Mod
$OFR OV.Mod
$OFR EditorText.Mod
$OFR Editor.Mod
$OFR -m FreeOberon.Mod

#                          -O0 change to -Os (?)   add -s (?)
gcc -g3 -O0 -fno-exceptions -I $OFRDIR/../../Mod/Lib \
  -I $OFRDIR/Lib/Obj Config.c term/term_linux.c \
  Int.c SDL2.c Graph.c Term.c Terminal.c OV.c EditorText.c \
  Editor.c $PROG.c -o ../$PROG \
  $OFRDIR/Lib/libOfront.a $SDL2Opts -lSDL2_image
