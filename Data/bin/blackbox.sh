#!/bin/bash
# This script is run by FreeOberon on Linux. Current directory of the
# script will be where FreeOberon executable is located. This
# particular script is for console programs compiled with Blackbox.
cd Data/bin/bbcp
BBCP=./blackbox
echo "ConsCompiler.Compile('Programs/Mod','$1')" | $BBCP
retcode=$?
cd ../../..
exit $retcode
