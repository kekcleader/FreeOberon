MODULE Life2;
IMPORT G := Graph2, Random;
CONST maxW = 60*8; maxH = 33*8;
  cellSize = 2;
  initial = 0.2;
TYPE
  Field = ARRAY maxH, maxW OF INTEGER;
VAR
  S: G.Bitmap;
  W, H: INTEGER; (* Real width and height of field in cells *)
  m, m2: Field; (* m2 is a temporary copy of m *)
  x0, y0: INTEGER; (* Field offset on screen in pixels *)
  colors: ARRAY 9 OF G.Color; (* Color constants: black, red etc. *)

  saved: ARRAY 3 OF INTEGER; (* Saved neighbour colors *)
  nofcolors: INTEGER; (* Number of saved neighbour colors *)

PROCEDURE Save(y, x: INTEGER);
BEGIN
  IF nofcolors < LEN(saved) THEN
    saved[nofcolors] := m2[y, x];
    INC(nofcolors)
  END
END Save;

PROCEDURE GetColor(): INTEGER;
VAR c: INTEGER;
BEGIN
  IF saved[0] = saved[1] THEN c := saved[0]
  ELSIF saved[0] = saved[2] THEN c := saved[0]
  ELSIF saved[1] = saved[2] THEN c := saved[1]
  ELSE c := saved[Random.Int(3)]
  END;
  RETURN c
END GetColor;

PROCEDURE Neighbours(x, y: INTEGER): INTEGER;
VAR n: INTEGER;
BEGIN
  n := 0;
  nofcolors := 0;
  IF y # 0 THEN
    IF m2[y - 1, x] # 0 THEN INC(n); Save(y - 1, x) END;
    IF (x # 0) & (m2[y - 1, x - 1] # 0) THEN INC(n); Save(y - 1, x - 1) END;
    IF (x # W - 1) & (m2[y - 1, x + 1] # 0) THEN INC(n); Save(y - 1, x + 1) END
  END;
  IF (x # 0) & (m2[y, x - 1] # 0) THEN INC(n); Save(y, x - 1) END;
  IF (x # W - 1) & (m2[y, x + 1] # 0) THEN INC(n); Save(y, x + 1) END;
  IF y # H - 1 THEN
    IF m2[y + 1, x] # 0 THEN INC(n); Save(y + 1, x) END;
    IF (x # 0) & (m2[y + 1, x - 1] # 0) THEN INC(n); Save(y + 1, x - 1) END;
    IF (x # W - 1) & (m2[y + 1, x + 1] # 0) THEN INC(n); Save(y + 1, x + 1) END
  END;
  RETURN n
END Neighbours;

PROCEDURE Live;
VAR x, y, n, c: INTEGER;
BEGIN
  m2 := m;
  FOR y := 0 TO H - 1 DO
    FOR x := 0 TO W - 1 DO
      n := Neighbours(x, y);
      IF n = 3 THEN
        m[y, x] := GetColor()
      ELSIF n # 2 THEN
        m[y, x] := 0
      END
    END
  END
END Live;

PROCEDURE DrawCell(x, y: INTEGER);
VAR xx, yy: INTEGER; c: G.Color;
BEGIN
  xx := x0 + x * cellSize;
  yy := y0 + y * cellSize;
  c := colors[m[y, x]];
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
  G.Settings(640, 400, {G.sharpPixels, G.spread, G.fullscreen});
  S := G.Init();

  W := S.w DIV cellSize;
  H := S.h DIV cellSize;
  IF W >= maxW THEN W := maxW - 1 END;
  IF H >= maxH THEN H := maxH - 1 END;

  colors[0] := G.MakeCol(10, 10, 10);
  colors[1] := G.MakeCol(240, 0, 0);
  colors[2] := G.MakeCol(230, 230, 230);
  colors[3] := G.MakeCol(0, 100, 255);
  colors[4] := G.MakeCol(0, 230, 0);
  colors[5] := G.MakeCol(255, 255, 0);
  colors[6] := G.MakeCol(230, 0, 230);
  colors[7] := G.MakeCol(150, 80, 0);
  colors[8] := G.MakeCol(255, 150, 0);

  FOR y := 0 TO H - 1 DO
    FOR x := 0 TO W - 1 DO
      IF Random.Uniform() < initial THEN
        m[y, x] := Random.Int(8) + 1
      ELSE
        m[y, x] := 0
      END
    END
  END;
  x0 := (S.w - cellSize * W) DIV 2;
  y0 := (S.h - cellSize * H) DIV 2
END Init;

BEGIN
  Init;
  Run;
  G.Close
END Life2.
