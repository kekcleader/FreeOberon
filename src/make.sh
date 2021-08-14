PROG="FreeOberon"
OFRDIR="$OBPATH"
SDL2Opts="-lSDL2"
OFR="ofront+ -88 -C -s"
export OBERON=.:$OFRDIR/Lib/Sym
CC="gcc"
AR="ar"
CCFULL="$CC -g3 -O0 -fno-exceptions -I $OFRDIR/../../Mod/Lib -I $OFRDIR/Lib/Obj"

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

$CCFULL -c Int.c
$CCFULL -c SDL2.c
$CCFULL -c Graph.c
$AR -crs ../data/bin/libFreeOberon.a Int.o SDL2.o Graph.o

$CCFULL Config.c term/term_linux.c Int.o SDL2.o Graph.o \
  Term.c Terminal.c OV.c EditorText.c Editor.c $PROG.c \
  -o ../$PROG $OFRDIR/Lib/libOfront.a \
  $SDL2Opts -lSDL2_image
