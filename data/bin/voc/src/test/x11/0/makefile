#for old systems like RHEL4 use
#CFLAGS=-L/usr/X11R6/lib -lX11
MODX11="../../../library/oocX11"
CFLAGS=-lX11
export CFLAGS
VOC = $(MOD) /opt/voc/bin/voc

all:
	$(VOC) -s $(MODX11)/oocX11.Mod $(MODX11)/oocXutil.Mod $(MODX11)/oocXYplane.Mod test.Mod -m
	#$(VOC) -Cm test.Mod
	#gcc -o test  test.o -fPIC -g -I /opt/voc-1.0/src/lib/system/gcc/x86_64 -I /opt/voc-1.0/lib/voc/obj -lVishapOberon -L. -L/opt/voc-1.0/lib -lX11

clean:
	rm *.c
	rm *.h
	rm *.o
