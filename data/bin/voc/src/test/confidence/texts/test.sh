#!/bin/sh
. ../testenv.sh
rm -f testTexts # Remove LSW binary so it doesn't hide Cygwin binary.
$OBECOMP testTexts.mod -m
./testTexts >result
. ../testresult.sh
