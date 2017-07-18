#!/bin/bash
# This script is run by FreeOberon on Linux.
# Current directory of the script will be where
# FreeOberon executable is located.
# This particular script is for graphical programs.
cd bin
voc -OC -cfFm ../Programs/$1
retcode=$?
if [ "$retcode" -eq "0" ]; then
  thename="${1%.*}"
  OBJPATH=../src
  SDL2Opts=`sdl2-config --cflags --libs`
  gcc -fPIC -g -I "/opt/voc/C/include" \
    -o $thename $thename.o \
    "$OBJPATH/Graph.o" "$OBJPATH/SDL2.o" \
    -L"/opt/voc/lib" -lvoc-OC \
    $SDL2Opts -lSDL2_image
fi
cd ..
exit $retcode
