#!/bin/sh
. ../testenv.sh
# Generate mixed source and assembly code listing
$OBECOMP IntSyntax.mod -fm >result
. ../testresult.sh
