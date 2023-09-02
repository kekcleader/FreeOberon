MODULE GameEngine;
IMPORT G := Graph, Random, Out, Strings;

CONST
  maxMapW* = 128;
  maxMapH* = maxMapW;

  cellW* = 16;
  cellH* = cellW;

  tilesInRow* = 8;

  (** Direction set elements **)
  up        = 0;
  right     = 1;
  down      = 2;
  left      = 3;
  upRight   = 4;
  upLeft    = 5;
  downRight = 6;
  downLeft  = 7;

  (** Sets of directions **)
  allCorners = {upRight, upLeft, downRight, downLeft};
  allSides = {up, right, down, left};

TYPE
  Cell* = RECORD (** A single cell of the map *)
    kind*: INTEGER; (** What is saved in a file *)
    tile*: INTEGER; (** What is displayed on screen *)
    corners*: SET; (** Set of upRight, upLeft, downRight, downLeft *)
    dirs*: SET (** Set of up, right, down, left *)
  END;

  Map* = RECORD
    w*, h*: INTEGER;
    cells*: ARRAY maxMapH, maxMapW OF Cell
  END;

  Game* = RECORD
    map*: Map
  END;

VAR
  tiles*: G.Bitmap;

PROCEDURE DrawCell*(cell: Cell; x, y, toX, toY: INTEGER);
VAR kx, ky: INTEGER;
  PROCEDURE DrawCorner(tile, offX, offY, toX, toY: INTEGER);
  BEGIN G.DrawPart(tiles,
        tile MOD tilesInRow * cellW + offX,
        tile DIV tilesInRow * cellH + offY,
        cellW DIV 2, cellH DIV 2, toX + offX, toY + offY)
  END DrawCorner;
BEGIN
  kx := cell.tile MOD tilesInRow * cellW;
  ky := cell.tile DIV tilesInRow * cellH;
  G.DrawPart(tiles, kx, ky, cellW, cellH, toX, toY);
  IF cell.corners * allCorners # {} THEN
    IF ({up, left, down, right} - cell.corners = {}) &
       ({upRight, downLeft} - cell.corners = {}) &
       ~(upLeft IN cell.corners)
    THEN
      DrawCorner(cell.kind + tilesInRow * 3 + 4, 0, 0, toX, toY)
    ELSIF upLeft IN cell.corners THEN
      DrawCorner(cell.kind + tilesInRow + 5, 0, 0, toX, toY)
    ELSIF ({upRight, up, left} - cell.corners = {}) & ~(down IN cell.corners) OR
          ({downLeft, left, up} - cell.corners = {}) & ~(right IN cell.corners) THEN
      DrawCorner(cell.kind + tilesInRow * 3 + 4, 0, 0, toX, toY)
    END;

    IF ({up, left, down, right} - cell.corners = {}) &
       ({upLeft, downRight} - cell.corners = {}) &
       ~(upRight IN cell.corners)
    THEN
      DrawCorner(cell.kind + tilesInRow * 3 + 4, cellW DIV 2, 0, toX, toY)
    ELSIF upRight IN cell.corners THEN
      DrawCorner(cell.kind + tilesInRow + 4, cellW DIV 2, 0, toX, toY)
    ELSIF ({upLeft, up, right} - cell.corners = {}) & ~(down IN cell.corners) OR
          ({downRight, right, up} - cell.corners = {}) & ~(left IN cell.corners) THEN
      DrawCorner(cell.kind + tilesInRow * 3 + 4, cellW DIV 2, 0, toX, toY)
    END;

    IF ({up, left, down, right} - cell.corners = {}) &
       ({upLeft, downRight} - cell.corners = {}) &
       ~(downLeft IN cell.corners)
    THEN
      DrawCorner(cell.kind + tilesInRow * 3 + 4, 0, cellH DIV 2, toX, toY)
    ELSIF downLeft IN cell.corners THEN
      DrawCorner(cell.kind + 5, 0, cellH DIV 2, toX, toY)
    ELSIF ({downRight, down, left} - cell.corners = {}) & ~(up IN cell.corners) OR
          ({upLeft, left, down} - cell.corners = {}) & ~(right IN cell.corners) THEN
      DrawCorner(cell.kind + tilesInRow * 3 + 4, 0, cellH DIV 2, toX, toY)
    END;

    IF ({up, left, down, right} - cell.corners = {}) &
       ({upRight, downLeft} - cell.corners = {}) &
       ~(downRight IN cell.corners)
    THEN
      DrawCorner(cell.kind + tilesInRow * 3 + 4, cellW DIV 2, cellH DIV 2, toX, toY)
    ELSIF downRight IN cell.corners THEN
      DrawCorner(cell.kind + 4, cellW DIV 2, cellH DIV 2, toX, toY)
    ELSIF ({downLeft, down, right} - cell.corners = {}) & ~(up IN cell.corners) OR
          ({upRight, right, down} - cell.corners = {}) & ~(left IN cell.corners) THEN
      DrawCorner(cell.kind + tilesInRow * 3 + 4, cellW DIV 2, cellH DIV 2, toX, toY)
    END
  END
