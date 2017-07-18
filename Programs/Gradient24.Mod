MODULE Gradient24;
IMPORT G := Graph;
VAR screen: G.Bitmap;
    y, b: INTEGER;
BEGIN
  screen := G.Init();
  y := 0;
  REPEAT
    b := 255 - 255 * y DIV screen.h;
    G.Line(screen, 0, y, screen.w - 1, y, G.MakeCol(b, 0, b));
    INC(y)
  UNTIL b = 0;
  G.Flip;
  G.Pause;
  G.Close
END Gradient24.