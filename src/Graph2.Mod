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
    lastX, lastY: INTEGER; (* Last mouse position in virtual pixels *)
    zoom: INTEGER; (* See constants above; based on this rzoom/izoom is used *)
    izoom: INTEGER; (* Window.izoom is used if Window.zoom = intZoom  *)
    rzoom: REAL;    (* Window.rzoom is used if Window.zoom = realZoom *)
    hasScale: BOOLEAN; (* If TRUE, scaleX and scaleY are used *)
    scaleX, scaleY: REAL; (* Deforms pixels on Flip, but zoom is for drawing *)
    flipX, flipY, flipW, flipH: REAL; (* Where to flip the window bitmap to *)
    iFlipX, iFlipY: INTEGER; (* Same as flipX, flipY, which are always whole *)
    options: SET;
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
  sizeStepX, sizeStepY: INTEGER; (* Assigned in procedure SetSizeStep *)
  wantScaleX, wantScaleY: REAL; (* Assigned in procedure SetScale *)
  wantTitle: ARRAY 256 OF CHAR; (* Assigned in procedure SetTitle *)
  queue: Al.EventQueue;
  windowList: Window;
  screen: Window;
  target: Bitmap;
  black: Color;

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
BEGIN sizeStepX := w; sizeStepY := h
END SetSizeStep;

PROCEDURE ApplySizeStep(VAR w, h: INTEGER);
BEGIN
  IF sizeStepX # 1 THEN w := w DIV sizeStepX * sizeStepX END;
  IF sizeStepY # 1 THEN h := h DIV sizeStepY * sizeStepY END
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
  IF W.zoom = noZoom THEN W.flipW := FLT(W.w); W.flipH := FLT(W.h);
    IF W.hasScale THEN
      W.flipW := W.flipW * W.scaleX; W.flipH := W.flipH * W.scaleY
    END;
    W.iFlipX := FLOOR(W.winW - W.flipW + 0.5) DIV 2;
    W.iFlipY := FLOOR(W.winH - W.flipH + 0.5) DIV 2
  ELSIF W.zoom = intZoom THEN w := W.w * W.izoom; h := W.h * W.izoom;
    W.flipW := FLT(w); W.flipH := FLT(h);
    IF W.hasScale THEN
      W.flipW := W.flipW * W.scaleX; W.flipH := W.flipH * W.scaleY;
      W.iFlipX := (W.winW - FLOOR(W.flipW + 0.5)) DIV 2;
      W.iFlipY := (W.winH - FLOOR(W.flipH + 0.5)) DIV 2
    ELSE W.iFlipX := (W.winW - w) DIV 2; W.iFlipY := (W.winH - h) DIV 2
    END
  ELSE W.flipW := FLT(W.w) * W.rzoom; W.flipH := FLT(W.h) * W.rzoom;
    IF W.hasScale THEN
      W.flipW := W.flipW * W.scaleX; W.flipH := W.flipH * W.scaleY
    END;
    W.flipW := FLT(FLOOR(W.flipW + 0.5)); W.flipH := FLT(FLOOR(W.flipH + 0.5));
    W.iFlipX := (W.winW - FLOOR(W.flipW + 0.1)) DIV 2;
    W.iFlipY := (W.winH - FLOOR(W.flipH + 0.1)) DIV 2;
  END;
  W.flipX := FLT(W.iFlipX); W.flipY := FLT(W.iFlipY);
  IF ~(exact IN W.options) & (smooth IN W.options) &
     (W.winW - W.flipX - W.flipW < W.rzoom) &
     (W.winH - W.flipY - W.flipH < W.rzoom) THEN
    W.iFlipX := 0; W.iFlipY := 0; W.flipX := 0.0; W.flipY := 0.0;
    W.flipW := FLT(W.winW); W.flipH := FLT(W.winH)
  END

  ;Out.String('ResetFlipVars ');
  Out.RealFix(W.flipX, 8, 1); Out.RealFix(W.flipY, 8, 1);
  Out.RealFix(W.flipW, 8, 1); Out.RealFix(W.flipH, 8, 1); Out.Ln;
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
    ELSIF (W.zoom = intZoom) & ~W.hasScale THEN
      w := W.winW DIV W.izoom; h := W.winH DIV W.izoom
    ELSE fw := W.winW / W.rzoom; fh := W.winH / W.rzoom; scaled := TRUE;
      IF W.hasScale THEN
        w := FLOOR(fw / W.scaleX + 0.1); h := FLOOR(fh / W.scaleY + 0.1)
      END
    END
  ELSE w := W.w; h := W.h
  END;
  ;Out.String('before scale ');Out.Int(w,0);Out.Ln;
  IF W.hasScale & ~scaled THEN
    w := FLOOR(w / W.scaleX + 0.1); h := FLOOR(h / W.scaleY + 0.1)
  END;
  ;Out.String('before apply ');Out.Int(w,0);Out.Ln;
  ApplySizeStep(w, h);
  IF (w > bw) OR (h > bh) OR (W.zoom = noZoom) THEN
    IF W.bmp # NIL THEN
      wasTarget := Al.get_target_bitmap() = W.bmp;
      Al.destroy_bitmap(W.bmp)
    END;
    IF W.zoom # noZoom THEN
      IF smooth IN W.options THEN opt := {Al.minLinear, Al.magLinear}
      ELSE opt := {}
      END;
      Al.set_new_bitmap_flags(opt);
      W.bmp := Al.create_bitmap(w, h);
      IF wasTarget THEN Target(W) END
    ELSE W.bmp := NIL;
      IF wasTarget THEN Target(NIL) END
    END;
  END;
  W.w := w; W.h := h;
  ResetFlipVars(W)
