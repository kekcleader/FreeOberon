ofront+ -887wm TestModule.Mod && \
gcc -o TestModule -g3 -O0 -fno-exceptions \
  -I ../data/bin/OfrontPlus/Target/Linux_amd64/../../Mod/Lib \
  -I ../data/bin/OfrontPlus/Target/Linux_amd64/Lib/Obj \
  TestModule.c \
  ../data/bin/libFreeOberon.a \
  ../data/bin/OfrontPlus/Target/Linux_amd64/Lib/libOfront.a

