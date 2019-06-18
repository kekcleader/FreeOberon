#!/bin/bash
# This script is run by Free Oberon on Linux. Current directory of the
# script will be where FreeOberon executable is located. This
# particular script is for console programs.
cd bin
VOCDIR=../data/bin/voc
CC=gcc
THENAME="${1%.*}"
ONAME="${THENAME##*/}"
SDL2Opts=`sdl2-config --cflags --libs`
shift
$CC -fPIC -g -I $VOCDIR/C/include \
  -o $ONAME $ONAME.o \
  $@ \
  $VOCDIR/lib/libvoc-OC.a
retcode=$?
cd ..
exit $retcode
