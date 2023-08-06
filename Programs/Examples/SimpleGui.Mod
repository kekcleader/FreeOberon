MODULE SimpleGui;
IMPORT G := Graph, Strings, Out;

TYPE
  Widget* = POINTER TO WidgetDesc;

  Message* = RECORD END;
  DrawMsg* = RECORD(Message) x*, y*, w*, h*: INTEGER END;
  MouseMoveMsg* = RECORD(Message) x*, y*: INTEGER END;
  MouseEnterMsg* = RECORD(Message) END;
  MouseLeaveMsg* = RECORD(Message) END;

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
    underMouse*: BOOLEAN
  END;

VAR
  Done*: BOOLEAN; (** FALSE after a failed opration and before the next Init *)
  forms*: Form;
  font*: G.Font;
  quit: BOOLEAN; (** Main loop in procedure Run ends when TRUE *)
  widgetUnderMouse: Widget;

(** Widget **)

PROCEDURE FindUnderMouseInList(x, y: INTEGER; c: Widget): Widget;
BEGIN
  WHILE (c # NIL) &
        ~((c.x <= x) & (x < c.x + c.w) &
          (c.y <= y) & (y < c.y + c.h))
  DO c := c.next
  END
RETURN c END FindUnderMouseInList;

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
  IF (widgetUnderMouse = NIL) OR (c # widgetUnderMouse) THEN
    IF widgetUnderMouse # NIL THEN WidgetOnMouseLeave(widgetUnderMouse) END;
    widgetUnderMouse := c;
    WidgetOnMouseEnter(widgetUnderMouse)
  END;
  msg.x := x; msg.y := y;
  c.handle(c, msg)
END WidgetOnMouseMove;

PROCEDURE WidgetHandleMouseMove*(c: Widget; x, y: INTEGER);
VAR p: Widget;
BEGIN
  p := FindUnderMouseInList(x, y, c.body);
  IF p # NIL THEN
    WidgetHandleMouseMove(p, x - p.x, y - p.y)
  ELSE
    WidgetOnMouseMove(c, x, y)
  END
END WidgetHandleMouseMove;

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
BEGIN
  p := c.body;
  WHILE p # NIL DO
    x2 := x + p.x; y2 := y + p.y;
    w2 := w - p.x; h2 := h - p.y;
    DrawWidget(p, x2, y2, w2, h2);
    p := p.next
  END
END DrawBody;

PROCEDURE InitWidget*(c: Widget; w, h: INTEGER);
BEGIN c.x := 0; c.y := 0; c.w := w; c.h := h;
  G.MakeCol(c.bgColor, 180, 180, 180);
  G.MakeCol(c.fgColor, 0, 0, 0);
  c.handle := WidgetHandler;
  c.body := NIL; c.next := NIL
END InitWidget;

PROCEDURE Put*(c, where: Widget; x, y: INTEGER);
BEGIN
  c.x := x; c.y := y;
  c.next := where.body;
  where.body := c
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

PROCEDURE InitPanel*(c: Panel; w, h: INTEGER);
BEGIN InitWidget(c, w, h);
  c.handle := PanelHandler
END InitPanel;

PROCEDURE NewPanel*(x, y, w, h: INTEGER): Panel;
VAR c: Panel;
BEGIN NEW(c); InitPanel(c, w, h)
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
BEGIN InitPanel(c, w, h);
  c.x := x; c.y := y;
  c.handle := FormHandler;
  c.next := forms; forms := c
END InitForm;

PROCEDURE NewForm*(x, y, w, h: INTEGER): Form;
VAR c: Form;
BEGIN NEW(c); InitForm(c, x, y, w, h);
RETURN c END NewForm;

(** Button **)

PROCEDURE DrawButton*(c: Button; x, y, w, h: INTEGER);
VAR cw, ch, tw: INTEGER;
BEGIN
  G.FillRect(x, y, x + c.w - 1, y + c.h - 1, c.bgColor);
  G.Rect(x, y, x + c.w - 1, y + c.h - 1, c.fgColor);
  IF ~c(Button).underMouse THEN
    G.Rect(x, y, x + c.w - 2, y + c.h - 2, c.fgColor)
  END;
  G.GetMonoFontSize(font, cw, ch);
  tw := Strings.Length(c.caption) * cw;
  G.DrawString(c.caption, x + (c.w - tw) DIV 2,
      y + (c.h - ch) DIV 2, font, c.fgColor)
END DrawButton;

PROCEDURE ButtonHandler*(c: Widget; VAR msg: Message);
VAR b: Button;
BEGIN b := c(Button);
  IF msg IS DrawMsg THEN
    DrawButton(b, msg(DrawMsg).x, msg(DrawMsg).y,
        msg(DrawMsg).w, msg(DrawMsg).h)
  ELSIF msg IS MouseEnterMsg THEN b.underMouse := TRUE
  ELSIF msg IS MouseLeaveMsg THEN b.underMouse := FALSE
  ELSE WidgetHandler(c, msg)
  END
END ButtonHandler;

PROCEDURE InitButton*(c: Button; where: Widget;
    x, y, w, h: INTEGER; caption: ARRAY OF CHAR);
BEGIN InitWidget(c, w, h);
  Strings.Copy(caption, c.caption);
  c.underMouse := FALSE;
  c.handle := ButtonHandler;
  Put(c, where, x, y)
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
  c := FindUnderMouseInList(e.x, e.y, forms);
  IF c # NIL THEN
    WidgetHandleMouseMove(c, e.x - c.x, e.y - c.y)
  END
END HandleMouseMove;

PROCEDURE HandleEvent(VAR e: G.Event);
BEGIN
  IF e.type = G.quit THEN quit := TRUE
  ELSIF e.type = G.mouseMove THEN HandleMouseMove(e)
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
  widgetUnderMouse := NIL
END Init;

END SimpleGui.