MODULE SimpleGui;
IMPORT G := Graph, Strings, Out;

CONST
  (** Align **)
  alLeft*   = 0;
  alCenter* = 1;
  alRight*  = 2;

TYPE
  Widget* = POINTER TO WidgetDesc;

  Message* = RECORD END;
  PutMsg* = RECORD(Message) what*: Widget; x*, y*: INTEGER END;
  DrawMsg* = RECORD(Message) x*, y*, w*, h*: INTEGER END;
  MouseMoveMsg* = RECORD(Message) x*, y*: INTEGER; btns*: SET END;
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
    redraw*: BOOLEAN; (** TRUE if widget or it's insides need to be redrawn *)
    redrawSelf*: BOOLEAN; (** TRUE if widget itself needs to be redrawn *)
    visible*: BOOLEAN;
    enabled*: BOOLEAN;
    focusable*: BOOLEAN; (** TRUE if widget can get focus *)
    focused*: BOOLEAN; (** TRUE if this widget is globally in focus *)
    hovered*: BOOLEAN; (** TRUE if mouse pointer is over the widget *)
    pressed*: BOOLEAN; (** TRUE if widget is held down with LMB *)
    body*: Widget; (** A ring of widgets that this widget contains *)
    parent*: Widget; (** A widget that this widget is contained in *)
    prev*, next*: Widget;
    handle*: Handler;

    onPaint*: PROCEDURE (c: Widget; x, y, w, h: INTEGER);
    onMouseDown*: PROCEDURE (c: Widget; x, y, btn: INTEGER);
    onMouseUp*: PROCEDURE (c: Widget; x, y, btn: INTEGER);
    onMouseMove*: PROCEDURE (c: Widget; x, y: INTEGER; btns: SET);
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

  Label* = POINTER TO LabelDesc;
  LabelDesc* = RECORD(WidgetDesc)
    caption*: ARRAY 256 OF CHAR;
    align*: INTEGER; (** One of {alLeft, alCenter, alRight} *)
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
    noBg*: BOOLEAN;
    outer*, inner*: Panel;
    scbHorz*, scbVert*: ScrollBar
  END;

  Canvas* = POINTER TO CanvasDesc;
  CanvasDesc = RECORD(WidgetDesc)
    bmp*: G.Bitmap
  END;

VAR
  Done*: BOOLEAN; (** FALSE after a failed opration and before the next Init *)
  app*: App;
  focusedWidget*: Widget; (** The widget with focus = TRUE *)
  font*: G.Font;
  quit: BOOLEAN; (** Main loop in procedure Run ends when TRUE *)
  forceFlip: BOOLEAN; (** Becomes TRUE on mouse move and FALSE after Flip *)
  hoveredWidget: Widget;
  pressedWidget: Widget;
  pressedX, pressedY: INTEGER;

(** Widget **)

PROCEDURE Redraw*(c: Widget);
VAR p: Widget;
BEGIN
  c.redraw := TRUE; c.redrawSelf := TRUE;
  p := c.parent;
  WHILE (p # NIL) & ~p.redraw DO p.redraw := TRUE; p := p.parent END
END Redraw;

PROCEDURE Drawn*(c: Widget);
BEGIN c.redraw := FALSE; c.redrawSelf := FALSE
END Drawn;

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

PROCEDURE WidgetOnMouseMove*(c: Widget; x, y: INTEGER; btns: SET);
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

  msg.x := x; msg.y := y; msg.btns := btns;
  c.handle(c, msg);

  IF c.onMouseMove # NIL THEN c.onMouseMove(c, x, y, btns) END
END WidgetOnMouseMove;

PROCEDURE WidgetHandleMouseMove*(c: Widget; x, y: INTEGER; btns: SET);
VAR p: Widget;
BEGIN
  IF pressedWidget # NIL THEN
    WidgetOnMouseMove(pressedWidget, x - pressedX, y - pressedY, btns)
  ELSE
    p := FindHoveredInRing(c.body, x, y, FALSE);
    IF p # NIL THEN
      WidgetHandleMouseMove(p, x - p.x, y - p.y, btns)
    ELSE
      WidgetOnMouseMove(c, x, y, btns)
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
  IF ((c = NIL) OR c.focusable) & (focusedWidget # c) THEN
    IF focusedWidget # NIL THEN
      focusedWidget.focused := FALSE;
      focusedWidget.handle(focusedWidget, lost)
    END;
    IF c # NIL THEN
      c.focused := TRUE;
      focusedWidget := c;
      focusedWidget.handle(focusedWidget, get)
    END
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
    IF c.redraw THEN
      IF c.redrawSelf THEN
        x := msg(DrawMsg).x; y := msg(DrawMsg).y;
        IF c.onPaint = NIL THEN
          G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);
          G.Rect(x, y, x + c.w - 1, y + c.h - 1, c.fgColor);
          G.Rect(x + 2, y + 2, x + c.w - 3, y + c.h - 3, c.fgColor)
        END;
        Drawn(c)
      END
    END
  ELSIF msg IS MouseDownMsg THEN
    IF msg(MouseDownMsg).btn = 1 THEN c.pressed := TRUE; Redraw(c) END
  ELSIF msg IS MouseUpMsg THEN c.pressed := FALSE; Redraw(c)
  ELSIF msg IS PutMsg THEN
    DirectPut(msg(PutMsg).what, c, msg(PutMsg).x, msg(PutMsg).y)
  ELSIF msg IS GetFocusMsg THEN Redraw(c)
  ELSIF msg IS LostFocusMsg THEN Redraw(c)
  END
END WidgetHandler;

PROCEDURE DrawWidget*(c: Widget; x, y, w, h: INTEGER);
VAR M: DrawMsg;
BEGIN
  M.x := x; M.y := y; M.w := w; M.h := h;
  c.handle(c, M);
  IF c.onPaint # NIL THEN
    c.onPaint(c, x, y, w, h);
  END
END DrawWidget;

PROCEDURE DrawBody*(c: Widget; x, y, w, h: INTEGER; forced: BOOLEAN);
VAR p: Widget;
  x2, y2, w2, h2: INTEGER;
  cx, cy, cw, ch: INTEGER;
  CX, CY, CW, CH: INTEGER;
BEGIN
  p := c.body;
  IF p # NIL THEN
    G.GetClip(CX, CY, CW, CH);
    IF CX + CW > x + w THEN CW := x + w - CX END;
    IF CY + CH > y + h THEN CH := y + h - CY END;
    IF CX < x THEN DEC(CW, x - CX); CX := x END;
    IF CY < y THEN DEC(CH, y - CY); CY := y END;
    REPEAT
      IF forced THEN p.redraw := TRUE; p.redrawSelf := TRUE END;
      IF p.redraw & p.visible THEN
        x2 := x + p.x; y2 := y + p.y;
        w2 := w - p.x; h2 := h - p.y;

        cx := x2; cy := y2; cw := p.w; ch := p.h;
        IF cx + cw > CX + CW THEN cw := CX + CW - cx END;
        IF cy + ch > CY + CH THEN ch := CY + CH - cy END;
        IF cx < CX THEN DEC(cw, CX - cx); cx := CX END;
        IF cy < CY THEN DEC(ch, CY - cy); cy := CY END;
        G.SetClip(cx, cy, cw, ch);

        DrawWidget(p, x2, y2, p.w, p.h)
      END;
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

PROCEDURE SetVisible*(c: Widget; visible: BOOLEAN);
BEGIN c.visible := visible
END SetVisible;

PROCEDURE SetEnabled*(c: Widget; enabled: BOOLEAN);
BEGIN c.enabled := enabled
END SetEnabled;

PROCEDURE SetOnPaint*(c: Widget; proc: PROCEDURE (c: Widget; x, y, w, h: INTEGER));
BEGIN c.onPaint := proc
END SetOnPaint;

PROCEDURE SetOnMouseMove*(c: Widget; proc: PROCEDURE (c: Widget; x, y: INTEGER; btns: SET));
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
  c.redraw := TRUE; c.redrawSelf := TRUE;
  c.visible := TRUE; c.enabled := TRUE;
  c.focusable := FALSE; c.focused := FALSE;
  c.hovered := FALSE; c.pressed := FALSE;
  G.MakeCol(c.bgColor, 180, 180, 180);
  G.MakeCol(c.fgColor, 0, 0, 0);
  c.handle := WidgetHandler
END InitWidget;

(** Creates and returns a new custom widget *)
PROCEDURE NewWidget*(where: Widget; x, y, w, h: INTEGER): Widget;
VAR c: Widget;
BEGIN NEW(c); InitWidget(c, w, h);
  Put(c, where, x, y)
RETURN c END NewWidget;

(** Panel **)

PROCEDURE PanelSetNoBg*(c: Panel; noBg: BOOLEAN);
BEGIN c.noBg := noBg; Redraw(c)
END PanelSetNoBg;

PROCEDURE PanelHandler*(c: Widget; VAR msg: Message);
VAR x, y: INTEGER;
BEGIN
  IF msg IS DrawMsg THEN
    IF c.redraw THEN
      x := msg(DrawMsg).x; y := msg(DrawMsg).y;
      IF c.redrawSelf & ~c(Panel).noBg THEN
        G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor)
      END;
      DrawBody(c, x, y, c.w, c.h, c.redrawSelf);
      Drawn(c)
    END
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
  IF c.redraw THEN
    IF c.redrawSelf THEN
      G.FillRect(c.x, c.y, c.x + c.w - 1, c.y + c.h - 1, c.bgColor)
    END;
    DrawBody(c, c.x, c.y, c.w, c.h, c.redrawSelf);
    Drawn(c)
  END
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
  G.VLine(X - 1, y + 1, Y - 3, bl);

  IF ~down THEN
    G.HLine(x + 3, y + 1, X - 2, wh);
    G.HLine(x + 2, Y - 2, X - 4, g1);
    G.VLine(x + 1, y + 3, Y - 2, wh);
    G.VLine(X - 2, y + 2, Y - 3, g1);
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
  IF c.redraw THEN
    DrawButtonBox(x, y, c.w, c.h, c.bgColor, c.parent.bgColor,
        c.pressed & c.hovered, TRUE);
    G.GetMonoFontSize(font, fw, fh);
    tw := Strings.Length(c.caption) * fw;
    tx := x + (c.w - tw) DIV 2;
    ty := y + (c.h - fh) DIV 2;
    IF c.pressed & c.hovered THEN INC(tx); INC(ty) END;
    G.DrawString(c.caption, tx, ty, font, c.fgColor);
    Drawn(c)
  END
END DrawButton;

PROCEDURE ButtonHandler*(c: Widget; VAR msg: Message);
VAR b: Button;
BEGIN b := c(Button);
  IF msg IS DrawMsg THEN
    DrawButton(b, msg(DrawMsg).x, msg(DrawMsg).y,
        msg(DrawMsg).w, msg(DrawMsg).h);
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

(** Label **)

PROCEDURE DrawLabel*(c: Label; x, y, w, h: INTEGER);
VAR fw, fh, tw, tx, ty: INTEGER;
BEGIN
  IF c.redraw THEN
    G.GetMonoFontSize(font, fw, fh);
    tx := 0;
    IF c.align # alLeft THEN
      tw := Strings.Length(c.caption) * fw;
      IF c.align = alCenter THEN
        tx := (c.w - tw) DIV 2
      ELSIF c.align = alRight THEN
        tx := c.w - tw
      END
    END;
    ty := y + (c.h - fh) DIV 2;
    G.DrawString(c.caption, tx, ty, font, c.fgColor);
    Drawn(c)
  END
END DrawLabel;

PROCEDURE LabelHandler*(c: Widget; VAR msg: Message);
VAR e: Label;
BEGIN e := c(Label);
  IF msg IS DrawMsg THEN
    DrawLabel(e, msg(DrawMsg).x, msg(DrawMsg).y,
        msg(DrawMsg).w, msg(DrawMsg).h)
  ELSE WidgetHandler(c, msg)
  END
END LabelHandler;

PROCEDURE InitLabel*(c: Label; where: Widget; x, y, w, h: INTEGER;
    caption: ARRAY OF CHAR);
BEGIN InitWidget(c, w, h);
  Strings.Copy(caption, c.caption);
  c.handle := LabelHandler;
  c.align := alLeft;
  Put(c, where, x, y)
END InitLabel;

PROCEDURE NewLabel*(where: Widget; x, y, w, h: INTEGER;
    caption: ARRAY OF CHAR): Label;
VAR c: Label;
BEGIN NEW(c); InitLabel(c, where, x, y, w, h, caption)
RETURN c END NewLabel;

PROCEDURE LabelSetCaption*(c: Label; caption: ARRAY OF CHAR);
BEGIN Strings.Copy(caption, c.caption); Redraw(c)
END LabelSetCaption;

PROCEDURE LabelSetAlign*(c: Label; align: INTEGER);
BEGIN c.align := align; Redraw(c)
END LabelSetAlign;

(** Edit **)

PROCEDURE DrawEdit*(c: Edit; x, y, w, h: INTEGER);
VAR fw, fh, tw, tx, ty: INTEGER;
  or, yw: G.Color;
BEGIN
  IF c.redraw THEN
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
    G.VLine(x + c.w - 1, y, y + c.h - 1, or);
    Drawn(c)
  END
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
    IF c.pos # n THEN
      c.pos := n;
      Redraw(c)
    END
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
  EditCheckOffset(c);
  Redraw(c)
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
  c.text[0] := 0X; c.len := 0; c.pos := 0; c.off := 0;
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
  c.off := 0;
  Redraw(c)
END EditSetText;

PROCEDURE EditGetText*(c: Edit; VAR text: ARRAY OF CHAR);
BEGIN Strings.Copy(c.text, text)
END EditGetText;

(** ScrollBar **)

PROCEDURE DrawBox(x, y, w, h: INTEGER; bg, fg: G.Color);
BEGIN
  G.FillRect(x, y, x + w - 1, y + h - 1, bg);
  G.Rect(x, y, x + w - 1, y + h - 1, fg)
END DrawBox;

PROCEDURE ScrollBarCalcMetrics(c: ScrollBar; long, wide: INTEGER;
    VAR hs, bs: INTEGER);
VAR maxHs, maxBs, pos, range: INTEGER;
BEGIN
  maxBs := long DIV 2;
  IF maxBs > 20 THEN maxBs := 20 END;

  bs := wide;
  IF bs > maxBs THEN bs := maxBs END;
  c.btnSize := bs;

  maxHs := long - bs * 2 + 4;
  hs := c.handleSize;
  IF hs < bs THEN hs := bs END;
  IF hs > maxHs THEN hs := maxHs END;
  c.handleSize := hs;

  pos := c.value;
  IF pos < c.min THEN pos := c.min ELSIF pos > c.max THEN pos := c.max END;

  range := c.max - c.min;
  c.handlePos := bs - 2;
  IF range # 0 THEN
    INC(c.handlePos, (pos * (maxHs - hs) + range DIV 2) DIV range)
  END
END ScrollBarCalcMetrics;

PROCEDURE DrawHorzScrollBar(c: ScrollBar; x, y, w, h: INTEGER);
VAR fw, fh, X, Y: INTEGER;
  hs, bs: INTEGER; (* Handle size and button size *)
  grey: G.Color;
BEGIN
  G.MakeCol(grey, 140, 140, 140);

  DrawButtonBox(x, y, c.w, c.h, grey, c.parent.bgColor, TRUE, TRUE);
  ScrollBarCalcMetrics(c, w, h, hs, bs);
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
END DrawHorzScrollBar;

PROCEDURE DrawVertScrollBar(c: ScrollBar; x, y, w, h: INTEGER);
VAR fw, fh, X, Y: INTEGER;
  hs, bs: INTEGER; (* Handle size and button size *)
  grey: G.Color;
BEGIN
  G.MakeCol(grey, 140, 140, 140);

  DrawButtonBox(x, y, c.w, c.h, grey, c.parent.bgColor, TRUE, TRUE);
  ScrollBarCalcMetrics(c, h, w, hs, bs);
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
    DrawHorzScrollBar(c, x, y, w, h)
  END;
  Drawn(c)
END DrawScrollBar;

PROCEDURE ScrollBarSetVertical*(c: ScrollBar; vertical: BOOLEAN);
BEGIN c.vertical := vertical; Redraw(c)
END ScrollBarSetVertical;

PROCEDURE ScrollBarSetHandleSize*(c: ScrollBar; size: INTEGER);
BEGIN c.handleSize := size; Redraw(c)
END ScrollBarSetHandleSize;

PROCEDURE ScrollBarSetValue*(c: ScrollBar; value: INTEGER);
BEGIN
  IF (value < c.min) OR (c.min >= c.max) THEN value := c.min
  ELSIF value > c.max THEN value := c.max
  END;
  IF c.value # value THEN
    c.value := value;
    IF c.onScroll # NIL THEN c.onScroll(c, value) END;
    Redraw(c)
  END
END ScrollBarSetValue;

PROCEDURE HandleScrollBarMouseMove(c: ScrollBar; VAR msg: MouseMoveMsg);
VAR n, x, size, w: INTEGER;
BEGIN
  IF c.handlePressed THEN
    IF c.vertical THEN x := msg.y; size := c.h
    ELSE x := msg.x; size := c.w
    END;

    w := size - c.btnSize * 2 - c.handleSize + 4;
    IF w = 0 THEN n := c.min
    ELSE n := x - c.handlePressPos - c.btnSize + 2;
      n := (n * (c.max - c.min) + w DIV 2) DIV w + c.min;
    END;
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
    Redraw(c)
  ELSIF x >= size - c.btnSize THEN
    c.btnPressed := 2(*More btn*);
    ScrollBarSetValue(c, c.value + d);
    Redraw(c)
  ELSIF msg.btn = 1 THEN
    IF (c.handlePos <= x) & (x < c.handlePos + c.handleSize) THEN
      c.btnPressed := 3(*Handle*);
      c.handlePressed := TRUE;
      c.handlePressPos := x - c.handlePos
    ELSIF x < c.handlePos THEN
      ScrollBarSetValue(c, c.value - c.bigInc)
    ELSE
      ScrollBarSetValue(c, c.value + c.bigInc)
    END;
    Redraw(c)
  ELSE c.btnPressed := 0(*Nothing*);
  END;
  WidgetHandler(c, msg)
END HandleScrollBarMouseDown;

PROCEDURE HandleScrollBarMouseUp(c: ScrollBar; VAR msg: MouseUpMsg);
BEGIN
  c.handlePressed := FALSE;
  c.btnPressed := 0(*Nothing*);
  Redraw(c)
END HandleScrollBarMouseUp;

PROCEDURE ScrollBarHandler*(c: Widget; VAR msg: Message);
VAR s: ScrollBar;
BEGIN s := c(ScrollBar);
  IF msg IS DrawMsg THEN
    DrawScrollBar(s, msg(DrawMsg).x, msg(DrawMsg).y,
        msg(DrawMsg).w, msg(DrawMsg).h)
  ELSIF msg IS MouseMoveMsg THEN HandleScrollBarMouseMove(s, msg(MouseMoveMsg))
  ELSIF msg IS MouseDownMsg THEN HandleScrollBarMouseDown(s, msg(MouseDownMsg))
  ELSIF msg IS MouseUpMsg THEN HandleScrollBarMouseUp(s, msg(MouseUpMsg))
  ELSE WidgetHandler(c, msg)
  END
END ScrollBarHandler;

PROCEDURE InitScrollBar*(c: ScrollBar; where: Widget;
    x, y, w, h: INTEGER);
BEGIN InitWidget(c, w, h);
  c.handle := ScrollBarHandler;
  c.value := 0; c.min := 0; c.max := 100; c.inc := 5; c.bigInc := 20;
  c.handlePos := 0; c.handleSize := 0; c.btnSize := 0;
  c.btnPressed := 0(*Nothing*);
  Put(c, where, x, y)
END InitScrollBar;

PROCEDURE NewScrollBar*(where: Widget; x, y, w, h: INTEGER): ScrollBar;
VAR c: ScrollBar;
BEGIN NEW(c); InitScrollBar(c, where, x, y, w, h)
RETURN c END NewScrollBar;

PROCEDURE ScrollBarSetOnScroll*(c: ScrollBar; proc: PROCEDURE (c: ScrollBar; value: INTEGER));
BEGIN c.onScroll := proc
END ScrollBarSetOnScroll;

(** ScrollBox **)

PROCEDURE ScrollBoxSetNoBg*(c: ScrollBox; noBg: BOOLEAN);
BEGIN PanelSetNoBg(c.inner, noBg)
END ScrollBoxSetNoBg;

PROCEDURE ScrollBoxHandler*(c: Widget; VAR msg: Message);
BEGIN
  IF msg IS DrawMsg THEN
    IF c.redraw THEN
      DrawBody(c, msg(DrawMsg).x, msg(DrawMsg).y, c.w, c.h, c.redrawSelf);
      Drawn(c)
    END
  ELSIF msg IS PutMsg THEN
    DirectPut(msg(PutMsg).what, c(ScrollBox).inner,
        msg(PutMsg).x, msg(PutMsg).y)
  ELSE WidgetHandler(c, msg)
  END
END ScrollBoxHandler;

PROCEDURE ScrollBoxSetInnerSize*(c: ScrollBox; w, h: INTEGER);
BEGIN
  Resize(c.inner, w, h);
  c.scbHorz.max := w - c.w + 16;
  c.scbVert.max := h - c.h + 16;

  IF (c.scbHorz.max > 0) & (w > 0) THEN
    SetVisible(c.scbHorz, TRUE);
    c.outer.h := c.h - c.scbHorz.h
  ELSE
    SetVisible(c.scbHorz, FALSE);
    c.outer.h := c.h
  END;
  c.scbVert.h := c.outer.h;

  IF (c.scbVert.max > 0) & (h > 0) THEN
    SetVisible(c.scbVert, TRUE);
    c.outer.w := c.w - c.scbVert.w
  ELSE
    SetVisible(c.scbVert, FALSE);
    c.outer.w := c.w
  END;
  c.scbHorz.w := c.outer.w;

  IF w > 0 THEN
    ScrollBarSetHandleSize(c.scbHorz, c.outer.w * (c.outer.w - 30) DIV w)
  END;
  IF h > 0 THEN
    ScrollBarSetHandleSize(c.scbVert, c.outer.h * (c.outer.h - 30) DIV h)
  END;

  Redraw(c)
END ScrollBoxSetInnerSize;

PROCEDURE ScrollBoxOnHorzScroll*(c: ScrollBar; value: INTEGER);
VAR sbx: ScrollBox;
BEGIN
  sbx := c.parent(ScrollBox);
  sbx.inner.x := -value;
  Redraw(sbx)
END ScrollBoxOnHorzScroll;

PROCEDURE ScrollBoxOnVertScroll*(c: ScrollBar; value: INTEGER);
VAR sbx: ScrollBox;
BEGIN
  sbx := c.parent(ScrollBox);
  sbx.inner.y := -value;
  Redraw(sbx)
END ScrollBoxOnVertScroll;

PROCEDURE InitScrollBox*(c: ScrollBox; where: Widget; x, y, w, h: INTEGER);
BEGIN InitWidget(c, w, h);
  c.handle := ScrollBoxHandler;

  c.scbHorz := NewScrollBar(NIL, 0, 0, w - 16, 16);
  DirectPut(c.scbHorz, c, 0, h - 16);
  ScrollBarSetOnScroll(c.scbHorz, ScrollBoxOnHorzScroll);

  c.scbVert := NewScrollBar(NIL, 0, 0, 16, h - 16);
  ScrollBarSetVertical(c.scbVert, TRUE);
  DirectPut(c.scbVert, c, w - 16, 0);
  ScrollBarSetOnScroll(c.scbVert, ScrollBoxOnVertScroll);

  c.outer := NewPanel(NIL, 0, 0, w - 16, h - 16);
  DirectPut(c.outer, c, 0, 0);
  PanelSetNoBg(c.outer, TRUE);

  c.inner := NewPanel(c.outer, 0, 0, 1, 1);
  ScrollBoxSetInnerSize(c, c.outer.w, c.outer.h);

  Put(c, where, x, y)
END InitScrollBox;

PROCEDURE NewScrollBox*(where: Widget; x, y, w, h: INTEGER): ScrollBox;
VAR c: ScrollBox;
BEGIN NEW(c); InitScrollBox(c, where, x, y, w, h)
RETURN c END NewScrollBox;

(** Canvas **)

PROCEDURE CanvasHandler*(c: Widget; VAR msg: Message);
VAR x, y: INTEGER;
BEGIN
  IF msg IS DrawMsg THEN
    IF c.redraw THEN
      x := msg(DrawMsg).x; y := msg(DrawMsg).y;
      IF c.redrawSelf THEN G.Draw(c(Canvas).bmp, x, y) END;
      DrawBody(c, x, y, c.w, c.h, c.redrawSelf);
      Drawn(c)
    END
  ELSE WidgetHandler(c, msg)
  END
END CanvasHandler;

PROCEDURE InitCanvas*(c: Canvas; where: Widget; x, y, w, h: INTEGER);
VAR wh: G.Color;
BEGIN InitWidget(c, w, h);
  c.bmp := G.NewBitmap(w, h);
  G.MakeCol(wh, 255, 255, 255);
  G.ClearBitmapToColor(c.bmp, wh);
  c.handle := CanvasHandler;
  Put(c, where, x, y)
END InitCanvas;

PROCEDURE NewCanvas*(where: Widget; x, y, w, h: INTEGER): Canvas;
VAR c: Canvas;
BEGIN NEW(c); InitCanvas(c, where, x, y, w, h)
RETURN c END NewCanvas;

(** General **)

PROCEDURE DrawAll;
VAR c: Widget;
  updated: BOOLEAN;
BEGIN
  G.TargetScreen;
  updated := FALSE;
  c := app.body;
  REPEAT
    IF c.redraw THEN
      DrawForm(c(Form));
      updated := TRUE
    END;
    c := c.next
  UNTIL c = app.body;
  IF updated OR forceFlip THEN
    G.Flip;
    G.Delay(4);
    forceFlip := FALSE
  ELSE G.Delay(4)
  END
END DrawAll;

PROCEDURE HandleMouseMove(VAR e: G.Event);
VAR c: Widget;
BEGIN
  forceFlip := TRUE;
  c := FindHoveredInRing(app.body, e.x, e.y, FALSE);
  IF c # NIL THEN
    WidgetHandleMouseMove(c, e.x - c.x, e.y - c.y, e.buttons)
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

PROCEDURE InitCursor;
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
  G.SetNewCursor(m, 0, 0)
END InitCursor;

PROCEDURE Init*;
BEGIN
  font := G.LoadFont('Data/Fonts/Main');
  IF font = NIL THEN font := G.LoadFont('../Data/Fonts/Main') END;
  IF font = NIL THEN Out.String('SimpleGui: Could not load font.'); Out.Ln END;
  InitCursor;
  Done := font # NIL;
  app := NewApp();
  hoveredWidget := NIL; pressedWidget := NIL;
  forceFlip := TRUE;
  pressedX := 0; pressedY := 0
END Init;

END SimpleGui.