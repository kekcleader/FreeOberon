#!/bin/bash
# This script is run by Free Oberon on Linux. Current directory of the
# script will be where FreeOberon executable is located. This
# particular script is for graphical programs.
CURDIR=$(pwd)
FBASE=$1
FPATH=${FBASE%/*}
FBASE=${FBASE##*/}
VOCDIR=$CURDIR/data/bin/voc
Al4Opts=`allegro-config --cflags --libs`
CC=gcc
if [ "$FNAME" != "$FPATH" ]; then
  cd $FPATH
fi
shift

ARGS=
while [ "$1" != "" ]; do
  ARGS="$ARGS $1.o"
  if [ -f "$1/$1.c" ]; then
    ARGS="$ARGS $1/$1.o"
  fi
  shift
done

$CC -fPIC -g -I $VOCDIR/C/include \
  -o $FBASE $FBASE.o \
  $ARGS \
  $VOCDIR/lib/Graph.o $VOCDIR/lib/Allegro.o \
  $VOCDIR/lib/Semaphore.o \
  $VOCDIR/lib/Semaphore/Semaphore.o \
  $VOCDIR/lib/Signals.o \
  $VOCDIR/lib/libvoc-OC.a \
  $Al4Opts -lloadpng

retcode=$?
exit $retcode
