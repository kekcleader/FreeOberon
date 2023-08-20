MODULE SimpleGui;
IMPORT G := Graph, Strings, Out;

TYPE
  Widget* = POINTER TO WidgetDesc;

  Message* = RECORD END;
  PutMsg* = RECORD(Message) what*: Widget; x*, y*: INTEGER END;
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
    body*: Widget; (** A ring of widgets that this widget contains *)
    parent*: Widget; (** A widget that this widget is contained in *)
    prev*, next*: Widget;
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

  App* = POINTER TO AppDesc;
  AppDesc* = RECORD(WidgetDesc) END;

  Form* = POINTER TO FormDesc;
  FormDesc* = RECORD(WidgetDesc) END;

  Panel* = POINTER TO PanelDesc;
  PanelDesc* = RECORD(WidgetDesc)
    noBg*: BOOLEAN
  END;

  Button* = POINTER TO ButtonDesc;
  ButtonDesc* = RECORD(WidgetDesc)
    caption*: ARRAY 64 OF CHAR
  END;

  Edit* = POINTER TO EditDesc;
  EditDesc* = RECORD(WidgetDesc)
    text*: ARRAY 256 OF CHAR;
    len*: INTEGER; (** Length of text in characters *)
    pos*: INTEGER; (** Position of text carret, in range [0; len] *)
    off*: INTEGER (** Used to slide text that does not fit, normal is 0 *)
  END;

  ScrollBar* = POINTER TO ScrollBarDesc;
  ScrollBarDesc* = RECORD(WidgetDesc)
    vertical*: BOOLEAN; (** TRUE for vertical scroll, FALSE for horizontal *)
    min*, max*: INTEGER;
    value*: INTEGER; (** The position of the scroll, in range [min; max] *)
    inc*, bigInc*: INTEGER; (** A single increment of value, and a big one *)
    btnSize*: INTEGER; (** Width or height (depending on vertical) of buttons *)
    handlePos*, handleSize*: INTEGER; (** Size and position of handle, px *)
    handlePressed*: BOOLEAN;
    handlePressPos*: INTEGER; (** Where handle was pressed, offset in px *)
    btnPressed*: INTEGER; (** 0-nothing, 1-less btn, 2-more btn, 3-handle *)
    onScroll*: PROCEDURE (c: ScrollBar; value: INTEGER);
  END;

  ScrollBox* = POINTER TO ScrollBoxDesc;
  ScrollBoxDesc* = RECORD(WidgetDesc)
    outer*, inner*: Panel;
    scbHoriz*, scbVert*: ScrollBar
  END;

VAR
  Done*: BOOLEAN; (** FALSE after a failed opration and before the next Init *)
  app*: App;
  focusedWidget*: Widget; (** The widget with focus = TRUE *)
  font*: G.Font;
  quit: BOOLEAN; (** Main loop in procedure Run ends when TRUE *)
  hoveredWidget: Widget;
  pressedWidget: Widget;
  pressedX, pressedY: INTEGER;

  mouseCursor: G.Bitmap;
  mouseX, mouseY: INTEGER;

(** Widget **)

