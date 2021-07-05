#!/bin/sh
. ../testenv.sh
# Generate mixed source and assembly code listing
rm -f TestLibrary # Remove LSW binary so it doesn't hide Cygwin binary.
$OBECOMP TestLibrary.mod -m
./TestLibrary >result
. ../testresult.sh
