MODULE MapEditor;
IMPORT G := Graph, S := SimpleGui, Out, Int, Strings;

CONST window = FALSE;
VAR
  frmMain: S.Form;

  pnlTop: S.Panel;
  lblMapName: S.Label;
  edtMapName: S.Edit;
  btnOpen: S.Button;
  btnSave: S.Button;
  btnExit: S.Button;

  pnlSide: S.Panel;

  sbxMap: S.ScrollBox;
  map: S.Widget;

PROCEDURE BtnExitOnClick(c: S.Widget);
BEGIN
  S.Quit
END BtnExitOnClick;

PROCEDURE MapOnPaint(c: S.Widget; x, y, w, h: INTEGER);
VAR color: G.Color;
BEGIN
  G.MakeCol(color, 255, 255, 0);
  G.Line(x, y, x + w - 1, y + h - 1, color);
  G.Line(x + w - 1, y, x, y + h - 1, color);
END MapOnPaint;

PROCEDURE SbxMapOnMouseMove(c: S.Widget; x, y: INTEGER; btns: SET);
VAR color: G.Color;
  draw: BOOLEAN;
BEGIN
  draw := TRUE;
  IF btns = {1} THEN
    G.MakeCol(color, 0, 0, 0)
  ELSIF btns = {2} THEN
    G.MakeCol(color, 0, 255, 255)
  ELSE
    draw := FALSE
  END;
  IF draw THEN
    G.Target(c(S.Canvas).bmp);
    G.PutPixel(x, y, color)
  END
END SbxMapOnMouseMove;

PROCEDURE InitInterface(): BOOLEAN;
VAR W, H: INTEGER;
  color: G.Color;
BEGIN
  G.GetScreenSize(W, H);
  frmMain := S.NewForm(0, 0, W, H);

  pnlTop := S.NewPanel(frmMain, 0, 0, W, 40);

  lblMapName := S.NewLabel(pnlTop, 8, 9, 120, 22, 'Имя файла:');
  S.LabelSetAlign(lblMapName, S.alRight);

  edtMapName := S.NewEdit(pnlTop, lblMapName.x + lblMapName.w + 8,
      9, 120, 22);

  btnOpen := S.NewButton(pnlTop, edtMapName.x + edtMapName.w + 8,
      8, 96, 24, 'Открыть');

  btnSave := S.NewButton(pnlTop, btnOpen.x + btnOpen.w + 8,
      8, 96, 24, 'Сохранить');

  btnExit := S.NewButton(pnlTop, W - 68, 8, 60, 24, 'Выход');
  S.SetOnClick(btnExit, BtnExitOnClick);

  pnlSide := S.NewPanel(frmMain, 0, pnlTop.h, 180, H - pnlTop.h);
  G.MakeCol(color, 40, 150, 40);
  S.SetBgColor(pnlSide, color);

  sbxMap := S.NewScrollBox(frmMain, pnlSide.w, pnlTop.h,
      W - pnlSide.w, H - pnlTop.h);
  S.ScrollBoxSetInnerSize(sbxMap, 1024, 1024);
  G.MakeCol(color, 0, 0, 0);
  S.SetBgColor(sbxMap, color);
  (*S.ScrollBoxSetNoBg(sbxMap, TRUE);*)
  (*S.SetOnMouseMove(sbxMap, SbxMapOnMouseMove);*)

RETURN TRUE END InitInterface;

PROCEDURE Init(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN ok := TRUE;
  IF window THEN G.Settings(640, 480, {G.window}) END;
  G.Init;
  IF ~G.Done THEN ok := FALSE END;
  IF ok THEN
    S.Init;
    IF ~S.Done THEN ok := FALSE END
  END;
  IF ok & ~InitInterface() THEN ok := FALSE END
RETURN ok END Init;

PROCEDURE Close;
BEGIN
  G.Close
END Close;

BEGIN
  IF Init() THEN S.Run ELSE Out.String('Error loading.'); Out.Ln END;
  Close
END MapEditor.