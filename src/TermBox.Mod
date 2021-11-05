MODULE TermBox;
IMPORT G := Graph2, Out;

CONST
  (* Settings set members *)
  fullscreen*  = 1;
  window*      = 2;
  exact*       = 3;
  sharp*       = 4;
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
  resize* = 11;
  none*   = 14;
  error*  = 15;

  (* Modifiers Set *)
  mShift*    = 0;
  mCtrl*     = 1;
  mAlt*      = 2;
  mLMeta*    = 3;
  mRMeta*    = 4;
  mAltGr*    = 5; (*!FIXME check this*)
  mMenu*     = 6; (*!FIXME check this*)
  mCommand*  = 7;
  mScroll*   = 8;
  mNum*      = 9;
  mCaps*     = 10;
  mAltKeys*  = {mAlt, mAltGr};
  mMetaKeys* = {mLMeta, mRMeta};

  emptyCh = ' ';

  partW = 800;
  partH = 250;

  nofcolors = 16;

TYPE
  Event* = RECORD
    type*: INTEGER;
    x*, y*: INTEGER;
    w*, h*: INTEGER;  (* Size of screen in cells on resize *)
    button*: INTEGER; (* Mouse button that is pressed *)
    key*: INTEGER;    (* Physical key code *)
    ch*: CHAR;        (* Typed character *)
    mod*: SET         (* Key modifiers *)
  END;

  Cell* = RECORD
    ch*: CHAR;
    fg*, bg*: INTEGER
  END;

  Part* = POINTER TO PartDesc; (* Part of screen buffer *)
  PartDesc* = RECORD
    cells: ARRAY partH, partW OF Cell;
    updated: ARRAY partH, partW OF BOOLEAN; (* TRUE means need to redraw *)
    w, h: INTEGER; (* Actually used sizes of array *)
    redraw: BOOLEAN; (* TRUE if any cell needs to be redrawn *)
    down, right: Part
  END;

  Buffer = RECORD (* Screen buffer *)
    first: Part;
    w, h: INTEGER;
    curX, curY: INTEGER; (* Cursor position *)
    redrawAll: BOOLEAN
  END;

VAR
  wantTitle: ARRAY 256 OF CHAR; (* Assigned in procedure SetTitle *)
  wantZoom: REAL;
  wantW, wantH: INTEGER;
  wantScaleX, wantScaleY: REAL;
  settings: SET;
  buffer: Buffer;

  screen: G.Window;
  font: G.MonoFont;
  colors: ARRAY nofcolors OF G.Color;

  Done*: BOOLEAN;

PROCEDURE SetPartCell(p: Part; x, y: INTEGER; ch: CHAR; fg, bg: INTEGER);
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

PROCEDURE SetPartChar(p: Part; x, y: INTEGER; ch: CHAR);
BEGIN
  IF p.cells[y, x].ch # ch THEN
    p.cells[y, x].ch := ch;
    p.updated[y, x] := TRUE;
    p.redraw := TRUE
  END
END SetPartChar;

PROCEDURE SetPartFg(p: Part; x, y, fg: INTEGER);
BEGIN
  IF p.cells[y, x].fg # fg THEN
    p.cells[y, x].fg := fg;
    p.redraw := TRUE
  END
END SetPartFg;

PROCEDURE SetPartBg(p: Part; x, y, bg: INTEGER);
BEGIN
  IF p.cells[y, x].bg # bg THEN
    p.cells[y, x].bg := bg;
    p.redraw := TRUE
  END
END SetPartBg;

