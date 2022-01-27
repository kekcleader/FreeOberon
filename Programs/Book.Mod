MODULE Book;
IMPORT Out, In, G := Graph2;
VAR c: G.Color;
BEGIN
  G.Init();
  G.MakeCol(c, 255, 0, 0);
  (*G.Circle(50, 50, 45, G.MakeCol(0, 255, 0));*)

  G.Line(FLOOR(200.0), 50, 450, 50, c);
  G.Line(150, 350, 400, 350, c);
  G.Line(200,  50, 150, 350, c);
  G.Line(450,  50, 400, 350, c);

  G.Line(150, 420, 400, 420, c);
  G.Line(450, 120, 400, 420, c);
  G.Line(400, 350, 400, 420, c);
  G.Line(450,  50, 450, 120, c);
  G.Line(150, 350, 150, 420, c);

  G.Line(151, 355, 399, 355, c);
  G.Line(151, 360, 399, 360, c);
  G.Line(151, 365, 399, 365, c);
  G.Line(151, 370, 399, 370, c);
  G.Line(151, 375, 399, 375, c);
  G.Line(151, 380, 399, 380, c);
  G.Line(151, 385, 399, 385, c);
  G.Line(151, 390, 399, 390, c);
  G.Line(151, 395, 399, 395, c);
  G.Line(151, 400, 399, 400, c);
  G.Line(151, 405, 399, 405, c);
  G.Line(151, 410, 399, 410, c);
  G.Line(151, 415, 399, 415, c);

  G.Line(449,  70, 401, 360, c);
  G.Line(449,  80, 401, 370, c);
  G.Line(449,  90, 401, 380, c);
  G.Line(449, 100, 401, 390, c);
  G.Line(449, 110, 401, 400, c);

  G.Flip;
  G.Pause;
  G.Close
END Book.
