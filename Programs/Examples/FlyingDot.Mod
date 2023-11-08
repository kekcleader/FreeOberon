MODULE FlyingDot;
IMPORT G := Graph;
VAR c: G.Color;
  x, y, vy: INTEGER;
BEGIN
  G.Init;
  G.MakeCol(c, 255, 255, 255);
  x := 0; y := 10; vy := 0;
  REPEAT
    G.PutPixel(x, y, c);
    INC(x, 2); INC(y, vy); INC(vy);
    IF vy > 15 THEN vy := -13 END;
    G.Flip;
    G.Delay(20)
  UNTIL G.KeyPressed();
  G.Close
END FlyingDot.