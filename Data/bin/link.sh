#!/bin/bash
### This script is run by Free Oberon on Linux and macOS
### to link user programs.
### When it is being run, the current directory
### must be the root directory of Free Oberon.

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

if [[ "$(uname)" == "Darwin" ]]; then
  THISOS="macOS"
else
  THISOS="Linux_amd64"
fi
FOBDIR="$DIR/../.."
OFRDIR="$DIR/OfrontPlus"
OFRTAR="$OFRDIR/Target/$THISOS"
PATH="$OFRTAR:$PATH"
CC="gcc"


shift

FILES=
FLAGS=
F=false

for arg in "$@"; do
  if [ "$arg" = "--linker-libs" ]
  then F=true
  elif [ "$F" = false ]
  then FILES="$FILES $arg"
  else FLAGS="$FLAGS $arg"
  fi
done








$CC -O0 -g -fno-exceptions \
  -I $FOBDIR/src \
  -I $OFRDIR/Mod/Lib \
  -I $OFRTAR/Lib/Obj \
  $ONAME.c -o $ONAME \
  $FILES \
  $FOBDIR/Data/bin/libFreeOberon.a \
  $OFRTAR/Lib/libOfront.a $FLAGS

retcode=$?
cd ..
exit $retcode
