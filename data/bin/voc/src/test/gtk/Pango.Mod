(***************************************************************************
Project:     Pango
Purpose:     Interface
Version:     2.0
Predecessor: 
Changes:     don't repeat 'g_' at the beginning of the names, change some
Target:	     Linux
Compiler:    oo2c
Date:        jan 2009
Author:      Frank Hrebabetzky

-- converted to use with voc by noch
***************************************************************************)

MODULE Pango
  (*[INTERFACE "C"; LINK LIB "pango-1.0" ADD_OPTION LibGTKPrefix END]*);

IMPORT G, SYSTEM;

CONST
  SCALE* =              1024;

TYPE
  ContextPtr* =         G.VoidPtr;
  FontDescriptionPtr* = G.VoidPtr;
  FontPtr* =            G.VoidPtr;
  LanguagePtr* =        G.VoidPtr;
  LayoutPtr* =          G.VoidPtr;

  FontMetricsPtr* =   POINTER TO FontMetrics;
  FontMetrics* =      RECORD
                        refCount*:                     G.uint;
                        ascent*, descent*,
                        approximateCharWidth*,
                        approximateDigitWidth*:       G.int
                      END;
  
  RectanglePtr* =     POINTER TO Rectangle;
  Rectangle* =        RECORD
                        x*, y*, width*, height*: G.int
                      END;
(*
PROCEDURE -includePangoContext()
   "#include <pango-1.0/pango/pango-context.h>";

PROCEDURE -includePangoFont()
   "#include <pango-1.0/pango/pango-font.h>";

PROCEDURE -includePangoLayout()
   "#include <pango-1.0/pango/pango-layout.h>";
*)



PROCEDURE (*["pango_context_get_metrics"]*) -contextGetMetrics*
  (context:ContextPtr; desc:FontDescriptionPtr; language:LanguagePtr):
  FontMetricsPtr
  "(FontMetricsPtr)pango_context_get_metrics(context, desc, language)";

PROCEDURE (*["pango_font_description_from_string"]*) -fontDescriptionFromString*
  (str:G.string): FontDescriptionPtr
  "(Pango_FontDescriptorPtr)pango_font_description_from_string(str)";

PROCEDURE (*["pango_font_get_metrics"]*) -fontGetMetrics*
  (font:FontPtr; language:LanguagePtr): FontMetricsPtr
  "(Pango_FontMetricsPtr)pango_font_get_metrics(font, language)";

PROCEDURE (*["pango_font_metrics_unref"]*) -fontMetricsUnref*
  (metrics:FontMetricsPtr)
  "pango_font_metrics_unref(metrics)";

PROCEDURE (*["pango_layout_get_pixel_extents"]*) -layoutGetPixelExtents*
  (layout:LayoutPtr; VAR inkRect,logicalRect:Rectangle)
  "pango_layout_get_pixel_extents(layout, incRect, logicalRect)";

PROCEDURE (*["pango_layout_get_pixel_size"]*) -layoutGetPixelSize*
  (layout:LayoutPtr; VAR width,height:G.int)
  "pango_layout_get_pixel_size(layout, width, height)";


PROCEDURE (*["pango_layout_set_font_description"]*) -layoutSetFontDescription*
  (layout:LayoutPtr; desc:FontDescriptionPtr)
  "pango_layout_set_font_description(layout, desc)";

PROCEDURE (*["pango_layout_set_text"]*) -layoutSetText*
  (layout:LayoutPtr; text:G.string; length:G.int)
   "pango_layout_set_text(layout, text, lenght)";

END Pango.

