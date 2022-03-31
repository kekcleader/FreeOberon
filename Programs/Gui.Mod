MODULE Gui;
IMPORT G := Graph, Strings, Out;

CONST
  (* Widget.state set members *)
  hover*  = 0;
  down*   = 1;
  focus*  = 2;
  active* = 3;

TYPE
  Caption* = POINTER TO CaptionDesc;
  CaptionDesc* = RECORD
    s*: ARRAY 100 OF CHAR
  END;

  DrawHandler* = PROCEDURE (W: Widget; x, y: INTEGER);
  MouseMoveHandler* = PROCEDURE (W: Widget; x, y, btn: INTEGER);
  MouseDownHandler* = PROCEDURE (W: Widget; x, y, btn: INTEGER);
  MouseUpHandler* = PROCEDURE (W: Widget; x, y, btn: INTEGER);
  MouseEnterHandler* = PROCEDURE (W: Widget);
  MouseLeaveHandler* = PROCEDURE (W: Widget);
  ClickHandler* = PROCEDURE (W: Widget);

  Message* = POINTER TO MsgDesc;
  MsgDesc* = RECORD END;
  Handler* = PROCEDURE (W: Widget; VAR msg: Message);

  Widget* = POINTER TO WidgetDesc;
  WidgetDesc* = RECORD
    x*, y*, w*, h*: INTEGER;
    tag*: INTEGER;
    state*: SET;
    visible*: BOOLEAN;
    enabled*: BOOLEAN;
    default*: BOOLEAN;
    tabStop*: BOOLEAN;
    tabOrder*: INTEGER;
    body*: Widget;
    text*: Caption;
    bmp*: G.Bitmap;
    parent*: Widget;
    prev*, next*: Widget;
    (* Event Handlers *)
    onMouseMove*: MouseMoveHandler;
    onMouseDown*: MouseDownHandler;
    onMouseUp*: MouseUpHandler;
    onMouseEnter*: MouseEnterHandler;
    onMouseLeave*: MouseLeaveHandler;
    onClick*: ClickHandler;
    (* Message Handler *)
    handle*: Handler;
    draw*: DrawHandler
  END;

  Window* = POINTER TO WindowDesc;
  WindowDesc* = RECORD(WidgetDesc)
    win*: G.Window;
    curMouseDownWidget*: Widget; (* Widget under mouse down event is saved here *)
    curHoverWidget*: Widget (* Widget currently being pointed on by mouse *)
  END;

VAR
  Done*: BOOLEAN;
  exitRunLoop: BOOLEAN; (* See procedure Run *)
  font: G.Font;

  newWindowSettings: SET;

  globalWin: Window; (* !FIXME *)

(* Widget *)

PROCEDURE SetOnMouseMove*(W: Widget; handler: MouseMoveHandler);
BEGIN
  W.onMouseMove := handler
END SetOnMouseMove;

PROCEDURE SetOnMouseDown*(W: Widget; handler: MouseDownHandler);
BEGIN
  W.onMouseDown := handler
END SetOnMouseDown;

PROCEDURE SetOnMouseUp*(W: Widget; handler: MouseUpHandler);
BEGIN
  W.onMouseUp := handler
END SetOnMouseUp;

PROCEDURE SetOnMouseEnter*(W: Widget; handler: MouseEnterHandler);
BEGIN
  W.onMouseEnter := handler
END SetOnMouseEnter;

PROCEDURE SetOnMouseLeave*(W: Widget; handler: MouseLeaveHandler);
BEGIN
  W.onMouseLeave := handler
END SetOnMouseLeave;

PROCEDURE SetOnClick*(W: Widget; handler: ClickHandler);
BEGIN
  W.onClick := handler;
END SetOnClick;

PROCEDURE InitWidget*(w: Widget);
BEGIN
  w.x := 0; w.y := 0; w.w := 24; w.h := 24;
  w.tag := 0;
  w.state := {};
  w.visible := TRUE;
  w.enabled := TRUE;
  w.default := FALSE;
  w.tabStop := TRUE;
  w.tabOrder := 0;
  w.draw := NIL;
  w.onMouseMove := NIL;
  w.onMouseDown := NIL;
  w.onMouseUp := NIL;
  w.onMouseEnter := NIL;
  w.onMouseLeave := NIL;
  w.onClick := NIL;

  (* Замок *)
  NEW(w.body); w.body.prev := w.body; w.body.next := w.body
END InitWidget;

PROCEDURE SetText*(w: Widget; s: ARRAY OF CHAR);
BEGIN
  IF w.text = NIL THEN NEW(w.text) END;
  Strings.Copy(s, w.text.s)