PROCEDURE FindHoveredInRing(list: Widget; x, y: INTEGER;
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
RETURN c END FindHoveredInRing;

PROCEDURE WidgetOnMouseEnter*(c: Widget);
VAR msg: MouseEnterMsg;
BEGIN
  IF pressedWidget = c THEN c.pressed := TRUE END;
  c.hovered := TRUE;
  c.handle(c, msg)
END WidgetOnMouseEnter;

PROCEDURE WidgetOnMouseLeave*(c: Widget);
VAR msg: MouseLeaveMsg;
BEGIN
  c.hovered := FALSE;
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
    p := FindHoveredInRing(c.body, x, y, FALSE);
    IF p # NIL THEN
      WidgetHandleMouseMove(p, x - p.x, y - p.y, btn)
    ELSE
      WidgetOnMouseMove(c, x, y, btn)
    END
  END
END WidgetHandleMouseMove;

PROCEDURE Resize*(c: Widget; w, h: INTEGER);
BEGIN
  c.w := w;
  c.h := h
END Resize;

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

PROCEDURE Detach*(c: Widget);
VAR p: Widget;
BEGIN
  IF c.parent # NIL THEN
    IF c.prev = c THEN
      c.parent.body := NIL
    ELSE
      c.prev.next := c.next;
      c.next.prev := c.prev
    END;
    c.parent := NIL
  END;
  c.prev := NIL; c.next := NIL
END Detach;

PROCEDURE AppendTo*(c: Widget; container: Widget);
VAR r: Widget;
BEGIN
  Detach(c);
  c.parent := container;
  r := container.body;
  IF r = NIL THEN
    container.body := c;
    c.prev := c; c.next := c
  ELSE
    c.next := r; c.prev := r.prev;
    r.prev.next := c; r.prev := c
  END
END AppendTo;

PROCEDURE DirectPut*(c, where: Widget; x, y: INTEGER);
BEGIN
  IF c # NIL THEN
    c.x := x; c.y := y;
    IF where # NIL THEN
      AppendTo(c, where)
    END
  END
END DirectPut;

PROCEDURE Put*(c, where: Widget; x, y: INTEGER);
VAR msg: PutMsg;
BEGIN
  IF c # NIL THEN
    c.x := x; c.y := y;
    IF where # NIL THEN
      msg.what := c;
      msg.x := x;
      msg.y := y;
      where.handle(where, msg)
    END
  END
END Put;

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
  p := FindHoveredInRing(c.body, x, y, TRUE);
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
  ELSIF msg IS MouseDownMsg THEN
    IF msg(MouseDownMsg).btn = 1 THEN c.pressed := TRUE END
  ELSIF msg IS MouseUpMsg THEN c.pressed := FALSE
  ELSIF msg IS PutMsg THEN
    DirectPut(msg(PutMsg).what, c, msg(PutMsg).x, msg(PutMsg).y)
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

(** Panel **)

PROCEDURE PanelSetNoBg*(c: Panel; noBg: BOOLEAN);
BEGIN c.noBg := noBg
END PanelSetNoBg;

PROCEDURE PanelHandler*(c: Widget; VAR msg: Message);
VAR x, y: INTEGER;
BEGIN
  IF msg IS DrawMsg THEN
    x := msg(DrawMsg).x; y := msg(DrawMsg).y;
    IF ~c(Panel).noBg THEN
      G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor)
    END;
    DrawBody(c, x, y, c.w, c.h)
  ELSE WidgetHandler(c, msg)
  END
END PanelHandler;

PROCEDURE InitPanel*(c: Panel; where: Widget; x, y, w, h: INTEGER);
BEGIN InitWidget(c, w, h);
  c.noBg := FALSE;
  c.handle := PanelHandler;
  Put(c, where, x, y)
END InitPanel;

PROCEDURE NewPanel*(where: Widget; x, y, w, h: INTEGER): Panel;
VAR c: Panel;
BEGIN NEW(c); InitPanel(c, where, x, y, w, h)
RETURN c END NewPanel;

(** App **)

PROCEDURE InitApp*(c: App);
VAR W, H: INTEGER;
BEGIN
  G.GetScreenSize(W, H);
  InitWidget(c, W, H)
END InitApp;

PROCEDURE NewApp*(): App;
VAR c: App;
BEGIN NEW(c); InitApp(c)
RETURN c END NewApp;

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
BEGIN InitWidget(c, w, h);
  c.x := x; c.y := y;
  c.handle := FormHandler;
  AppendTo(c, app)
END InitForm;

PROCEDURE NewForm*(x, y, w, h: INTEGER): Form;
VAR c: Form;
BEGIN NEW(c); InitForm(c, x, y, w, h)
RETURN c END NewForm;

(** Button **)

