MODULE oocXutil (*[INTERFACE "C"]*);

IMPORT
  C := oocC, X := oocX11, SYSTEM;


(* 
 * Bitmask returned by XParseGeometry().  Each bit tells if the corresponding
 * value (x, y, width, height) was found in the parsed string.
 *)
CONST
  NoValue* = 00000H;
  XValue* = 00001H;
  YValue* = 00002H;
  WidthValue* = 00004H;
  HeightValue* = 00008H;
  AllValues* = 0000FH;
  XNegative* = 00010H;
  YNegative* = 00020H;
  
(*
 * new version containing basewidth, baseheight, and wingravity fields;
 * used with WMNORMALHINTS.
 *)
TYPE
  XSizeHintsPtr* = POINTER TO XSizeHints;
  XSizeHints* = RECORD
    flags*: X.ulongmask;        (* marks which fields in this structure are defined *)
    x*, y*: C.int;              (* obsolete for new window mgrs, but clients *)
    width*, height*: C.int;     (* should set so old wm's don't mess up *)
    minwidth*, minheight*: C.int;
    maxwidth*, maxheight*: C.int;
    widthinc*, heightinc*: C.int;
    minaspect*, maxaspect*: RECORD
      x*: C.int;                (* numerator *)
      y*: C.int;                (* denominator *)
    END;
    basewidth*, baseheight*: C.int;(* added by ICCCM version 1 *)
    wingravity*: C.int;        (* added by ICCCM version 1 *)
  END;
  
(*
 * The next block of definitions are for window manager properties that
 * clients and applications use for communication.
 *)
CONST
(* flags argument in size hints *)
  USPosition* = {0};            (* user specified x, y *)
  USSize* = {1};                (* user specified width, height *)
  PPosition* = {2};             (* program specified position *)
  PSize* = {3};                 (* program specified size *)
  PMinSize* = {4};              (* program specified minimum size *)
  PMaxSize* = {5};              (* program specified maximum size *)
  PResizeInc* = {6};            (* program specified resize increments *)
  PAspect* = {7};               (* program specified min and max aspect ratios *)
  PBaseSize* = {8};             (* program specified base for incrementing *)
  PWinGravity* = {9};           (* program specified window gravity *)
(* obsolete *)
  PAllHints* = PPosition+PSize+PMinSize+PMaxSize+PResizeInc+PAspect;

TYPE
  XWMHintsPtr* = POINTER TO XWMHints;
  XWMHints* = RECORD
    flags*: X.ulongmask;(* marks which fields in this structure are defined *)
    input*: X.Bool;   (* does this application rely on the window manager to
			get keyboard input? *)
    initialstate*: C.int;        (* see below *)
    iconpixmap*: X.Pixmap;       (* pixmap to be used as icon *)
    iconwindow*: X.Window;       (* window to be used as icon *)
    iconx*, icony*: C.int;      (* initial position of icon *)
    iconmask*: X.Pixmap;         (* icon mask bitmap *)
    windowgroup*: X.XID;         (* id of related window group *)
  END;

CONST
(* definition for flags of XWMHints *)
  InputHint* = {0};
  StateHint* = {1};
  IconPixmapHint* = {2};
  IconWindowHint* = {3};
  IconPositionHint* = {4};
  IconMaskHint* = {5};
  WindowGroupHint* = {6};
  AllHints* = InputHint+StateHint+IconPixmapHint+IconWindowHint+IconPositionHint+IconMaskHint+WindowGroupHint;
  XUrgencyHint* = {8};
(* definitions for initial window state *)
  WithdrawnState* = 0;          (* for windows that are not mapped *)
  NormalState* = 1;             (* most applications want to start this way *)
  IconicState* = 3;             (* application wants to start as an icon *)
  
(*
 * Obsolete states no longer defined by ICCCM
 *)
