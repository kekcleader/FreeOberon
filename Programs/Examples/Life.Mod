MODULE Life;
IMPORT G := Graph, Random;
CONST maxW = 60*4; maxH = 33*4;
  cellSize = 4;
  initial = 0.44;
TYPE
  Field = ARRAY maxH, maxW OF BOOLEAN;
VAR
  sw, sh: INTEGER; (* Screen size in pixels *)
  W, H: INTEGER; (* Actual width and height of field in cells *)
  m, m2: Field; (* m2 is a temporary copy of m *)
  x0, y0: INTEGER; (* Field offset on screen in pixels *)
  red, black, white: G.Color;

PROCEDURE Neighbours(x, y: INTEGER): INTEGER;
VAR n: INTEGER;
BEGIN
  n := 0;
  IF y # 0 THEN
    IF m2[y - 1, x] THEN INC(n) END;
    IF (x # 0) & m2[y - 1, x - 1] THEN INC(n) END;
    IF (x # W - 1) & m2[y - 1, x + 1] THEN INC(n) END;
  END;
  IF (x # 0) & m2[y, x - 1] THEN INC(n) END;
  IF (x # W - 1) & m2[y, x + 1] THEN INC(n) END;
  IF y # H - 1 THEN
    IF m2[y + 1, x] THEN INC(n) END;
    IF (x # 0) & m2[y + 1, x - 1] THEN INC(n) END;
    IF (x # W - 1) & m2[y + 1, x + 1] THEN INC(n) END;
  END;
  RETURN n
END Neighbours;

PROCEDURE Live;
VAR x, y, n: INTEGER;
BEGIN
  m2 := m;
  FOR y := 0 TO H - 1 DO
    FOR x := 0 TO W - 1 DO
      n := Neighbours(x, y);
      IF n = 3 THEN
        m[y, x] := TRUE
      ELSIF n # 2 THEN
        m[y, x] := FALSE
      END
    END
  END
END Live;

PROCEDURE DrawCell(x, y: INTEGER);
VAR xx, yy: INTEGER;
  c: G.Color;
BEGIN
  xx := x0 + x * cellSize;
  yy := y0 + y * cellSize;
  IF m[y, x] THEN c := red ELSE c := black END;
  G.FillRect(xx, yy, xx + cellSize - 1, yy + cellSize - 1, c)
END DrawCell;

PROCEDURE Draw;
VAR x, y: INTEGER;
BEGIN
  FOR y := 0 TO H - 1 DO
    FOR x := 0 TO W - 1 DO
      DrawCell(x, y)
    END
  END;
  G.Flip
END Draw;

PROCEDURE Run;
BEGIN
  REPEAT
    Draw;
    Live
  UNTIL G.KeyPressed()
END Run;

PROCEDURE Init;
VAR x, y: INTEGER;
BEGIN
  G.Settings(640, 480, {});
  G.Init;

  G.GetScreenSize(sw, sh);
  W := sw DIV cellSize;
  H := sh DIV cellSize;
  IF W >= maxW THEN W := maxW - 1 END;
  IF H >= maxH THEN H := maxH - 1 END;

  G.MakeCol(red, 240, 0, 0);
  G.MakeCol(black, 10, 10, 10);
  G.MakeCol(white, 230, 230, 230);

  FOR y := 0 TO H - 1 DO
    FOR x := 0 TO W - 1 DO
      m[y, x] := Random.Uniform() < initial
    END
  END;
  x0 := (sw - cellSize * W) DIV 2;
  y0 := (sh - cellSize * H) DIV 2
END Init;

BEGIN
  Init;
  Run;
  G.Close
END Life.
