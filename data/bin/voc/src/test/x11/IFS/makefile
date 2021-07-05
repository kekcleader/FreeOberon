CFLAGS=-lX11
export CFLAGS
MODX11="../../../library/oocX11"
VOC = $(MOD) /opt/voc/bin/voc

all:
	$(VOC) -s $(MODX11)/oocX11.Mod $(MODX11)/oocXutil.Mod $(MODX11)/oocXYplane.Mod IFS.Mod IFStest.Mod -m
	#$(VOC) -Cm test.Mod
	#gcc -o test  test.o -fPIC -g -I /opt/voc-1.0/src/lib/system/gcc/x86_64 -I /opt/voc-1.0/lib/voc/obj -lVishapOberon -L. -L/opt/voc-1.0/lib -lX11

clean:
	rm *.c
	rm *.h
	rm *.sym
	rm *.o

