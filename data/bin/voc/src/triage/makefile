#SHELL := /bin/bash
BUILDID=$(shell date +%Y/%m/%d)
TOS = linux
TARCH = x86_64
#TARCH = x86 x86_64 armv6j armv6j_hardfp armv7a_hardfp powerpc
CCOMP = gcc
RELEASE = 1.1


INCLUDEPATH = -Isrc/lib/system/$(TOS)/$(CCOMP)/$(TARCH)

SETPATH = CFLAGS=$(INCLUDEPATH)  PATH=.:/bin:/usr/bin MODULES=.:src/lib:src/lib/v4:src/lib/v4/$(TARCH):src/lib/v4_compat:src/lib/system/$(TOS)/$(CCOMP):src/lib/system/$(TOS)/$(CCOMP)/$(TARCH):src/lib/ulm:src/lib/ulm/$(TARCH):src/lib/ooc2:src/lib/ooc2/$(TOS)/$(CCOMP):src/lib/ooc:src/lib/ooc/$(TOS)/$(CCOMP)/$(TARCH):src/lib/pow:src/lib/misc:src/lib/s3:src/lib/s3/$(TARCH):src/voc:src/voc/$(TOS)/$(CCOMP):src/voc/$(TOS)/$(CCOMP)/$(TARCH):src/tools/ocat:src/tools/browser:src/tools/vocparam:src/tools/vmake:src/tools/coco:src/test

VOC = voc
VERSION = $(TOS).$(CCOMP).$(TARCH)
VOCSTATIC0 = $(SETPATH) ./vocstatic.$(TOS).$(CCOMP).$(TARCH)
VOCSTATIC = $(SETPATH) ./voc
VOCPARAM = $(shell ./vocparam > voc.par)
LIBNAME = VishapOberon
LIBRARY = lib$(LIBNAME)

ifndef PRF
PRF = "/opt"
endif
PREFIX = $(PRF)/voc-$(RELEASE)
PREFIXLN = $(PRF)/voc

CCOPT = -fPIC $(INCLUDEPATH) -g -fno-stack-protector
SHRLIBEXT = so
CC = $(CCOMP) $(CCOPT) -c
CL = $(CCOMP) $(CCOPT)
LD = $(CCOMP) -shared -o $(LIBRARY).$(SHRLIBEXT)
# s is necessary to create index inside a archive
ARCHIVE = ar rcs $(LIBRARY).a

#%.c: %.Mod
#%.o: %.c
#	$(CC) $(input)

all: stage2 stage3 stage4 stage5 stage6 stage7

# when porting to new platform:
# * put corresponding .par file into current directory. it can be generated on the target platform by compiling vocparam (stage0) and running (stage1)
# * run make port0 - this will generate C source files for the target architecture
# * move the source tree to the target machine, and compile (or compile here via crosscompiler) (port1)
port0: stage2 stage3 stage4

# now compile C source files for voc, showdef and ocat on target machine (or by using crosscompiler)
port1: stage5
# after you have "voc" compiled for target architecture. replace vocstatic with it and run make on target platform to get everything compiled

# this builds binary which generates voc.par
stage0: src/tools/vocparam/vocparam.c
	$(CL) -I src/lib/system/$(TOS)/$(CCOMP)/$(TARCH) -o vocparam src/tools/vocparam/vocparam.c

# this creates voc.par for a host architecture.
# comment this out if you need to build a compiler for a different architecture.
stage1: 
	#rm voc.par
	#$(shell "./vocparam > voc.par")
	#./vocparam > voc.par
	$(VOCPARAM)

# this copies necessary voc.par to the current directory.
# skip this if you are building compiler for the host architecture.
stage2:
	cp src/par/voc.par.$(CCOMP).$(TARCH) voc.par
#	cp src/par/voc.par.gnu.x86_64 voc.par
#	cp src/par/voc.par.gnu.x86 voc.par
#	cp src/par/voc.par.gnu.armv6 voc.par
#	cp src/par/voc.par.gnu.armv7 voc.par
	cp src/voc/prf.Mod_default src/voc/prf.Mod

# this prepares modules necessary to build the compiler itself
stage3:

	$(VOCSTATIC0) -siapxPS SYSTEM.Mod 
	$(VOCSTATIC0) -sPFS Args.Mod Console.Mod Unix.Mod
	sed -i.tmp "s#/opt#$(PRF)#g" src/voc/prf.Mod
	$(VOCSTATIC0) -sPFS prf.Mod
	$(VOCSTATIC0) -sPFS Strings.Mod architecture.Mod version.Mod Kernel0.Mod Modules.Mod
	$(VOCSTATIC0) -sxPFS Files0.Mod 
	$(VOCSTATIC0) -sPFS Reals.Mod Texts0.Mod
	$(VOCSTATIC0) -sPFS vt100.Mod

