MODULE TestSimpleGui;
IMPORT G := Graph, S := SimpleGui, Out, Int, Strings;

CONST window = FALSE;
VAR
  frmMain: S.Form;
  pnlSide: S.Panel;
  btnSave: S.Button;
  btnExit: S.Button;
  pnlMap: S.Panel;
  btn2: S.Button;
  btnMove: S.Button;
  edtText: S.Edit;
  scbHorz, scbHorz2: S.ScrollBar;
  scbVert: S.ScrollBar;
  sbxMap: S.ScrollBox;
  btnFile: S.Button;
  btnEdit: S.Button;
  edtMsg: S.Edit;
  custom: S.Widget;
  cnvSign: S.Canvas;

  XX, YY: INTEGER;
  moving: BOOLEAN;

PROCEDURE BtnExitOnClick(c: S.Widget);
BEGIN
  S.Quit
END BtnExitOnClick;

PROCEDURE Btn2OnClick(c: S.Widget);
BEGIN
  c(S.Button).caption[1] := CHR((ORD(c(S.Button).caption[1]) + 1) MOD 1256)
END Btn2OnClick;

PROCEDURE BtnExitOnMouseMove(c: S.Widget; x, y: INTEGER; btns: SET);
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

PROCEDURE BtnMoveOnMouseMove(c: S.Widget; x, y: INTEGER; btns: SET);
BEGIN
  IF moving THEN
    c.x := c.x + x - XX;
    c.y := c.y + y - YY;
    XX := x; YY := y;
    IF c.x < 0 THEN c.x := 0 END
  END;
END BtnMoveOnMouseMove;

PROCEDURE OnScroll(c: S.ScrollBar; value: INTEGER);
VAR s: ARRAY 32 OF CHAR;
BEGIN
  S.ScrollBarSetValue(scbHorz2, value);

  Int.Str(scbHorz.value, s);
  Strings.Append(':', s);
  Int.Append(scbVert.value, s);
  S.EditSetText(edtText, s)
END OnScroll;

PROCEDURE ScbHorz2OnScroll(c: S.ScrollBar; value: INTEGER);
BEGIN
  S.ScrollBarSetValue(scbVert, value)
END ScbHorz2OnScroll;

PROCEDURE CustomOnPaint(c: S.Widget; x, y, w, h: INTEGER);
VAR color: G.Color;
BEGIN
  G.MakeCol(color, 255, 255, 0);
  G.Line(x, y, x + w - 1, y + h - 1, color);
  G.Line(x + w - 1, y, x, y + h - 1, color);
END CustomOnPaint;

PROCEDURE CustomOnMouseMove(c: S.Widget; x, y: INTEGER; btns: SET);
VAR color: G.Color;
BEGIN
  G.MakeCol(color, 0, x * 7 MOD 256, y * 7 MOD 256);
  btnFile.bgColor := color
END CustomOnMouseMove;

PROCEDURE CnvSignOnMouseMove(c: S.Widget; x, y: INTEGER; btns: SET);
VAR color: G.Color;
  draw: BOOLEAN;
BEGIN
  draw := TRUE;
  IF btns = {1} THEN
    color := btnFile.bgColor
  ELSIF btns = {2} THEN
    G.MakeCol(color, 0, 255, 255)
  ELSE
    draw := FALSE
  END;
  IF draw THEN
    G.Target(c(S.Canvas).bmp);
    G.PutPixel(x, y, color)
  END
END CnvSignOnMouseMove;

PROCEDURE InitInterface(): BOOLEAN;
VAR W, H: INTEGER;
  color: G.Color;
BEGIN
  G.GetScreenSize(W, H);
  frmMain := S.NewForm(0, 0, W, H);

  pnlSide := S.NewPanel(frmMain, 4, 4, 104, H - 8);
  G.MakeCol(color, 40, 150, 40);
  S.SetBgColor(pnlSide, color);
  btnSave := S.NewButton(pnlSide, 4, 4, 96, 24, 'Сохранить');
  btnExit := S.NewButton(pnlSide, 4, 32, 96, 24, 'Выйти');
  S.SetOnClick(btnExit, BtnExitOnClick);
  S.SetOnMouseMove(btnExit, BtnExitOnMouseMove);
  edtText := S.NewEdit(pnlSide, 4, 60, 96, 20);
  scbHorz := S.NewScrollBar(pnlSide, 4, 84, 96, 16);
  S.ScrollBarSetOnScroll(scbHorz, OnScroll);
  scbHorz2 := S.NewScrollBar(pnlSide, 24, 104, 76, 50);
  S.ScrollBarSetOnScroll(scbHorz2, ScbHorz2OnScroll);
  scbVert := S.NewScrollBar(pnlSide, 4, 104, 16, 140);
  S.ScrollBarSetVertical(scbVert, TRUE);
  S.ScrollBarSetOnScroll(scbVert, OnScroll);

  pnlMap := S.NewPanel(frmMain, 112, 4, W - 116, H - 8);
  G.MakeCol(color, 150, 90, 40);
  S.SetBgColor(pnlMap, color);
  btn2 := S.NewButton(pnlMap, 64, 4, 96, 96, 'ОГО!');
  S.SetOnClick(btn2, Btn2OnClick);
  btnMove := S.NewButton(pnlMap, 168, 4, 96, 96, 'ДВИГАЙ');
  S.SetOnMouseDown(btnMove, BtnMoveOnMouseDown);
  S.SetOnMouseUp(btnMove, BtnMoveOnMouseUp);
  S.SetOnMouseMove(btnMove, BtnMoveOnMouseMove);

  sbxMap := S.NewScrollBox(pnlMap, 4, 104, 300, 200);
  S.ScrollBoxSetNoBg(sbxMap, ~TRUE);
  S.ScrollBoxSetInnerSize(sbxMap, 700, 800);
  G.MakeCol(color, 0, 90, 255);
  S.SetBgColor(sbxMap, color);
  btnFile := S.NewButton(sbxMap, 20, 40, 80, 24, 'Файл');
  btnEdit := S.NewButton(sbxMap, 260, 40, 80, 24, 'Правка');
  edtMsg := S.NewEdit(sbxMap, 60, 170, 120, 35);

  custom := S.NewWidget(sbxMap, 50, 70, 100, 70);
  S.SetOnPaint(custom, CustomOnPaint);
  S.SetOnMouseMove(custom, CustomOnMouseMove);

  cnvSign := S.NewCanvas(sbxMap, 210, 80, 150, 250);
  S.SetOnMouseMove(cnvSign, CnvSignOnMouseMove);

  moving := FALSE
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
END TestSimpleGui.
