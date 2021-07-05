MODULE oocX11;(* [INTERFACE "C";
                 LINK LIB "X11" ADDOPTION LibX11Prefix, LibX11Suffix END];*)

IMPORT
  C := oocC, SYSTEM;

CONST
  XPROTOCOL* = 11;             (* current protocol version *)
  XPROTOCOLREVISION* = 0;     (* current minor version *)


TYPE
  ulongmask* = C.longset;
  (*uintmask* = C.set;*)
  uintmask* = C.int;

(* ### include file X.h, conversion of the file
       $XConsortium: X.h,v 1.69 94/04/17 20:10:48 dpw Exp $  *)

(* Resources *)
TYPE
  XID* = C.longint;
  Mask* = C.longint;
  Atom* = C.longint;
  AtomPtr1d* = POINTER TO ARRAY OF Atom;
  VisualID* = C.longint;
  Time* = C.longint;

  Window* = XID;
  WindowPtr1d* = POINTER TO ARRAY OF Window;
  Drawable* = XID;
  Font* = XID;
  Pixmap* = XID;
  Cursor* = XID;
  Colormap* = XID;
  ColormapPtr1d* = POINTER TO ARRAY OF Colormap;
  GContext* = XID;
  KeySym* = XID;
  KeySymPtr1d* = POINTER TO ARRAY OF KeySym;

  KeyCode* = C.char;
  KeyCodePtr1d* = POINTER TO ARRAY OF KeyCode;

(*****************************************************************
 * RESERVED RESOURCE AND CONSTANT DEFINITIONS
 *****************************************************************)
CONST
  None* = 0;                    (* universal null resource or null atom *)
  ParentRelative* = 1;          (* background pixmap in CreateWindow
                                   and ChangeWindowAttributes *)
  CopyFromParent* = 0;          (* border pixmap in CreateWindow
                                   and ChangeWindowAttributes
                                   special VisualID and special window
                                   class passed to CreateWindow *)
  PointerWindow* = 0;           (* destination window in SendEvent *)
  InputFocus* = 1;              (* destination window in SendEvent *)
  PointerRoot* = 1;             (* focus window in SetInputFocus *)
  AnyPropertyType* = 0;         (* special Atom, passed to GetProperty *)
  AnyKey* = 0;                  (* special Key Code, passed to GrabKey *)
  AnyButton* = 0;               (* special Button Code, passed to GrabButton *)
  AllTemporary* = 0;            (* special Resource ID passed to KillClient *)
  CurrentTime* = 0;             (* special Time *)
  NoSymbol* = 0;                (* special KeySym *)

(*****************************************************************
 * EVENT DEFINITIONS
 *****************************************************************)
(* Input Event Masks. Used as event-mask window attribute and as arguments
   to Grab requests.  Not to be confused with event names.  *)
CONST
  NoEventMask*              = {};
  KeyPressMask*             = {0};
  KeyReleaseMask*           = {1};
  ButtonPressMask*          = {2};
  ButtonReleaseMask*        = {3};
  EnterWindowMask*          = {4};
  LeaveWindowMask*          = {5};
  PointerMotionMask*        = {6};
  PointerMotionHintMask*    = {7};
  Button1MotionMask*        = {8};
  Button2MotionMask*        = {9};
  Button3MotionMask*        = {10};
  Button4MotionMask*        = {11};
  Button5MotionMask*        = {12};
  ButtonMotionMask*         = {13};
  KeymapStateMask*          = {14};
  ExposureMask*             = {15};
  VisibilityChangeMask*     = {16};
  StructureNotifyMask*      = {17};
  ResizeRedirectMask*       = {18};
  SubstructureNotifyMask*   = {19};
  SubstructureRedirectMask* = {20};
  FocusChangeMask*          = {21};
  PropertyChangeMask*       = {22};
  ColormapChangeMask*       = {23};
  OwnerGrabButtonMask*      = {24};

