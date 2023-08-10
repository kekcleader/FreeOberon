MODULE MapEditor;
IMPORT G := Graph, S := SimpleGui, Out;

VAR
  frmMain: S.Form;
  pnlButtons: S.Panel;
  btnSave: S.Button;
  btnExit: S.Button;
  pnlMap: S.Panel;
  btn2: S.Button;

PROCEDURE Btn2OnClick(c: S.Widget);
BEGIN
  c(S.Button).caption[1] := CHR((ORD(c(S.Button).caption[1]) + 1) MOD 1256)
END Btn2OnClick;

PROCEDURE BtnExitOnMouseMove(c: S.Widget; x, y: INTEGER);
BEGIN
  c(S.Button).caption[5] := CHR((ORD(c(S.Button).caption[5]) + 1) MOD 256);
  c(S.Button).caption[6] := CHR(ORD(c(S.Button).caption[5]) + 1);
  c(S.Button).caption[7] := 0X
END BtnExitOnMouseMove;

PROCEDURE InitInterface(): BOOLEAN;
VAR W, H: INTEGER;
  color: G.Color;
BEGIN
  G.GetScreenSize(W, H);
  frmMain := S.NewForm(0, 0, W, H);

  pnlButtons := S.NewPanel(frmMain, 4, 4, 104, 60);
  G.MakeCol(color, 40, 150, 40);
  S.SetBgColor(pnlButtons, color);
  btnSave := S.NewButton(pnlButtons, 4, 4, 96, 24, 'Сохранить');
  btnExit := S.NewButton(pnlButtons, 4, 32, 96, 24, 'Выйти');
  S.SetOnMouseMove(btnExit, BtnExitOnMouseMove);

  pnlMap := S.NewPanel(frmMain, 112, 4, W - 116, H - 8);
  G.MakeCol(color, 150, 90, 40);
  S.SetBgColor(pnlMap, color);
  btn2 := S.NewButton(pnlMap, 64, 64, 96, 96, 'ОГО!');
  S.SetOnClick(btn2, Btn2OnClick)

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