END DrawCell;

PROCEDURE CheckNeighbours(VAR map: Map; x, y, kind: INTEGER): SET;
VAR s: SET;
  PROCEDURE P(VAR map: Map; x, y, dir: INTEGER; VAR s: SET);
  BEGIN
    IF (0 <= x) & (x < map.w) & (0 <= y) & (y < map.h) &
       ((map.cells[y, x].kind = kind) OR
        (kind = 64) & (map.cells[y, x].kind = 96))
    THEN INCL(s, dir)
    END
  END P;
BEGIN
  s := {};
  P(map, x    , y - 1, up       , s);
  P(map, x + 1, y    , right    , s);
  P(map, x    , y + 1, down     , s);
  P(map, x - 1, y    , left     , s);
  P(map, x - 1, y - 1, upLeft   , s);
  P(map, x + 1, y - 1, upRight  , s);
  P(map, x - 1, y + 1, downLeft , s);
  P(map, x + 1, y + 1, downRight, s)
RETURN s END CheckNeighbours;

PROCEDURE UpdateMapTile*(VAR map: Map; x, y: INTEGER);
VAR kind, tile, xx, yy: INTEGER;
  dirs: SET; (* Set of directions of neighbours where kind is the same *)
  corners: SET;
BEGIN
  kind := map.cells[y, x].kind;
  tile := kind;
  corners := {};
  IF (kind >= 32) & (kind MOD 32 = 0) THEN
    dirs := CheckNeighbours(map, x, y, kind);
    xx := 3; yy := 3;
    IF up IN dirs THEN
      IF {left, right, down} - dirs = {} THEN
        IF    ~(upLeft    IN dirs) & ~(downLeft  IN dirs) THEN xx := 0; yy := 1
        ELSIF ~(upLeft    IN dirs) & ~(upRight   IN dirs) THEN xx := 1; yy := 0
        ELSIF ~(upRight   IN dirs) & ~(downRight IN dirs) THEN xx := 2; yy := 1
        ELSIF ~(downLeft  IN dirs) & ~(downRight IN dirs) THEN xx := 1; yy := 2
        ELSIF ~(upLeft    IN dirs) THEN xx := 5; yy := 1
        ELSIF ~(upRight   IN dirs) THEN xx := 4; yy := 1
        ELSIF ~(downLeft  IN dirs) THEN xx := 5; yy := 0
        ELSIF ~(downRight IN dirs) THEN xx := 4; yy := 0
        ELSE xx := 1; yy := 1
        END
      ELSIF {left , right} - dirs = {} THEN xx := 1; yy := 2
      ELSIF {left , down } - dirs = {} THEN xx := 2; yy := 1
      ELSIF {right, down } - dirs = {} THEN xx := 0; yy := 1
      ELSIF left  IN dirs THEN xx := 2; yy := 2
      ELSIF right IN dirs THEN xx := 0; yy := 2
      ELSIF down  IN dirs THEN xx := 3; yy := 1
      ELSE                     xx := 3; yy := 2
      END
    ELSIF down IN dirs THEN
      IF {left, right} - dirs = {} THEN xx := 1; yy := 0
      ELSIF left  IN dirs THEN xx := 2; yy := 0
      ELSIF right IN dirs THEN xx := 0; yy := 0
      ELSE                     xx := 3; yy := 0
      END
    ELSIF left IN dirs THEN
      IF right IN dirs THEN  xx := 1; yy := 3
      ELSE                   xx := 2; yy := 3
      END
    ELSIF right IN dirs THEN xx := 0; yy := 3
    END;
    tile := kind + xx + yy * tilesInRow;
    IF {up, left, upLeft} - dirs = {upLeft} THEN INCL(corners, upLeft) END;
    IF {up, right, upRight} - dirs = {upRight} THEN INCL(corners, upRight) END;
    IF {down, left, downLeft} - dirs = {downLeft} THEN INCL(corners, downLeft) END;
    IF {down, right, downRight} - dirs = {downRight} THEN INCL(corners, downRight) END;
    corners := corners + dirs * allSides
  END;
  map.cells[y, x].tile := tile;
  map.cells[y, x].corners := corners;
  map.cells[y, x].dirs := dirs
