MODULE MapEditor;
IMPORT G := Graph, S := SimpleGui, Out;

VAR
  frmMain: S.Form;
  btnSave: S.Button;
  btnExit: S.Button;

PROCEDURE InitInterface(): BOOLEAN;
VAR W, H: INTEGER;
BEGIN
  G.GetScreenSize(W, H);
  frmMain := S.NewForm(0, 0, W, H);
  btnSave := S.NewButton(frmMain, 8, 8, 96, 24, 'Сохранить');
  btnExit := S.NewButton(frmMain, 8, 40, 96, 24, 'Выйти');
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