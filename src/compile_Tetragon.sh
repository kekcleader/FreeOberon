OFRDIR="../Data/bin/OfrontPlus/Target/Linux_amd64"
PATH="$OFRDIR:$PATH"
export OBERON=.:$OFRDIR/Lib/Sym

ofront+ -887ws Allegro5.Mod && \
ofront+ -887ws Graph.Mod && \
ofront+ -887ws TermBox.Mod && \
ofront+ -887wm Tetragon.Mod && \
gcc -o Tetragon -g3 -O0 -fno-exceptions \
  -I ../Data/bin/OfrontPlus/Target/Linux_amd64/../../Mod/Lib \
  -I ../Data/bin/OfrontPlus/Target/Linux_amd64/Lib/Obj \
  Graph.c TermBox.c Tetragon.c \
  ../Data/bin/libFreeOberon.a \
  ../Data/bin/OfrontPlus/Target/Linux_amd64/Lib/libOfront.a \
  $(pkg-config \
    allegro_primitives-5 allegro_image-5 allegro_audio-5 \
    allegro_acodec-5 allegro_font-5 allegro_dialog-5 \
    allegro-5 --libs --cflags)