(* Event names.  Used in "type" field in XEvent structures.  Not to be
confused with event masks above.  They start from 2 because 0 and 1
are reserved in the protocol for errors and replies. *)
CONST
  KeyPress*         = 2;
  KeyRelease*       = 3;
  ButtonPress*      = 4;
  ButtonRelease*    = 5;
  MotionNotify*     = 6;
  EnterNotify*      = 7;
  LeaveNotify*      = 8;
  FocusIn*          = 9;
  FocusOut*         = 10;
  KeymapNotify*     = 11;
  Expose*           = 12;
  GraphicsExpose*   = 13;
  NoExpose*         = 14;
  VisibilityNotify* = 15;
  CreateNotify*     = 16;
  DestroyNotify*    = 17;
  UnmapNotify*      = 18;
  MapNotify*        = 19;
  MapRequest*       = 20;
  ReparentNotify*   = 21;
  ConfigureNotify*  = 22;
  ConfigureRequest* = 23;
  GravityNotify*    = 24;
  ResizeRequest*    = 25;
  CirculateNotify*  = 26;
  CirculateRequest* = 27;
  PropertyNotify*   = 28;
  SelectionClear*   = 29;
  SelectionRequest* = 30;
  SelectionNotify*  = 31;
  ColormapNotify*   = 32;
  ClientMessage*    = 33;
  MappingNotify*    = 34;
  LASTEvent*        = 35;              (* must be bigger than any event # *)

(* Key masks. Used as modifiers to GrabButton and GrabKey, results of
   QueryPointer, state in various key-, mouse-, and button-related events. *)
CONST
  ShiftMask*   = {0};
  LockMask*    = {1};
  ControlMask* = {2};
  Mod1Mask*    = {3};
  Mod2Mask*    = {4};
  Mod3Mask*    = {5};
  Mod4Mask*    = {6};
  Mod5Mask*    = {7};

(* modifier names.  Used to build a SetModifierMapping request or
   to read a GetModifierMapping request.  These correspond to the
   masks defined above. *)
CONST
  ShiftMapIndex*   = 0;
  LockMapIndex*    = 1;
  ControlMapIndex* = 2;
  Mod1MapIndex*    = 3;
  Mod2MapIndex*    = 4;
  Mod3MapIndex*    = 5;
  Mod4MapIndex*    = 6;
  Mod5MapIndex*    = 7;

(* button masks.  Used in same manner as Key masks above. Not to be confused
   with button names below. *)
CONST
  Button1Mask* = {8};
  Button2Mask* = {9};
  Button3Mask* = {10};
  Button4Mask* = {11};
  Button5Mask* = {12};
  AnyModifier* = {15};          (* used in GrabButton, GrabKey *)

(* button names. Used as arguments to GrabButton and as detail in ButtonPress
   and ButtonRelease events.  Not to be confused with button masks above.
   Note that 0 is already defined above as "AnyButton".  *)
CONST
  Button1* = 1;
  Button2* = 2;
  Button3* = 3;
  Button4* = 4;
  Button5* = 5;

(* Notify modes *)
CONST
  NotifyNormal* = 0;
  NotifyGrab* = 1;
  NotifyUngrab* = 2;
  NotifyWhileGrabbed* = 3;
  NotifyHint* = 1;              (* for MotionNotify events *)

(* Notify detail *)
CONST
  NotifyAncestor* = 0;
  NotifyVirtual* = 1;
  NotifyInferior* = 2;
  NotifyNonlinear* = 3;
  NotifyNonlinearVirtual* = 4;
  NotifyPointer* = 5;
  NotifyPointerRoot* = 6;
  NotifyDetailNone* = 7;

(* Visibility notify *)
CONST
  VisibilityUnobscured* = 0;
  VisibilityPartiallyObscured* = 1;
  VisibilityFullyObscured* = 2;

(* Circulation request *)
CONST
  PlaceOnTop* = 0;
  PlaceOnBottom* = 1;

(* protocol families *)
CONST
  FamilyInternet* = 0;
  FamilyDECnet* = 1;
  FamilyChaos* = 2;

(* Property notification *)
CONST
  PropertyNewValue* = 0;
  PropertyDelete* = 1;

(* Color Map notification *)
CONST
  ColormapUninstalled* = 0;
  ColormapInstalled* = 1;

(* GrabPointer, GrabButton, GrabKeyboard, GrabKey Modes *)
CONST
  GrabModeSync* = 0;
  GrabModeAsync* = 1;

(* GrabPointer, GrabKeyboard reply status *)
CONST
  GrabSuccess* = 0;
  AlreadyGrabbed* = 1;
  GrabInvalidTime* = 2;
  GrabNotViewable* = 3;
  GrabFrozen* = 4;

(* AllowEvents modes *)
CONST
  AsyncPointer* = 0;
  SyncPointer* = 1;
  ReplayPointer* = 2;
  AsyncKeyboard* = 3;
  SyncKeyboard* = 4;
  ReplayKeyboard* = 5;
  AsyncBoth* = 6;
  SyncBoth* = 7;

(* Used in SetInputFocus, GetInputFocus *)
CONST
  RevertToNone* = None;
  RevertToPointerRoot* = PointerRoot;
  RevertToParent* = 2;


(*****************************************************************
 * ERROR CODES
 *****************************************************************)
CONST
  Success* = 0;                 (* everything's okay *)
  BadRequest* = 1;              (* bad request code *)
  BadValue* = 2;                (* int parameter out of range *)
  BadWindow* = 3;               (* parameter not a Window *)
  BadPixmap* = 4;               (* parameter not a Pixmap *)
  BadAtom* = 5;                 (* parameter not an Atom *)
  BadCursor* = 6;               (* parameter not a Cursor *)
  BadFont* = 7;                 (* parameter not a Font *)
  BadMatch* = 8;                (* parameter mismatch *)
  BadDrawable* = 9;             (* parameter not a Pixmap or Window *)
  BadAccess* = 10;              (* depending on context:
                                 - key/button already grabbed
                                 - attempt to free an illegal
                                   cmap entry
                                - attempt to store into a read-only
                                   color map entry.
                                - attempt to modify the access control
                                   list from other than the local host.
                                *)
  BadAlloc* = 11;               (* insufficient resources *)
  BadColor* = 12;               (* no such colormap *)
  BadGC* = 13;                  (* parameter not a GC *)
  BadIDChoice* = 14;            (* choice not in range or already used *)
  BadName* = 15;                (* font or color name doesn't exist *)
  BadLength* = 16;              (* Request length incorrect *)
  BadImplementation* = 17;      (* server is defective *)
  FirstExtensionError* = 128;
  LastExtensionError* = 255;


(*****************************************************************
 * WINDOW DEFINITIONS
 *****************************************************************)
(* Window classes used by CreateWindow *)
(* Note that CopyFromParent is already defined as 0 above *)
CONST
  InputOutput* = 1;
  InputOnly* = 2;

(* Window attributes for CreateWindow and ChangeWindowAttributes *)
CONST
  CWBackPixmap* = {0};
  CWBackPixel* = {1};
  CWBorderPixmap* = {2};
  CWBorderPixel* = {3};
  CWBitGravity* = {4};
  CWWinGravity* = {5};
  CWBackingStore* = {6};
  CWBackingPlanes* = {7};
  CWBackingPixel* = {8};
  CWOverrideRedirect* = {9};
  CWSaveUnder* = {10};
  CWEventMask* = {11};
  CWDontPropagate* = {12};
  CWColormap* = {13};
  CWCursor* = {14};

(* ConfigureWindow structure *)
CONST
  CWX* = {0};
  CWY* = {1};
  CWWidth* = {2};
  CWHeight* = {3};
  CWBorderWidth* = {4};
  CWSibling* = {5};
  CWStackMode* = {6};

(* Bit Gravity *)
CONST
  ForgetGravity* = 0;
  NorthWestGravity* = 1;
  NorthGravity* = 2;
  NorthEastGravity* = 3;
  WestGravity* = 4;
  CenterGravity* = 5;
  EastGravity* = 6;
  SouthWestGravity* = 7;
  SouthGravity* = 8;
  SouthEastGravity* = 9;
  StaticGravity* = 10;
  (* Window gravity + bit gravity above *)
  UnmapGravity* = 0;

(* Used in CreateWindow for backing-store hint *)
CONST
  NotUseful* = 0;
  WhenMapped* = 1;
  Always* = 2;

(* Used in GetWindowAttributes reply *)
CONST
  IsUnmapped* = 0;
  IsUnviewable* = 1;
  IsViewable* = 2;

(* Used in ChangeSaveSet *)
CONST
  SetModeInsert* = 0;
  SetModeDelete* = 1;

(* Used in ChangeCloseDownMode *)
CONST
  DestroyAll* = 0;
  RetainPermanent* = 1;
  RetainTemporary* = 2;

(* Window stacking method (in configureWindow) *)
CONST
  Above* = 0;
  Below* = 1;
  TopIf* = 2;
  BottomIf* = 3;
  Opposite* = 4;

(* Circulation direction *)
CONST
  RaiseLowest* = 0;
  LowerHighest* = 1;

(* Property modes *)
CONST
  PropModeReplace* = 0;
  PropModePrepend* = 1;
  PropModeAppend* = 2;


(*****************************************************************
 * GRAPHICS DEFINITIONS
 *****************************************************************)

(* graphics functions, as in GC.alu *)
CONST
  GXclear* = 00H;               (* 0 *)
  GXand* = 01H;                 (* src AND dst *)
  GXandReverse* = 02H;          (* src AND NOT dst *)
  GXcopy* = 03H;                (* src *)
  GXandInverted* = 04H;         (* NOT src AND dst *)
  GXnoop* = 05H;                (* dst *)
  GXxor* = 06H;                 (* src XOR dst *)
  GXor* = 07H;                  (* src OR dst *)
  GXnor* = 08H;                 (* NOT src AND NOT dst *)
  GXequiv* = 09H;               (* NOT src XOR dst *)
  GXinvert* = 0AH;              (* NOT dst *)
  GXorReverse* = 0BH;           (* src OR NOT dst *)
  GXcopyInverted* = 0CH;        (* NOT src *)
  GXorInverted* = 0DH;          (* NOT src OR dst *)
  GXnand* = 0EH;                (* NOT src OR NOT dst *)
  GXset* = 0FH;                 (* 1 *)

(* LineStyle *)
CONST
  LineSolid* = 0;
  LineOnOffDash* = 1;
  LineDoubleDash* = 2;

(* capStyle *)
CONST
  CapNotLast* = 0;
  CapButt* = 1;
  CapRound* = 2;
  CapProjecting* = 3;

(* joinStyle *)
CONST
  JoinMiter* = 0;
  JoinRound* = 1;
  JoinBevel* = 2;

(* fillStyle *)
CONST
  FillSolid* = 0;
  FillTiled* = 1;
  FillStippled* = 2;
  FillOpaqueStippled* = 3;

(* fillRule *)
CONST
  EvenOddRule* = 0;
  WindingRule* = 1;

(* subwindow mode *)
CONST
  ClipByChildren* = 0;
  IncludeInferiors* = 1;

(* SetClipRectangles ordering *)
CONST
  Unsorted* = 0;
  YSorted* = 1;
  YXSorted* = 2;
  YXBanded* = 3;

(* CoordinateMode for drawing routines *)
CONST
  CoordModeOrigin* = 0;         (* relative to the origin *)
  CoordModePrevious* = 1;       (* relative to previous point *)

(* Polygon shapes *)
CONST
  Complex* = 0;                 (* paths may intersect *)
  Nonconvex* = 1;               (* no paths intersect, but not convex *)
  Convex* = 2;                  (* wholly convex *)

(* Arc modes for PolyFillArc *)
CONST
  ArcChord* = 0;                (* join endpoints of arc *)
  ArcPieSlice* = 1;             (* join endpoints to center of arc *)


(* GC components: masks used in CreateGC, CopyGC, ChangeGC, OR'ed into
   GC.stateChanges *)
CONST
  GCFunction* = {0};
  GCPlaneMask* = {1};
  GCForeground* = {2};
  GCBackground* = {3};
  GCLineWidth* = {4};
  GCLineStyle* = {5};
  GCCapStyle* = {6};
  GCJoinStyle* = {7};
  GCFillStyle* = {8};
  GCFillRule* = {9};
  GCTile* = {10};
  GCStipple* = {11};
  GCTileStipXOrigin* = {12};
  GCTileStipYOrigin* = {13};
  GCFont* = {14};
  GCSubwindowMode* = {15};
  GCGraphicsExposures* = {16};
  GCClipXOrigin* = {17};
  GCClipYOrigin* = {18};
  GCClipMask* = {19};
  GCDashOffset* = {20};
  GCDashList* = {21};
  GCArcMode* = {22};
  GCLastBit* = 22;


(*****************************************************************
 * FONTS
 *****************************************************************)

(* used in QueryFont -- draw direction *)
CONST
  FontLeftToRight* = 0;
  FontRightToLeft* = 1;
  FontChange* = 255;


(*****************************************************************
 *  IMAGING
 *****************************************************************)

(* ImageFormat -- PutImage, GetImage *)
CONST
  XYBitmap* = 0;                (* depth 1, XYFormat *)
  XYPixmap* = 1;                (* depth == drawable depth *)
  ZPixmap* = 2;                 (* depth == drawable depth *)


(*****************************************************************
 *  COLOR MAP STUFF
 *****************************************************************)

(* For CreateColormap *)
CONST
  AllocNone* = 0;               (* create map with no entries *)
  AllocAll* = 1;                (* allocate entire map writeable *)

(* Flags used in StoreNamedColor, StoreColors *)
CONST
  DoRed* = {0};
  DoGreen* = {1};
  DoBlue* = {2};


(*****************************************************************
 * CURSOR STUFF
 *****************************************************************)

(* QueryBestSize Class *)
CONST
  CursorShape* = 0;             (* largest size that can be displayed *)
  TileShape* = 1;               (* size tiled fastest *)
  StippleShape* = 2;            (* size stippled fastest *)


(*****************************************************************
 * KEYBOARD/POINTER STUFF
 *****************************************************************)
CONST
  AutoRepeatModeOff* = 0;
  AutoRepeatModeOn* = 1;
  AutoRepeatModeDefault* = 2;
  LedModeOff* = 0;
  LedModeOn* = 1;

(* masks for ChangeKeyboardControl *)
CONST
  KBKeyClickPercent* = {0};
  KBBellPercent* = {1};
  KBBellPitch* = {2};
  KBBellDuration* = {3};
  KBLed* = {4};
  KBLedMode* = {5};
  KBKey* = {6};
  KBAutoRepeatMode* = {7};
  MappingSuccess* = 0;
  MappingBusy* = 1;
  MappingFailed* = 2;
  MappingModifier* = 0;
  MappingKeyboard* = 1;
  MappingPointer* = 2;


(*****************************************************************
 * SCREEN SAVER STUFF
 *****************************************************************)
CONST
  DontPreferBlanking* = 0;
  PreferBlanking* = 1;
  DefaultBlanking* = 2;
  DisableScreenSaver* = 0;
  DisableScreenInterval* = 0;
  DontAllowExposures* = 0;
  AllowExposures* = 1;
  DefaultExposures* = 2;

(* for ForceScreenSaver *)
CONST
  ScreenSaverReset* = 0;
  ScreenSaverActive* = 1;


(*****************************************************************
 * HOSTS AND CONNECTIONS
 *****************************************************************)

(* for ChangeHosts *)
CONST
  HostInsert* = 0;
  HostDelete* = 1;

(* for ChangeAccessControl *)
CONST
  EnableAccess* = 1;
  DisableAccess* = 0;

(* Display classes  used in opening the connection
 * Note that the statically allocated ones are even numbered and the
 * dynamically changeable ones are odd numbered *)
CONST
  StaticGray* = 0;
  GrayScale* = 1;
  StaticColor* = 2;
  PseudoColor* = 3;
  TrueColor* = 4;
  DirectColor* = 5;

(* Byte order  used in imageByteOrder and bitmapBitOrder *)
CONST
  LSBFirst* = 0;
  MSBFirst* = 1;



(* ### include file Xlib.h, conversion of the file
       $XConsortium: Xlib.h,v 11.237 94/09/01 18:44:49 kaleb Exp $
       $XFree86: xc/lib/X11/Xlib.h,v 3.2 1994/09/17 13:44:15 dawes Exp $ *)

(*
 *      Xlib.h - Header definition and support file for the C subroutine
 *      interface library (Xlib) to the X Window System Protocol (V11).
 *      Structures and symbols starting with "" are private to the library.
 *)

CONST
  XlibSpecificationRelease* = 6;

(* replace this with #include or typedef appropriate for your system *)
TYPE
  wchart* = C.longint;

TYPE
  XPointer* = C.address;
  XPointerPtr1d* = POINTER TO ARRAY OF XPointer;
  Bool* = C.int;
  Status* = C.int;

CONST
  True* = 1;
  False* = 0;

CONST
  QueuedAlready* = 0;
  QueuedAfterReading* = 1;
  QueuedAfterFlush* = 2;

(*
 * Extensions need a way to hang private data on some structures.
 *)
TYPE
  XExtDataPtr* = POINTER TO XExtData;
  XExtData* = RECORD
    number*: C.int;             (* number returned by XRegisterExtension *)
    next*: XExtDataPtr;         (* next item on list of data for structure *)
    freePrivate*: PROCEDURE (): C.int;  (* called to free private storage *)
    privateData*: XPointer;    (* data private to this extension. *)
  END;
  XExtDataPtr1d* = POINTER TO ARRAY OF XExtDataPtr;

(*
 * This file contains structures used by the extension mechanism.
 *)
TYPE
  XExtCodesPtr* = POINTER TO XExtCodes;
  XExtCodes* = RECORD
    extension*: C.int;          (* extension number *)
    majorOpcode*: C.int;       (* major op-code assigned by server *)
    firstEvent*: C.int;        (* first event number for the extension *)
    firstError*: C.int;        (* first error number for the extension *)
  END;

(*
 * Data structure for retrieving info about pixmap formats.
 *)
TYPE
  XPixmapFormatValuesPtr* = POINTER TO XPixmapFormatValues;
  XPixmapFormatValues* = RECORD
    depth*: C.int;
    bitsPerPixel*: C.int;
    scanlinePad*: C.int;
  END;

(*
 * Data structure for setting graphics context.
 *)
TYPE
  XGCValuesPtr* = POINTER TO XGCValues;
  XGCValues* = RECORD
    function*: C.int;           (* logical operation *)
    planemask*: ulongmask;     (* plane mask *)
    foreground*: C.longint;     (* foreground pixel *)
    background*: C.longint;     (* background pixel *)
    linewidth*: C.int;         (* line width *)
    linestyle*: C.int;         (* LineSolid, LineOnOffDash, LineDoubleDash *)
    capstyle*: C.int;          (* CapNotLast, CapButt,
                                   CapRound, CapProjecting *)
    joinstyle*: C.int;         (* JoinMiter, JoinRound, JoinBevel *)
    fillstyle*: C.int;         (* FillSolid, FillTiled,
                                   FillStippled, FillOpaeueStippled *)
    fillrule*: C.int;          (* EvenOddRule, WindingRule *)
    arcmode*: C.int;           (* ArcChord, ArcPieSlice *)
    tile*: Pixmap;              (* tile pixmap for tiling operations *)
    stipple*: Pixmap;           (* stipple 1 plane pixmap for stipping *)
    tsxorigin*: C.int;        (* offset for tile or stipple operations *)
    tsyorigin*: C.int;
    font*: Font;                (* default text font for text operations *)
    subwindowmode*: C.int;     (* ClipByChildren, IncludeInferiors *)
    graphicsexposures*: Bool;  (* boolean, should exposures be generated *)
    clipxorigin*: C.int;      (* origin for clipping *)
    clipyorigin*: C.int;
    clipmask*: Pixmap;         (* bitmap clipping; other calls for rects *)
    dashoffset*: C.int;        (* patterned/dashed line information *)
    dashes*: C.char;
  END;

(*
 * Graphics context.  The contents of this structure are implementation
 * dependent.  A GC should be treated as opaque by application code.
 *)
TYPE
  GC* = POINTER TO RECORD
    extdata*: XExtDataPtr;     (* hook for extension to hang data *)
    gid*: GContext;             (* protocol ID for graphics context *)
    (* there is more to this structure, but it is private to Xlib *)
  END;

(*
 * Visual structure; contains information about colormapping possible.
 *)
TYPE
  VisualPtr* = POINTER TO Visual;
  Visual* = RECORD
    extdata*: XExtDataPtr;     (* hook for extension to hang data *)
    visualid*: VisualID;        (* visual id of this visual *)
    class*: C.int;              (* class of screen (monochrome, etc.) *)
    redmask*, greenmask*, bluemask*: ulongmask;  (* mask values *)
    bitsperrgb*: C.int;       (* log base 2 of distinct color values *)
    mapentries*: C.int;        (* color map entries *)
  END;

(*
 * Depth structure; contains information for each possible depth.
 *)
TYPE
  DepthPtr* = POINTER TO Depth;
  Depth* = RECORD
    depth*: C.int;              (* this depth (Z) of the depth *)
    nvisuals*: C.int;           (* number of Visual types at this depth *)
    visuals*: VisualPtr;        (* list of visuals possible at this depth *)
  END;

(*
 * Information about the screen.  The contents of this structure are
 * implementation dependent.  A Screen should be treated as opaque
 * by application code.
 *)
TYPE
  DisplayPtr* = POINTER TO Display;
  ScreenPtr* = POINTER TO Screen;
  Screen* = RECORD
    extdata*: XExtDataPtr;     (* hook for extension to hang data *)
    display*: DisplayPtr;       (* back pointer to display structure *)
    root*: Window;              (* Root window id. *)
    width*, height*: C.int;     (* width and height of screen *)
    mwidth*, mheight*: C.int;   (* width and height of  in millimeters *)
    ndepths*: C.int;            (* number of depths possible *)
    depths*: DepthPtr;          (* list of allowable depths on the screen *)
    rootdepth*: C.int;         (* bits per pixel *)
    rootvisual*: VisualPtr;    (* root visual *)
    defaultgc*: GC;            (* GC for the root root visual *)
    cmap*: Colormap;            (* default color map *)
    whitepixel*: C.longint;
    blackpixel*: C.longint;    (* White and Black pixel values *)
    maxmaps*, minmaps*: C.int; (* max and min color maps *)
    backingstore*: C.int;      (* Never, WhenMapped, Always *)
    saveunders*: Bool;
    rootinputmask*: ulongmask;(* initial root input mask *)
  END;

(*
 * Format structure; describes ZFormat data the screen will understand.
 *)
TYPE
  ScreenFormatPtr* = POINTER TO ScreenFormat;
  ScreenFormat* = RECORD
    extdata*: XExtDataPtr;     (* hook for extension to hang data *)
    depth*: C.int;              (* depth of this image format *)
    bitsPerPixel*: C.int;     (* bits/pixel at this depth *)
    scanlinePad*: C.int;       (* scanline must padded to this multiple *)
  END;

(*
 * Data structure for setting window attributes.
 *)
TYPE
  XSetWindowAttributesPtr* = POINTER TO XSetWindowAttributes;
  XSetWindowAttributes* = RECORD
    backgroundpixmap*: Pixmap; (* background or None or ParentRelative *)
    backgroundpixel*: C.longint;(* background pixel *)
    borderpixmap*: Pixmap;     (* border of the window *)
    borderpixel*: C.longint;   (* border pixel value *)
    bitgravity*: C.int;        (* one of bit gravity values *)
    wingravity*: C.int;        (* one of the window gravity values *)
    backingstore*: C.int;      (* NotUseful, WhenMapped, Always *)
    backingplanes*: C.longint; (* planes to be preseved if possible *)
    backingpixel*: C.longint;  (* value to use in restoring planes *)
    saveunder*: Bool;          (* should bits under be saved? (popups) *)
    eventmask*: ulongmask;     (* set of events that should be saved *)
    donotpropagatemask*: ulongmask;(* set of events that should not propagate *)
    overrideredirect*: Bool;   (* boolean value for override-redirect *)
    colormap*: Colormap;        (* color map to be associated with window *)
    cursor*: Cursor;            (* cursor to be displayed (or None) *)
  END;

  XWindowAttributesPtr* = POINTER TO XWindowAttributes;
  XWindowAttributes* = RECORD
    x*, y*: C.int;              (* location of window *)
    width*, height*: C.int;     (* width and height of window *)
    borderwidth*: C.int;       (* border width of window *)
    depth*: C.int;              (* depth of window *)
    visual*: VisualPtr;         (* the associated visual structure *)
    root*: Window;              (* root of screen containing window *)
    class*: C.int;              (* InputOutput, InputOnly*)
    bitgravity*: C.int;        (* one of bit gravity values *)
    wingravity*: C.int;        (* one of the window gravity values *)
    backingstore*: C.int;      (* NotUseful, WhenMapped, Always *)
    backingplanes*: C.longint; (* planes to be preserved if possible *)
    backingpixel*: C.longint;  (* value to be used when restoring planes *)
    saveunder*: Bool;          (* boolean, should bits under be saved? *)
    colormap*: Colormap;        (* color map to be associated with window *)
    mapinstalled*: Bool;       (* boolean, is color map currently installed*)
    mapstate*: C.int;          (* IsUnmapped, IsUnviewable, IsViewable *)
    alleventmasks*: ulongmask;(* set of events all people have interest in*)
    youreventmask*: ulongmask;(* my event mask *)
    donotpropagatemask*: ulongmask;(* set of events that should not propagate *)
    overrideredirect*: Bool;   (* boolean value for override-redirect *)
    screen*: ScreenPtr;         (* back pointer to correct screen *)
  END;

(*
 * Data structure for host setting; getting routines.
 *
 *)
TYPE
  XHostAddressPtr* = POINTER TO XHostAddress;
  XHostAddress* = RECORD
    family*: C.int;             (* for example FamilyInternet *)
    length*: C.int;             (* length of address, in bytes *)
    address*: C.charPtr1d;      (* pointer to where to find the bytes *)
  END;
  XHostAddressPtr1d* = POINTER TO ARRAY OF XHostAddress;

(*
 * Data structure for "image" data, used by image manipulation routines.
 *)
  XImagePtr* = POINTER TO XImage;
  XImage* = RECORD
    width*, height*: C.int;     (* size of image *)
    xoffset*: C.int;            (* number of pixels offset in X direction *)
    format*: C.int;             (* XYBitmap, XYPixmap, ZPixmap *)
    data*: C.charPtr1d;         (* pointer to image data *)
    byteorder*: C.int;         (* data byte order, LSBFirst, MSBFirst *)
    bitmapunit*: C.int;        (* quant. of scanline 8, 16, 32 *)
    bitmapbitorder*: C.int;   (* LSBFirst, MSBFirst *)
    bitmappad*: C.int;         (* 8, 16, 32 either XY or ZPixmap *)
    depth*: C.int;              (* depth of image *)
    bytesperline*: C.int;     (* accelarator to next line *)
    bitsPerPixel*: C.int;     (* bits per pixel (ZPixmap) *)
    redmask*: ulongmask;       (* bits in z arrangment *)
    greenmask*: ulongmask;
    bluemask*: ulongmask;
    obdata*: XPointer;          (* hook for the object routines to hang on *)
    f*: RECORD                  (* image manipulation routines *)
      createimage*: PROCEDURE (): XImagePtr;
      destroyimage*: PROCEDURE (a: XImagePtr): C.int;
      getpixel*: PROCEDURE (a: XImagePtr; b, c: C.int): C.longint;
      putpixel*: PROCEDURE (a: XImagePtr; b, c: C.int; d: C.longint): C.int;
      subimage*: PROCEDURE (a: XImagePtr; b, c: C.int; d, e: C.longint): XImagePtr;
      addpixel*: PROCEDURE (a: XImagePtr; b: C.longint): C.int;
    END
  END;

(*
 * Data structure for XReconfigureWindow
 *)
TYPE
  XWindowChangesPtr* = POINTER TO XWindowChanges;
  XWindowChanges* = RECORD
    x*, y*: C.int;
    width*, height*: C.int;
    borderwidth*: C.int;
    sibling*: Window;
    stackmode*: C.int;
  END;

(*
 * Data structure used by color operations
 *)
TYPE
  XColorPtr* = POINTER TO XColor;
  XColor* = RECORD
    pixel*: C.longint;
    red*, green*, blue*: C.shortint;
    flags*: C.char;       (* dored, dogreen, doblue *)
    pad*: C.char;
  END;

(*
 * Data structures for graphics operations.  On most machines, these are
 * congruent with the wire protocol structures, so reformatting the data
 * can be avoided on these architectures.
 *)
TYPE
  XSegmentPtr* = POINTER TO XSegment;
  XSegment* = RECORD
    x1*, y1*, x2*, y2*: C.shortint;
  END;
  XPointPtr* = POINTER TO XPoint;
  XPoint* = RECORD
    x*, y*: C.shortint;
  END;
  XRectanglePtr* = POINTER TO XRectangle;
  XRectangle* = RECORD
    x*, y*: C.shortint;
    width*, height*: C.shortint;
  END;
  XArcPtr* = POINTER TO XArc;
  XArc* = RECORD
    x*, y*: C.shortint;
    width*, height*: C.shortint;
    angle1*, angle2*: C.shortint;
  END;

(* Data structure for XChangeKeyboardControl *)
TYPE
  XKeyboardControlPtr* = POINTER TO XKeyboardControl;
  XKeyboardControl* = RECORD
    keyclickpercent*: C.int;
    bellpercent*: C.int;
    bellpitch*: C.int;
    bellduration*: C.int;
    led*: C.int;
    ledmode*: C.int;
    key*: C.int;
    autorepeatmode*: C.int;   (* On, Off, Default *)
  END;

(* Data structure for XGetKeyboardControl *)
TYPE
  XKeyboardStatePtr* = POINTER TO XKeyboardState;
  XKeyboardState* = RECORD
    keyclickpercent*: C.int;
    bellpercent*: C.int;
    bellpitch*, bellduration*: C.int;
    ledmask*: ulongmask;
    globalautorepeat*: C.int;
    autorepeats*: ARRAY 32 OF C.char;
  END;

(* Data structure for XGetMotionEvents.  *)
TYPE
  XTimeCoordPtr* = POINTER TO XTimeCoord;
  XTimeCoord* = RECORD
    time*: Time;
    x*, y*: C.shortint;
  END;

(* Data structure for X{Set,Get}ModifierMapping *)
TYPE
  XModifierKeymapPtr* = POINTER TO XModifierKeymap;
  XModifierKeymap* = RECORD
    maxkeypermod*: C.int;      (* The server's max # of keys per modifier *)
    modifiermap*: KeyCodePtr1d; (* An 8 by maxkeypermod array of modifiers *)
  END;

(*
 * Display datatype maintaining display specific data.
 * The contents of this structure are implementation dependent.
 * A Display should be treated as opaque by application code.
 *)
TYPE
  XPrivatePtr* = C.address;
  XrmHashBucketRecPtr* = C.address;

TYPE
  Display* = RECORD
    extdata*: XExtDataPtr;     (* hook for extension to hang data *)
    private1*: XPrivatePtr;
    fd*: C.int;                 (* Network socket. *)
    private2*: C.int;
    protomajorversion*: C.int;(* major version of server's X protocol *)
    protominorversion*: C.int;(* minor version of servers X protocol *)
    vendor*: C.charPtr1d;       (* vendor of the server hardware *)
    private3*: XID;
    private4*: XID;
    private5*: XID;
    private6*: C.int;
    resourcealloc*: PROCEDURE (): XID;  (* allocator function *)
    byteorder*: C.int;         (* screen byte order, LSBFirst, MSBFirst *)
    bitmapunit*: C.int;        (* padding and data requirements *)
    bitmappad*: C.int;         (* padding requirements on bitmaps *)
    bitmapbitorder*: C.int;   (* LeastSignificant or MostSignificant *)
    nformats*: C.int;           (* number of pixmap formats in list *)
    pixmapformat*: ScreenFormatPtr;(* pixmap format list *)
    private8*: C.int;
    release*: C.int;            (* release of the server *)
    private9*: XPrivatePtr;
    private10*: XPrivatePtr;
    qlen*: C.int;               (* Length of input event queue *)
    lastrequestread*: C.longint;(* seq number of last event read *)
    request*: C.longint;        (* sequence number of last request. *)
    private11*: XPointer;
    private12*: XPointer;
    private13*: XPointer;
    private14*: XPointer;
    maxrequestsize*: C.int;   (* maximum number 32 bit words in request*)
    db*: XrmHashBucketRecPtr;
    private15*: PROCEDURE (): C.int;
    displayname*: C.charPtr1d; (* "host:display" string used on this connect*)
    defaultscreen*: C.int;     (* default screen for operations *)
    nscreens*: C.int;           (* number of screens on this server*)
    screens*: ScreenPtr;        (* pointer to list of screens *)
    motionbuffer*: C.longint;  (* size of motion buffer *)
    private16*: C.longint;
    minkeycode*: C.int;        (* minimum defined keycode *)
    maxkeycode*: C.int;        (* maximum defined keycode *)
    private17*: XPointer;
    private18*: XPointer;
    private19*: C.int;
    xdefaults*: C.charPtr1d;    (* contents of defaults from server *)
  END;


(*
 * Definitions of specific events.
 *)
TYPE
  XKeyEventPtr* = POINTER TO XKeyEvent;
  XKeyEvent* = RECORD
    type*: C.int;               (* of event *)
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;            (* "event" window it is reported relative to *)
    root*: Window;              (* root window that the event occured on *)
    subwindow*: Window;         (* child window *)
    time*: Time;                (* milliseconds *)
    x*, y*: C.int;              (* pointer x, y coordinates in event window *)
    xroot*, yroot*: C.int;    (* coordinates relative to root *)
    state*: uintmask;           (* key or button mask *)
    keycode*: C.int;            (* detail *)
    samescreen*: Bool;         (* same screen flag *)
  END;
  XKeyPressedEvent* = XKeyEvent;
  XKeyReleasedEvent* = XKeyEvent;

  XButtonEventPtr* = POINTER TO XButtonEvent;
  XButtonEvent* = RECORD
    type*: C.int;               (* of event *)
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;            (* "event" window it is reported relative to *)
    root*: Window;              (* root window that the event occured on *)
    subwindow*: Window;         (* child window *)
    time*: Time;                (* milliseconds *)
    x*, y*: C.int;              (* pointer x, y coordinates in event window *)
    xroot*, yroot*: C.int;    (* coordinates relative to root *)
    state*: uintmask;           (* key or button mask *)
    button*: C.int;             (* detail *)
    samescreen*: Bool;         (* same screen flag *)
  END;
  XButtonPressedEvent* = XButtonEvent;
  XButtonReleasedEvent* = XButtonEvent;

  XMotionEventPtr* = POINTER TO XMotionEvent;
  XMotionEvent* = RECORD
    type*: C.int;               (* of event *)
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;            (* "event" window reported relative to *)
    root*: Window;              (* root window that the event occured on *)
    subwindow*: Window;         (* child window *)
    time*: Time;                (* milliseconds *)
    x*, y*: C.int;              (* pointer x, y coordinates in event window *)
    xroot*, yroot*: C.int;    (* coordinates relative to root *)
    state*: uintmask;           (* key or button mask *)
    ishint*: C.char;           (* detail *)
    samescreen*: Bool;         (* same screen flag *)
  END;
  XPointerMovedEvent* = XMotionEvent;

  XCrossingEventPtr* = POINTER TO XCrossingEvent;
  XCrossingEvent* = RECORD
    type*: C.int;               (* of event *)
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;            (* "event" window reported relative to *)
    root*: Window;              (* root window that the event occured on *)
    subwindow*: Window;         (* child window *)
    time*: Time;                (* milliseconds *)
    x*, y*: C.int;              (* pointer x, y coordinates in event window *)
    xroot*, yroot*: C.int;    (* coordinates relative to root *)
    mode*: C.int;               (* NotifyNormal, NotifyGrab, NotifyUngrab *)
    detail*: C.int;             (*
         * NotifyAncestor, NotifyVirtual, NotifyInferior,
         * NotifyNonlinear,NotifyNonlinearVirtual
         *)
    samescreen*: Bool;         (* same screen flag *)
    focus*: Bool;               (* boolean focus *)
    state*: uintmask;           (* key or button mask *)
  END;
  XEnterWindowEvent* = XCrossingEvent;
  XLeaveWindowEvent* = XCrossingEvent;

  XFocusChangeEventPtr* = POINTER TO XFocusChangeEvent;
  XFocusChangeEvent* = RECORD
    type*: C.int;               (* FocusIn or FocusOut *)
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;            (* window of event *)
    mode*: C.int;               (* NotifyNormal, NotifyGrab, NotifyUngrab *)
    detail*: C.int;             (*
         * NotifyAncestor, NotifyVirtual, NotifyInferior,
         * NotifyNonlinear,NotifyNonlinearVirtual, NotifyPointer,
         * NotifyPointerRoot, NotifyDetailNone
         *)
  END;
  XFocusInEvent* = XFocusChangeEvent;
  XFocusOutEvent* = XFocusChangeEvent;

(* generated on EnterWindow and FocusIn  when KeyMapState selected *)
  XKeymapEventPtr* = POINTER TO XKeymapEvent;
  XKeymapEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;
    keyvector*: ARRAY 32 OF C.char;
  END;

  XExposeEventPtr* = POINTER TO XExposeEvent;
  XExposeEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;
    x*, y*: C.int;
    width*, height*: C.int;
    count*: C.int;              (* if non-zero, at least this many more *)
  END;
  XGraphicsExposeEventPtr* = POINTER TO XGraphicsExposeEvent;
  XGraphicsExposeEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    drawable*: Drawable;
    x*, y*: C.int;
    width*, height*: C.int;
    count*: C.int;              (* if non-zero, at least this many more *)
    majorcode*: C.int;         (* core is CopyArea or CopyPlane *)
    minorcode*: C.int;         (* not defined in the core *)
  END;

  XNoExposeEventPtr* = POINTER TO XNoExposeEvent;
  XNoExposeEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    drawable*: Drawable;
    majorcode*: C.int;         (* core is CopyArea or CopyPlane *)
    minorcode*: C.int;         (* not defined in the core *)
  END;

  XVisibilityEventPtr* = POINTER TO XVisibilityEvent;
  XVisibilityEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;
    state*: C.int;              (* Visibility state *)
  END;

  XCreateWindowEventPtr* = POINTER TO XCreateWindowEvent;
  XCreateWindowEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    parent*: Window;            (* parent of the window *)
    window*: Window;            (* window id of window created *)
    x*, y*: C.int;              (* window location *)
    width*, height*: C.int;     (* size of window *)
    borderwidth*: C.int;       (* border width *)
    overrideredirect*: Bool;   (* creation should be overridden *)
  END;

  XDestroyWindowEventPtr* = POINTER TO XDestroyWindowEvent;
  XDestroyWindowEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    event*: Window;
    window*: Window;
  END;

  XUnmapEventPtr* = POINTER TO XUnmapEvent;
  XUnmapEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    event*: Window;
    window*: Window;
    fromconfigure*: Bool;
  END;

  XMapEventPtr* = POINTER TO XMapEvent;
  XMapEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    event*: Window;
    window*: Window;
    overrideredirect*: Bool;   (* boolean, is override set... *)
  END;

  XMapRequestEventPtr* = POINTER TO XMapRequestEvent;
  XMapRequestEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    parent*: Window;
    window*: Window;
  END;

  XReparentEventPtr* = POINTER TO XReparentEvent;
  XReparentEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    event*: Window;
    window*: Window;
    parent*: Window;
    x*, y*: C.int;
    overrideredirect*: Bool;
  END;

  XConfigureEventPtr* = POINTER TO XConfigureEvent;
  XConfigureEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    event*: Window;
    window*: Window;
    x*, y*: C.int;
    width*, height*: C.int;
    borderwidth*: C.int;
    above*: Window;
    overrideredirect*: Bool;
  END;

  XGravityEventPtr* = POINTER TO XGravityEvent;
  XGravityEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    event*: Window;
    window*: Window;
    x*, y*: C.int;
  END;

  XResizeRequestEventPtr* = POINTER TO XResizeRequestEvent;
  XResizeRequestEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;
    width*, height*: C.int;
  END;

  XConfigureRequestEventPtr* = POINTER TO XConfigureRequestEvent;
  XConfigureRequestEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    parent*: Window;
    window*: Window;
    x*, y*: C.int;
    width*, height*: C.int;
    borderwidth*: C.int;
    above*: Window;
    detail*: C.int;             (* Above, Below, TopIf, BottomIf, Opposite *)
    valuemask*: ulongmask;
  END;

  XCirculateEventPtr* = POINTER TO XCirculateEvent;
  XCirculateEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    event*: Window;
    window*: Window;
    place*: C.int;              (* PlaceOnTop, PlaceOnBottom *)
  END;

  XCirculateRequestEventPtr* = POINTER TO XCirculateRequestEvent;
  XCirculateRequestEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    parent*: Window;
    window*: Window;
    place*: C.int;              (* PlaceOnTop, PlaceOnBottom *)
  END;

  XPropertyEventPtr* = POINTER TO XPropertyEvent;
  XPropertyEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;
    atom*: Atom;
    time*: Time;
    state*: C.int;              (* NewValue, Deleted *)
  END;

  XSelectionClearEventPtr* = POINTER TO XSelectionClearEvent;
  XSelectionClearEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;
    selection*: Atom;
    time*: Time;
  END;

  XSelectionRequestEventPtr* = POINTER TO XSelectionRequestEvent;
  XSelectionRequestEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    owner*: Window;
    requestor*: Window;
    selection*: Atom;
    target*: Atom;
    property*: Atom;
    time*: Time;
  END;

  XSelectionEventPtr* = POINTER TO XSelectionEvent;
  XSelectionEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    requestor*: Window;
    selection*: Atom;
    target*: Atom;
    property*: Atom;            (* ATOM or None *)
    time*: Time;
  END;

  XColormapEventPtr* = POINTER TO XColormapEvent;
  XColormapEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;
    colormap*: Colormap;        (* COLORMAP or None *)
    new*: Bool;
    state*: C.int;              (* ColormapInstalled, ColormapUninstalled *)
  END;

  XClientMessageEventPtr* = POINTER TO XClientMessageEvent;
  XClientMessageEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;
    messagetype*: Atom;
    format*: C.int;
    data*: RECORD (*[UNION]*)
      b*: ARRAY 20 OF C.char;
      s*: ARRAY 10 OF C.shortint;
      l*: ARRAY 5 OF C.longint;
    END;
  END;

  XMappingEventPtr* = POINTER TO XMappingEvent;
  XMappingEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;            (* unused *)
    request*: C.int;            (* one of MappingModifier, MappingKeyboard,
                                   MappingPointer *)
    firstkeycode*: C.int;      (* first keycode *)
    count*: C.int;              (* defines range of change w. firstkeycode*)
  END;

  XErrorEventPtr* = POINTER TO XErrorEvent;
  XErrorEvent* = RECORD
    type*: C.int;
    display*: DisplayPtr;       (* Display the event was read from *)
    resourceid*: XID;           (* resource id *)
    serial*: C.longint;         (* serial number of failed request *)
    errorcode*: C.char;        (* error code of failed request *)
    requestcode*: C.char;      (* Major op-code of failed request *)
    minorcode*: C.char;        (* Minor op-code of failed request *)
  END;

  XAnyEventPtr* = POINTER TO XAnyEvent;
  XAnyEvent* = RECORD
    type*: C.int;
    serial*: C.longint;         (* # of last request processed by server *)
    sendevent*: Bool;          (* true if this came from a SendEvent request *)
    display*: DisplayPtr;       (* Display the event was read from *)
    window*: Window;            (* window on which event was requested in event mask *)
  END;

(*
 * this union is defined so Xlib can always use the same sized
 * event structure internally, to avoid memory fragmentation.
 *)
  XEventPtr* = POINTER TO XEvent;
  XEvent* = RECORD (*[UNION]*)
    type*: C.int;               (* must not be changed; first element *)
    xany*: XAnyEvent;
    xkey*: XKeyEvent;
    xbutton*: XButtonEvent;
    xmotion*: XMotionEvent;
    xcrossing*: XCrossingEvent;
    xfocus*: XFocusChangeEvent;
    xexpose*: XExposeEvent;
    xgraphicsexpose*: XGraphicsExposeEvent;
    xnoexpose*: XNoExposeEvent;
    xvisibility*: XVisibilityEvent;
    xcreatewindow*: XCreateWindowEvent;
    xdestroywindow*: XDestroyWindowEvent;
    xunmap*: XUnmapEvent;
    xmap*: XMapEvent;
    xmaprequest*: XMapRequestEvent;
    xreparent*: XReparentEvent;
    xconfigure*: XConfigureEvent;
    xgravity*: XGravityEvent;
    xresizerequest*: XResizeRequestEvent;
    xconfigurerequest*: XConfigureRequestEvent;
    xcirculate*: XCirculateEvent;
    xcirculaterequest*: XCirculateRequestEvent;
    xproperty*: XPropertyEvent;
    xselectionclear*: XSelectionClearEvent;
    xselectionrequest*: XSelectionRequestEvent;
    xselection*: XSelectionEvent;
    xcolormap*: XColormapEvent;
    xclient*: XClientMessageEvent;
    xmapping*: XMappingEvent;
    xerror*: XErrorEvent;
    xkeymap*: XKeymapEvent;
    pad*: ARRAY 24 OF C.longint;
  END;

(*
(*
 * per character font metric information.
 *)
TYPE
  XCharStructPtr* = POINTER TO XCharStruct;
  XCharStruct* = RECORD
    lbearing*: C.shortint;      (* origin to left edge of raster *)
    rbearing*: C.shortint;      (* origin to right edge of raster *)
    width*: C.shortint;         (* advance to next char's origin *)
    ascent*: C.shortint;        (* baseline to top edge of raster *)
    descent*: C.shortint;       (* baseline to bottom edge of raster *)
    attributes*: C.shortint;    (* per char flags (not predefined) *)
  END;

(*
 * To allow arbitrary information with fonts, there are additional properties
 * returned.
 *)
TYPE
  
  XFontPropPtr* = POINTER TO XFontProp;
  XFontProp* = RECORD
    name*: Atom;
    card32*: C.longint;
  END;

  XFontStructPtr* = POINTER TO XFontStruct;
  XFontStruct* = RECORD
    extdata*: XExtDataPtr;     (* hook for extension to hang data *)
    fid*: Font;                 (* Font id for this font *)
    direction*: C.int;          (* hint about direction the font is painted *)
    mincharorbyte2*: C.int;  (* first character *)
    maxcharorbyte2*: C.int;  (* last character *)
    minbyte1*: C.int;          (* first row that exists *)
    maxbyte1*: C.int;          (* last row that exists *)
    allcharsexist*: Bool;     (* flag if all characters have non-zero size*)
    defaultchar*: C.int;       (* char to print for undefined character *)
    nproperties*: C.int;       (* how many properties there are *)
    properties*: XFontPropPtr;  (* pointer to array of additional properties*)
    minbounds*: XCharStruct;   (* minimum bounds over all existing char*)
    maxbounds*: XCharStruct;   (* maximum bounds over all existing char*)
    perchar*: XCharStructPtr;  (* firstchar to lastchar information *)
    ascent*: C.int;             (* log. extent above baseline for spacing *)
    descent*: C.int;            (* log. descent below baseline for spacing *)
  END;

(*
 * PolyText routines take these as arguments.
 *)
TYPE
  
  XTextItemPtr* = POINTER TO XTextItem;
  XTextItem* = RECORD
    chars*: C.charPtr1d;        (* pointer to string *)
    nchars*: C.int;             (* number of characters *)
    delta*: C.int;              (* delta between strings *)
    font*: Font;                (* font to print it in, None don't change *)
  END;

  XChar2bPtr* = POINTER TO XChar2b;
  XChar2b* = RECORD
    byte1*: C.char;
    byte2*: C.char;
  END;

  XTextItem16Ptr* = POINTER TO XTextItem16;
  XTextItem16* = RECORD
    chars*: XChar2bPtr;         (* two byte characters *)
    nchars*: C.int;             (* number of characters *)
    delta*: C.int;              (* delta between strings *)
    font*: Font;                (* font to print it in, None don't change *)
  END;

  XEDataObjectPtr* = POINTER TO XEDataObject;
  XEDataObject* = RECORD (*[UNION]*)
    display*: DisplayPtr;
    gc*: GC;
    visual*: VisualPtr;
    screen*: ScreenPtr;
    pixmapformat*: ScreenFormatPtr;
    font*: XFontStructPtr;
  END;

  XFontSetExtentsPtr* = POINTER TO XFontSetExtents;
  XFontSetExtents* = RECORD
    maxinkextent*: XRectangle;
    maxlogicalextent*: XRectangle;
  END;
*)
TYPE
(*  XOMProc* = PROCEDURE;

  XOMDesc* = RECORD END;
  XOCDesc* = RECORD END;
  XOM* = POINTER TO XOMDesc;
  XOC* = POINTER TO XOCDesc;
  XFontSet* = POINTER TO XOCDesc;
*)
TYPE
(*  XmbTextItemPtr* = POINTER TO XmbTextItem;
  XmbTextItem* = RECORD
    chars*: C.charPtr1d;
    nchars*: C.int;
    delta*: C.int;
    fontset*: XFontSet;
  END;
*)
TYPE
  (*wcharPtr1d* = POINTER TO ARRAY OF wchart;
  wcharPtr2d* = POINTER TO ARRAY OF wcharPtr1d;*)
  (*XwcTextItemPtr* = POINTER TO XwcTextItem;
  XwcTextItem* = RECORD
    chars*: wcharPtr1d;
    nchars*: C.int;
    delta*: C.int;
    fontset*: XFontSet;
  END;
*)

CONST
  XNRequiredCharSet* = "requiredCharSet";
  XNQueryOrientation* = "queryOrientation";
  XNBaseFontName* = "baseFontName";
  XNOMAutomatic* = "omAutomatic";
  XNMissingCharSet* = "missingCharSet";
  XNDefaultString* = "defaultString";
  XNOrientation* = "orientation";
  XNDirectionalDependentDrawing* = "directionalDependentDrawing";
  XNContextualDrawing* = "contextualDrawing";
  XNFontInfo* = "fontInfo";

TYPE
  XOMCharSetListPtr* = POINTER TO XOMCharSetList;
  XOMCharSetList* = RECORD
    charsetcount*: C.int;
    charsetlist*: C.charPtr2d;
  END;

CONST  (* enum XOrientation *)
  XOMOrientationLTRTTB* = 0;
  XOMOrientationRTLTTB* = 1;
  XOMOrientationTTBLTR* = 2;
  XOMOrientationTTBRTL* = 3;
  XOMOrientationContext* = 4;

TYPE
  XOrientation* = C.enum1;
  XOrientationPtr1d* = POINTER TO ARRAY OF XOrientation;

TYPE
  XOMOrientationPtr* = POINTER TO XOMOrientation;
  XOMOrientation* = RECORD
    numorient*: C.int;
    orient*: XOrientationPtr1d;    (* Input Text description *)
  END;

TYPE
(*  XFontStructPtr1d* = POINTER TO ARRAY OF XFontStructPtr;
  XOMFontInfoPtr* = POINTER TO XOMFontInfo;
  XOMFontInfo* = RECORD
    numfont*: C.int;
    fontstructlist*: XFontStructPtr1d;
    fontnamelist*: C.charPtr2d;
  END;
*)
TYPE
  XIMProc* = PROCEDURE;

TYPE
  XIMDesc* = RECORD END;
  XICDesc* = RECORD END;
  XIM* = POINTER TO XIMDesc;
  XIC* = POINTER TO XICDesc;

  XIMStyle* = C.longint;
  XIMStylePtr1d* = POINTER TO ARRAY OF XIMStyle;

TYPE
  XIMStylesPtr* = POINTER TO XIMStyles;
  XIMStyles* = RECORD
    countstyles*: C.shortint;
    supportedstyles*: XIMStylePtr1d;
  END;

CONST
  XIMPreeditArea* = 00001H;
  XIMPreeditCallbacks* = 00002H;
  XIMPreeditPosition* = 00004H;
  XIMPreeditNothing* = 00008H;
  XIMPreeditNone* = 00010H;
  XIMStatusArea* = 00100H;
  XIMStatusCallbacks* = 00200H;
  XIMStatusNothing* = 00400H;
  XIMStatusNone* = 00800H;

CONST
  XNVaNestedList* = "XNVaNestedList";
  XNQueryInputStyle* = "queryInputStyle";
  XNClientWindow* = "clientWindow";
  XNInputStyle* = "inputStyle";
  XNFocusWindow* = "focusWindow";
  XNResourceName* = "resourceName";
  XNResourceClass* = "resourceClass";
  XNGeometryCallback* = "geometryCallback";
  XNDestroyCallback* = "destroyCallback";
  XNFilterEvents* = "filterEvents";
  XNPreeditStartCallback* = "preeditStartCallback";
  XNPreeditDoneCallback* = "preeditDoneCallback";
  XNPreeditDrawCallback* = "preeditDrawCallback";
  XNPreeditCaretCallback* = "preeditCaretCallback";
  XNPreeditStateNotifyCallback* = "preeditStateNotifyCallback";
  XNPreeditAttributes* = "preeditAttributes";
  XNStatusStartCallback* = "statusStartCallback";
  XNStatusDoneCallback* = "statusDoneCallback";
  XNStatusDrawCallback* = "statusDrawCallback";
  XNStatusAttributes* = "statusAttributes";
  XNArea* = "area";
  XNAreaNeeded* = "areaNeeded";
  XNSpotLocation* = "spotLocation";
  XNColormap* = "colorMap";
  XNStdColormap* = "stdColorMap";
  XNForeground* = "foreground";
  XNBackground* = "background";
  XNBackgroundPixmap* = "backgroundPixmap";
  XNFontSet* = "fontSet";
  XNLineSpace* = "lineSpace";
  XNCursor* = "cursor";

CONST
  XNQueryIMValuesList* = "queryIMValuesList";
  XNQueryICValuesList* = "queryICValuesList";
  XNVisiblePosition* = "visiblePosition";
  XNR6PreeditCallback* = 6;
  XNStringConversionCallback* = "stringConversionCallback";
  XNStringConversion* = "stringConversion";
  XNResetState* = "resetState";
  XNHotKey* = "hotKey";
  XNHotKeyState* = "hotKeyState";
  XNPreeditState* = "preeditState";
  XNSeparatorofNestedList* = "separatorofNestedList";

CONST
  XBufferOverflow* = 1;
  XLookupNone* = 1;
  XLookupChars* = 2;
  XLookupKeySym* = 3;
  XLookupBoth* = 4;

TYPE
  XVaNestedList* = C.address;

TYPE
  XIMCallbackPtr* = POINTER TO XIMCallback;
  XIMCallback* = RECORD
    clientdata*: XPointer;
    callback*: XIMProc;
  END;

  XIMFeedback* = C.longint;
  XIMFeedbackPtr1d* = POINTER TO ARRAY OF XIMFeedback;

CONST
  XIMReverse* = {0};
  XIMUnderline* = {1};
  XIMHighlight* = {2};
  XIMPrimary* = {5};
  XIMSecondary* = {6};
  XIMTertiary* = {7};
  XIMVisibleToForward* = {8};
  XIMVisibleToBackword* = {9};
  XIMVisibleToCenter* = {10};

(*
TYPE
  XIMTextPtr* = POINTER TO XIMText;
  XIMText* = RECORD
    length*: C.shortint;
    feedback*: XIMFeedbackPtr1d;
    encodingiswchar*: Bool;
    string*: RECORD (*[UNION]*)
      multibyte*: C.charPtr1d;
      widechar*: wcharPtr1d
    END
  END;

  XIMPreeditState* = C.longint;
*)
CONST
  XIMPreeditUnKnown* = {};
  XIMPreeditEnable* = {0};
  XIMPreeditDisable* = {1};

(*
TYPE
  XIMPreeditStateNotifyCallbackStructPtr* = POINTER TO XIMPreeditStateNotifyCallbackStruct;
  XIMPreeditStateNotifyCallbackStruct* = RECORD
    state*: XIMPreeditState;
  END;

  XIMResetState* = C.longint;
*)
CONST
  XIMInitialState* = {0};
  XIMPreserveState* = {1};
(*
TYPE
  XIMStringConversionFeedback* = C.longint;
  XIMStringConversionFeedbackPtr1d* = POINTER TO ARRAY OF XIMStringConversionFeedback;
*)
CONST
  XIMStringConversionLeftEdge* = 000000001H;
  XIMStringConversionRightEdge* = 000000002H;
  XIMStringConversionTopEdge* = 000000004H;
  XIMStringConversionBottomEdge* = 000000008H;
  XIMStringConversionConcealed* = 000000010H;
  XIMStringConversionWrapped* = 000000020H;
(*
TYPE
  XIMStringConversionTextPtr* = POINTER TO XIMStringConversionText;
  XIMStringConversionText* = RECORD
    length*: C.shortint;
    feedback*: XIMStringConversionFeedbackPtr1d;
    encodingiswchar*: Bool;
    string*: RECORD (*[UNION]*)
      mbs*: C.charPtr1d;
      wcs*: wcharPtr1d;
    END;
  END;
  XIMStringConversionPosition* = C.shortint;
  XIMStringConversionType* = C.shortint;
*)
CONST
  XIMStringConversionBuffer* = 00001H;
  XIMStringConversionLine* = 00002H;
  XIMStringConversionWord* = 00003H;
  XIMStringConversionChar* = 00004H;

TYPE
  XIMStringConversionOperation* = C.shortint;

CONST
  XIMStringConversionSubstitution* = 00001H;
  XIMStringConversionRetrival* = 00002H;

(*
TYPE
  XIMStringConversionCallbackStructPtr* = POINTER TO XIMStringConversionCallbackStruct;
  XIMStringConversionCallbackStruct* = RECORD
    position*: XIMStringConversionPosition;
    type*: XIMStringConversionType;
    operation*: XIMStringConversionOperation;
    factor*: C.shortint;
    text*: XIMStringConversionTextPtr;
  END;

  XIMPreeditDrawCallbackStructPtr* = POINTER TO XIMPreeditDrawCallbackStruct;
  XIMPreeditDrawCallbackStruct* = RECORD
    caret*: C.int;              (* Cursor offset within pre-edit string *)
    chgfirst*: C.int;          (* Starting change position *)
    chglength*: C.int;         (* Length of the change in character count *)
    text*: XIMTextPtr;
  END;
*)
CONST  (* enum XIMCaretDirection *)
  XIMForwardChar* = 0;
  XIMBackwardChar* = 1;
  XIMForwardWord* = 2;
  XIMBackwardWord* = 3;
  XIMCaretUp* = 4;
  XIMCaretDown* = 5;
  XIMNextLine* = 6;
  XIMPreviousLine* = 7;
  XIMLineStart* = 8;
  XIMLineEnd* = 9;
  XIMAbsolutePosition* = 10;
  XIMDontChange* = 11;

TYPE
  XIMCaretDirection* = C.enum1;

CONST  (* enum XIMCaretStyle *)
  XIMIsInvisible* = 0;
  XIMIsPrimary* = 1;
  XIMIsSecondary* = 2;

TYPE
  XIMCaretStyle* = C.enum1;
(*
TYPE
  XIMPreeditCaretCallbackStructPtr* = POINTER TO XIMPreeditCaretCallbackStruct;
  XIMPreeditCaretCallbackStruct* = RECORD
    position*: C.int;           (* Caret offset within pre-edit string *)
    direction*: XIMCaretDirection;(* Caret moves direction *)
    style*: XIMCaretStyle;      (* Feedback of the caret *)
  END;
*)
CONST  (* enum XIMStatusDataType *)
  XIMTextType* = 0;
  XIMBitmapType* = 1;

TYPE
  XIMStatusDataType* = C.enum1;

TYPE
(*
  XIMStatusDrawCallbackStructPtr* = POINTER TO XIMStatusDrawCallbackStruct;
  XIMStatusDrawCallbackStruct* = RECORD
    type*: XIMStatusDataType;
    data*: RECORD (*[UNION]*)
      text*: XIMTextPtr;
      bitmap*: Pixmap;
    END;
  END;
*)
  XIMHotKeyTriggerPtr* = POINTER TO XIMHotKeyTrigger;
  XIMHotKeyTrigger* = RECORD
    keysym*: KeySym;
    modifier*: C.int;
    modifiermask*: uintmask;
  END;

  XIMHotKeyTriggersPtr* = POINTER TO XIMHotKeyTriggers;
  XIMHotKeyTriggers* = RECORD
    numhotkey*: C.int;
    key*: XIMHotKeyTriggerPtr;
  END;
  XIMHotKeyState* = C.longint;

CONST
  XIMHotKeyStateON* = 00001H;
  XIMHotKeyStateOFF* = 00002H;

TYPE
  XIMValuesList* = RECORD
    countvalues*: C.shortint;
    supportedvalues*: C.charPtr2d;
  END;


VAR
  Xdebug*: C.int;

TYPE
  (* procedure type declarations to acommodate the stricter Oberon-2
     assignment rules.*)
  DisplayProc* = PROCEDURE (display: DisplayPtr): C.int;
  EventProc* = PROCEDURE (display: DisplayPtr; event: XEventPtr; arg: XPointer): Bool;

  (* Xlib procedure variables *)
  XErrorHandler* = PROCEDURE (display: DisplayPtr; errorevent: XErrorEventPtr): C.int;
  XIOErrorHandler* = PROCEDURE (display: DisplayPtr);
  XConnectionWatchProc* = PROCEDURE (dpy: DisplayPtr; clientdate: XPointer; fd: C.int; opening: Bool; watchdata: XPointerPtr1d);


PROCEDURE -aincludexlib      "#include <X11/Xlib.h>";
PROCEDURE -aincludexutil     "#include <X11/Xutil.h>";
PROCEDURE -aincludexresource "#include <X11/Xresource.h>";


(*
PROCEDURE XLoadQueryFont* (
    display: DisplayPtr;
    name: ARRAY OF C.char): XFontStructPtr;
PROCEDURE XQueryFont* (
    display: DisplayPtr;
    fontID: XID): XFontStructPtr;
PROCEDURE XGetMotionEvents* (
    display: DisplayPtr;
    w: Window;
    start: Time;
    stop: Time;
    VAR neventsreturn: C.int): XTimeCoordPtr;
PROCEDURE XDeleteModifiermapEntry* (
    modmap: XModifierKeymapPtr;
    keycodeentry: KeyCode;  (* or unsigned int instead of KeyCode *)
    modifier: C.int): XModifierKeymapPtr;
PROCEDURE XGetModifierMapping* (
    display: DisplayPtr): XModifierKeymapPtr;
PROCEDURE XInsertModifiermapEntry* (
    modmap: XModifierKeymapPtr;
    keycodeentry: KeyCode;  (* or unsigned int instead of KeyCode *)
    modifier: C.int): XModifierKeymapPtr;
PROCEDURE XNewModifiermap* (
    maxkeyspermod: C.int): XModifierKeymapPtr;
*)
PROCEDURE -XCreateImage* (
    display: DisplayPtr;
    visual: VisualPtr;
    depth: C.int;
    format: C.int;
    offset: C.int;
    data: C.address;
    width: C.int;
    height: C.int;
    bitmapPad: C.int;
    bytesPerLine: C.int): XImagePtr
    "(oocX11_XImagePtr)XCreateImage((struct _XDisplay*)display, (Visual*)visual, depth, format, offset, (char*)data, width, height, bitmapPad, bytesPerLine)";
(*
PROCEDURE XInitImage* (
    image: XImagePtr): Status;
PROCEDURE XGetImage* (
    display: DisplayPtr;
    d: Drawable;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int;
    planemask: ulongmask;
    format: C.int): XImagePtr;
PROCEDURE XGetSubImage* (
    display: DisplayPtr;
    d: Drawable;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int;
    planemask: ulongmask;
    format: C.int;
    destimage: XImagePtr;
    destx: C.int;
    desty: C.int): XImagePtr;

(*
 * X function declarations.
 *)
 *)
PROCEDURE -XOpenDisplay* (name: ARRAY OF C.char): DisplayPtr "(oocX11_DisplayPtr)XOpenDisplay((char*)name)";

PROCEDURE OpenDisplay* (name: ARRAY OF C.char): DisplayPtr;
BEGIN
   RETURN XOpenDisplay(name)
END OpenDisplay;
(*
PROCEDURE XrmInitialize* ();
PROCEDURE XFetchBytes* (
    display: DisplayPtr;
    VAR nbytesreturn: C.int): C.charPtr1d;
PROCEDURE XFetchBuffer* (
    display: DisplayPtr;
    VAR nbytesreturn: C.int;
    buffer: C.int): C.charPtr1d;
PROCEDURE XGetAtomName* (
    display: DisplayPtr;
    atom: Atom): C.charPtr1d;
PROCEDURE XGetAtomNames* (
    dpy: DisplayPtr;
    VAR atoms: ARRAY OF Atom;
    count: C.int;
    VAR namesreturn: C.charPtr2d): Status;
PROCEDURE XGetDefault* (
    display: DisplayPtr;
    program: ARRAY OF C.char;
    option: ARRAY OF C.char): C.charPtr1d;
PROCEDURE XDisplayName* (
    string[NILCOMPAT]: ARRAY OF C.char): C.charPtr1d;
PROCEDURE XKeysymToString* (
    keysym: KeySym): C.charPtr1d;
PROCEDURE XSynchronize* (
    display: DisplayPtr;
    onoff: Bool): DisplayProc;
PROCEDURE XSetAfterFunction* (
    display: DisplayPtr;
    procedure: DisplayProc): DisplayProc;
PROCEDURE XInternAtom* (
    display: DisplayPtr;
    atomname: ARRAY OF C.char;
    onlyifexists: Bool): Atom;
PROCEDURE XInternAtoms* (
    dpy: DisplayPtr;
    names: C.charPtr2d;
    count: C.int;
    onlyIfExists: Bool;
    VAR atomsreturn: Atom): Status;
PROCEDURE XCopyColormapAndFree* (
    display: DisplayPtr;
    colormap: Colormap): Colormap;
PROCEDURE XCreateColormap* (
    display: DisplayPtr;
    w: Window;
    visual: VisualPtr;
    alloc: C.int): Colormap;
PROCEDURE XCreatePixmapCursor* (
    display: DisplayPtr;
    source: Pixmap;
    mask: Pixmap;
    VAR foregroundcolor: XColor;
    VAR backgroundcolor: XColor;
    x: C.int;
    y: C.int): Cursor;
PROCEDURE XCreateGlyphCursor* (
    display: DisplayPtr;
    sourcefont: Font;
    maskfont: Font;
    sourcechar: C.int;
    maskchar: C.int;
    VAR foregroundcolor: XColor;
    VAR backgroundcolor: XColor): Cursor;
PROCEDURE XCreateFontCursor* (
    display: DisplayPtr;
    shape: C.int): Cursor;
PROCEDURE XLoadFont* (
    display: DisplayPtr;
    name: ARRAY OF C.char): Font;
*)
PROCEDURE -XCreateGC* (
    display: DisplayPtr;
    d: Drawable;
    valueMask: ulongmask;
    VAR values: XGCValues): GC
    "(oocX11_GC)XCreateGC((struct _XDisplay*)display, d, valueMask, (XGCValues *)values)";
(*
PROCEDURE XGContextFromGC* (
    gc: GC): GContext;
PROCEDURE XFlushGC* (
    display: DisplayPtr;
    gc: GC);
PROCEDURE XCreatePixmap* (
    display: DisplayPtr;
    d: Drawable;
    width: C.int;
    height: C.int;
    depth: C.int): Pixmap;
PROCEDURE XCreateBitmapFromData* (
    display: DisplayPtr;
    d: Drawable;
    data: ARRAY OF C.char;
    width: C.int;
    height: C.int): Pixmap;
PROCEDURE XCreatePixmapFromBitmapData* (
    display: DisplayPtr;
    d: Drawable;
    data: C.address;
    width: C.int;
    height: C.int;
    fg: C.longint;
    bg: C.longint;
    depth: C.int): Pixmap;
*)
PROCEDURE -XCreateSimpleWindow* (
    display: DisplayPtr;
    parent: Window;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int;
    borderWidth: C.int;
    border: C.longint;
    background: C.longint): Window
    "(long)XCreateSimpleWindow((struct _XDisplay*)display, parent, x, y, width, height, borderWidth, border, background)";
(*
PROCEDURE XGetSelectionOwner* (
    display: DisplayPtr;
    selection: Atom): Window;
PROCEDURE XCreateWindow* (
    display: DisplayPtr;
    parent: Window;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int;
    borderwidth: C.int;
    depth: C.int;
    class: C.int;
    VAR visual: Visual;
    valuemask: ulongmask;
    VAR attributes: XSetWindowAttributes): Window;
PROCEDURE XListInstalledColormaps* (
    display: DisplayPtr;
    w: Window;
    VAR numreturn: C.int): ColormapPtr1d;
PROCEDURE XListFonts* (
    display: DisplayPtr;
    pattern: ARRAY OF C.char;
    maxnames: C.int;
    VAR actualcountreturn: C.int): C.charPtr2d;
PROCEDURE XListFontsWithInfo* (
    display: DisplayPtr;
    pattern: ARRAY OF C.char;
    maxnames: C.int;
    VAR countreturn: C.int;
    VAR inforeturn: XFontStructPtr1d): C.charPtr2d;
PROCEDURE XGetFontPath* (
    display: DisplayPtr;
    VAR npathsreturn: C.int): C.charPtr2d;
PROCEDURE XListExtensions* (
    display: DisplayPtr;
    VAR nextensionsreturn: C.int): C.charPtr2d;
PROCEDURE XListProperties* (
    display: DisplayPtr;
    w: Window;
    VAR numpropreturn: C.int): AtomPtr1d;
PROCEDURE XListHosts* (
    display: DisplayPtr;
    VAR nhostsreturn: C.int;
    VAR statereturn: Bool): XHostAddressPtr1d;
PROCEDURE XKeycodeToKeysym* (
    display: DisplayPtr;
    keycode: KeyCode;  (* or C.int *)
    index: C.int): KeySym;
PROCEDURE XLookupKeysym* (
    keyevent: XKeyEventPtr;
    index: C.int): KeySym;
PROCEDURE XGetKeyboardMapping* (
    display: DisplayPtr;
    firstkeycode: KeyCode;  (* or C.int *)
    keycodecount: C.int;
    VAR keysymsperkeycodereturn: C.int): KeySymPtr1d;
PROCEDURE XStringToKeysym* (
    string: ARRAY OF C.char): KeySym;
PROCEDURE XMaxRequestSize* (
    display: DisplayPtr): C.longint;
PROCEDURE XExtendedMaxRequestSize* (
    display: DisplayPtr): C.longint;
PROCEDURE XResourceManagerString* (
    display: DisplayPtr): C.charPtr1d;
PROCEDURE XScreenResourceString* (
    screen: ScreenPtr): C.charPtr1d;
PROCEDURE XDisplayMotionBufferSize* (
    display: DisplayPtr): C.longint;
PROCEDURE XVisualIDFromVisual* (
    visual: VisualPtr): VisualID;


(* multithread routines *)
PROCEDURE XInitThreads* (): Status;
PROCEDURE XLockDisplay* (
    display: DisplayPtr);
PROCEDURE XUnlockDisplay* (
    display: DisplayPtr);


(* routines for dealing with extensions *)
PROCEDURE XInitExtension* (
    display: DisplayPtr;
    name: ARRAY OF C.char): XExtCodesPtr;
PROCEDURE XAddExtension* (
    display: DisplayPtr): XExtCodesPtr;
PROCEDURE XFindOnExtensionList* (
    structure: ARRAY OF XExtDataPtr;
    number: C.int): XExtDataPtr;
PROCEDURE XEHeadOfExtensionList* (
    object: XEDataObject): XExtDataPtr1d;

(* these are routines for which there are also macros *)
*)
PROCEDURE -XRootWindow* (
    display: DisplayPtr;
    screen: C.int): Window
    "(long)XRootWindow((struct _XDisplay*)display, screen)";
(*
PROCEDURE XDefaultRootWindow* (
    display: DisplayPtr): Window;
PROCEDURE XRootWindowOfScreen* (
    screen: ScreenPtr): Window;
*)
PROCEDURE -XDefaultVisual* (
    display: DisplayPtr;
    screen: C.int): VisualPtr
    "(oocX11_VisualPtr)XDefaultVisual((struct _XDisplay*)display, screen)";
(*
PROCEDURE XDefaultVisualOfScreen* (
    screen: ScreenPtr): VisualPtr;
PROCEDURE XDefaultGC* (
    display: DisplayPtr;
    screennumber: C.int): GC;
PROCEDURE XDefaultGCOfScreen* (
    screen: ScreenPtr): GC;
*)
PROCEDURE -XBlackPixel* (
    display: DisplayPtr;
    screen: C.int): C.longint
    "(long)XBlackPixel((struct _XDisplay*)display, screen)";

PROCEDURE -XWhitePixel* (
    display: DisplayPtr;
    screen: C.int): C.longint
    "(long)XWhitePixel((struct _XDisplay*)display, screen)";
(*
PROCEDURE XAllPlanes* (): C.longint;
PROCEDURE XBlackPixelOfScreen* (
    screen: ScreenPtr): C.longint;
PROCEDURE XWhitePixelOfScreen* (
    screen: ScreenPtr): C.longint;
PROCEDURE XNextRequest* (
    display: DisplayPtr): C.longint;
PROCEDURE XLastKnownRequestProcessed* (
    display: DisplayPtr): C.longint;
PROCEDURE XServerVendor* (
    display: DisplayPtr): C.charPtr1d;
PROCEDURE XDisplayString* (
    display: DisplayPtr): C.charPtr1d;
PROCEDURE XDefaultColormap* (
    display: DisplayPtr;
    screennumber: C.int): Colormap;
PROCEDURE XDefaultColormapOfScreen* (
    screen: ScreenPtr): Colormap;
PROCEDURE XDisplayOfScreen* (
    screen: ScreenPtr): DisplayPtr;
PROCEDURE XScreenOfDisplay* (
    display: DisplayPtr;
    screennumber: C.int): ScreenPtr;
*)
PROCEDURE -XDefaultScreenOfDisplay* (
    display: DisplayPtr): ScreenPtr
     "(long)XDefaultScreen((struct _XDisplay*)display)";
(*
PROCEDURE XEventMaskOfScreen* (
    screen: ScreenPtr): C.longint;
PROCEDURE XScreenNumberOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XSetErrorHandler* (
    handler: XErrorHandler): XErrorHandler;
PROCEDURE XSetIOErrorHandler* (
    handler: XIOErrorHandler): XIOErrorHandler;

PROCEDURE XListPixmapFormats* (
    display: DisplayPtr;
    VAR countreturn: C.int): XPixmapFormatValuesPtr;
PROCEDURE XListDepths* (
    display: DisplayPtr;
    screennumber: C.int;
    VAR countreturn: C.int): C.intPtr1d;


(* ICCCM routines for things that don't require special include files; *)
(* other declarations are given in Xutil.h                             *)
PROCEDURE XReconfigureWMWindow* (
    display: DisplayPtr;
    w: Window;
    screennumber: C.int;
    mask: uintmask;
    VAR changes: XWindowChanges): Status;
PROCEDURE XGetWMProtocols* (
    display: DisplayPtr;
    w: Window;
    VAR protocolsreturn: AtomPtr1d;
    VAR countreturn: C.int): Status;
PROCEDURE XSetWMProtocols* (
    display: DisplayPtr;
    w: Window;
    protocols: ARRAY OF Atom;
    count: C.int): Status;
PROCEDURE XIconifyWindow* (
    display: DisplayPtr;
    w: Window;
    screennumber: C.int): Status;
PROCEDURE XWithdrawWindow* (
    display: DisplayPtr;
    w: Window;
    screennumber: C.int): Status;
PROCEDURE XGetCommand* (
    display: DisplayPtr;
    w: Window;
    VAR argvreturn: C.charPtr2d;
    VAR argcreturn: C.int): Status;
PROCEDURE XGetWMColormapWindows* (
    display: DisplayPtr;
    w: Window;
    VAR windowsreturn: WindowPtr1d;
    VAR countreturn: C.int): Status;
PROCEDURE XSetWMColormapWindows* (
    display: DisplayPtr;
    w: Window;
    colormapwindows: ARRAY OF Window;
    count: C.int): Status;
PROCEDURE XFreeStringList* (
    list: C.charPtr2d);
PROCEDURE XSetTransientForHint* (
    display: DisplayPtr;
    w: Window;
    propwindow: Window);


(* The following are given in alphabetical order *)
PROCEDURE XActivateScreenSaver* (
    display: DisplayPtr);
PROCEDURE XAddHost* (
    display: DisplayPtr;
    host: XHostAddressPtr);
PROCEDURE XAddHosts* (
    display: DisplayPtr;
    hosts: XHostAddressPtr;
    numhosts: C.int);
PROCEDURE XAddToExtensionList* (
    VAR structure: XExtDataPtr;
    extdata: XExtDataPtr);  (* ??? mh, don't know if that's correct *)
PROCEDURE XAddToSaveSet* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XAllocColor* (
    display: DisplayPtr;
    colormap: Colormap;
    VAR screeninout: XColor): Status;
PROCEDURE XAllocColorCells* (
    display: DisplayPtr;
    colormap: Colormap;
    contig: Bool;
    VAR planemasksreturn: ulongmask;
    nplanes: C.int;
    VAR pixelsreturn: C.longint;
    npixels: C.int): Status;
PROCEDURE XAllocColorPlanes* (
    display: DisplayPtr;
    colormap: Colormap;
    contig: Bool;
    VAR pixelsreturn: C.longint;
    ncolors: C.int;
    nreds: C.int;
    ngreens: C.int;
    nblues: C.int;
    VAR rmaskreturn: ulongmask;
    VAR gmaskreturn: ulongmask;
    VAR bmaskreturn: ulongmask): Status;
PROCEDURE XAllocNamedColor* (
    display: DisplayPtr;
    colormap: Colormap;
    colorname: ARRAY OF C.char;
    VAR screendefreturn: XColor;
    VAR exactdefreturn: XColor): Status;
PROCEDURE XAllowEvents* (
    display: DisplayPtr;
    eventmode: C.int;
    time: Time);
PROCEDURE XAutoRepeatOff* (
    display: DisplayPtr);
PROCEDURE XAutoRepeatOn* (
    display: DisplayPtr);
PROCEDURE XBell* (
    display: DisplayPtr;
    percent: C.int);
PROCEDURE XBitmapBitOrder* (
    display: DisplayPtr): C.int;
PROCEDURE XBitmapPad* (
    display: DisplayPtr): C.int;
PROCEDURE XBitmapUnit* (
    display: DisplayPtr): C.int;
PROCEDURE XCellsOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XChangeActivePointerGrab* (
    display: DisplayPtr;
    eventmask: uintmask;
    cursor: Cursor;
    time: Time);
PROCEDURE XChangeGC* (
    display: DisplayPtr;
    gc: GC;
    valuemask: ulongmask;
    VAR values: XGCValues);
PROCEDURE XChangeKeyboardControl* (
    display: DisplayPtr;
    valuemask: ulongmask;
    VAR values: XKeyboardControl);
PROCEDURE XChangeKeyboardMapping* (
    display: DisplayPtr;
    firstkeycode: C.int;
    keysymsperkeycode: C.int;
    keysyms: ARRAY OF KeySym;
    numcodes: C.int);
PROCEDURE XChangePointerControl* (
    display: DisplayPtr;
    doaccel: Bool;
    dothreshold: Bool;
    accelnumerator: C.int;
    acceldenominator: C.int;
    threshold: C.int);
PROCEDURE XChangeProperty* (
    display: DisplayPtr;
    w: Window;
    property: Atom;
    type: Atom;
    format: C.int;
    mode: C.int;
    data: ARRAY OF C.char;
    nelements: C.int);
PROCEDURE XChangeSaveSet* (
    display: DisplayPtr;
    w: Window;
    changemode: C.int);
PROCEDURE XChangeWindowAttributes* (
    display: DisplayPtr;
    w: Window;
    valuemask: ulongmask;
    VAR attributes: XSetWindowAttributes);
PROCEDURE XCheckIfEvent* (
    display: DisplayPtr;
    VAR eventreturn: XEvent;
    predicate: EventProc;
    arg: XPointer): Bool;
PROCEDURE XCheckMaskEvent* (
    display: DisplayPtr;
    eventmask: ulongmask;
    VAR eventreturn: XEvent): Bool;
PROCEDURE XCheckTypedEvent* (
    display: DisplayPtr;
    eventtype: C.int;
    VAR eventreturn: XEvent): Bool;
PROCEDURE XCheckTypedWindowEvent* (
    display: DisplayPtr;
    w: Window;
    eventtype: C.int;
    VAR eventreturn: XEvent): Bool;
PROCEDURE XCheckWindowEvent* (
    display: DisplayPtr;
    w: Window;
    eventmask: ulongmask;
    VAR eventreturn: XEvent): Bool;
PROCEDURE XCirculateSubwindows* (
    display: DisplayPtr;
    w: Window;
    direction: C.int);
PROCEDURE XCirculateSubwindowsDown* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XCirculateSubwindowsUp* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XClearArea* (
    display: DisplayPtr;
    w: Window;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int;
    exposures: Bool);
PROCEDURE XClearWindow* (
    display: DisplayPtr;
    w: Window);
*)

PROCEDURE -XCloseDisplay* (
    display: DisplayPtr)
    "XCloseDisplay((struct _XDisplay*)display)";


(*
PROCEDURE XConfigureWindow* (
    display: DisplayPtr;
    w: Window;
    valuemask: uintmask;
    VAR values: XWindowChanges);
PROCEDURE XConnectionNumber* (
    display: DisplayPtr): C.int;
PROCEDURE XConvertSelection* (
    display: DisplayPtr;
    selection: Atom;
    target: Atom;
    property: Atom;
    requestor: Window;
    time: Time);
PROCEDURE XCopyArea* (
    display: DisplayPtr;
    src: Drawable;
    dest: Drawable;
    gc: GC;
    srcx: C.int;
    srcy: C.int;
    width: C.int;
    height: C.int;
    destx: C.int;
    desty: C.int);
PROCEDURE XCopyGC* (
    display: DisplayPtr;
    src: GC;
    valuemask: ulongmask;
    dest: GC);
PROCEDURE XCopyPlane* (
    display: DisplayPtr;
    src: Drawable;
    dest: Drawable;
    gc: GC;
    srcx: C.int;
    srcy: C.int;
    width: C.int;
    height: C.int;
    destx: C.int;
    desty: C.int;
    plane: C.longint);
PROCEDURE XDefaultDepth* (
    display: DisplayPtr;
    screennumber: C.int): C.int;
PROCEDURE XDefaultDepthOfScreen* (
    screen: ScreenPtr): C.int;
*)
PROCEDURE -XDefaultScreen* (
    display: DisplayPtr): C.int
    "(int)XDefaultScreen((struct _XDisplay*)display)";
(*
PROCEDURE XDefineCursor* (
    display: DisplayPtr;
    w: Window;
    cursor: Cursor);
PROCEDURE XDeleteProperty* (
    display: DisplayPtr;
    w: Window;
    property: Atom);
*)
PROCEDURE -XDestroyWindow* (
    display: DisplayPtr;
    w: Window)
    "XDestroyWindow((struct _XDisplay*)display, w)";


PROCEDURE -XDestroyImage* (image : XImagePtr)
   "XDestroyImage((struct _XDisplay*)image)";

(*
PROCEDURE XDestroySubwindows* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XDoesBackingStore* (
    screen: ScreenPtr): C.int;
PROCEDURE XDoesSaveUnders* (
    screen: ScreenPtr): Bool;
PROCEDURE XDisableAccessControl* (
    display: DisplayPtr);
PROCEDURE XDisplayCells* (
    display: DisplayPtr;
    screennumber: C.int): C.int;
*)
PROCEDURE -XDisplayHeight* (
    display: DisplayPtr;
    screen: C.int): C.int
    "(int)XDisplayHeight((struct _XDisplay*)display, screen)";
(*
PROCEDURE XDisplayHeightMM* (
    display: DisplayPtr;
    screennumber: C.int): C.int;
PROCEDURE XDisplayKeycodes* (
    display: DisplayPtr;
    VAR minkeycodesreturn: C.int;
    VAR maxkeycodesreturn: C.int);
PROCEDURE XDisplayPlanes* (
    display: DisplayPtr;
    screennumber: C.int): C.int;
*)
PROCEDURE -XDisplayWidth* (
    display: DisplayPtr;
    screennumber: C.int): C.int
    "(int)XDisplayWidth((struct _XDisplay*)display, screen)";
(*
PROCEDURE XDisplayWidthMM* (
    display: DisplayPtr;
    screennumber: C.int): C.int;
PROCEDURE XDrawArc* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int;
    angle1: C.int;
    angle2: C.int);
PROCEDURE XDrawArcs* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    arcs: ARRAY OF XArc;
    narcs: C.int);
PROCEDURE XDrawImageString* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    string: ARRAY OF C.char;
    length: C.int);
PROCEDURE XDrawImageString16* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
(*    string: ARRAY OF XChar2b;*)
    string: ARRAY OF LONGCHAR;
    length: C.int);
PROCEDURE XDrawLine* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x1: C.int;
    x2: C.int;
    y1: C.int;
    y2: C.int);
PROCEDURE XDrawLines* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    points: ARRAY OF XPoint;
    npoints: C.int;
    mode: C.int);
*)    
PROCEDURE -XDrawPoint* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int)
    "XDrawPoint((struct _XDisplay*)display, d, (struct _XGC*)gc, x, y)";
(*
PROCEDURE XDrawPoints* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    points: ARRAY OF XPoint;
    npoints: C.int;
    mode: C.int);
PROCEDURE XDrawRectangle* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int);
PROCEDURE XDrawRectangles* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    rectangles: ARRAY OF XRectangle;
    nrectangles: C.int);
PROCEDURE XDrawSegments* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    segments: ARRAY OF XSegment;
    nsegments: C.int);
PROCEDURE XDrawString* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    string: ARRAY OF C.char;
    length: C.int);
