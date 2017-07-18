(***************************************************************************
Project:     HelloWorld
Purpose:     A libglade-Hello-World with oo2c
Version:     1.0
Predecessor: -
Changes:     -
Target:	     Linux
Compiler:    oo2c
Date:        Jan. 2009
Author:      Frank Hrebabetzky

-- converted to use with voc by noch
***************************************************************************)

MODULE HelloWorld;

IMPORT
  SYSTEM, Args, Out := Console, G, Gdk, Gtk, Glade, handlers;

CONST
  (*GUIFILE =     "gui.glade";*)
  ERRXML =      1;              (* xml file problem *)
  ERRNOTFOUND = 2;              (* widget not found *)

VAR
  argc :        LONGINT;
  argv :        Gtk.ArgVector;
  xml:          Glade.XMLPtr;
  drawing:      Gtk.WidgetPtr;
  GuiFile, name:      Glade.CString;

PROCEDURE (*["Hello"]*) Hello* (widget:Gtk.WidgetPtr; data:SYSTEM.PTR);
BEGIN
  Out.String("Hello, world!");   Out.Ln;
END Hello;


PROCEDURE (*["Draw"]*) Draw* (widget:Gtk.WidgetPtr;
  event:Gdk.EventExposePtr; data:G.pointer): G.boolean;
VAR a: G.int;
BEGIN
  a:= widget.allocation.width DIV 2;
  Gdk.drawArc (widget.window, widget.style.fgGc[ORD(widget.state)], G.TRUE,
  a DIV 2, a DIV 2, a, a, 0, 64*360);
  RETURN G.TRUE;
END Draw;

BEGIN
  argc:= Args.argc;
  argv:= SYSTEM.VAL (Gtk.ArgVector, Args.argv);
  Gtk.init (argc, argv);
  NEW(GuiFile);
  COPY("gui.glade", GuiFile^);
  xml:= Glade.xmlNew (GuiFile, NIL, NIL);
  ASSERT (SYSTEM.VAL(SYSTEM.PTR, xml)#NIL, ERRXML);
  Glade.xmlSignalAutoconnect (xml);
  NEW(name); COPY("drawing", name^);
  drawing:= Glade.xmlGetWidget (xml, name);
  ASSERT (drawing#NIL, ERRNOTFOUND);
  Gtk.main;
END HelloWorld.
