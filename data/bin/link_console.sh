#!/bin/bash
# This script is run by Free Oberon on Linux. Current directory of the
# script will be where FreeOberon executable is located. This
# particular script is for console programs.
CURDIR=$(pwd)
FBASE=$1
FPATH=${FBASE%/*}
FBASE=${FBASE##*/}
VOCDIR=$CURDIR/data/bin/voc
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
  $VOCDIR/lib/libvoc-OC.a
retcode=$?
exit $retcode
