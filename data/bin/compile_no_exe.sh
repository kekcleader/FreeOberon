#!/bin/bash
# This script is run by FreeOberon on Linux.
# Current directory of the script will be where
# FreeOberon executable is located.
# This particular script is for compilation with no executable.
cd bin
VOCDIR=../data/bin/voc
VOC=$VOCDIR/bin/voc
$VOC -OC -cfFm ../Programs/$1
retcode=$?
cd ..
exit $retcode
