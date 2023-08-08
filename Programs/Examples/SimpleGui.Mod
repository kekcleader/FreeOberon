MODULE SimpleGui;
IMPORT G := Graph, Strings, Out;

TYPE
  Widget* = POINTER TO WidgetDesc;

  Message* = RECORD END;
  DrawMsg* = RECORD(Message) x*, y*, w*, h*: INTEGER END;
  MouseMoveMsg* = RECORD(Message) x*, y*: INTEGER END;
  MouseEnterMsg* = RECORD(Message) END;
  MouseLeaveMsg* = RECORD(Message) END;
  MouseDownMsg* = RECORD(Message) x*, y*: INTEGER END;
  MouseUpMsg* = RECORD(Message) x*, y*: INTEGER END;

  Handler* = PROCEDURE (c: Widget; VAR msg: Message);

  WidgetDesc* = RECORD
    x*, y*, w*, h*: INTEGER;
    bgColor*, fgColor*: G.Color;
    body*: Widget;
    next*: Widget;
    handle*: Handler;
  END;

  Panel* = POINTER TO PanelDesc;
  PanelDesc* = RECORD(WidgetDesc) END;

  Form* = POINTER TO FormDesc;
  FormDesc* = RECORD(PanelDesc) END;

  Button* = POINTER TO ButtonDesc;
  ButtonDesc* = RECORD(WidgetDesc)
    caption*: ARRAY 64 OF CHAR;
    hovered*: BOOLEAN; (** TRUE if mouse pointer is over the button *)
    pressed*: BOOLEAN (** TRUE if button is held down with LMB *)
    ;X*, Y*: INTEGER
  END;

VAR
  Done*: BOOLEAN; (** FALSE after a failed opration and before the next Init *)
  forms*: Form;
  font*: G.Font;
  quit: BOOLEAN; (** Main loop in procedure Run ends when TRUE *)
  hoveredWidget: Widget;
  pressedWidget: Widget;
  pressedX, pressedY: INTEGER;

(** Widget **)

PROCEDURE FindHoveredInList(list: Widget; x, y: INTEGER;
    forMouseDown: BOOLEAN): Widget;
