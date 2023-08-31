MODULE MapEditor;
IMPORT G := Graph, S := SimpleGui, Out, Int, Strings, E := GameEngine;
CONST window = FALSE;
TYPE
  MapWidget = POINTER TO MapWidgetDesc;
  MapWidgetDesc = RECORD(S.WidgetDesc)
    curX, curY: INTEGER
  END;

  TilesetWidget = POINTER TO TilesetWidgetDesc;
  TilesetWidgetDesc = RECORD(S.ScrollBox)
    curTile: INTEGER
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

  sbxMap: S.ScrollBox;
  wgtMap: MapWidget;
  wgtTileset: TilesetWidget;

  game: E.Game;

PROCEDURE Limit(x, min, max: INTEGER): INTEGER;
BEGIN
  IF x < min THEN x := min ELSIF x > max THEN x := max END
RETURN x END Limit;

(** Map Widget **)

PROCEDURE DrawCell(cell: E.Cell; x, y, toX, toY: INTEGER);
VAR kx, ky: INTEGER;
BEGIN
  kx := cell.tile MOD E.tilesInRow * E.cellW;
  ky := cell.tile DIV E.tilesInRow * E.cellH;
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
  (*INC(cx, E.cellW * 2);
  INC(cy, E.cellW * 2);
  DEC(cw, E.cellW * 4);
  DEC(ch, E.cellW * 4);*)

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
  END
END MapWidgetHandleDraw;

(** (x; y) in cells *)
PROCEDURE OnMapMouseDown(x, y: INTEGER);
BEGIN
  E.SetCell(game.map, x, y, wgtTileset.curTile);
  S.Redraw(wgtMap)
END OnMapMouseDown;

PROCEDURE MapWidgetHandleMouseDown(c: S.Widget; VAR msg: S.MouseDownMsg);
VAR m: MapWidget;
  x, y: INTEGER;
BEGIN
  m := c(MapWidget);
  x := Limit(msg.x DIV E.cellW, 0, game.map.w - 1);
  y := Limit(msg.y DIV E.cellH, 0, game.map.h - 1);
  IF msg.btn = 1 THEN
    OnMapMouseDown(x, y)
  END
END MapWidgetHandleMouseDown;

PROCEDURE MapWidgetHandleMouseMove(c: S.Widget; VAR msg: S.MouseMoveMsg);
VAR m: MapWidget;
  x, y: INTEGER;
