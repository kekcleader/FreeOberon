#/bin/bash
PROG1="FreeOberon"
PROG2="fob"
OFRDIR="../Data/bin/OfrontPlus/Target/Linux_amd64"


PATH="$OFRDIR:$PATH"
export OBERON=.:$OFRDIR/Lib/Sym


OFR="ofront+ -s -88"
CC="cc"
AR="ar"
CCFULL="$CC -O0 -fno-exceptions -I $OFRDIR/../../Mod/Lib -I $OFRDIR/Lib/Obj"


$OFR -Cw Config.Mod &&

$OFR -Cw Func.Mod &&

$OFR -Cw Utf8.Mod &&

$OFR -Cw Strings.Mod &&

$OFR -Cw Reals.Mod &&

$OFR -Cw Int.Mod &&

$OFR -7w Time.Mod &&

$OFR -Cw In.Mod &&

$OFR -Cw Out.Mod &&

$OFR -7w Debug.Mod &&

$OFR -7w Args.Mod &&

$OFR -7w Env.Mod &&

$OFR -Cw Files.Mod &&

$OFR -7w Texts.Mod &&

$OFR -7w Random.Mod &&

$OFR -7w StrList.Mod &&

$OFR -7w Dir.Mod &&

$OFR -7w Allegro5.Mod &&

$OFR -7w Graph.Mod &&

$OFR -7w Sound.Mod &&

$OFR -7w TermBox.Mod &&

$OFR -Cw Term.Mod &&

$OFR -7w OV.Mod &&

$OFR -7w FoStrings.Mod &&

$OFR -Cw EditorText.Mod &&

$OFR -Cw Editor.Mod &&

$OFR -Cw Builder.Mod &&

$OFR -Cwm FreeOberon.Mod &&

$OFR -7wm Fob.Mod &&




$CCFULL -c Utf8.c &&

$CCFULL -c Strings.c &&

$CCFULL -c Reals.c &&

$CCFULL -c Int.c &&

$CCFULL -c Time.c &&

$CCFULL -c In.c &&

$CCFULL -c Out.c &&

$CCFULL -c Args.c &&

$CCFULL -c Env.c &&

$CCFULL -c Files.c &&

$CCFULL -c Texts.c &&

$CCFULL -c Random.c &&

$CCFULL -c StrList.c &&

$CCFULL -c Dir.c &&

$CCFULL -c Graph.c &&

$CCFULL -c Sound.c &&

$CCFULL -c TermBox.c &&


$AR -crs ../Data/bin/libFreeOberon.a \
  Utf8.o Strings.o Reals.o Int.o Time.o In.o Out.o Args.o Env.o \
  Files.o Texts.o Random.o \
  StrList.o Dir.o Graph.o Sound.o TermBox.o &&


$CCFULL -o ../$PROG1 \
  Graph.c Sound.c TermBox.c \
  Term.c term/term_linux.c \
  Config.c Func.c Debug.c OV.c FoStrings.c EditorText.c Editor.c Builder.c \
  FreeOberon.c \
  ../Data/bin/libFreeOberon.a \
  $OFRDIR/Lib/libOfront.a \
  $(pkg-config \
    allegro_primitives-5 allegro_image-5 allegro_audio-5 \
    allegro_acodec-5 allegro_font-5 allegro_dialog-5 \
    allegro-5 --libs --cflags) &&


$CCFULL -o ../$PROG2 \
  FoStrings.c Builder.c \
  Term.c term/term_linux.c \
  Config.c Func.c Debug.c Fob.c \
  ../Data/bin/libFreeOberon.a \
  $OFRDIR/Lib/libOfront.a