END ResetWindowBitmap;

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

PROCEDURE ApplyScale*(W: Window);
VAR t: Al.Transform;
BEGIN
  (*Target(W);
  Al.build_transform(t, 0.0, 0.0, 6.0, 6.0, 0.0);
  Al.use_transform(t)*)
END ApplyScale;

PROCEDURE SetWindowScale*(W: Window; x, y: REAL);
BEGIN W.hasScale := (x # 1.0) OR (y # 1.0);
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
      ;Out.String('target.bmp # NIL');Out.Ln;
      Al.clear_to_color(SYSTEM.VAL(Al.Color, black));
      ;Out.Int(W.w, 7);
      ;Out.Int(W.h, 7);
      ;Out.RealFix(W.flipX, 7, 2);
      ;Out.RealFix(W.flipY, 7, 2);
      ;Out.RealFix(W.flipW, 7, 2);
      ;Out.RealFix(W.flipH, 7, 2);Out.Ln;
      Al.draw_scaled_bitmap(W.bmp, 0.0, 0.0, FLT(W.w), FLT(W.h),
        W.flipX, W.flipY, W.flipW, W.flipH, {});
    ELSE
      ;Out.String('target.bmp = NIL');Out.Ln;
      Al.draw_filled_rectangle(0.0, 0.0, W.flipX, FLT(W.winH),
        SYSTEM.VAL(Al.Color, black));
      Al.draw_filled_rectangle(W.flipX + W.w, 0.0, FLT(W.winW), FLT(W.winH),
        SYSTEM.VAL(Al.Color, black));
      Al.draw_filled_rectangle(W.flipX, 0.0, W.flipX + FLT(W.w), W.flipY,
        SYSTEM.VAL(Al.Color, black));
      Al.draw_filled_rectangle(W.flipX, W.flipY + FLT(W.h),
        W.flipX + FLT(W.w), FLT(W.winH), SYSTEM.VAL(Al.Color, black))
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

PROCEDURE NewWindow*(x, y, w, h: INTEGER; title: ARRAY OF CHAR;
    options: SET): Window;
VAR W: Window;
  d: Al.Display;
  q: ARRAY 256 OF SHORTCHAR;
  opt: SET;
  n, dw, dh, nw, nh, sw, sh: INTEGER;
  nwf, nhf: REAL;
BEGIN NEW(W); W.lastX := -1; W.lastY := -1;
  IF {fullscreen, window} * opt = {} THEN INCL(opt, window)
  ELSIF window IN opt THEN EXCL(opt, fullscreen)
  END;
  W.options := options;

  W.hasScale := (wantScaleX # 1.0) OR (wantScaleY # 1.0);
  W.scaleX := wantScaleX; W.scaleY := wantScaleY;
  W.rzoom := wantZoom;
  IF wantZoom = 1.0 THEN W.zoom := noZoom
  ELSIF FLOOR(wantZoom + 0.001) * 100 = FLOOR(wantZoom * 100 + 0.001) THEN
    W.zoom := intZoom; W.izoom := FLOOR(wantZoom + 0.001)
  ELSE W.zoom := realZoom
  END;

  Utf8.Encode(title, q); Al.set_new_window_title(q);
  IF software IN options THEN n := 0 ELSE n := 1 END;
  Al.set_new_display_option(Al.renderMethod, n, Al.suggest);
  Al.set_new_display_option(Al.vsync, 2, Al.suggest);

  IF smooth IN options THEN n := 1;
    Al.set_new_display_option(Al.samples, 8, Al.suggest)
  ELSE n := 0
  END;
  Al.set_new_display_option(Al.sampleBuffers, n, Al.suggest);

  GetDesktopResolution(dw, dh);
  dw := FLOOR(FLT(dw) / W.scaleX + 0.1);
  dh := FLOOR(FLT(dh) / W.scaleY + 0.1);

  IF (w < 0) OR (h < 0) THEN
    IF fullscreen IN options THEN
      w := FLOOR(dw / wantZoom + 0.1); h := FLOOR(dh / wantZoom + 0.1);
      ApplySizeStep(w, h);
      sw := FLOOR(w * wantZoom + 0.1); sh := FLOOR(h * wantZoom + 0.1)
    ELSE w := 640; h := 400; W.zoom := noZoom;
      ApplySizeStep(w, h); sw := w; sh := h
    END
  ELSIF fullscreen IN options THEN
    IF smooth IN options THEN nwf := dw / w; nhf := dh / h;
      IF nhf < nwf THEN nwf := nhf END;
      W.zoom := realZoom; W.rzoom := nwf;
      IF exact IN options THEN
        sw := FLOOR(w * nwf + 0.1); sh := FLOOR(h * nwf + 0.1)
      ELSE sw := dw; sh := dh
      END
    ELSE nw := dw DIV w; nh := dh DIV h;
      IF nh < nw THEN nw := nh END;
      W.zoom := intZoom; W.izoom := nw; W.rzoom := FLT(nw);
      IF exact IN options THEN sw := w * nw; sh := h * nw
      ELSE sw := dw DIV nw * nw; sh := dh DIV nw * nw
      END
    END;

    IF W.zoom = realZoom THEN
      w := FLOOR(sw / W.rzoom + 0.1); h := FLOOR(sh / W.rzoom + 0.1)
    ELSIF W.zoom = intZoom THEN w := sw DIV W.izoom; h := sh DIV W.izoom
    ELSE w := sw; h := sh
    END;
    ApplySizeStep(w, h); sw := w; sh := h
  ELSE ApplySizeStep(w, h);
    sw := FLOOR(w * wantZoom * W.scaleX + 0.999);
    sh := FLOOR(h * wantZoom * W.scaleY + 0.999)
  END;

  IF center IN options THEN
    GetDesktopResolution(dw, dh);
    x := (dw - sw) DIV 2;
    y := (dh - sh) DIV 2;
    IF x < 0 THEN x := 0 END;
    IF y < 0 THEN y := 0 END;
    Al.set_new_window_position(x, y)
  ELSIF (x < 0) OR (y < 0) THEN
    Al.set_new_window_position(Al.intMax, Al.intMax)
  ELSE Al.set_new_window_position(x, y)
  END;

  opt := {};
  IF fullscreen IN options THEN INCL(opt, Al.fullscreenWindow)
  ELSE INCL(opt, Al.windowed)
  END;
  IF resizable IN options THEN INCL(opt, Al.resizable) END;
  IF maximized IN options THEN INCL(opt, Al.maximized) END;
  IF minimized IN options THEN INCL(opt, Al.minimized) END;
  IF frameless IN options THEN INCL(opt, Al.frameless) END;
  Al.set_new_display_flags(opt);

  ;Out.Int(sw,20);Out.Int(sh,10);Out.Ln;
  W.display := Al.create_display(sw, sh);
  IF W.display # NIL THEN
    W.winW := Al.get_display_width(W.display);
    W.winH := Al.get_display_height(W.display);
    W.w := w; W.h := h;
    ResetWindowBitmap(W);
    Al.register_event_source(queue, Al.get_display_event_source(W.display));
    W.next := windowList; windowList := W
  ELSE Error('Could not create dispaly.')
  END;
  IF (screen = NIL) & (W # NIL) THEN
    screen := W;
    Target(screen)
  END
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

PROCEDURE ApplyResize*(window: Window);
BEGIN Al.acknowledge_resize(window.display);
  window.winW := Al.get_display_width(window.display);
  window.winH := Al.get_display_height(window.display);
  ResetWindowBitmap(window)
END ApplyResize;

PROCEDURE WaitEvent*(VAR event: Event);
VAR E: Al.Event;
  DE: Al.PDisplayEvent;
  TE: Al.PTimerEvent;
  KE: Al.PKeyboardEvent;
  ME: Al.PMouseEvent;
  W: Window;
  skip: BOOLEAN;
  x, y: INTEGER;
BEGIN
  REPEAT skip := FALSE;
    Al.wait_for_event(queue, E);
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
      IF W.hasScale THEN
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
      IF W.hasScale THEN event.x := FLOOR(event.x / W.scaleX + 0.1);
        event.y := FLOOR(event.y / W.scaleY + 0.1)
      END;
      event.z := ME.z; event.w := ME.w;
      event.button := ME.button;
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
      IF W.hasScale THEN event.x := FLOOR(event.x / W.scaleX + 0.1);
        event.y := FLOOR(event.y / W.scaleY + 0.1)
      END;
      event.z := ME.z; event.w := ME.w;
      event.button := ME.button;
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
      event.display := KE.display;
      event.window := GetWindow(event.display)
    ELSIF E.type = Al.eventKeyUp THEN
      event.type := keyUp;
      KE := SYSTEM.VAL(Al.PKeyboardEvent, SYSTEM.ADR(E));
      event.key := KE.keycode;
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
      event.type := resize;
      DE := SYSTEM.VAL(Al.PDisplayEvent, SYSTEM.ADR(E));
      event.x := DE.x; event.y := DE.y;
      event.w := DE.width; event.h := DE.height;
      event.display := DE.source;
      event.window := GetWindow(event.display)
    ELSIF E.type = Al.eventDisplayClose THEN
      event.type := quit;
      event.display := SYSTEM.VAL(Al.Display, E.source);
      event.window := GetWindow(event.display)
    ELSE skip := TRUE
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
  DrawPart(bmp, sx, sy, w, h, x, y)
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
BEGIN ok := TRUE;
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

    IF ~(manual IN settings) THEN
      IF ~InitScreen() THEN ok := FALSE END
    END
  ELSE Error('Coult not init Allegro.'); ok := FALSE
  END;
  Done := ok
END Init;

PROCEDURE ResetDefaults;
BEGIN
  wantW := 640; wantH := 400; sizeStepX := 1; sizeStepY := 1;
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
