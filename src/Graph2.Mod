MODULE Graph2;
IMPORT Out, Al := Allegro5, Utf8, Files, Strings, SYSTEM;

CONST
  fontPlanes = 4; (*!TODO*)

  (* Settings set members *)
  manual*      = 0;
  fullscreen*  = 1;
  window*      = 2;
  exact*       = 3;
  smooth*      = 4;
  software*    = 5;
  initMouse*   = 6;
  center*      = 7;
  resizable*   = 8;
  maximized*   = 9;
  minimized*   = 10;
  frameless*   = 11;
  nobuffer*    = 12;
  topleft*     = 13;

  (* Event.type possible values *)
  quit*        = 1;
  timer*       = 2;
  windowEvent* = 3;
  keyDown*     = 4;
  keyUp*       = 5;
  char*        = 6;
  mouseMove*   = 7;
  mouseDown*   = 8;
  mouseUp*     = 9;
  mouseWheel*  = 10;
  resize*      = 11;

  (* Window.zoom possible values *)
  noZoom   = 0; (* The screen is not zoomed *)
  intZoom  = 1; (* The zoom value is an integer: 2x, 3x etc. *)
  realZoom = 2; (* The zoom value is not an integer, i.e. 2.5x *)

  (* Flip flags *)
  flipHor*  = 1;
  flipVert* = 2;

  (* Key Codes *)
  kA*          = 1;
  kB*          = 2;
  kC*          = 3;
  kD*          = 4;
  kE*          = 5;
  kF*          = 6;
  kG*          = 7;
  kH*          = 8;
  kI*          = 9;
  kJ*          = 10;
  kK*          = 11;
  kL*          = 12;
  kM*          = 13;
  kN*          = 14;
  kO*          = 15;
  kP*          = 16;
  kQ*          = 17;
  kR*          = 18;
  kS*          = 19;
  kT*          = 20;
  kU*          = 21;
  kV*          = 22;
  kW*          = 23;
  kX*          = 24;
  kY*          = 25;
  kZ*          = 26;
  k0*          = 27;
  k1*          = 28;
  k2*          = 29;
  k3*          = 30;
  k4*          = 31;
  k5*          = 32;
  k6*          = 33;
  k7*          = 34;
  k8*          = 35;
  k9*          = 36;
  k0Pad*       = 37;
  k1Pad*       = 38;
  k2Pad*       = 39;
  k3Pad*       = 40;
  k4Pad*       = 41;
  k5Pad*       = 42;
  k6Pad*       = 43;
  k7Pad*       = 44;
  k8Pad*       = 45;
  k9Pad*       = 46;
  kF1*         = 47;
  kF2*         = 48;
  kF3*         = 49;
  kF4*         = 50;
  kF5*         = 51;
  kF6*         = 52;
  kF7*         = 53;
  kF8*         = 54;
  kF9*         = 55;
  kF10*        = 56;
  kF11*        = 57;
  kF12*        = 58;
  kEsc*        = 59;
  kTilde*      = 60;
  kMinus*      = 61;
  kEquals*     = 62;
  kBackspace*  = 63;
  kTab*        = 64;
  kOpenBrace*  = 65;
  kCloseBrace* = 66;
  kEnter*      = 67;
  kColon*      = 68;
  kQuote*      = 69;
  kBackslash*  = 70;
  kBackslash2* = 71;
  kComma*      = 72;
  kStop*       = 73;
  kSlash*      = 74;
  kSpace*      = 75;
  kInsert*     = 76;
  kDel*        = 77;
  kHome*       = 78;
  kEnd*        = 79;
  kPgUp*       = 80;
  kPgDn*       = 81;
  kLeft*       = 82;
  kRight*      = 83;
  kUp*         = 84;
  kDown*       = 85;
  kSlashPad*   = 86;
  kAsterisk*   = 87;
  kMinusPad*   = 88;
  kPlusPad*    = 89;
  kDelPad*     = 90;
  kEnterPad*   = 91;
  kPrtScr*     = 92;
  kPause*      = 93;
  kEqualsPad*  = 103;
  kBackquote*  = 104;
  kSemicolon2* = 105;
  kCommand*    = 106;

  kBack*       = 107;
  kVolumeUp*   = 108;
  kVolumeDown* = 109;

  kModifers*   = 215;

  kLShift*     = 215;
  kRShift*     = 216;
  kLCtrl*      = 217;
  kRCtrl*      = 218;
  kAlt*        = 219;
  kAltGr*      = 220;
  kLMeta*      = 221;
  kRMeta*      = 222;
  kMenu*       = 223;
  kScrLock*    = 224;
  kNumLock*    = 225;
  kCapsLock*   = 226;

  kMax*        = 226;

  (* Modifiers Set *)
  mLShift*   = 0;
  mRShift*   = 1;
  mLCtrl*    = 6;
  mRCtrl*    = 7;
  mLAlt*     = 8;
  mRAlt*     = 9;
  mLMeta*    = 10;
  mRMeta*    = 11;
  mNumLock*  = 12;
  mCapsLock* = 13;
  mMenu*     = 14;
  mCommand*  = 29;
  mScrLock*  = 30;
  mCtrl*  = {mLCtrl, mRCtrl};
  mShift* = {mLShift, mRShift};
  mAlt*   = {mLAlt, mRAlt};
  mMeta*   = {mLMeta, mRMeta};

