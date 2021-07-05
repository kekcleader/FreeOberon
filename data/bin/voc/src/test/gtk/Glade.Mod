(***************************************************************************
Project:     Glade
Purpose:     Interface
Version:     1.0
Predecessor: -
Changes:     -
Target:	     Linux
Compiler:    oo2c
Date:        jan 2009
Author:      Frank Hrebabetzky

-- converted to use with voc by noch
***************************************************************************)

MODULE Glade
  (*[INTERFACE "C"; LINK LIB "glade-2.0" ADD_OPTION LibGladePrefix END]*);

IMPORT
  SYSTEM, Gtk;

TYPE

  String* = ARRAY 256 OF CHAR;
  GString = ARRAY 16000 OF CHAR;
  CString* =    POINTER (*[CSTRING]*) TO String;
  XMLPtr* =     (*SYSTEM.PTR*) POINTER TO GString;

(*
PROCEDURE -includeGladeXml()
   "#include <libglade-2.0/glade/glade-xml.h>";
*)
PROCEDURE (*["glade_xml_new"]*) -xmlNew*
        (fname,root,domain:CString): XMLPtr
   "(Glade_XMLPtr)glade_xml_new(fname, root, domain)";

PROCEDURE (*["glade_xml_signal_autoconnect"]*) -xmlSignalAutoconnect*
        (self:XMLPtr)
	"glade_xml_signal_autoconnect(self)";

PROCEDURE (*["glade_xml_get_widget"]*) -xmlGetWidget*
        (self:XMLPtr; name:CString): Gtk.WidgetPtr
	"(Gtk_WidgetPtr)glade_xml_get_widget(self, name)";

END Glade.
