MODULE TestSound;
IMPORT G := Graph, Sound, Out;
VAR c: G.Color;
BEGIN
  G.Settings(320, 200, {G.window, G.center});
  G.Init;
  Sound.Init;
  IF ~Sound.Done THEN Out.String('SOUND INIT FAILED.'); Out.Ln END;
  G.MakeCol(c, 240, 10, 0);
  G.ClearToColor(c);
  G.Flip;
  Sound.Sound(412);
  G.Delay(1000);
  Sound.Close;
  G.Close
END TestSound.