PROCEDURE MakeOrAndYw(bg: G.Color; VAR or, yw: G.Color);
VAR r, g, b: INTEGER;
BEGIN
  G.ColorToRGB(bg, r, g, b);
  G.MakeCol(yw, (r + 255 * 2) DIV 3, (g + 255 * 3) DIV 4, (b * 3 + 255) DIV 4);
  IF (r <= g) & (r <= b) THEN
    g := (g * 2 + 255 * 3) DIV 5;
    b := (b * 3 + 255) DIV 4
  ELSIF (g <= r) & (g <= b) THEN
    r := (r * 2 + 255 * 3) DIV 5;
    b := (b * 3 + 255) DIV 4
  ELSE
    r := (r * 2 + 255 * 3) DIV 5;
    g := (g * 3 + 255) DIV 4
  END;
  G.MakeCol(or, r, g, b)
END MakeOrAndYw;

PROCEDURE DrawButtonBox(x, y, w, h: INTEGER; bg, parentBg: G.Color;
    down, glow: BOOLEAN);
VAR wh, bl, g1, g2, or, yw: G.Color;
  X, Y: INTEGER;
BEGIN
  G.MakeCol(bl, 0, 0, 0);
  G.MakeCol(wh, 255, 255, 255);
  G.MakeCol(g1, 140, 140, 140);
  G.MakeCol(g2, 80, 80, 80);

  MakeOrAndYw(parentBg, or, yw);

  X := x + w - 1; Y := y + h - 1;

  G.FillRect(x + 1, y + 1, X - 2, Y - 2, bg);

  G.HLine(x + 2, y, X - 1, bl);
  G.HLine(x, Y - 1, X - 4, bl);
  G.VLine(x, y + 2, Y - 1, bl);
  G.VLine(X - 1, y + 1, Y - 4, bl);

  IF ~down THEN
    G.HLine(x + 3, y + 1, X - 2, wh);
    G.HLine(x + 2, Y - 2, X - 4, g1);
    G.VLine(x + 1, y + 3, Y - 2, wh);
    G.VLine(X - 2, y + 2, Y - 4, g1);
    G.PutPixel(X - 3, Y - 3, g1);
    G.Line(X - 4, Y - 3, X - 3, Y - 4, g1);
    G.PutPixel(x + 2, y + 2, wh)
  END;

  G.Line(X - 3, Y - 2, X - 2, Y - 3, bl);
  G.Line(X - 3, Y - 1, X - 1, Y - 3, g2);
  G.Line(x + 1, y + 2, x + 2, y + 1, g1);

  G.PutPixel(x + 1, y + 1, bl);
  IF glow THEN
    G.Line(X - 2, Y - 1, X - 1, Y - 2, yw);
    G.HLine(x + 1, Y, X - 2, or);
    G.VLine(X, y + 1, Y - 2, or);
    G.PutPixel(X - 1, Y - 1, or)
  END
END DrawButtonBox;

PROCEDURE DrawButton*(c: Button; x, y, w, h: INTEGER);
VAR fw, fh, tw, tx, ty: INTEGER;
BEGIN
  DrawButtonBox(x, y, c.w, c.h, c.bgColor, c.parent.bgColor,
      c.pressed & c.hovered, TRUE);
  G.GetMonoFontSize(font, fw, fh);
  tw := Strings.Length(c.caption) * fw;
  tx := x + (c.w - tw) DIV 2;
  ty := y + (c.h - fh) DIV 2;
  IF c.pressed & c.hovered THEN INC(tx); INC(ty) END;
  G.DrawString(c.caption, tx, ty, font, c.fgColor)
END DrawButton;
PROCEDURE ButtonHandler*(c: Widget; VAR msg: Message);
VAR b: Button;
BEGIN b := c(Button);
  IF msg IS DrawMsg THEN
    DrawButton(b, msg(DrawMsg).x, msg(DrawMsg).y,
        msg(DrawMsg).w, msg(DrawMsg).h)
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
END InitButton;

PROCEDURE NewButton*(where: Widget; x, y, w, h: INTEGER; caption: ARRAY OF CHAR): Button;
VAR c: Button;
BEGIN NEW(c); InitButton(c, where, x, y, w, h, caption)
RETURN c END NewButton;

(** Edit **)

PROCEDURE DrawEdit*(c: Edit; x, y, w, h: INTEGER);
VAR fw, fh, tw, tx, ty: INTEGER;
  or, yw: G.Color;