PROCEDURE GetPart(S: Buffer; VAR x, y: INTEGER): Part;
VAR p: Part;
BEGIN p := S.first;
  WHILE (p # NIL) & (y >= p.h) DO DEC(y, p.h); p := p.down END;
  WHILE (p # NIL) & (x >= p.w) DO DEC(x, p.w); p := p.right END
RETURN p END GetPart;

PROCEDURE ClearTo*(fg, bg: INTEGER);
VAR x, y: INTEGER;
  l, p: Part;
BEGIN l := buffer.first;
  WHILE l # NIL DO p := l;
    WHILE p # NIL DO
      FOR y := 0 TO p.h - 1 DO
        FOR x := 0 TO p.w - 1 DO
          SetPartCell(p, x, y, emptyCh, fg, bg)
        END
      END;
      p := p.right
    END;
    l := l.down
  END
END ClearTo;

PROCEDURE Clear;
BEGIN ClearTo(7, 0)
END Clear;

PROCEDURE DrawCell(x, y: INTEGER; cell: Cell);
VAR w, h: INTEGER;
BEGIN G.GetMonoFontSize(font, w, h); x := x * w; y := y * h;
  G.FillRect(x, y, x + w - 1, y + h - 1, colors[cell.bg MOD nofcolors]);
  G.DrawChar(cell.ch, x, y, font, colors[cell.fg MOD nofcolors])
END DrawCell;

PROCEDURE Flip;
BEGIN G.Flip
END Flip;

PROCEDURE UpdateCell(x, y: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN p.updated[y, x] := TRUE; p.redraw := TRUE END
END UpdateCell;

PROCEDURE SetCursor*(x, y: INTEGER);
BEGIN
  IF (x # buffer.curX) OR (y # buffer.curY) THEN
    UpdateCell(buffer.curX, buffer.curY);
    IF (0 <= x) & (x < buffer.w) & (0 <= y) & (y < buffer.h) THEN
      buffer.curX := x; buffer.curY := y;
      UpdateCell(x, y)
    ELSE buffer.curX := -1; buffer.curY := -1
    END
  END
END SetCursor;

PROCEDURE HideCursor*;
BEGIN SetCursor(-1, -1)
END HideCursor;

PROCEDURE SetBg*(x, y, bg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartBg(p, x, y, bg) END
END SetBg;

PROCEDURE SetFg*(x, y, fg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartFg(p, x, y, fg) END
END SetFg;

PROCEDURE SetCell*(x, y: INTEGER; ch: CHAR; fg, bg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartCell(p, x, y, ch, fg, bg) END
END SetCell;

PROCEDURE SetChar*(x, y: INTEGER; ch: CHAR);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartChar(p, x, y, ch) END
END SetChar;

PROCEDURE Size*(VAR width, height: INTEGER);
BEGIN width := buffer.w; height := buffer.h
END Size;

PROCEDURE GetCell*(x, y: INTEGER; VAR cell: Cell);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN cell := p.cells[y, x]
  ELSE cell.ch := emptyCh; cell.fg := 7; cell.bg := 0
  END
END GetCell;

PROCEDURE Flush*;
VAR x, y, X, Y: INTEGER;
  l, p: Part;
BEGIN
  l := buffer.first; Y := 0;
  WHILE l # NIL DO p := l; X := 0;
    WHILE p # NIL DO
      IF p.redraw OR buffer.redrawAll THEN
        FOR y := 0 TO p.h - 1 DO
          FOR x := 0 TO p.w - 1 DO
            IF p.updated[y, x] OR buffer.redrawAll THEN
              DrawCell(X + x, Y + y, p.cells[y, x]);
              p.updated[y, x] := FALSE
            END
          END
        END;
        p.redraw := FALSE
      END;
      INC(X, l.w); p := p.right
    END;
    INC(Y, l.h); l := l.down
  END;
  buffer.redrawAll := FALSE;
  Flip
END Flush;

PROCEDURE Sync*;
BEGIN
  buffer.redrawAll := TRUE;
  Flush
END Sync;

PROCEDURE NewPart(w, h: INTEGER): Part;
VAR p: Part;
  x, y: INTEGER;
BEGIN NEW(p); p.redraw := TRUE; p.down := NIL; p.right := NIL;
  p.w := w; p.h := h;
  FOR y := 0 TO h - 1 DO
    FOR x := 0 TO w - 1 DO
      p.cells[y, x].ch := emptyCh;
      p.cells[y, x].fg := 7;
      p.cells[y, x].bg := 0;
      p.updated[y, x] := TRUE
    END
  END
RETURN p END NewPart;

PROCEDURE ResizePart(p: Part; w, h: INTEGER);
VAR x, y: INTEGER;
BEGIN p.redraw := TRUE;
  FOR y := p.h TO h - 1 DO
    FOR x := p.w TO w - 1 DO
      p.cells[y, x].ch := emptyCh;
      p.cells[y, x].fg := 7;
      p.cells[y, x].bg := 0;
      p.updated[y, x] := TRUE
    END
  END;
  p.w := w; p.h := h
END ResizePart;

PROCEDURE InitBuffer;
VAR W, H, fw, fh: INTEGER;
BEGIN G.GetScreenSize(W, H); G.GetMonoFontSize(font, fw, fh);
  buffer.w := W DIV fw; buffer.h := H DIV fh;
  IF buffer.w > partW THEN buffer.w := partW END; (*!FIXME*)
  IF buffer.h > partH THEN buffer.h := partH END;
  buffer.first := NewPart(buffer.w, buffer.h);
  buffer.curX := -1; buffer.curY := -1; buffer.redrawAll := TRUE
END InitBuffer;

PROCEDURE ResizeBuffer;
VAR W, H, fw, fh, nw, nh: INTEGER;
BEGIN G.GetScreenSize(W, H); G.GetMonoFontSize(font, fw, fh);
  nw := W DIV fw; nh := H DIV fh;
  IF nw > partW THEN nw := partW END; (*!FIXME*)
  IF nh > partH THEN nh := partH END;
  IF (nw # buffer.w) OR (nh # buffer.h) THEN
    buffer.w := nw; buffer.h := nh;
    ResizePart(buffer.first, nw, nh)
  END
END ResizeBuffer;

PROCEDURE Set(s: SET);
VAR i: INTEGER;
  f: BOOLEAN;
BEGIN f := TRUE;
  Out.Char('{');
  FOR i := 0 TO 31 DO
    IF i IN s THEN
      IF f THEN f := FALSE ELSE Out.String(', ') END;
      Out.Int(i, 0)
    END
  END;
  Out.Char('}')
END Set;

PROCEDURE ToggleFS;
BEGIN
  IF ~(G.window IN G.GetWindowOptions(screen)) THEN
    G.SetWindowScale(screen, 1.0, 1.0)
  ELSE G.SetWindowScale(screen, 5/6, 1.0)
  END;
  G.ToggleFullscreen(screen)
END ToggleFS;

PROCEDURE WaitEvent*(VAR event: Event);
VAR e: G.Event;
  skip: BOOLEAN;
  fw, fh: INTEGER;
BEGIN
  REPEAT skip := TRUE;
  event.ch := '&';
    G.WaitEvent(e);
    IF e.type = G.mouseMove THEN
    ELSIF e.type = G.mouseDown THEN
    ELSIF e.type = G.mouseUp THEN
    ELSIF e.type = G.timer THEN
    ELSIF e.type = G.keyDown THEN
      IF (e.key = G.kEnter) & (e.mod * G.mAltKeys # {}) THEN ToggleFS; Sync END
    ELSIF e.type = G.char THEN
      event.type := key;
      event.key := e.key;
      event.ch := e.ch;
      event.mod := e.mod;
      skip := FALSE
    ELSIF e.type = G.resize THEN
      event.type := resize; G.GetMonoFontSize(font, fw, fh);
      event.w := e.w DIV fw; event.h := e.h DIV fh;
      ResizeBuffer;
      Sync;
      skip := FALSE
    ELSIF e.type = G.quit THEN
      event.type := quit;
      skip := FALSE
    END
  UNTIL ~skip
END WaitEvent;

PROCEDURE Close*;
BEGIN
  font := NIL;
  G.Close
END Close;

PROCEDURE LoadFont(): BOOLEAN;
VAR f: G.Font;
BEGIN
  f := G.LoadFont('mainfont');
  IF f # NIL THEN 
    IF f IS G.MonoFont THEN font := f(G.MonoFont)
    ELSE Out.String('The font is not monospaced.'); Out.Ln
    END
  ELSE Out.String('Could not load font.'); Out.Ln
  END
RETURN font # NIL END LoadFont;

PROCEDURE ExpandColor(color: INTEGER; VAR r, g, b: INTEGER);
BEGIN
  CASE color OF
     0: b :=   0; g :=   0; r :=   0
  |  1: b :=  90; g :=   0; r :=   0
  |  2: b :=   0; g := 176; r :=   0
  |  3: b := 176; g := 176; r :=   0
  |  4: b :=   0; g :=   0; r := 176
  |  5: b := 176; g :=   0; r := 176
  |  6: b :=   0; g :=  85; r := 176
  |  7: b := 176; g := 176; r := 176
  |  8: b :=  85; g :=  85; r :=  85
  |  9: b := 255; g :=  85; r :=  85
  | 10: b :=  85; g := 255; r :=  85
  | 11: b := 255; g := 255; r :=  85
  | 12: b :=  85; g :=  85; r := 255
  | 13: b := 255; g :=  85; r := 255
  | 14: b :=  85; g := 255; r := 255
  | 15: b := 255; g := 255; r := 255
  END
END ExpandColor;

PROCEDURE InitColors;
VAR i, r, g, b: INTEGER;
BEGIN
  FOR i := 0 TO nofcolors - 1 DO
    ExpandColor(i, r, g, b);
    G.MakeCol(colors[i], r, g, b)
  END;
END InitColors;

PROCEDURE SetTitle*(title: ARRAY OF CHAR);
BEGIN wantTitle := title
END SetTitle;

PROCEDURE SetZoomF*(zoom: REAL);
BEGIN wantZoom := zoom; G.SetZoomF(zoom)
END SetZoomF;

PROCEDURE SetZoom*(zoom: INTEGER);
BEGIN wantZoom := FLT(zoom); G.SetZoom(zoom)
END SetZoom;

PROCEDURE SetScale*(x, y: REAL);
BEGIN wantScaleX := x; wantScaleY := y; G.SetScale(x, y)
END SetScale;

PROCEDURE MakeGraphSettings(): SET;
VAR s: SET;
BEGIN s := {};
  IF fullscreen IN settings THEN INCL(s, G.fullscreen)
  ELSE INCL(s, G.topleft);
    IF window IN settings THEN INCL(s, G.window) END
  END;
  IF exact IN settings THEN INCL(s, G.exact) END;
  IF ~(sharp IN settings) THEN INCL(s, G.smooth) END;
  IF software IN settings THEN INCL(s, G.software) END;
  IF initMouse IN settings THEN INCL(s, G.initMouse) END;
  IF center IN settings THEN INCL(s, G.center) END;
  IF resizable IN settings THEN INCL(s, G.resizable) END;
  IF maximized IN settings THEN INCL(s, G.maximized) END;
  IF minimized IN settings THEN INCL(s, G.minimized) END;
  IF frameless IN settings THEN INCL(s, G.frameless) END;
RETURN s END MakeGraphSettings;

PROCEDURE InitScreen;
VAR W, H, dw, dh, fw, fh: INTEGER;
BEGIN G.GetMonoFontSize(font, fw, fh); G.GetDesktopResolution(dw, dh);
  W := wantW * fw; H := wantH * fh;

  IF (wantScaleX # 0.0) & (wantScaleY # 0.0) THEN
    G.SetScale(wantScaleX, wantScaleY)
  ELSIF ((fullscreen IN settings) OR (wantZoom >= 6/5 - 0.01)) &
        ~(sharp IN settings) & (dw >= W * 6/5 - 0.01) THEN
    G.SetScale(5/6, 1.0)
  END;

  G.SetSizeStep(fw, fh);
  screen := G.NewWindow(-1, -1, W, H, wantTitle, MakeGraphSettings())
END InitScreen;

PROCEDURE Init*;
BEGIN Done := FALSE;
  G.Settings(-1, -1, {G.manual});
  G.Init;
  IF G.Done & LoadFont() THEN
    InitScreen;
    InitColors;
    InitBuffer;
    Done := TRUE
  END
END Init;

PROCEDURE Settings*(w, h: INTEGER; flags: SET);
BEGIN wantW := w; wantH := h;
  IF {fullscreen, window} * flags = {} THEN INCL(flags, fullscreen)
  ELSIF fullscreen IN flags THEN EXCL(flags, window)
  END;
  settings := flags
END Settings;

BEGIN wantW := 80; wantH := 25; wantScaleX := 0.0; wantScaleY := 0.0;
  settings := {fullscreen}; Done := FALSE
END TermBox.
