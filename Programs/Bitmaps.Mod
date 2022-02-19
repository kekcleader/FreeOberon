MODULE Bitmaps;
IMPORT G := Graph, Out, R := Random, M := Math;
CONST maxSpeed = 0.8;
  maxSpeed2 = maxSpeed * maxSpeed;
VAR b: G.Bitmap;
  w, h: INTEGER;
  x, y, vx, vy: REAL;
  r: REAL;
  c: G.Color;

PROCEDURE Val(x: INTEGER): INTEGER;
RETURN ABS((x MOD 512) - 256) END Val;

BEGIN
  G.Init; G.ShowMouse(FALSE);
  b := G.LoadBitmap('../Data/Images/Icon.png');
  IF b = NIL THEN Out.String('Could not load image.'); Out.Ln
  ELSE
    G.MakeRGBA(c, 0, 255, 255, 0);
    G.Target(b);
    G.ThickLine(0, 0, b.w - 1, b.h - 1, c, 3);
    G.TargetScreen;

    G.GetScreenSize(w, h);
    DEC(w, b.w); DEC(h, b.h);
    x := R.Uniform() * w;
    y := R.Uniform() * h;
    vx := 0.0; vy := 0.0;
    REPEAT
      x := x + vx; y := y + vy;
      IF x < 0 THEN vx := -vx; x := 0.0
      ELSIF x >= w THEN vx := -vx; x := FLT(w)
      END;
      IF y < 0 THEN vy := -vy; y := 0.0
      ELSIF y >= h THEN vy := -vy; y := FLT(h)
      END;
      vx := vx + (R.Uniform() - 0.5) * maxSpeed / 10;
      vy := vy + (R.Uniform() - 0.5) * maxSpeed / 10;
      r := vx * vx + vy * vy;
      IF r > maxSpeed2 THEN
        r := maxSpeed / M.sqrt(r);
        vx := vx * r; vy := vy * r
      END;
      (*G.ClearScreen;*)
      G.MakeCol(c, Val(FLOOR((x + y) / 4)), Val(FLOOR((x + y + 100) / 2)), 0);
      (*G.DrawTintedPart(b, c, 0, 0, b.w, b.h, FLOOR(x), FLOOR(y));*)
      G.Draw(b, FLOOR(x), FLOOR(y));
      G.Flip;
      G.Delay(1)
    UNTIL G.KeyPressed();
    G.Pause
  END;
  G.Close
END Bitmaps.