(***************************************************************************
Project:     Gdk
Purpose:     Interface
Version:     2.0
Predecessor: GTK
Changes:     don't repeat 'g_' at the beginning of the names, change some
Target:	     Linux
Compiler:    oo2c
Date:        jan 2009
Author:      Frank Hrebabetzky

-- converted to use with voc by noch
***************************************************************************)

MODULE Gdk
  (*[INTERFACE "C"; LINK LIB "gdk-x11-2.0" ADD_OPTION LibGladePrefix END]*);

IMPORT G, Pango, SYSTEM;

CONST
  GravityNorthWest*           = 1;
  HintMinSize*                = 2;
  
  (* GdkFunction *)
  Copy*                         = 00H;
  Invert*                       = 01H;
  XOR*                          = 02H;
  Clear*                        = 03H;
  And*                          = 04H;
  AndReverse*                   = 05H;
  AndInvert*                    = 06H;
  Noop*                         = 07H;
  Or*                           = 08H;
  Equiv*                        = 09H;
  OrReverse*                    = 0AH;
  CopyInvert*                   = 0BH;
  OrInvert*                     = 0CH;
  Nand*                         = 0DH;
  Set*                          = 0EH;

  (* GdkCapStyle *)
  CapNotLastT*                  = 0;
  CapButt*                      = 1;
  CapRound*                     = 2;
  CapProjecting*                = 3;

  (* GdkJoinStyle *)
  JoinMiter*                    = 0;
  JoinRound*                    = 1;
  JounBevel*                    = 2;

  (* GdkLineStyle *)
  LineSolid*                    = 0;
  LineOnOffDash*                = 1;
  LineDoubleDash*               = 2;

TYPE
  ColormapPtr*          = G.VoidPtr;
  EventPtr*             = G.VoidPtr;
  EventExposePtr*       = G.VoidPtr;
  FontPtr*              = G.VoidPtr;
  CPtr*                 = G.VoidPtr;
  ImagePtr*             = G.VoidPtr;
  PixmapPtr*            = G.VoidPtr;

  ColorPtr* = POINTER TO Color;
  Color* =    RECORD
                pixel* :                G.uint32;
                red*, green*, blue*:    G.uint16;
              END;

  DrawablePtr* = POINTER TO Drawable;
  Drawable* = RECORD                     (* gdkdrawable.h *)
                parentInstance*:        G.Object
              END;
  
  GCValuesPtr* = POINTER TO GCValues;
  GCValues* = RECORD
                foreground*, background*:               Color;
                font*:                                  FontPtr;
                function*, fill*:                       G.int;
                tile*, stipple*, clipMask*:             PixmapPtr;
                subwindowMode*,
                tsXOrigin*, tsYOrigin*,
                clipXOrigin*, clipYOrigin*,
                graphicsExposures*, lineWidth*,
                lineStyle*, capStyle*, joinStyle*:      G.int
              END;
  
  GeometryPtr* = POINTER TO Geometry;
  Geometry* = RECORD
                minWidth*, minHeight*,
                maxWidth*, maxHeight*,
                baseWidth*, baseHeight*,
                widthInc*, heightInc*:          G.int;
                minAspect*, maxAspect*:         G.double;
                winGravity*:                    G.int;
              END;

  RectanglePtr* = POINTER TO Rectangle;
  Rectangle*= RECORD                     (* gdktypes.h *)
                x*, y*, width*, height*:        G.int
              END;
  
  Window* =     Drawable;                (* gdktypes.h *)
  WindowPtr* =  DrawablePtr;

(*
PROCEDURE -includeGdkColor()
   "#include <gtk-2.0/gdk/gdkcolor.h>";

PROCEDURE -includeGdkDrawable()
   "#include <gtk-2.0/gdk/gdkdrawable.h>";

PROCEDURE -includeGdkGc()
   "#include <gtk-2.0/gdk/gdkgc.h>";

PROCEDURE -includeGkdImage()
   "#include <gtk-2.0/gdk/gdkimage.h>";

PROCEDURE -includeGdkPixmap()
   "#include <gtk-2.0/gdk/gdkpixmap.h>";
*)
PROCEDURE (*["gdk_colormap_alloc_color"]*) -colormapAllocColor*
  (colormap:ColormapPtr; color:ColorPtr;
  writeable,bestMatch:G.boolean): G.boolean
  "(G_boolean)gdk_colormap_alloc_color(colormap, color, writeable, bestMatch)";

PROCEDURE (*["gdk_colormap_get_system"]*) -colormapGetSystem* (): ColormapPtr
   "(Gdk_ColormapPtr)gdk_colormap_get_system ()";

