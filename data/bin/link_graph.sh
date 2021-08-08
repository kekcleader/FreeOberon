#!/bin/bash
# This script is run by Free Oberon on Linux. Current directory of the
# script will be where FreeOberon executable is located. This
# particular script is for graphical programs.
cd bin
VOCDIR=../data/bin/voc/install
CC=gcc
THENAME="${1%.*}"
ONAME="${THENAME##*/}"
SDL2Opts=`sdl2-config --cflags --libs`
shift
$CC -fPIC -g -I $VOCDIR/C/include \
  -o $ONAME $ONAME.o \
  $@ \
  $VOCDIR/lib/Graph.o $VOCDIR/lib/SDL2.o \
  $VOCDIR/lib/Int.o \
  $VOCDIR/lib/libvoc-OC.a \
  $SDL2Opts -lSDL2_image
retcode=$?
cd ..
exit $retcode
