#!/bin/bash
#   This script is automatically run by Free Oberon on Windows
#   for each compiled module. The initial current directory of
#   the script is where FreeOberon executable is located.
#   You are free to edit this file to adjust the process.

cd bin

OFRDIR="../data/bin/OfrontPlus/Target/Linux_amd64"
PATH="$OFRDIR:$PATH"
export OBERON=".:../src:$OFRDIR/Lib/Sym"
OFR="ofront+ -88 -7 -s"


$OFR $2 ../Programs/$1
retcode=$?
cd ..
exit $retcode
