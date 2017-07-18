#!/bin/sh
. ../testenv.sh
rm -f aa # Remove LSW binary so it doesn't hide Cygwin binary.
$OBECOMP aa.mod -m
./aa >result
. ../testresult.sh
