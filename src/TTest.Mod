MODULE TTest;
IMPORT T := TermBox, Out, Kernel;
VAR ch: CHAR;
  W, H: INTEGER;
  needRedraw: BOOLEAN;

PROCEDURE DoubleBox(x1, y1, x2, y2, fg, bg: INTEGER);
VAR i: INTEGER;
BEGIN
  IF x1 > x2 THEN i := x1; x1 := x2; x2 := i END;
  IF y1 > y2 THEN i := y1; y1 := y2; y2 := i END;
  FOR i := x1 + 1 TO x2 - 1 DO
    T.SetCell(i, y1, 2550X, fg, bg);
    T.SetCell(i, y2, 2550X, fg, bg)
  END;
  FOR i := y1 + 1 TO y2 - 1 DO
    T.SetCell(x1, i, 2551X, fg, bg);
    T.SetCell(x2, i, 2551X, fg, bg)
  END
END DoubleBox;

PROCEDURE Draw;
BEGIN
  T.ClearTo(15, 1);
  DoubleBox(0, 1, W - 1, H - 2, 15, 1);
  T.Flush
END Draw;

PROCEDURE OnResize;
BEGIN
  T.Size(W, H);
  raw;
  needRedraw := TRUE
END OnResize;

PROCEDURE Paste;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  T.TESTCB(s);
  T.Print(5, 5, s, 3, 1);
  needRedraw := TRUE
END Paste;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE; needRedraw := TRUE;
  Draw;
  REPEAT
    IF needRedraw THEN T.Flush; needRedraw := FALSE END;
    T.WaitEvent(e);
    IF e.type = T.quit THEN done := TRUE
    ELSIF e.type = T.resize THEN OnResize
    ELSIF e.type = T.key THEN
      IF e.ch = 'p' THEN Paste
      ELSIF e.ch = 'q' THEN done := TRUE
      ELSE ch := e.ch
      END;
      needRedraw := TRUE
    ELSIF e.type = T.mouse THEN
      T.SetChar(e.x, e.y, ch);
      needRedraw := TRUE
    END
  UNTIL done
END Run;

BEGIN
  T.Settings(80, 25, {T.center, T.window, T.resizable});
  T.SetTitle('Oberon TermBox Test');
  T.Init;
  T.Size(W, H);
  ch := ' ';
  Run;
  T.Close
END TTest.
