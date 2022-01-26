#!/bin/bash
#   This script is run by Free Oberon on Linux
#   to link a console program.
#   When it is being run, the current directory
#   must be the root directory of Free Oberon.

cd bin

THENAME="${1%.*}"
ONAME="${THENAME##*/}"

FOBDIR=".."
OFRDIR="../Data/bin/OfrontPlus"
OFRTAR="$OFRDIR/Target/Linux_amd64"
PATH="$OFRTAR:$PATH"
CC="gcc"


shift




# These blanks are left to allow Windows and Linux
# versions of the script to be viewed in parallel.





$CC -g3 -O0 -fno-exceptions \
  -I $FOBDIR/src \
  -I $OFRDIR/Mod/Lib \
  -I $OFRTAR/Lib/Obj \
  $ONAME.c -o $ONAME \
  $@ \
  $FOBDIR/Data/bin/libFreeOberon.a \
  $OFRDIR/Lib/libOfront.a



retcode=$?
cd ..
exit $retcode