PROCEDURE XDrawString16* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
(*    string: ARRAY OF XChar2b;*)
    string: ARRAY OF LONGCHAR;
    length: C.int);
PROCEDURE XDrawText* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    items: ARRAY OF XTextItem;
    nitems: C.int);
PROCEDURE XDrawText16* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    items: ARRAY OF XTextItem16;
    nitems: C.int);
PROCEDURE XEnableAccessControl* (
    display: DisplayPtr);
*)
PROCEDURE -XEventsQueued* (
    display: DisplayPtr;
    mode: C.int): C.int
    "(int)XEventsQueued((struct _XDisplay*)display, mode)";
(*
PROCEDURE XFetchName* (
    display: DisplayPtr;
    w: Window;
    VAR windownamereturn: C.charPtr1d): Status;
PROCEDURE XFillArc* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int;
    angle1: C.int;
    angle2: C.int);
PROCEDURE XFillArcs* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    arcs: ARRAY OF XArc;
    narcs: C.int);
PROCEDURE XFillPolygon* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    points: ARRAY OF XPoint;
    npoints: C.int;
    shape: C.int;
    mode: C.int);
*)
PROCEDURE -XFillRectangle* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int)
    "XFillRectangle((struct _XDisplay*)display, d, (struct _XGC*)gc, x, y, width, height)";
