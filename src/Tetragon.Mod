MODULE Tetragon;
(** Another TermBox usage example module *)
IMPORT T := TermBox, Out, Random, Kernel;
CONST
  maxW = 19; maxH = 12; (* Field maximum size *)

  (** Field contents (values of Cell.n) *)
  nothing = 0;
  soldier = 1;
  base    = 2;

TYPE
  Cell = RECORD
    n: INTEGER; (* Cell contents *)
    team: INTEGER (* Player number or -1 *)
  END;
  Field = ARRAY maxH, maxW OF Cell;

VAR SW, SH: INTEGER; (* Screen size in characters *)
  W, H: INTEGER; (* Field size *)
  field: Field;
  fieldX, fieldY: INTEGER; (* Field's offset on screen *)
  cellW, cellH: INTEGER; (* Cell's size on screen *)

  turn: INTEGER; (* Whoose turn is it: 0 to 1 *)
  curX, curY: INTEGER; (* Selected cell *)

PROCEDURE RestartGame;
VAR i, j: INTEGER;
BEGIN
  FOR i := 0 TO H - 1 DO
    FOR j := 0 TO W - 1 DO
      field[i, j].n := nothing;
      field[i, j].team := 0
    END
  END;
  i := H DIV 2;
  j := (W - 8) DIV 2;
  field[i, j].n := base;
  field[i, j].team := 0;
  field[i, j + 8].n := base;
  field[i, j + 8].team := 1;
  field[i, j + 9].n := soldier;
  field[i, j + 9].team := 1;

  turn := 0;
  curX := j; curY := i
END RestartGame;

PROCEDURE DrawCell(x, y: INTEGER);
VAR X, Y: INTEGER;
  fg, bg: INTEGER;
  c, c2: CHAR;
  cell: Cell;
BEGIN
  X := fieldX + x * cellW; Y := fieldY + y * cellH;
  cell := field[y, x];
  bg := 3;
  IF cell.team = 0 THEN fg := 4 ELSE fg := 9 END;
  IF cell.n = nothing THEN c := ' '
  ELSE
    IF cell.team = 0 THEN c := 'X' ELSE c := 'O' END;
    IF cell.n = base THEN bg := fg; fg := 0 END
  END;
  T.SetCell(X + 2, Y + 1, c, fg, bg);
  IF (curX = x) & (curY = y) THEN c := '>'; c2 := '<'
  ELSE c := ' '; c2 := ' '
  END;
  T.SetCell(X + 1, Y + 1, c, 0, 3);
  T.SetCell(X + 3, Y + 1, c2, 0, 3)
END DrawCell;

PROCEDURE DrawFrame;
CONST fg = 15; bg = 3;
VAR i, j, k: INTEGER;
  x, y: INTEGER;
BEGIN
  y := fieldY;
  FOR i := 0 TO H - 1 DO
    x := fieldX;
    FOR j := 0 TO W - 1 DO
      T.SetCell(x, y, 256CX, fg, bg);
      FOR k := 1 TO cellW - 1 DO T.SetCell(x + k, y, 2550X, fg, bg) END;
      FOR k := 1 TO cellH - 1 DO T.SetCell(x, y + k, 2551X, fg, bg) END;
      INC(x, cellW)
    END;
    INC(y, cellH)
  END;
  y := fieldY; x := fieldX + cellW * W;
  FOR i := 0 TO H - 1 DO
    T.SetCell(fieldX, y, 2560X, fg, bg);
    T.SetCell(x, y, 2563X, fg, bg);
    FOR k := 1 TO cellH - 1 DO T.SetCell(x, y + k, 2551X, fg, bg) END;
    INC(y, cellH)
  END;
  x := fieldX; y := fieldY + cellH * H;
  FOR i := 0 TO W - 1 DO
    T.SetCell(x, fieldY, 2566X, fg, bg);
    T.SetCell(x, y, 2569X, fg, bg);
    FOR k := 1 TO cellW - 1 DO T.SetCell(x + k, y, 2550X, fg, bg) END;
    INC(x, cellW)
  END;
  x := fieldX + cellW * W;
  T.SetCell(fieldX, fieldY, 2554X, fg, bg);
  T.SetCell(x, fieldY, 2557X, fg, bg);
  T.SetCell(fieldX, y, 255AX, fg, bg);
  T.SetCell(x, y, 255DX, fg, bg)
END DrawFrame;

PROCEDURE Draw;
VAR i, j: INTEGER;
BEGIN
  T.ClearTo(11, 3);
  DrawFrame;
  FOR i := 0 TO H - 1 DO
    FOR j := 0 TO W - 1 DO
      DrawCell(j, i)
    END
  END
END Draw;

PROCEDURE SetCur(x, y: INTEGER);
VAR X, Y: INTEGER;
BEGIN
  IF ((x # curX) OR (y # curY)) & (0 <= x) & (x < W) & (0 <= y) & (y < H) THEN
    X := curX; Y := curY;
    curX := x; curY := y;
    DrawCell(x, y);
    DrawCell(X, Y);
    T.Flush
  END
END SetCur;

PROCEDURE OnMouse(e: T.Event);
VAR x, y: INTEGER;
BEGIN
  x := (e.x - fieldX) DIV cellW;
  y := (e.y - fieldY) DIV cellH;
  SetCur(x, y)
END OnMouse;

PROCEDURE OnKey(e: T.Event);
VAR i, x, y: INTEGER;
BEGIN
  i := curY * W + curX;
  IF e.key = T.kUp THEN DEC(i, W)
  ELSIF e.key = T.kDown THEN INC(i, W)
  ELSIF e.key = T.kLeft THEN DEC(i, 1)
  ELSIF e.key = T.kRight THEN INC(i, 1)
  END;
  x := i MOD W;
  y := i MOD (W * H) DIV W;
  SetCur(x, y)
END OnKey;

PROCEDURE OnResize;
BEGIN
  T.Size(SW, SH);
  ;;;;;;Out.Int(SW, 7);Out.Int(SH, 7);Out.Ln;;;;;;
  fieldX := (SW - W * cellW) DIV 2;
  fieldY := (SH - H * cellH) DIV 2;
  Draw;
  T.Flush
END OnResize;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  Draw;
  T.Flush;
  REPEAT
    T.WaitEvent(e);
    IF e.type = T.mouse THEN OnMouse(e)
    ELSIF e.type = T.key THEN OnKey(e)
    ELSIF e.type = T.resize THEN OnResize
    ELSIF e.type = T.quit THEN done := TRUE
    END
  UNTIL done
END Run;

PROCEDURE InitVars;
BEGIN
  W := maxW; H := maxH;
  cellW := 4; cellH := 2;
  fieldX := (SW - W * cellW) DIV 2;
  fieldY := (SH - H * cellH) DIV 2
END InitVars;

BEGIN
  (*T.Settings(80, 25, {T.window, T.center, T.resizable});*)
  T.Init;
  T.Size(SW, SH);
  InitVars;
  RestartGame;
  Run;
  T.Close
END Tetragon.
