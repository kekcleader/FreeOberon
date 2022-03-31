#!/bin/bash
#   This script is automatically run by Free Oberon on Linux
#   for each compiled module. The initial current directory of
#   the script is where FreeOberon executable is located.
#   You are free to edit this file to adjust the process.

# Set DIR = directory of this script
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

FNAME=$1

if [[ "${FNAME:0:1}" != "/" ]]; then
  FNAME=../$FNAME
fi


mkdir -p _Build
cd _Build

OFRDIR="$DIR/OfrontPlus/Target/Linux_amd64"
PATH="$OFRDIR:$PATH"
export OBERON=".:$DIR/../../src:$OFRDIR/Lib/Sym"
OFR="ofront+ -s -88 -7w"


$OFR $2 $FNAME
retcode=$?
cd ..
exit $retcode
