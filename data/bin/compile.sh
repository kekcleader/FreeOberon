#!/bin/bash
# This script is run by FreeOberon on Linux.
# Current directory of the script will be where
# FreeOberon executable is located.
# This particular script is for graphical programs.
cd bin
VOCDIR=../data/bin/voc
VOC=$VOCDIR/bin/voc
CC=gcc
$VOC -OC -cfFm ../Programs/$1
retcode=$?
if [ "$retcode" -eq "0" ]; then
  THENAME="${1%.*}"
  ONAME="${THENAME##*/}"
  SDL2Opts=`sdl2-config --cflags --libs`
  $CC -fPIC -g -I $VOCDIR/C/include \
    -o $ONAME $ONAME.o \
    $VOCDIR/lib/Graph.o $VOCDIR/lib/SDL2.o \
    $VOCDIR/lib/libvoc-OC.a \
    $SDL2Opts -lSDL2_image
fi
cd ..
exit $retcode
