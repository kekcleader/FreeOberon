MODULE SimpleGui;
IMPORT G := Graph, Strings, Out;

TYPE
  Widget* = POINTER TO WidgetDesc;

  Message* = RECORD END;
  DrawMsg* = RECORD(Message) x*, y*, w*, h*: INTEGER END;
  MouseMoveMsg* = RECORD(Message) x*, y*, btn*: INTEGER END;
  MouseDownMsg* = RECORD(Message) x*, y*, btn*: INTEGER END;
  MouseUpMsg* = RECORD(Message) x*, y*, btn*: INTEGER END;
  MouseEnterMsg* = RECORD(Message) END;
  MouseLeaveMsg* = RECORD(Message) END;
  ClickMsg* = RECORD(Message) END;
  GetFocusMsg* = RECORD(Message) END;
  LostFocusMsg* = RECORD(Message) END;
  KeyDownMsg* = RECORD(Message) key*: INTEGER END;
  KeyUpMsg* = RECORD(Message) key*: INTEGER END;
  CharMsg* = RECORD(Message)
    key*: INTEGER;
    ch*: CHAR;
    mod*: SET;
    repeat*: BOOLEAN
  END;

  Handler* = PROCEDURE (c: Widget; VAR msg: Message);

  WidgetDesc* = RECORD
    x*, y*, w*, h*: INTEGER;
    bgColor*, fgColor*: G.Color;
    focusable*: BOOLEAN; (** TRUE if widget can get focus *)
    focused*: BOOLEAN; (** TRUE if this widget is globally in focus *)
    hovered*: BOOLEAN; (** TRUE if mouse pointer is over the widget *)
    pressed*: BOOLEAN; (** TRUE if widget is held down with LMB *)
    body*: Widget; (** Ring *)
    prev*, next*, parent*: Widget;
    handle*: Handler;

    onMouseDown*: PROCEDURE (c: Widget; x, y, btn: INTEGER);
    onMouseUp*: PROCEDURE (c: Widget; x, y, btn: INTEGER);
    onMouseMove*: PROCEDURE (c: Widget; x, y, btn: INTEGER);
    onMouseEnter*: PROCEDURE (c: Widget);
    onMouseLeave*: PROCEDURE (c: Widget);
    onClick*: PROCEDURE (c: Widget);
    onKeyDown*: PROCEDURE (c: Widget; key: INTEGER);
    onKeyUp*: PROCEDURE (c: Widget; key: INTEGER);
    onChar*: PROCEDURE (c: Widget; key: INTEGER; ch: CHAR; mod: SET; repeat: BOOLEAN);
  END;

  Panel* = POINTER TO PanelDesc;
  PanelDesc* = RECORD(WidgetDesc) END;

  Form* = POINTER TO FormDesc;
  FormDesc* = RECORD(PanelDesc) END;

  Button* = POINTER TO ButtonDesc;
  ButtonDesc* = RECORD(WidgetDesc)
    caption*: ARRAY 64 OF CHAR
    ;X*, Y*: INTEGER
  END;

  Edit* = POINTER TO EditDesc;
  EditDesc* = RECORD(WidgetDesc)
    text*: ARRAY 256 OF CHAR;
    len*: INTEGER; (** Length of text in characters *)
    pos*: INTEGER; (** Position of text carret, in range [0; len] *)
    off*: INTEGER (** Used to slide text that does not fit, normal is 0 *)
  END;

VAR
  Done*: BOOLEAN; (** FALSE after a failed opration and before the next Init *)
  forms*: Widget;
  focusedWidget*: Widget; (** The widget with focus = TRUE *)
  font*: G.Font;
  quit: BOOLEAN; (** Main loop in procedure Run ends when TRUE *)
  hoveredWidget: Widget;
  pressedWidget: Widget;
  pressedX, pressedY: INTEGER;

(** Widget **)

PROCEDURE FindHoveredInList(list: Widget; x, y: INTEGER;
    forMouseDown: BOOLEAN): Widget;
