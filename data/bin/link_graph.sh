#!/bin/bash
#   This script is run by Free Oberon on Linux. Current directory of the
#   script will be where FreeOberon executable is located. This
#   particular script is for graphical programs.

cd bin

THENAME="${1%.*}"
ONAME="${THENAME##*/}"
OFRDIR="../data/bin/OfrontPlus/Target/Linux_amd64"
PATH="$OFRDIR:$PATH"
CC="gcc"

SDL2Opts=`sdl2-config --cflags --libs`


shift











$CC -g3 -O0 -fno-exceptions \
  -I ../../src \
  -I $OFRDIR/../../Mod/Lib \
  -I $OFRDIR/Lib/Obj \
  $ONAME.c -o $ONAME \
  $@ \
  ../data/bin/libFreeOberon.a \
  $OFRDIR/Lib/libOfront.a \
  $SDL2Opts -lSDL2_image
retcode=$?
cd ..
exit $retcode