BEGIN
  m := c(MapWidget);
  x := Limit(msg.x DIV E.cellW, 0, game.map.w - 1);
  y := Limit(msg.y DIV E.cellH, 0, game.map.h - 1);
  IF (x # m.curX) OR (y # m.curY) THEN
    m.curX := x; m.curY := y;
    IF 1 IN msg.btns THEN
      OnMapMouseDown(x, y)
    END;
    S.Redraw(c)
  END
END MapWidgetHandleMouseMove;

PROCEDURE MapWidgetHandler(c: S.Widget; VAR msg: S.Message);
BEGIN
  IF msg IS S.MouseMoveMsg THEN
    MapWidgetHandleMouseMove(c, msg(S.MouseMoveMsg))
  ELSIF msg IS S.MouseLeaveMsg THEN
    c(MapWidget).curX := -1; S.Redraw(c)
  ELSIF msg IS S.MouseDownMsg THEN
    MapWidgetHandleMouseDown(c, msg(S.MouseDownMsg))
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

(** Tileset Widget **)

PROCEDURE TilesetWidgetOnInnerPaint(c: S.Widget; x, y, w, h: INTEGER);
VAR col: G.Color;
  n, X, Y: INTEGER;
  t: TilesetWidget;
BEGIN
  t := c.parent.parent(TilesetWidget);
  G.Draw(E.tiles, x, y);

  G.MakeCol(col, 0, 110, 240);
  X := x + t.curTile MOD E.tilesInRow * E.cellW;
  Y := y + t.curTile DIV E.tilesInRow * E.cellH;
  G.Rect(X, Y, X + E.cellW - 1, Y + E.cellH - 1, col)
END TilesetWidgetOnInnerPaint;

PROCEDURE TilesetWidgetOnMouseDown(c: S.Widget; x, y, btn: INTEGER);
VAR t: TilesetWidget;
  n: INTEGER;
BEGIN t := c.parent.parent(TilesetWidget);
  IF btn = 1 THEN
    IF x < 0 THEN x := 0 ELSIF x >= c.w THEN x := c.w - 1 END;
    IF y < 0 THEN y := 0 ELSIF y >= c.h THEN y := c.h - 1 END;

    n := y DIV E.cellH * E.tilesInRow + x DIV E.cellW;
    IF t.curTile # n THEN
      t.curTile := n;
      S.Redraw(c)
    END
  END
END TilesetWidgetOnMouseDown;

PROCEDURE TilesetWidgetOnMouseMove(c: S.Widget; x, y: INTEGER; btns: SET);
BEGIN IF 1 IN btns THEN TilesetWidgetOnMouseDown(c, x, y, 1) END
END TilesetWidgetOnMouseMove;

PROCEDURE NewTilesetWidget(where: S.Widget; x, y, w, h: INTEGER): TilesetWidget;
VAR c: TilesetWidget;
BEGIN
  NEW(c); S.InitScrollBox(c, where, x, y, w, h);
  S.ScrollBoxSetInnerSize(c, E.tiles.w, E.tiles.h);
  S.SetOnPaint(c.inner, TilesetWidgetOnInnerPaint);
  S.SetOnMouseMove(c.inner, TilesetWidgetOnMouseMove);
  S.SetOnMouseDown(c.inner, TilesetWidgetOnMouseDown);
  c.curTile := 0
RETURN c END NewTilesetWidget;

(** - **)

PROCEDURE BtnExitOnClick(c: S.Widget);
BEGIN
  S.Quit
END BtnExitOnClick;

PROCEDURE InitInterface(): BOOLEAN;
VAR W, H, w, h: INTEGER;
  color: G.Color;
BEGIN
  G.GetScreenSize(W, H);
  frmMain := S.NewForm(0, 0, W, H);

  pnlTop := S.NewPanel(frmMain, 0, 0, W, 40);

  lblMapName := S.NewLabel(pnlTop, 8, 9, 88, 22, 'Имя файла:');
  S.LabelSetAlign(lblMapName, S.alRight);

  edtMapName := S.NewEdit(pnlTop, lblMapName.x + lblMapName.w + 8,
      9, 40, 22);

  btnOpen := S.NewButton(pnlTop, edtMapName.x + edtMapName.w + 8,
      8, 70, 24, 'Открыть');

  btnSave := S.NewButton(pnlTop, btnOpen.x + btnOpen.w + 8,
      8, 80, 24, 'Сохранить');

  btnExit := S.NewButton(pnlTop, W - 68, 8, 52, 24, 'Выход');
  S.SetOnClick(btnExit, BtnExitOnClick);

  pnlSide := S.NewPanel(frmMain, 0, pnlTop.h, 144, H - pnlTop.h);
  G.MakeCol(color, 40, 150, 40);
  S.SetBgColor(pnlSide, color);

  wgtTileset := NewTilesetWidget(pnlSide, 0, 0, pnlSide.w, pnlSide.h);

  sbxMap := S.NewScrollBox(frmMain, pnlSide.w, pnlTop.h,
      W - pnlSide.w, H - pnlTop.h);
  w := game.map.w * E.cellW;
  h := game.map.h * E.cellH;
  S.ScrollBoxSetInnerSize(sbxMap, w, h);
  (*S.ScrollBoxSetNoBg(sbxMap, TRUE);*)

  wgtMap := NewMapWidget(sbxMap, 0, 0, w, h)
RETURN TRUE END InitInterface;

PROCEDURE Init(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN ok := TRUE;
  G.Settings(320, 200, {});
  IF window THEN G.Settings(1240, 780, {G.window(*, G.maximized*)}) END;
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