(*
PROCEDURE XFillRectangles* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    rectangles: ARRAY OF XRectangle;
    nrectangles: C.int);
*)
PROCEDURE -XFlush* (
    display: DisplayPtr)
    "XFlush((struct _XDisplay*)display)";
(*
PROCEDURE XForceScreenSaver* (
    display: DisplayPtr;
    mode: C.int);
PROCEDURE XFree* (data: C.address);
PROCEDURE XFreeColormap* (
    display: DisplayPtr;
    colormap: Colormap);
PROCEDURE XFreeColors* (
    display: DisplayPtr;
    colormap: Colormap;
    pixels: ARRAY OF C.longint;
    npixels: C.int;
    planes: C.longint);
PROCEDURE XFreeCursor* (
    display: DisplayPtr;
    cursor: Cursor);
PROCEDURE XFreeExtensionList* (
    list: C.charPtr2d);
PROCEDURE XFreeFont* (
    display: DisplayPtr;
    fontstruct: XFontStructPtr);
PROCEDURE XFreeFontInfo* (
    names: C.charPtr2d;
    freeinfo: XFontStructPtr;
    actualcount: C.int);
PROCEDURE XFreeFontNames* (
    list: C.charPtr2d);
PROCEDURE XFreeFontPath* (
    list: C.charPtr2d);
PROCEDURE XFreeGC* (
    display: DisplayPtr;
    gc: GC);
PROCEDURE XFreeModifiermap* (
    modmap: XModifierKeymapPtr);
PROCEDURE XFreePixmap* (
    display: DisplayPtr;
    pixmap: Pixmap);
PROCEDURE XGeometry* (
    display: DisplayPtr;
    screen: C.int;
    position: ARRAY OF C.char;
    defaultposition: ARRAY OF C.char;
    bwidth: C.int;
    fwidth: C.int;
    fheight: C.int;
    xadder: C.int;
    yadder: C.int;
    VAR xreturn: C.int;
    VAR yreturn: C.int;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int): C.int;
PROCEDURE XGetErrorDatabaseText* (
    display: DisplayPtr;
    name: ARRAY OF C.char;
    message: ARRAY OF C.char;
    defaultstring: ARRAY OF C.char;
    VAR bufferreturn: ARRAY OF C.char;
    length: C.int);
PROCEDURE XGetErrorText* (
    display: DisplayPtr;
    code: C.int;
    VAR bufferreturn: ARRAY OF C.char;
    length: C.int);
PROCEDURE XGetFontProperty* (
    fontstruct: XFontStructPtr;
    atom: Atom;
    VAR valuereturn: C.longint): Bool;
PROCEDURE XGetGCValues* (
    display: DisplayPtr;
    gc: GC;
    valuemask: ulongmask;
    VAR valuesreturn: XGCValues): Status;
PROCEDURE XGetGeometry* (
    display: DisplayPtr;
    d: Drawable;
    VAR rootreturn: Window;
    VAR xreturn: C.int;
    VAR yreturn: C.int;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int;
    VAR borderwidthreturn: C.int;
    VAR depthreturn: C.int): Status;
PROCEDURE XGetIconName* (
    display: DisplayPtr;
    w: Window;
    VAR iconnamereturn: C.charPtr1d): Status;
PROCEDURE XGetInputFocus* (
    display: DisplayPtr;
    VAR focusreturn: Window;
    VAR reverttoreturn: C.int);
PROCEDURE XGetKeyboardControl* (
    display: DisplayPtr;
    VAR valuesreturn: XKeyboardState);
PROCEDURE XGetPointerControl* (
    display: DisplayPtr;
    VAR accelnumeratorreturn: C.int;
    VAR acceldenominatorreturn: C.int;
    VAR thresholdreturn: C.int);
PROCEDURE XGetPointerMapping* (
    display: DisplayPtr;
    VAR mapreturn: C.char;
    nmap: C.int): C.int;
PROCEDURE XGetScreenSaver* (
    display: DisplayPtr;
    VAR timeoutreturn: C.int;
    VAR intervalreturn: C.int;
    VAR preferblankingreturn: C.int;
    VAR allowexposuresreturn: C.int);
PROCEDURE XGetTransientForHint* (
    display: DisplayPtr;
    w: Window;
    VAR propwindowreturn: Window): Status;
PROCEDURE XGetWindowProperty* (
    display: DisplayPtr;
    w: Window;
    property: Atom;
    longoffset: C.longint;
    longlength: C.longint;
    delete: Bool;
    reqtype: Atom;
    VAR actualtypereturn: Atom;
    VAR actualformatreturn: C.int;
    VAR nitemsreturn: C.longint;
    VAR bytesafterreturn: C.longint;
    VAR propreturn: C.charPtr1d): C.int;
PROCEDURE XGetWindowAttributes* (
    display: DisplayPtr;
    w: Window;
    VAR windowattributesreturn: XWindowAttributes): Status;
PROCEDURE XGrabButton* (
    display: DisplayPtr;
    button: C.int;
    modifiers: C.int;
    grabwindow: Window;
    ownerevents: Bool;
    eventmask: uintmask;
    pointermode: C.int;
    keyboardmode: C.int;
    confineto: Window;
    cursor: Cursor);
PROCEDURE XGrabKey* (
    display: DisplayPtr;
    keycode: C.int;
    modifiers: C.int;
    grabwindow: Window;
    ownerevents: Bool;
    pointermode: C.int;
    keyboardmode: C.int);
PROCEDURE XGrabKeyboard* (
    display: DisplayPtr;
    grabwindow: Window;
    ownerevents: Bool;
    pointermode: C.int;
    keyboardmode: C.int;
    time: Time): C.int;
PROCEDURE XGrabPointer* (
    display: DisplayPtr;
    grabwindow: Window;
    ownerevents: Bool;
    eventmask: uintmask;
    pointermode: C.int;
    keyboardmode: C.int;
    confineto: Window;
    cursor: Cursor;
    time: Time): C.int;
PROCEDURE XGrabServer* (
    display: DisplayPtr);
PROCEDURE XHeightMMOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XHeightOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XIfEvent* (
    display: DisplayPtr;
    VAR eventreturn: XEvent;
    predicate: EventProc;
    arg: XPointer);
PROCEDURE XImageByteOrder* (
    display: DisplayPtr): C.int;
PROCEDURE XInstallColormap* (
    display: DisplayPtr;
    colormap: Colormap);
PROCEDURE XKeysymToKeycode* (
    display: DisplayPtr;
    keysym: KeySym): KeyCode;
PROCEDURE XKillClient* (
    display: DisplayPtr;
    resource: XID);
PROCEDURE XLookupColor* (
    display: DisplayPtr;
    colormap: Colormap;
    colorname: ARRAY OF C.char;
    VAR exactdefreturn: XColor;
    VAR screendefreturn: XColor): Status;
PROCEDURE XLowerWindow* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XMapRaised* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XMapSubwindows* (
    display: DisplayPtr;
    w: Window);
*)
PROCEDURE -XMapWindow* (
    display: DisplayPtr;
    w: Window)
    "XMapWindow((struct _XDisplay*)display, w)";

