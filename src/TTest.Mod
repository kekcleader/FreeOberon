MODULE TTest;
IMPORT T := TermBox, Out, Kernel;
VAR ch: CHAR;
  X, Y: INTEGER;
  W, H: INTEGER;

PROCEDURE DrawOnce;
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
  T.SetChar(34, 6, 255DX)
END DrawOnce;

PROCEDURE Draw;
BEGIN
  T.SetCell(X, Y, ch, 0, 4);
  T.Flush
END Draw;

PROCEDURE OnResize;
VAR x, y, w, h: INTEGER;
BEGIN
  T.Size(w, h);
  FOR y := 0 TO h - 1 DO
    FOR x := W TO w - 1 DO
      T.SetCell(x, y, CHR(ORD(ch) + 1), 0, (x + y) MOD 16)
    END
  END;
  FOR y := H TO h - 1 DO
    FOR x := 0 TO w - 1 DO
      T.SetCell(x, y, CHR(ORD(ch) + 1), 0, (x * y) MOD 16)
    END
  END;
  W := w; H := h;
  T.Flush
END OnResize;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  DrawOnce;
  REPEAT
    Draw;
    T.WaitEvent(e);
    IF e.type = T.quit THEN done := TRUE
    ELSIF e.type = T.resize THEN OnResize
    ELSIF e.type = T.key THEN
      Out.Int(e.key, 5); (*Out.Char(' '); Out.Char(e.ch); *)Out.Int(ORD(e.ch), 5);Out.Ln;
      IF e.key = 82 THEN DEC(X)
      ELSIF e.key = 83 THEN INC(X)
      ELSIF e.key = 84 THEN DEC(Y)
      ELSIF e.key = 85 THEN INC(Y)
      ELSE ch := e.ch
      END;
      IF X < 0 THEN X := 0 ELSIF X >= W THEN X := W - 1 END;
      IF Y < 0 THEN Y := 0 ELSIF Y >= H THEN Y := H - 1 END;
      IF e.ch = 'q' THEN done := TRUE END
    END
  UNTIL done
END Run;

BEGIN
  T.Settings(80, 25, {(*T.center, T.window, T.resizable*)});
  T.SetZoom(2);
  T.SetTitle('Oberon TermBox Module');
  T.Init;
  T.Size(W, H);
  ch := ' ';
  Run;
  T.Close
END TTest.
