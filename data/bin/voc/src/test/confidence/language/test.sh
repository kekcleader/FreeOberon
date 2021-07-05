#!/bin/sh
. ../testenv.sh
# Generate mixed source and assembly code listing
rm -f TestLanguage # Remove LSW binary so it doesn't hide Cygwin binary.
$OBECOMP TestLanguage.mod -m
./TestLanguage >result
. ../testresult.sh
