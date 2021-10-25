OFRDIR="../data/bin/OfrontPlus/Target/Linux_amd64"
export OBERON=.:$OFRDIR/Lib/Sym

ofront+ -887ws Allegro5.Mod && \
ofront+ -887ws Graph2.Mod && \
ofront+ -887ws TermBox.Mod && \
ofront+ -887wm TTest.Mod && \
gcc -o TTest -g3 -O0 -fno-exceptions \
  -I ../data/bin/OfrontPlus/Target/Linux_amd64/../../Mod/Lib \
  -I ../data/bin/OfrontPlus/Target/Linux_amd64/Lib/Obj \
  Graph2.c TermBox.c TTest.c \
  ../data/bin/libFreeOberon.a \
  ../data/bin/OfrontPlus/Target/Linux_amd64/Lib/libOfront.a \
  $(pkg-config \
    allegro_primitives-5 allegro_image-5 allegro_audio-5 \
    allegro_acodec-5 allegro_font-5 allegro_dialog-5 \
    allegro-5 --libs --cflags)
