MODULE TermBox;
(** Termbox is a module for creating cross-platform text-based interfaces *)
IMPORT G := Graph, Strings, Int, Out, Platform;

CONST
  partW = 512;
  partH = 256;
  emptyCh = ' ';
  nofcolors = 16;
  cursorTickSpeed = 1 / 2;
  flipSpeed = 1 / 60;
  stdW = 80;
  stdH = 25;

  (** Flags for procedure Settings **)
  (** The flags only work if TermBox works via module Graph *)
  fullscreen*  =  1; (** Run in fullscreen if possible *)
  window*      =  2; (** Run in window if possible *)
  exact*       =  3; (** Use the exact given pixel size *)
  sharp*       =  4; (** Use integer multitudes of hardware pixels *)
  software*    =  5; (** Render graphics in software *)
  noMouse*     =  6; (** Hide mouse pointer *)
  center*      =  7; (** Center the window *)
  resizable*   =  8; (** Make window resizable *)
  maximized*   =  9; (** Maximize window on startup *)
  minimized*   = 10; (** Minimize window on startup *)
  frameless*   = 11; (** Hide window frames *)

  (** Event.type possible values **)
  noEvent* =  0; (** No event occurred (used only internally) *)
  quit*    =  1; (** User closed the window (works only if Graph is used) *)
  key*     =  2; (** Key press *)
  mouse*   =  3; (** Mouse button click, release or drag *)
  resize*  = 11; (** Terminal window changed its size *)
  timer*   = 14; (** Tick of the TermBox timer *)
  error*   = 15; (** Error event *)

  (** Key Codes **)
  kA*          = 1;
  kB*          = 2;
  kC*          = 3;
  kD*          = 4;
  kE*          = 5;
  kF*          = 6;
  kG*          = 7;
  kH*          = 8;
  kI*          = 9;
  kJ*          = 10;
  kK*          = 11;
  kL*          = 12;
  kM*          = 13;
  kN*          = 14;
  kO*          = 15;
  kP*          = 16;
  kQ*          = 17;
  kR*          = 18;
  kS*          = 19;
  kT*          = 20;
  kU*          = 21;
  kV*          = 22;
  kW*          = 23;
  kX*          = 24;
  kY*          = 25;
  kZ*          = 26;
  k0*          = 27;
  k1*          = 28;
  k2*          = 29;
  k3*          = 30;
  k4*          = 31;
  k5*          = 32;
  k6*          = 33;
  k7*          = 34;
  k8*          = 35;
  k9*          = 36;
  k0Pad*       = 37;
  k1Pad*       = 38;
  k2Pad*       = 39;
  k3Pad*       = 40;
  k4Pad*       = 41;
  k5Pad*       = 42;
  k6Pad*       = 43;
  k7Pad*       = 44;
  k8Pad*       = 45;
  k9Pad*       = 46;
  kF1*         = 47;
  kF2*         = 48;
  kF3*         = 49;
  kF4*         = 50;
  kF5*         = 51;
  kF6*         = 52;
  kF7*         = 53;
  kF8*         = 54;
  kF9*         = 55;
  kF10*        = 56;
  kF11*        = 57;
  kF12*        = 58;
  kEsc*        = 59;
  kTilde*      = 60;
  kMinus*      = 61;
  kEquals*     = 62;
  kBackspace*  = 63;
  kTab*        = 64;
  kOpenBrace*  = 65;
  kCloseBrace* = 66;
  kEnter*      = 67;
  kColon*      = 68;
  kQuote*      = 69;
  kBackslash*  = 70;
  kBackslash2* = 71;
  kComma*      = 72;
  kStop*       = 73;
  kSlash*      = 74;
  kSpace*      = 75;
  kInsert*     = 76;
  kDel*        = 77;
  kHome*       = 78;
  kEnd*        = 79;
  kPgUp*       = 80;
  kPgDn*       = 81;
  kLeft*       = 82;
  kRight*      = 83;
  kUp*         = 84;
  kDown*       = 85;
  kSlashPad*   = 86;
  kAsterisk*   = 87;
  kMinusPad*   = 88;
  kPlusPad*    = 89;
  kDelPad*     = 90;
  kEnterPad*   = 91;
  kPrtScr*     = 92;
  kPause*      = 93;
  kEqualsPad*  = 103;
  kBackquote*  = 104;
  kSemicolon2* = 105;
  kCommand*    = 106;

  kBack*       = 107;
  kVolumeUp*   = 108;
  kVolumeDown* = 109;

  kModifers*   = 215;

  kLShift*     = 215;
  kRShift*     = 216;
  kLCtrl*      = 217;
  kRCtrl*      = 218;
  kAlt*        = 219;
  kAltGr*      = 220;
  kLMeta*      = 221;
  kRMeta*      = 222;
  kMenu*       = 223;
  kScrLock*    = 224;
  kNumLock*    = 225;
  kCapsLock*   = 226;

  kMax*        = 226; (** Maximum key code *)

  (** Key Modifiers Set - Event.mod **)
  (** The set of modifier keys such as Alt or Ctrl *)
  mShift*      =  0; (** SHIFT *)
  mCtrl*       =  1; (** CTRL *)
  mAlt*        =  2; (** ALT *)
  mLwin*       =  3; (** Left Windows Key *)
  mRwin*       =  4; (** Right Windows Key *)
  mMenu*       =  5; (** Menu Key *)
  mAltGr*      =  6; (** ALT-Graph (Right ALT) *)
  mCommand*    =  7; (** Command key (on Mac) *)
  mScrolllock* =  8; (** Scroll Lock *)
  mNumlock*    =  9; (** Num Lock *)
  mCapslock*   = 10; (** Caps Lock *)

  (** Characters **)
  (** Useful constants for pseudo-graphical box drawing *)
  lineHor*         = 2500X;
  lineVert*        = 2502X;

  lineUpRight*     = 2514X;
  lineUpLeft*      = 2518X;
  lineDownLeft*    = 2510X;
  lineDownRight*   = 250CX;

  lineVertRight*   = 251CX;
  lineVertLeft*    = 2524X;
  lineHorUp*       = 2534X;
  lineHorDown*     = 252CX;
  lineCross*       = 253CX;

  doubleHor*       = 2550X;
  doubleVert*      = 2551X;

  doubleUpRight*   = 255AX;
  doubleUpLeft*    = 255DX;
  doubleDownLeft*  = 2557X;
  doubleDownRight* = 2554X;

  doubleVertRight* = 2560X;
  doubleVertLeft*  = 2563X;
  doubleHorUp*     = 2569X;
  doubleHorDown*   = 2566X;
  doubleCross*     = 256CX;

  doubleUpLineRight*   = 2559X;
  doubleUpLineLeft*    = 255CX;
  doubleDownLineRight* = 2553X;
  doubleDownLineLeft*  = 2556X;
  doubleLeftLineUp*    = 255BX;
  doubleLeftLineDown*  = 2555X;
  doubleRightLineUp*   = 2558X;
  doubleRightLineDown* = 2552X;

  doubleVertLineLeft*  = 2562X;
  doubleVertLineRight* = 255FX;
  doubleVertLineHor*   = 256BX;
  doubleHorLineUp*     = 2567X;
  doubleHorLineDown*   = 2564X;
  doubleHorLineVert*   = 256AX;

  lightShade*      = 2591X;
  mediumShade*     = 2592X;
  darkShade*       = 2593X;

  triangleUp*    = 1EX (*25B2X*);
  triangleDown*  = 1FX (*25BCX*);
  triangleRight* = 10X (*25BAX*);
  triangleLeft*  = 11X (*25C4X*);

  arrowUp*        = 18X (*2191X*);
  arrowDown*      = 19X (*2193X*);
  arrowRight*     = 1AX (*2192X*);
  arrowLeft*      = 1BX (*2190X*);
  arrowLeftRight* = 1DX (*2194X*);
  arrowUpDown*    = 12X (*2195X*);

  blackSquare*    = 25A0X;
  upperHalfBlock* = 2580X;
  lowerHalfBlock* = 2584X;
  fullBlock*      = 2588X;
  leftHalfBlock*  = 258CX;
  rightHalfBlock* = 2590X;