END SetText;

(** Returns parent (or w) with .parent=NIL *)
PROCEDURE GetTopParent*(W: Widget): Widget;
BEGIN
  WHILE W.parent # NIL DO W := W.parent END
RETURN W END GetTopParent;

PROCEDURE UnsetAllDefaultsInside*(W: Widget);
VAR p: Widget;
BEGIN
  W.default := FALSE;
  p := W.body.next;
  WHILE p # W.body DO
    UnsetAllDefaultsInside(p);
    p := p.next
  END
END UnsetAllDefaultsInside;

PROCEDURE UnsetAllDefaultsOutside*(W: Widget);
BEGIN
  UnsetAllDefaultsInside(GetTopParent(W))
END UnsetAllDefaultsOutside;

PROCEDURE SetDefault*(W: Widget; value: BOOLEAN);
BEGIN
  IF ~W.default & value THEN UnsetAllDefaultsOutside(W) END;
  W.default := value;
  INCL(W.state, active)
END SetDefault;

PROCEDURE SetEnabled*(w: Widget; value: BOOLEAN);
BEGIN
  w.enabled := value
END SetEnabled;

PROCEDURE SetVisible*(w: Widget; value: BOOLEAN);
BEGIN
  w.visible := value
END SetVisible;

PROCEDURE Place*(where, what: Widget; x, y: INTEGER);
BEGIN
  what.x := x; what.y := y;

  (* Добавление в кольцо с замком *)
  what.prev := where.body.prev;
  what.next := where.body;
  where.body.prev.next := what;
  where.body.prev := what;

  what.parent := where;

  IF what.default THEN
    UnsetAllDefaultsOutside(what);
    what.default := TRUE
  END
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
  G.MakeCol(c, 212, 208, 200);
  G.ClearToColor(c);

  DrawBody(W, x, y)
END DrawWindow;

PROCEDURE InitWindow*(win: Window; w, h: INTEGER);
BEGIN
  InitWidget(win);
  win.win := G.NewWindow(-1, -1, w, h,
    'Window', newWindowSettings);
  win.x := 0; win.y := 0;
  win.w := win.win.w; win.h := win.win.h;
  win.curMouseDownWidget := NIL;
  win.curHoverWidget := win;
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
  G.Flip;
  G.Delay(1)
END DrawAll;

(* Fonts *)

PROCEDURE GetFont*(W: Widget): G.Font;
RETURN font END GetFont;

(* General *)

