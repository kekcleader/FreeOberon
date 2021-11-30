MODULE Tetragon;
IMPORT T := TermBox, Out, Random, Kernel;
CONST
  maxW = 20; maxH = 12; (* Field maximum size *)

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

PROCEDURE ResetField;
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
  field[i, j + 9].team := 1
END ResetField;

PROCEDURE DrawCell(i, j: INTEGER);
VAR x, y: INTEGER;
  fg, bg: INTEGER;
  c: CHAR;
  cell: Cell;
BEGIN
  x := fieldX + j * cellW; y := fieldY + i * cellH;
  cell := field[i, j];
  bg := 3;
  IF cell.team = 0 THEN fg := 4 ELSE fg := 9 END;
  IF cell.n = nothing THEN c := ' '
  ELSE
    IF cell.team = 0 THEN c := 'X' ELSE c := 'O' END;
    IF cell.n = base THEN bg := fg; fg := 0 END
  END;
  T.SetCell(x + 2, y + 1, c, fg, bg);
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
      DrawCell(i, j)
    END
  END
END Draw;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  Draw;
  T.Flush;
  REPEAT
    T.WaitEvent(e);
    IF e.type = T.mouse THEN
    ELSIF e.type = T.key THEN
    ELSIF e.type = T.resize THEN T.Size(SW, SH)
    ELSIF e.type = T.quit THEN done := TRUE
    END
  UNTIL done
END Run;

PROCEDURE InitVars;
BEGIN
  W := maxW; H := maxH;
  cellW := 4; cellH := 2;
  fieldX := (SW - W * cellW) DIV 2;
  fieldY := (SH - H * cellH) DIV 2;
  ResetField
END InitVars;

BEGIN
  T.Init;
  T.Size(SW, SH);
  InitVars;
  Run;
  T.Close
END Tetragon.