CONST
  DontCareState* = 0;           (* don't know or care *)
  ZoomState* = 2;               (* application wants to start zoomed *)
  InactiveState* = 4;           (* application believes it is seldom used; *)
                                (* some wm's may put it on inactive menu *)
(*
 * new structure for manipulating TEXT properties; used with WMNAME, 
 * WMICONNAME, WMCLIENTMACHINE, and WMCOMMAND.
 *)
TYPE
  XTextPropertyPtr* = POINTER TO XTextProperty;
  XTextProperty* = RECORD
    value*: C.charPtr1d;        (* same as Property routines *)
    encoding*: X.Atom;          (* prop type *)
    format*: C.int;             (* prop data format: 8, 16, or 32 *)
    nitems*: C.longint;         (* number of data items in value *)
  END;

CONST
  XNoMemory* = 1;
  XLocaleNotSupported* = 2;
  XConverterNotFound* = 3;
  
CONST  (* enum XICCEncodingStyle *)
  XStringStyle* = 0;
  XCompoundTextStyle* = 1;
  XTextStyle* = 2;
  XStdICCTextStyle* = 3;

TYPE
  XICCEncodingStyle* = C.enum1;
  XIconSizePtr* = POINTER TO XIconSize;
  XIconSize* = RECORD
    minwidth*, minheight*: C.int;
    maxwidth*, maxheight*: C.int;
    widthinc*, heightinc*: C.int;
  END;
  XClassHintPtr* = POINTER TO XClassHint;
  XClassHint* = RECORD
    resname*: C.charPtr1d;
    resclass*: C.charPtr1d;
  END;
  
(*
 * These macros are used to give some sugar to the image routines so that
 * naive people are more comfortable with them.
 *)
(* can't define any macros here *)

(*
 * Compose sequence status structure, used in calling XLookupString.
 *)
TYPE
  XComposeStatusPtr* = POINTER TO XComposeStatus;
  XComposeStatus* = RECORD
    composeptr*: X.XPointer;     (* state table pointer *)
    charsmatched*: C.int;      (* match state *)
  END;
  
(*
 * Keysym macros, used on Keysyms to test for classes of symbols
 *)
(* can't define any macros here *)

(*
 * opaque reference to Region data type 
 *)
TYPE
  XRegion* = RECORD END;
  Region* = POINTER TO XRegion;
  
(* Return values from XRectInRegion() *)
CONST
  RectangleOut* = 0;
  RectangleIn* = 1;
  RectanglePart* = 2;
  
(*
 * Information used by the visual utility routines to find desired visual
 * type from the many visuals a display may support.
 *)
TYPE
  XVisualInfoPtr* = POINTER TO XVisualInfo;
  XVisualInfo* = RECORD
    visual*: X.VisualPtr;
    visualid*: X.VisualID;
    screen*: C.int;
    depth*: C.int;
    class*: C.int;
    redmask*: X.ulongmask;
    greenmask*: X.ulongmask;
    bluemask*: X.ulongmask;
    colormapsize*: C.int;
    bitsperrgb*: C.int;
  END;

CONST
  VisualNoMask* = 00H;
  VisualIDMask* = 01H;
  VisualScreenMask* = 02H;
  VisualDepthMask* = 04H;
  VisualClassMask* = 08H;
  VisualRedMaskMask* = 010H;
  VisualGreenMaskMask* = 020H;
  VisualBlueMaskMask* = 040H;
  VisualColormapSizeMask* = 080H;
  VisualBitsPerRGBMask* = 0100H;
  VisualAllMask* = 01FFH;
  
(*
 * This defines a window manager property that clients may use to
 * share standard color maps of type RGBCOLORMAP:
 *)
TYPE
  XStandardColormapPtr* = POINTER TO XStandardColormap;
  XStandardColormap* = RECORD
    colormap*: X.Colormap;
    redmax*: C.longint;
    redmult*: C.longint;
    greenmax*: C.longint;
    greenmult*: C.longint;
    bluemax*: C.longint;
    bluemult*: C.longint;
    basepixel*: C.longint;
    visualid*: X.VisualID;        (* added by ICCCM version 1 *)
    killid*: X.XID;               (* added by ICCCM version 1 *)
  END;

CONST
  ReleaseByFreeingColormap* = 1;(* for killid field above *)
  
(*
 * return codes for XReadBitmapFile and XWriteBitmapFile
 *)
CONST
  BitmapSuccess* = 0;
  BitmapOpenFailed* = 1;
  BitmapFileInvalid* = 2;
  BitmapNoMemory* = 3;
  
  
(****************************************************************
 *
 * Context Management
 *
 ****************************************************************)
(* Associative lookup table return codes *)
CONST
  XCSUCCESS* = 0;               (* No error. *)
  XCNOMEM* = 1;                 (* Out of memory *)
  XCNOENT* = 2;                 (* No entry in table *)

TYPE
  XContext* = C.int;
  
  
(* The following declarations are alphabetized. *)
(*
PROCEDURE XAllocClassHint* (): XClassHintPtr;
PROCEDURE XAllocIconSize* (): XIconSizePtr;
PROCEDURE XAllocSizeHints* (): XSizeHintsPtr;
PROCEDURE XAllocStandardColormap* (): XStandardColormapPtr;
PROCEDURE XAllocWMHints* (): XWMHintsPtr;
PROCEDURE XClipBox* (
    r: Region;
    VAR rectreturn: X.XRectangle);
PROCEDURE XCreateRegion* (): Region;
PROCEDURE XDefaultString* (): C.charPtr1d;
PROCEDURE XDeleteContext* (
    display: X.DisplayPtr;
    rid: X.XID;
    context: XContext): C.int;
PROCEDURE XDestroyRegion* (
    r: Region);
PROCEDURE XEmptyRegion* (
    r: Region);
PROCEDURE XEqualRegion* (
    r1: Region;
    r2: Region);
PROCEDURE XFindContext* (
    display: X.DisplayPtr;
    rid: X.XID;
    context: XContext;
    VAR datareturn: X.XPointer): C.int;
PROCEDURE XGetClassHint* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR classhintsreturn: XClassHint): X.Status;
PROCEDURE XGetIconSizes* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR sizelistreturn: XIconSize;
    VAR countreturn: C.int): X.Status;
PROCEDURE XGetNormalHints* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR hintsreturn: XSizeHints): X.Status;
PROCEDURE XGetRGBColormaps* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR stdcmapreturn: XStandardColormap;
    VAR countreturn: C.int;
    property: X.Atom): X.Status;
PROCEDURE XGetSizeHints* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR hintsreturn: XSizeHints;
    property: X.Atom): X.Status;