BEGIN
  MakeOrAndYw(c.parent.bgColor, or, yw);

  G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);
  G.GetMonoFontSize(font, fw, fh);
  tw := Strings.Length(c.text) * fw;
  tx := x + 2 - c.off;
  ty := y + (c.h - fh) DIV 2;
  G.DrawString(c.text, tx, ty, font, c.fgColor);
  IF c.focused THEN
    INC(tx, fw * c.pos - 1);
    G.VLine(tx, ty, ty + fh - 1, or);
    G.HLine(tx - 1, ty, tx + 1, or);
    G.HLine(tx - 1, ty + fh - 1, tx + 1, or)
  END;
  G.HLine(x, y, x + c.w - 2, c.fgColor);
  G.VLine(x, y, y + c.h - 1, c.fgColor);
  G.HLine(x + 1, y + c.h - 1, x + c.w - 1, or);
  G.VLine(x + c.w - 1, y, y + c.h - 1, or)
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

PROCEDURE EditSetText*(c: Edit; text: ARRAY OF CHAR);
BEGIN
  Strings.Copy(text, c.text);
  c.len := Strings.Length(text);
  c.pos := 0;
  c.off := 0
END EditSetText;

(** ScrollBar **)

PROCEDURE DrawBox(x, y, w, h: INTEGER; bg, fg: G.Color);
BEGIN
  G.FillRect(x, y, x + w - 1, y + h - 1, bg);
  G.Rect(x, y, x + w - 1, y + h - 1, fg)
END DrawBox;

PROCEDURE DrawHorizScrollBar(c: ScrollBar; x, y, w, h: INTEGER);
VAR fw, fh, X, Y, hs, maxHs, pos, range: INTEGER;
  bs: INTEGER; (** Button size *)
  grey: G.Color;
BEGIN
  G.MakeCol(grey, 80, 80, 80);

  DrawButtonBox(x, y, c.w, c.h, c.bgColor, c.parent.bgColor, TRUE, TRUE);
  hs := c.handleSize;
  bs := c.h;
  IF bs > 20 THEN bs := 20 END;
  c.btnSize := bs;
  maxHs := c.w - bs * 2 + 4;
  IF hs > maxHs THEN hs := maxHs END;
  range := c.max - c.min;
  pos := c.value;
  IF pos < c.min THEN pos := c.min ELSIF pos > c.max THEN pos := c.max END;
  c.handlePos := bs - 2 + ((maxHs - hs) * pos + range DIV 2) DIV range;

  DrawButtonBox(x, y, bs, c.h, c.bgColor,
      c.parent.bgColor, c.btnPressed = 1, FALSE);
  DrawButtonBox(x + c.w - bs, y, bs, c.h, c.bgColor,
      c.parent.bgColor, c.btnPressed = 2, TRUE);
  X := x + (bs - 1) DIV 2; Y := y + (bs - 1) DIV 2;
  IF c.btnPressed = 1 THEN INC(X); INC(Y) END;
  G.HLine(X - 4, Y, X + 4, c.fgColor);
  G.Line(X - 4, Y, X - 1, Y + 3, c.fgColor);
  G.Line(X - 4, Y, X - 1, Y - 3, c.fgColor);
  X := x + c.w - bs DIV 2 - 1;
  IF c.btnPressed = 1 THEN DEC(Y) END;
  IF c.btnPressed = 2 THEN INC(X); INC(Y) END;
  G.HLine(X - 4, Y, X + 4, c.fgColor);
  G.Line(X + 4, Y, X + 1, Y + 3, c.fgColor);
  G.Line(X + 4, Y, X + 1, Y - 3, c.fgColor);

  DrawButtonBox(x + c.handlePos, y, hs, c.h, c.bgColor,
      c.parent.bgColor, c.btnPressed = 3, FALSE)
END DrawHorizScrollBar;

PROCEDURE DrawVertScrollBar(c: ScrollBar; x, y, w, h: INTEGER);
VAR fw, fh, X, Y, hs, maxHs, pos, range: INTEGER;
  bs: INTEGER; (** Button size *)
  grey: G.Color;
