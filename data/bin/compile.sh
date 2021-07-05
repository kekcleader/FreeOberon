#!/bin/bash
# This script is run by Free Oberon on Linux. Current directory of the
# script will be where FreeOberon executable is located.
cd bin
VOCDIR=../data/bin/voc/install
VOC=$VOCDIR/bin/voc
$VOC -OC -cfF $2 ../Programs/$1
retcode=$?
cd ..
exit $retcode