PROCEDURE (*["gdk_draw_arc"]*) -drawArc* (drawable:DrawablePtr; gc:CPtr;
        filled:G.boolean; x,y,width,height,angle1,angle2:G.int)
   "gdk_draw_arc(drawable, gc, filled, x, y, width, height, angle1, angle2)";

PROCEDURE (*["gdk_draw_image"]*) -drawImage* (drawable:DrawablePtr;
  gc:CPtr; image:ImagePtr; xsrc,ysrc,xdest,ydest,width,height:G.int)
 "gdk_draw_image(drawable, gc, image, xsrc, ysrc, xdest, ydest, width, height)";

PROCEDURE (*["gdk_draw_layout"]*) -drawLayout* (drawable:DrawablePtr;
  gc:CPtr; x,y:G.int; layout:Pango.LayoutPtr)
  "gdk_draw_layout(drawable, gc, x, y, layout)";

PROCEDURE (*["gdk_draw_line"]*) -drawLine* (drawable:DrawablePtr;
  gc:CPtr; x1,y1,x2,y2:G.int)
  "gdk_draw_line(drawable, gc, x1, y1, x2, y2)";

PROCEDURE (*["gdk_draw_point"]*) -drawPoint* (drawable:DrawablePtr;
  gc:CPtr; x,y:G.int)
  "gdk_draw_point(drawable, gc, x, y)";

PROCEDURE (*["gdk_draw_rectangle"]*) -drawRectangle* (drawable:DrawablePtr;
  gc:CPtr; filled:G.boolean; x, y, width, height : G.int)
  "gdk_draw_rectangle(drawable, gc, filled, x, y, width, height)";

PROCEDURE (*["gdk_drawable_get_image"]*) -drawableGetImage* (drawable : DrawablePtr; x, y, width, height : G.int): ImagePtr
  "(Gdk_ImagePtr)gdk_drawable_get_image(drawable, x, y, width, height)";

PROCEDURE (*["gdk_gc_get_values"]*) -gcGetValues* (gc:CPtr; VAR values:GCValues)
  "gdk_gc_get_values(gc, values)";

PROCEDURE (*["gdk_gc_new"]*) -gcNew* (drawable:DrawablePtr): CPtr
   "(Gdk_PCtr)gdk_gc_new(drawable)";

PROCEDURE (*["gdk_gc_set_background"]*) -gcSetBackground*(gc:CPtr; color:ColorPtr)
   "gdk_gc_set_background(gc, color)";

PROCEDURE (*["gdk_gc_set_clip_origin"]*) -gcSetClipOrigin* (gc:CPtr; x,y:G.int)
   "gdk_gc_set_clip_origin(gc, x, y)";

PROCEDURE (*["gdk_gc_set_clip_rectangle"]*) -gcSetClipRectangle* (gc:CPtr; rectangle:RectanglePtr)
  "gdk_gc_set_clip_rectangle(gc, rectangle)";

PROCEDURE (*["gdk_gc_set_foreground"]*) -gcSetForeground* (gc:CPtr; color:ColorPtr)
   "gdk_gc_set_foreground(gc, color)";

PROCEDURE (*["gdk_gc_set_function"]*) -gcSetFunction* (gc:CPtr; function:G.int)
   "gdk_gc_set_function(gc, function)";

PROCEDURE (*["gdk_gc_set_line_attributes"]*) -gcSetLineAttributes*
  (gc:CPtr; lineWidth,lineStyle,capStyle,joinStyle:G.int)
  "gdk_gc_set_line_attributes(gc, lineWidth, lineStyle, capStyle, joinStyle)";

PROCEDURE (*["gdk_gc_set_rgb_fg_color"]*) -gcSetRgbFgColor*(gc:CPtr; color:ColorPtr)
   "gdk_gc_set_rgb_fg_color(gc, color)";

PROCEDURE (*["gdk_gc_set_rgb_bg_color"]*) -gcSetRgbBgColor*
  (gc:CPtr; color:ColorPtr)
  "gdk_gc_set_rgb_bg_color(gc, color)";

PROCEDURE (*["gdk_image_get_pixel"]*) -imageGetPixel*
  (image:ImagePtr; x,y:G.int): G.uint32
  "(G_uint32)gdk_image_get_pixel(image, x, y)";

PROCEDURE (*["gdk_image_put_pixel"]*) -imagePutPixel*
  (image:ImagePtr; x,y:G.int; pixel:G.uint32)
  "gdk_image_put_pixel(image, x, y, pixel)";

PROCEDURE (*["gdk_pixmap_new"]*) -pixmapNew*
  (drawable:DrawablePtr; width,height,depth:G.int): PixmapPtr
  "(Gdk_PixmapPtr)gdk_pixmap_new(drawable, width, height, depth)";

END Gdk.