PROCEDURE TriggerOnMouseMove*(W: Widget; x, y, btn: INTEGER);
BEGIN
  IF (W # NIL) & (W.onMouseMove # NIL) THEN
    W.onMouseMove(W, x, y, btn)
  END
END TriggerOnMouseMove;

PROCEDURE TriggerOnMouseDown*(W: Widget; x, y, btn: INTEGER);
BEGIN
  IF (W # NIL) & (W.onMouseDown # NIL) THEN
    W.onMouseDown(W, x, y, btn)
  END
END TriggerOnMouseDown;

PROCEDURE TriggerOnMouseUp*(W: Widget; x, y, btn: INTEGER);
BEGIN
  IF (W # NIL) & (W.onMouseUp # NIL) THEN
    W.onMouseUp(W, x, y, btn)
  END
END TriggerOnMouseUp;

PROCEDURE TriggerOnMouseEnter*(W: Widget);
BEGIN
  IF (W # NIL) & (W.onMouseEnter # NIL) THEN W.onMouseEnter(W) END
END TriggerOnMouseEnter;

PROCEDURE TriggerOnMouseLeave*(W: Widget);
BEGIN
  IF (W # NIL) & (W.onMouseLeave # NIL) THEN W.onMouseLeave(W) END
END TriggerOnMouseLeave;

PROCEDURE TriggerOnClick*(W: Widget);
BEGIN
  IF (W # NIL) & (W.onClick # NIL) THEN
    W.onClick(W)
  END
END TriggerOnClick;

PROCEDURE FindWidgetUnderMouse*(W: Widget; VAR x, y: INTEGER): Widget;
VAR p: Widget;
BEGIN
  IF W = NIL THEN p := NIL
  ELSIF W.body # NIL THEN
    p := W.body.prev;
    WHILE (p # W.body) &
          ~((p.x <= x) & (x < p.x + p.w) &
            (p.y <= y) & (y < p.y + p.h))
    DO p := p.prev
    END;
    IF p = W.body THEN p := W
    ELSE DEC(x, p.x); DEC(y, p.y);
      p := FindWidgetUnderMouse(p, x, y)
    END
  ELSE p := W
  END
RETURN p END FindWidgetUnderMouse;

(** Input: (x; y) relative to window.
    Output: (x; y) relative to widget. *)
PROCEDURE WindowToWidgetXY*(W: Widget; VAR x, y: INTEGER);
BEGIN
  WHILE (W # NIL) & ~(W IS Window) DO
    DEC(x, W.x); DEC(y, W.y);
    W := W.parent
  END
END WindowToWidgetXY;

(** Returns TRUE if first widget is parent of second. *)
PROCEDURE IsParent*(a, b: Widget): BOOLEAN;
BEGIN
  WHILE (b # NIL) & (a # b) DO b := b.parent END
RETURN (a # NIL) & (a = b) END IsParent;

PROCEDURE MouseLeaveCascade(from, to: Widget);
VAR p: Widget;
BEGIN
  p := from;
  WHILE (p # NIL) & (p # to) & ~IsParent(p, to) DO
    EXCL(p.state, hover);
    TriggerOnMouseLeave(p);
    p := p.parent
  END
END MouseLeaveCascade;

PROCEDURE MouseEnterCascade(from, to: Widget);
VAR p: Widget;
  m: ARRAY 100 OF Widget;
  len: INTEGER;
BEGIN
  len := 0;

  p := to;
  WHILE (p # NIL) & (p # from) & ~IsParent(p, from) DO
    INCL(p.state, hover);
    IF len < LEN(m) THEN
      m[len] := p;
      INC(len)
    END;
    p := p.parent
  END;

  WHILE len > 0 DO
    DEC(len);
    TriggerOnMouseEnter(m[len])
  END
END MouseEnterCascade;

PROCEDURE HandleMouseMoveEvent*(e: G.Event);
VAR W: Widget;
  x, y: INTEGER;
BEGIN
  x := e.x; y := e.y;
  IF globalWin.curMouseDownWidget # NIL THEN
    W := globalWin.curMouseDownWidget;
    WindowToWidgetXY(W, x, y);
    IF (x >= 0) & (y >= 0) & (W.w > x) & (W.h > y) & (1 IN e.buttons) THEN
      INCL(W.state, down)
    ELSE EXCL(W.state, down)
    END
  ELSE
    W := FindWidgetUnderMouse(globalWin, x, y);
    IF globalWin.curHoverWidget # W THEN
      MouseLeaveCascade(globalWin.curHoverWidget, W);
      MouseEnterCascade(globalWin.curHoverWidget, W);
      globalWin.curHoverWidget := W
    END
  END;
  IF W # NIL THEN
    TriggerOnMouseMove(W, x, y, e.button)
  END
END HandleMouseMoveEvent;

PROCEDURE HandleMouseDownEvent*(e: G.Event);
VAR W: Widget;
  x, y: INTEGER;
BEGIN
  x := e.x; y := e.y;
  W := FindWidgetUnderMouse(globalWin, x, y);
  IF W # NIL THEN
    IF e.button = 1 THEN
      INCL(W.state, down) (* Mark button as being left-mouse-button-down *)
    END;
    globalWin.curMouseDownWidget := W; (* Save for future mouse up event *)
    TriggerOnMouseDown(W, x, y, e.button)
  END
END HandleMouseDownEvent;

PROCEDURE HandleMouseUpEvent*(e: G.Event);
VAR W: Widget;
  x, y: INTEGER;
BEGIN
  x := e.x; y := e.y;
  W := globalWin.curMouseDownWidget;
  globalWin.curMouseDownWidget := NIL;
  IF W # NIL THEN
    WindowToWidgetXY(W, x, y);
    EXCL(W.state, down);
    TriggerOnMouseUp(W, x, y, e.button);
    IF (x >= 0) & (y >= 0) & (W.w > x) & (W.h > y) & (e.button = 1) THEN
      TriggerOnClick(W)
    END
  END
END HandleMouseUpEvent;

PROCEDURE HandleEvent(e: G.Event);
BEGIN
  IF e.type = G.mouseMove THEN
    HandleMouseMoveEvent(e)
  ELSIF e.type = G.mouseDown THEN
    HandleMouseDownEvent(e)
  ELSIF e.type = G.mouseUp THEN
    HandleMouseUpEvent(e)
  ELSIF e.type = G.keyDown THEN
    IF e.key = G.kEsc THEN exitRunLoop := TRUE END;
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
  Done := TRUE
END Gui.