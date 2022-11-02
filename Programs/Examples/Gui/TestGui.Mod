MODULE TestGui;
IMPORT Gui, B := Buttons, Panels, G := Graph, Int, Strings, Out;

VAR
  win: Gui.Window;
  btn, btn2, btn3: B.Button;
  panel1: Panels.Panel;
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

PROCEDURE Btn3OnMouseEnter(W: Gui.Widget);
BEGIN
  Gui.SetText(W, 'СЮДА')
END Btn3OnMouseEnter;

PROCEDURE Btn3OnMouseLeave(W: Gui.Widget);
BEGIN
  Gui.SetText(W, 'ТУДА')
END Btn3OnMouseLeave;

PROCEDURE InitInterface;
BEGIN
  Gui.NewWindowSettings({G.fullscreen});
  win := Gui.NewWindow(320, 200);

  (*Gui.NewWindowSettings({});
    win := Gui.NewWindow(800, 600);*)

  panel1 := Panels.NewPanel(220, 140, 'Кнопки');
  Gui.Place(win, panel1, (win.w - panel1.w) DIV 2, (win.h - panel1.h) DIV 3);

  btn := B.NewButton(110, 24, 'Нажми меня');
  Gui.SetDefault(btn, TRUE);
  Gui.SetOnMouseMove(btn, MyButtonMouseMove);
  Gui.SetOnMouseDown(btn, MyButtonMouseDown);
  Gui.SetOnMouseUp(btn, MyButtonMouseUp);
  Gui.SetOnClick(btn, BtnOnClick);
  Gui.Place(panel1, btn, 8, 20);

  btn2 := B.NewButton(110, 24, 'Щёлкни сюда');
  Gui.SetDefault(btn2, TRUE);
  Gui.SetOnClick(btn2, BtnOnClick);
  Gui.Place(panel1, btn2, 8, btn.y + btn.h + 8);

  btn3 := B.NewButton(110, 24, 'Ничто');
  Gui.Place(panel1, btn3, 8, btn2.y + btn2.h + 8);
  Gui.SetOnMouseEnter(btn3, Btn3OnMouseEnter);
  Gui.SetOnMouseLeave(btn3, Btn3OnMouseLeave);

  Gui.SetDefault(btn3, TRUE);

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