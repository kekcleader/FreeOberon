MODULE TestGui;
IMPORT Gui, B := Buttons, G := Graph, Out;

VAR
  win: Gui.Window;
  btn: B.Button;

PROCEDURE InitInterface;
BEGIN
  Gui.NewWindowSettings(320, 200, {G.fullscreen});
  win := Gui.NewWindow();
  btn := B.NewButton(110, 24, 'Нажми меня');
  Gui.Place(win, btn, (win.w - btn.w) DIV 2, (win.h - btn.h) DIV 3)
END InitInterface;

BEGIN
  Gui.Init;
  IF Gui.Done THEN
    InitInterface;
    Gui.Run;
    Gui.Close
  ELSE Out.String('Could not init GUI.'); Out.Ln
  END
END TestGui.