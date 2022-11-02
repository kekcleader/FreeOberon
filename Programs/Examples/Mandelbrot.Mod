MODULE Mandelbrot;
IMPORT G := Graph;

PROCEDURE Go(sx, sy: INTEGER; x, y: REAL);
CONST iter = 768;
VAR c: G.Color;
  col, i: INTEGER;
  re, im, re2: REAL;
BEGIN re := x; im := y; i := 0;
  REPEAT re2 := re * re - im * im;
    im := 2 * re * im; re := re2;
    re := re + x; im := im + y; INC(i)
  UNTIL (i = iter) OR (re * re + im * im > 4);
  IF i # iter THEN i := i * 5;
    IF i > 255 THEN i := 255 END;
    G.MakeCol(c, i, 0, 0);
    G.PutPixel(sx, sy, c)
  END
END Go;

PROCEDURE Do;
VAR x, y, W, H: INTEGER;
  x0, y0, x1, y1: REAL;
BEGIN G.Settings(0, 0, {G.fullscreen});
  G.Init; G.GetScreenSize(W, H); G.ClearScreen; G.Flip;
  y0 := 1.0; y1 := -1.0;
  x1 := 2.0 * W / H / 3.0; x0 := -x1 * 2.0;
  FOR y := 0 TO H - 1 DO
    FOR x := 0 TO W - 1 DO
      Go(x, y, x0 + x / (W - 1) * (x1 - x0),
               y0 + y / (H - 1) * (y1 - y0))
    END
  END;
  G.Flip; G.Pause; G.Close
END Do;

BEGIN
  Do
END Mandelbrot.
