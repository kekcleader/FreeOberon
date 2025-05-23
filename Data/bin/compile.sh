#!/bin/bash
### This script is automatically run by Free Oberon on Linux and macOS
### for each compiled module. The initial current directory of
### the script is where FreeOberon executable is located.
### You are free to edit this file to adjust the process.

### Set DIR = directory of this script
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

FNAME=$1









if [[ "${FNAME:0:1}" != "/" ]]; then
  FNAME=../$FNAME
fi

mkdir -p _Build
cd _Build

if [[ "$(uname)" == "Darwin" ]]; then
  THISOS="macOS"
else
  THISOS="Linux_amd64"
fi
OFRDIR="$DIR/OfrontPlus/Target/$THISOS"
PATH="$OFRDIR:$PATH"
export OBERON=".:$DIR/../../src:$OFRDIR/Lib/Sym"
OFR="ofront+ -s -88 -7w"

NEEDPATCH=0
MAINFLAG=$2
if [[ "$MAINFLAG" == "-M" ]]; then
  MAINFLAG=-m
  NEEDPATCH=1
fi

$OFR $MAINFLAG "$FNAME"
retcode=$?

echo "AA=[$THISOS], BB=[$2]" >> /tmp/b
if [[ "$THISOS" == "macOS" && "$NEEDPATCH" == "1" ]]; then
  "$DIR/patch.sh" "$(basename "${FNAME/.Mod/}").c"
fi

cd ..
exit $retcode
