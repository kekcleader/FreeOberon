MODULE BlitBmp;
IMPORT G := Graph;
VAR s, b: G.Bitmap;
BEGIN
  s := G.Init();
  b := G.LoadBitmap('data/examples/rocket.png');
  G.BlitWhole(b, s, 100, 60);
  G.Flip; G.Pause; G.Close
END BlitBmp.