PROCEDURE -XMaskEvent* (
    display: DisplayPtr;
    mask: ulongmask;
    VAR event: XEvent)
    "XMaskEvent((struct _XDisplay*)display, mask, (union _XEvent*)event)";

(*
PROCEDURE XMaxCmapsOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XMinCmapsOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XMoveResizeWindow* (
    display: DisplayPtr;
    w: Window;
    x: C.int;
    y: C.int;
    width: C.int;
    height: C.int);
PROCEDURE XMoveWindow* (
    display: DisplayPtr;
    w: Window;
    x: C.int;
    y: C.int);
    *)
PROCEDURE -XNextEvent* (
    display: DisplayPtr;
    VAR event: XEvent)
    "XNextEvent((struct _XDisplay*)display, (union _XEvent*)event)";
(*
PROCEDURE XNoOp* (
    display: DisplayPtr);
PROCEDURE XParseColor* (
    display: DisplayPtr;
    colormap: Colormap;
    spec: ARRAY OF C.char;
    VAR exactdefreturn: XColor): Status;
PROCEDURE XParseGeometry* (
    parsestring: ARRAY OF C.char;
    VAR xreturn: C.int;
    VAR yreturn: C.int;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int): C.int;
PROCEDURE XPeekEvent* (
    display: DisplayPtr;
    VAR eventreturn: XEvent);
PROCEDURE XPeekIfEvent* (
    display: DisplayPtr;
    VAR eventreturn: XEvent;
    predicate: EventProc;
    arg: XPointer);
PROCEDURE XPending* (
    display: DisplayPtr): C.int;
PROCEDURE XPlanesOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XProtocolRevision* (
    display: DisplayPtr): C.int;
PROCEDURE XProtocolVersion* (
    display: DisplayPtr): C.int;
PROCEDURE XPutBackEvent* (
    display: DisplayPtr;
    event: XEventPtr);
*)
PROCEDURE -XPutImage* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    image: XImagePtr;
    srcX: C.int;
    srcY: C.int;
    dstX: C.int;
    dstY: C.int;
    width: C.int;
    height: C.int)
    "XPutImage((struct _XDisplay*)display, d, (struct _XGC*)gc, (struct _XImage*)image, srcX, srcY, dstX, dstY, width, height)";
