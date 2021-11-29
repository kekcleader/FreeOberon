MODULE TermSnow;
IMPORT T := TermBox, Out, Random, Kernel;

TYPE
  Star = RECORD
    x, y, n: INTEGER
  END;

VAR W, H: INTEGER;
  stars: ARRAY 50 OF Star;
  starChars: ARRAY 5 OF CHAR;

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
  ELSE
    T.SetChar(star.x, star.y, ' ')
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
  ELSIF Random.Int(20) < 10 THEN
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
BEGIN
  FOR i := 0 TO LEN(stars) - 1 DO AnimateStar(stars[i]) END
END Animate;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  Draw;
  T.Flush;
  ;Out.String('RUN');Out.Ln;;;;;;;;
  REPEAT
    ;Out.String('RUN LOOP ITERATION');Out.Ln;;;;;;;;
    IF T.HasEvents() THEN
      ;Out.String('HAS EVENTS');Out.Ln;;;;;;;;
      T.WaitEvent(e);
      IF e.type = T.quit THEN done := TRUE
      ELSIF e.type = T.resize THEN OnResize
      END
    ELSE
      ;Out.String('NO EVENTS');Out.Ln;;;;;;;;
      Animate;
      ;Out.String('PRE FLUSH');Out.Ln;;;;;;;;
      T.Flush;
      ;Out.String('AFTER FLUSH');Out.Ln;;;;;;;;
      (*T.Delay(10)*)
    END
  UNTIL done
  ;Out.String('END RUN');Out.Ln;;;;;;;;
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
  starChars[3] := '*';
  starChars[4] := 0FX
END InitStars;

BEGIN
  T.Settings(0, 0, {T.window, T.center});
  T.Init;
  T.Size(W, H);
  InitStars;
  Run;
  T.Close
END TermSnow.
