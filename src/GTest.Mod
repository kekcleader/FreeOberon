(* Graph2 Test Module *)
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
  font: G.Font;

PROCEDURE OpenDialog;
VAR opt: SET;
BEGIN
  IF nofdialogs # LEN(dialogs) THEN
    opt := {G.smooth, G.resizable};
    IF ODD(nofdialogs) THEN INCL(opt, G.exact) END;
    dialogs[nofdialogs] := G.NewWindow(40, nofdialogs * 70,
      300, 100 + 50 * nofdialogs, 'Dialog', opt);
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

  IF mX # -1 THEN G.Draw(B, mX - B.w, mY - B.h) END;

  G.DrawString('Привет, Оберон!', 17, 17, font, c1);
  G.DrawString('Привет, Оберон!', 16, 16, font, c2);
  G.DrawString('Lai dzīvo Oberona nedēļa!', 17, 33, font, c1);
  G.DrawString('Lai dzīvo Oberona nedēļa!', 16, 32, font, c2);

  G.Flip
END DrawWin;

PROCEDURE Draw;
VAR i: INTEGER;
BEGIN
  DrawWin(main);
  i := 0;
  WHILE (i # nofdialogs) & ~quit DO (*!FIXME ~quit??*)
    DrawWin(dialogs[i]);
    INC(i)
  END
END Draw;

PROCEDURE Run;
VAR e: G.Event;
  r, g, b, W, H: INTEGER;
  z: REAL;
BEGIN
  quit := FALSE;
  redraw := TRUE;
  G.StartTimer(t);
  REPEAT
    IF redraw & ~G.HasEvents() THEN
      Draw;
      redraw := FALSE
    END;

    G.WaitEvent(e);
    IF e.type = G.mouseMove THEN
      IF (e.dx # 0) OR (e.dy # 0) THEN
        mX := e.x; mY := e.y
      END;
      G.MakeCol(c2, mX * 256 DIV e.window.w, mY * 256 DIV e.window.h, 0);
      redraw := TRUE
    ELSIF e.type = G.mouseWheel THEN
      IF e.dz # 0 THEN
        Out.String('e.dz = '); Out.Int(e.dz, 0); Out.Ln;
        G.ColorToRGB(c1, r, g, b);
        g := (g + e.dz * 8) MOD 256;
        G.MakeCol(c1, r, g, b);
        z := (FLT(FLOOR(G.GetWindowZoom(e.window) * 10 + 0.5)) + e.dz) / 10;
        IF z < 0.3 THEN z := 0.3 END;
        Out.String('zoom = '); Out.RealFix(z, 0, 2); Out.Ln;
        G.SetWindowZoomF(e.window, z)
      END;
      redraw := TRUE
    ELSIF e.type = G.mouseDown THEN
      IF e.button = 1 THEN
        OpenDialog;
        redraw := TRUE
      END
    ELSIF e.type = G.timer THEN
      INC(Z);
      redraw := TRUE
    ELSIF e.type = G.keyDown THEN
      IF e.window = main THEN INC(Z) ELSE DEC(Z) END;
      redraw := TRUE
    ELSIF e.type = G.char THEN
      IF e.window = main THEN Out.String('Main window ') END;
      Out.String('char typed: '); Out.Char(e.ch); Out.Ln;
      Out.String('         Code '); Out.Int(ORD(e.ch), 0); Out.Ln;
      redraw := TRUE
    ELSIF e.type = G.resize THEN
      Out.String('Resize '); Out.Int(e.window.w, 0);Out.Char('x');Out.Int(e.window.h, 0);Out.Ln;
      redraw := TRUE
    ELSIF e.type = G.quit THEN
      IF e.window = main THEN quit := TRUE
      ELSE CloseDialog(e.window)
      END
    END
  UNTIL quit
END Run;

PROCEDURE RunSingle;
VAR i, n, W, H: INTEGER;
  c3, c4, c5: G.Color;
BEGIN
  G.Settings(640, 400, {G.smooth, G.window, G.resizable, G.nobuffer});
  G.Settings(320, 200, {G.window, G.resizable});
  (*G.SetZoomF(2.0);*)
  (*G.SetScale(5/6, 1.0);*)
  G.Init;
  G.GetScreenSize(W, H);
  G.MakeCol(c1, 0, 80, 210);
  G.MakeCol(c2, 0, 255, 0);
  G.MakeCol(c3, 255, 255, 255);
  G.MakeCol(c4, 50, 30, 255);
  B := G.LoadBitmap('../Data/Images/Icon.png');
  IF B = NIL THEN Out.String('COULD NOT LOAD ../Data/Images/Icon.png'); Out.Ln END;
  font := G.LoadFont('../Data/Fonts/Main');
  IF font = NIL THEN Out.String('COULD NOT LOAD ../Data/Fonts/Main'); Out.Ln END;

  main := G.GetScreen();
  t := G.NewTimer(0.5);
  mX := -1; mY := -1;
  Run;

  G.Close
END RunSingle;

PROCEDURE RunSimple;
VAR c, cc: G.Color;
  e: G.Event;
  done: BOOLEAN;
  X, Y, x, y: INTEGER;
  F: G.Font;
BEGIN
  G.Settings(0, 0, {});
  G.Init;
  F := G.LoadFont('Data/Fonts/Main');
  G.MakeCol(c, 40, 150, 200);
  G.MakeCol(cc, 230, 210, 150);
  done := FALSE; X := 20; Y := 20;
  REPEAT
    WHILE G.HasEvents() DO
      G.WaitEvent(e);
      IF e.type = G.quit THEN done := TRUE
      ELSIF e.type = G.mouseMove THEN
        X := e.x; Y := e.y;      
      END
    END;
    G.ClearToColor(c);
    G.Line(20, 20, 620, 380, cc);
    G.Line(20, 20, 20, 380, cc);
    G.Line(20, 380, 620, 380, cc);
    G.Line(20, 380, X, Y, cc);
    FOR y := 0 TO 400 BY 16 DO
      FOR x := 20 TO 800 BY 12*8 DO
        G.DrawString('Hello World!', X + x, Y + y, F, cc)
      END
    END;
    G.Flip
  UNTIL done;
  G.Close
END RunSimple;

BEGIN
  (*RunSimple;*)
  (*RunSingle;*)

  nofdialogs := 0;
  Z := 0;

  G.Settings(-1, -1, {G.manual});
  G.Init;
  main := G.NewWindow(-1, -1, 800, 600, 'Oberon Allegro 5 Test',
    {G.resizable, G.maximized});

  B := G.LoadBitmap('../Data/Images/Icon.png');
  IF B = NIL THEN Out.String('COULD NOT LOAD ../Data/Images/Icon.png'); Out.Ln END;
  font := G.LoadFont('../Data/Fonts/Main');
  IF font = NIL THEN Out.String('COULD NOT LOAD ../Data/Fonts/Main'); Out.Ln END;

  t := G.NewTimer(1.0);
  G.MakeCol(c1, 180, 80, 20);
  G.MakeCol(c2, 240, 180, 80);

  Run;
  G.Close
END GTest.