BEGIN
  G.MakeCol(grey, 80, 80, 80);

  DrawButtonBox(x, y, c.w, c.h, c.bgColor, c.parent.bgColor, TRUE, TRUE);
  hs := c.handleSize;
  bs := c.w;
  IF bs > 20 THEN bs := 20 END;
  c.btnSize := bs;
  maxHs := c.h - bs * 2 + 4;
  IF hs > maxHs THEN hs := maxHs END;
  range := c.max - c.min;
  pos := c.value;
  IF pos < c.min THEN pos := c.min ELSIF pos > c.max THEN pos := c.max END;
  c.handlePos := bs - 2 + ((maxHs - hs) * pos + range DIV 2) DIV range;

  DrawButtonBox(x, y, c.w, bs, c.bgColor,
      c.parent.bgColor, c.btnPressed = 1, FALSE);
  DrawButtonBox(x, y + c.h - bs, c.w, bs, c.bgColor,
      c.parent.bgColor, c.btnPressed = 2, TRUE);
  X := x + (bs - 1) DIV 2; Y := y + (bs - 1) DIV 2;
  IF c.btnPressed = 1 THEN INC(X); INC(Y) END;
  G.VLine(X, Y - 4, Y + 4, c.fgColor);
  G.Line(X, Y - 4, X + 3, Y - 1, c.fgColor);
  G.Line(X, Y - 4, X - 3, Y - 1, c.fgColor);
  Y := y + c.h - bs DIV 2 - 1;
  IF c.btnPressed = 1 THEN DEC(X) END;
  IF c.btnPressed = 2 THEN INC(X); INC(Y) END;
  G.VLine(X, Y - 4, Y + 4, c.fgColor);
  G.Line(X, Y + 4, X + 3, Y + 1, c.fgColor);
  G.Line(X, Y + 4, X - 3, Y + 1, c.fgColor);

  DrawButtonBox(x, y + c.handlePos, c.w, hs, c.bgColor,
      c.parent.bgColor, c.btnPressed = 3, FALSE)
END DrawVertScrollBar;

PROCEDURE DrawScrollBar*(c: ScrollBar; x, y, w, h: INTEGER);
BEGIN
  IF c.vertical THEN
    DrawVertScrollBar(c, x, y, w, h)
  ELSE
    DrawHorizScrollBar(c, x, y, w, h)
  END
END DrawScrollBar;

PROCEDURE ScrollBarSetVertical*(c: ScrollBar; vertical: BOOLEAN);
BEGIN c.vertical := vertical
END ScrollBarSetVertical;

PROCEDURE ScrollBarSetValue*(c: ScrollBar; value: INTEGER);
BEGIN
  IF value < c.min THEN value := c.min
  ELSIF value > c.max THEN value := c.max
  END;
  IF c.value # value THEN
    c.value := value;
    IF c.onScroll # NIL THEN c.onScroll(c, value) END
  END
END ScrollBarSetValue;

PROCEDURE HandleScrollBarMouseMove(c: ScrollBar; VAR msg: MouseMoveMsg);
VAR n, x, size, w: INTEGER;
BEGIN
  IF c.handlePressed THEN
    IF c.vertical THEN x := msg.y; size := c.h
    ELSE x := msg.x; size := c.w
    END;

    w := size - c.btnSize * 2 - c.handleSize;
    n := x - c.handlePressPos - c.btnSize;
    n := (n * (c.max - c.min) + w DIV 2) DIV w + c.min;

    ScrollBarSetValue(c, n)
  END
END HandleScrollBarMouseMove;

PROCEDURE HandleScrollBarMouseDown(c: ScrollBar; VAR msg: MouseDownMsg);
VAR x, d, size: INTEGER;
BEGIN
  IF c.vertical THEN x := msg.y; size := c.h
  ELSE x := msg.x; size := c.w
  END;
  IF msg.btn = 2 THEN d := 1 ELSE d := c.inc END;
  IF x < c.btnSize THEN
    c.btnPressed := 1(*Less btn*);
    ScrollBarSetValue(c, c.value - d);
  ELSIF x >= size - c.btnSize THEN
    c.btnPressed := 2(*More btn*);
    ScrollBarSetValue(c, c.value + d)
  ELSIF msg.btn = 1 THEN
    IF (c.handlePos <= x) & (x < c.handlePos + c.handleSize) THEN
      c.btnPressed := 3(*Handle*);
      c.handlePressed := TRUE;
      c.handlePressPos := x - c.handlePos
    ELSIF x < c.handlePos THEN
      ScrollBarSetValue(c, c.value - c.bigInc)
    ELSE
      ScrollBarSetValue(c, c.value + c.bigInc)
    END
  ELSE c.btnPressed := 0(*Nothing*);
  END;
  WidgetHandler(c, msg)
