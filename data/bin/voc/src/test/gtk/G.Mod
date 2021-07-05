(***************************************************************************
Project:     G
Purpose:     Interface to Gtk GLib
Version:     2.0
Predecessor: Glib
Changes:     don't repeat 'g_' at the beginning of the names, change some
Target:	     Linux
Compiler:    oo2c
Date:        jan 2009
Author:      Frank Hrebabetzky

-- converted to use with voc by noch
***************************************************************************)

MODULE G (*[INTERFACE "C"; LINK LIB "glib-2.0" ADD_OPTION LibGladePrefix END]*);

IMPORT SYSTEM;

CONST
  FALSE*                = 0;
  TRUE*                 = 1;  (* original: #define TRUE	(!FALSE) *)

TYPE
  boolean*             = LONGINT;
  char*                = CHAR;
  float*               = REAL;
  double*              = LONGREAL;
  int*                 = LONGINT;
  size*                = LONGINT;
  ssize*               = LONGINT;
  uint*                = LONGINT;
  uint8*               = CHAR;
  uint16*              = INTEGER;
  uint32*              = LONGINT;
  ulong*               = LONGINT;
  ushort*              = INTEGER;
  Quark*               = LONGINT;

  VoidPtr*              = SYSTEM.PTR;
  ArrayPtr*            = VoidPtr;
  DataPtr*             = VoidPtr;
  pointer*             = VoidPtr;
  SListPtr*            = VoidPtr;
  TypeClassPtr*        = VoidPtr;

  string*    = POINTER (*[ CSTRING ]*) TO ARRAY OF char;

  VoidFunc*    = PROCEDURE ();
  
  ErrorPtr*= POINTER TO Error;
  Error* =   RECORD
                domain*:                Quark;
                code*:                  int;
                message*:               string;
              END;
  
  TypeInstance* =    RECORD             (* gtype.h *)
                        gClass*:       TypeClassPtr
                      END;

  Object* =  RECORD                     (* gobject.h *)
                gTypeInstance*:       TypeInstance;
                refCount*:             uint;
                qdata*:                 DataPtr
              END;

(*
PROCEDURE -includeglib()
   "#include <glib-2.0/glib.h>";

PROCEDURE -includegmem()
   "#include <glib-2.0/glib/gmem.h>";   

PROCEDURE -includegconvert()
   "#include <glib-2.0/glib/gconvert.h";
*)
PROCEDURE (*["g_free"]*) -free* (mem:pointer)
   "g_free(mem)";
(* 2 versions of g_localeto_utf8: first for using param.'error', second for
   calling the proc.with act.param.'NIL', t.i. not using it.*)
(*PROCEDURE g_locale_to_utf8* (opsysstring:Ptr_gchar; len:gssize;
        VAR bytes_read,bytes_written:gsize; VAR error:GErrorPtr): Ptr_gchar;*)
PROCEDURE (*["g_locale_to_utf8"]*) -localeToUtf8* (opsysstring:string; len:ssize;
        VAR bytesRead,bytesWritten:size; error:VoidPtr): string
	"(G_string)g_locale_to_utf8 (opsysstring, len, bytesRead, bytesWritten, size)";

END G.

