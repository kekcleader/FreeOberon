MODULE Gui;
IMPORT G := Graph, Strings, Out;

TYPE
  Caption* = POINTER TO CaptionDesc;
  CaptionDesc* = RECORD
    s*: ARRAY 100 OF CHAR
  END;

  DrawHandler* = PROCEDURE (W: Widget; x, y: INTEGER);
  MouseDownHandler* = PROCEDURE (W: Widget; x, y, btn: INTEGER);

  Widget* = POINTER TO WidgetDesc;
  WidgetDesc* = RECORD
    x*, y*, w*, h*: INTEGER;
    body*: Widget;
    text*: Caption;
    bmp*: G.Bitmap;
    parent*: Widget;
    prev*, next*: Widget;
    draw*: DrawHandler;
    (* Event Handlers *)
    onMouseDown*: MouseDownHandler
  END;

  Window* = POINTER TO WindowDesc;
  WindowDesc* = RECORD(WidgetDesc)
    win*: G.Window
  END;

VAR
  Done*: BOOLEAN;
  exitRunLoop: BOOLEAN; (* See procedure Run *)
  font: G.Font;

  newWindowSettings: SET;
  ZZZ: INTEGER;

  globalWin: Window; (* !FIXME *)

(* Widget *)

PROCEDURE SetOnMouseDown*(W: Widget; handler: MouseDownHandler);
BEGIN
  W.onMouseDown := handler
END SetOnMouseDown;

PROCEDURE InitWidget*(w: Widget);
BEGIN
  w.x := 0; w.y := 0; w.w := 24; w.h := 24;
  w.draw := NIL;
  w.onMouseDown := NIL;

  (* Замок *)
  NEW(w.body); w.body.prev := w.body; w.body.next := w.body
END InitWidget;

PROCEDURE SetText*(w: Widget; s: ARRAY OF CHAR);
BEGIN
  IF w.text = NIL THEN NEW(w.text) END;
  Strings.Copy(s, w.text.s)
END SetText;

PROCEDURE Place*(where, what: Widget; x, y: INTEGER);
BEGIN
  what.x := x; what.y := y;

  (* Добавление в кольцо с замком *)
  what.prev := where.body.prev;
  what.next := where.body;
  where.body.prev.next := what;
  where.body.prev := what
END Place;

(* Window *)

PROCEDURE NewWindowSettings*(settings: SET);
BEGIN
  newWindowSettings := settings
END NewWindowSettings;

PROCEDURE DrawWidget(W: Widget; x, y: INTEGER);
BEGIN
  W.draw(W, x + W.x, y + W.y)
END DrawWidget;

PROCEDURE DrawBody*(W: Widget; x, y: INTEGER);
VAR p: Widget;
BEGIN
  p := W.body.next;
  WHILE p # W.body DO
    DrawWidget(p, x, y);
    p := p.next
  END
END DrawBody;

PROCEDURE DrawWindow*(W: Widget; x, y: INTEGER);
VAR c: G.Color;
  w, h: INTEGER;
BEGIN
  G.MakeCol(c, ZZZ * 40 MOD 256, 120, 120);
  G.ClearToColor(c);
  G.MakeCol(c, 0, 0, ZZZ * 20 MOD 256);
  G.GetScreenSize(w, h);
  G.Rect(5, 5, w - 6, h - 6, c);

  DrawBody(W, x, y)
END DrawWindow;

PROCEDURE InitWindow*(win: Window; w, h: INTEGER);
BEGIN
  InitWidget(win);
  win.win := G.NewWindow(-1, -1, w, h,
    'Window', newWindowSettings);
  win.x := 0; win.y := 0;
  win.w := win.win.w; win.h := win.win.h;
  win.draw := DrawWindow
END InitWindow;

PROCEDURE NewWindow*(w, h: INTEGER): Window;
VAR win: Window;
BEGIN
  NEW(win);
  InitWindow(win, w, h);
  globalWin := win
RETURN win END NewWindow;

(* Draw *)

PROCEDURE DrawAll;
BEGIN
  globalWin.draw(globalWin, 0, 0);
  G.Flip
END DrawAll;

(* Fonts *)

PROCEDURE GetFont*(W: Widget): G.Font;
RETURN font END GetFont;

(* General *)

PROCEDURE TriggerOnMouseDown*(W: Widget; x, y, btn: INTEGER);
BEGIN
  IF (W # NIL) & (W.onMouseDown # NIL) THEN
    W.onMouseDown(W, x, y, btn)
  END
END TriggerOnMouseDown;

PROCEDURE FindWidgetUnderMouse*(W: Widget; VAR x, y: INTEGER): Widget;
VAR p: Widget;
BEGIN
  IF W = NIL THEN p := W
  ELSIF W.body # NIL THEN
    p := W.body.prev;
    WHILE (p # W.body) &
          ~((p.x <= x) & (x < p.x + p.w) &
            (p.y <= y) & (y < p.y + p.h))
    DO p := p.prev
    END;
    IF p = W.body THEN p := W END
  ELSE p := NIL
  END
RETURN p END FindWidgetUnderMouse;

PROCEDURE HandleMouseDownEvent*(e: G.Event);
VAR W: Widget;
  x, y: INTEGER;
BEGIN
  x := e.x; y := e.y;
  W := FindWidgetUnderMouse(globalWin, x, y);
  TriggerOnMouseDown(W, x, y, e.button)
END HandleMouseDownEvent;

PROCEDURE HandleEvent(e: G.Event);
BEGIN
  IF e.type = G.mouseDown THEN
    HandleMouseDownEvent(e)
  ELSIF e.type = G.keyDown THEN
    IF e.key = G.kEsc THEN exitRunLoop := TRUE END;
    INC(ZZZ)
  ELSIF e.type = G.quit THEN
    exitRunLoop := TRUE
  END
END HandleEvent;

PROCEDURE Run*;
VAR e: G.Event;
BEGIN
  exitRunLoop := FALSE;
  REPEAT
    WHILE G.HasEvents() DO
      G.WaitEvent(e);
      HandleEvent(e)
    END;
    DrawAll
  UNTIL exitRunLoop
END Run;

PROCEDURE Init*;
BEGIN
  G.Settings(0, 0, {G.manual});
  G.Init;
  IF G.Done THEN
    font := G.LoadFont('../Data/Fonts/Main');
    IF font = NIL THEN
      Out.String('Gui: Could not load font.'); Out.Ln;
      Done := FALSE
    END
  ELSE Done := FALSE
  END
END Init;

PROCEDURE Close*;
BEGIN
  G.Close
END Close;

BEGIN
  Done := TRUE;
  ZZZ := 0
END Gui.