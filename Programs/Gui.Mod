MODULE Gui;
IMPORT G := Graph, Strings, Out;

TYPE
  Caption* = POINTER TO CaptionDesc;
  CaptionDesc* = RECORD
    s*: ARRAY 100 OF CHAR
  END;

  DrawHandler* = PROCEDURE (W: Widget; x, y: INTEGER);

  Widget* = POINTER TO WidgetDesc;
  WidgetDesc* = RECORD
    x*, y*, w*, h*: INTEGER;
    body*: Widget;
    text*: Caption;
    bmp*: G.Bitmap;
    parent*: Widget;
    prev*, next*: Widget;
    draw*: DrawHandler
  END;

  Window* = POINTER TO WindowDesc;
  WindowDesc* = RECORD(WidgetDesc)
    win*: G.Window
  END;

VAR
  Done*: BOOLEAN;
  exitRunLoop: BOOLEAN; (* See procedure Run *)
  font: G.Font;

  newWindowW, newWindowH: INTEGER;
  newWindowSettings: SET;
  ZZZ: INTEGER;

  globalWin: Window; (* !FIXME *)

(* Widget *)

PROCEDURE InitWidget*(w: Widget);
BEGIN
  w.x := 0; w.y := 0; w.w := 24; w.h := 24;
  w.draw := NIL;

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

PROCEDURE NewWindowSettings*(w, h: INTEGER; settings: SET);
BEGIN
  newWindowW := w;
  newWindowH := h;
  newWindowSettings := settings
END NewWindowSettings;

PROCEDURE DrawBody*(W: Widget; x, y: INTEGER);
VAR p: Widget;
BEGIN
  p := W.body.next;
  WHILE p # W.body DO
    p.draw(p, x + p.x, y + p.y);
    p := p.next
  END
END DrawBody;

PROCEDURE DrawWindow*(W: Widget; x, y: INTEGER);
VAR c: G.Color;
  w, h: INTEGER;
BEGIN
  G.MakeCol(c, ZZZ * 40 MOD 256, 0, 0);
  G.ClearToColor(c);
  G.MakeCol(c, 0, 0, ZZZ * 20 MOD 256);
  G.GetScreenSize(w, h);
  G.Rect(5, 5, w - 6, h - 6, c);

  DrawBody(W, x, y)
END DrawWindow;

PROCEDURE InitWindow*(win: Window);
BEGIN
  InitWidget(win);
  win.win := G.NewWindow(-1, -1, newWindowW, newWindowH,
    'Window', newWindowSettings);
  win.x := 0; win.y := 0;
  win.w := win.win.w; win.h := win.win.h;
  win.draw := DrawWindow
END InitWindow;

PROCEDURE NewWindow*(): Window;
VAR win: Window;
BEGIN
  NEW(win);
  InitWindow(win);
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

PROCEDURE HandleEvent(e: G.Event);
BEGIN
  IF e.type = G.keyDown THEN
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