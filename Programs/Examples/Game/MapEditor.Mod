MODULE MapEditor;
IMPORT G := Graph, S := SimpleGui, Out, Int, Strings, E := GameEngine;
CONST window = ~FALSE;
VAR
  frmMain: S.Form;

  pnlTop: S.Panel;
  lblMapName: S.Label;
  edtMapName: S.Edit;
  btnOpen: S.Button;
  btnSave: S.Button;
  btnExit: S.Button;

  pnlSide: S.Panel;
  scbVert: S.ScrollBar;

  sbxMap: S.ScrollBox;
  wgtMap: S.Widget;
  cellX, cellY: INTEGER;

  game: E.Game;

PROCEDURE BtnExitOnClick(c: S.Widget);
BEGIN
  S.Quit
END BtnExitOnClick;

PROCEDURE DrawCell(cell: E.Cell; x, y, toX, toY: INTEGER);
VAR kx, ky: INTEGER;
BEGIN
  kx := cell.kind MOD E.tilesInRow * E.cellW;
  ky := cell.kind DIV E.tilesInRow * E.cellH;
  G.DrawPart(E.tiles, kx, ky, E.cellW, E.cellH, toX, toY);
END DrawCell;

PROCEDURE WgtMapOnPaint(c: S.Widget; x, y, w, h: INTEGER);
VAR X, Y, i, j: INTEGER;
BEGIN
  Y := y;
  FOR i := 0 TO game.map.h - 1 DO
    X := x;
    FOR j := 0 TO game.map.w - 1 DO
      DrawCell(game.map.cells[i, j], i, j, X, Y);
      INC(X, E.cellW)
    END;
    INC(Y, E.cellH)
  END
END WgtMapOnPaint;

PROCEDURE WgtMapOnMouseMove(c: S.Widget; x, y: INTEGER; btns: SET);
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
END WgtMapOnMouseMove;

PROCEDURE InitMapWidgetVars;
BEGIN
  cellX := -1;
  cellY := 0
END InitMapWidgetVars;

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

  scbVert := S.NewScrollBar(pnlSide, 20, 20, 16, 150);
  S.ScrollBarSetVertical(scbVert, TRUE);
  scbVert.max := 8;

  sbxMap := S.NewScrollBox(frmMain, pnlSide.w, pnlTop.h,
      W - pnlSide.w, H - pnlTop.h);
  S.ScrollBoxSetInnerSize(sbxMap, 1024, 1024);
  G.MakeCol(color, 0, 0, 0);
  S.ScrollBoxSetNoBg(sbxMap, TRUE);

  wgtMap := S.NewWidget(sbxMap, 0, 0, 1024, 1024);
  S.SetOnPaint(wgtMap, WgtMapOnPaint);
  (*S.SetOnMouseMove(wgtMap, WgtMapOnMouseMove);*)
  InitMapWidgetVars
RETURN TRUE END InitInterface;

PROCEDURE Init(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN ok := TRUE;
  IF window THEN G.Settings(640, 480, {G.window, G.maximized}) END;
  G.Init;
  IF ~G.Done THEN ok := FALSE END;
  IF ok THEN
    S.Init;
    IF ~S.Done THEN ok := FALSE END
  END;
  IF ok & ~E.Init() THEN ok := FALSE END;
  IF ok THEN E.InitGame(game) END;
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