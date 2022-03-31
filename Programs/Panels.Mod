MODULE Panels;
IMPORT Gui, G := Graph, Strings, Out;

CONST
  marTop = 8;
  indent = 6;

TYPE
  Panel* = POINTER TO PanelDesc;
  PanelDesc* = RECORD(Gui.WidgetDesc) END;

PROCEDURE DrawPanel*(W: Gui.Widget; x, y: INTEGER);
VAR c: G.Color;
  f: G.Font;
  fw, fh, tLen: INTEGER;
BEGIN
  f := Gui.GetFont(W);
  G.GetMonoFontSize(f, fw, fh);
  tLen := fw * Strings.Length(W.text.s(*!FIXME*)) + 4;

  G.MakeCol(c, 0, 0, 0);
  G.DrawString(W.text.s(*!FIXME*), x + indent + 2, y, f, c);

  G.MakeCol(c, 128, 128, 128);
  G.HLine(x, y + marTop, x + indent, c);
  G.HLine(x + indent + tLen, y + marTop, x + W.w - 2, c);
  G.VLine(x, y + marTop, y + W.h - 2, c);
  G.HLine(x, y + W.h - 2, x + W.w - 2, c);
  G.VLine(x + W.w - 2, y + marTop, y + W.h - 2, c);

  G.MakeCol(c, 255, 255, 255);
  G.HLine(x + 1, y + marTop + 1, x + indent, c);
  G.HLine(x + indent + tLen, y + marTop + 1, x + W.w - 3, c);
  G.VLine(x + 1, y + marTop + 1, y + W.h - 3, c);
  G.HLine(x, y + W.h - 1, x + W.w - 1, c);
  G.VLine(x + W.w - 1, y + marTop, y + W.h - 2, c);

  Gui.DrawBody(W, x, y)
END DrawPanel;

PROCEDURE InitPanel*(p: Panel; w, h: INTEGER; title: ARRAY OF CHAR);
BEGIN
  Gui.InitWidget(p);
  p.w := w; p.h := h;
  Gui.SetText(p, title);
  p.draw := DrawPanel
END InitPanel;

PROCEDURE NewPanel*(w, h: INTEGER; title: ARRAY OF CHAR): Panel;
VAR p: Panel;
BEGIN NEW(p); InitPanel(p, w, h, title)
RETURN p END NewPanel;

END Panels.