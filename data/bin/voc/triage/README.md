
Vishap oberon compiler
======================

[ⱱishap Oberon Compiler](http://oberon.vishap.am) (voc) is a free (GPLv3) professional oberon-2 compiler.

Platforms:
=========
voc produces x86_64, x86, ppc, armv{4-7} binaries and works on those platforms.
On x86_64 it supports 64bit LONGINT and 64bit SET types.
By using currently stable C backend voc is relatively easy to port to any platform for which C compiler exists.

Operating Systems:
==================
Currently GNU/Linux, Mac OS X, FreeBSD and OpenBSD sources (with bootstrap binaries) are published.

Ports to Solaris, AIX will be made and published in case there is an interest from community.
voc should work on MS Windows/ReactOS via Cygwin/gcc, however we did not test it on Windows compatible machine.

Backends:
=========
voc has stable C backend, which generates human readable and easily debuggable C code.
Generated C code is fairly efficient and does not cause a noticeable overhead. voc was used to generate code even for low end 8 bit devices like nmos6502 and AVR micros.

Work on native backends for arm and x86_64 is in progress.

Libraries:
==========
voc comes with a useful set of libraries, in particular:
– Oberon V4 and S3 compatible library set.
– ooc (optimizing oberon-2 compiler) library port.
– Ulm’s Oberon system library port.

This makes it easier to compile/port software which was developed by using those compilers.

Work on other compatibility layers is in progress.
voc team also works on bindings to existing C/Pascal libraries.

Some other freely redistributable libraries are available as a part of voc distribution.

Licensing:
==========
voc’s frontend and C backend engine is a fork of Josef Templ’s Ofront, which has been released under FreeBSD License. Unlike Ofront, it does not include Oberon v4 environment.
Ulm Oberon Library is distributed under GPL.
ooc library is distributed under GPL.

voc tools are distributed under GPLv3.
most of the runtime in libVishapOberon is distributed under GPLv3 with runtime exception.
ulm and ooc libraries were distributed under GPL, thus static linking to those modules from libVishapOberon.a to proprietary code is disallowed.

Naming:
=======
Vishaps are dragons inhabited in Armenian Highlands.
We decided to name the project “Vishap” because ties between compilers and dragons have ancient traditions.

Also, Vishaps are known in tales, fiction. [This page](http://blog.fogus.me/2015/04/27/six-works-of-computer-science-fiction/) refers to some technologies as “computer science fiction”. Among them to Oberon. This brings another meaning, Oberon is like aliens, ghosts. And Vishaps.


How to use
==========

First you need to [build](https://github.com/norayr/voc/blob/master/COMPILE) it.

As it is stated in [COMPILE](https://github.com/norayr/voc/blob/master/COMPILE) page, voc is installed in /opt/voc/bin if you did not change the prefix.
So, in order to run voc you need to type 

>/opt/voc/bin/voc

or add /opt/voc/bin to you PATH environment variable, and then just typing voc will execute it. For that you have to know how to work in Unix shell, and this knowledge is out of the scope of this document.

Type voc and it'll show you help.

Simple example
============

Let's write hello world file:

>$ cat hey.Mod

<code>
MODULE hey;  

  IMPORT Console;  

BEGIN  

  Console.String("hey there"); Console.Ln  

END hey.  
</code>

>voc -M hey.Mod

will compile your module and link it statically to libVishapOberon.

>voc -m hey.Mod

will link the module dynamically.

Example with two modules
====================

If you have more than one module, and you want them to be compiled in to elf file then:
Let's assume we have module M0 which imports M1;

>voc -l M1.Mod -s M0.Mod -M

Here -l is a global option.
Module M1 will be compiled with -s option, i. e. sym file will be generated.

Module M0 will be compiled and linked statically.

Example with many modules
======================

In case you have modules in different directories, like "ui", "logic", "math", then you need to export MODULES environment variable like this:

>export MODULES=".:ui:logic:math"

and after call voc

>voc -s ui0.Mod

Otherwise you can use full path:

>voc -s ui/ui0.Mod


