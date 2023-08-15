MODULE MapEditor;
IMPORT G := Graph, S := SimpleGui, Out, Int;

VAR
  frmMain: S.Form;
  pnlSide: S.Panel;
  btnSave: S.Button;
  btnExit: S.Button;
  pnlMap: S.Panel;
  btn2: S.Button;
  btnMove: S.Button;
  edtText: S.Edit;
  scbHoriz: S.ScrollBar;

  XX, YY: INTEGER;
  moving: BOOLEAN;

PROCEDURE Btn2OnClick(c: S.Widget);
BEGIN
  c(S.Button).caption[1] := CHR((ORD(c(S.Button).caption[1]) + 1) MOD 1256)
END Btn2OnClick;

PROCEDURE BtnExitOnMouseMove(c: S.Widget; x, y, btn: INTEGER);
BEGIN
  c(S.Button).caption[5] := CHR((ORD(c(S.Button).caption[5]) + 1) MOD 256);
  c(S.Button).caption[6] := CHR(ORD(c(S.Button).caption[5]) + 1);
  c(S.Button).caption[7] := 0X
END BtnExitOnMouseMove;

PROCEDURE BtnMoveOnMouseDown(c: S.Widget; x, y, btn: INTEGER);
BEGIN
  IF btn = 1 THEN moving := TRUE; XX := x; YY := y END
END BtnMoveOnMouseDown;

PROCEDURE BtnMoveOnMouseUp(c: S.Widget; x, y, btn: INTEGER);
BEGIN moving := FALSE
END BtnMoveOnMouseUp;

PROCEDURE BtnMoveOnMouseMove(c: S.Widget; x, y, btn: INTEGER);
BEGIN
  IF moving THEN
    c.x := c.x + x - XX;
    c.y := c.y + y - YY;
    XX := x; YY := y;
    IF c.x < 0 THEN c.x := 0 END
  END;
END BtnMoveOnMouseMove;

PROCEDURE ScbHorizOnScroll(c: S.Widget; value: INTEGER);
VAR s: ARRAY 16 OF CHAR;
BEGIN
  Int.Str(value, s);
  S.EditSetText(edtText, s)
END ScbHorizOnScroll;

PROCEDURE InitInterface(): BOOLEAN;
VAR W, H: INTEGER;
  color: G.Color;
BEGIN
  G.GetScreenSize(W, H);
  frmMain := S.NewForm(0, 0, W, H);

  pnlSide := S.NewPanel(frmMain, 4, 4, 104, 104);
  G.MakeCol(color, 40, 150, 40);
  S.SetBgColor(pnlSide, color);
  btnSave := S.NewButton(pnlSide, 4, 4, 96, 24, 'Сохранить');
  btnExit := S.NewButton(pnlSide, 4, 32, 96, 24, 'Выйти');
  S.SetOnMouseMove(btnExit, BtnExitOnMouseMove);
  edtText := S.NewEdit(pnlSide, 4, 60, 96, 20);
  scbHoriz := S.NewScrollBar(pnlSide, 4, 84, 96, 16);
  S.SetOnScroll(scbHoriz, ScbHorizOnScroll);

  pnlMap := S.NewPanel(frmMain, 112, 4, W - 116, H - 8);
  G.MakeCol(color, 150, 90, 40);
  S.SetBgColor(pnlMap, color);
  btn2 := S.NewButton(pnlMap, 64, 64, 96, 96, 'ОГО!');
  S.SetOnClick(btn2, Btn2OnClick);
  btnMove := S.NewButton(pnlMap, 168, 64, 96, 96, 'ДВИГАЙ');
  S.SetOnMouseDown(btnMove, BtnMoveOnMouseDown);
  S.SetOnMouseUp(btnMove, BtnMoveOnMouseUp);
  S.SetOnMouseMove(btnMove, BtnMoveOnMouseMove);

  moving := FALSE
RETURN TRUE END InitInterface;

PROCEDURE Init(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN ok := FALSE;
  G.Init;
  S.Init;
  IF G.Done & S.Done & InitInterface() THEN
    ok := TRUE
  END
RETURN ok END Init;

PROCEDURE Close;
BEGIN
  G.Close
END Close;

BEGIN
  IF Init() THEN S.Run ELSE Out.String('Error loading.'); Out.Ln END;
  Close
END MapEditor.