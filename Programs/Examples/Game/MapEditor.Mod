MODULE MapEditor;
IMPORT G := Graph, S := SimpleGui, Out, Int, Strings, E := GameEngine;
CONST window = FALSE;

TYPE
  MapWidget = POINTER TO MapWidgetDesc;
  MapWidgetDesc = RECORD(S.WidgetDesc)
    curX, curY: INTEGER
  END;

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
  wgtMap: MapWidget;

  game: E.Game;

PROCEDURE Limit(x, min, max: INTEGER): INTEGER;
BEGIN
  IF x < min THEN x := min ELSIF x > max THEN x := max END
RETURN x END Limit;

(** Map Widget **)

PROCEDURE DrawCell(cell: E.Cell; x, y, toX, toY: INTEGER);
VAR kx, ky: INTEGER;
BEGIN
  kx := cell.kind MOD E.tilesInRow * E.cellW;
  ky := cell.kind DIV E.tilesInRow * E.cellH;
  G.DrawPart(E.tiles, kx, ky, E.cellW, E.cellH, toX, toY)
END DrawCell;

PROCEDURE MapWidgetHandleDraw(c: S.Widget; VAR msg: S.DrawMsg);
VAR x: INTEGER;
  X, Y, i, j: INTEGER;
  cx, cy, cw, ch: INTEGER;
  x0, y0, x1, y1: INTEGER;
  col: G.Color;
  m: MapWidget;
BEGIN
  m := c(MapWidget);
  G.GetClip(cx, cy, cw, ch);
(*  INC(cx, E.cellW * 2);
  INC(cy, E.cellW * 2);
  DEC(cw, E.cellW * 4);
  DEC(ch, E.cellW * 4); *)
(*  INC(cx, 1);
  INC(cy, 1);
  DEC(cw, 2);
  DEC(ch, 2);*)

  x0 := (cx - msg.x) DIV E.cellW;
  IF x0 < 0 THEN x0 := 0 END;

  y0 := (cy - msg.y) DIV E.cellH;
  IF y0 < 0 THEN y0 := 0 END;

  x1 := (cx - msg.x + cw - 1) DIV E.cellW;
  IF x1 >= game.map.w THEN x1 := game.map.w - 1 END;

  y1 := (cy - msg.y + ch - 1) DIV E.cellH;
  IF y1 >= game.map.h THEN y1 := game.map.h - 1 END;

  G.MakeCol(col, 255, 0, 128);
  G.FillRect(0, 0, 2000, 2000, col);

  x := msg.x + x0 * E.cellW;
  Y := msg.y + y0 * E.cellH;
  FOR i := y0 TO y1 DO
    X := x;
    FOR j := x0 TO x1 DO
      DrawCell(game.map.cells[i, j], i, j, X, Y);
      INC(X, E.cellW)
    END;
    INC(Y, E.cellH)
  END;

  IF m.curX >= 0 THEN
    G.MakeCol(col, 240, 0, 0);
    X := msg.x + m.curX * E.cellW;
    Y := msg.y + m.curY * E.cellH;
    G.Rect(X - 1, Y - 1, X + E.cellW, Y + E.cellH, col);
  END;
  ;G.MakeCol(col, 0, 0, 0);
  G.Rect(cx - 2, cy - 2, cx + cw + 1, cy + ch + 1, col);
END MapWidgetHandleDraw;

PROCEDURE MapWidgetHandleMouseMove(c: S.Widget; VAR msg: S.MouseMoveMsg);
VAR m: MapWidget;
  x, y: INTEGER;
BEGIN
  m := c(MapWidget);
  x := Limit(msg.x DIV E.cellW, 0, game.map.w - 1);
  y := Limit(msg.y DIV E.cellH, 0, game.map.h - 1);
  IF (x # m.curX) OR (y # m.curY) THEN
    m.curX := x; m.curY := y;
    S.Redraw(c)
  END
END MapWidgetHandleMouseMove;

PROCEDURE MapWidgetHandler(c: S.Widget; VAR msg: S.Message);
BEGIN
  IF msg IS S.MouseMoveMsg THEN
    MapWidgetHandleMouseMove(c, msg(S.MouseMoveMsg))
  ELSIF msg IS S.MouseLeaveMsg THEN
    c(MapWidget).curX := -1; S.Redraw(c)
  ELSIF msg IS S.DrawMsg THEN
    MapWidgetHandleDraw(c, msg(S.DrawMsg))
  ELSE
    S.WidgetHandler(c, msg)
  END
END MapWidgetHandler;

PROCEDURE NewMapWidget(where: S.Widget; x, y, w, h: INTEGER): MapWidget;
VAR c: MapWidget;
BEGIN
  NEW(c); S.InitWidget(c, w, h);
  c.curX := -1; c.curY := 0;
  c.handle := MapWidgetHandler;
  S.Put(c, where, x, y)
RETURN c END NewMapWidget;
(** - **)

PROCEDURE BtnExitOnClick(c: S.Widget);
BEGIN
  S.Quit
END BtnExitOnClick;

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

  wgtMap := NewMapWidget(sbxMap, 0, 0, 1024, 1024)
RETURN TRUE END InitInterface;

PROCEDURE Init(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN ok := TRUE;
  IF window THEN G.Settings(640, 480, {G.window(*, G.maximized*)}) END;
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