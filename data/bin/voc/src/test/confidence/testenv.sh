#!/bin/sh
## '.' this file from individual test.sh files.
#set -e

echo --- Confidence test $(basename "$PWD") ---

if which cygpath >/dev/null 2>/dev/null
then export PATH="$(cygpath "$1")/bin":"$PATH"
else export PATH="$1/bin":"$PATH"
fi
# Set library paths for darwin and termux(android)
export DYLD_LIBRARY_PATH=$1/lib:$DYLD_LIBRARY_PATH
export LD_LIBRARY_PATH=$1/lib:$LD_LIBRARY_PATH
rm -f *.o *.obj *.exe *.sym *.c *.h result new.asm $(basename "$PWD")

# Under gcc generate assembly source for source change test.
# NOTE: The cygwin 64 bit build has relocation errors with
# these assembly generation options.
if [ "$COMPILER" = "gcc" -a "$FLAVOUR" != "cygwin.LP64.gcc" ]
then export CFLAGS="-gstabs -g1 -Wa,-acdhln=new.asm -Wl,-Map=output.map"
fi
