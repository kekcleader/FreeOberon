MODULE GTest;
IMPORT G := Graph2, Random, Out;
VAR main: G.Window;
  dialogs: ARRAY 10 OF G.Window;
  nofdialogs: INTEGER;
  quit: BOOLEAN;
  redraw: BOOLEAN;
  Z: INTEGER;
  t: G.Timer;
  c1, c2: G.Color;
  mX, mY: INTEGER;
  B: G.Bitmap;

PROCEDURE OpenDialog;
BEGIN
  IF nofdialogs # LEN(dialogs) THEN
    dialogs[nofdialogs] := G.NewWindow(-1, -1,
      300, 100 + 50 * nofdialogs, 'Dialog', {G.center});
    INC(nofdialogs)
  END
END OpenDialog;

PROCEDURE CloseDialog(W: G.Window);
VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE (i # nofdialogs) & (dialogs[i] # W) DO INC(i) END;
  IF i # nofdialogs THEN
    G.CloseWindow(dialogs[i]);
    dialogs[i] := dialogs[nofdialogs - 1];
    DEC(nofdialogs)
  END
END CloseDialog;

PROCEDURE DrawWin(W: G.Window);
VAR i, x, y, w, h: INTEGER;
BEGIN
  G.Target(W);
  G.ClearToColor(c1);

  FOR i := 0 TO 8 DO
    x := i MOD 3; y := i DIV 3;
    w := (W.w - 1) * (x + 1) DIV 3 - 1;
    h := (W.h - 1) * (y + 1) DIV 3 - 1;
    x := (W.w - 1) * x DIV 3 + 1;
    y := (W.h - 1) * y DIV 3 + 1;
    IF Z MOD 9 = i THEN
      G.FillRect(x, y, w, h, c2)
    ELSE
      G.Rect(x, y, w, h, c2);
      G.Line(x, y, w, h, c2);
      G.Line(x, h, w, y, c2)
    END
  END;

  IF mX # -1 THEN G.Draw(B, mX, mY) END;

  G.Flip
END DrawWin;

PROCEDURE Draw;
VAR i: INTEGER;
BEGIN
  DrawWin(main);
  i := 0;
  WHILE (i # nofdialogs) & ~quit DO
    DrawWin(dialogs[i]);
    INC(i)
  END
END Draw;

PROCEDURE Run;
VAR e: G.Event;
BEGIN
  quit := FALSE;
  redraw := TRUE;
  G.StartTimer(t);
  REPEAT
    IF redraw & G.NoEvents() THEN
      Draw;
      redraw := FALSE
    END;

    G.WaitEvent(e);
    IF e.type = G.mouseMove THEN
      IF e.window = main THEN
        mX := e.x; mY := e.y
      END;
      G.MakeCol(80 + Random.Int(2) * 40, 80, 30, c1);
      G.MakeCol(0, Random.Int(3) * 70, 0, c2);
      redraw := TRUE
    ELSIF e.type = G.mouseDown THEN
      Out.String('Mouse DOWN '); Out.Int(e.x, 0); Out.Char(':'); Out.Int(e.y, 0); Out.Ln;
      OpenDialog;
      redraw := TRUE
    ELSIF e.type = G.timer THEN
      INC(Z);
      redraw := TRUE
    ELSIF e.type = G.keyDown THEN
      Out.String('Key Down');Out.Ln;
      IF e.window = main THEN
        INC(Z)
      ELSE
        DEC(Z)
      END;
      redraw := TRUE
    ELSIF e.type = G.char THEN
      IF e.window = main THEN Out.String('Main window ') END;
      Out.String('char typed: '); Out.Char(e.ch); Out.Ln;
      Out.String('         Code '); Out.Int(ORD(e.ch), 0); Out.Ln;
      redraw := TRUE
    ELSIF e.type = G.resize THEN
      Out.String('Resize');Out.Ln;
      G.ApplyResize(e.window);
      redraw := TRUE
    ELSIF e.type = G.quit THEN
      Out.String('Quit');Out.Ln;
      IF e.window = main THEN
        quit := TRUE
      ELSE
        CloseDialog(e.window)
      END
    END
  UNTIL quit
END Run;

PROCEDURE RunSingle;
VAR i, n: INTEGER;
  c3, c4, c5: G.Color;
BEGIN
                                                                                                      
  G.Settings(320, 200, {(*G.exact, G.smooth*)});
  (*G.SetScale(5/6, 1.0);*)
  G.Init;
  G.MakeCol(210, 80, 30, c1);
  G.MakeCol(0, 255, 0, c2);
  G.MakeCol(255, 255, 255, c3);
  G.MakeCol(50, 30, 255, c4);
  B := G.LoadBitmap('img.png');
  IF B = NIL THEN Out.String('COULD NOT LOAD img.png'); Out.Ln END;
  G.ClearScreen;
    (*DELETEME*)          G.Flip; G.Delay(20);

  i := 0;
  REPEAT
    n := i * 255 DIV G.Height();
    G.MakeCol(n, n DIV 3, 255 - n, c5);
    G.Line(0, i, G.Width() - 1, i, c5);
    G.Flip; G.Delay(1);
    INC(i)
  UNTIL i = G.Height();

  i := 0;
  REPEAT
    G.DrawRotated(B, B.w DIV 2, B.h DIV 2, 15 + i * 25, 80,
      FLT(i) * 15 / 180.0 * 3.14, {});
    G.DrawRotated(B, B.w DIV 2, B.h DIV 2, G.Width() - 15 - i * 25, 130,
      FLT(i) * 15 / 180.0 * 3.14, {G.flipHor});
      (*DELETEME*)          G.Flip; G.Delay(50);
    INC(i)
  UNTIL i = 14;
  G.Line(0, 0, 0, 10, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.Line(2, 0, 2, 10, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.Line(10, 0, 40, 30, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.Line(10, 10, 40, 70, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.PutPixel(4, 4, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.PutPixel(6, 4, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.PutPixel(6, 4, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.PutPixel2(4, 14, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.PutPixel2(6, 14, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.PutPixel2(6, 14, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.PutPixel2(6, 13, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.PutPixel2(7, 13, c2);
    (*DELETEME*)          G.Flip; G.Delay(20);
  G.Target(B);

  G.Line(0, 0, 15, 0, c2);
  G.Line(0, 22, 15, 22, c2);
  G.Line(0, 0, 0, 22, c2);
  G.Line(15, 0, 15, 22, c2);

  G.Line(0, 0, 15, 5, c4);
  G.Line(15, 0, 12, 22, c3);

  G.TargetScreen;
  G.Draw(B, 130, 100);
  main := G.GetScreen();
  t := G.NewTimer(1.0);
  mX := -1; mY := -1;

  Run;

  G.Close
END RunSingle;

BEGIN
  RunSingle;
(*
  nofdialogs := 0;
  Z := 0;

  G.Settings(-1, -1, {G.manual});
  G.Init;
  main := G.NewWindow(-1, -1, 800, 600, 'Oberon Allegro 5 Test',
    {G.resizable, G.maximized});
  t := G.NewTimer(1.0);
  G.MakeCol(180, 80, 20, c1);
  G.MakeCol(240, 180, 80, c2);

  Run;
  G.Close*)
END GTest.
