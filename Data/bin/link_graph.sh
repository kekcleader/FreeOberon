#!/bin/bash
#   This script is run by Free Oberon on Linux
#   to link a graphics program.
#   When it is being run, the current directory
#   must be the root directory of Free Oberon.

# Set DIR = directory of this script
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

cd _Build

THENAME="${1%.*}"
ONAME="${THENAME##*/}"

FOBDIR="$DIR/../.."
OFRDIR="$DIR/OfrontPlus"
OFRTAR="$OFRDIR/Target/Linux_amd64"
PATH="$OFRTAR:$PATH"
CC="gcc"


shift











$CC -O0 -fno-exceptions \
  -I $FOBDIR/src \
  -I $OFRDIR/Mod/Lib \
  -I $OFRTAR/Lib/Obj \
  $ONAME.c -o $ONAME \
  $@ \
  $FOBDIR/Data/bin/libFreeOberon.a \
  $OFRTAR/Lib/libOfront.a \
  $(pkg-config \
    allegro_primitives-5 allegro_image-5 allegro_audio-5 \
    allegro_acodec-5 allegro_font-5 allegro_dialog-5 \
    allegro-5 --libs --cflags)
retcode=$?
cd ..
exit $retcode