PROCEDURE XGetStandardColormap* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR colormapreturn: XStandardColormap;
    property: X.Atom): X.Status;
PROCEDURE XGetTextProperty* (
    display: X.DisplayPtr;
    window: X.Window;
    VAR textpropreturn: XTextProperty;
    property: X.Atom): X.Status;
PROCEDURE XGetVisualInfo* (
    display: X.DisplayPtr;
    vinfomask: X.ulongmask;
    vinfotemplate: XVisualInfoPtr;
    VAR nitemsreturn: C.int): XVisualInfoPtr;
PROCEDURE XGetWMClientMachine* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR textpropreturn: XTextProperty): X.Status;
PROCEDURE XGetWMHints* (
    display: X.DisplayPtr;
    w: X.Window): XWMHintsPtr;
PROCEDURE XGetWMIconName* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR textpropreturn: XTextProperty): X.Status;
PROCEDURE XGetWMName* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR textpropreturn: XTextProperty): X.Status;
PROCEDURE XGetWMNormalHints* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR hintsreturn: XSizeHints;
    VAR suppliedreturn: C.longint): X.Status;
PROCEDURE XGetWMSizeHints* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR hintsreturn: XSizeHints;
    VAR suppliedreturn: C.longint;
    property: X.Atom): X.Status;