TYPE
  Event* = RECORD (** Record that holds information on the event occurred *)
    type*: INTEGER;   (** One of Event.type constants (see above) *)
    x*, y*: INTEGER;  (** For mouse presses, releases and drags *)
    w*, h*: INTEGER;  (** Size of screen in cells on resize *)
    button*: INTEGER; (** Mouse button that is pressed, 0 means release *)
    key*: INTEGER;    (** Physical key code of the key pressed or released *)
    ch*: CHAR;        (** The typed character on key press *)
    mod*: SET         (** Key modifiers set (see above) *)
  END;

  Cell = RECORD
    ch, oldCh: CHAR;
    fg, oldFg: INTEGER;
    bg, oldBg: INTEGER;
    updated: INTEGER (** >0 means need to redraw, 2 means redraw in any case *)
  END;

  Part = POINTER TO PartDesc; (** Part of screen buffer *)
  PartDesc = RECORD
    cells: ARRAY partH, partW OF Cell;
    w, h: INTEGER;   (** Actually used sizes of array *)
    redraw: BOOLEAN; (** TRUE if any cell needs to be redrawn *)
    down, right: Part
  END;

  Buffer = RECORD (** Screen buffer *)
    first: Part;
    w, h: INTEGER;
    redrawAll: BOOLEAN
  END;

