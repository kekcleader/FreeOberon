#!/bin/sh
. ../testenv.sh
rm -f intest # Remove LSW binary so it doesn't hide Cygwin binary.
echo 'Splurdle.25H  "Bert"rest of line'>input
echo another line>>input
$OBECOMP intest.mod -m -O2
./intest <input >result-O2
$OBECOMP intest.mod -m -OC
./intest <input >result-OC
echo --- Testing with Oberon 2 variable model --- >result
cat result-O2 >>result
echo "" >>result
echo "" >>result
echo --- Testing with Component Pascal variable model --- >>result
cat result-OC >>result
. ../testresult.sh