PROCEDURE XGetZoomHints* (
    display: X.DisplayPtr;
    w: X.Window;
    VAR zhintsreturn: XSizeHints): X.Status;
PROCEDURE XIntersectRegion* (
    sra, srb, drreturn: Region);  (* ??? *)
PROCEDURE XConvertCase* (
    sym: X.KeySym;
    VAR lower: X.KeySym;
    VAR upper: X.KeySym);
*)
PROCEDURE -XLookupString* (
    (*VAR eventStruct: X.XKeyEvent;*)
    VAR eventStruct: X.XEvent;
    VAR bufferReturn: ARRAY OF C.char;
    bytesBuffer: C.int;
    VAR keysymReturn: X.KeySym;
    (*VAR statusInOut(*[NILCOMPAT]*): XComposeStatus): C.int*)
    VAR statusInOut(*[NILCOMPAT]*): C.longint): C.int
    "(int)XLookupString((XKeyEvent*)eventStruct, bufferReturn, bytesBuffer, (KeySym*)keysymReturn, (XComposeStatus*)statusInOut)";
(*
PROCEDURE XMatchVisualInfo* (
    display: X.DisplayPtr;
    screen: C.int;
    depth: C.int;
    class: C.int;
    VAR vinforeturn: XVisualInfo): X.Status;
PROCEDURE XOffsetRegion* (
    r: Region;
    dx: C.int;
    dy: C.int);
PROCEDURE XPointInRegion* (
    r: Region;
    x: C.int;
    y: C.int): X.Bool;
PROCEDURE XPolygonRegion* (
    points: ARRAY OF X.XPoint;
    n: C.int;
    fillrule: C.int): Region;
PROCEDURE XRectInRegion* (
    r: Region;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int): C.int;
PROCEDURE XSaveContext* (
    display: X.DisplayPtr;
    rid: X.XID;
    context: XContext;
    data: ARRAY OF C.char): C.int;
PROCEDURE XSetClassHint* (
    display: X.DisplayPtr;
    w: X.Window;
    classhints: XClassHintPtr);
PROCEDURE XSetIconSizes* (
    display: X.DisplayPtr;
    w: X.Window;
    sizelist: XIconSizePtr;
    count: C.int);
PROCEDURE XSetNormalHints* (
    display: X.DisplayPtr;
    w: X.Window;
    hints: XSizeHintsPtr);
PROCEDURE XSetRGBColormaps* (
    display: X.DisplayPtr;
    w: X.Window;
    stdcmaps: XStandardColormapPtr;
    count: C.int;
    property: X.Atom);
PROCEDURE XSetSizeHints* (
    display: X.DisplayPtr;
    w: X.Window;
    hints: XSizeHintsPtr;
    property: X.Atom);
PROCEDURE XSetStandardProperties* (
    display: X.DisplayPtr;
    w: X.Window;
    windowname: ARRAY OF C.char;
    iconname: ARRAY OF C.char;
    iconpixmap: X.Pixmap;
    argv: C.charPtr2d;
    argc: C.int;
    hints: XSizeHintsPtr);
PROCEDURE XSetTextProperty* (
    display: X.DisplayPtr;
    w: X.Window;
    textprop: XTextPropertyPtr;
    property: X.Atom);
PROCEDURE XSetWMClientMachine* (
    display: X.DisplayPtr;
    w: X.Window;
    textprop: XTextPropertyPtr);
PROCEDURE XSetWMHints* (
    display: X.DisplayPtr;
    w: X.Window;
    wmhints: XWMHintsPtr);
PROCEDURE XSetWMIconName* (
    display: X.DisplayPtr;
    w: X.Window;
    textprop: XTextPropertyPtr);
PROCEDURE XSetWMName* (
    display: X.DisplayPtr;
    w: X.Window;
    textprop: XTextPropertyPtr);
PROCEDURE XSetWMNormalHints* (
    display: X.DisplayPtr;
    w: X.Window;
    hints: XSizeHintsPtr);
PROCEDURE XSetWMProperties* (
    display: X.DisplayPtr;
    w: X.Window;
    windowname: XTextPropertyPtr;
    iconname: XTextPropertyPtr;
    argv: C.charPtr2d;
    argc: C.int;
    normalhints: XSizeHintsPtr;
    wmhints: XWMHintsPtr;
    classhints: XClassHintPtr);
PROCEDURE XmbSetWMProperties* (
    display: X.DisplayPtr;
    w: X.Window;
    windowname: ARRAY OF C.char;
    iconname: ARRAY OF C.char;
    argv: C.charPtr2d;
    argc: C.int;
    normalhints: XSizeHintsPtr;
    wmhints: XWMHintsPtr;
    classhints: XClassHintPtr);
PROCEDURE XSetWMSizeHints* (
    display: X.DisplayPtr;
    w: X.Window;
    hints: XSizeHintsPtr;
    property: X.Atom);
PROCEDURE XSetRegion* (
    display: X.DisplayPtr;
    gc: X.GC;
    r: Region);
PROCEDURE XSetStandardColormap* (
    display: X.DisplayPtr;
    w: X.Window;
    colormap: XStandardColormapPtr;
    property: X.Atom);
PROCEDURE XSetZoomHints* (
    display: X.DisplayPtr;
    w: X.Window;
    zhints: XSizeHintsPtr);
PROCEDURE XShrinkRegion* (
    r: Region;
    dx: C.int;
    dy: C.int);
PROCEDURE XStringListToTextProperty* (
    list: C.charPtr2d;
    count: C.int;
    VAR textpropreturn: XTextProperty): X.Status;
PROCEDURE XSubtractRegion* (
    sra, srb, drreturn: Region);  (* ??? *)
PROCEDURE XmbTextListToTextProperty* (
    display: X.DisplayPtr;
    list: C.charPtr2d;
    count: C.int;
    style: XICCEncodingStyle;
    VAR textpropreturn: XTextProperty): C.int;
PROCEDURE XwcTextListToTextProperty* (
    display: X.DisplayPtr;
    list: ARRAY OF X.wchart;
    count: C.int;
    style: XICCEncodingStyle;
    VAR textpropreturn: XTextProperty): C.int;
PROCEDURE XwcFreeStringList* (
    list: X.wcharPtr2d);
PROCEDURE XTextPropertyToStringList* (
    textprop: XTextPropertyPtr;
    VAR listreturn: C.charPtr2d;
    VAR countreturn: C.int): X.Status;
PROCEDURE XTextPropertyToTextList* (
    display: X.DisplayPtr;
    textprop: XTextPropertyPtr;
    VAR listreturn: C.charPtr2d;
    VAR countreturn: C.int): X.Status;
PROCEDURE XwcTextPropertyToTextList* (
    display: X.DisplayPtr;
    textprop: XTextPropertyPtr;
    VAR listreturn: X.wcharPtr2d;
    VAR countreturn: C.int): X.Status;
PROCEDURE XUnionRectWithRegion* (
    rectangle: X.XRectanglePtr;
    srcregion: Region;
    destregionreturn: Region);  (* ??? *)
PROCEDURE XUnionRegion* (
    sra, srb, drreturn: Region);  (* ??? *)
PROCEDURE XWMGeometry* (
    display: X.DisplayPtr;
    screennumber: C.int;
    usergeometry: ARRAY OF C.char;
    defaultgeometry: ARRAY OF C.char;
    borderwidth: C.int;
    hints: XSizeHintsPtr;
    VAR xreturn: C.int;
    VAR yreturn: C.int;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int;
    VAR gravityreturn: C.int): C.int;
PROCEDURE XXorRegion* (
    sra, srb, drreturn: Region);  (* ??? *)
*)
END oocXutil.
