MODULE TestGui;
IMPORT Gui, B := Buttons, G := Graph, Int, Strings, Out;

VAR
  win: Gui.Window;
  btn, btn2: B.Button;
  QQQ, WWW: INTEGER;

PROCEDURE BtnOnClick(W: Gui.Widget);
VAR s: ARRAY 30 OF CHAR;
BEGIN
  s := 'Щёлк ';
  Int.Append(W.tag, s);
  Gui.SetText(W, s);
  INC(W.tag)
END BtnOnClick;

PROCEDURE MyButtonMouseMove(W: Gui.Widget; x, y, btn: INTEGER);
VAR s: ARRAY 30 OF CHAR;
BEGIN
  Int.Str(x, s);
  Strings.Append(':', s);
  Int.Append(y, s);
  Gui.SetText(W, s)
END MyButtonMouseMove;

PROCEDURE MyButtonMouseDown(W: Gui.Widget; x, y, btn: INTEGER);
VAR s: ARRAY 30 OF CHAR;
BEGIN
  Int.Str(QQQ, s);
  Strings.Append(', ', s);
  Int.Append(x, s);
  Strings.Append(':', s);
  Int.Append(y, s);
  Gui.SetText(W, s);
  INC(QQQ)
END MyButtonMouseDown;

PROCEDURE MyButtonMouseUp(W: Gui.Widget; x, y, btn: INTEGER);
VAR s: ARRAY 30 OF CHAR;
BEGIN
  Int.Str(QQQ, s);
  Strings.Append('; ', s);
  Int.Append(x, s);
  Strings.Append(':', s);
  Int.Append(y, s);
  Gui.SetText(W, s);
  INC(QQQ)
END MyButtonMouseUp;

PROCEDURE InitInterface;
BEGIN
  Gui.NewWindowSettings({G.fullscreen});
  win := Gui.NewWindow(320, 200);

  btn := B.NewButton(110, 24, 'Нажми меня');
  Gui.SetOnMouseMove(btn, MyButtonMouseMove);
  Gui.SetOnMouseDown(btn, MyButtonMouseDown);
  Gui.SetOnMouseUp(btn, MyButtonMouseUp);
  Gui.SetOnClick(btn, BtnOnClick);
  Gui.Place(win, btn, (win.w - btn.w) DIV 2, (win.h - btn.h) DIV 3);

  btn2 := B.NewButton(110, 24, 'Щёлкни сюда');
  Gui.SetOnClick(btn2, BtnOnClick);
  Gui.Place(win, btn2, btn.x, btn.y + btn.h + 4)

END InitInterface;

BEGIN
  QQQ := 0; WWW := 0;
  Gui.Init;
  IF Gui.Done THEN
    InitInterface;
    Gui.Run;
    Gui.Close
  ELSE Out.String('Could not init GUI.'); Out.Ln
  END
END TestGui.