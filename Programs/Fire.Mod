MODULE Fire;
IMPORT Out, Random, G := Graph, M := Math, Int;
CONST signHeat = 63;
  introLen = 3000;
  signWaitDelay = 90;
  signChance = 2;
  fireRand = 3;
  K = 2; (* Pixel buffer resolution multiplier *)
VAR clr: ARRAY 64 OF G.Color;
  w, h: INTEGER;
  heat: INTEGER;
  m: ARRAY 300 * K, 640 * K OF BYTE;
  intro, wait: INTEGER;
  f: G.Font;

PROCEDURE PutPixel(x, y, c: INTEGER);
BEGIN
  IF m[y, x] # c THEN
    m[y, x] := c;
    G.PutPixel(x, y, clr[c])
  END
END PutPixel;

PROCEDURE PutPixelMaybe(x, y, c: INTEGER);
BEGIN
  IF (0 <= x) & (x < w) & (0 <= y) & (y < h) THEN
    PutPixel(x, y, c)
  END
END PutPixelMaybe;

PROCEDURE SwapPoints(VAR x1, y1, x2, y2: INTEGER);
VAR t: INTEGER;
BEGIN
  t := x1; x1 := x2; x2 := t;
  t := y1; y1 := y2; y2 := t
END SwapPoints;

PROCEDURE Line(x1, y1, x2, y2, c: INTEGER);
VAR dx, dy, x, y, half, t: INTEGER;
BEGIN
  dx := ABS(x1 - x2); dy := ABS(y1 - y2);
  IF dx = 0 THEN
    IF y1 > y2 THEN t := y1; y1 := y2; y2 := t END;
    FOR y := y1 TO y2 DO PutPixelMaybe(x1, y, c) END
  ELSIF dy = 0 THEN
    IF x1 > x2 THEN t := x1; x1 := x2; x2 := t END;
    FOR x := x1 TO x2 DO PutPixelMaybe(x, y1, c) END
  ELSIF dx > dy THEN
    IF x1 > x2 THEN SwapPoints(x1, y1, x2, y2) END;
    half := dx DIV 2;
    FOR x := x1 TO x2 DO
      PutPixelMaybe(x, y1 + ((y2 - y1) * x + half) DIV dx, c)
    END
  ELSE
    IF y1 > y2 THEN SwapPoints(x1, y1, x2, y2) END;
    half := dy DIV 2;
    FOR y := y1 TO y2 DO
      PutPixelMaybe(x1 + ((x2 - x1) * y + half) DIV dy, y, c)
    END
  END
END Line;

PROCEDURE ThickLine(x1, y1, x2, y2, c: INTEGER);
CONST T = 3;
VAR x, y: INTEGER;
BEGIN
  FOR y := 0 TO T DO
    FOR x := 0 TO T DO
      Line(x1 + x, y1 + y, x2 + x, y2 + y, c)
    END
  END
END ThickLine;

PROCEDURE C(x, y, W: INTEGER);
BEGIN
  ThickLine(x, y, x + W, y, signHeat);
  ThickLine(x, y + W, x + W, y + W, signHeat);
  ThickLine(x, y, x, y + W, signHeat)
END C;

PROCEDURE P(x, y, W: INTEGER);
VAR W2: INTEGER;
BEGIN
  W2 := W DIV 2;
  ThickLine(x, y, x + W, y, signHeat);
  ThickLine(x, y, x, y + W, signHeat);
  ThickLine(x, y + W2, x + W, y + W2, signHeat);
  ThickLine(x + W, y, x + W, y + W2, signHeat)
END P;

PROCEDURE Sign;
VAR x, y, i, W, pad: INTEGER;
BEGIN
  pad := w DIV 20;
  W := (w - 5 * pad) DIV 6;
  y := (h - W) DIV 2 - Random.Int(pad * 2);
  x := (w - W * 4 - 3 * pad) DIV 2 + Random.Int(pad * 4 + 1) - pad * 2;
  FOR i := 0 TO 2 DO C(x, y, W); INC(x, W + pad) END;
  P(x, y, W);
  wait := signWaitDelay
END Sign;

PROCEDURE GoFire;
VAR x, y, c: INTEGER;
BEGIN
  FOR y := 0 TO h - 2 DO
    FOR x := 1 TO w - 2 DO
      c := (m[y + 1, x] * 2 + m[y, x - 1] + m[y, x + 1]) DIV 4;
      IF c # 0 THEN INC(c, Random.Int(2 * fireRand + 1) - fireRand) END;
      IF c < 0 THEN c := 0 ELSIF c > 63 THEN c := 63 END;
      PutPixel(x, y, c)
    END
  END
END GoFire;

PROCEDURE Run;
VAR done: BOOLEAN;
  ch: CHAR;
  x, y: INTEGER;
  Z: ARRAY 20 OF CHAR;
BEGIN
  done := FALSE;
  FOR x := 0 TO w - 1 DO
    FOR y := 0 TO h - 1 DO
      m[y, x] := 0
    END
  END;
  REPEAT
    IF intro # 0 THEN
      DEC(intro);
      Line(2, h - 1, w - 3, h - 1,
        FLOOR((1 - M.sin(intro * (M.pi / 2) / introLen)) * 63))
    ELSE
      Line(2, h - 1, w - 3, h - 1, heat)
    END;

    IF wait = 0 THEN
      IF Random.Int(100) < signChance THEN Sign END
    ELSE DEC(wait)
    END;
    GoFire;
    G.Flip;

    IF G.KeyPressed() THEN
      ch := G.ReadKey();
      IF ch = CHR(27) THEN done := TRUE
      ELSIF ch = '=' (*'+'*) THEN
        IF heat < 63 THEN INC(heat) END
      ELSIF ch = '-' THEN
        IF heat > 0 THEN DEC(heat) END
      ELSIF ('0' <= ch) & (ch <= '9') THEN
        heat := (ORD(ch) - ORD('0')) * 7
      ELSIF (ch = ' ') THEN
        intro := 0;
        wait := 0
      END
    END
  UNTIL done
END Run;

PROCEDURE Do;
VAR i: INTEGER;
BEGIN
  G.Settings(320, 200, {G.smooth});
  (*G.Settings(640, 400, {G.smooth});*)
  G.Init();
  f := G.LoadFont('../Data/Fonts/Main');
  G.ShowMouse(FALSE);
  G.GetTargetSize(w, h);
  IF h > LEN(m) THEN h := LEN(m) END;
  IF w > LEN(m[0]) THEN w := LEN(m[0]) END;

  (* Initialize palette *)
  FOR i := 0 TO 15 DO
    G.MakeCol(clr[i], i * 8, 0, 0);
    G.MakeCol(clr[i + 16], (i + 16) * 8, 0, 0);
    G.MakeCol(clr[i + 32], 240, i * 16, 0);
    G.MakeCol(clr[i + 48], 240, 240, i * 16)
  END;

  heat := 63;
  intro := introLen;
  wait := intro;
  Run;
  G.Close
END Do;

BEGIN
  Do
END Fire.