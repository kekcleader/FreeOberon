MODULE Gradient24;
IMPORT G := Graph;
VAR y, b, W, H: INTEGER;
  c: G.Color;
BEGIN
  G.Init;
  G.GetScreenSize(W, H);
  y := 0;
  REPEAT
    b := 255 - 255 * y DIV H;
    G.MakeCol(c, b, 0, b);
    G.Line(0, y, W - 1, y, c);
    INC(y)
  UNTIL b = 0;
  G.Flip;
  G.Pause;
  G.Close
END Gradient24.