TYPE
  ADRINT = SYSTEM.ADRINT;
  REAL = SYSTEM.REAL64;
  SHORTREAL = SYSTEM.REAL32;
  LONGINT = SYSTEM.INT64;
  SHORTCHAR = SYSTEM.CHAR8;

  Color* = RECORD
    r, g, b, a: SHORTREAL
  END;

  Transform* = RECORD
    m: ARRAY 4, 4 OF REAL
  END;

  Timer* = POINTER TO TimerDesc;
  TimerDesc* = RECORD
    tmr: Al.Timer
  END;

  Bitmap* = POINTER TO BitmapDesc;
  BitmapDesc* = RECORD
    bmp: Al.Bitmap;
    w*, h*: INTEGER
  END;

  Window* = POINTER TO WindowDesc;
  WindowDesc* = RECORD(BitmapDesc)
    display: Al.Display;
    winW, winH: INTEGER; (* Window size in real pixels *)
    initX, initY: INTEGER; (* Window position upon its creation *)
    initW, initH: INTEGER; (* Window size upon its creation *)
    fsW, fsH: INTEGER; (* Window size upon its creation *)
    wantZoom: REAL; (* Window zoom upon its creation *)
    lastX, lastY: INTEGER; (* Last mouse position in virtual pixels *)
    lastW, lastH: INTEGER; (* Last stepped size in virtual pixels *)
    zoom: INTEGER; (* See constants above; based on this rzoom/izoom is used *)
    izoom: INTEGER; (* Window.izoom is used if Window.zoom = intZoom  *)
    rzoom: REAL;    (* Window.rzoom is used if Window.zoom = realZoom *)
    scaleOn: BOOLEAN; (* If TRUE, scaleX and scaleY are used *)
    scaleX, scaleY: REAL; (* Deforms pixels on Flip, but zoom is for drawing *)
    sizeStepX, sizeStepY: INTEGER;
    flipX, flipY, flipW, flipH: REAL; (* Where to flip the window bitmap to *)
    iFlipX, iFlipY: INTEGER; (* Same as flipX, flipY, which are always whole *)
    options: SET;
    title: ARRAY 256 OF CHAR;
    resized: BOOLEAN; (* TRUE if fullscreen mode has been toggled for window *)
    next: Window (* See windowList below *)
  END;

  Event* = RECORD
    type*: INTEGER;
    time*: REAL;
    x*, y*, z*, w*, h*: INTEGER;
    dx*, dy*, dz*, dw*: INTEGER;
    button*: INTEGER;
    buttons*: SET; (* What mouse buttons are pressed *)
    down*: BOOLEAN;
    count*: LONGINT; (* Timer counter *)
    key*: INTEGER; (* Physical key code *)
    ch*: CHAR; (* Typed character for event.type = char *)
    mod*: SET; (* Key modifiers *)
    repeat*: BOOLEAN;
    window*: Window;
    display: Al.Display;
    source: ADRINT
  END;

  FontMessage* = POINTER TO FontMessageDesc;
  FontMessageDesc* = RECORD

  END;

  FontDrawMsg* = POINTER TO FontDrawMsgDesc;
  FontDrawMsgDesc* = RECORD(FontMessage)

  END;

  Font* = POINTER TO FontDesc;
  FontDesc* = RECORD
    handle: PROCEDURE (font: Font; VAR msg: FontMessage);
    draw: PROCEDURE (font: Font; VAR msg: FontDrawMsg)
  END;

  MonoFont* = POINTER TO MonoFontDesc;
  MonoFontDesc* = RECORD(FontDesc)
    bmp: Bitmap;
    charW, charH: INTEGER;
    rows, cols: INTEGER
  END;

VAR
  Done*: BOOLEAN;

  settings: SET; (* See list of constants Settings above *)
  wantW, wantH: INTEGER; (* Assigned in procedure Settings *)
  wantZoom: REAL; (* Assigned in procedure SetZoom *)
  wantSizeStepX, wantSizeStepY: INTEGER; (* Assigned in SetSizeStep *)
  wantScaleX, wantScaleY: REAL; (* Assigned in procedure SetScale *)
  wantTitle: ARRAY 256 OF CHAR; (* Assigned in procedure SetTitle *)
  queue: Al.EventQueue;
  windowList: Window;
  screen: Window;
  target: Bitmap;
  black: Color;
  anyWindowResized: BOOLEAN;

  (* Keyboard modifier keys *)
  keyModMap: ARRAY 256 OF INTEGER;
  keyMods: SET;

PROCEDURE InitKeyMod;
VAR i: INTEGER;
BEGIN keyMods := {};
  FOR i := 0 TO LEN(keyModMap) - 1 DO keyModMap[i] := -1 END;
  keyModMap[kLShift] := mLShift; keyModMap[kRShift] := mRShift;
  keyModMap[kLCtrl] := mLCtrl; keyModMap[kRCtrl] := mRCtrl;
  keyModMap[kAlt] := mLAlt; keyModMap[kAltGr] := mRAlt;
  keyModMap[kLMeta] := mLMeta; keyModMap[kRMeta] := mRMeta;
  keyModMap[kNumLock] := mNumLock; keyModMap[kCapsLock] := mCapsLock;
  keyModMap[kScrLock] := mScrLock; keyModMap[kCommand] := mCommand;
  keyModMap[kMenu] := mMenu
END InitKeyMod;

PROCEDURE SetKeyMod(key: INTEGER; on: BOOLEAN);
BEGIN
  IF key < LEN(keyModMap) THEN
    key := keyModMap[key];
    IF key >= 0 THEN
      IF on THEN INCL(keyMods, key) ELSE EXCL(keyMods, key) END
    END
  END
END SetKeyMod;

PROCEDURE Error(s: ARRAY OF CHAR);
BEGIN Out.String(s); Out.Ln
END Error;

PROCEDURE GetDesktopResolution*(VAR w, h: INTEGER);
VAR info: Al.MonitorInfo;
BEGIN
  IF Al.get_monitor_info(0, info) THEN
    w := info.x2 - info.x1;
    h := info.y2 - info.y1
  ELSE w := -1; h := -1
  END
END GetDesktopResolution;

PROCEDURE GetScreen*(): Window;
RETURN screen END GetScreen;

PROCEDURE GetScreenSize*(VAR width, height: INTEGER);
BEGIN
  IF screen # NIL THEN width := screen.w; height := screen.h
  ELSE width := 0; height := 0
  END
END GetScreenSize;

PROCEDURE Settings*(w, h: INTEGER; flags: SET);
BEGIN wantW := w; wantH := h; settings := flags
END Settings;

PROCEDURE SetSizeStep*(w, h: INTEGER);
BEGIN wantSizeStepX := w; wantSizeStepY := h
END SetSizeStep;

PROCEDURE ApplySizeStep(W: Window; VAR w, h: INTEGER);
BEGIN
  IF W.sizeStepX # 1 THEN
    w := w DIV W.sizeStepX * W.sizeStepX;
    IF w < W.sizeStepX THEN w := W.sizeStepX END
  END;
  IF W.sizeStepY # 1 THEN
    h := h DIV W.sizeStepY * W.sizeStepY;
    IF h < W.sizeStepY THEN h := W.sizeStepY END
  END
END ApplySizeStep;

PROCEDURE GetTarget*(): Bitmap;
RETURN target END GetTarget;

PROCEDURE GetTargetSize*(VAR width, height: INTEGER);
BEGIN
  IF target # NIL THEN width := target.w; height := target.h
  ELSE width := 0; height := 0
  END
END GetTargetSize;

PROCEDURE Target*(bitmap: Bitmap);
VAR T: Al.Transform;
  W: Window;
BEGIN target := bitmap;
  IF bitmap # NIL THEN
    IF (bitmap IS Window) & (bitmap.bmp = NIL) THEN W := bitmap(Window);
      Al.set_target_backbuffer(W.display);
      Al.build_transform(T, W.flipX, W.flipY, W.scaleX, W.scaleY, 0.0);
      Al.use_transform(T)
    ELSE Al.set_target_bitmap(SYSTEM.VAL(Al.Bitmap, bitmap.bmp))
    END
  END
END Target;

PROCEDURE TargetScreen*;
BEGIN
  IF screen # NIL THEN Target(screen)
  ELSIF windowList # NIL THEN Target(windowList)
  ELSE Target(NIL)
  END
END TargetScreen;

