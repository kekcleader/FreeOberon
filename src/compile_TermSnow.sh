PROG=TermSnow
OFRDIR="../Data/bin/OfrontPlus/Target/Linux_amd64"
PATH="$OFRDIR:$PATH"
export OBERON=.:$OFRDIR/Lib/Sym
OFR="ofront+ -s88"

$OFR -7w Allegro5.Mod && \
$OFR -7w Graph.Mod && \
$OFR -7w TermBox.Mod && \
$OFR -7w TermSnow.Mod && \
$OFR -7wm $PROG.Mod && \
gcc -o $PROG -g3 -O0 -fno-exceptions \
  -I $OFRDIR/../../Mod/Lib \
  -I $OFRDIR/Lib/Obj \
  Graph.c TermBox.c $PROG.c \
  ../Data/bin/libFreeOberon.a \
  $OFRDIR/Lib/libOfront.a \
  $(pkg-config \
    allegro_primitives-5 allegro_image-5 allegro_audio-5 \
    allegro_acodec-5 allegro_font-5 allegro_dialog-5 \
    allegro-5 --libs --cflags)
