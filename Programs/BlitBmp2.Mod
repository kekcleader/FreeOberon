MODULE BlitBmp2;
IMPORT G := Graph2, S := SYSTEM;
CONST N = 100;
VAR s, b: G.Bitmap;
  x, y, vx, vy: ARRAY N OF REAL;
  i: INTEGER;
BEGIN
  s := G.Init();
  IF s = NIL THEN HALT(3) END;
  b := G.LoadBitmap('../Data/Examples/rocket.png');
  IF b = NIL THEN HALT(4) END;
  FOR i := 0 TO N - 1 DO
    x[i] := s.w * G.Uniform();
    y[i] := s.h * G.Uniform();
    vx[i] := 0.0; vy[i] := -G.Uniform() * 5 - 0.3
  END;
  REPEAT
    G.ClearScreen;
    G.StretchBlit(b, s, 0, 0, b.w, b.h, 0, 0, s.w, s.h);
    FOR i := 0 TO N - 1 DO
      G.BlitWhole(b, s, FLOOR(x[i]), FLOOR(y[i]));
      x[i] := x[i] + vx[i]; y[i] := y[i] + vy[i];
      IF x[i] < -b.w THEN x[i] := x[i] + s.w + b.w
      ELSIF x[i] > s.w THEN x[i] := x[i] - s.w - b.w
      END;
      IF y[i] < -b.h THEN y[i] := y[i] + s.h + b.h
      ELSIF y[i] > s.h THEN y[i] := y[i] - s.h - b.h
      END;
      vx[i] := vx[i] + (G.Uniform() * 2 - 1) / 50;
      vy[i] := vy[i] + (G.Uniform() * 2 - 1) / 50
    END;
    G.Flip;
    G.Delay(20)
  UNTIL G.KeyPressed();
  G.Close
END BlitBmp2.