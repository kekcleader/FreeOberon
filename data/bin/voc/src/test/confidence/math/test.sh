#!/bin/sh
. ../testenv.sh
rm -f mathtest # Remove LSW binary so it doesn't hide Cygwin binary.
$OBECOMP mathtest.mod -m -OC
./mathtest >result
. ../testresult.sh
