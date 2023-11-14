MODULE Viewer;
IMPORT Files, Out, T := TermBox, Args, Graph;

CONST
  lineLen = 140;

TYPE
  Line = POINTER TO LineDesc;
  LineDesc = RECORD
    s: ARRAY lineLen OF CHAR;
    prev, next: Line
  END;

  Viewer = RECORD
    first, last: Line;
    count: INTEGER; (** Количество строк *)
    curY: INTEGER; (** Сдвиг вниз от первой строки *)
    firstOnScreen: Line; (** Первая строка, видимая сейчас на экране *)
    redraw: BOOLEAN (** Нужно ли перерисовывать *)
  END;

VAR
  X, Y, W, H: INTEGER;
  fg, bg, border, scrollFg, scrollBg: INTEGER;

PROCEDURE ReadFile(VAR v: Viewer; fname: ARRAY OF CHAR);
VAR
  F: Files.File;
  r: Files.Rider;
  ch: CHAR;
  p: Line;
  i: INTEGER;
BEGIN
  F := Files.Old(fname);
  IF F = NIL THEN
    Out.String('Could not read file "');
    Out.String(fname); Out.String('".'); Out.Ln
  ELSE
    Files.Set(r, F, 0);
    NEW(v.first);
    p := v.first;
    i := 0;
    v.count := 1;
    Files.ReadChar(r, ch);
    WHILE ~r.eof DO
      IF ch = 0AX THEN
        p.s[i] := 0X;
        NEW(p.next);
        p.next.prev := p;
        p := p.next;
        i := 0;
        INC(v.count)
      ELSIF ch # 0DX THEN
        IF i < LEN(p.s) - 1 THEN p.s[i] := ch; INC(i) END
      END;
      Files.ReadChar(r, ch)
    END;
    p.s[i] := 0X;
    v.last := p
  END;
  v.firstOnScreen := v.first;
  v.curY := 0
END ReadFile;

PROCEDURE MoveLineUp(VAR v: Viewer);
BEGIN
  IF v.curY > 0 THEN
    DEC(v.curY);
    v.firstOnScreen := v.firstOnScreen.prev
  END
END MoveLineUp;

PROCEDURE MoveLineDown(VAR v: Viewer);
BEGIN
  IF v.curY < v.count - H THEN
    INC(v.curY);
    v.firstOnScreen := v.firstOnScreen.next
  END
END MoveLineDown;

PROCEDURE MoveScreenUp(VAR v: Viewer);
VAR i: INTEGER;
BEGIN
  i := H;
  WHILE i # 0 DO MoveLineUp(v); DEC(i) END
END MoveScreenUp;

PROCEDURE MoveScreenDown(VAR v: Viewer);
VAR i: INTEGER;
BEGIN
  i := H;
  WHILE i # 0 DO MoveLineDown(v); DEC(i) END
END MoveScreenDown;

PROCEDURE MoveToTop(VAR v: Viewer);
BEGIN
  v.firstOnScreen := v.first;
  v.curY := 0
END MoveToTop;

PROCEDURE MoveToBottom(VAR v: Viewer);
VAR y: INTEGER;
  p: Line;
BEGIN
  y := v.count - H;
  IF y <= 0 THEN
    MoveToTop(v)
  ELSE
    v.curY := y;
    p := v.first;
    WHILE y # 0 DO
      p := p.next;
      DEC(y)
    END;
    v.firstOnScreen := p
  END
END MoveToBottom;

PROCEDURE HandleKey(VAR v: Viewer; key: INTEGER; VAR done: BOOLEAN);
BEGIN
  v.redraw := TRUE;
  IF key = T.kEsc THEN done := TRUE
  ELSIF key = T.kUp THEN MoveLineUp(v)
  ELSIF key = T.kDown THEN MoveLineDown(v)
  ELSIF key = T.kPgUp THEN MoveScreenUp(v)
  ELSIF key = T.kPgDn THEN MoveScreenDown(v)
  ELSIF key = T.kHome THEN MoveToTop(v)
  ELSIF key = T.kEnd THEN MoveToBottom(v)
  ELSE v.redraw := FALSE
  END
END HandleKey;

PROCEDURE DrawLine(v: Viewer; p: Line; y: INTEGER);
VAR x: INTEGER;
BEGIN
  x := 0;
  WHILE (p.s[x] # 0X) & (x < W) DO
    T.SetCell(X + x, Y + y, p.s[x], fg, bg);
    INC(x)
  END;
  T.Print(X, Y + H, W,
    'Двигайтесь клавишами со стрелками, а также Home, End, PageUp, PageDown',
    bg, border)
END DrawLine;

PROCEDURE InitialDraw(VAR v: Viewer);
BEGIN
  T.ClearTo(fg, border);
  T.Fill(X, Y, W, H, ' ', fg, bg);
END InitialDraw;

PROCEDURE DrawScrollbar(v: Viewer);
VAR y, h, n: INTEGER;
BEGIN
  h := H * H DIV v.count;
  IF h < 1 THEN h := 1 END;
  IF h < H THEN
    n := v.count - H;
    y := (v.curY * (H - h) + n DIV 2) DIV n;

    T.Fill(X + W - 2, Y, 2, H, ' ', fg, scrollBg);
    T.Fill(X + W - 2, Y + y, 2, h, ' ', fg, scrollFg)
  END
END DrawScrollbar;

PROCEDURE Draw(v: Viewer);
VAR p: Line;
  i: INTEGER;
BEGIN
  T.Fill(X, Y, W, H, ' ', fg, bg);
  p := v.firstOnScreen;
  i := 0;
  WHILE (i < H) & (p # NIL) DO
    DrawLine(v, p, i);
    INC(i);
    p := p.next
  END;
  DrawScrollbar(v);
  T.Flush
END Draw;

PROCEDURE Run(VAR v: Viewer);
VAR e: T.Event;
  done: BOOLEAN;
BEGIN
  InitialDraw(v);
  v.redraw := TRUE;
  REPEAT
    IF v.redraw THEN
      Draw(v);
      v.redraw := FALSE
    END;
    T.WaitEvent(e);
    IF e.type = T.quit THEN done := TRUE
    ELSIF e.type = T.key THEN HandleKey(v, e.key, done)
    END
  UNTIL done;
END Run;

PROCEDURE View(fname: ARRAY OF CHAR);
VAR v: Viewer;
BEGIN
  T.Init; T.HideCursor; T.HideMouse;
  T.Size(W, H); DEC(W, 4); DEC(H, 2); X := 2; Y := 1;
  fg := 3; bg := 1; border := 9; scrollBg := 0; scrollFg := 3;
  ReadFile(v, fname);
  Run(v);
  T.Close
END View;

PROCEDURE Usage;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  Out.String('Viewer. Usage:'); Out.Ln;
  Args.Get(0, s);
  Out.String('  '); Out.String(s);
  Out.String(' fileName'); Out.Ln
END Usage;

PROCEDURE Do;
VAR s: ARRAY 1024 OF CHAR;
BEGIN
  IF Args.Count() = 1 THEN
    Args.Get(1, s);
    View(s)
  ELSE
    Usage;
    View('../README.md') (*This is for easier demonstration, you may delete it*)
  END
END Do;

BEGIN
  Do
END Viewer.