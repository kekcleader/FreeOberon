MODULE TermBox;
IMPORT G := Graph2;

CONST
  (* Settings set members *)
  fullscreen*  = 1;
  window*      = 2;
  exact*       = 3;
  smooth*      = 4;
  software*    = 5;
  initMouse*   = 6;
  center*      = 7;
  resizable*   = 8;
  maximized*   = 9;
  minimized*   = 10;
  frameless*   = 11;

  (* Event.type possible values *)
  quit*   = 0;
  key*    = 1;
  mouse*  = 2;
  none*   = 14;
  error*  = 15;

  emptyCh = ORD(' ');

  partW = 80;
  partH = 25;

TYPE
  Cell* = RECORD
    ch*: INTEGER;
    fg*, bg*: INTEGER
  END;

  Event* = RECORD
    type*: INTEGER;
    x*, y*: INTEGER;
    w*, h*: INTEGER;  (* Size of screen in cells on resize *)
    button*: INTEGER; (* Mouse button that is pressed *)
    key*: INTEGER;    (* Physical key code *)
    ch*: INTEGER;     (* Typed character *)
    mod*: SET         (* Key modifiers *)
  END;

  Part* = POINTER TO PartDesc; (* Part of screen *)
  PartDesc* = RECORD
    cells: ARRAY partH, partW OF Cell;
    updated: ARRAY partH, partW OF BOOLEAN; (* TRUE means need to redraw *)
    w, h: INTEGER; (* Actually used sizes of array *)
    redraw: BOOLEAN; (* TRUE if any cell needs to be redrawn *)
    down, right: Part
  END;

  Screen = RECORD
    first: Part;
    w, h: INTEGER;
    curX, curY: INTEGER (* Cursor position *)
  END;

VAR
  wantW, wantH: INTEGER;
  settings: SET;
  screen: Screen;

PROCEDURE SetPartCell(x, y, ch, fg, bg: INTEGER);
BEGIN
  IF (p.cells[y, x].ch # ch) OR
     (p.cells[y, x].fg # fg) OR
     (p.cells[y, x].bg # bg)
  THEN
    p.cells[y, x].ch := ch;
    p.cells[y, x].fg := fg;
    p.cells[y, x].bg := bg;
    p.updated[y, x] := TRUE;
    p.redraw := TRUE
  END
END SetPartCell;

PROCEDURE ClearTo(fg, bg: INTEGER);
VAR x, y: INTEGER;
  l, p: Part;
BEGIN l := screen.first;
  WHILE l # NIL DO p := l;
    WHILE p # NIL DO
      FOR y := 0 TO p.h - 1 DO
        FOR x := 0 TO p.w - 1 DO
          SetPartCell(x, y, emptyCh, fg, bg)
        END
      END;
      p := p.right
    END;
    l := l.next
  END
END ClearTo;

PROCEDURE Clear;
BEGIN ClearTo(7, 0)
END Clear;

PROCEDURE DrawCell(x, y: INTEGER; cell: Cell);
BEGIN

END DrawCell;

PROCEDURE SetCursor*(x, y: INTEGER);
BEGIN
  IF (x # screen.curX) OR (y # screen.curY) THEN
    UpdateCell(screen.curX, screen.curY);
    IF (0 <= x) & (x < screen.w) & (0 <= y) & (y < screen.h) THEN
      screen.curX := x; screen.curY := y;
      UpdateCell(x, y)
    ELSE screen.curX := -1; screen.curY := -1
    END
  END
END SetCursor;

PROCEDURE HideCursor*;
BEGIN SetCursor(-1, -1)
END HideCursor;

PROCEDURE SetBg*(x, y, bg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(screen, x, y);
  IF p # NIL THEN SetPartBg(p, x, y, bg) END
END SetBg;

PROCEDURE SetFg*(x, y, fg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(screen, x, y);
  IF p # NIL THEN SetPartFg(p, x, y, fg) END
END SetFg;

PROCEDURE SetCell*(x, y, ch, fg, bg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(screen, x, y);
  IF p # NIL THEN SetPartCell(p, x, y, ch, fg, bg) END
END SetCell;

PROCEDURE SetChar*(x, y, ch: INTEGER);
VAR p: Part;
BEGIN p := GetPart(screen, x, y);
  IF p # NIL THEN SetPartChar(p, x, y, ch) END
END SetChar;

PROCEDURE Size*(VAR width, height: INTEGER);
BEGIN width := screen.w; height := screen.h
END Size;

PROCEDURE GetCell*(x, y: INTEGER; VAR cell: Cell);
VAR p: Part;
BEGIN p := GetPart(screen, x, y);
  IF p # NIL THEN cell := p.cells[y, x]
  ELSE cell.ch := emptyCh; cell.fg := 7; cell.bg := 0
  END
END GetCell;

PROCEDURE WaitEvent*(VAR event: Event);
BEGIN
  event.type := 
END WaitEvent;

PROCEDURE Flush*;
VAR x, y, X, Y: INTEGER;
  l, p: Part;
BEGIN l := screen.first; Y := 0;
  WHILE l # NIL DO p := l; X := 0;
    WHILE p # NIL DO
      IF p.redraw THEN
        FOR y := 0 TO p.h - 1 DO
          FOR x := 0 TO p.w - 1 DO
            IF p.updated[y, x] THEN
              DrawCell(X + x, Y + y, p.cell[y, x]);
              p.updated[y, x] := FALSE
            END
          END
        END;
        p.redraw := FALSE
      END;
      INC(X, l.w); p := p.right
    END;
    INC(Y, l.h); l := l.next
  END
END Flush;

PROCEDURE Sync*;
BEGIN
  Flush (*!FIXME ?*)
END Sync;

PROCEDURE Close*;
BEGIN
  screen := NIL;
  G.Close
END Close;

PROCEDURE Init*;
BEGIN
  G.Settings(640, 400, {G.window, G.resizable, G.center(*, G.exact*)});
  (*G.SetZoomF(1.0);*)
  (*G.SetScale(5/6, 1.0);*)
  G.Init;
  G.GetScreenSize(W, H);
END Init;

PROCEDURE Settings*(w, h: INTEGER; flags: SET);
BEGIN wantW := w; wantH := h; settings := flags
END Settings;

BEGIN wantW := 80; wantH := 25; settings := {}
END TermBox.