(*
PROCEDURE XQLength* (
    display: DisplayPtr): C.int;
PROCEDURE XQueryBestCursor* (
    display: DisplayPtr;
    d: Drawable;
    width: C.int;
    height: C.int;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int): Status;
PROCEDURE XQueryBestSize* (
    display: DisplayPtr;
    class: C.int;
    whichscreen: Drawable;
    width: C.int;
    height: C.int;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int): Status;
PROCEDURE XQueryBestStipple* (
    display: DisplayPtr;
    whichscreen: Drawable;
    width: C.int;
    height: C.int;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int): Status;
PROCEDURE XQueryBestTile* (
    display: DisplayPtr;
    whichscreen: Drawable;
    width: C.int;
    height: C.int;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int): Status;
PROCEDURE XQueryColor* (
    display: DisplayPtr;
    colormap: Colormap;
    VAR definout: XColor);
PROCEDURE XQueryColors* (
    display: DisplayPtr;
    colormap: Colormap;
    VAR defsinout: ARRAY OF XColor;
    ncolors: C.int);
PROCEDURE XQueryExtension* (
    display: DisplayPtr;
    name: ARRAY OF C.char;
    VAR majorOpcodereturn: C.int;
    VAR firstEventreturn: C.int;
    VAR firstErrorreturn: C.int): Bool;
PROCEDURE XQueryKeymap* (
    display: DisplayPtr;
    VAR keysreturn: ARRAY (*32*) OF C.char);
PROCEDURE XQueryPointer* (
    display: DisplayPtr;
    w: Window;
    VAR rootreturn: Window;
    VAR childreturn: Window;
    VAR rootxreturn: C.int;
    VAR rootyreturn: C.int;
    VAR winxreturn: C.int;
    VAR winyreturn: C.int;
    VAR maskreturn: uintmask): Bool;
PROCEDURE XQueryTextExtents* (
    display: DisplayPtr;
    fontID: XID;
    string: ARRAY OF C.char;
    nchars: C.int;
    VAR directionreturn: C.int;
    VAR fontascentreturn: C.int;
    VAR fontdescentreturn: C.int;
    VAR overallreturn: XCharStruct);
PROCEDURE XQueryTextExtents16* (
    display: DisplayPtr;
    fontID: XID;
(*    string: ARRAY OF XChar2b;*)
    string: ARRAY OF LONGCHAR;
    nchars: C.int;
    VAR directionreturn: C.int;
    VAR fontascentreturn: C.int;
    VAR fontdescentreturn: C.int;
    VAR overallreturn: XCharStruct);
PROCEDURE XQueryTree* (
    display: DisplayPtr;
    w: Window;
    VAR rootreturn: Window;
    VAR parentreturn: Window;
    VAR childrenreturn: WindowPtr1d;
    VAR nchildrenreturn: C.int): Status;
PROCEDURE XRaiseWindow* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XReadBitmapFile* (
    display: DisplayPtr;
    d: Drawable;
    filename: ARRAY OF C.char;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int;
    VAR bitmapreturn: Pixmap;
    VAR xhotreturn: C.int;
    VAR yhotreturn: C.int): C.int;
PROCEDURE XReadBitmapFileData* (
    filename: ARRAY OF C.char;
    VAR widthreturn: C.int;
    VAR heightreturn: C.int;
    VAR datareturn: C.address;
    VAR xhotreturn: C.int;
    VAR yhotreturn: C.int): C.int;
PROCEDURE XRebindKeysym* (
    display: DisplayPtr;
    keysym: KeySym;
    list: ARRAY OF KeySym;
    modcount: C.int;
    string: ARRAY OF C.char;
    bytesstring: C.int);
PROCEDURE XRecolorCursor* (
    display: DisplayPtr;
    cursor: Cursor;
    VAR foregroundcolor: XColor;
    VAR backgroundcolor: XColor);
PROCEDURE XRefreshKeyboardMapping* (
    eventmap: XMappingEventPtr);
PROCEDURE XRemoveFromSaveSet* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XRemoveHost* (
    display: DisplayPtr;
    host: XHostAddressPtr);
PROCEDURE XRemoveHosts* (
    display: DisplayPtr;
    hosts: ARRAY OF XHostAddress;
    numhosts: C.int);
PROCEDURE XReparentWindow* (
    display: DisplayPtr;
    w: Window;
    parent: Window;
    x: C.int;
    y: C.int);
PROCEDURE XResetScreenSaver* (
    display: DisplayPtr);
PROCEDURE XResizeWindow* (
    display: DisplayPtr;
    w: Window;
    width: C.int;
    height: C.int);
PROCEDURE XRestackWindows* (
    display: DisplayPtr;
    windows: ARRAY OF Window;
    nwindows: C.int);
PROCEDURE XRotateBuffers* (
    display: DisplayPtr;
    rotate: C.int);
PROCEDURE XRotateWindowProperties* (
    display: DisplayPtr;
    w: Window;
    properties: ARRAY OF Atom;
    numprop: C.int;
    npositions: C.int);
PROCEDURE XScreenCount* (
    display: DisplayPtr): C.int;
*)
PROCEDURE -XSelectInput* (
    display: DisplayPtr;
    window: Window;
    eventMask: ulongmask)
   "XSelectInput((struct _XDisplay*)display, window, (long)eventMask)";    
