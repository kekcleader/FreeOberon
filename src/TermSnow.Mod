MODULE TermSnow;
IMPORT T := TermBox, Out, Random, Kernel;

TYPE
  Star = RECORD
    x, y, n: INTEGER
  END;

VAR W, H: INTEGER;
  stars: ARRAY 50 OF Star;
  starChars: ARRAY 4 OF CHAR;

PROCEDURE OnResize;
BEGIN
  T.Size(W, H)
END OnResize;

PROCEDURE DrawStar(star: Star);
VAR fg: INTEGER;
BEGIN
  IF star.n # 0 THEN
    IF star.n = 1 THEN fg := 11 ELSE fg := 15 END;
    T.SetCell(star.x, star.y, starChars[star.n], fg, 0)
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
  IF FALSE & (Random.Int(10000) < 10) THEN
    IF star.n = 0 THEN
      star.n := 1
    ELSIF star.n > 0 THEN
      IF star.n < 3 THEN INC(star.n) ELSE star.n := 0 END;
      DrawStar(star)
    END
  END
END AnimateStar;

PROCEDURE Animate;
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(stars) - 1 DO AnimateStar(stars[i]) END
END Animate;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  Draw;
  T.Flush;
  REPEAT
    IF T.HasEvents() THEN
      T.WaitEvent(e);
      IF e.type = T.quit THEN done := TRUE
      ELSIF e.type = T.resize THEN OnResize
      END
    ELSE
      Animate;
      T.Flush;
      T.Delay(100)
    END
  UNTIL done
END Run;

PROCEDURE InitStars;
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
  starChars[3] := '*'
END InitStars;

BEGIN
  T.Settings(80, 25, {T.noMouse});
  T.Init;
  T.Size(W, H);
  InitStars;
  Run;
  T.Close
END TermSnow.