VAR
  t0, t1: REAL;

  wantTitle: ARRAY 256 OF CHAR; (** Assigned in procedure SetTitle *)
  wantZoom: REAL;
  wantW, wantH: INTEGER;
  wantScaleX, wantScaleY: REAL;
  settings: SET;
  buffer: Buffer;
  iconFile, fontFile: ARRAY 256 OF CHAR;

  processingEvent: BOOLEAN;
  skipEnter: BOOLEAN; (** If TRUE, skip the G.char event with key = enter *)
  mouseDown: BOOLEAN;
  mouseShown: BOOLEAN;
  mouseX, mouseY, mouseButton: INTEGER;
  curX, curY: INTEGER; (** Text cursor position *)
  cursorShown: BOOLEAN; (** TRUE if text cursor is show while it is blinking *)
  cursorTimer: G.Timer; (** Text cursor tick timer *)
  flipTimer: G.Timer; (** Frame change timer *)
  userTimer: G.Timer; (** User timer set by StartTimer *)

  needFlip: INTEGER;
  screen: G.Window;
  font: G.MonoFont;
  colors: ARRAY nofcolors OF G.Color;

  Done*: BOOLEAN; (** TRUE on successful initialization, FALSE on error *)

PROCEDURE SetPartCellUpdated(p: Part; VAR cell: Cell);
BEGIN
  IF cell.updated # 2 THEN
    IF (cell.ch # cell.oldCh) OR
       (cell.fg # cell.oldFg) OR
       (cell.bg # cell.oldBg)
    THEN cell.updated := 1; p.redraw := TRUE
    ELSE cell.updated := 0
    END
  END
END SetPartCellUpdated;

PROCEDURE ClearUpdated(VAR cell: Cell);
BEGIN cell.updated := 0; cell.oldCh := cell.ch;
  cell.oldFg := cell.fg; cell.oldBg := cell.bg
END ClearUpdated;

PROCEDURE SetPartCell(p: Part; x, y: INTEGER; ch: CHAR; fg, bg: INTEGER);
BEGIN
  p.cells[y, x].ch := ch;
  p.cells[y, x].fg := fg MOD nofcolors;
  p.cells[y, x].bg := bg MOD nofcolors;
  SetPartCellUpdated(p, p.cells[y, x])
END SetPartCell;

PROCEDURE SetPartChar(p: Part; x, y: INTEGER; ch: CHAR);
BEGIN
  p.cells[y, x].ch := ch;
  SetPartCellUpdated(p, p.cells[y, x])
END SetPartChar;

PROCEDURE SetPartFg(p: Part; x, y, fg: INTEGER);
BEGIN
  p.cells[y, x].fg := fg MOD nofcolors;
  SetPartCellUpdated(p, p.cells[y, x])
END SetPartFg;

PROCEDURE SetPartBg(p: Part; x, y, bg: INTEGER);
BEGIN
  p.cells[y, x].bg := bg MOD nofcolors;
  SetPartCellUpdated(p, p.cells[y, x])
END SetPartBg;

PROCEDURE GetPart(S: Buffer; VAR x, y: INTEGER): Part;
VAR p: Part;
BEGIN
  IF (0 <= x) & (x < S.w) & (0 <= y) & (y < S.h) THEN p := S.first;
    WHILE (p # NIL) & (y >= p.h) DO DEC(y, p.h); p := p.down END;
    WHILE (p # NIL) & (x >= p.w) DO DEC(x, p.w); p := p.right END
  ELSE p := NIL
  END
RETURN p END GetPart;

(** Clears the internal back buffer with foreground `fg` and background `bg` *)
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

(** Clears the internal back buffer with a grey foreground and a
    black background *)
PROCEDURE Clear*;
BEGIN ClearTo(7, 0)
END Clear;

PROCEDURE InvertColor(color: INTEGER): INTEGER;
BEGIN IF color >= 8 THEN color := 15 - color ELSE color := 7 - color END
RETURN color END InvertColor;

PROCEDURE DrawCell(x, y: INTEGER; cell: Cell);
VAR X, Y, w, h, fg, bg: INTEGER;
BEGIN
  IF ~mouseShown OR (x # mouseX) OR (y # mouseY) THEN
    fg := cell.fg; bg := cell.bg
  ELSE fg := InvertColor(cell.fg); bg := InvertColor(cell.bg)
  END;
  w := font.charW; h := font.charH; X := x * w; Y := y * h;
  G.FillRect(X, Y, X + w - 1, Y + h - 1, colors[bg MOD nofcolors]);
  G.DrawChar(cell.ch, X, Y, font, colors[fg MOD nofcolors]);
  IF cursorShown & (x = curX) & (y = curY) THEN
    G.FillRect(X, Y + h - 3, X + w - 1, Y + h - 2, colors[fg MOD nofcolors])
  END
END DrawCell;

PROCEDURE GetMousePos(e: G.Event; VAR x, y: INTEGER);
BEGIN
  x := e.x DIV font.charW; y := e.y DIV font.charH;
  IF x < 0 THEN x := 0 ELSIF x >= buffer.w THEN x := buffer.w - 1 END;
  IF y < 0 THEN y := 0 ELSIF y >= buffer.h THEN y := buffer.h - 1 END
END GetMousePos;

PROCEDURE UpdateCell(x, y: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN p.cells[y, x].updated := 2; p.redraw := TRUE END
END UpdateCell;

PROCEDURE Flip(forse: BOOLEAN);
BEGIN
  IF ~G.HasEvents() OR forse THEN G.Flip; needFlip := 0
  ELSE INC(needFlip)
  END
END Flip;

(** Synchronizes the internal back buffer with the terminal.
     Nothing will change on the screen until Flush or Sync is called *)
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
            IF buffer.redrawAll OR (p.cells[y, x].updated # 0) THEN
              DrawCell(X + x, Y + y, p.cells[y, x]);
              ClearUpdated(p.cells[y, x])
            END
          END
        END;
        p.redraw := FALSE
      END;
      INC(X, l.w); p := p.right
    END;
    INC(Y, l.h); l := l.down
  END;
  IF buffer.redrawAll THEN Flip(TRUE); buffer.redrawAll := FALSE
  ELSE Flip(FALSE)
  END
END Flush;

(** Sync comes handy when something causes desync between TermBox's
    understanding of a terminal buffer and the reality. Such as a third party
    process. Sync forces a complete resync between TermBox and the terminal,
    it may not be visually pretty though. *)
PROCEDURE Sync*;
BEGIN
  buffer.redrawAll := TRUE;
  Flush
END Sync;

PROCEDURE MoveMouse(x, y: INTEGER);
BEGIN
  IF mouseShown THEN UpdateCell(mouseX, mouseY) END;
  mouseX := x; mouseY := y;
  IF mouseShown THEN UpdateCell(x, y); Flush END
END MoveMouse;

PROCEDURE ToggleFS;
BEGIN
  IF ~(G.window IN G.GetWindowOptions(screen)) THEN
    IF wantZoom >= 6/5 - 0.01 THEN G.SetNewWindowScale(5/6, 1.0)
    ELSE G.SetNewWindowScale(1.0, 1.0)
    END;
    G.SetWindowOption(screen, G.topleft, TRUE)
  ELSE G.SetNewWindowScale(5/6, 1.0);
    G.SetWindowOption(screen, G.topleft, FALSE)
  END;
  G.ToggleFS(screen);
  Sync
END ToggleFS;

(** Returns TRUE if fullscreen mode is currently used *)
PROCEDURE IsFS*(): BOOLEAN;
RETURN ~(G.window IN G.GetWindowOptions(screen))
END IsFS;

(** Switch to window mode *)
PROCEDURE SwitchToWindow*;
BEGIN IF IsFS() THEN ToggleFS END
END SwitchToWindow;

(** Switch to fullscreen mode *)
PROCEDURE SwitchToFS*;
BEGIN IF ~IsFS() THEN ToggleFS END
END SwitchToFS;

PROCEDURE ResetCell(VAR cell: Cell);
BEGIN
  cell.ch := emptyCh; cell.fg := 7; cell.bg := 0;
  cell.oldCh := cell.ch; cell.oldFg := cell.fg; cell.oldBg := cell.bg;
  cell.updated := 2
END ResetCell;

PROCEDURE NewPart(w, h: INTEGER): Part;
VAR p: Part;
  x, y: INTEGER;
BEGIN NEW(p); p.redraw := TRUE; p.down := NIL; p.right := NIL;
  p.w := w; p.h := h;
  FOR y := 0 TO h - 1 DO
    FOR x := 0 TO w - 1 DO
      ResetCell(p.cells[y, x])
    END
  END
RETURN p END NewPart;

PROCEDURE ResizePart(p: Part; w, h: INTEGER);
VAR x0, x, y: INTEGER;
BEGIN p.redraw := TRUE;
  FOR y := 0 TO h - 1 DO
    IF y < p.h THEN x0 := p.w ELSE x0 := 0 END;
    FOR x := x0 TO w - 1 DO
      p.cells[y, x].ch := emptyCh;
      p.cells[y, x].fg := 7;
      p.cells[y, x].bg := 0;
      p.cells[y, x].updated := 2
    END
  END;
  p.w := w; p.h := h
END ResizePart;

PROCEDURE InitBuffer;
VAR W, H: INTEGER;
BEGIN G.GetScreenSize(W, H);
  buffer.w := W DIV font.charW; buffer.h := H DIV font.charH;
  IF buffer.w > partW THEN buffer.w := partW END; (*!FIXME*)
  IF buffer.h > partH THEN buffer.h := partH END;
  buffer.first := NewPart(buffer.w, buffer.h);
  curX := -1; curY := -1; buffer.redrawAll := TRUE
END InitBuffer;

PROCEDURE ResizeBuffer;
VAR W, H, nw, nh: INTEGER;
BEGIN G.GetScreenSize(W, H);
  nw := W DIV font.charW; nh := H DIV font.charH;
  IF nw > partW THEN nw := partW END; (*!FIXME*)
  IF nh > partH THEN nh := partH END;
  IF (nw # buffer.w) OR (nh # buffer.h) THEN
    buffer.w := nw; buffer.h := nh;
    ResizePart(buffer.first, nw, nh)
  END
END ResizeBuffer;

PROCEDURE ParseEvent(e: G.Event; VAR event: Event);
VAR fw, fh: INTEGER;
BEGIN
  processingEvent := TRUE;
  IF e.type = G.mouseMove THEN GetMousePos(e, event.x, event.y);
    event.type := noEvent;
    IF (event.x # mouseX) OR (event.y # mouseY) THEN
      IF mouseDown THEN event.type := mouse;
        event.button := mouseButton
      END;
      MoveMouse(event.x, event.y)
    END
  ELSIF e.type = G.timer THEN
    IF e.timer = flipTimer THEN
      event.type := noEvent;
      IF needFlip # 0 THEN G.Flip; needFlip := 0 END
    ELSIF e.timer = cursorTimer THEN
      event.type := noEvent;
      IF curX >= 0 THEN
        cursorShown := ~cursorShown;
        UpdateCell(curX, curY);
        Flush
      END
    ELSE
      event.type := timer
    END
  ELSIF e.type = G.mouseDown THEN event.type := mouse;
    mouseDown := TRUE; GetMousePos(e, event.x, event.y);
    MoveMouse(event.x, event.y);
    mouseButton := e.button; event.button := mouseButton;
  ELSIF e.type = G.mouseUp THEN event.type := mouse;
    mouseDown := FALSE; GetMousePos(e, event.x, event.y);
    MoveMouse(event.x, event.y);
    event.button := 0; (* 0 means release *)
  ELSIF e.type = G.char THEN
    IF (e.key = G.kEnter) & (e.mod * {G.mMenu, G.mAlt, G.mAltGr} # {}) THEN
      ToggleFS; skipEnter := TRUE
    ELSE event.type := key;
      event.key := e.key;
      event.ch := e.ch;
      event.mod := e.mod
    END
  ELSIF e.type = G.resize THEN
    event.type := resize;
    event.w := e.w DIV font.charW; event.h := e.h DIV font.charH;
    ResizeBuffer;
    Sync
  ELSIF e.type = G.quit THEN event.type := quit
  ELSE event.type := noEvent
  END;
  processingEvent := FALSE
END ParseEvent;

PROCEDURE WaitAndParseEvent(VAR event: Event);
VAR E: G.Event;
BEGIN
  IF (needFlip # 0) & ~G.PeekEvent(E) THEN G.Flip; needFlip := 0 END;
  G.WaitEvent(E);
  ParseEvent(E, event)
END WaitAndParseEvent;

PROCEDURE PeekAndParseEvent(VAR event: Event): BOOLEAN;
VAR E: G.Event;
  got: BOOLEAN;
BEGIN
  IF G.PeekEvent(E) THEN
    ParseEvent(E, event); got := TRUE;
    IF event.type = noEvent THEN G.DropNextEvent END
  ELSE
    G.DropNextEvent; got := FALSE
  END
RETURN got END PeekAndParseEvent;

(** Waits until the next event, copies it in `event`
    and removes it from the queue *)
PROCEDURE WaitEvent*(VAR event: Event);
BEGIN REPEAT WaitAndParseEvent(event) UNTIL event.type # noEvent
END WaitEvent;

(** Copies the next event in the queue to `event` but does not remove
    it from the queue. *)
PROCEDURE PeekEvent*(VAR event: Event): BOOLEAN;
VAR got: BOOLEAN;
BEGIN
  got := PeekAndParseEvent(event);
  WHILE got & (event.type = noEvent) DO
    got := PeekAndParseEvent(event)
  END
RETURN got END PeekEvent;

(** Returns TRUE if there are events in the events queue *)
PROCEDURE HasEvents*(): BOOLEAN;
VAR e: Event;
  x: BOOLEAN;
BEGIN
  IF processingEvent THEN x := FALSE ELSE x := PeekEvent(e) END
RETURN x END HasEvents;

(** Moves the text input cursor to cell (x; y) *)
PROCEDURE SetCursor*(x, y: INTEGER);
BEGIN
  IF (x # curX) OR (y # curY) THEN
    UpdateCell(curX, curY);
    IF (0 <= x) & (x < buffer.w) & (0 <= y) & (y < buffer.h) THEN
      curX := x; curY := y;
      UpdateCell(x, y)
    ELSE curX := -1; curY := -1
    END;
    cursorShown := TRUE;
    G.StopTimer(cursorTimer);
    G.StartTimer(cursorTimer)
  END
END SetCursor;

(** Hides the text input cursor (moves it off the screen) *)
PROCEDURE HideCursor*;
BEGIN SetCursor(-1, -1)
END HideCursor;

(** Shows the mouse cursor *)
PROCEDURE ShowMouse*;
BEGIN IF ~mouseShown THEN mouseShown := TRUE; UpdateCell(mouseX, mouseY) END
END ShowMouse;

(** Hides the mouse cursor *)
PROCEDURE HideMouse*;
BEGIN IF mouseShown THEN mouseShown := FALSE; UpdateCell(mouseX, mouseY) END
END HideMouse;

(** Sets background color `bg` for the cell at position (x; y) *)
PROCEDURE SetBg*(x, y, bg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartBg(p, x, y, bg) END
END SetBg;

(** Sets foreground color `fg` for the cell at position (x; y) *)
PROCEDURE SetFg*(x, y, fg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartFg(p, x, y, fg) END
END SetFg;

(** Fills the cell at (x; y) with character `ch` and the given
    foreground (fg) and background (bg) colors *)
PROCEDURE SetCell*(x, y: INTEGER; ch: CHAR; fg, bg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartCell(p, x, y, ch, fg, bg) END
END SetCell;

(** Fill a rectangular area of characters with `ch` using the foreground (fg)
    and background (bg) colors. The top-left corner of the area is (x; y),
    width is `w` and height is `h` *)
PROCEDURE Fill*(x, y, w, h: INTEGER; ch: CHAR; fg, bg: INTEGER);
VAR X, Y: INTEGER;
BEGIN
  FOR Y := y TO y + h - 1 DO
    FOR X := x TO x + w - 1 DO
      SetCell(X, Y, ch, fg, bg)
    END
  END
END Fill;

(** Writes at most `limit` characters of `s` in a line starting at position
    (x; y) on to the terminal using the given foreground (fg) and
    background (bg) colors *)
PROCEDURE Print*(x, y, limit: INTEGER; s: ARRAY OF CHAR; fg, bg: INTEGER);
VAR i, w, h: INTEGER;
BEGIN i := 0;
  WHILE (s[i] # 0X) & (i # limit) & (x < buffer.w) DO
    SetCell(x, y, s[i], fg, bg); INC(i); INC(x)
  END
END Print;

(** Sets the character of the cell at (x; y) *)
PROCEDURE SetChar*(x, y: INTEGER; ch: CHAR);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartChar(p, x, y, ch) END
END SetChar;

(** Returns size of the terminal window in characters *)
PROCEDURE Size*(VAR width, height: INTEGER);
BEGIN width := buffer.w; height := buffer.h
END Size;

(** Given the (x; y) coordinate, returns data of the
    corresponding terminal cell *)
PROCEDURE GetCell*(x, y: INTEGER; VAR ch: CHAR; VAR fg, bg: INTEGER);
VAR p: Part;
  cell: Cell;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN cell := p.cells[y, x];
    ch := cell.ch; fg := cell.fg; bg := cell.bg
  ELSE ch := emptyCh; fg := 0; bg := 0
  END
END GetCell;

(** Delay for `ms` milliseconds *)
PROCEDURE Delay*(ms: INTEGER);
BEGIN G.Delay(ms)
END Delay;

(** Closes TermBox *)
PROCEDURE Close*;
BEGIN
  font := NIL;
  G.Close
END Close;

PROCEDURE PreloadFont(): BOOLEAN;
VAR f: G.Font;
BEGIN
  f := G.LoadFontInfo(fontFile);
  IF f # NIL THEN 
    IF f IS G.MonoFont THEN font := f(G.MonoFont)
    ELSE Out.String('TermBox: The font is not monospaced.'); Out.Ln
    END
  ELSE Out.String('TermBox: Could not load font "');
    Out.String(fontFile); Out.String('".'); Out.Ln
  END
RETURN font # NIL END PreloadFont;

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

(** Sets the title of the window *)
PROCEDURE SetTitle*(title: ARRAY OF CHAR);
BEGIN wantTitle := title
END SetTitle;

(** Sets zoom as a real number. *)
PROCEDURE SetZoomF*(zoom: REAL);
BEGIN wantZoom := zoom; G.SetZoomF(zoom)
END SetZoomF;

(** Sets zoom as an integer.
     SetZoom(2) will make virtual pixels two times bigger in size *)
PROCEDURE SetZoom*(zoom: INTEGER);
BEGIN wantZoom := FLT(zoom); G.SetZoom(zoom)
END SetZoom;

(** Sets horizontal (x) and vertical (y) scale factors.
     Call SetScale(2.0, 1.0) to two make pixels times wider *)
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
  IF noMouse IN settings THEN INCL(s, G.noMouse) END;
  IF center IN settings THEN INCL(s, G.center) END;
  IF resizable IN settings THEN INCL(s, G.resizable) END;
  IF maximized IN settings THEN INCL(s, G.maximized) END;
  IF minimized IN settings THEN INCL(s, G.minimized) END;
  IF frameless IN settings THEN INCL(s, G.frameless) END;
RETURN s END MakeGraphSettings;

PROCEDURE InitIcon;
VAR b: G.Bitmap;
BEGIN
  b := G.LoadBitmap(iconFile);
  IF b # NIL THEN G.SetWindowIcon(screen, b) END
END InitIcon;

(** Returns Graph.Window object of the terminal (only when Graph is used) *)
PROCEDURE GetWindow*(): G.Window;
RETURN screen END GetWindow;

PROCEDURE InitScreen;
VAR W, H, dw, dh: INTEGER;
BEGIN G.GetDesktopResolution(dw, dh);
  W := wantW * font.charW; H := wantH * font.charH;

  IF (wantScaleX # 0.0) & (wantScaleY # 0.0) THEN
    G.SetScale(wantScaleX, wantScaleY)
  ELSIF ((fullscreen IN settings) OR (wantZoom >= 6.0/5.0 - 0.01)) &
        ~(sharp IN settings) & (FLT(dw) >= FLT(W) * 6.0/5.0 - 0.01) THEN
    G.SetScale(5/6, 1.0)
  END;

  G.SetSizeStep(font.charW, font.charH);
  screen := G.NewWindow(-1, -1, W, H, wantTitle, MakeGraphSettings());
  G.ShowMouse(noMouse IN settings);
  G.SetWindowFullscreenSize(screen, W, H);
  InitIcon
END InitScreen;

(** Start TermBox timer. The timer event will be created every `speed`
    fraction of a second.
     Call StartTimer(1/30) for 30 timer events every second *)
PROCEDURE StartTimer*(speed: REAL);
BEGIN
  userTimer := G.NewTimer(speed);
  G.StartTimer(userTimer)
END StartTimer;

PROCEDURE InitTimers;
BEGIN
  cursorShown := TRUE;
  cursorTimer := G.NewTimer(cursorTickSpeed);
  G.StartTimer(cursorTimer);

  flipTimer := G.NewTimer(flipSpeed);
  G.StartTimer(flipTimer)
END InitTimers;

(** Initializes TermBox. Sets Done to TRUE on success, FALSE otherwise *)
PROCEDURE Init*;
VAR opt: SET;
BEGIN Done := FALSE;
  IF noMouse IN settings THEN opt := {G.noMouse} ELSE opt := {} END;
  G.Settings(-1, -1, opt + {G.manual});
  G.Init;
  IF G.Done & PreloadFont() THEN
    InitScreen;
    G.LoadFontBitmap(font);
    IF font.loaded THEN
      InitColors;
      InitBuffer;
      InitTimers;
      mouseDown := FALSE;
      mouseShown := ~(noMouse IN settings);
      skipEnter := FALSE;
      needFlip := 0;
      processingEvent := FALSE;
      Done := TRUE
    ELSE G.CloseWindow(screen)
    END
  END
END Init;

(** Sets width and height of graphical window and settings flags (for Graph) *)
PROCEDURE Settings*(w, h: INTEGER; flags: SET);
BEGIN
  IF w = 0 THEN wantW := stdW ELSE wantW := w END;
  IF h = 0 THEN wantH := stdH ELSE wantH := h END;
  IF {fullscreen, window} * flags = {} THEN INCL(flags, fullscreen)
  ELSIF fullscreen IN flags THEN EXCL(flags, window)
  END;
  settings := flags
END Settings;

(** Sets the terminal icon file name (if Graph is used) *)
PROCEDURE SetIconFile*(s: ARRAY OF CHAR);
BEGIN iconFile := s
END SetIconFile;

(** Sets the font file name for the terminal (if Graph is used) *)
PROCEDURE SetFontFile*(s: ARRAY OF CHAR);
BEGIN fontFile := s
END SetFontFile;

BEGIN wantW := stdW; wantH := stdH; wantScaleX := 0.0; wantScaleY := 0.0;
  settings := {fullscreen}; Done := FALSE;
  iconFile := '../Data/Images/Icon.png';
  fontFile := '../Data/Fonts/Main';
END TermBox.
