CFLAGS=`pkg-config --cflags --libs libglade-2.0` -export-dynamic
export CFLAGS

VOC = /opt/voc/bin/voc

all:
#	$(VOC) -s G.Mod
#	$(VOC) -s Pango.Mod
#	$(VOC) -s Gdk.Mod
#	$(VOC) -s Gtk.Mod
#	$(VOC) -s Glade.Mod
#	$(VOC) -s handlers.Mod
#	$(VOC) -m HelloWorld.Mod
	$(VOC) -s G.Mod Pango.Mod Gdk.Mod Gtk.Mod Glade.Mod handlers.Mod HelloWorld.Mod -m

clean:
	rm *.c
	rm *.h
	rm *.sym
	rm *.o
