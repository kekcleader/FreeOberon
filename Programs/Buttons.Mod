MODULE Buttons;
IMPORT Gui, G := Graph, Out;

TYPE
  Button* = POINTER TO ButtonDesc;
  ButtonDesc* = RECORD(Gui.Widget)
  END;

PROCEDURE DrawButton*(W: Gui.Widget; x, y: INTEGER);
VAR c: G.Color;
  f: G.Font;
  fw, fh: INTEGER;
BEGIN
  G.MakeCol(c, 210, 205, 200);
  G.FillRect(x, y, x + W.w - 1, y + W.h - 1, c);
  G.MakeCol(c, 255, 255, 255);
  G.FillRect(x, y, x + W.w - 1, y + W.h - 1, c);
  G.MakeCol(c, 0, 0, 0);
  G.HLine(x, y + W.h - 1, x + W.w - 1, c);
  G.VLine(x + W.w - 1, y, y + W.h - 1, c);
  G.MakeCol(c, 80, 80, 80);
  G.HLine(x + 1, y + W.h - 2, x + W.w - 2, c);
  G.VLine(x + W.w - 2, y + 1, y + W.h - 2, c);
  f := Gui.GetFont(W);
  G.GetMonoFontSize(f, fw, fh);
  G.MakeCol(c, 0, 0, 0);
  G.DrawString(W.text.s(*!FIXME*), x + 4,
    y + (W.h - fh) DIV 2, f, c)
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