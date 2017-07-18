#!/bin/sh
. ../testenv.sh
$OBECOMP isptest.mod -m -O2
./isptest >result-O2
$OBECOMP isptest.mod -m -OC
./isptest >result-OC
echo --- Testing with Oberon 2 variable model --- >result
cat result-O2 >>result
echo "" >>result
echo "" >>result
echo --- Testing with Component Pascal variable model --- >>result
cat result-OC >>result
. ../testresult.sh
