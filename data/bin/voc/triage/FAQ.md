

compiler does show only character position, not the line number
===============================================================

Yes, by default it shows you the character position, because it's faster to go to character position in vim
:goto number

In case you still want to use line numbers then pass -l option to voc

voc -ls m.Mod

compilation crashes on Ubuntu 15.10 x86_64 or latest Raspbians on Raspberry Pi with recent (like 3.12) kernels.
===========================================================================

> echo 1 > /proc/sys/vm/legacy_va_layout

should fix that.

compilation crashes with "cannot find -lc" on recent fedoras
============================================================

remove <code>-static</code> from makefile on the line where voc binary created (first -static you'll find)

make errors on freebsd
======================

># make -f makefile.freebsd.clang.x86_64 
make: "/root/voc/makefile.freebsd.clang.x86_64" line 22: Need an operator
make: "/root/voc/makefile.freebsd.clang.x86_64" line 24: Need an operator
make: Fatal errors encountered -- cannot continue
make: stopped in /root/voc

use gmake.
