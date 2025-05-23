MODULE Rocket2;
IMPORT Out, Random, G := Graph, M := Math;
CONST N = 100;
VAR b: G.Bitmap;
  x, y, vx, vy: ARRAY N OF REAL;
  w, h, pw, ph, i: INTEGER;
  t: REAL;
  c: G.Color;
BEGIN
  (* Try theese settings:    (the default is (640, 400, {})) *)
  (* G.Settings(0, 0, {}); *)
  (* G.Settings(0, 0, {G.window}); *)
  (* G.Settings(320, 200, {}); *)
  (* G.Settings(320, 200, {G.smooth}); *)
  (* G.Settings(320, 200, {G.exact}); *)
  (* G.Settings(320, 200, {G.smooth, G.exact}); *)
  (* G.Settings(800, 600, {G.exact}); *)
  (* G.Settings(420, 900, {G.smooth, G.exact}); *)
  G.Init();
  G.ShowMouse(FALSE);
  G.GetTargetSize(w, h);
  b := G.LoadBitmap('Data/rocket.png');
  IF b = NIL THEN
    Out.String('Could not load rocket.png'); Out.Ln; ASSERT(FALSE)
  END;
  FOR i := 0 TO N - 1 DO
    x[i] := FLT(w) * Random.Uniform();
    y[i] := FLT(h) * Random.Uniform();
    vx[i] := 0.0; vy[i] := -Random.Uniform() * 5.0 - 0.3
  END;
  t := 0.0;
  REPEAT
    G.MakeCol(c, 10, 30, 60 + FLOOR(60.0 * M.cos(t / 40.0)));
    G.ClearToColor(c);
    pw := FLOOR(h * b.w / b.h * (0.65 + 0.05 * M.sin(t)));
    ph := FLOOR(FLT(h) * (0.65 + 0.05 * M.cos(t)));
    G.DrawEx(b, 0, 0, b.w, b.h,
      (w - pw) DIV 2,
      (h - ph) DIV 2 - FLOOR(FLT(h) * 0.2 * M.sin(t / 40.0)),
      pw, ph, {});
    FOR i := 0 TO N - 1 DO
      G.Draw(b, FLOOR(x[i]), FLOOR(y[i]));
      x[i] := x[i] + vx[i]; y[i] := y[i] + vy[i];
      IF x[i] < -FLT(b.w) THEN x[i] := x[i] + FLT(w + b.w)
      ELSIF x[i] > FLT(w) THEN x[i] := x[i] - FLT(w - b.w)
      END;
      IF y[i] < -FLT(b.h) THEN y[i] := y[i] + FLT(h + b.h)
      ELSIF y[i] > FLT(h) THEN y[i] := y[i] - FLT(h - b.h)
      END;
      vx[i] := vx[i] + (Random.Uniform() * 2.0 - 1.0) / 50.0;
      vy[i] := vy[i] + (Random.Uniform() * 2.0 - 1.0) / 50.0
    END;
    G.Flip;
    G.Delay(20);
    t := t + 0.15
  UNTIL G.KeyPressed();
  G.Close
END Rocket2.