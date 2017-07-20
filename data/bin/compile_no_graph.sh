#!/bin/bash
# This script is run by FreeOberon on Linux.
# Current directory of the script will be where
# FreeOberon executable is located.
# This particular script is for console programs.
cd bin
VOCDIR=../data/bin/voc
VOC=$VOCDIR/bin/voc
CC=gcc
$VOC -OC -cfFm ../Programs/$1
retcode=$?
if [ "$retcode" -eq "0" ]; then
  THENAME="${1%.*}"
  $CC -fPIC -g -I $VOCDIR/C/include \
    -o $THENAME $THENAME.o \
    $VOCDIR/lib/Graph.o $VOCDIR/lib/SDL2.o \
    $VOCDIR/lib/libvoc-OC.a
fi
cd ..
exit $retcode
