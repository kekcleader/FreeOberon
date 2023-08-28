MODULE GameEngine;
IMPORT G := Graph, Random, Out, Strings;

CONST
  maxMapW* = 128;
  maxMapH* = maxMapW;

  cellW* = 16;
  cellH* = cellW;

  tilesInRow* = 8;

TYPE
  Cell* = RECORD (** A single cell of the map *)
    kind*: INTEGER
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

PROCEDURE MakeRandomMap*(VAR map: Map; w, h: INTEGER);
VAR x, y: INTEGER;
BEGIN
  map.w := w; map.h := h;
  FOR y := 0 TO h - 1 DO
    FOR x := 0 TO w - 1 DO
      map.cells[y, x].kind := 0 (*Random.Int(4)*)
    END
  END
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