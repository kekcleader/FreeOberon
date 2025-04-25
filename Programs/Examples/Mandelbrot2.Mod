MODULE Mandelbrot2;
IMPORT G := Graph, M := Math, Random;
CONST iter = 768;
VAR col, W, H: INTEGER;
  m: POINTER TO ARRAY OF ARRAY OF INTEGER;
  angle: REAL;

PROCEDURE Go(sx, sy: INTEGER; x, y: REAL);
VAR col, i: INTEGER;
  re, im, re2: REAL;
BEGIN re := x; im := y; i := 0;
  REPEAT re2 := re * re - im * im;
    im := 2.0 * re * im; re := re2;
    re := re + x; im := im + y; INC(i)
  UNTIL (i = iter) OR (re * re + im * im > 4.0);
  m[sy, sx] := i
END Go;

PROCEDURE Draw;
VAR i, x, y: INTEGER;
  shine: REAL;
  c: G.Color;
BEGIN shine := 1.0 - M.cos(angle);
  FOR y := 0 TO H - 1 DO
    FOR x := 0 TO W - 1 DO
      i := m[y, x];
      IF i # iter THEN
        i := FLOOR(FLT(i) * shine);
        IF i > 255 THEN i := 255 END;
        CASE col OF
          0: G.MakeCol(c, i, 0, 0)
        | 1: G.MakeCol(c, i, i DIV 3, 0)
        | 2: G.MakeCol(c, i, i, 0)
        | 3: G.MakeCol(c, 0, i, 0)
        | 4: G.MakeCol(c, 0, i DIV 2, i)
        | 5: G.MakeCol(c, 0, 0, i)
        | 6: G.MakeCol(c, i * 2 DIV 4, 0, i * 2 DIV 4)
        END;
        G.PutPixel(x, y, c)
      END
    END
  END
END Draw;

PROCEDURE Set(cx, cy, r: REAL);
VAR x, y: INTEGER;
  x0, y0, x1, y1: REAL;
BEGIN
  x0 := cx - r; x1 := cx + r;
  y0 := cy + r * FLT(H) / FLT(W); y1 := 2.0 * cy - y0;
  y := 0;
  WHILE (y < H) & ~G.KeyPressed() DO
    FOR x := 0 TO W - 1 DO
      Go(x, y, x0 + x / (W - 1) * (x1 - x0),
               y0 + y / (H - 1) * (y1 - y0))
    END;
    INC(y)
  END
END Set;

PROCEDURE Do;
VAR x, y, r: REAL;
BEGIN G.Settings(320, 200, {G.exact});
  G.Init; G.Flip; G.GetScreenSize(W, H); NEW(m, H, W);
  x := -0.619; y := -0.456; r := 0.1;
  Set(x, y, r);
  angle := 0.0; col := 0;
  REPEAT Draw; angle := angle + M.pi / 45.0;
    IF angle > M.pi * 2.0 THEN
      angle := 0.0;
      col := (col + 1) MOD 7;
      G.ClearScreen; G.Flip;
      r := r / 2.0;
      Set(x, y, r)
    ELSE G.Flip; G.Delay(10)
    END
  UNTIL G.KeyPressed();
  G.Close
END Do;

BEGIN
  Do
END Mandelbrot2.
