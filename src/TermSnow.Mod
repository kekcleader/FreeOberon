MODULE TermSnow;
IMPORT T := TermBox, Out, Random, Kernel;

TYPE
  Star = RECORD
    x, y, n: INTEGER
  END;

VAR W, H: INTEGER;
  stars: ARRAY 50 OF Star;
  starChars: ARRAY 5 OF CHAR;

  mouse: RECORD
    x1, y1, x2, y2: INTEGER;
    down: BOOLEAN
  END;

PROCEDURE OnResize;
BEGIN
  T.Size(W, H)
END OnResize;

PROCEDURE DrawStar(star: Star);
VAR fg: INTEGER;
  cell: T.Cell;
BEGIN
  T.GetCell(star.x, star.y, cell);
  IF cell.bg = 0 THEN (* Do not draw on non-black background *)
    IF star.n # 0 THEN
      IF star.n = 1 THEN fg := 3 ELSE fg := 15 END;
      T.SetCell(star.x, star.y, starChars[star.n], fg, 0)
    ELSE
      T.SetChar(star.x, star.y, ' ')
    END
  END
END DrawStar;

PROCEDURE Draw;
VAR i, fg: INTEGER;
BEGIN
  T.ClearTo(11, 0);
  FOR i := 0 TO LEN(stars) - 1 DO DrawStar(stars[i]) END
END Draw;

PROCEDURE AnimateStar(VAR star: Star);
BEGIN
  IF star.n > 1 THEN
    IF star.n < LEN(starChars) - 1 THEN INC(star.n) ELSE star.n := 0 END;
    DrawStar(star)
  ELSIF Random.Int(1000) < 15 THEN
    INC(star.n);
    IF star.n = 1 THEN
      star.x := Random.Int(W);
      star.y := Random.Int(H)
    END;
    DrawStar(star)
  END
END AnimateStar;

PROCEDURE Animate;
VAR i: INTEGER;
BEGIN FOR i := 0 TO LEN(stars) - 1 DO AnimateStar(stars[i]) END
END Animate;

PROCEDURE Line(color: INTEGER);
VAR x1, y1, x2, y2, x, y: INTEGER;
  D, D2: INTEGER; (* D = Divisor, D2 = half of divisor *)

  PROCEDURE Swap(VAR x1, y1, x2, y2: INTEGER);
  VAR t: INTEGER;
  BEGIN
    t := x1; x1 := x2; x2 := t;
    t := y1; y1 := y2; y2 := t
  END Swap;

BEGIN
  x1 := mouse.x1; y1 := mouse.y1; x2 := mouse.x2; y2 := mouse.y2;
  IF ABS(x1 - x2) <= ABS(y1 - y2) THEN
    IF y1 > y2 THEN Swap(x1, y1, x2, y2) END;
    D := y2 - y1; D2 := D DIV 2;
    FOR y := y1 TO y2 DO
      IF y1 = y2 THEN x := x1
      ELSE x := ((y - y1) * (x2 - x1) + D2) DIV D + x1
      END;
      T.SetCell(x, y, ' ', 7, color)
    END
  ELSE
    IF x1 > x2 THEN Swap(x1, y1, x2, y2) END;
    D := x2 - x1; D2 := D DIV 2;
    FOR x := x1 TO x2 DO
      IF x1 = x2 THEN y := y1
      ELSE y := ((x - x1) * (y2 - y1) + D2) DIV D + y1
      END;
      T.SetCell(x, y, ' ', 7, color)
    END
  END
END Line;

PROCEDURE OnMouseDown(x, y: INTEGER);
BEGIN
  IF mouse.down THEN
    Line(0)
  ELSE
    mouse.down := TRUE;
    mouse.x1 := x; mouse.y1 := y
  END;
  mouse.x2 := x; mouse.y2 := y;
  Line(10)
END OnMouseDown;

PROCEDURE OnMouseUp(x, y: INTEGER);
BEGIN
  IF mouse.down THEN
    Line(0);
    mouse.x2 := x; mouse.y2 := y;
    Line(4);
    mouse.down := FALSE
  END
END OnMouseUp;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  Draw;
  T.Flush;
  T.StartTimer(1/5);
  REPEAT
    T.WaitEvent(e);
    IF e.type = T.timer THEN
      Animate;
      T.Flush
    ELSIF e.type = T.resize THEN OnResize
    ELSIF e.type = T.quit THEN done := TRUE
    ELSIF e.type = T.mouse THEN
      IF e.button # 0 THEN OnMouseDown(e.x, e.y)
      ELSE OnMouseUp(e.x, e.y)
      END
    END
  UNTIL done
END Run;

PROCEDURE InitVars;
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(stars) - 1 DO
    stars[i].x := Random.Int(W);
    stars[i].y := Random.Int(H);
    stars[i].n := Random.Int(2)
  END;

  starChars[0] := 0B7X;
  starChars[1] := 80X;
  starChars[2] := 7X;
  starChars[3] := '*';
  starChars[4] := 0FX;

  mouse.down := FALSE
END InitVars;

BEGIN
  T.Settings(0, 0, {(*T.window, *)T.center, T.resizable});
  T.Init;
  T.Size(W, H);
  InitVars;
  Run;
  T.Close
END TermSnow.
