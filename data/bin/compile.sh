#!/bin/bash
# This script is run by Free Oberon on Linux. Current directory of the
# script will be where FreeOberon executable is located.
CURDIR=$(pwd)
FNAME=$1
FPATH=${FNAME%/*}
FNAME=${FNAME##*/}
FBASE=${FNAME%.*}
EXTPATH=$FPATH/$FBASE
EXTNAME=$EXTPATH/$FBASE.c
export VOCDIR=$CURDIR/data/bin/voc
VOC=$VOCDIR/bin/voc
CC=gcc
if [ -f "$EXTNAME" ]; then
  cd $EXTPATH
  $CC -c $FBASE.c -o $FBASE.o
  cd $CURDIR
fi
if [ "$FNAME" != "$FPATH" ]; then
  cd $FPATH
fi
$VOC -OC -cfF $2 $FNAME
retcode=$?
cd ..
exit $retcode