VAR c: Widget;
BEGIN
  IF list # NIL THEN
    c := list.prev;
    WHILE (c # NIL) &
          ~((c.x <= x) & (x < c.x + c.w) &
            (c.y <= y) & (y < c.y + c.h))
    DO
      IF c = list THEN c := NIL ELSE c := c.prev END
    END;
    IF forMouseDown & (c # NIL) THEN
      INC(pressedX, c.x); INC(pressedY, c.y)
    END
  ELSE c := NIL
  END
RETURN c END FindHoveredInList;

PROCEDURE WidgetOnMouseEnter*(c: Widget);
VAR msg: MouseEnterMsg;
BEGIN
  IF pressedWidget = c THEN c.pressed := TRUE END;
  c.handle(c, msg)
END WidgetOnMouseEnter;

PROCEDURE WidgetOnMouseLeave*(c: Widget);
VAR msg: MouseLeaveMsg;
BEGIN
  c.pressed := FALSE;
  c.handle(c, msg)
END WidgetOnMouseLeave;

PROCEDURE WidgetOnMouseMove*(c: Widget; x, y, btn: INTEGER);
VAR msg: MouseMoveMsg;
BEGIN
  IF (0 <= x) & (x < c.w) & (0 <= y) & (y < c.h) THEN
    IF c # hoveredWidget THEN
      IF hoveredWidget # NIL THEN WidgetOnMouseLeave(hoveredWidget) END;
      hoveredWidget := c;
      WidgetOnMouseEnter(hoveredWidget)
    END
  ELSIF c = hoveredWidget THEN
    WidgetOnMouseLeave(c);
    hoveredWidget := NIL
  END;

  msg.x := x; msg.y := y; msg.btn := btn;
  c.handle(c, msg);

  IF c.onMouseMove # NIL THEN c.onMouseMove(c, x, y, btn) END
END WidgetOnMouseMove;

PROCEDURE WidgetHandleMouseMove*(c: Widget; x, y, btn: INTEGER);
VAR p: Widget;
BEGIN
  IF pressedWidget # NIL THEN
    WidgetOnMouseMove(pressedWidget, x - pressedX, y - pressedY, btn)
  ELSE
    p := FindHoveredInList(c.body, x, y, FALSE);
    IF p # NIL THEN
      WidgetHandleMouseMove(p, x - p.x, y - p.y, btn)
    ELSE
      WidgetOnMouseMove(c, x, y, btn)
    END
  END
END WidgetHandleMouseMove;

PROCEDURE Focus*(c: Widget);
VAR get: GetFocusMsg;
  lost: LostFocusMsg;
BEGIN
  IF c.focusable THEN
    IF focusedWidget # NIL THEN
      focusedWidget.focused := FALSE;
      focusedWidget.handle(focusedWidget, lost)
    END;
    c.focused := TRUE;
    focusedWidget := c;
    focusedWidget.handle(focusedWidget, get)
  END
END Focus;

PROCEDURE WidgetOnMouseDown*(c: Widget; x, y, btn: INTEGER);
VAR msg: MouseDownMsg;
BEGIN
  pressedWidget := c;
  Focus(c);
  msg.x := x; msg.y := y; msg.btn := btn;
  c.handle(c, msg);
  IF c.onMouseDown # NIL THEN c.onMouseDown(c, x, y, btn) END
END WidgetOnMouseDown;

PROCEDURE WidgetHandleMouseDown*(c: Widget; x, y, btn: INTEGER);
VAR p: Widget;
BEGIN
  p := FindHoveredInList(c.body, x, y, TRUE);
  IF p # NIL THEN
    WidgetHandleMouseDown(p, x - p.x, y - p.y, btn)
  ELSE
    WidgetOnMouseDown(c, x, y, btn)
  END
END WidgetHandleMouseDown;

PROCEDURE WidgetOnMouseUp*(c: Widget; x, y, btn: INTEGER);
VAR msg: MouseUpMsg;
BEGIN
  pressedWidget := NIL;
  msg.x := x; msg.y := y; msg.btn := btn;
  c.handle(c, msg);
  IF c.onMouseUp # NIL THEN c.onMouseUp(c, x, y, btn) END
END WidgetOnMouseUp;

PROCEDURE WidgetOnClick*(c: Widget);
VAR msg: ClickMsg;
BEGIN c.handle(c, msg);
  IF c.onClick # NIL THEN c.onClick(c) END
END WidgetOnClick;

PROCEDURE WidgetHandler*(c: Widget; VAR msg: Message);
VAR x, y: INTEGER;
BEGIN
  IF msg IS DrawMsg THEN
    x := msg(DrawMsg).x; y := msg(DrawMsg).y;
    G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);
    G.Rect(x, y, x + c.w - 1, y + c.h - 1, c.fgColor);
    G.Rect(x + 2, y + 2, x + c.w - 3, y + c.h - 3, c.fgColor)
  END
END WidgetHandler;

PROCEDURE DrawWidget*(c: Widget; x, y, w, h: INTEGER);
VAR M: DrawMsg;
BEGIN
  M.x := x; M.y := y; M.w := w; M.h := h;
  c.handle(c, M)
END DrawWidget;

PROCEDURE DrawBody*(c: Widget; x, y, w, h: INTEGER);
VAR p: Widget;
  x2, y2, w2, h2: INTEGER;
  cx, cy, cw, ch: INTEGER;
BEGIN
  p := c.body;
  IF p # NIL THEN
    REPEAT
      x2 := x + p.x; y2 := y + p.y;
      w2 := w - p.x; h2 := h - p.y;

      cx := x2; cy := y2; cw := p.w; ch := p.h;
      IF cx + cw > x + w THEN cw := x + w - cx END;
      IF cy + ch > y + h THEN ch := y + h - cy END;
      IF cx < x THEN DEC(cw, x - cx); cx := x END;
      IF cy < y THEN DEC(ch, y - cy); cy := y END;
      G.SetClip(cx, cy, cw, ch);

      DrawWidget(p, x2, y2, p.w, p.h);
      p := p.next
    UNTIL p = c.body;
    G.UnsetClip
  END
END DrawBody;

PROCEDURE SetBgColor*(c: Widget; color: G.Color);
BEGIN c.bgColor := color
END SetBgColor;

PROCEDURE SetFgColor*(c: Widget; color: G.Color);
BEGIN c.fgColor := color
END SetFgColor;

PROCEDURE SetOnMouseMove*(c: Widget; proc: PROCEDURE (c: Widget; x, y, btn: INTEGER));
BEGIN c.onMouseMove := proc
END SetOnMouseMove;

PROCEDURE SetOnMouseDown*(c: Widget; proc: PROCEDURE (c: Widget; x, y, btn: INTEGER));
BEGIN c.onMouseDown := proc
END SetOnMouseDown;

PROCEDURE SetOnMouseUp*(c: Widget; proc: PROCEDURE (c: Widget; x, y, btn: INTEGER));
BEGIN c.onMouseUp := proc
END SetOnMouseUp;

PROCEDURE SetOnClick*(c: Widget; proc: PROCEDURE (c: Widget));
BEGIN c.onClick := proc
END SetOnClick;

PROCEDURE InitWidget*(c: Widget; w, h: INTEGER);
BEGIN c.x := 0; c.y := 0; c.w := w; c.h := h;
  c.focusable := FALSE; c.focused := FALSE;
  c.hovered := FALSE; c.pressed := FALSE;
  G.MakeCol(c.bgColor, 180, 180, 180);
  G.MakeCol(c.fgColor, 0, 0, 0);
  c.handle := WidgetHandler
END InitWidget;

PROCEDURE AppendToRing*(c: Widget; VAR ring: Widget);
BEGIN
  IF ring = NIL THEN
    ring := c;
    c.prev := c; c.next := c
  ELSE
    c.next := ring; c.prev := ring.prev;
    ring.prev.next := c; ring.prev := c
  END
END AppendToRing;

PROCEDURE Put*(c, where: Widget; x, y: INTEGER);
VAR p: Widget;
BEGIN
  IF (c # NIL) & (where # NIL) THEN
    c.x := x; c.y := y;
    AppendToRing(c, where.body)
  END
END Put;

(** Panel **)

PROCEDURE PanelHandler*(c: Widget; VAR msg: Message);
VAR x, y: INTEGER;
BEGIN
  IF msg IS DrawMsg THEN
    x := msg(DrawMsg).x; y := msg(DrawMsg).y;
    G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);
    DrawBody(c, x, y, c.w, c.h)
  ELSE WidgetHandler(c, msg)
  END
END PanelHandler;

PROCEDURE InitPanel*(c: Panel; where: Widget; x, y, w, h: INTEGER);
BEGIN InitWidget(c, w, h);
  c.handle := PanelHandler;
  Put(c, where, x, y)
END InitPanel;

PROCEDURE NewPanel*(where: Widget; x, y, w, h: INTEGER): Panel;
VAR c: Panel;
BEGIN NEW(c); InitPanel(c, where, x, y, w, h)
RETURN c END NewPanel;

(** Form **)

PROCEDURE DrawForm*(c: Form);
BEGIN
  G.FillRect(c.x, c.y, c.x + c.w - 1, c.y + c.h - 1, c.bgColor);
  DrawBody(c, c.x, c.y, c.w, c.h)
END DrawForm;

PROCEDURE FormHandler*(c: Widget; VAR msg: Message);
BEGIN WidgetHandler(c, msg)
END FormHandler;

PROCEDURE InitForm*(c: Form; x, y, w, h: INTEGER);
BEGIN InitPanel(c, NIL, x, y, w, h);
  c.handle := FormHandler;
  AppendToRing(c, forms)
END InitForm;

PROCEDURE NewForm*(x, y, w, h: INTEGER): Form;
VAR c: Form;
BEGIN NEW(c); InitForm(c, x, y, w, h);
RETURN c END NewForm;

(** Button **)

PROCEDURE DrawButton*(c: Button; x, y, w, h: INTEGER);
VAR fw, fh, tw, tx, ty: INTEGER;
  down: BOOLEAN;
  Z: G.Color;
BEGIN
  down := c.pressed & c.hovered;
  G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);

  ;G.MakeCol(Z, 255, 128, 0);
  ;G.Line(x + c.h DIV 4, y + c.h DIV 2, x + c.X, y + c.Y, Z);
  ;G.MakeCol(Z, 215, 0, 0);
  ;G.Line(x + c.h DIV 4, y + c.h DIV 2 + 1, x + c.X, y + c.Y + 1, Z);

  G.Rect(x, y, x + c.w - 1, y + c.h - 1, c.fgColor);
  IF ~down THEN
    G.Rect(x, y, x + c.w - 2, y + c.h - 2, c.fgColor)
  END;
  G.GetMonoFontSize(font, fw, fh);
  tw := Strings.Length(c.caption) * fw;
  tx := x + (c.w - tw) DIV 2;
  ty := y + (c.h - fh) DIV 2;
  IF down THEN INC(tx); INC(ty) END;
  G.DrawString(c.caption, tx, ty, font, c.fgColor)
