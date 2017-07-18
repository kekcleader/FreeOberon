#!/bin/sh
. ../testenv.sh
$OBECOMP hello.mod -m
./hello >result
. ../testresult.sh
