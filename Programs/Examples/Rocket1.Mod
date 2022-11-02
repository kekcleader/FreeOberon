MODULE Rocket1;
IMPORT G := Graph, Out;
VAR b: G.Bitmap;
BEGIN
  G.Init();
  b := G.LoadBitmap('Data/rocket.png');
  IF b = NIL THEN Out.String('Could not load rocket.png'); Out.Ln
  ELSE
    G.Draw(b, 100, 60);
    G.Flip; G.Pause; G.Close
  END
END Rocket1.
