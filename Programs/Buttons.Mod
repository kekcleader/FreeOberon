MODULE Buttons;
IMPORT Gui, G := Graph, Out;

TYPE
  Button* = POINTER TO ButtonDesc;
  ButtonDesc* = RECORD(Gui.WidgetDesc)
  END;

PROCEDURE DrawNormalButton*(W: Gui.Widget; x, y: INTEGER);
VAR c: G.Color;
  active: BOOLEAN;
  w, h: INTEGER;
BEGIN
  active := {Gui.focus, Gui.active} * W.state # {};
  w := W.w; h := W.h;

  IF Gui.hover IN W.state THEN
    G.MakeCol(c, 220, 215, 210);
  ELSE G.MakeCol(c, 212, 208, 200)
  END;

  G.FillRect(x + 1, y + 1, x + W.w - 3, y + W.h - 3, c);

  IF active THEN
    G.MakeCol(c, 0, 0, 0);
    G.Rect(x, y, x + w - 1, y + h - 1, c);
    INC(x); INC(y); DEC(w, 2); DEC(h, 2)
  END;

  G.MakeCol(c, 255, 255, 255);
  G.Rect(x, y, x + w - 1, y + h - 1, c);
  G.MakeCol(c, 64, 64, 64);
  G.HLine(x, y + h - 1, x + w - 1, c);
  G.VLine(x + w - 1, y, y + h - 1, c);
  G.MakeCol(c, 128, 128, 128);
  G.HLine(x + 1, y + h - 2, x + w - 2, c);
  G.VLine(x + w - 2, y + 1, y + h - 2, c)
END DrawNormalButton;

PROCEDURE DrawDownButton*(W: Gui.Widget; x, y: INTEGER);
VAR c: G.Color;
BEGIN
  G.MakeCol(c, 220, 215, 210);
  G.FillRect(x + 2, y + 2, x + W.w - 3, y + W.h - 3, c);

  G.MakeCol(c, 0, 0, 0);
  G.Rect(x, y, x + W.w - 1, y + W.h - 1, c);

  G.MakeCol(c, 128, 128, 128);
  G.Rect(x + 1, y + 1, x + W.w - 2, y + W.h - 2, c)
END DrawDownButton;

PROCEDURE DrawButton*(W: Gui.Widget; x, y: INTEGER);
VAR c: G.Color;
  f: G.Font;
  fw, fh: INTEGER;
BEGIN
  IF Gui.down IN W.state THEN DrawDownButton(W, x, y)
  ELSE DrawNormalButton(W, x, y)
  END;

  f := Gui.GetFont(W);
  G.GetMonoFontSize(f, fw, fh);
  G.MakeCol(c, 0, 0, 0);

  INC(x, 4); INC(y, (W.h - fh) DIV 2);
  IF Gui.down IN W.state THEN INC(x); INC(y) END;

  G.DrawString(W.text.s(*!FIXME*), x, y, f, c)
END DrawButton;

PROCEDURE InitButton*(b: Button; w, h: INTEGER; text: ARRAY OF CHAR);
BEGIN
  Gui.InitWidget(b);
  b.w := w; b.h := h;
  Gui.SetText(b, text);
  b.draw := DrawButton
END InitButton;

PROCEDURE NewButton*(w, h: INTEGER; text: ARRAY OF CHAR): Button;
VAR b: Button;
BEGIN NEW(b); InitButton(b, w, h, text)
RETURN b END NewButton;

END Buttons.