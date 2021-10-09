MODULE Graph2;
IMPORT Out, Al := Allegro5, Utf8, SYSTEM;

CONST
  (* Settings set members *)
  manual*      = 0;
  fullscreen*  = 1;
  exact*       = 2;
  smooth*      = 3;
  software*    = 4;
  initMouse*   = 5;
  centered*    = 6;
  resizable*   = 7;
  maximized*   = 8;
  minimized*   = 9;
  frameless*   = 10;

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
    w*, h*: INTEGER;
    scaleX, scaleY: REAL
  END;

  Window* = POINTER TO WindowDesc;
  WindowDesc* = RECORD(BitmapDesc)
    display: Al.Display;
    winW, winH: INTEGER;
    pixelSize: REAL;
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
    display: Al.Display;
    source: ADRINT
  END;

VAR
  settings: SET; (* See list of constants Settings above *)
  wantW, wantH: INTEGER; (* Assigned in procedure Settings *)
  sizeStepX, sizeStepY: INTEGER; (* Assigned in procedure SetSizeStep *)
  scaleX, scaleY: REAL; (* Assigned in procedure SetScale *)
  wantScreenTitle: ARRAY 256 OF CHAR; (* Assigned in procedure SetTitle *)
  queue: Al.EventQueue;
  windowList: Window;
  screen: Window;
  target: Bitmap;

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

PROCEDURE Width*(): INTEGER;
RETURN screen.w END Width;

PROCEDURE Height*(): INTEGER;
RETURN screen.h END Height;

PROCEDURE Settings*(w, h: INTEGER; flags: SET);
BEGIN wantW := w; wantH := h; settings := flags
END Settings;

PROCEDURE SetSizeStep*(w, h: INTEGER);
BEGIN sizeStepX := w; sizeStepY := h
END SetSizeStep;

PROCEDURE Target*(W: Bitmap);
BEGIN target := W;
  IF (W IS Window) & (W.bmp = NIL) THEN
    Al.set_target_backbuffer(W(Window).display)
  ELSE Al.set_target_bitmap(SYSTEM.VAL(Al.Bitmap, W.bmp))
  END
END Target;

PROCEDURE TargetScreen*;
BEGIN
  IF screen # NIL THEN Target(screen)
  ELSIF windowList # NIL THEN Target(windowList)
  END
END TargetScreen;

PROCEDURE ApplyScale*(W: Window);
VAR t: Al.Transform;
BEGIN
  (*Target(W);
  Al.build_transform(t, 0.0, 0.0, 6.0, 6.0, 0.0);
  Al.use_transform(t)*)
END ApplyScale;

PROCEDURE SetWindowScale*(W: Window; x, y: REAL);
BEGIN W.scaleX := x; W.scaleY := y; ApplyScale(W)
END SetWindowScale;

PROCEDURE SetScale*(x, y: REAL);
BEGIN
  IF screen # NIL THEN SetWindowScale(screen, x, y) END
END SetScale;

PROCEDURE SetTitle*(title: ARRAY OF CHAR);
BEGIN wantScreenTitle := title
END SetTitle;

