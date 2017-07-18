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
***************************************************************************)

MODULE handlers;

IMPORT
  SYSTEM, Out := Console, G, Gdk, Gtk;

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

END handlers.
