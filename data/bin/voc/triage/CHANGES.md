commit 6d36f4ee8c4487f85fa751f39b2302f0a998a3cb (HEAD, origin/master, origin/HEAD, master)
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Sep 19 00:31:50 2014 +0400

    fixed date

commit 0d85205cfdec38e272f0c4f7af938a936c127376
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Sep 19 00:28:51 2014 +0400

    fixed bug in Reals.Mod which was actual on x86_64
    without prototype, return type of ecvt was int, which has 4 byte size on
    x86 but still has the same size on x86_64, that's why pointer which is 8
    byte long could not fit in the variable holding return value. And it
    could get negative value causing programs to explode. Fixed with casting
    the result to LONGINT.

commit 90a0dc3ae28eae79d536343cf95153bb0b099176
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 23:56:28 2014 +0400

    updated version.Mod and makefiles to reflect the new version.

commit 807a7bd019a406ec5e8f3a2fbfce340def29fcac
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 19:35:24 2014 +0400

    updated changelog

commit 0ae29b9b4c9badfe0fa0c04f618afc1c96eea037
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 19:34:23 2014 +0400

    fixed spec file to reflect latest changes

commit 2108b6bb72663885e5febfda912ec8d67973de88
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 19:21:26 2014 +0400

    updated spec file

commit 7e9069e08d89c3d4fc002c779f98839abc073eb4
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 19:14:06 2014 +0400

    improved changelog generation script to fix the email address to possibly prevent spambots to identify an email address.

commit ed4572f096378e6aa71a4d1c6f6f531024f6b2b8
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 19:08:09 2014 +0400

    fixed permissions of changelog generation script

commit 8ef024ac15786a8c2e027097cd13847d4808b1ad
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 19:06:57 2014 +0400

    fixed changelog generator script

commit d8c6930c2d2655dc6954a2ce0a78c967be495751
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 19:05:40 2014 +0400

    updated changelog - CHANGES file.

commit 3470abddde8d307902e7c64b2159642c3f57f3e4
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 18:56:52 2014 +0400

     updated changes

commit 5e57b0459db53cde5ecf78862f456ff665d0a336
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 18:55:07 2014 +0400

    spec file to 1.0.1 update

commit a3891b3f3c7f4bc3a7f547d21d1622be0515b3d1
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 18:48:35 2014 +0400

    updated changelog, updated FAQ on how to solve Raspberry Pi building errors.

commit 803af7e43910114f403bceebb97ea31e072ecfbf
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 18 18:39:59 2014 +0400

    making 1.0.1 release

commit 69defc9ce01c86d57c2cc29eb1251a86d6bf4006
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Sep 17 20:01:24 2014 +0400

    fix

commit 9892f9205c98579fcad9695dc4007584ace8e6e4
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Sep 17 19:59:22 2014 +0400

    even faster way

commit 05b8d63835cbb5ec6c44611ca0a860b8c0b8740d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Sep 17 15:21:33 2014 +0400

    no overflow in OPM anymore

commit 04662f9e7d9e24f8158f73d1f98a8e54092192be
Author: root <root[at]raspberrypi.(none)>
Date:   Mon Sep 15 19:00:59 2014 +0000

    updated arm bootstrap binary

commit c2b91243e9f73334516b743b7eb49d1c071d6014
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Sep 15 22:14:08 2014 +0400

    improved risc crosscompiler, added example and readme.

commit 1acddf0fb9d9adbf7bc5927365f22a69f0cfd39f
Author: norayr chilingarian <norayr[at]vishap.am>
Date:   Sun Sep 14 22:53:24 2014 +0400

    found problem in OPV.stat, not properly handled yet. needs investigation.

commit bf48ee50dec9b0cd81279a4439cef39ad4965bf9
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sun Sep 14 21:30:59 2014 +0400

    spec file fixes on pidora (fc20 on raspberry pi)

commit c900218965173a69c5fe9afa5ba53430ae663a11
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sun Sep 14 06:09:09 2014 +0400

    re re revised oberon compiler for RISC works -- noch

commit c8cc10450766a6e1f8e472fa8da2e7258bcf6434
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sat Sep 13 18:27:48 2014 +0400

    fixed or sources

commit 1c7d4dc066c27b9b19700b4a0c9018c140c0d108
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 11 15:57:22 2014 +0400

    updated README.md with info how to build rpm from provided spec file.

commit bef25cd7a75853470a6478d3526334c3e182b179
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 11 15:46:09 2014 +0400

    added crlf handling partly following discussion at
    
    https://code.google.com/p/ofront/issues/detail?id=3
    
    and by introducing corresponding changes in ShowLine and ShowLineErr
    functions
    in OPM module.

commit 15ca10d4ce66ca9f0f2220ab18d88ed1c65b023f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 11 13:25:21 2014 +0400

    changes to the spec file to compile on x86_64, x86, armv6hj_hardfp,
    armv7a_hardfp
    also makes this spec file less distribution specific:
    * no glibc-static on rhel4/5
    * xorg-devel is called xorg-x11-devel on rhel4
    thus requierements are changed to search for header files, not package
    names.

