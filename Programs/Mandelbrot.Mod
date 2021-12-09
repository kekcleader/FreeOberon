MODULE Mandelbrot;
IMPORT G := Graph;
VAR s: G.Bitmap;

PROCEDURE Go(sx, sy: INTEGER; x, y: REAL);
CONST iter = 768;
VAR col, i: INTEGER;
  re, im, re2: REAL;
BEGIN re := x; im := y; i := 0;
  REPEAT re2 := re * re - im * im;
    im := 2 * re * im; re := re2;
    re := re + x; im := im + y; INC(i)
  UNTIL (i = iter) OR (re * re + im * im > 4);
  IF i # iter THEN i := i * 5;
    IF i > 255 THEN i := 255 END;
    G.PutPixel(s, sx, sy, G.MakeCol(i, 0, 0))
  END
END Go;

PROCEDURE Do;
VAR x, y: INTEGER;
  x0, y0, x1, y1: REAL;
BEGIN G.Settings(0, 0, {G.fullscreen});
  s := G.Init(); G.Flip;
  y0 := 1.0; y1 := -1.0;
  x1 := 2.0 * s.w / s.h / 3.0; x0 := -x1 * 2.0;
  FOR y := 0 TO s.h - 1 DO
    FOR x := 0 TO s.w - 1 DO
      Go(x, y, x0 + x / (s.w - 1) * (x1 - x0),
               y0 + y / (s.h - 1) * (y1 - y0))
    END
  END;
  G.Flip; G.Pause; G.Close
END Do;

BEGIN
  Do
END Mandelbrot.
