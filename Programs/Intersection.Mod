MODULE Intersection;
IMPORT G := Graph, Random, Int;
CONST eps = 0.001;

TYPE
  Point = RECORD
    x, y: REAL
  END;
  Line = RECORD
    s, v: Point
  END;

VAR W, H: INTEGER;
  f: G.Font;
  YY: INTEGER;

PROCEDURE Intersect(A, B: Line; VAR t, T: REAL; VAR P: Point): BOOLEAN;
VAR z: REAL;
BEGIN
  z := A.v.x * B.v.y - A.v.y * B.v.x;
  IF (z < -eps) OR (z > eps) THEN
    t := ((B.s.x - A.s.x) * B.v.y - (B.s.y - A.s.y) * B.v.x) / z;
    P.x := A.s.x + A.v.x * t;
    P.y := A.s.y + A.v.y * t;
    IF (B.v.x < -eps) OR (B.v.x > eps) THEN
      T := (A.s.x - B.s.x + A.v.x * t) / B.v.x
    ELSE
      T := (A.s.y - B.s.y + A.v.y * t) / B.v.y
    END
  END
RETURN (z < -eps) OR (z > eps) END Intersect;

PROCEDURE SpreadLine(VAR A: Line);
VAR B, C: Line;
    t1, t2, T: REAL;
    P1, P2, E: Point;
    c: G.Color;
    ZZ: ARRAY 100 OF CHAR;
BEGIN
  B.s.x := 10.0;
  B.s.y := FLT(H) - 10.0;
  C.s.x := 10.0;
  C.s.y := 10.0;
  B.v.x := FLT(W) - 20.0;
  B.v.y := 0.0;
  C.v.x := FLT(W) - 20.0;
  C.v.y := 0.0;

  IF Intersect(A, B, t1, T, P1) & Intersect(A, C, t2, T, P2) THEN
    G.MakeCol(c, 0, 255, 0);
    G.FillRect(FLOOR(P1.x) - 3, FLOOR(P1.y) - 3, FLOOR(P1.x) + 3, FLOOR(P1.y) + 3, c);
    G.MakeCol(c, 255, 0, 0);
    G.FillRect(FLOOR(P2.x) - 3, FLOOR(P2.y) - 3, FLOOR(P2.x) + 3, FLOOR(P2.y) + 3, c);

    A.s := P1;
    A.v.x := P2.x - P1.x;
    A.v.y := P2.y - P1.y
  END;

  B.s.x := 10.0;
  B.s.y := 10.0;
  C.s.x := FLT(W) - 10.0;
  C.s.y := 10.0;
  B.v.x := 0.0;
  B.v.y := FLT(H) - 20.0;
  C.v.x := 0.0;
  C.v.y := FLT(H) - 20.0;

  IF Intersect(A, B, t1, T, P1) & Intersect(A, C, t2, T, P2) THEN
    G.MakeCol(c, 0, 255, 255);
    G.FillRect(FLOOR(P1.x) - 3, FLOOR(P1.y) - 3, FLOOR(P1.x) + 3, FLOOR(P1.y) + 3, c);
    G.MakeCol(c, 255, 0, 255);
    G.FillRect(FLOOR(P2.x) - 3, FLOOR(P2.y) - 3, FLOOR(P2.x) + 3, FLOOR(P2.y) + 3, c);

    Int.Str(FLOOR(t1 * 100), ZZ);
    G.DrawString(ZZ, 20, H - 50 + YY, f, c);
    Int.Str(FLOOR(t2 * 100), ZZ);
    G.DrawString(ZZ, 150, H - 50 + YY, f, c);
    INC(YY, 16);

    IF (t1 >= 0) & (t1 <= 1) THEN
      IF t1 < t2 THEN
        E.x := A.s.x + A.v.x;
        E.y := A.s.y + A.v.y;
        A.s := P1;
        A.v.x := E.x - A.s.x;
        A.v.y := E.y - A.s.y
      ELSE
        A.v.x := P1.x - A.s.x;
        A.v.y := P1.y - A.s.y
      END
    END;
    IF (t2 >= 0) & (t2 <= 1) THEN
      IF t1 < t2 THEN
        A.v.x := P2.x - A.s.x;
        A.v.y := P2.y - A.s.y
      ELSE
        E.x := A.s.x + A.v.x;
        E.y := A.s.y + A.v.y;
        A.s := P2;
        A.v.x := E.x - A.s.x;
        A.v.y := E.y - A.s.y
      END
    END
  END
END SpreadLine;

PROCEDURE Do;
VAR A, B: Line;
    c: G.Color;
    P: Point;
    t, T: REAL;
BEGIN
  YY := 0;
  G.ClearScreen;

  A.s.x := Random.Uniform() * W;
  A.s.y := Random.Uniform() * H;
  B.s.x := Random.Uniform() * W;
  B.s.y := Random.Uniform() * H;
  A.v.x := Random.Uniform() * W - A.s.x;
  A.v.y := Random.Uniform() * H - A.s.y;
  B.v.x := Random.Uniform() * W - B.s.x;
  B.v.y := Random.Uniform() * H - B.s.y;

  G.MakeCol(c, 155, 0, 0);
  G.ThickLine(FLOOR(A.s.x), FLOOR(A.s.y), FLOOR(A.s.x + A.v.x), FLOOR(A.s.y + A.v.y), c, 7);
  G.Rect(FLOOR(A.s.x) - 9, FLOOR(A.s.y) - 9, FLOOR(A.s.x) + 9, FLOOR(A.s.y) + 9, c);
  G.MakeCol(c, 155, 155, 0);
  G.ThickLine(FLOOR(B.s.x), FLOOR(B.s.y), FLOOR(B.s.x + B.v.x), FLOOR(B.s.y + B.v.y), c, 7);
  G.Rect(FLOOR(B.s.x) - 9, FLOOR(B.s.y) - 9, FLOOR(B.s.x) + 9, FLOOR(B.s.y) + 9, c);

  SpreadLine(A);
  SpreadLine(B);

  G.MakeCol(c, 255, 0, 0);
  G.Line(FLOOR(A.s.x), FLOOR(A.s.y), FLOOR(A.s.x + A.v.x), FLOOR(A.s.y + A.v.y), c);
  G.MakeCol(c, 255, 255, 0);
  G.Line(FLOOR(B.s.x), FLOOR(B.s.y), FLOOR(B.s.x + B.v.x), FLOOR(B.s.y + B.v.y), c);
  IF Intersect(A, B, t, T, P) THEN
    G.MakeCol(c, 0, 255, 255);
    G.Rect(FLOOR(P.x) - 9, FLOOR(P.y) - 9, FLOOR(P.x) + 9, FLOOR(P.y) + 9, c);
    G.MakeCol(c, 255, 255, 255);
    G.Rect(FLOOR(P.x) - 7, FLOOR(P.y) - 7, FLOOR(P.x) + 7, FLOOR(P.y) + 7, c)
  END;

  G.MakeCol(c, 0, 50, 255);
  G.Rect(10, 10, W - 10, H - 10, c)
END Do;

PROCEDURE Do2;
VAR ch: CHAR;
BEGIN
  G.Init;
  f := G.LoadFont('../Data/Fonts/Main');
  G.GetScreenSize(W, H);
  REPEAT
    Do;
    G.Flip;
    ch := G.ReadKey();
  UNTIL ch = CHR(27);
  G.Close
END Do2;

BEGIN
  Do2
END Intersection.