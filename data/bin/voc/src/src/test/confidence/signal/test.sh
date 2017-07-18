#!/bin/sh
. ../testenv.sh
rm -f SignalTest # Remove LSW binary so it doesn't hide Cygwin binary.
$OBECOMP signal.mod -m
./SignalTest x &
sleep 1
kill -2 $!
wait
. ../testresult.sh
