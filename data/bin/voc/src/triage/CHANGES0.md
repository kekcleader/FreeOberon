Before initial commit
=====================

* fixed bug in OPC.Genheader function. If new option is added in OPM, but not added in OPC, compiler was crashing. Simple ELSE fixed the problem.

* par file is not necessary by default (there is a command line argument for that, and defaultTarget is set in OPM.Mod, version.Mod and architecture.Mod) 

* external compiler is called by default. added options to just generate the output, and not call external compiler or assembler.

* OBERON variable always contains current directory path by default (changes in Kernel.Mod, added oocStrings dependency to it), as well as installed default libraries sym files path.

* MODULES variable added in order to specify directories where to look for source file. OBERON variable is not used by developer anymore, only MODULES variable.

* error messages are now more descriptive (errors.Mod added)

* help is now more descriptive

* version module which defines the target and version string. 

* recoursive build (not yet implemented)

* change max and min longint, change maxset - calculated, and not hardcoded

* real 64bit LONGINT on x86_64

* changed makefile

* ported some ooc and ooc2 libraries

* ported some Ulm Oberon libraries

* works with unicode strings

* voc checks for CFLAGS variable, and adds it to it's command line. this is used during bootstrapping, see makefile.

* many other changes

