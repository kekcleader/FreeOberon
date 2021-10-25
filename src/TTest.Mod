MODULE TTest;
IMPORT T := TermBox, Out, Kernel;
VAR Y: CHAR;

PROCEDURE Draw;
VAR x: INTEGER;
BEGIN
  T.ClearTo(14, 4);
  FOR x := 0 TO 31 DO
    T.SetCell(x + 3, 3, CHR(ORD('А') + x), 15, 4);
    T.SetChar(x + 3, 5, 2566X);
    T.SetChar(x + 3, 6, 2569X)
  END;
  T.SetChar(3, 5, 2554X);
  T.SetChar(3, 6, 255AX);
  T.SetChar(34, 5, 2557X);
  T.SetChar(34, 6, 255DX);
  T.SetCell(15, 1, Y, 0, 4);
  T.Flush
END Draw;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  REPEAT
    Draw;
    Out.String('DRAW DONE'); Out.Ln;
    T.WaitEvent(e);
    IF e.type = T.quit THEN done := TRUE
    ELSIF e.type = T.key THEN
      Y := e.ch;
      Out.Int(e.key, 5); Out.Char(' '); Out.Char(e.ch); Out.Int(ORD(e.ch), 5);Out.Ln;
      IF e.ch = 'q' THEN done := TRUE
      ELSIF e.ch = 'z' THEN T.Z END
    END
  UNTIL done
END Run;

BEGIN
  T.Init;
  Y := ' ';
  Run;
  T.Close
END TTest.