(*PROCEDURE ColorToRGB*(color: INTEGER; VAR r, g, b: INTEGER);
PROCEDURE ColorToRGBA*(color: INTEGER; VAR r, g, b, a: INTEGER);
PROCEDURE ClearBitmap*(bmp: Bitmap);
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
BEGIN
  IF (target # NIL) & (target IS Window) & (target.bmp # NIL) THEN
    tmp := Al.get_target_bitmap();
    Al.set_target_backbuffer(target(Window).display);
    Al.draw_scaled_bitmap(target.bmp, 0.0, 0.0, FLT(target.w), FLT(target.h),
      0.0, 0.0, FLT(target(Window).winW), FLT(target(Window).winH), {});
    Al.flip_display();
    Al.set_target_bitmap(tmp)
  ELSE Al.flip_display()
  END;
END Flip;

PROCEDURE PutPixel2*(x, y: INTEGER; c: Color);
BEGIN Al.draw_filled_rectangle(FLT(x), FLT(y), FLT(x + 1), FLT(y + 1),
  SYSTEM.VAL(Al.Color, c))
END PutPixel2;

PROCEDURE PutPixel*(x, y: INTEGER; c: Color);
BEGIN Al.draw_pixel(FLT(x) + 0.5, FLT(y) + 0.5, SYSTEM.VAL(Al.Color, c))
END PutPixel;

PROCEDURE MakeCol*(r, g, b: INTEGER; VAR c: Color);
BEGIN c.r := r / 255; c.g := g / 255; c.b := b / 255; c.a := 1.0
END MakeCol;

PROCEDURE ClearToColor*(c: Color);
BEGIN Al.clear_to_color(SYSTEM.VAL(Al.Color, c))
END ClearToColor;

PROCEDURE ClearScreen*;
VAR c: Color;
BEGIN MakeCol(0, 0, 0, c); Al.clear_to_color(SYSTEM.VAL(Al.Color, c))
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
  b.bmp := Al.create_bitmap(w, h);
  IF b.bmp = NIL THEN b := NIL
  ELSE b.w := w; b.h := h
  END
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

PROCEDURE SetWindowTitle*(W: Window; title: ARRAY OF CHAR);
VAR q: ARRAY 256 OF SHORTCHAR;
BEGIN Utf8.Encode(title, q); Al.set_window_title(W.display, q)
END SetWindowTitle;

PROCEDURE NewWindow*(x, y, w, h: INTEGER; title: ARRAY OF CHAR;
    options: SET): Window;
VAR W: Window;
  d: Al.Display;
  q: ARRAY 256 OF SHORTCHAR;
  opt: SET;
  n, dw, dh, nw, nh, sw, sh: INTEGER;
  nwf, nhf: REAL;
BEGIN NEW(W); W.pixelSize := 1.0;

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
  dw := FLOOR(FLT(dw) * scaleX); dh := FLOOR(FLT(h) * scaleY);

  IF (w < 0) OR (h < 0) THEN
    IF ~(fullscreen IN options) THEN w := 640; h := 400
    ELSE w := dw; h := dh
    END
  ELSIF fullscreen IN options THEN
    IF smooth IN options THEN nwf := dw / w; nhf := dh / h;
      IF nhf < nwf THEN nwf := nhf END;
      W.pixelSize := nwf;
      IF exact IN options THEN sw := FLOOR(w * nwf); sh := FLOOR(h * nwf)
      ELSE sw := FLOOR(dw / nwf); sh := FLOOR(dh / nwf)
      END
    ELSE nw := dw DIV w; nh := dh DIV h;
      IF nh < nw THEN nw := nh END;
      W.pixelSize := FLT(nw);
      IF exact IN options THEN sw := w * nw; sh := h * nw
      ELSE sw := dw DIV nw; sh := dh DIV nw
      END
    END;
  END;

  w := FLOOR(sw / W.pixelSize);
  h := FLOOR(sh / W.pixelSize);

  (*IF sizeStepX # 1 THEN w := w DIV sizeStepX * sizeStepX END;
  IF sizeStepY # 1 THEN h := h DIV sizeStepY * sizeStepY END;*)

  W.w := w; W.h := h;

  IF centered IN options THEN
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

  W.display := Al.create_display(w, h);
  W.winW := Al.get_display_width(W.display);
  W.winH := Al.get_display_height(W.display);

  IF W.pixelSize # 1.0 THEN
    W.bmp := Al.create_bitmap(wantW, wantH);
    W.w := wantW; W.h := wantH
  ELSE W.bmp := NIL
  END;

  Al.register_event_source(queue, Al.get_display_event_source(W.display));
  W.next := windowList; windowList := W
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

PROCEDURE GetWindow*(e: Event): Window;
VAR W: Window;
  d: Al.Display;
BEGIN d := e.display; W := windowList;
  WHILE (W # NIL) & (W.display # d) DO W := W.next END
RETURN W END GetWindow;

PROCEDURE ApplyResize*(e: Event);
VAR W: Window;
BEGIN Al.acknowledge_resize(e.display);
  W := GetWindow(e);
  W.w := Al.get_display_width(e.display);
  W.h := Al.get_display_height(e.display)
END ApplyResize;

PROCEDURE WaitEvent*(VAR event: Event);
VAR E: Al.Event;
  DE: Al.PDisplayEvent;
  TE: Al.PTimerEvent;
  KE: Al.PKeyboardEvent;
  ME: Al.PMouseEvent;
BEGIN Al.wait_for_event(queue, E);
  event.time := E.timestamp;
  IF E.type = Al.eventMouseAxes THEN
    event.type := mouseMove;
    ME := SYSTEM.VAL(Al.PMouseEvent, SYSTEM.ADR(E));
    event.x := ME.x; event.y := ME.y; event.z := ME.z; event.w := ME.w;
    event.dx := ME.dx; event.dy := ME.dy; event.dz := ME.dz; event.dw := ME.dw;
    event.button := ME.button;
    event.display := ME.display
  ELSIF E.type = Al.eventMouseButtonDown THEN
    event.type := mouseDown;
    ME := SYSTEM.VAL(Al.PMouseEvent, SYSTEM.ADR(E));
    event.x := ME.x; event.y := ME.y; event.z := ME.z; event.w := ME.w;
    event.button := ME.button;
    event.display := ME.display
  ELSIF E.type = Al.eventMouseButtonUp THEN
    event.type := mouseUp;
    ME := SYSTEM.VAL(Al.PMouseEvent, SYSTEM.ADR(E));
    event.x := ME.x; event.y := ME.y; event.z := ME.z; event.w := ME.w;
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
    event.display := KE.display
  ELSIF E.type = Al.eventKeyUp THEN
    event.type := keyUp;
    KE := SYSTEM.VAL(Al.PKeyboardEvent, SYSTEM.ADR(E));
    event.key := KE.keycode;
    event.display := KE.display
  ELSIF E.type = Al.eventKeyChar THEN
    event.type := char;
    KE := SYSTEM.VAL(Al.PKeyboardEvent, SYSTEM.ADR(E));
    event.key := KE.keycode;
    event.ch := CHR(KE.unichar);
    event.mod := KE.modifiers;
    event.repeat := KE.repeat;
    event.display := KE.display
  ELSIF E.type = Al.eventDisplayResize THEN
    event.type := resize;
    DE := SYSTEM.VAL(Al.PDisplayEvent, SYSTEM.ADR(E));
    event.x := DE.x; event.y := DE.y;
    event.w := DE.width; event.h := DE.height;
    event.display := DE.source
  ELSIF E.type = Al.eventDisplayClose THEN
    event.type := quit;
    event.display := SYSTEM.VAL(Al.Display, E.source)
  ELSE
    event.type := 1000 + E.type
  END
END WaitEvent;

PROCEDURE StartTimer*(timer: Timer);
BEGIN Al.start_timer(timer.tmr)
END StartTimer;

PROCEDURE InitScreen;
BEGIN
  IF ~(fullscreen IN settings) & ((wantW <= 0) OR (wantH <= 0)) THEN
    wantW := 640; wantH := 400
  END;
  screen := NewWindow(-1, -1, wantW, wantH, wantScreenTitle, settings);
  Target(screen)
END InitScreen;

PROCEDURE Init*;
BEGIN
  IF Al.install_system(Al.get_allegro_version(), 0) THEN
    IF ~Al.install_keyboard() THEN
      Out.String('Could not install keyboard.'); Out.Ln
    END;

    IF ~Al.install_mouse() THEN
      Out.String('Could not install mouse.'); Out.Ln
    END;

    IF ~Al.init_primitives_addon() THEN
      Out.String('Could not init primitives addon.'); Out.Ln
    END;

    IF ~Al.init_image_addon() THEN
      Out.String('Could not init image addon.'); Out.Ln
    END;

    queue := Al.create_event_queue();
    IF queue = NIL THEN
      Out.String('Could not create queue.'); Out.Ln
    END;

    Al.register_event_source(queue, Al.get_keyboard_event_source());
    Al.register_event_source(queue, Al.get_mouse_event_source());

    IF ~(manual IN settings) THEN InitScreen END
  ELSE Out.String('ERROR'); Out.Ln
  END
END Init;

PROCEDURE ResetDefaults;
BEGIN
  wantW := 640; wantH := 400; sizeStepX := 1; sizeStepY := 1;
  scaleX := 1.0; scaleY := 1.0;
  settings := {fullscreen};
  wantScreenTitle := 'Oberon'
END ResetDefaults;

PROCEDURE Close*;
BEGIN
  Al.uninstall_system;
  queue := NIL; windowList := NIL; screen := NIL; target := NIL;
  ResetDefaults
END Close;

BEGIN
  ResetDefaults
END Graph2.