END DrawButton;

PROCEDURE BMM(c: Button; x, y: INTEGER);
BEGIN
  c.X := x; c.Y := y
END BMM;

PROCEDURE ButtonHandler*(c: Widget; VAR msg: Message);
VAR b: Button;
BEGIN b := c(Button);
  IF msg IS DrawMsg THEN
    DrawButton(b, msg(DrawMsg).x, msg(DrawMsg).y,
        msg(DrawMsg).w, msg(DrawMsg).h)
  ELSIF msg IS MouseMoveMsg THEN BMM(b, msg(MouseMoveMsg).x, msg(MouseMoveMsg).y)
  ELSIF msg IS MouseEnterMsg THEN b.hovered := TRUE
  ELSIF msg IS MouseLeaveMsg THEN b.hovered := FALSE
  ELSIF msg IS MouseDownMsg THEN
    IF msg(MouseDownMsg).btn = 1 THEN b.pressed := TRUE END
  ELSIF msg IS MouseUpMsg THEN b.pressed := FALSE
  ELSE WidgetHandler(c, msg)
  END
END ButtonHandler;

PROCEDURE InitButton*(c: Button; where: Widget;
    x, y, w, h: INTEGER; caption: ARRAY OF CHAR);
BEGIN InitWidget(c, w, h);
  Strings.Copy(caption, c.caption);
  c.focusable := TRUE;
  c.handle := ButtonHandler;
  Put(c, where, x, y)
  ;c.X := 0; c.Y := 0;
