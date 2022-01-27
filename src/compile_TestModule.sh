ofront+ -887wm TestModule.Mod && \
gcc -o TestModule -g3 -O0 -fno-exceptions \
  -I ../Data/bin/OfrontPlus/Target/Linux_amd64/../../Mod/Lib \
  -I ../Data/bin/OfrontPlus/Target/Linux_amd64/Lib/Obj \
  TestModule.c \
  ../Data/bin/libFreeOberon.a \
  ../Data/bin/OfrontPlus/Target/Linux_amd64/Lib/libOfront.a

