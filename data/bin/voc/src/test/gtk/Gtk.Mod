(***************************************************************************
Project:     Gtk
Purpose:     Interface
Version:     2.0
Predecessor: GTK 1.1
Changes:     don't repeat 'gtk_' at the beginning of the names
Target:	     Linux
Compiler:    oo2c
Date:        jan 2009
Author:      Frank Hrebabetzky

-- converted to use with voc by noch
***************************************************************************)

MODULE Gtk
  (*[INTERFACE "C"; LINK LIB "gtk-x11-2.0" ADD_OPTION LibGladePrefix END]*);

IMPORT G, Gdk, Pango, SYSTEM;

CONST
  WindowToplevel*      = 0;
  (* GtkAttachOptions *)
  EXPAND*               = 1;
  SHRINK*               = 2;
  FILL*                 = 4;
  (* GtkButtonsType *)
  ButtonsNone*          = 0;
  ButtonsOk*            = 1;
  ButtonsClose*         = 2;
  ButtonsCancel*        = 3;
  ButtonsYesNo*         = 4;
  ButtonsOkCancel*      = 5;
  (* GtkDialogFlags *)
  DialogModal*          = 1;
  DialogDestroyWithParent* = 2;
  DialogNoSeparator*    = 4;
  (* GtkMessageType *)
  MessageInfo*          = 0;
  MessageWarning*       = 1;
  MessageQuestion*      = 2;
  MessageError*         = 3;

TYPE
  Object* =   RECORD                     (* gtkobject.h *)
                parentInstance*:        G.Object;
                flags*:                 G.uint32
              END;
  RcStylePtr            = G.VoidPtr;
  Allocation            = Gdk.Rectangle;

  StylePtr*             = POINTER TO Style;
  Style* = RECORD                        (* gtkstyle.h *)
      parentInstance*:                         G.Object;
      fg*, bg*, light*, dark*, mid*, text*,
      base*, textAa*:                          ARRAY 5 OF Gdk.Color;
      black*, white*:                           Gdk.Color;
      fontDesc*:                               Pango.FontDescriptionPtr;
      xthickness*, ythickness*:                 G.int;
      fgGc*, bgGc*, lightGc*, darkGc*,
      midGc*, textGc*, baseGc*, textAaGc*:     ARRAY 5 OF Gdk.CPtr;
      blackGc*, whiteGc*:                       Gdk.CPtr;
      bgPixmap*:                                ARRAY 5 OF Gdk.PixmapPtr;
      attachCount*, depth*:                     G.int;
      colormap*:                                Gdk.ColormapPtr;
      privateFont*:                             Gdk.FontPtr;
      privateFontDesc*:                         Pango.FontDescriptionPtr;
      rcStyle*:                                 RcStylePtr;
      styles*:                                  G.SListPtr;
      propertyCache*:                           G.ArrayPtr;
      iconFactories*:                          G.SListPtr
    END;
    
  Requisition*  = RECORD                 (* gtkwidget.h *)
                    width*, height*:    G.int
                  END;

  WidgetPtr*    = POINTER TO Widget;
  Widget*       = RECORD                 (* gtkwidget.h *)
      object*:          Object;
      privateFlags*:    G.uint16;
      state*:           G.uint8;
      savedState*:      G.uint8;
      name*:            G.string;
      style*:           StylePtr;
      requisition*:     Requisition;
      allocation*:      Allocation;
      window*:          Gdk.WindowPtr;
      parent*:          WidgetPtr
    END;

  ArgVector* =  POINTER TO ARRAY OF POINTER TO ARRAY OF CHAR;
(*
PROCEDURE -includeGtk()
   "#include <gtk-2.0/gtk/gtkmain.h>";
*)
PROCEDURE (*["gtk_init"]*) -init* (VAR argc:LONGINT; VAR argv:ArgVector)
   "gtk_init(argc, argv)";

PROCEDURE (*["gtk_main"]*) -main*
   "gtk_main()";

END Gtk.