END InitButton;

PROCEDURE NewButton*(where: Widget; x, y, w, h: INTEGER; caption: ARRAY OF CHAR): Button;
VAR c: Button;
BEGIN NEW(c); InitButton(c, where, x, y, w, h, caption)
RETURN c END NewButton;

(** Edit **)

PROCEDURE DrawEdit*(c: Edit; x, y, w, h: INTEGER);
VAR fw, fh, tw, tx, ty: INTEGER;
  down: BOOLEAN;
  red: G.Color;
BEGIN
  G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);
  G.GetMonoFontSize(font, fw, fh);
  tw := Strings.Length(c.text) * fw;
  tx := x + 2 - c.off;
  ty := y + (c.h - fh) DIV 2;
  G.DrawString(c.text, tx, ty, font, c.fgColor);
  IF c.focused THEN
    G.MakeCol(red, 250, 0, 0);
    INC(tx, fw * c.pos - 1);
    G.VLine(tx, ty, ty + fh - 1, red);
    G.HLine(tx - 1, ty, tx + 1, red);
    G.HLine(tx - 1, ty + fh - 1, tx + 1, red)
  END;
  G.Rect(x, y, x + c.w - 1, y + c.h - 1, c.fgColor)
END DrawEdit;

PROCEDURE EditOnMouseDown*(c: Edit; VAR msg: MouseDownMsg);
VAR n, fw, fh: INTEGER;
BEGIN
  IF (msg.btn = 1) & (msg.x > 0) & (msg.x < c.w - 1) &
     (msg.y > 0) & (msg.y < c.h - 1)
  THEN
    G.GetMonoFontSize(font, fw, fh);
    n := (msg.x - 2 + fw DIV 2) DIV fw;
    IF n < 0 THEN n := 0 ELSIF n > c.len THEN n := c.len END;
    c.pos := n
  END