(*
PROCEDURE XSendEvent* (
    display: DisplayPtr;
    w: Window;
    propagate: Bool;
    eventmask: ulongmask;
    eventsend: XEventPtr): Status;
PROCEDURE XSetAccessControl* (
    display: DisplayPtr;
    mode: C.int);
PROCEDURE XSetArcMode* (
    display: DisplayPtr;
    gc: GC;
    arcmode: C.int);
PROCEDURE XSetBackground* (
    display: DisplayPtr;
    gc: GC;
    background: C.longint);
PROCEDURE XSetClipMask* (
    display: DisplayPtr;
    gc: GC;
    pixmap: Pixmap);
PROCEDURE XSetClipOrigin* (
    display: DisplayPtr;
    gc: GC;
    clipxorigin: C.int;
    clipyorigin: C.int);
PROCEDURE XSetClipRectangles* (
    display: DisplayPtr;
    gc: GC;
    clipxorigin: C.int;
    clipyorigin: C.int;
    rectangles: XRectanglePtr;
    n: C.int;
    ordering: C.int);
PROCEDURE XSetCloseDownMode* (
    display: DisplayPtr;
    closemode: C.int);
PROCEDURE XSetCommand* (
    display: DisplayPtr;
    w: Window;
    argv: C.charPtr2d;
    argc: C.int);
PROCEDURE XSetDashes* (
    display: DisplayPtr;
    gc: GC;
    dashoffset: C.int;
    dashlist: ARRAY OF C.char;
    n: C.int);
PROCEDURE XSetFillRule* (
    display: DisplayPtr;
    gc: GC;
    fillrule: C.int);
PROCEDURE XSetFillStyle* (
    display: DisplayPtr;
    gc: GC;
    fillstyle: C.int);
PROCEDURE XSetFont* (
    display: DisplayPtr;
    gc: GC;
    font: Font);
PROCEDURE XSetFontPath* (
    display: DisplayPtr;
    directories: C.charPtr2d;
    ndirs: C.int);
PROCEDURE XSetForeground* (
    display: DisplayPtr;
    gc: GC;
    foreground: C.longint);
PROCEDURE XSetFunction* (
    display: DisplayPtr;
    gc: GC;
    function: C.int);
PROCEDURE XSetGraphicsExposures* (
    display: DisplayPtr;
    gc: GC;
    graphicsexposures: Bool);
PROCEDURE XSetIconName* (
    display: DisplayPtr;
    w: Window;
    iconname: ARRAY OF C.char);
PROCEDURE XSetInputFocus* (
    display: DisplayPtr;
    focus: Window;
    revertto: C.int;
    time: Time);
PROCEDURE XSetLineAttributes* (
    display: DisplayPtr;
    gc: GC;
    linewidth: C.int;
    linestyle: C.int;
    capstyle: C.int;
    joinstyle: C.int);
PROCEDURE XSetModifierMapping* (
    display: DisplayPtr;
    modmap: XModifierKeymapPtr): C.int;
PROCEDURE XSetPlaneMask* (
    display: DisplayPtr;
    gc: GC;
    planemask: ulongmask);
PROCEDURE XSetPointerMapping* (
    display: DisplayPtr;
    map: ARRAY OF C.char;
    nmap: C.int): C.int;
PROCEDURE XSetScreenSaver* (
    display: DisplayPtr;
    timeout: C.int;
    interval: C.int;
    preferblanking: C.int;
    allowexposures: C.int);
PROCEDURE XSetSelectionOwner* (
    display: DisplayPtr;
    selection: Atom;
    owner: Window;
    time: Time);
PROCEDURE XSetState* (
    display: DisplayPtr;
    gc: GC;
    foreground: C.longint;
    background: C.longint;
    function: C.int;
    planemask: ulongmask);
PROCEDURE XSetStipple* (
    display: DisplayPtr;
    gc: GC;
    stipple: Pixmap);
PROCEDURE XSetSubwindowMode* (
    display: DisplayPtr;
    gc: GC;
    subwindowmode: C.int);
PROCEDURE XSetTSOrigin* (
    display: DisplayPtr;
    gc: GC;
    tsxorigin: C.int;
    tsyorigin: C.int);
PROCEDURE XSetTile* (
    display: DisplayPtr;
    gc: GC;
    tile: Pixmap);
PROCEDURE XSetWindowBackground* (
    display: DisplayPtr;
    w: Window;
    backgroundpixel: C.longint);
PROCEDURE XSetWindowBackgroundPixmap* (
    display: DisplayPtr;
    w: Window;
    backgroundpixmap: Pixmap);
PROCEDURE XSetWindowBorder* (
    display: DisplayPtr;
    w: Window;
    borderpixel: C.longint);
PROCEDURE XSetWindowBorderPixmap* (
    display: DisplayPtr;
    w: Window;
    borderpixmap: Pixmap);
PROCEDURE XSetWindowBorderWidth* (
    display: DisplayPtr;
    w: Window;
    width: C.int);
PROCEDURE XSetWindowColormap* (
    display: DisplayPtr;
    w: Window;
    colormap: Colormap);
PROCEDURE XStoreBuffer* (
    display: DisplayPtr;
    bytes: ARRAY OF C.char;
    nbytes: C.int;
    buffer: C.int);
PROCEDURE XStoreBytes* (
    display: DisplayPtr;
    bytes: ARRAY OF C.char;
    nbytes: C.int);
PROCEDURE XStoreColor* (
    display: DisplayPtr;
    colormap: Colormap;
    VAR color: XColor);
PROCEDURE XStoreColors* (
    display: DisplayPtr;
    colormap: Colormap;
    color: ARRAY OF XColor;
    ncolors: C.int);
*)
PROCEDURE -XStoreName* (
    display: DisplayPtr;
    window: Window;
    name: ARRAY OF C.char)
    "XStoreName((struct _XDisplay*)display, window, (char*)name)";
