MODULE Book;
IMPORT Out, In, G := Graph;
VAR screen: G.Bitmap;
BEGIN
  screen := G.Init();
  G.Line(screen, FLOOR(200.0), 50, 450, 50, G.MakeCol(255, 0, 0));
  G.Line(screen, 150, 350, 400, 350, G.MakeCol(255, 0, 0));
  G.Line(screen, 200, 50, 150, 350, G.MakeCol(255, 0, 0));
  G.Line(screen, 450, 50, 400, 350, G.MakeCol(255, 0, 0));

  G.Line(screen, 150, 420, 400, 420, G.MakeCol(255, 0, 0));
  G.Line(screen, 450, 120, 400, 420, G.MakeCol(255, 0, 0));
  G.Line(screen, 400, 350, 400, 420, G.MakeCol(255, 0, 0));
  G.Line(screen, 450, 50, 450, 120, G.MakeCol(255, 0, 0));
  G.Line(screen, 150, 350, 150, 420, G.MakeCol(255, 0, 0));

  G.Line(screen, 151, 355, 399, 355, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 360, 399, 360, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 365, 399, 365, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 370, 399, 370, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 375, 399, 375, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 380, 399, 380, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 385, 399, 385, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 390, 399, 390, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 395, 399, 395, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 400, 399, 400, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 405, 399, 405, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 410, 399, 410, G.MakeCol(130, 0, 0));
  G.Line(screen, 151, 415, 399, 415, G.MakeCol(130, 0, 0));

  G.Line(screen, 449, 70, 401, 360, G.MakeCol(130, 0, 0));
  G.Line(screen, 449, 80, 401, 370, G.MakeCol(130, 0, 0));
  G.Line(screen, 449, 90, 401, 380, G.MakeCol(130, 0, 0));
  G.Line(screen, 449, 100, 401, 390, G.MakeCol(130, 0, 0));
  G.Line(screen, 449, 110, 401, 400, G.MakeCol(130, 0, 0));

  G.Flip;
  G.Pause;
  G.Close
END Book.