END EditOnMouseDown;

PROCEDURE EditCheckOffset(c: Edit);
VAR n, fw, fh: INTEGER;
BEGIN
  G.GetMonoFontSize(font, fw, fh);
  n := c.pos * fw - c.off;
  IF c.len * fw <= c.w - 4 THEN c.off := 0
  ELSIF n < 0 THEN c.off := c.pos * fw
  ELSIF n >= c.w - 4 THEN c.off := c.pos * fw - c.w + 4
  ELSIF c.len * fw - c.off <= c.w - 4 THEN c.off := c.len * fw - c.w + 4
  END
END EditCheckOffset;

PROCEDURE EditOnChar*(c: Edit; VAR msg: CharMsg);
VAR i: INTEGER;
BEGIN
  IF msg.key = G.kBackspace THEN
    IF c.pos > 0 THEN
      Strings.Delete(c.text, c.pos - 1, 1);
      DEC(c.len); DEC(c.pos)
    END
  ELSIF msg.key = G.kDel THEN
    IF c.pos < c.len THEN
      Strings.Delete(c.text, c.pos, 1);
      DEC(c.len)
    END
  ELSIF msg.ch < ' ' THEN
    IF msg.key = G.kLeft THEN DEC(c.pos)
    ELSIF msg.key = G.kRight THEN INC(c.pos)
    ELSIF msg.key = G.kHome THEN c.pos := 0
    ELSIF msg.key = G.kEnd THEN c.pos := c.len
    END;
    IF c.pos < 0 THEN c.pos := 0 ELSIF c.pos > c.len THEN c.pos := c.len END
  ELSIF c.len < LEN(c.text) - 1 THEN
    c.text[c.len + 1] := 0X;
    i := c.len;
    WHILE i > c.pos DO
      c.text[i] := c.text[i - 1];
      DEC(i)
    END;
    c.text[c.pos] := msg.ch;
    INC(c.len); INC(c.pos)
  END;
  EditCheckOffset(c)
END EditOnChar;

PROCEDURE EditHandler*(c: Widget; VAR msg: Message);
VAR e: Edit;
BEGIN e := c(Edit);
  IF msg IS DrawMsg THEN
    DrawEdit(e, msg(DrawMsg).x, msg(DrawMsg).y,
        msg(DrawMsg).w, msg(DrawMsg).h)
  ELSIF msg IS MouseDownMsg THEN EditOnMouseDown(e, msg(MouseDownMsg))
  ELSIF msg IS CharMsg THEN EditOnChar(e, msg(CharMsg))
  ELSE WidgetHandler(c, msg)
  END
END EditHandler;