(*
PROCEDURE XStoreNamedColor* (
    display: DisplayPtr;
    colormap: Colormap;
    color: ARRAY OF C.char;
    pixel: C.longint;
    flags: uintmask);
PROCEDURE XSync* (
    display: DisplayPtr;
    discard: Bool);
PROCEDURE XTextExtents* (
    fontstruct: XFontStructPtr;
    string: ARRAY OF C.char;
    nchars: C.int;
    VAR directionreturn: C.int;
    VAR fontascentreturn: C.int;
    VAR fontdescentreturn: C.int;
    VAR overallreturn: XCharStruct);
PROCEDURE XTextExtents16* (
    fontstruct: XFontStructPtr;
(*    string: ARRAY OF XChar2b;*)
    string: ARRAY OF LONGCHAR;
    nchars: C.int;
    VAR directionreturn: C.int;
    VAR fontascentreturn: C.int;
    VAR fontdescentreturn: C.int;
    VAR overallreturn: XCharStruct);
PROCEDURE XTextWidth* (
    fontstruct: XFontStructPtr;
    string: ARRAY OF C.char;
    count: C.int): C.int;
PROCEDURE XTextWidth16* (
    fontstruct: XFontStructPtr;
(*    string: ARRAY OF XChar2b;*)
    string: ARRAY OF LONGCHAR;
    count: C.int): C.int;
PROCEDURE XTranslateCoordinates* (
    display: DisplayPtr;
    srcw: Window;
    destw: Window;
    srcx: C.int;
    srcy: C.int;
    VAR destxreturn: C.int;
    VAR destyreturn: C.int;
    VAR childreturn: Window): Bool;
PROCEDURE XUndefineCursor* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XUngrabButton* (
    display: DisplayPtr;
    button: C.int;
    modifiers: C.int;
    grabwindow: Window);
PROCEDURE XUngrabKey* (
    display: DisplayPtr;
    keycode: C.int;
    modifiers: C.int;
    grabwindow: Window);
PROCEDURE XUngrabKeyboard* (
    display: DisplayPtr;
    time: Time);
PROCEDURE XUngrabPointer* (
    display: DisplayPtr;
    time: Time);
PROCEDURE XUngrabServer* (
    display: DisplayPtr);
PROCEDURE XUninstallColormap* (
    display: DisplayPtr;
    colormap: Colormap);
PROCEDURE XUnloadFont* (
    display: DisplayPtr;
    font: Font);
PROCEDURE XUnmapSubwindows* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XUnmapWindow* (
    display: DisplayPtr;
    w: Window);
PROCEDURE XVendorRelease* (
    display: DisplayPtr): C.int;
PROCEDURE XWarpPointer* (
    display: DisplayPtr;
    srcw: Window;
    destw: Window;
    srcx: C.int;
    srcy: C.int;
    srcwidth: C.int;
    srcheight: C.int;
    destx: C.int;
    desty: C.int);
PROCEDURE XWidthMMOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XWidthOfScreen* (
    screen: ScreenPtr): C.int;
PROCEDURE XWindowEvent* (
    display: DisplayPtr;
    w: Window;
    eventmask: ulongmask;
    VAR eventreturn: XEvent);
PROCEDURE XWriteBitmapFile* (
    display: DisplayPtr;
    filename: ARRAY OF C.char;
    bitmap: Pixmap;
    width: C.int;
    height: C.int;
    xhot: C.int;
    yhot: C.int): C.int;
PROCEDURE XSupportsLocale* (): Bool;
PROCEDURE XSetLocaleModifiers* (
    modifierlist: ARRAY OF C.char): C.charPtr1d;
PROCEDURE XOpenOM* (
    display: DisplayPtr;
    rdb: XrmHashBucketRecPtr;
    resname: ARRAY OF C.char;
    resclass: ARRAY OF C.char): XOM;
PROCEDURE XCloseOM* (
    om: XOM): Status;
PROCEDURE XSetOMValues* (
    om: XOM;
    ...): C.charPtr1d;
PROCEDURE XGetOMValues* (
    om: XOM;
    ...): C.charPtr1d;
PROCEDURE XDisplayOfOM* (
    om: XOM): DisplayPtr;
PROCEDURE XLocaleOfOM* (
    om: XOM): C.charPtr1d;
PROCEDURE XCreateOC* (
    om: XOM;
    ...): XOC;
PROCEDURE XDestroyOC* (
    oc: XOC);
PROCEDURE XOMOfOC* (
    oc: XOC): XOM;
PROCEDURE XSetOCValues* (
    oc: XOC;
    ...): C.charPtr1d;
PROCEDURE XGetOCValues* (
    oc: XOC;
    ...): C.charPtr1d;
PROCEDURE XCreateFontSet* (
    display: DisplayPtr;
    basefontnamelist: ARRAY OF C.char;
    VAR missingcharsetlist: C.charPtr2d;
    VAR missingcharsetcount: C.int;
    VAR defstring: C.charPtr1d): XFontSet;
PROCEDURE XFreeFontSet* (
    display: DisplayPtr;
    fontset: XFontSet);
PROCEDURE XFontsOfFontSet* (
    fontset: XFontSet;
    VAR fontstructlist: XFontStructPtr1d;
    VAR fontnamelist: C.charPtr2d): C.int;
PROCEDURE XBaseFontNameListOfFontSet* (
    fontset: XFontSet): C.charPtr1d;
PROCEDURE XLocaleOfFontSet* (
    fontset: XFontSet): C.charPtr1d;
PROCEDURE XContextDependentDrawing* (
    fontset: XFontSet): Bool;
PROCEDURE XDirectionalDependentDrawing* (
    fontset: XFontSet): Bool;
PROCEDURE XContextualDrawing* (
    fontset: XFontSet): Bool;
PROCEDURE XExtentsOfFontSet* (
    fontset: XFontSet): XFontSetExtentsPtr;
PROCEDURE XmbTextEscapement* (
    fontset: XFontSet;
    text: ARRAY OF C.char;
    bytestext: C.int): C.int;
PROCEDURE XwcTextEscapement* (
    fontset: XFontSet;
    text: ARRAY OF wchart;
    numwchars: C.int): C.int;
PROCEDURE XmbTextExtents* (
    fontset: XFontSet;
    text: ARRAY OF C.char;
    bytestext: C.int;
    VAR overallinkreturn: XRectangle;
    VAR overalllogicalreturn: XRectangle): C.int;
PROCEDURE XwcTextExtents* (
    fontset: XFontSet;
    text: ARRAY OF wchart;
    numwchars: C.int;
    VAR overallinkreturn: XRectangle;
    VAR overalllogicalreturn: XRectangle): C.int;
PROCEDURE XmbTextPerCharExtents* (
    fontset: XFontSet;
    text: ARRAY OF C.char;
    bytestext: C.int;
    inkextentsbuffer: ARRAY OF XRectangle;
    logicalextentsbuffer: ARRAY OF XRectangle;
    buffersize: C.int;
    VAR numchars: C.int;
    VAR overallinkreturn: XRectangle;
    VAR overalllogicalreturn: XRectangle): Status;
PROCEDURE XwcTextPerCharExtents* (
    fontset: XFontSet;
    text: ARRAY OF wchart;
    numwchars: C.int;
    inkextentsbuffer: ARRAY OF XRectangle;
    logicalextentsbuffer: ARRAY OF XRectangle;
    buffersize: C.int;
    VAR numchars: C.int;
    VAR overallinkreturn: XRectangle;
    VAR overalllogicalreturn: XRectangle): Status;
PROCEDURE XmbDrawText* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    textitems: ARRAY OF XmbTextItem;
    nitems: C.int);
PROCEDURE XwcDrawText* (
    display: DisplayPtr;
    d: Drawable;
    gc: GC;
    x: C.int;
    y: C.int;
    textitems: ARRAY OF XwcTextItem;
    nitems: C.int);
PROCEDURE XmbDrawString* (
    display: DisplayPtr;
    d: Drawable;
    fontset: XFontSet;
    gc: GC;
    x: C.int;
    y: C.int;
    text: ARRAY OF C.char;
    bytestext: C.int);
PROCEDURE XwcDrawString* (
    display: DisplayPtr;
    d: Drawable;
    fontset: XFontSet;
    gc: GC;
    x: C.int;
    y: C.int;
    text: ARRAY OF wchart;
    numwchars: C.int);
PROCEDURE XmbDrawImageString* (
    display: DisplayPtr;
    d: Drawable;
    fontset: XFontSet;
    gc: GC;
    x: C.int;
    y: C.int;
    text: ARRAY OF C.char;
    bytestext: C.int);
PROCEDURE XwcDrawImageString* (
    display: DisplayPtr;
    d: Drawable;
    fontset: XFontSet;
    gc: GC;
    x: C.int;
    y: C.int;
    text: ARRAY OF wchart;
    numwchars: C.int);
PROCEDURE XOpenIM* (
    dpy: DisplayPtr;
    rdb: XrmHashBucketRecPtr;
    resname: ARRAY OF C.char;
    resclass: ARRAY OF C.char): XIM;
PROCEDURE XCloseIM* (
    im: XIM): Status;
PROCEDURE XGetIMValues* (
    im: XIM;
    ...): C.charPtr1d;
PROCEDURE XDisplayOfIM* (
    im: XIM): DisplayPtr;
PROCEDURE XLocaleOfIM* (
    im: XIM): C.charPtr1d;
PROCEDURE XCreateIC* (
    im: XIM;
    ...): XIC;
PROCEDURE XDestroyIC* (
    ic: XIC);
PROCEDURE XSetICFocus* (
    ic: XIC);
PROCEDURE XUnsetICFocus* (
    ic: XIC);
PROCEDURE XwcResetIC* (
    ic: XIC): C.charPtr1d;
PROCEDURE XmbResetIC* (
    ic: XIC): C.charPtr1d;
PROCEDURE XSetICValues* (
    ic: XIC;
    ...): C.charPtr1d;
PROCEDURE XGetICValues* (
    ic: XIC;
    ...): C.charPtr1d;
PROCEDURE XIMOfIC* (
    ic: XIC): XIM;
PROCEDURE XFilterEvent* (
    event: XEventPtr;
    window: Window): Bool;
PROCEDURE XmbLookupString* (
    ic: XIC;
    VAR event: XKeyPressedEvent;
    VAR bufferreturn: ARRAY OF C.char;
    bytesbuffer: C.int;
    VAR keysymreturn: KeySym;
    VAR statusreturn: Status): C.int;
PROCEDURE XwcLookupString* (
    ic: XIC;
    VAR event: XKeyPressedEvent;
    VAR bufferreturn: wchart;
    wcharsbuffer: C.int;
    VAR keysymreturn: KeySym;
    VAR statusreturn: Status): C.int;
PROCEDURE XVaCreateNestedList* (
    unused: C.int;
    ...): XVaNestedList;


(* internal connections for IMs *)
PROCEDURE XRegisterIMInstantiateCallback* (
    dpy: DisplayPtr;
    rdb: XrmHashBucketRecPtr;
    resname: C.charPtr1d;
    resclass: C.charPtr1d;
    callback: XIMProc;
    clientdata: ARRAY OF XPointer): Bool;
PROCEDURE XUnregisterIMInstantiateCallback* (
    dpy: DisplayPtr;
    rdb: XrmHashBucketRecPtr;
    resname: C.charPtr1d;
    resclass: C.charPtr1d;
    callback: XIMProc;
    clientdata: ARRAY OF XPointer): Bool;
PROCEDURE XInternalConnectionNumbers* (
    dpy: DisplayPtr;
    VAR fdreturn: C.intPtr1d;
    VAR countreturn: C.int): Status;
PROCEDURE XProcessInternalConnection* (
    dpy: DisplayPtr;
    fd: C.int);
PROCEDURE XAddConnectionWatch* (
    dpy: DisplayPtr;
    callback: XConnectionWatchProc;
    clientdata: XPointer): Status;
PROCEDURE XRemoveConnectionWatch* (
    dpy: DisplayPtr;
    callback: XConnectionWatchProc;
    clientdata: XPointer);
*)
END oocX11.
