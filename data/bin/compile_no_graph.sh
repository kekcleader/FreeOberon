#!/bin/bash
# This script is run by FreeOberon on Linux.
# Current directory of the script will be where
# FreeOberon executable is located.
# This particular script is for console programs.
cd bin
voc -OC -cfFm ../Programs/$1
retcode=$?
if [ "$retcode" -eq "0" ]; then
  thename="${1%.*}"
  OBJPATH=../src
  gcc -fPIC -g -I "/opt/voc/C/include" \
    -o $thename $thename.o \
    -L"/opt/voc/lib" -lvoc-OC
fi
cd ..
exit $retcode