VAR c: Widget;
BEGIN c := list;
  WHILE (c # NIL) &
        ~((c.x <= x) & (x < c.x + c.w) &
          (c.y <= y) & (y < c.y + c.h))
  DO c := c.next
  END;
  IF forMouseDown & (c # NIL) THEN
    INC(pressedX, c.x); INC(pressedY, c.y)
  END
RETURN c END FindHoveredInList;

PROCEDURE WidgetOnMouseEnter*(c: Widget);
VAR msg: MouseEnterMsg;
BEGIN c.handle(c, msg)
END WidgetOnMouseEnter;

PROCEDURE WidgetOnMouseLeave*(c: Widget);
VAR msg: MouseLeaveMsg;
BEGIN c.handle(c, msg)
END WidgetOnMouseLeave;

PROCEDURE WidgetOnMouseMove*(c: Widget; x, y: INTEGER);
VAR msg: MouseMoveMsg;
BEGIN
  IF (hoveredWidget = NIL) OR (c # hoveredWidget) THEN
    IF hoveredWidget # NIL THEN WidgetOnMouseLeave(hoveredWidget) END;
    hoveredWidget := c;
    WidgetOnMouseEnter(hoveredWidget)
  END;
  msg.x := x; msg.y := y;
  c.handle(c, msg)
END WidgetOnMouseMove;

PROCEDURE WidgetHandleMouseMove*(c: Widget; x, y: INTEGER);
VAR p: Widget;
BEGIN
  IF pressedWidget # NIL THEN
    WidgetOnMouseMove(pressedWidget, x - pressedX, y - pressedY)
  ELSE
    p := FindHoveredInList(c.body, x, y, FALSE);
    IF p # NIL THEN
      WidgetHandleMouseMove(p, x - p.x, y - p.y)
    ELSE
      WidgetOnMouseMove(c, x, y)
    END
  END
END WidgetHandleMouseMove;

PROCEDURE WidgetOnMouseDown*(c: Widget; x, y: INTEGER);
VAR msg: MouseDownMsg;
BEGIN
  pressedWidget := c;
  msg.x := x; msg.y := y;
  c.handle(c, msg)
END WidgetOnMouseDown;

PROCEDURE WidgetHandleMouseDown*(c: Widget; x, y: INTEGER);
VAR p: Widget;
BEGIN
  p := FindHoveredInList(c.body, x, y, TRUE);
  IF p # NIL THEN
    WidgetHandleMouseDown(p, x - p.x, y - p.y)
  ELSE
    WidgetOnMouseDown(c, x, y)
  END
END WidgetHandleMouseDown;

PROCEDURE WidgetOnMouseUp*(c: Widget; x, y: INTEGER);
VAR msg: MouseUpMsg;
BEGIN
  pressedWidget := NIL;
  msg.x := x; msg.y := y;
  c.handle(c, msg)
END WidgetOnMouseUp;

PROCEDURE WidgetHandleMouseUp*(c: Widget; x, y: INTEGER);
VAR p: Widget;
BEGIN
  IF pressedWidget # NIL THEN
    WidgetOnMouseUp(pressedWidget, x - pressedX, y - pressedY)
  ELSE
    p := FindHoveredInList(c.body, x, y, FALSE);
    IF p # NIL THEN
      WidgetHandleMouseUp(p, x - p.x, y - p.y)
    ELSE
      WidgetOnMouseUp(c, x, y)
    END
  END
END WidgetHandleMouseUp;

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
  Z: G.Color;
BEGIN
  p := c.body;
  WHILE p # NIL DO
    x2 := x + p.x; y2 := y + p.y;
    w2 := w - p.x; h2 := h - p.y;
    (* !FIXME clip x2,y2,w2,h2 to not more than x,y,w,h*)
    (*G.UnsetClip; G.MakeCol(Z, 255, 0, 0); G.Rect(x2-1, y2-1, x2 + w2, y2 + h2,Z);*)
    G.SetClip(x2, y2, p.w, p.h);
    DrawWidget(p, x2, y2, p.w, p.h);
    p := p.next
  END;
  G.UnsetClip
END DrawBody;

PROCEDURE SetBgColor*(c: Widget; color: G.Color);
BEGIN c.bgColor := color
END SetBgColor;

PROCEDURE SetFgColor*(c: Widget; color: G.Color);
BEGIN c.fgColor := color
END SetFgColor;

PROCEDURE InitWidget*(c: Widget; w, h: INTEGER);
BEGIN c.x := 0; c.y := 0; c.w := w; c.h := h;
  G.MakeCol(c.bgColor, 180, 180, 180);
  G.MakeCol(c.fgColor, 0, 0, 0);
  c.handle := WidgetHandler;
  c.body := NIL; c.next := NIL
END InitWidget;

PROCEDURE Put*(c, where: Widget; x, y: INTEGER);
BEGIN
  IF c # NIL THEN
    c.x := x; c.y := y;
    IF where # NIL THEN
      c.next := where.body;
      where.body := c
    END
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
  c.next := forms; forms := c
END InitForm;

PROCEDURE NewForm*(x, y, w, h: INTEGER): Form;
VAR c: Form;
BEGIN NEW(c); InitForm(c, x, y, w, h);
RETURN c END NewForm;

(** Button **)

PROCEDURE DrawButton*(c: Button; x, y, w, h: INTEGER);
VAR cw, ch, tw, tx, ty: INTEGER;
  down: BOOLEAN;
  Z: G.Color;
BEGIN
  down := c(Button).pressed & c(Button).hovered;
  G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);

  ;G.MakeCol(Z, 255, 128, 0);
  ;G.Line(x + c.h DIV 4, y + c.h DIV 2, x + c(Button).X, y + c(Button).Y, Z);
  ;G.MakeCol(Z, 215, 0, 0);
  ;G.Line(x + c.h DIV 4, y + c.h DIV 2 + 1, x + c(Button).X, y + c(Button).Y + 1, Z);

  G.Rect(x, y, x + c.w - 1, y + c.h - 1, c.fgColor);
  IF ~down THEN
    G.Rect(x, y, x + c.w - 2, y + c.h - 2, c.fgColor)
  END;
  G.GetMonoFontSize(font, cw, ch);
  tw := Strings.Length(c.caption) * cw;
  tx := x + (c.w - tw) DIV 2;
  ty := y + (c.h - ch) DIV 2;
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
  ELSIF msg IS MouseDownMsg THEN b.pressed := TRUE
  ELSIF msg IS MouseUpMsg THEN b.pressed := FALSE
  ELSE WidgetHandler(c, msg)
  END
END ButtonHandler;

PROCEDURE InitButton*(c: Button; where: Widget;
    x, y, w, h: INTEGER; caption: ARRAY OF CHAR);
BEGIN InitWidget(c, w, h);
  Strings.Copy(caption, c.caption);
  c.hovered := FALSE;
  c.pressed := FALSE;
  c.handle := ButtonHandler;
  Put(c, where, x, y)
  ;c.X := 0; c.Y := 0;
END InitButton;

PROCEDURE NewButton*(where: Widget; x, y, w, h: INTEGER; caption: ARRAY OF CHAR): Button;
VAR c: Button;
BEGIN NEW(c); InitButton(c, where, x, y, w, h, caption)
RETURN c END NewButton;

(** General **)

PROCEDURE DrawAll*;
VAR c: Widget;
BEGIN
  c := forms;
  WHILE c # NIL DO
    DrawForm(c(Form));
    c := c.next
  END;
  G.Flip
END DrawAll;

PROCEDURE HandleMouseMove(VAR e: G.Event);
VAR c: Widget;
BEGIN
  c := FindHoveredInList(forms, e.x, e.y, FALSE);
  IF c # NIL THEN
    WidgetHandleMouseMove(c, e.x - c.x, e.y - c.y)
  END
END HandleMouseMove;

PROCEDURE HandleMouseDown(VAR e: G.Event);
VAR c: Widget;
BEGIN
  pressedX := 0; pressedY := 0;
  c := FindHoveredInList(forms, e.x, e.y, TRUE);
  IF c # NIL THEN
    WidgetHandleMouseDown(c, e.x - c.x, e.y - c.y)
  END
END HandleMouseDown;

PROCEDURE HandleMouseUp(VAR e: G.Event);
VAR c: Widget;
BEGIN
  c := FindHoveredInList(forms, e.x, e.y, FALSE);
  IF c # NIL THEN
    WidgetHandleMouseUp(c, e.x - c.x, e.y - c.y)
  END
END HandleMouseUp;

PROCEDURE HandleEvent(VAR e: G.Event);
BEGIN
  IF e.type = G.quit THEN quit := TRUE
  ELSIF e.type = G.mouseMove THEN HandleMouseMove(e)
  ELSIF e.type = G.mouseDown THEN HandleMouseDown(e)
  ELSIF e.type = G.mouseUp THEN HandleMouseUp(e)
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