commit 143bd70de335bd678881a2f9376fc2ed16b2af45
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Sep 11 13:21:50 2014 +0400

    rpmbuild spec file by D. E. Evans (sinuhe[at]gnu.org).

commit 06fa95074846dec3ea0f28c12a99fb84fe93a8ae
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Aug 28 14:23:36 2014 +0400

    added IFS ( Iterated Function System ) example from Reiser's book

commit 0b2f1902efc64cac3b29fd79bd0b3a671d0a5a18
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Aug 4 14:15:47 2014 +0400

    added ReadByte wrapper for compatibility with latest NW Oberon system

commit 5f508b16bb8d0a2caff67f5c0363267a44a74e07
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri May 30 10:19:32 2014 +0400

    fixed games with compatIn module

commit da97c546c43e292ce9361aab833f776b9b2e08e8
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue May 20 01:02:52 2014 +0400

    freebsd fix for ldconfig

commit 2d6ac451bae3ebee1a66ab0f11cd4cb2e9206dcb
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue May 20 00:56:33 2014 +0400

    freebsd port works.
    I have no freebsd, and port was made by request and with help of
    tangentstorm from #oberon channel (:
    still it's not well tested and is considered experimental.

commit 1186133f78fd42853b95d3f8651c12943c5082ab
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed May 7 21:19:57 2014 +0400

    fixed stage0 in all makefiles

commit f540d26ad4fa0d283d12871311f95df9505270e6
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed May 7 21:04:23 2014 +0400

    vocparam removed

commit bf6e685d1cef8be284703bcdf467ba386e74a0cf
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed May 7 21:02:32 2014 +0400

    removed unnecessary binaries

commit 74f47aa69cf7e30122bb3741911ecf9441f52d9f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed May 7 20:09:30 2014 +0400

    0. fixed OPM.Mark bug, now when pos = -1 it shows error correctly.
    1. added cool error message handling with showing "^" under the line
    which points exactly where the error is.

commit 561137e16dcd601cb17627d3e2f342bcfb7306c0
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Apr 14 02:29:33 2014 +0400

    main program msg is also green

commit fc3af7e3af90dffa19572dca84595c94092eab95
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Apr 14 02:23:52 2014 +0400

    x86_64 and powerpc bootstrap binaries update

commit 72b53f61f74ffc0392c89f385f505dc0f337e7fa
Author: norayr <norayr[at]arnet.am>
Date:   Mon Apr 14 02:20:31 2014 +0400

    raspberry pi bootstrap binary

commit ca80f58e9450ba10e0e95f64fce98a9c8689b0a7
Author: norayr <norayr[at]arnet.am>
Date:   Mon Apr 14 06:01:11 2014 +0800

    darwin bootstrap binary

commit 175a480412acf782b70c03f736b3a4cba7b06065
Author: norayr <norayr[at]arnet.am>
Date:   Mon Apr 14 01:57:06 2014 +0400

    green output, powerpc binaries

commit f4d3bb13ff66376938dccb71cd647da7333b3770
Author: norayr <norayr[at]arnet.am>
Date:   Mon Apr 14 05:32:39 2014 +0800

    darwin bootstrap binary

commit 338c3f47e86aa7e7c3acdcfb15fb86dcf9854a81
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Apr 14 01:22:03 2014 +0400

    first colored messasges in OPM using vt100, 'f' option added to disable
    it

commit 4943886b6436a439a0250f4591114cd908262069
Author: norayr <norayr[at]arnet.am>
Date:   Sun Apr 13 21:04:37 2014 +0400

    module crt almost completed, crttest for reference

commit fd34af424eacdba8cc24ed844cf0b39990b60fb9
Author: norayr <norayr[at]arnet.am>
Date:   Sun Apr 13 14:56:28 2014 +0400

    powerpc clang bootstrap binary updated

commit c35e1e499e05982822f56348854cd3572b34411c
Author: norayr <norayr[at]arnet.am>
Date:   Sun Apr 13 14:50:25 2014 +0400

    updated raspberry pi gcc bootstrap binary

commit 6ba3d536933bc6062918176deb2027b77f42c319
Author: norayr <norayr[at]arnet.am>
Date:   Sun Apr 13 14:35:34 2014 +0400

    updated powerpc bootstrap binary

commit 018b64defcc554311d66586fef4d62613e96c84e
Author: norayr <norayr[at]arnet.am>
Date:   Sun Apr 13 18:26:46 2014 +0800

    darwin bootstrap binary updated

commit 01664df2eee197fbee209108e0fed27567c832df
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sun Apr 13 14:15:48 2014 +0400

    gnuc -> gcc, more abstraction in makefiles and extTools