# build the compiler
stage4:
	$(VOCSTATIC0) -sPFS errors.Mod
	$(VOCSTATIC0) -sPFS extTools.Mod
	$(VOCSTATIC0) -sPFS OPM.cmdln.Mod 
	$(VOCSTATIC0) -sxPFS OPS.Mod 
	$(VOCSTATIC0) -sPFS OPT.Mod OPC.Mod OPV.Mod OPB.Mod OPP.Mod
	$(VOCSTATIC0) -smPS voc.Mod
	$(VOCSTATIC0) -smPS BrowserCmd.Mod
	$(VOCSTATIC0) -smPS OCatCmd.Mod

#this is to build the compiler from C sources.
#this is a way to create a bootstrap binary.
stage5:
	$(CC) SYSTEM.c Args.c Console.c Modules.c Unix.c \
	Strings.c architecture.c prf.c version.c Kernel0.c Files0.c Reals.c Texts0.c vt100.c \
	extTools.c \
	OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c

	$(CL) -static  voc.c -o voc \
	SYSTEM.o Args.o Console.o Modules.o Unix.o \
	Strings.o architecture.o prf.o version.o Kernel0.o Files0.o Reals.o Texts0.o vt100.o \
	extTools.o \
	OPM.o OPS.o OPT.o OPC.o OPV.o OPB.o OPP.o errors.o
	$(CL) BrowserCmd.c -o showdef \
	SYSTEM.o Args.o Console.o Modules.o Unix.o Strings.o architecture.o prf.o version.o Kernel0.o Files0.o Reals.o Texts0.o vt100.o \
	OPM.o OPS.o OPT.o OPV.o OPC.o errors.o

	$(CL) OCatCmd.c -o ocat \
	SYSTEM.o Args.o Console.o Modules.o Unix.o Strings.o architecture.o prf.o version.o Kernel0.o Files0.o Reals.o Texts0.o
	
# build all library files
stage6:
	#v4 libs
	$(VOCSTATIC) -sPF	Kernel.Mod
	$(VOCSTATIC) -sPF	Files.Mod
	$(VOCSTATIC) -sPF	Texts.Mod
	$(VOCSTATIC) -sPF	Printer.Mod
	$(VOCSTATIC) -sPF	Strings.Mod
	$(VOCSTATIC) -sPF	Sets.Mod
	$(VOCSTATIC) -sPF	Sets0.Mod
	$(VOCSTATIC) -sPF        Oberon.Mod

	#ooc libs
	$(VOCSTATIC) -sPF	oocAscii.Mod
	$(VOCSTATIC) -sPF	oocStrings.Mod
	$(VOCSTATIC) -sPF	oocStrings2.Mod
	$(VOCSTATIC) -sPF	oocOakStrings.Mod
	$(VOCSTATIC) -sPF	oocCharClass.Mod
	$(VOCSTATIC) -sPF	oocConvTypes.Mod
	$(VOCSTATIC) -sPF	oocIntConv.Mod
	$(VOCSTATIC) -sPF	oocIntStr.Mod
	$(VOCSTATIC) -sPF	oocSysClock.Mod
	$(VOCSTATIC) -sPF	oocTime.Mod
	$(VOCSTATIC) -sPF	oocRandomNumbers.Mod
