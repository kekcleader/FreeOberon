#!/bin/sh
. ../testenv.sh
rm -f outtest # Remove LSW binary so it doesn't hide Cygwin binary.
$OBECOMP outtest.mod -m -O2
./outtest >result-O2
$OBECOMP outtest.mod -m -OC
./outtest >result-OC
echo --- Testing with Oberon 2 variable model --- >result
cat result-O2 >>result
echo "" >>result
echo "" >>result
echo --- Testing with Component Pascal variable model --- >>result
cat result-OC >>result
. ../testresult.sh
