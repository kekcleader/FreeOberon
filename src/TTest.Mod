MODULE TTest;
IMPORT T := TermBox;
VAR Y: CHAR;

PROCEDURE Draw;
VAR x: INTEGER;
BEGIN
  T.Init;
  T.Clear(14, 4);
  FOR x := 0 TO 31 DO
    T.SetCell(x + 3, 3, CHR(ORD('А') + x), 15, 4);
    T.SetChar(x + 3, 5, 2566X);
    T.SetChar(x + 3, 6, 2569X)
  END;
  T.SetChar(3, 5, 2564X);
  T.SetChar(3, 6, 255AX);
  T.SetChar(34, 5, 2557X);
  T.SetChar(34, 6, 255DX);
  T.SetCell(15, 1, Y, 0, 4);
  T.Flush
END Draw;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN
  done := FALSE;
  REPEAT
    Draw;
    T.WaitEvent(e);
    IF e.type = T.quit THEN done := TRUE
    ELSIF e.type = T.key THEN
      Y := e.ch;
      IF e.ch = 'q' THEN done := TRUE END
    END
  UNTIL done
END Run;

BEGIN
  T.Init;
  Y := ' ';
  Run;
  T.Close
END TTest.