PROCEDURE InitEdit*(c: Edit; where: Widget; x, y, w, h: INTEGER);
BEGIN InitWidget(c, w, h);
  c.focusable := TRUE;
  G.MakeCol(c.bgColor, 255, 255, 255);
  c.text := 'Привет'; c.len := 6; c.pos := 2; c.off := 0;
  c.handle := EditHandler;
  Put(c, where, x, y)
END InitEdit;

PROCEDURE NewEdit*(where: Widget; x, y, w, h: INTEGER): Edit;
VAR c: Edit;
BEGIN NEW(c); InitEdit(c, where, x, y, w, h)
RETURN c END NewEdit;

(** General **)

PROCEDURE DrawAll*;
VAR c: Widget;
BEGIN
  c := forms;
  REPEAT
    DrawForm(c(Form));
    c := c.next
  UNTIL c = forms;
  G.Flip
END DrawAll;

PROCEDURE HandleMouseMove(VAR e: G.Event);
VAR c: Widget;
BEGIN
  c := FindHoveredInList(forms, e.x, e.y, FALSE);
  IF c # NIL THEN
    WidgetHandleMouseMove(c, e.x - c.x, e.y - c.y, e.button)
  END
END HandleMouseMove;

PROCEDURE HandleMouseDown(VAR e: G.Event);
VAR c: Widget;
BEGIN
  pressedX := 0; pressedY := 0;
  c := FindHoveredInList(forms, e.x, e.y, TRUE);
  IF c # NIL THEN
    WidgetHandleMouseDown(c, e.x - c.x, e.y - c.y, e.button)
  END
END HandleMouseDown;

PROCEDURE HandleMouseUp(VAR e: G.Event);
VAR c: Widget;
BEGIN
  IF pressedWidget # NIL THEN
    c := pressedWidget;
    IF ~c.hovered THEN c := NIL END;
    WidgetOnMouseUp(pressedWidget, e.x - pressedX, e.y - pressedY, e.button);
    IF (c # NIL) & (e.button = 1) THEN
      WidgetOnClick(c)
    END
  END
END HandleMouseUp;

PROCEDURE HandleKeyDown(VAR e: G.Event);
VAR msg: KeyDownMsg;
BEGIN
  IF focusedWidget # NIL THEN
    msg.key := e.key;
    focusedWidget.handle(focusedWidget, msg)
  END
END HandleKeyDown;

PROCEDURE HandleKeyUp(VAR e: G.Event);
VAR msg: KeyUpMsg;
BEGIN
  IF focusedWidget # NIL THEN
    msg.key := e.key;
    focusedWidget.handle(focusedWidget, msg)
  END
END HandleKeyUp;

PROCEDURE HandleChar(VAR e: G.Event);
VAR msg: CharMsg;
BEGIN
  IF focusedWidget # NIL THEN
    msg.key := e.key; msg.ch := e.ch;
    msg.mod := e.mod; msg.repeat := e.repeat;
    focusedWidget.handle(focusedWidget, msg)
  END
END HandleChar;

PROCEDURE HandleEvent(VAR e: G.Event);
BEGIN
  IF e.type = G.quit THEN quit := TRUE
  ELSIF e.type = G.mouseMove THEN HandleMouseMove(e)
  ELSIF e.type = G.mouseDown THEN HandleMouseDown(e)
  ELSIF e.type = G.mouseUp   THEN HandleMouseUp(e)
  ELSIF e.type = G.keyDown   THEN HandleKeyDown(e)
  ELSIF e.type = G.keyUp     THEN HandleKeyUp(e)
  ELSIF e.type = G.char      THEN HandleChar(e)
  END
END HandleEvent;

PROCEDURE Run*;
VAR e: G.Event;
BEGIN
  quit := FALSE;
  REPEAT
    WHILE G.HasEvents() DO
      G.WaitEvent(e);
      HandleEvent(e)
    END;
    DrawAll
  UNTIL quit
END Run;

PROCEDURE Init*;
BEGIN
  forms := NIL;
  font := G.LoadFont('Data/Fonts/Main');
  IF font = NIL THEN Out.String('SimpleGui: could not load font.'); Out.Ln END;
  Done := font # NIL;
  hoveredWidget := NIL; pressedWidget := NIL;
  pressedX := 0; pressedY := 0
END Init;

END SimpleGui.