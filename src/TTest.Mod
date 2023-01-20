(** TermBox Test Module *)
MODULE TTest;
IMPORT T := TermBox, Out, Kernel;
VAR ch: CHAR;
  W, H: INTEGER;
  X, Y: INTEGER; (* Text Cursor *)

PROCEDURE DoubleBox(x1, y1, x2, y2, fg, bg: INTEGER);
VAR i: INTEGER;
BEGIN
  IF x1 > x2 THEN i := x1; x1 := x2; x2 := i END;
  IF y1 > y2 THEN i := y1; y1 := y2; y2 := i END;
  T.SetCell(x1, y1, 2554X, fg, bg);
  T.SetCell(x2, y1, 2557X, fg, bg);
  T.SetCell(x1, y2, 255AX, fg, bg);
  T.SetCell(x2, y2, 255DX, fg, bg);
  FOR i := x1 + 1 TO x2 - 1 DO
    T.SetCell(i, y1, 2550X, fg, bg);
    T.SetCell(i, y2, 2550X, fg, bg)
  END;
  FOR i := y1 + 1 TO y2 - 1 DO
    T.SetCell(x1, i, 2551X, fg, bg);
    T.SetCell(x2, i, 2551X, fg, bg)
  END
END DoubleBox;

PROCEDURE Rect(x1, y1, x2, y2, fg, bg: INTEGER);
VAR x, y: INTEGER;
BEGIN
  IF x1 > x2 THEN x := x1; x1 := x2; x2 := x END;
  IF y1 > y2 THEN y := y1; y1 := y2; y2 := y END;
  FOR y := y1 TO y2 DO
    FOR x := x1 TO x2 DO
      T.SetCell(x, y, ' ', fg, bg)
    END
  END
END Rect;

PROCEDURE Draw;
VAR i: INTEGER;
BEGIN
  T.ClearTo(15, 1);
  Rect(0, 0, W - 1, 0, 0, 7);
  Rect(0, H - 1, W - 1, H - 1, 0, 7);
  DoubleBox(0, 1, W - 1, H - 2, 15, 1);
  FOR i := 0 TO 15 DO
    T.SetCell(4 + i, 5, 17X, i + 3, i)
  END;
  T.Flush
END Draw;

PROCEDURE OnResize;
BEGIN
  T.Size(W, H);
  Draw
END OnResize;

PROCEDURE Paste;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  T.TESTCB(s);
  T.Print(5, 5, s, 3, 1)
END Paste;

PROCEDURE Menu;
CONST S = 'Файл Правка Поиск Запуск Компиляция Отладка Сервис Окно Справка';
VAR i, a, b: INTEGER;
  s: ARRAY 200 OF CHAR;
BEGIN s := S; i := 0; a := ORD(ch) MOD 16;
  WHILE s[i] # 0X DO
    IF ('А' <= s[i]) & (s[i] <= 'Я') OR (s[i] = 'Ё') THEN b := a + 4
    ELSE b := a
    END;
    T.SetCell(i + 1, 0, s[i], b, 7);
    INC(i)
  END
END Menu;

PROCEDURE GoToXY(x, y: INTEGER);
BEGIN X := x; Y := y; T.SetCursor(x, y)
END GoToXY;

PROCEDURE Move(dx, dy: INTEGER);
BEGIN INC(dx, X); INC(dy, Y);
  IF (0 <= dx) & (dx < W) & (0 <= dy) & (dy < H) THEN GoToXY(dx, dy) END
END Move;

PROCEDURE Type(ch: CHAR);
BEGIN
  IF ch = 8X (* Backspace *) THEN
    IF X = 0 THEN Move(0, -1); GoToXY(W - 1, Y) ELSE Move(-1, 0) END;
    T.SetChar(X, Y, ' ')
  ELSIF ch = 0DX (* Enter *) THEN
    Move(0, 1); GoToXY(0, Y)
  ELSE
    T.SetChar(X, Y, ch);
    IF X = W - 1 THEN Move(0, 1); GoToXY(0, Y) ELSE Move(1, 0) END
  END
END Type;

(*PROCEDURE SSET(x: SET);
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO 31 DO
    IF i IN x THEN Out.Int(i, 3) END
  END;
  Out.Ln
END SSET;*)

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  Draw;
  REPEAT
    T.Flush;
    T.WaitEvent(e);
    IF e.type = T.quit THEN done := TRUE
    ELSIF e.type = T.resize THEN OnResize
    ELSIF e.type = T.key THEN
      IF e.mod * T.mCtrl # {} THEN
        IF e.key = T.kP THEN Paste
        ELSIF e.key = T.kQ THEN done := TRUE
        END
      ELSIF e.ch # 0X THEN
        ch := e.ch; Type(ch)
      ELSIF e.key = T.kUp THEN Move(0, -1)
      ELSIF e.key = T.kDown THEN Move(0, 1)
      ELSIF e.key = T.kLeft THEN Move(-1, 0)
      ELSIF e.key = T.kRight THEN Move(1, 0)
      END;
      Menu
    ELSIF e.type = T.mouse THEN
      T.SetChar(e.x, e.y, ch);
      GoToXY(e.x, e.y)
    END
  UNTIL done
END Run;

BEGIN
  T.Settings(80, 25, {T.center, (*T.window,*) T.resizable(*, T.noMouse*)});
  T.SetTitle('Oberon TermBox Test');
  T.Init;
  GoToXY(1, 2);
  T.Size(W, H);
  ch := '+';
  Run;
  T.Close
END TTest.