END UpdateMapTile;

PROCEDURE UpdateMapTiles*(VAR map: Map);
VAR x, y: INTEGER;
BEGIN
  FOR y := 0 TO map.h - 1 DO
    FOR x := 0 TO map.w - 1 DO
      UpdateMapTile(map, x, y)
    END
  END
END UpdateMapTiles;

PROCEDURE UpdateMapTileAround*(VAR map: Map; x, y: INTEGER);
BEGIN
  UpdateMapTile(map, x, y);
  IF x > 0 THEN
    UpdateMapTile(map, x - 1, y);
    IF y > 0 THEN UpdateMapTile(map, x - 1, y - 1) END;
    IF y < map.h - 1 THEN UpdateMapTile(map, x - 1, y + 1) END
  END;
  IF x < map.w - 1 THEN
    UpdateMapTile(map, x + 1, y);
    IF y > 0 THEN UpdateMapTile(map, x + 1, y - 1) END;
    IF y < map.h - 1 THEN UpdateMapTile(map, x + 1, y + 1) END
  END;
  IF y > 0 THEN UpdateMapTile(map, x, y - 1) END;
  IF y < map.h - 1 THEN UpdateMapTile(map, x, y + 1) END
END UpdateMapTileAround;

PROCEDURE SetCell*(VAR map: Map; x, y, kind: INTEGER);
  PROCEDURE P(VAR cell: Cell; kind: INTEGER);
  BEGIN
    IF cell.kind # kind THEN
      cell.kind := kind;
      UpdateMapTileAround(map, x, y)
    END
  END P;
BEGIN
  P(map.cells[y, x], kind)
END SetCell;

PROCEDURE MakeRandomMap*(VAR map: Map; w, h: INTEGER);
VAR x, y: INTEGER;
BEGIN
  map.w := w; map.h := h;
  FOR y := 0 TO h - 1 DO
    FOR x := 0 TO w - 1 DO
      map.cells[y, x].kind := 0 (*Random.Int(4)*)
    END
  END;
  UpdateMapTiles(map)
END MakeRandomMap;

PROCEDURE LoadMap*(VAR map: Map; fname: ARRAY OF CHAR): BOOLEAN;
BEGIN

RETURN TRUE END LoadMap;

PROCEDURE SaveMap*(VAR map: Map; fname: ARRAY OF CHAR);
BEGIN

END SaveMap;

(** Returns a bitmap with the given name (appends strings to make a file name).
    On error sets ok to FALSE and ouputs an error message.
    Never sets ok to TRUE. *)
PROCEDURE LoadBitmap(name: ARRAY OF CHAR; VAR ok: BOOLEAN): G.Bitmap;
VAR bmp: G.Bitmap;
  s: ARRAY 256 OF CHAR;
BEGIN
  s := 'Data/Graph/';
  Strings.Append(name, s);
  Strings.Append('.png', s);
  bmp := G.LoadBitmap(s);
  IF bmp = NIL THEN
    ok := FALSE;
    Out.String('Error: Could not load bitmap "');
    Out.String(s); Out.String('".'); Out.Ln
  END
RETURN bmp END LoadBitmap;

PROCEDURE InitGame*(VAR game: Game);
BEGIN
  MakeRandomMap(game.map, 128, 128)
END InitGame;

PROCEDURE Init*(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN ok := TRUE;
  tiles := LoadBitmap('tiles', ok)
RETURN ok END Init;

END GameEngine.