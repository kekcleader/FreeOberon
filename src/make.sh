#/bin/bash
PROG="FreeOberon"
OFRDIR="../data/bin/OfrontPlus/Target/Linux_amd64"

export PATH=$OFRDIR:$PATH
export OBERON=.:$OFRDIR/Lib/Sym

SDL2Opts="-lSDL2"
OFR="ofront+ -s -88"
CC="gcc"
AR="ar"
CCFULL="$CC -g3 -O0 -fno-exceptions -I $OFRDIR/../../Mod/Lib -I $OFRDIR/Lib/Obj"


$OFR -C Config_linux.Mod

$OFR -C Utf8.Mod

$OFR -C Strings.Mod

$OFR -C Reals.Mod

$OFR -C Int.Mod

$OFR -C In.Mod

$OFR -C Out.Mod

$OFR -C Files.Mod

$OFR -7w StrList.Mod

$OFR -7w Dir.Mod

$OFR -C -i SDL2.Mod

$OFR -C Graph.Mod

$OFR -C Terminal.Mod

$OFR -C Term.Mod

$OFR -C OV.Mod

$OFR -C EditorText.Mod

$OFR -C Editor.Mod

$OFR -C -m FreeOberon.Mod



$CCFULL -c Utf8.c
$CCFULL -c Strings.c
$CCFULL -c Reals.c
$CCFULL -c Int.c
$CCFULL -c In.c
$CCFULL -c Out.c
$CCFULL -c Files.c
$CCFULL -c StrList.c
$CCFULL -c Dir.c
$CCFULL -c SDL2.c
$CCFULL -c Graph.c
$AR -crs ../data/bin/libFreeOberon.a \
  Utf8.o Strings.o Reals.o Int.o In.o Out.o Files.o \
  StrList.o Dir.o SDL2.o Graph.o

$CCFULL Config.c term/term_linux.c \
  Utf8.o Strings.o Reals.o Int.o In.o Out.o Files.o \
  StrList.o Dir.o SDL2.o Graph.o \
  Term.c Terminal.c OV.c EditorText.c Editor.c \
  $PROG.c -o ../$PROG \
  $OFRDIR/Lib/libOfront.a \
  $SDL2Opts -lSDL2_image

