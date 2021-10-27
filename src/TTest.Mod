MODULE TTest;
IMPORT T := TermBox, Out, Kernel;
VAR Y: CHAR;

PROCEDURE Draw;
VAR x: INTEGER;
BEGIN
  T.ClearTo(14, 4);
  T.SetCell(0, 0, 'К', 3, 1);
  T.SetCell(1, 23, 'й', 2, 1);
  T.SetCell(0, 24, 'Ю', 3, 1);
  T.SetCell(78, 23, 'щ', 0, 7);
  T.SetCell(79, 24, 'ц', 3, 1);
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
    T.WaitEvent(e);
    IF e.type = T.quit THEN done := TRUE
    ELSIF e.type = T.key THEN
      Y := e.ch;
      Out.Int(e.key, 5); Out.Char(' '); Out.Char(e.ch); Out.Int(ORD(e.ch), 5);Out.Ln;
      IF e.ch = 'q' THEN done := TRUE END
    END
  UNTIL done
END Run;

BEGIN
  T.Settings(80, 25, {T.center, T.window, T.resizable});
  T.SetZoom(2);
  T.SetTitle('Oberon TermBox Module');
  T.Init;
  Y := ' ';
  Run;
  T.Close
END TTest.
