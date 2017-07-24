MODULE BlitBmp;
IMPORT G := Graph;
VAR s, b: G.Bitmap;
BEGIN
  s := G.Init();
  IF s = NIL THEN HALT(3) END;
  b := G.LoadBitmap('data/examples/rocket.png');
  IF b = NIL THEN HALT(4) END;
  G.BlitWhole(b, s, 100, 60);
  G.Flip; G.Pause; G.Close
END BlitBmp.
