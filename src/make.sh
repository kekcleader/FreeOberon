#/bin/bash
PROG="FreeOberon"
OFRDIR="../Data/bin/OfrontPlus/Target/Linux_amd64"

PATH="$OFRDIR:$PATH"
export OBERON=.:$OFRDIR/Lib/Sym


OFR="ofront+ -s -88"
CC="gcc"
AR="ar"
CCFULL="$CC -g3 -O0 -fno-exceptions -I $OFRDIR/../../Mod/Lib -I $OFRDIR/Lib/Obj"


$OFR -Cw Config_linux.Mod

$OFR -Cw Utf8.Mod

$OFR -Cw Strings.Mod

$OFR -Cw Reals.Mod

$OFR -Cw Int.Mod

$OFR -Cw In.Mod

$OFR -Cw Out.Mod

$OFR -Cw Files.Mod

$OFR -7w Texts.Mod

$OFR -7w Random.Mod

$OFR -7w StrList.Mod

$OFR -7w Dir.Mod

$OFR -7w Allegro5.Mod

$OFR -7w Graph2.Mod

$OFR -7w TermBox.Mod

$OFR -Cw Term.Mod

$OFR -7w OV.Mod

$OFR -7w FoStrings.Mod

$OFR -Cw EditorText.Mod

$OFR -Cw Editor.Mod

$OFR -Cwm FreeOberon.Mod



$CCFULL -c Utf8.c
$CCFULL -c Strings.c
$CCFULL -c Reals.c
$CCFULL -c Int.c
$CCFULL -c In.c
$CCFULL -c Out.c
$CCFULL -c Files.c
$CCFULL -c Texts.c
$CCFULL -c Random.c
$CCFULL -c StrList.c
$CCFULL -c Dir.c
$CCFULL -c Graph2.c
$CCFULL -c TermBox.c

$AR -crs ../Data/bin/libFreeOberon.a \
  Utf8.o Strings.o Reals.o Int.o In.o Out.o Files.o Texts.o Random.o \
  StrList.o Dir.o Graph2.o TermBox.o

$CCFULL -o ../$PROG \
  Graph2.c TermBox.c \
  Config.c term/term_linux.c \
  Term.c OV.c FoStrings.c EditorText.c Editor.c \
  $PROG.c \
  ../Data/bin/libFreeOberon.a \
  $OFRDIR/Lib/libOfront.a \
  $(pkg-config \
    allegro_primitives-5 allegro_image-5 allegro_audio-5 \
    allegro_acodec-5 allegro_font-5 allegro_dialog-5 \
    allegro-5 --libs --cflags)