PROCEDURE ResetFlipVars(W: Window);
VAR w, h: INTEGER;
BEGIN
  IF W.zoom = intZoom THEN
    w := W.w * W.izoom; h := W.h * W.izoom;
    IF W.scaleOn THEN
      W.flipW := FLT(FLOOR(FLT(w) * W.scaleX + 0.9));
      W.flipH := FLT(FLOOR(FLT(h) * W.scaleY + 0.9));
      W.iFlipX := (W.winW - FLOOR(W.flipW + 0.1)) DIV 2;
      W.iFlipY := (W.winH - FLOOR(W.flipH + 0.1)) DIV 2
    ELSE W.flipW := FLT(w); W.flipH := FLT(h);
      W.iFlipX := (W.winW - w) DIV 2; W.iFlipY := (W.winH - h) DIV 2
    END
  ELSE
    W.flipW := FLT(FLOOR(W.w * W.rzoom * W.scaleX + 0.9));
    W.flipH := FLT(FLOOR(W.h * W.rzoom * W.scaleY + 0.9));
    W.iFlipX := (W.winW - FLOOR(W.flipW + 0.1)) DIV 2;
    W.iFlipY := (W.winH - FLOOR(W.flipH + 0.1)) DIV 2
  END;
  IF topleft IN W.options THEN W.iFlipX := 0; W.iFlipY := 0 END;
  W.flipX := FLT(W.iFlipX); W.flipY := FLT(W.iFlipY);
  IF ~(exact IN W.options) & (smooth IN W.options) &
     ~(topleft IN W.options) & (W.winW - W.flipX - W.flipW < W.rzoom) &
     (W.winH - W.flipY - W.flipH < W.rzoom) THEN
    W.iFlipX := 0; W.iFlipY := 0; W.flipX := 0.0; W.flipY := 0.0;
    W.flipW := FLT(W.winW); W.flipH := FLT(W.winH)
  END
END ResetFlipVars;

PROCEDURE ResetWindowBitmap(W: Window);
VAR opt: SET;
  w, h, bw, bh: INTEGER;
  fw, fh: REAL;
  scaled, wasTarget: BOOLEAN;
BEGIN scaled := FALSE;
  IF W.bmp = NIL THEN bw := -1
  ELSE bw := Al.get_bitmap_width(W.bmp); bh := Al.get_bitmap_height(W.bmp)
  END;
  IF ~(exact IN W.options) THEN
    IF W.zoom = noZoom THEN w := W.winW; h := W.winH
    ELSIF (W.zoom = intZoom) & ~W.scaleOn THEN
      w := W.winW DIV W.izoom; h := W.winH DIV W.izoom
    ELSE scaled := TRUE;
      w := FLOOR(W.winW / W.rzoom / W.scaleX + 0.1);
      h := FLOOR(W.winH / W.rzoom / W.scaleY + 0.1)
    END
  ELSE w := W.w; h := W.h
  END;
  IF W.scaleOn & ~scaled THEN
    w := FLOOR(w / W.scaleX + 0.1); h := FLOOR(h / W.scaleY + 0.1)
  END;

  ApplySizeStep(W, w, h);
  IF (w > bw) OR (h > bh) OR (W.zoom = noZoom) THEN
    IF W.bmp # NIL THEN
      wasTarget := Al.get_target_bitmap() = W.bmp;
      Al.destroy_bitmap(W.bmp)
    END;
    IF (W.zoom = noZoom) & (nobuffer IN W.options) THEN
      W.bmp := NIL;
      IF wasTarget THEN Target(NIL) END
    ELSE
      IF smooth IN W.options THEN opt := {Al.minLinear, Al.magLinear}
      ELSE opt := {}
      END;
      Al.set_new_bitmap_flags(opt);
      W.bmp := Al.create_bitmap(w, h);
      IF wasTarget THEN Target(W) END
    END
  END;
  W.w := w; W.h := h;
  ResetFlipVars(W)
END ResetWindowBitmap;

PROCEDURE GetWindowOptions*(W: Window): SET;
RETURN W.options END GetWindowOptions;

PROCEDURE GetWindowZoom*(W: Window): REAL;
RETURN W.rzoom END GetWindowZoom;

PROCEDURE SetWindowZoomF*(W: Window; zoom: REAL);
BEGIN W.rzoom := zoom;
  IF zoom = 1.0 THEN W.zoom := noZoom
  ELSIF FLOOR(zoom + 0.001) * 100 = FLOOR(zoom * 100 + 0.001) THEN
    W.zoom := intZoom; W.izoom := FLOOR(zoom + 0.001)
  ELSE W.zoom := realZoom
  END;
  ResetWindowBitmap(W)
END SetWindowZoomF;

PROCEDURE SetWindowZoom*(W: Window; zoom: INTEGER);
BEGIN W.rzoom := FLT(zoom);
  IF zoom = 1 THEN W.zoom := noZoom
  ELSE W.zoom := intZoom; W.izoom := zoom
  END;
  ResetWindowBitmap(W)
END SetWindowZoom;

PROCEDURE SetNewWindowZoomF*(zoom: REAL);
BEGIN wantZoom := zoom
END SetNewWindowZoomF;

PROCEDURE SetZoomF*(zoom: REAL);
BEGIN wantZoom := zoom;
  IF screen # NIL THEN SetWindowZoomF(screen, zoom) END
END SetZoomF;

PROCEDURE SetNewWindowZoom*(zoom: INTEGER);
BEGIN wantZoom := FLT(zoom)
END SetNewWindowZoom;

PROCEDURE SetZoom*(zoom: INTEGER);
BEGIN wantZoom := FLT(zoom);
  IF screen # NIL THEN SetWindowZoom(screen, zoom) END
END SetZoom;

PROCEDURE SetWindowFullscreenSize*(win: Window; width, height: INTEGER);
BEGIN win.fsW := width; win.fsH := height
END SetWindowFullscreenSize;

PROCEDURE ApplyScale*(W: Window);
VAR t: Al.Transform;
BEGIN
  (*Target(W);
  Al.build_transform(t, 0.0, 0.0, 6.0, 6.0, 0.0);
  Al.use_transform(t)*)
END ApplyScale;

PROCEDURE SetWindowOption*(W: Window; key: INTEGER; on: BOOLEAN);
BEGIN IF on THEN INCL(W.options, key) ELSE EXCL(W.options, key) END
END SetWindowOption;

