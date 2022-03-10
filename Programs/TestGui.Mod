MODULE TestGui;
IMPORT Gui, B := Buttons, G := Graph, Int, Out;

VAR
  win: Gui.Window;
  btn: B.Button;
  QQQ: INTEGER;

PROCEDURE MyButtonMouseDown(W: Gui.Widget; x, y, btn: INTEGER);
VAR s: ARRAY 30 OF CHAR;
BEGIN
  s := 'Щёлк номер ';
  Int.Append(QQQ, s);
  Gui.SetText(W, s);
  INC(QQQ)
END MyButtonMouseDown;

PROCEDURE InitInterface;
BEGIN
  Gui.NewWindowSettings({G.fullscreen});
  win := Gui.NewWindow(320, 200);
  btn := B.NewButton(110, 24, 'Нажми меня');
  Gui.SetOnMouseDown(btn, MyButtonMouseDown);
  Gui.Place(win, btn, (win.w - btn.w) DIV 2, (win.h - btn.h) DIV 3)
END InitInterface;

BEGIN
  QQQ := 0;
  Gui.Init;
  IF Gui.Done THEN
    InitInterface;
    Gui.Run;
    Gui.Close
  ELSE Out.String('Could not init GUI.'); Out.Ln
  END
END TestGui.