END HandleScrollBarMouseDown;

PROCEDURE ScrollBarHandler*(c: Widget; VAR msg: Message);
VAR s: ScrollBar;
BEGIN s := c(ScrollBar);
  IF msg IS DrawMsg THEN
    DrawScrollBar(s, msg(DrawMsg).x, msg(DrawMsg).y,
        msg(DrawMsg).w, msg(DrawMsg).h)
  ELSIF msg IS MouseMoveMsg THEN HandleScrollBarMouseMove(s, msg(MouseMoveMsg))
  ELSIF msg IS MouseDownMsg THEN HandleScrollBarMouseDown(s, msg(MouseDownMsg))
  ELSIF msg IS MouseUpMsg THEN s.handlePressed := FALSE; s.btnPressed := 0(*Nothing*)
  ELSE WidgetHandler(c, msg)
  END
END ScrollBarHandler;

PROCEDURE InitScrollBar*(c: ScrollBar; where: Widget;
    x, y, w, h: INTEGER);
BEGIN InitWidget(c, w, h);
  c.handle := ScrollBarHandler;
  c.value := 0; c.min := 0; c.max := 100; c.inc := 5; c.bigInc := 20;
  c.handlePos := 0; c.handleSize := 24; c.btnSize := 0;
  c.btnPressed := 0(*Nothing*);
  Put(c, where, x, y)
END InitScrollBar;

PROCEDURE NewScrollBar*(where: Widget; x, y, w, h: INTEGER): ScrollBar;
VAR c: ScrollBar;
BEGIN NEW(c); InitScrollBar(c, where, x, y, w, h)
RETURN c END NewScrollBar;

PROCEDURE SetOnScroll*(c: ScrollBar; proc: PROCEDURE (c: ScrollBar; value: INTEGER));
BEGIN c.onScroll := proc
END SetOnScroll;

(** ScrollBox **)

PROCEDURE ScrollBoxHandler*(c: Widget; VAR msg: Message);
VAR x, y: INTEGER;
BEGIN
  IF msg IS DrawMsg THEN
    x := msg(DrawMsg).x; y := msg(DrawMsg).y;
    G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);
    DrawBody(c, x, y, c.w, c.h)
  ELSIF msg IS PutMsg THEN
    DirectPut(msg(PutMsg).what, c(ScrollBox).inner,
        msg(PutMsg).x, msg(PutMsg).y)
  ELSE WidgetHandler(c, msg)
  END
END ScrollBoxHandler;

PROCEDURE ScrollBoxSetInnerSize*(c: ScrollBox; w, h: INTEGER);
BEGIN
  Resize(c.inner, w, h);
  c.scbHoriz.max := w - c.outer.w;
  c.scbVert.max := h - c.outer.h
END ScrollBoxSetInnerSize;

PROCEDURE ScrollBoxOnHorizScroll*(c: ScrollBar; value: INTEGER);
BEGIN
  
END ScrollBoxOnHorizScroll;

PROCEDURE InitScrollBox*(c: ScrollBox; where: Widget; x, y, w, h: INTEGER);
BEGIN InitWidget(c, w, h);
  c.handle := ScrollBoxHandler;

  c.scbHoriz := NewScrollBar(NIL, 0, 0, w - 16, 16);
  DirectPut(c.scbHoriz, c, 0, h - 16);
  SetOnScroll(c.scbHoriz, ScrollBoxOnHorizScroll);

  c.scbVert := NewScrollBar(NIL, 0, 0, 16, h - 16);
  DirectPut(c.scbVert, c, w - 16, 0);
  (*SetOnScroll(c.scbHoriz, ScrollBoxOnVertScroll);*)

  ScrollBarSetVertical(c.scbVert, TRUE);
  c.outer := NewPanel(NIL, 0, 0, w - 16, h - 16);
  DirectPut(c.outer, c, 0, 0);
  PanelSetNoBg(c.outer, TRUE);

  c.inner := NewPanel(c.outer, 0, 0, 1, 1);
  ScrollBoxSetInnerSize(c, w * 2, h * 3);

  Put(c, where, x, y)