PROCEDURE SetWindowScale*(W: Window; x, y: REAL);
BEGIN W.scaleOn := (x # 1.0) OR (y # 1.0);
  W.scaleX := x; W.scaleY := y; ApplyScale(W)
END SetWindowScale;

PROCEDURE SetNewWindowScale*(x, y: REAL);
BEGIN wantScaleX := x; wantScaleY := y
END SetNewWindowScale;

PROCEDURE SetScale*(x, y: REAL);
BEGIN wantScaleX := x; wantScaleY := y;
  IF screen # NIL THEN SetWindowScale(screen, x, y) END
END SetScale;

PROCEDURE SetWindowTitle*(W: Window; title: ARRAY OF CHAR);
VAR q: ARRAY 256 OF SHORTCHAR;
BEGIN Utf8.Encode(title, q); Al.set_window_title(W.display, q)
END SetWindowTitle;

PROCEDURE SetNewWindowTitle*(title: ARRAY OF CHAR);
BEGIN wantTitle := title
END SetNewWindowTitle;

PROCEDURE SetTitle*(title: ARRAY OF CHAR);
BEGIN wantTitle := title;
  IF screen # NIL THEN SetWindowTitle(screen, title) END
END SetTitle;

(*PROCEDURE ClearBitmap*(bmp: Bitmap);
PROCEDURE ClearScreenToColor*(color: INTEGER);*)

PROCEDURE LoadBitmap*(fname: ARRAY OF CHAR): Bitmap;
VAR B: Bitmap;
  q: ARRAY 2048 OF SHORTCHAR;
BEGIN NEW(B); Utf8.Encode(fname, q); B.bmp := Al.load_bitmap(q);
  IF B.bmp = NIL THEN B := NIL
  ELSE B.w := Al.get_bitmap_width(B.bmp); B.h := Al.get_bitmap_height(B.bmp)
  END
RETURN B END LoadBitmap;

PROCEDURE Flip*;
VAR tmp: Al.Bitmap;
  W: Window;
  T: Al.Transform;
  x, y, w, h: REAL;
BEGIN
  IF ((target = NIL) OR ~(target IS Window)) & (screen # NIL) THEN
    Target(screen)
  END;
  IF (target # NIL) & (target IS Window) THEN
    W := target(Window);
    tmp := Al.get_target_bitmap();
    Al.set_target_backbuffer(W.display);
    Al.identity_transform(T);
    Al.use_transform(T);
    IF target.bmp # NIL THEN
      Al.clear_to_color(SYSTEM.VAL(Al.Color, black));
      Al.draw_scaled_bitmap(W.bmp, 0.0, 0.0, FLT(W.w), FLT(W.h),
        W.flipX, W.flipY, W.flipW, W.flipH, {})
    ELSE w := FLT(W.winW); h := FLT(W.winH);
      x := FLT(FLOOR(W.flipX + W.flipW + 0.1));
      y := FLT(FLOOR(W.flipY + W.flipH + 0.1));
      Al.draw_filled_rectangle(0.0, 0.0, w, W.flipY,
        SYSTEM.VAL(Al.Color, black));
      Al.draw_filled_rectangle(0.0, y, w, h, SYSTEM.VAL(Al.Color, black));
      Al.draw_filled_rectangle(0.0, W.flipY, W.flipX, y,
        SYSTEM.VAL(Al.Color, black));
      Al.draw_filled_rectangle(x, W.flipY, w, y, SYSTEM.VAL(Al.Color, black))
    END;
    Al.flip_display();
    Al.set_target_bitmap(tmp)
  END
END Flip;

PROCEDURE PutPixel2*(x, y: INTEGER; c: Color);
BEGIN Al.draw_filled_rectangle(FLT(x), FLT(y), FLT(x + 1), FLT(y + 1),
  SYSTEM.VAL(Al.Color, c))
END PutPixel2;

PROCEDURE PutPixel*(x, y: INTEGER; c: Color);
BEGIN Al.draw_pixel(FLT(x) + 0.5, FLT(y) + 0.5, SYSTEM.VAL(Al.Color, c))
END PutPixel;

PROCEDURE MakeCol*(VAR color: Color; r, g, b: INTEGER);
BEGIN color.r := r / 255; color.g := g / 255;
  color.b := b / 255; color.a := 1.0
END MakeCol;

PROCEDURE ColorToRGB*(color: Color; VAR r, g, b: INTEGER);
BEGIN r := FLOOR(color.r * 255 + 0.1) MOD 256;
  g := FLOOR(color.g * 255 + 0.1) MOD 256;
  b := FLOOR(color.b * 255 + 0.1) MOD 256
END ColorToRGB;

PROCEDURE ColorToRGBA*(color: Color; VAR r, g, b, a: INTEGER);
BEGIN r := FLOOR(color.r * 255 + 0.1) MOD 256;
  g := FLOOR(color.g * 255 + 0.1) MOD 256;
  b := FLOOR(color.b * 255 + 0.1) MOD 256;
  a := FLOOR(color.a * 255 + 0.1) MOD 256
END ColorToRGBA;

PROCEDURE ClearToColor*(c: Color);
BEGIN Al.clear_to_color(SYSTEM.VAL(Al.Color, c))
END ClearToColor;

PROCEDURE ClearScreen*;
BEGIN Al.clear_to_color(SYSTEM.VAL(Al.Color, black))
END ClearScreen;

PROCEDURE ThickLineF*(x1, y1, x2, y2: REAL; color: Color; thickness: REAL);
BEGIN Al.draw_line(x1, y1, x2, y2, SYSTEM.VAL(Al.Color, color), thickness)
END ThickLineF;

PROCEDURE ThickLine*(x1, y1, x2, y2: INTEGER; color: Color;
    thickness: INTEGER);
BEGIN
  Al.draw_line(FLT(x1) + 0.5, FLT(y1) + 0.5, FLT(x2) + 0.5, FLT(y2) + 0.5,
    SYSTEM.VAL(Al.Color, color), FLT(thickness))
END ThickLine;

PROCEDURE LineF*(x1, y1, x2, y2: REAL; color: Color);
BEGIN
  IF x1 < x2 THEN x2 := x2 + 1
  ELSIF x1 > x2 THEN x1 := x1 + 1
  ELSE x1 := x1 + 0.5; x2 := x2 + 0.5
  END;
  IF y1 < y2 THEN y2 := y2 + 1
  ELSIF y1 > y2 THEN y1 := y1 + 1
  ELSE y1 := y1 + 0.5; y2 := y2 + 0.5
  END;
  Al.draw_line(x1, y1, x2, y2, SYSTEM.VAL(Al.Color, color), 0.0)
END LineF;

PROCEDURE Line*(x1, y1, x2, y2: INTEGER; color: Color);
BEGIN
  LineF(FLT(x1), FLT(y1), FLT(x2), FLT(y2), color)
  (*Al.draw_line(FLT(x1) + 0.5, FLT(y1) + 0.5,
    FLT(x2) + 0.5, FLT(y2) + 0.5, SYSTEM.VAL(Al.Color, color), 1.0)*)
END Line;

PROCEDURE FillRectF*(x1, y1, x2, y2: REAL; color: Color);
BEGIN Al.draw_filled_rectangle(x1, y1, x2, y2, SYSTEM.VAL(Al.Color, color))
END FillRectF;

PROCEDURE FillRect*(x1, y1, x2, y2: INTEGER; color: Color);
BEGIN
  Al.draw_filled_rectangle(FLT(x1), FLT(y1),
    FLT(x2 + 1), FLT(y2 + 1), SYSTEM.VAL(Al.Color, color))
END FillRect;

PROCEDURE ThickRectF*(x1, y1, x2, y2: REAL; color: Color; thickness: REAL);
BEGIN Al.draw_rectangle(x1, y1, x2, y2, SYSTEM.VAL(Al.Color, color), thickness)
END ThickRectF;

PROCEDURE ThickRect*(x1, y1, x2, y2: INTEGER; color: Color;
    thickness: INTEGER);
BEGIN
  Al.draw_rectangle(FLT(x1) + 0.5, FLT(y1) + 0.5,
    FLT(x2) + 0.5, FLT(y2) + 0.5, SYSTEM.VAL(Al.Color, color), FLT(thickness))
END ThickRect;

PROCEDURE RectF*(x1, y1, x2, y2: REAL; color: Color);
BEGIN Al.draw_rectangle(x1, y1, x2, y2, SYSTEM.VAL(Al.Color, color), 1.0)
END RectF;

PROCEDURE Rect*(x1, y1, x2, y2: INTEGER; color: Color);
BEGIN
  Al.draw_rectangle(FLT(x1) + 0.5, FLT(y1) + 0.5,
    FLT(x2) + 0.5, FLT(y2) + 0.5, SYSTEM.VAL(Al.Color, color), 1.0)
END Rect;

PROCEDURE NewBitmap*(w, h: INTEGER): Bitmap;
VAR b: Bitmap;
BEGIN NEW(b);
  Al.set_new_bitmap_flags({}); (*!FIXME*)
  b.bmp := Al.create_bitmap(w, h);
  IF b.bmp = NIL THEN b := NIL ELSE b.w := w; b.h := h END
RETURN b END NewBitmap;

PROCEDURE DrawPartFlip*(bmp: Bitmap; sx, sy, sw, sh, dx, dy: INTEGER;
    flags: SET);
BEGIN
  Al.draw_bitmap_region(bmp.bmp, FLT(sx), FLT(sy), FLT(sw), FLT(sh),
    FLT(dx), FLT(dy), flags)
END DrawPartFlip;

PROCEDURE DrawPart*(bmp: Bitmap; sx, sy, sw, sh, dx, dy: INTEGER);
BEGIN
  Al.draw_bitmap_region(bmp.bmp, FLT(sx), FLT(sy), FLT(sw), FLT(sh),
    FLT(dx), FLT(dy), {})
END DrawPart;

PROCEDURE DrawTintedPart*(bmp: Bitmap; color: Color;
    sx, sy, sw, sh, dx, dy: INTEGER);
BEGIN
  Al.draw_tinted_bitmap_region(bmp.bmp, SYSTEM.VAL(Al.Color, color),
    FLT(sx), FLT(sy), FLT(sw), FLT(sh), FLT(dx), FLT(dy), {})
END DrawTintedPart;

PROCEDURE DrawFlip*(bmp: Bitmap; x, y: INTEGER; flags: SET);
BEGIN Al.draw_bitmap(bmp.bmp, FLT(x), FLT(y), flags)
END DrawFlip;

PROCEDURE Draw*(bmp: Bitmap; x, y: INTEGER);
BEGIN Al.draw_bitmap(bmp.bmp, FLT(x), FLT(y), {})
END Draw;

PROCEDURE DrawEx*(bmp: Bitmap; sx, sy, sw, sh, dx, dy, dw, dh: INTEGER;
    flags: SET);
BEGIN
  Al.draw_scaled_bitmap(bmp.bmp, FLT(sx), FLT(sy), FLT(sw), FLT(sh),
    FLT(dx), FLT(dy), FLT(dw), FLT(dh), flags)
END DrawEx;

PROCEDURE DrawRotated*(bmp: Bitmap; cx, cy, dx, dy: INTEGER;
    angle: REAL; flags: SET);
BEGIN
  Al.draw_rotated_bitmap(bmp.bmp, FLT(cx), FLT(cy),
    FLT(dx), FLT(dy), angle, flags)
END DrawRotated;

PROCEDURE DrawScaledRotated*(bmp: Bitmap; cx, cy, dx, dy: INTEGER;
    xScale, yScale, angle: REAL; flags: SET);
BEGIN
  Al.draw_scaled_rotated_bitmap(bmp.bmp, FLT(cx), FLT(cy),
    FLT(dx), FLT(dy), xScale, yScale, angle, flags)
END DrawScaledRotated;

PROCEDURE DelayF*(n: REAL);
BEGIN Al.rest(n)
END DelayF;

PROCEDURE Delay*(n: INTEGER);
BEGIN Al.rest(n / 1000)
END Delay;

PROCEDURE Pause*;
BEGIN

END Pause;

PROCEDURE RecreateDisplay(W: Window; alterSize: BOOLEAN);
VAR d: Al.Display;
  q: ARRAY 256 OF SHORTCHAR;
  opt: SET;
  n, x, y, w, h, dw, dh, nw, nh, sw, sh: INTEGER;
  nwf, nhf: REAL;
  isCurTarget: BOOLEAN;
BEGIN isCurTarget := target = W;
  IF W.display # NIL THEN Al.destroy_display(W.display) END;

  W.rzoom := W.wantZoom;
  IF W.wantZoom = 1.0 THEN W.zoom := noZoom
  ELSIF FLOOR(W.wantZoom + 0.001) * 100 = FLOOR(W.wantZoom * 100 + 0.001) THEN
    W.zoom := intZoom; W.izoom := FLOOR(W.wantZoom + 0.001)
  ELSE W.zoom := realZoom
  END;

  Utf8.Encode(W.title, q); Al.set_new_window_title(q);
  IF software IN W.options THEN n := 0 ELSE n := 1 END;
  Al.set_new_display_option(Al.renderMethod, n, Al.suggest);
  Al.set_new_display_option(Al.vsync, 2, Al.suggest);

  IF smooth IN W.options THEN n := 1;
    Al.set_new_display_option(Al.samples, 8, Al.suggest)
  ELSE n := 0
  END;
  Al.set_new_display_option(Al.sampleBuffers, n, Al.suggest);

  GetDesktopResolution(dw, dh);
  dw := FLOOR(FLT(dw) / wantScaleX + 0.1);
  dh := FLOOR(FLT(dh) / W.scaleY + 0.1);

  IF fullscreen IN W.options THEN w := W.fsW; h := W.fsH
  ELSE w := W.initW; h := W.initH
  END;

  IF (w < 0) OR (h < 0) THEN
    IF fullscreen IN W.options THEN
      w := FLOOR(dw / W.wantZoom + 0.1); h := FLOOR(dh / W.wantZoom + 0.1);
      ApplySizeStep(W, w, h);
      sw := FLOOR(w * W.wantZoom + 0.1); sh := FLOOR(h * W.wantZoom + 0.1)
    ELSE w := 640; h := 400; W.zoom := noZoom;
      ApplySizeStep(W, w, h); sw := w; sh := h
    END
  ELSIF fullscreen IN W.options THEN
    IF smooth IN W.options THEN nwf := dw / w; nhf := dh / h;
      IF nhf < nwf THEN nwf := nhf END;
      W.zoom := realZoom; W.rzoom := nwf;
      IF exact IN W.options THEN
        sw := FLOOR(w * nwf + 0.1); sh := FLOOR(h * nwf + 0.1)
      ELSE sw := dw; sh := dh
      END
    ELSE nw := dw DIV w; nh := dh DIV h;
      IF nh < nw THEN nw := nh END;
      W.zoom := intZoom; W.izoom := nw; W.rzoom := FLT(nw);
      IF exact IN W.options THEN sw := w * nw; sh := h * nw
      ELSE sw := dw DIV nw * nw; sh := dh DIV nw * nw
      END
    END;

    IF W.zoom = realZoom THEN
      w := FLOOR(sw / W.rzoom + 0.1); h := FLOOR(sh / W.rzoom + 0.1)
    ELSIF W.zoom = intZoom THEN w := sw DIV W.izoom; h := sh DIV W.izoom
    ELSE w := sw; h := sh
    END;
    ApplySizeStep(W, w, h); sw := w; sh := h;
    IF alterSize THEN W.initW := w; W.initH := h END
  ELSE ApplySizeStep(W, w, h);
    sw := FLOOR(w * W.wantZoom * W.scaleX + 0.999);
    sh := FLOOR(h * W.wantZoom * W.scaleY + 0.999)
  END;

  W.lastW := w; W.lastH := h;

  IF center IN W.options THEN GetDesktopResolution(dw, dh);
    x := (dw - sw) DIV 2; y := (dh - sh) DIV 2;
    IF x < 0 THEN x := 0 END; IF y < 0 THEN y := 0 END
  ELSIF (W.initX < 0) OR (W.initY < 0) THEN x := Al.intMax; y := Al.intMax
  ELSE x := W.initX; y := W.initY
  END;
  Al.set_new_window_position(x, y);

  opt := {};
  IF fullscreen IN W.options THEN INCL(opt, Al.fullscreenWindow)
  ELSE INCL(opt, Al.windowed)
  END;
  IF resizable IN W.options THEN INCL(opt, Al.resizable) END;
  IF maximized IN W.options THEN INCL(opt, Al.maximized) END;
  IF minimized IN W.options THEN INCL(opt, Al.minimized) END;
  IF frameless IN W.options THEN INCL(opt, Al.frameless) END;
  Al.set_new_display_flags(opt);

  IF W.bmp # NIL THEN Al.destroy_bitmap(W.bmp); W.bmp := NIL END;
  W.display := Al.create_display(sw, sh);
  IF W.display # NIL THEN
    W.winW := Al.get_display_width(W.display);
    W.winH := Al.get_display_height(W.display);
    W.w := w; W.h := h;
    ResetWindowBitmap(W);
    Al.register_event_source(queue, Al.get_display_event_source(W.display));
    IF isCurTarget THEN Target(W) END
  END
END RecreateDisplay;

PROCEDURE NewWindow*(x, y, w, h: INTEGER; title: ARRAY OF CHAR;
    options: SET): Window;
VAR W: Window;
  d: Al.Display;
  q: ARRAY 256 OF SHORTCHAR;
  opt: SET;
  n, dw, dh, nw, nh, sw, sh: INTEGER;
  nwf, nhf: REAL;
BEGIN NEW(W); W.lastX := -1; W.lastY := -1; W.resized := FALSE;
  W.sizeStepX := wantSizeStepX; W.sizeStepY := wantSizeStepY;
  IF {fullscreen, window} * options = {} THEN INCL(options, window)
  ELSIF window IN options THEN EXCL(options, fullscreen)
  END;
  W.options := options;
  W.title := title;
  W.wantZoom := wantZoom;
  W.scaleOn := (wantScaleX # 1.0) OR (wantScaleY # 1.0);
  W.scaleX := wantScaleX; W.scaleY := wantScaleY;
  W.initX := x; W.initY := y; W.initW := w; W.initH := h;
  W.fsW := w; W.fsH := h;

  W.display := NIL; RecreateDisplay(W, TRUE);
  IF W.display # NIL THEN W.next := windowList; windowList := W
  ELSE Error('Could not create dispaly.'); W := NIL
  END;
  IF (screen = NIL) & (W # NIL) THEN screen := W; Target(screen) END
RETURN W END NewWindow;

PROCEDURE CloseWindow*(W: Window);
BEGIN Al.destroy_display(W.display)
END CloseWindow;

PROCEDURE NewTimer*(speed: REAL): Timer;
VAR T: Timer;
BEGIN NEW(T); T.tmr := Al.create_timer(speed);
  Al.register_event_source(queue, Al.get_timer_event_source(T.tmr))
RETURN T END NewTimer;

PROCEDURE NoEvents*(): BOOLEAN;
RETURN Al.is_event_queue_empty(queue) END NoEvents;

PROCEDURE GetWindow(d: Al.Display): Window;
VAR W: Window;
BEGIN W := windowList;
  WHILE (W # NIL) & (W.display # d) DO W := W.next END
RETURN W END GetWindow;

PROCEDURE ToggleFullscreen*(win: Window);
VAR fs: BOOLEAN;
  w, h: REAL;
BEGIN
  IF (win = NIL) & (screen # NIL) THEN win := screen END;
  IF (win # NIL) & (win.display # NIL) THEN
    fs := ~(Al.windowed IN Al.get_display_flags(win.display));
    IF fs THEN EXCL(win.options, fullscreen); INCL(win.options, window)
    ELSE INCL(win.options, fullscreen); EXCL(win.options, window);
      w := Al.get_display_width(win.display) / win.rzoom;
      h := Al.get_display_height(win.display) / win.rzoom;
      IF win.scaleOn THEN w := w / win.scaleX; h := h / win.scaleY END;
      win.initW := FLOOR(w + 0.1); win.initH := FLOOR(h + 0.1);
      EXCL(win.options, center);
      Al.get_window_position(win.display, win.initX, win.initY);
      ApplySizeStep(win, win.initW, win.initH)
    END;
    win.scaleX := wantScaleX;
    win.scaleY := wantScaleY;
    RecreateDisplay(win, FALSE);
    win.resized := TRUE; anyWindowResized := TRUE
  END
END ToggleFullscreen;

PROCEDURE MakeResizeEvent(VAR event: Event);
VAR W: Window;
BEGIN W := windowList;
  WHILE (W # NIL) & ~W.resized DO W := W.next END;
  event.type := resize;
  event.window := W; event.display := W.display;
  event.w := W.w; event.h := W.h;
  W.resized := FALSE;
  WHILE (W # NIL) & ~W.resized DO W := W.next END;
  IF W = NIL THEN anyWindowResized := FALSE END
END MakeResizeEvent;

PROCEDURE SSet(s: SET);
VAR i: INTEGER;
BEGIN Out.Char('{');
  FOR i := 0 TO 31 DO IF i IN s THEN Out.Int(i, 3) END END;
  Out.Char('}')
END SSet;

PROCEDURE WaitEvent*(VAR event: Event);
VAR E: Al.Event;
  DE: Al.PDisplayEvent;
  TE: Al.PTimerEvent;
  KE: Al.PKeyboardEvent;
  ME: Al.PMouseEvent;
  W: Window;
  skip: BOOLEAN;
  x, y, w, h: INTEGER;
  fw, fh: REAL;
BEGIN
  REPEAT skip := FALSE;
    IF anyWindowResized THEN MakeResizeEvent(event)
    ELSE Al.wait_for_event(queue, E);
      event.time := E.timestamp;
      IF E.type = Al.eventMouseAxes THEN
        ME := SYSTEM.VAL(Al.PMouseEvent, SYSTEM.ADR(E));
        W := GetWindow(ME.display);
        IF W.zoom = noZoom THEN x := ME.x - W.iFlipX; y := ME.y - W.iFlipY
        ELSIF W.zoom = intZoom THEN
          x := (ME.x - W.iFlipX) DIV W.izoom; y := (ME.y - W.iFlipY) DIV W.izoom
        ELSE x := FLOOR((ME.x - W.flipX) / W.rzoom + 0.1);
          y := FLOOR((ME.y - W.flipY) / W.rzoom + 0.1)
        END;
        IF W.scaleOn THEN
          x := FLOOR(x / W.scaleX + 0.1); y := FLOOR(y / W.scaleY + 0.1)
        END;
        IF (x # W.lastX) OR (y # W.lastY) OR (ME.dz # 0) OR (ME.dw # 0) THEN
          IF (ME.dz # 0) OR (ME.dw # 0) THEN event.type := mouseWheel;
            event.dz := ME.dz; event.dw := ME.dw;
            event.x := W.lastX; event.y := W.lastY;
            event.z := ME.z; event.w := ME.w;
            event.dx := 0; event.dy := 0
          ELSE event.type := mouseMove;
            IF x = -1 THEN event.dx := 0; event.dy := 0
            ELSE event.dx := x - W.lastX; event.dy := y - W.lastY
            END;
            event.x := x; event.y := y;
            W.lastX := event.x; W.lastY := event.y
          END;
          event.button := ME.button;
          event.mod := keyMods;
          event.display := ME.display; event.window := W
        ELSE skip := TRUE
        END
      ELSIF E.type = Al.eventMouseButtonDown THEN
        event.type := mouseDown;
        ME := SYSTEM.VAL(Al.PMouseEvent, SYSTEM.ADR(E));
        W := GetWindow(ME.display); event.window := W;
        IF W.zoom = noZoom THEN event.x := ME.x; event.y := ME.y
        ELSIF W.zoom = intZoom THEN
          event.x := ME.x DIV W.izoom; event.y := ME.y DIV W.izoom
        ELSE event.x := FLOOR(ME.x / W.rzoom + 0.1);
          event.y := FLOOR(ME.y / W.rzoom + 0.1)
        END;
        IF W.scaleOn THEN event.x := FLOOR(event.x / W.scaleX + 0.1);
          event.y := FLOOR(event.y / W.scaleY + 0.1)
        END;
        event.z := ME.z; event.w := ME.w;
        event.button := ME.button;
        event.mod := keyMods;
        event.display := ME.display
      ELSIF E.type = Al.eventMouseButtonUp THEN
        event.type := mouseUp;
        ME := SYSTEM.VAL(Al.PMouseEvent, SYSTEM.ADR(E));
        W := GetWindow(ME.display); event.window := W;
        IF W.zoom = noZoom THEN event.x := ME.x; event.y := ME.y
        ELSIF W.zoom = intZoom THEN
          event.x := ME.x DIV W.izoom; event.y := ME.y DIV W.izoom
        ELSE
          event.x := FLOOR(ME.x / W.rzoom + 0.1);
          event.y := FLOOR(ME.y / W.rzoom + 0.1)
        END;
        IF W.scaleOn THEN event.x := FLOOR(event.x / W.scaleX + 0.1);
          event.y := FLOOR(event.y / W.scaleY + 0.1)
        END;
        event.z := ME.z; event.w := ME.w;
        event.button := ME.button;
        event.mod := keyMods;
        event.display := ME.display
      ELSIF E.type = Al.eventTimer THEN
        event.type := timer;
        TE := SYSTEM.VAL(Al.PTimerEvent, SYSTEM.ADR(E));
        event.count := TE.count;
        event.source := SYSTEM.VAL(ADRINT, TE.source)
      ELSIF E.type = Al.eventKeyDown THEN
        event.type := keyDown;
        KE := SYSTEM.VAL(Al.PKeyboardEvent, SYSTEM.ADR(E));
        event.key := KE.keycode;
        SetKeyMod(event.key, TRUE);
        event.mod := keyMods;
        Out.Int(event.key, 3); Out.String(' : ');SSet(event.mod);Out.Ln;
        event.display := KE.display;
        event.window := GetWindow(event.display)
      ELSIF E.type = Al.eventKeyUp THEN
        event.type := keyUp;
        KE := SYSTEM.VAL(Al.PKeyboardEvent, SYSTEM.ADR(E));
        event.key := KE.keycode;
        event.mod := keyMods;
        SetKeyMod(event.key, FALSE);
        event.display := KE.display;
        event.window := GetWindow(event.display)
      ELSIF E.type = Al.eventKeyChar THEN
        event.type := char;
        KE := SYSTEM.VAL(Al.PKeyboardEvent, SYSTEM.ADR(E));
        event.key := KE.keycode;
        event.ch := CHR(KE.unichar);
        event.mod := KE.modifiers;
        event.repeat := KE.repeat;
        event.display := KE.display;
        event.window := GetWindow(event.display)
      ELSIF E.type = Al.eventDisplayResize THEN
        DE := SYSTEM.VAL(Al.PDisplayEvent, SYSTEM.ADR(E));
        Al.acknowledge_resize(DE.source); W := GetWindow(DE.source);
        W.winW := Al.get_display_width(DE.source);
        W.winH := Al.get_display_height(DE.source);
        fw := W.winW / W.rzoom; fh := W.winH / W.rzoom;
        IF W.scaleOn THEN fw := fw / W.scaleX; fh := fh / W.scaleY END;
        w := FLOOR(fw + 0.1); h := FLOOR(fh + 0.1);
        ApplySizeStep(W, w, h);
        IF (w # W.lastW) OR (h # W.lastH) THEN W.lastW := w; W.lastH := h;
          event.type := resize; event.window := W; event.display := DE.source;
          event.w := w; event.h := h; event.x := DE.x; event.y := DE.y;
          ResetWindowBitmap(W)
        ELSE ResetFlipVars(W); Flip; skip := TRUE
        END
      ELSIF E.type = Al.eventDisplayClose THEN
        event.type := quit;
        event.display := SYSTEM.VAL(Al.Display, E.source);
        event.window := GetWindow(event.display)
      ELSE skip := TRUE
      END
    END
  UNTIL ~skip
END WaitEvent;

PROCEDURE StartTimer*(timer: Timer);
BEGIN Al.start_timer(timer.tmr)
END StartTimer;

(* Font *)

PROCEDURE GetMonoFontSize*(font: Font; VAR charW, charH: INTEGER);
BEGIN charW := font(MonoFont).charW; charH := font(MonoFont).charH
END GetMonoFontSize;

PROCEDURE FindFontChar(font: Font; c: CHAR; VAR bmp: Bitmap;
    VAR x, y, w, h: INTEGER);
VAR n: INTEGER;
  m: MonoFont;
BEGIN m := font(MonoFont);
  IF c < 200X THEN n := ORD(c)
  ELSIF (400X <= c) & (c < 500X) THEN n := ORD(c) + (300H - 400H)
  ELSIF (2500X <= c) & (c < 2600X) THEN n := ORD(c) + (200H - 2500H)
  ELSE n := -1
  END;
  IF n < 0 THEN n := 1 (* "Bad" character *) END;
  bmp := m.bmp;
  x := n MOD m.cols * m.charW; y := n DIV m.cols * m.charH;
  w := m.charW; h := m.charH
END FindFontChar;

PROCEDURE DrawCharEx*(ch: CHAR; x, y: INTEGER; font: Font; color: Color;
    VAR w: INTEGER);
VAR sx, sy, h: INTEGER;
  bmp: Bitmap;
BEGIN FindFontChar(font, ch, bmp, sx, sy, w, h);
  DrawTintedPart(bmp, color, sx, sy, w, h, x, y)
END DrawCharEx;

PROCEDURE DrawChar*(ch: CHAR; x, y: INTEGER; font: Font; color: Color);
VAR w: INTEGER;
BEGIN DrawCharEx(ch, x, y, font, color, w)
END DrawChar;

PROCEDURE DrawString*(s: ARRAY OF CHAR; x, y: INTEGER;
    font: Font; color: Color);
VAR i, cx, cy, charW, destW, destH: INTEGER;
  m: MonoFont;
BEGIN m := font(MonoFont); i := 0; cx := x; cy := y;
  GetTargetSize(destW, destH);
  WHILE (s[i] # 0X) & (cx < destW) & (cy < destH) DO
    IF s[i] = 0AX THEN cx := x; INC(cy, m.charH)
    ELSE DrawCharEx(s[i], cx, cy, font, color, charW);
      INC(i); INC(cx, charW)
    END
  END
END DrawString;

PROCEDURE MonoFontDraw(f: Font; VAR msg: FontDrawMsg);
VAR m: MonoFont;
BEGIN m := f(MonoFont);
  (*!TODO*)
END MonoFontDraw;

PROCEDURE MonoFontHandle(f: Font; VAR msg: FontMessage);
VAR m: MonoFont;
BEGIN m := f(MonoFont)
  (*!TODO*)
END MonoFontHandle;

PROCEDURE LoadFont*(fname: ARRAY OF CHAR): Font;
VAR f: MonoFont;
  bmp: Bitmap;
  F: Files.File;
  r: Files.Rider;
  s: ARRAY 4096 OF CHAR;
BEGIN f := NIL;
  s := fname; Strings.Append('.ofi', s);
  F := Files.Old(s);
  IF F # NIL THEN
    Files.Close(F); (*!TODO*)
    s := fname; Strings.Append('.png', s);
    bmp := LoadBitmap(s);
    IF bmp # NIL THEN
      NEW(f); f.bmp := bmp;
      f.cols := 16; f.rows := 16 * fontPlanes;
      f.charW := bmp.w DIV f.cols; f.charH := bmp.h DIV f.rows;
      f.draw := MonoFontDraw;
      f.handle := MonoFontHandle
    END
  END
RETURN f END LoadFont;

(* Clipboard *)

PROCEDURE GetClipboardText*(win: Window; VAR s: ARRAY OF CHAR);
TYPE P = POINTER [1] TO ARRAY 5000 OF SHORTCHAR;
VAR a: Al.ADRINT;
  p: P;
  q: ARRAY 20 OF SHORTCHAR;
BEGIN
  a := Al.get_clipboard_text(win.display);
  (*IF a = 0 THEN a := Al.get_clipboard_text(win.display) END; (*Allegro bug*)*)
  Out.String('a = ');Out.Int(a, 0);Out.Ln;
  IF a # 0 THEN p := SYSTEM.VAL(P, a); Utf8.Decode(p^, s);
    Al.free_with_context(a, 27, 'Graph2.Mod', 'GetClipboardText')
    (*;Utf8.Encode('Привет', q);
    ;IF Al.set_clipboard_text(win.display, SYSTEM.VAL(Al.ADRINT, SYSTEM.ADR(q))) THEN END*)
  ELSE s[0] := 0X
  END
END GetClipboardText;

(* Init *)

PROCEDURE InitScreen(): BOOLEAN;
VAR opt: SET;
BEGIN
  IF ~(fullscreen IN settings) & ((wantW <= 0) OR (wantH <= 0)) THEN
    wantW := 640; wantH := 400
  END;
  opt := settings;
  IF {fullscreen, window} * opt = {} THEN INCL(opt, fullscreen)
  ELSIF fullscreen IN opt THEN EXCL(opt, window)
  END
RETURN NewWindow(-1, -1, wantW, wantH, wantTitle, opt) # NIL END InitScreen;

PROCEDURE Init*;
VAR ok: BOOLEAN;
BEGIN ok := TRUE; anyWindowResized := FALSE;
  IF Al.install_system(Al.get_allegro_version(), 0) THEN
    IF ~Al.install_keyboard() THEN
      Error('Could not install keyboard.'); ok := FALSE
    END;

    IF ~Al.install_mouse() THEN
      Error('Could not install mouse.'); ok := FALSE
    END;

    IF ~Al.init_primitives_addon() THEN
      Error('Could not init primitives addon.'); ok := FALSE
    END;

    IF ~Al.init_image_addon() THEN
      Error('Could not init image addon.'); ok := FALSE
    END;

    queue := Al.create_event_queue();
    IF queue = NIL THEN
      Error('Could not create queue.'); ok := FALSE
    END;

    Al.register_event_source(queue, Al.get_keyboard_event_source());
    Al.register_event_source(queue, Al.get_mouse_event_source());
    InitKeyMod;

    IF ~(manual IN settings) THEN
      IF ~InitScreen() THEN ok := FALSE END
    END
  ELSE Error('Coult not init Allegro.'); ok := FALSE
  END;
  Done := ok
END Init;

PROCEDURE ResetDefaults;
BEGIN
  wantW := 640; wantH := 400; wantSizeStepX := 1; wantSizeStepY := 1;
  wantScaleX := 1.0; wantScaleY := 1.0; wantZoom := 1.0;
  settings := {};
  wantTitle := 'Oberon'
END ResetDefaults;

PROCEDURE Close*;
BEGIN
  Al.uninstall_system;
  queue := NIL; windowList := NIL; screen := NIL; target := NIL;
  ResetDefaults
END Close;

BEGIN Done := FALSE;
  MakeCol(black, 0, 0, 0);
  ResetDefaults
END Graph2.