commit cd6978683336daa7107777ba9f1e64ccbf4488bf
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sun Apr 13 13:17:00 2014 +0400

    extTools.Mod, fix warnings like "argument unused during compilation:
    '-L.'"

commit 61ef35ff33e1a9dec9b2a42d53b5830b5f93c681
Author: norayr <norayr[at]arnet.am>
Date:   Sun Apr 13 12:12:44 2014 +0400

    clang powerpc platform

commit ad8e18c77782172280e3d3b778c81febc0a8b787
Author: root <root[at]raspberrypi.(none)>
Date:   Sat Apr 12 02:27:13 2014 +0400

    small fix in extTools module

commit 16a810e037bd2b9fab193656f710c09a4558ad07
Author: root <root[at]raspberrypi.(none)>
Date:   Sat Apr 12 02:11:40 2014 +0400

    added Makefile to build vt100 and crt modules.

commit 7c1a5ebea39be7fd5f2a715c0b100ee22e9536b6
Author: root <root[at]raspberrypi.(none)>
Date:   Sat Apr 12 02:06:17 2014 +0400

    raspberry pi bootstrap binary updated (;

commit 7f11185f6a0ccea0233cefe4a6e57ac8e9f39830
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Apr 11 21:41:49 2014 +0400

    vt100 and crt units, some changes in Unix.Mod

commit c0b83a8ee9cfedd5d2b36f4c34b80cfbb2cce9d6
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Apr 11 17:21:57 2014 +0400

    vt100 improved

commit ec730b6da2a6f5e1eb0e91da77944db1dcd37d1b
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Apr 11 15:02:26 2014 +0400

    initial vt100 module release

commit f066c42eb985e6ae4d515e2be3b21d4df6948111
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Apr 10 17:51:05 2014 +0400

    silences clang warnings of type "place parentheses around the '&' expression". small fix in OPV to
    make it

commit b25a810007dbc05b67c45ffd9c9584451c7040e4
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Apr 10 17:02:55 2014 +0400

    added includes to not use internal write, read in Console and Unix

commit 615253e7a93026d2e9fb82deaa5a4a635290f0b6
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Apr 10 14:17:41 2014 +0400

    clang is used to compile libs on linux too.

commit b72099fddcb46ae9abddd3a3c681b3e7ad400e38
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Apr 10 14:09:01 2014 +0400

    same fixes as in previous commit for gcc

commit 9200db9d2140dc800ddaaa6761f9f59f47fb97ca
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Apr 10 14:03:53 2014 +0400

    changed long to unsigned long in SYSTEM.h and SYSTEM.c0 to silence clang
    warnings

commit d2680335c65bc9ede4aedcb740186cbbb8ddd79c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Mar 27 16:44:51 2014 +0400

    linux clang platform added

commit 87f7119dfd52ebe995b4382383441368fe116c35
Author: Norayr Chilingarian <noch[at]Stewarts-MacBook-Pro.local>
Date:   Fri Mar 21 06:53:33 2014 +0800

    static and dynamic linking works on macosx -- noch

commit bdb2b32588c8e81e604cd987518378b8f2d7a659
Author: Norayr Chilingarian <noch[at]Stewarts-MacBook-Pro.local>
Date:   Fri Mar 21 04:22:23 2014 +0800

    fixed problem with short prefix path in version module

commit e1f76da27804f23e804a2012937320fb6c7f92b2
Author: Norayr Chilingarian <noch[at]Stewarts-MacBook-Pro.local>
Date:   Fri Mar 21 04:00:44 2014 +0800

    separated Kernel, Files. Texts modules for bootstrapping and general use

commit e0a915b319233f7dfa73c21dd05738e4299ce05e
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Mar 20 21:51:08 2014 +0400

    excluded compiler (non library) object files from libraries.
    synced linux and macosx makefiles more

commit f3548d289fddc7bf3134b73a859886fd8511dfd0
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Mar 20 21:11:03 2014 +0400

    prefixed installation now works.
    fixed bug with -m, it couldn't work because libVishapOberon contained
    bindings to X11 but was not linked to X11

commit 2610f274ebfc893b7db2c6ae79221dc26fe3789a
Author: Norayr Chilingarian <noch[at]Stewarts-MacBook-Pro.local>
Date:   Thu Mar 20 18:40:07 2014 +0800

    dylib and a archive generation under macosx

commit 93d73204c701918ca71c3502f500c5143635ade9
Author: Norayr Chilingarian <noch[at]Stewarts-MacBook-Pro.local>
Date:   Thu Mar 20 07:04:05 2014 +0800

    eventually, macosx version. can compile itself.

commit 97fd38782727a1fc4230f3aa9805ba16d0e282cd
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Mar 19 04:33:20 2014 +0400

    fixed bug in darwin's system.c0 file

commit 5da154ee1c692e6b74b07912984d5393607ddb19
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Mar 19 04:20:47 2014 +0400

    Files, Kernel changes to eliminate warnings under darwin

commit e9b49fedc9199504d68790608cba8ac9c8b8f5d9
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Mar 19 04:09:44 2014 +0400

    fixes

commit f9e43e94454eb1002fbd00a1c85f4725d5be263d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Mar 19 02:54:48 2014 +0400

    SYSTEM.c0 fix for Darwin platform

commit 7ed322be7903745b420947387e58133e295a3578
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Mar 19 02:49:37 2014 +0400

    SYSTEM.h fix for darwin

commit 08f6becf7d7d88430b82d94c1b492f0883330d29
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Mar 19 02:38:17 2014 +0400

    fixed darwin Unix.Mod module

commit a7f927b36c696c02782bc2180af8779fa202fae0
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Mar 19 02:36:19 2014 +0400

    darwin port... making...

commit 092de30de383b83cee700451d2aabbaa4036cc23
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Mar 19 02:26:05 2014 +0400

    par file for clang

commit 279e037b5ffac4f90f29c001bf0b664f1e811f27
Author: Norayr Chilingarian <noch[at]Stewarts-MacBook-Pro.local>
Date:   Wed Mar 19 06:23:47 2014 +0800

    Darwin port ... yet not ready

commit 02f7cad3569bf8a3e294a0e78236057e0da91371
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Mar 18 20:25:59 2014 +0400

    small fix

commit 2fbafbcadbff45a1d76c600d9bf99a137d092d4d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Mar 18 20:09:27 2014 +0400

    fixed all makefiles

commit 49b86a4ac5f92113e807a12fc11df3ee305ab35c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Mar 18 20:05:19 2014 +0400

    added target os, added experimental darwin, starting darwin port

commit 048a6f7f35acd45184a35fd087145499a7a1f4fd
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Feb 11 22:35:57 2014 +0400

    fixed makefile

commit d7d6a6607126ee4e898c5a5860cbb2592643a8f4
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Feb 11 22:32:26 2014 +0400

    fixed makefile

commit 0571cd78413ed35992a4d53870c6d6aab84ceec2
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 20:31:37 2014 +0400

    rename

commit c72709c86ea8e64a33fb9f02e4fb6b323e8891da
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 20:30:26 2014 +0400

    readme fix

commit a7eaf9cacb2f7eb78be6217cdc1c08fa2fc85483
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 20:29:11 2014 +0400

    not important change

commit f77ccb00588038263cfc91f6241c4ee18f123077
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 20:27:18 2014 +0400

    added audio example

commit 5356b94f898af0f70222e72faba1feeb00c7b425
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 18:12:15 2014 +0400

    added two more examples Tron and Vier

commit fd8a8cac54728de3f29f9d35209c0ea5b488c916
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 17:56:26 2014 +0400

    fixed tetris readme

commit ec7a6854667b4a6f17c035d8b53f8cdc3920f0fc
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 17:01:10 2014 +0400

    tetris example added

commit a2fbb3aaa4680d068731530b19fee7477170559d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 16:48:44 2014 +0400

    minesweeper example added

commit 1e13d96ce192ce5af6380a2935a2d7474e40c868
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 16:39:46 2014 +0400

    compatIn improved, vmake makefile added

commit 74bb4adb10312d0324d5200c3035e2673f975d11
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Feb 3 12:15:35 2014 +0400

    Listen.Mod added

commit 97181a4b8d7b6bbae32aaf86dc1631f3c6b34f1c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Jan 31 17:08:54 2014 +0400

    gtk example

commit 9fb89d2a1423c04af313cef4394cd6abab74536f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Jan 30 19:42:58 2014 +0400

    added PacMan demo

commit c1f00814789fc9212c55ddee84ff67c5eb33aabc
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Jan 30 13:01:00 2014 +0400

    makefile fix

commit 00fa074dd4c2b7420b4bef2cf15b31add7fe2e36
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Jan 30 00:16:31 2014 +0400

    updated X11 test makefile for old systems

commit 3618fac1b10eed7fd3eb268dda5c10422f874fd7
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Jan 30 00:03:19 2014 +0400

    remaining ooc C type files

commit 47c51986a1dc7844e7ab2410d2d2db3ffa67020c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 29 23:59:31 2014 +0400

    XYplane and X wrappers added

commit 4bacf7f7528fc2ddcefde0687503815076f8cd23
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Jan 24 23:04:41 2014 +0400

    Sets module

commit 938c3786c80ce022a2a539b215e971264ca109a8
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Jan 24 18:27:12 2014 +0400

    Sets.Mod added to makefile

commit 6cd74433a2b4e7c5d8af8af77bead8264b4e4629
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Jan 24 18:24:26 2014 +0400

    Sets.Mod ported, works for 64 bit too

commit b600d11d01ddb15b65d2304fbb7a4a561d3fb9a4
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Jan 24 18:22:02 2014 +0400

    Sets.Mod from v4 system added (GPL)

commit edf0df4cbf9ba41f10649a49d95764c4c1b78e7c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Jan 24 17:12:26 2014 +0400

    PO 2013 compiler for Wirth's RISC processor now can be compiled with voc

commit cf06850388ae4c534aa3bf159c297b871b948cd4
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Jan 24 17:11:12 2014 +0400

    Project Oberon 2013 edition compiler source added

commit eace02450d3fba5c44298f51147b938501f81a9d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 22 15:50:08 2014 +0400

    OakFiles modified to be closer to PO 2013 Files -- noch

commit b0a30438d1c067983b70380d71decd876bf1bea5
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 22 14:35:18 2014 +0400

    OakFiles, added WriteByte to be more compatible with PO 2013 -- noch

commit 1736258d7de965f6206d1f7f82c93f3b3356321c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 22 00:50:20 2014 +0400

    ported TCrypt module

commit d5a6f185c61f9ec64c0c5e680a60f5f448c73763
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 22 00:43:16 2014 +0400

    ported ulmConclusions, ulmRandomGenerators

commit 7b7c968aacc6e89a1a58d21f540a27bad724a940
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 22 00:28:04 2014 +0400

    ported ulmAsymmetricCiphers.Mod

commit 2e05d3b3397bd48e4dcdf2d74ddc20e5736144b3
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 22 00:20:04 2014 +0400

    ported ulmBlockCiphers.Mod

commit 2a16fd9af70a7c3d103dc874d3cdb947916a5c39
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 22 00:12:50 2014 +0400

    ported ulmCipherOps.Mod

commit 2ae37f223d5f4822eed26f2f8772981eba674876
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 22 00:08:11 2014 +0400

    ulmCiphers added

commit 7fee90885b7a4cd99ebd2cf63d6d286d91787165
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 8 05:22:50 2014 +0400

    powerpc bootstrap binary

commit 13a7216990353c1b32528848d781aa45e1d7e813
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 8 05:14:57 2014 +0400

    powerpc

commit b273a9901bf9d24b59e2618be34417754a60a0c3
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Jan 8 04:01:49 2014 +0400

    powerpc port completed.
    mostly there are changes in Reals.Mod, for big endian.

commit 44086e5817f49734116d2221478b59d86c05ff86
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Jan 6 20:38:56 2014 +0400

    porting to powerpc

commit 931dae4763e25446221ee3860c18fb253d309c3e
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Jan 6 20:30:21 2014 +0400

    adding powerpc target

commit b18729c5195bdd188cf7e7ad125f63ded7921729
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Nov 14 18:47:49 2013 +0400

    Kernel.Mod fixed, so that MODULES variable is always checked first.
    This means, custom module with the same name, as standard, will be checked first.

commit d1ce637c81ed5351564d510025c915a111e34da9
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Nov 13 17:23:03 2013 +0400

    increased command line length

commit 5ea1331d6f1278ceea77b2e23e78ed6dcd9f6f7f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Nov 12 16:36:07 2013 +0400

    Filenames module name fixed

commit 5f88bfe681f53f62f46c2576c868b679f92971b7
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Nov 12 16:05:08 2013 +0400

    oocFilenames.Mod added

commit 2d0c36b73c30cca37f3b2798dd70dba73564a462
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Nov 6 19:50:11 2013 +0400

    ulmSysStat for 32 bit platforms now works

commit 2ed3b84719fb491f4e439c96b30b3c59673098f2
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Nov 6 16:05:53 2013 +0400

    bootstrap binary for x86 updated

commit bbb031f234c6f0e2b54a9e585a666d53636aa71c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Nov 6 16:00:20 2013 +0400

    Reals brought back for x86 and other 32bit platforms with gnuc dependency

commit 015afee491e557aa2f80007e6d9b0a17fe64e23a
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Nov 6 14:42:28 2013 +0400

    ulmEvents fixed, beautified

commit 534c0549fdbba1a1a8924c379b277ff344cbaac8
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Nov 6 00:12:26 2013 +0400

    makefiles updated

commit d9f6914fe5f3acabe685c920a233d5f1aaf37b66
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Nov 6 00:10:20 2013 +0400

    extTools fixed for non 64bit architectures, SysStat can now be compiled on 32bit architectures

commit d2c954e16f4b0b7b4a09c88b04588803e12c7566
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Nov 5 22:05:20 2013 +0400

    SysStat, SysConversions ported

commit 1355629f901bf7488adbcd202c97e266a5a62d34
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Nov 5 15:49:47 2013 +0400

    Unix.Mod modified, synced with output of cpp /usr/include/asm/stat.h

commit c9c82e0a97a31961e5855e74e4a6cfde1a077c59
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Nov 5 14:20:54 2013 +0400

    fixed x86_64/Unix.Mod, swapped mode and nlink fields

commit 909a06c48a21d39bf397a4cc1c0204167343c4fd
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Nov 4 17:17:57 2013 +0400

    ported SysConversions

commit c9646a0f9fbc5c85f79e525d69ba4a5eb18740d1
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Nov 4 16:07:40 2013 +0400

    ported TimeConditions, Conditions fixed

commit 4c7126816b0f0c8de7edfb92d880425ad87c6a1b
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Nov 4 15:24:46 2013 +0400

    ported StreamConditions, Conditions fixed

commit 81e897f416cc1a08c86ce918f95b099cf5d2088b
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Nov 4 15:12:20 2013 +0400

    ulmConditions ported, ulmRelatedEvents fixed

commit 418da2a304dedee3b6d18ce6f038d25886236e06
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Nov 4 15:04:16 2013 +0400

    ported ulmTimers

commit 94ed5a801ea25eb9478168ed56aa4bd12ab97e84
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Nov 4 14:52:35 2013 +0400

    added ulmClocks

commit 6b187773535520c744b112e55f5064dec52ef40d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sat Nov 2 15:48:24 2013 +0400

    array size 32 is not enough with some ulm oberon library files.
    vmake crashed - out of array bounds error. fixed.

commit 1527f30aa30d03f51eb5cd77170f9ab1d6d09141
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 31 23:32:20 2013 +0400

    added v4 strings

commit 6b3baeb47fda67b858e4df90025a29c9f6d5d6c0
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 31 23:03:06 2013 +0400

    added help message to vmake if run without arguments

commit 776ccc8b4686556364a153ee78c5efc5a29690a1
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 31 22:51:42 2013 +0400

    vmake ported

commit 2aeddb9975ffb490bd66391de0fe75d4428bf364
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 31 22:37:05 2013 +0400

    Make module from Trianus system added.
    S3 system filen renamed with prefix eth.

commit 671fa80f5003cd21ca7d63245c2bc4adea719793
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 31 20:43:07 2013 +0400

    ported Sets from S3

commit bd3b90d6b66049cf93ef36ab4ac0af01f0b287d6
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 31 20:39:37 2013 +0400

    ported RandomNumbers

commit fcc5f1447d796b454bd7de31e7b4e87b83f7d160
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 31 18:51:55 2013 +0400

    added GetName function to OakFiles;
    ported BTrees, MD5, Zip, Zlib, ZlibBuffers, ZlibDeflate, ZlibInflate, ZlibReaders, ZlibWriters to compile with voc

commit 8d6b0063bb3eb2f3933a25f5c17c4fef29dcda86
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 30 22:04:03 2013 +0400

    changed hints a little

commit 80a34fe70cb8013355cb0ca3558c7de389b5c141
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 30 21:47:34 2013 +0400

    updated hints file with known bug about shifting variables of set type

commit 740a5077601b59fd823c0a64056e3a67edf8493c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 30 21:41:31 2013 +0400

    updated makefile

commit 5531f92727c386b8d01f1b4934996b584bac5971
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 30 21:40:23 2013 +0400

    ported MersenneTwister to voc

commit 555d3301ff2b9b0b43ed2fb0e0e2df968e0e228c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 30 21:39:40 2013 +0400

    added MersenneTwister.Mod which can be compiled with XDS system. Now will port it to voc

commit 1325713892c39a319119c29870f4e1d025bc008d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 30 19:58:31 2013 +0400

    Unix.Mod for 32bit platforms modified too.

commit 13da72a3ac3d73541928172df9955c9c43a29e29
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 30 19:55:27 2013 +0400

    oocSysClock now don't use C calls, but use Unix.Mod instead.
    Unix.Mod modified, Gettimeofday now returns value.
    Kernel.Mod modified in order to conform to Unix.Mod new interface

commit 80d4889d39c8cfcf4da1d3cb9ae16ba8e778f378
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 21:18:50 2013 +0400

    MultiArrays port

commit 79055e9f2510fe2ed296eede070701b10a880649
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 21:17:53 2013 +0400

    multi arrays initial commit (not binary now) to see changes

commit 1330471474ca71eb1dec100405e671c0f6d15a9a
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 21:11:29 2013 +0400

    updated makefile

commit 0f9b0604da3c97cb180527bf29e8e5ddc7892234
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 21:03:27 2013 +0400

    ported MultyArray module

commit e6bd70d1d3efea226568025e535decdd31205d2e
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 21:02:03 2013 +0400

    MultiArray modules initial commit

commit dda22584da384ed4ad13fc2f2c3e16c6d601599c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 19:41:23 2013 +0400

    Scales fixed, Times added.

commit 86528051819bdbf129b19f80331d281c1bacc176
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 18:43:31 2013 +0400

    ported Scales

commit c5823b76579562a167e152aa7dd526f8734de9b0
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 18:42:28 2013 +0400

    Scales initial commit

commit e76b8bf27ce9795a130bfefd9b24e9bccdd377b1
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 17:15:11 2013 +0400

    ported ulmLoader, ulmNetIO, ulmPersistentDisciplines, ulmPersistentObjects, ulmScales
    fixed ulmConstStrings

commit 841d00e9d08aaf55705ce81ab868ec3465844265
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 29 16:23:31 2013 +0400

    ported SysIO,  modified ulmSYSTEM for that as a wrapper to Unix.Mod
    ulmSYSTEM.UNIXCALLs are wrapped to Unix.Mod functions.
    Added Pipe to Unix.Mod

commit 44734e664358df741c3833300fbb8930058c81e7
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 28 20:49:41 2013 +0400

    ported Write

commit a34ee73f1c864294d43fc37f7da6aef023891dfe
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 28 20:49:07 2013 +0400

    added Write

commit b0fb5713a39f1175ef9cd310bd2161c3e3cda24c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sat Oct 26 18:56:03 2013 +0400

    added Printer module from V4 system/ofront

commit 3c1f0f0906d8ebd0c87d3538dbf04d93dd6b06fa
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sat Oct 26 18:33:26 2013 +0400

    updated makefiles

commit b66639a18b9b507bf8101cb530f7ab2d2ae7596f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sat Oct 26 18:31:38 2013 +0400

    added pow opal strings module

commit 278abe4110aea9bc8eb8b8c84c02d5e258a9d5e3
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 18:44:28 2013 +0400

    ulmSysErrors ported.

commit 9f8fefcd1bd2c8eb08d8113de4877d7781eafc25
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 18:40:35 2013 +0400

    ulmErrors ported.

commit a9ee80528fbb69d45b5c3cfc0e43861421a56497
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 18:34:06 2013 +0400

    ulmErrors initial commit

commit 60f0426d1787354a0de8f5b8f78eb0695dcc9eac
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 18:33:07 2013 +0400

    ulmSys, ulmSysConversions

commit ea1429795c72223f66d6d0c87cafe52b2acffe23
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 18:07:03 2013 +0400

    ulmPlotters

commit 5c5d315fbe4cff91b758026750de281fb1b42be0
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 18:00:42 2013 +0400

    Plotters first commit

commit 6ef66fa5421ef261643b27bef03129d97cf5f828
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 17:54:58 2013 +0400

    ported ulmStrings, ulmConstStrings.
    changed hidden fields limit in OPM module.
    makefiles

commit d3d8ac9de6ef19185afa6bdf73a37c55c1677998
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 16:04:35 2013 +0400

    ConstStrings initial commit

commit 0896b33ccebecab05109f3b0e9abe3c7145b2e28
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 16:01:32 2013 +0400

    ulmStrings ported

commit 0c771ad7a692093cb64d51296669c0456caece7f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 15:58:22 2013 +0400

    ulmStrings first commit

commit 1e73cef60c7c2a8d097a9acf6cc159c64b5ca53c
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 15:50:38 2013 +0400

    ulmTexts.Mod ported

commit a006fc20c20eadaf21b88abc1c1f467eb71f8bc3
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 15:26:13 2013 +0400

    ulmTexts.Mod added

commit af125012597ba35081c1ea38e0496fc4f2f6e07f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 23 15:19:17 2013 +0400

    added ulmOperations.Mod

commit ce6490771e03f2d561b10cd04d448000ef7e37e8
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 22 19:56:23 2013 +0400

    ulmPrint ported, ulmStreams modified.
    needs test, I am not sure it will work correctly.
    it is not clean how some type casts would work in voc.

commit c648686eb7629929abf589b83b990474fc46f8a0
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 22 17:10:42 2013 +0400

    ulmPrint added,
    ulmIEEE, ulmMC68881, ulmReals ported

commit 577a398bfbdeb1c93203f7601d2cb6e84da5a5a6
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 22 16:57:13 2013 +0400

    MC68881, Reals, StreamDisciplines

commit ab6cd805d5b507a6de3a2208b7f92a5ec4eeda35
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 22 16:43:03 2013 +0400

    StreamDisciplines

commit 26711501d038f3396de30c36a3bdebe8d86d502f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 22 16:37:44 2013 +0400

    ulmAssertions, ulmIndirectDisciplines

commit e05e466d38ab6be9de27f1c945012fb3158359d3
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Tue Oct 22 14:11:34 2013 +0400

    added BinaryRider, TextRider, JulianDay.
    riders are not very useful because PosixFileDesc, Files and StdChannels are not ported.

commit 0358bfac55f2ba7597805f638967134255731128
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 21 20:27:54 2013 +0400

    OakFiles fixed

commit 8f34e77d9d77f165231b1ef8c32b5f99cb71d30b
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 21 19:53:26 2013 +0400

    added OakFiles.Mod which does not search for files in OBERON path, implemented ReadLine procedure.
    added oocRts wrapper around Unix.Mod and Args.Mod,added Filenames.Mod.
    Unix.Mod and Args.Mod modified, interface extended.

commit 569ba1e5fd9d4e0f82f5006e71b11e6f82af48f1
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 21 17:14:59 2013 +0400

    modified all makefiles to compile ComplexMath and LComplexMath

commit 1f2fccfa3e091c9cbe19bb4f65d365d8dea378bf
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 21 17:12:38 2013 +0400

    added ComplexMath and LComplexMath

commit fb38248e595e9a51f1aa00e9063de794080cb418
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 21 16:53:56 2013 +0400

    added Channel, Msg, RealConv, RealStr

commit 08c4a44059d19e323273a9098a84de47193e498d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Oct 18 19:05:05 2013 +0400

    improved makefiles, now it's easier to build a compiler.

commit c6a299a1fed65fbc6a9c525d8e95c6ecccccbb7f
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Oct 18 18:43:15 2013 +0400

    ported four more modules from ooc lib

commit 24b30cdae7633db84a86c76681b87cd1ef06c2a4
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Oct 18 17:45:17 2013 +0400

    added oocRealMath oocOakMath modules

commit c9ebc5174d3778614350e90bfc2eab2723a338f3
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Oct 18 17:34:26 2013 +0400

    fixed Reals.Mod, see comments there, git rid of libc dependency, becaus ecvt call caused crash when running ./showdef oocLowLReal.sym file.
    
    added oocLowReal.Mod and oocLowLReal.Mod

commit ec65d603a9e787983d6f99a37872f8925eeae7fc
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Oct 18 01:14:01 2013 +0400

    Reals converted from Oberon text to ascii text

commit f80034927c1ea2c2dcb86d4ad904acb9b56bfa74
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 17 03:28:08 2013 +0400

    fixed directory layout

commit 7303ba3836decc9635c90dbae0baacce372d8b06
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 16 19:30:01 2013 +0400

    updated x86 bootstrap binary

commit af6746cd0f34c0b43461d5ba653c6e402805fcec
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 16 19:22:58 2013 +0400

    ulmTypes.Mod and ulmStreams.Mod modules ported.

commit 4a4b3939a3692fdf5d86f6c40d2a2545ec46b55d
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 16 13:51:35 2013 +0400

    ulmProcess added

commit bf5bc16cd60cab3b214f04dfdc26a0914dac6c16
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Wed Oct 16 01:56:09 2013 +0400

    ulmIO.Mod changed and now it works with 64 bit longint numbers.

commit 2cf9f399e300826bf45a230a185e7076a1830265
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Oct 11 20:57:16 2013 +0400

    ulmSYSTEM implements SYSTEM.UNIXCALL with two calls (read and write a
    character), ported ulmIO which uses those calls.

commit 3071be3c36749f47afdcb66f295e544b6b89e890
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Oct 11 20:49:55 2013 +0400

    ulmSYSTEM updated, implemented SYSTEM.UNIXCALL for one character read
    and write.
    added ulmIO module which uses those calls.

commit 2327556b15bd8d21c3130fd0dd955bb64366abcd
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 10 19:19:33 2013 +0400

    ulmSYSTEM.Mod cleanup

commit 0d9024e4aea0739d35e2a556176264a7eec90459
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Thu Oct 10 19:16:50 2013 +0400

    ulmEvents.Mod does not use C/asm code anymore. getaddr code procedure is
    replaced by more correct SYSTEM.VAL calls.
    
    added Readme and FAQ

commit e81c21e56f4ffbae117812291ab8c9bb92596550
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 7 17:03:04 2013 +0400

    updated linux.gnuc.x86_64 bootstrap binary

commit fef1fe590c9e461d02580e9a0505ad43de7c103b
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 7 17:02:26 2013 +0400

    updated x86_64 bootstrap binary (vocstatic)

commit a3214b81549d7c1d4654c62af52514261ed08ed0
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Mon Oct 7 16:46:04 2013 +0400

    fixed issue with multiple modules compilation.
    now voc adds dependency modules object files to the main module
    compiling command line.
    for example, if MM0 imports MM1 then if we call voc like:
    voc -l MM1.Mod -s MM0.Mod -M
    
     the commandline will look like
    
    cc  MM0.c MM1.o -static  -o MM0  -fPIC -g -I /opt/voc-1.0/src/lib/system/gnuc/x86_64  -I /opt/voc-1.0/lib/voc/obj -lVishapOberon -L. -L/opt/voc-1.0/lib

commit cb804b16cb695eb08e3896e615c4a5a454ddb43e
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sat Oct 5 22:40:38 2013 +0400

    -MC now works, does not compile main unit by default, but creates object
    file and don't link it.

commit 01be73a99d582637642650dfa6a5dc33262302b9
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Sat Sep 28 01:57:02 2013 +0400

    commented out c compiler command line output, may be will add debug mode later.
    -- noch

commit 760d82694852e3d20a22e63979c42ce8c80ba298
Author: Norayr Chilingarian <norayr[at]arnet.am>
Date:   Fri Sep 27 22:34:17 2013 +0400

    voc compiler first commit

commit 4a7dc4b549496f34f4ba8b000614859eb603e12d
Author: norayr <norayr[at]arnet.am>
Date:   Fri Sep 27 08:55:16 2013 -0700

    Initial commit