#	$(VOCSTATIC) -s	oocLongStrings.Mod
#	$(CC)		oocLongStrings.c
#	$(VOCSTATIC) -s	oocMsg.Mod
#	$(CC)		oocMsg.c


	#ooc2 libs
	$(VOCSTATIC) -sPF ooc2Strings.Mod
	$(VOCSTATIC) -sPF ooc2Ascii.Mod
	$(VOCSTATIC) -sPF ooc2CharClass.Mod
	$(VOCSTATIC) -sPF ooc2ConvTypes.Mod
	$(VOCSTATIC) -sPF ooc2IntConv.Mod
	$(VOCSTATIC) -sPF ooc2IntStr.Mod
	$(VOCSTATIC) -sPF ooc2Real0.Mod
	#ooc libs
	$(VOCSTATIC) -sPF oocLowReal.Mod oocLowLReal.Mod
	$(VOCSTATIC) -sPF oocRealMath.Mod oocOakMath.Mod
	$(VOCSTATIC) -sPF oocLRealMath.Mod
	$(VOCSTATIC) -sPF oocLongInts.Mod
	$(VOCSTATIC) -sPF oocComplexMath.Mod oocLComplexMath.Mod
	$(VOCSTATIC) -sPF oocLRealConv.Mod oocLRealStr.Mod
	$(VOCSTATIC) -sPF oocRealConv.Mod oocRealStr.Mod
	$(VOCSTATIC) -sPF oocMsg.Mod oocChannel.Mod
	$(VOCSTATIC) -sPF oocStrings2.Mod oocRts.Mod oocFilenames.Mod
	$(VOCSTATIC) -sPF oocTextRider.Mod oocBinaryRider.Mod oocJulianDay.Mod
	$(VOCSTATIC) -sPF oocFilenames.Mod
	$(VOCSTATIC) -sPF oocwrapperlibc.Mod
	$(VOCSTATIC) -sPF oocC.Mod

	#Ulm's Oberon system libs
	$(VOCSTATIC) -sPF ulmSys.Mod
	$(VOCSTATIC) -sPF ulmSYSTEM.Mod
	$(VOCSTATIC) -sPF ulmASCII.Mod
	$(VOCSTATIC) -sPF ulmSets.Mod
	$(VOCSTATIC) -sPF ulmObjects.Mod
	$(VOCSTATIC) -sPF ulmDisciplines.Mod
	$(VOCSTATIC) -sPF ulmPriorities.Mod
	$(VOCSTATIC) -sPF ulmServices.Mod
	$(VOCSTATIC) -sPF ulmEvents.Mod
	$(VOCSTATIC) -sPF ulmResources.Mod
	$(VOCSTATIC) -sPF ulmForwarders.Mod
	$(VOCSTATIC) -sPF ulmRelatedEvents.Mod
	$(VOCSTATIC) -sPF ulmIO.Mod
	$(VOCSTATIC) -sPF ulmProcess.Mod
	$(VOCSTATIC) -sPF ulmTypes.Mod
	$(VOCSTATIC) -sPF ulmStreams.Mod
	$(VOCSTATIC) -sPF ulmAssertions.Mod
	$(VOCSTATIC) -sPF ulmIndirectDisciplines.Mod
	$(VOCSTATIC) -sPF ulmStreamDisciplines.Mod
	$(VOCSTATIC) -sPF ulmIEEE.Mod
	$(VOCSTATIC) -sPF ulmMC68881.Mod
	$(VOCSTATIC) -sPF ulmReals.Mod
	$(VOCSTATIC) -sPF ulmPrint.Mod
	$(VOCSTATIC) -sPF ulmWrite.Mod
	$(VOCSTATIC) -sPF ulmTexts.Mod
	$(VOCSTATIC) -sPF ulmStrings.Mod
	$(VOCSTATIC) -sPF ulmConstStrings.Mod
	$(VOCSTATIC) -sPF ulmPlotters.Mod
	$(VOCSTATIC) -sPF ulmSysTypes.Mod
	$(VOCSTATIC) -sPF ulmSysConversions.Mod
	$(VOCSTATIC) -sPF ulmErrors.Mod
	$(VOCSTATIC) -sPF ulmSysErrors.Mod
	$(VOCSTATIC) -sPF ulmSysIO.Mod
	$(VOCSTATIC) -sPF ulmLoader.Mod
	$(VOCSTATIC) -sPF ulmNetIO.Mod
	$(VOCSTATIC) -sPF ulmPersistentObjects.Mod
	$(VOCSTATIC) -sPF ulmPersistentDisciplines.Mod
	$(VOCSTATIC) -sPF ulmOperations.Mod
	$(VOCSTATIC) -sPF ulmScales.Mod
	$(VOCSTATIC) -sPF ulmTimes.Mod
	$(VOCSTATIC) -sPF ulmClocks.Mod
	$(VOCSTATIC) -sPF ulmTimers.Mod
	$(VOCSTATIC) -sPF ulmConditions.Mod
	$(VOCSTATIC) -sPF ulmStreamConditions.Mod
	$(VOCSTATIC) -sPF ulmTimeConditions.Mod
	$(VOCSTATIC) -sPF ulmSysConversions.Mod
	$(VOCSTATIC) -sPF ulmSysStat.Mod
	$(VOCSTATIC) -sPF ulmCiphers.Mod
	$(VOCSTATIC) -sPF ulmCipherOps.Mod
	$(VOCSTATIC) -sPF ulmBlockCiphers.Mod
	$(VOCSTATIC) -sPF ulmAsymmetricCiphers.Mod
	$(VOCSTATIC) -sPF ulmConclusions.Mod
	$(VOCSTATIC) -sPF ulmRandomGenerators.Mod
	$(VOCSTATIC) -sPF ulmTCrypt.Mod
	$(VOCSTATIC) -sPF ulmIntOperations.Mod

	#pow32 libs
	$(VOCSTATIC) -sPF powStrings.Mod

	#misc libs
	$(VOCSTATIC) -sPF MultiArrays.Mod
	$(VOCSTATIC) -sPF MultiArrayRiders.Mod
	$(VOCSTATIC) -sPF MersenneTwister.Mod
	$(VOCSTATIC) -sPF Listen.Mod
	
	#s3 libs
	$(VOCSTATIC) -sPF ethBTrees.Mod
	$(VOCSTATIC) -sPF ethMD5.Mod
	$(VOCSTATIC) -sPF ethSets.Mod
	$(VOCSTATIC) -sPF ethZlib.Mod
	$(VOCSTATIC) -sPF ethZlibBuffers.Mod
	$(VOCSTATIC) -sPF ethZlibInflate.Mod
	$(VOCSTATIC) -sPF ethZlibDeflate.Mod
	$(VOCSTATIC) -sPF ethZlibReaders.Mod
	$(VOCSTATIC) -sPF ethZlibWriters.Mod
	$(VOCSTATIC) -sPF ethZip.Mod
	$(VOCSTATIC) -sPF ethRandomNumbers.Mod
	$(VOCSTATIC) -sPF ethGZReaders.Mod
	$(VOCSTATIC) -sPF ethGZWriters.Mod
	$(VOCSTATIC) -sPF ethUnicode.Mod
	$(VOCSTATIC) -sPF ethDates.Mod
	$(VOCSTATIC) -sPF ethReals.Mod
	$(VOCSTATIC) -sPF ethStrings.Mod