END InitScrollBox;

PROCEDURE NewScrollBox*(where: Widget; x, y, w, h: INTEGER): ScrollBox;
VAR c: ScrollBox;
BEGIN NEW(c); InitScrollBox(c, where, x, y, w, h)
RETURN c END NewScrollBox;

(** General **)

PROCEDURE DrawCursor;
BEGIN
  IF mouseX >= 0 THEN
    G.Draw(mouseCursor, mouseX, mouseY)
  END
END DrawCursor;

PROCEDURE DrawAll;
VAR c: Widget;
BEGIN
  G.TargetScreen;
  c := app.body;
  REPEAT
    DrawForm(c(Form));
    c := c.next
  UNTIL c = app.body;
  DrawCursor;
  G.Flip
END DrawAll;

PROCEDURE HandleMouseMove(VAR e: G.Event);
VAR c: Widget;
BEGIN
  mouseX := e.x; mouseY := e.y;
  c := FindHoveredInRing(app.body, e.x, e.y, FALSE);
  IF c # NIL THEN
    WidgetHandleMouseMove(c, e.x - c.x, e.y - c.y, e.button)
  END
END HandleMouseMove;

PROCEDURE HandleMouseDown(VAR e: G.Event);
VAR c: Widget;
BEGIN
  pressedX := 0; pressedY := 0;
  c := FindHoveredInRing(app.body, e.x, e.y, TRUE);
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

PROCEDURE Quit*;
BEGIN quit := TRUE
END Quit;

PROCEDURE Run*;
VAR e: G.Event;
BEGIN
  quit := FALSE;
  REPEAT
    WHILE ~quit & G.HasEvents() DO
      G.WaitEvent(e);
      HandleEvent(e)
    END;
    DrawAll
  UNTIL quit
END Run;

PROCEDURE CreateArrowCursor(): G.Bitmap;
VAR m: G.Bitmap;
  bl, wh: G.Color;
  i: INTEGER;
BEGIN
  m := G.NewBitmap(10, 16);
  G.ClearBitmap(m);
  G.Target(m);
  G.MakeCol(bl, 0, 0, 0);
  G.MakeCol(wh, 255, 255, 255);

  G.PutPixel(1, 1, wh);
  FOR i := 2 TO 8 DO G.HLine(1, i, i, wh) END;
  G.HLine(1, 9, 5, wh);
  G.HLine(1, 10, 5, wh);
  G.PutPixel(1, 11, wh);
  G.HLine(5, 11, 6, wh);
  G.HLine(5, 12, 6, wh);
  G.HLine(6, 13, 7, wh);
  G.HLine(6, 14, 7, wh);

  G.Line(1, 0, 9, 8, bl);
  G.VLine(0, 1, 12, bl);
  G.Line(1, 12, 3, 10, bl);
  G.Line(4, 11, 5, 14, bl);
  G.HLine(6, 15, 7, bl);
  G.Line(6, 9, 8, 14, bl);
  G.HLine(7, 9, 9, bl);
RETURN m END CreateArrowCursor;

PROCEDURE InitCursor;
BEGIN
  mouseCursor := CreateArrowCursor();
  mouseX := -1; mouseY := 0;
  G.ShowMouse(FALSE)
END InitCursor;

PROCEDURE Init*;
BEGIN
  font := G.LoadFont('Data/Fonts/Main');
  IF font = NIL THEN Out.String('SimpleGui: could not load font.'); Out.Ln END;
  InitCursor;
  Done := font # NIL;
  app := NewApp();
  hoveredWidget := NIL; pressedWidget := NIL;
  pressedX := 0; pressedY := 0
END Init;

END SimpleGui.