# build remaining tools
#	$(VOCSTATIC0) -sPFS compatIn.Mod
#	$(VOCSTATIC0) -smPS vmake.Mod
#	$(CC) compatIn.c
#	$(CL) vmake.c -o vmake SYSTEM.o Args.o compatIn.o Texts.o Console.o Files.o Reals.o Modules.o Kernel.o Unix.o Strings.o oocIntStr.o oocConvTypes.o oocIntConv.o



stage7:
	#remove non library objects
	rm -f Kernel0.o Files0.o Texts0.o architecture.o prf.o version.o extTools.o OPM.o OPS.o OPT.o OPC.o OPV.o OPB.o OPP.o errors.o
	#objects := $(wildcard *.o)
	#$(LD) objects
	$(ARCHIVE) *.o 
	#$(ARCHIVE) objects
	$(LD) *.o
	echo "$(PREFIX)/lib" > 05vishap.conf

clean:
#	rm_objects := rm $(wildcard *.o)
#	objects
	rm *.h
	rm *.c
	rm *.sym
	rm *.o
	rm *.a
	rm *.$(SHRLIBEXT)

install:
	test -d $(PREFIX)/bin | mkdir -p $(PREFIX)/bin
	cp voc $(PREFIX)/bin/
	cp showdef $(PREFIX)/bin/
	cp ocat $(PREFIX)/bin/
	#cp vmake $(PREFIX)/bin/
	cp -a src $(PREFIX)/

	test -d $(PREFIX)/lib/voc | mkdir -p $(PREFIX)/lib/voc
	test -d $(PREFIX)/lib/voc/ | mkdir -p $(PREFIX)/lib/voc
	test -d $(PREFIX)/lib/voc/obj | mkdir -p $(PREFIX)/lib/voc/obj
	test -d $(PREFIX)/lib/voc/sym | mkdir -p $(PREFIX)/lib/voc/sym

	cp $(LIBRARY).$(SHRLIBEXT) $(PREFIX)/lib
	cp $(LIBRARY).a $(PREFIX)/lib
	cp *.c $(PREFIX)/lib/voc/obj/
	cp *.h $(PREFIX)/lib/voc/obj/
	cp *.sym $(PREFIX)/lib/voc/sym/

	cp 05vishap.conf /etc/ld.so.conf.d/
	ldconfig
	ln -s $(PREFIX) $(PREFIXLN)

#        cp *.o $(PREFIX)/lib/voc/$(RELEASE)/obj/
uninstall:
	rm -rf $(PREFIX)
	rm -rf $(PREFIXLN)
