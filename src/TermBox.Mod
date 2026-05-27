MODULE TermBox;
(** Termbox VT100 backend — works directly in a terminal via escape sequences.
    Provides the same public interface as the Graph-based TermBoxG. *)
IMPORT TermVT, Utf8, Out, SYSTEM, Strings;

CONST
  partW = 512;
  partH = 256;
  emptyCh = ' ';
  nofcolors = 16;
  stdW = 80;
  stdH = 25;

  (** Flags for procedure Settings — no-op in VT100 mode *)
  fullscreen*  =  1;
  window*      =  2;
  exact*       =  3;
  sharp*       =  4;
  software*    =  5;
  noMouse*     =  6;
  center*      =  7;
  resizable*   =  8;
  maximized*   =  9;
  minimized*   = 10;
  frameless*   = 11;

  (** Event.type possible values **)
  noEvent* =  0; (** No event occurred (used only internally) *)
  quit*    =  1; (** Quit event (Ctrl+C or equivalent) *)
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

  (** Mouse wheel pseudo-buttons used in Event.button *)
  kWheelUp*   = 4;
  kWheelDown* = 5;

  (** Key Modifiers Set - Event.mod **)
  mShift*      =  0; (** SHIFT *)
  mCtrl*       =  1; (** CTRL *)
  mAlt*        =  2; (** ALT *)
  mLwin*       =  3; (** Left Windows Key — never set in VT100 mode *)
  mRwin*       =  4; (** Right Windows Key — never set in VT100 mode *)
  mMenu*       =  5; (** Menu Key — never set in VT100 mode *)
  mAltGr*      =  6; (** ALT-Graph — never set in VT100 mode *)
  mCommand*    =  7; (** Command key — never set in VT100 mode *)
  mScrolllock* =  8; (** Scroll Lock — never set in VT100 mode *)
  mNumlock*    =  9; (** Num Lock — never set in VT100 mode *)
  mCapslock*   = 10; (** Caps Lock — never set in VT100 mode *)

  (** Characters **)
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

  triangleUp*    = 1EX;
  triangleDown*  = 1FX;
  triangleRight* = 10X;
  triangleLeft*  = 11X;

  arrowUp*        = 18X;
  arrowDown*      = 19X;
  arrowRight*     = 1AX;
  arrowLeft*      = 1BX;
  arrowLeftRight* = 1DX;
  arrowUpDown*    = 12X;

  blackSquare*    = 25A0X;
  upperHalfBlock* = 2580X;
  lowerHalfBlock* = 2584X;
  fullBlock*      = 2588X;
  leftHalfBlock*  = 258CX;
  rightHalfBlock* = 2590X;

  (* Output buffer size *)
  outBufSize = 65536;

  (* Input buffer size *)
  inBufSize = 256;

TYPE
  SHORTCHAR = Utf8.SHORTCHAR;

  Event* = RECORD
    type*: INTEGER;
    x*, y*: INTEGER;
    w*, h*: INTEGER;
    button*: INTEGER;
    key*: INTEGER;
    ch*: CHAR;
    mod*: SET
  END;

  Cell = RECORD
    ch, oldCh: CHAR;
    fg, oldFg: INTEGER;
    bg, oldBg: INTEGER;
    updated: INTEGER
  END;

  Part = POINTER TO PartDesc;
  PartDesc = RECORD
    cells: ARRAY partH, partW OF Cell;
    w, h: INTEGER;
    redraw: BOOLEAN;
    down, right: Part
  END;

  Buffer = RECORD
    first: Part;
    w, h: INTEGER;
    redrawAll: BOOLEAN
  END;

VAR
  wantW, wantH: INTEGER;
  settings: SET;
  buffer: Buffer;
  wantTitle: ARRAY 256 OF CHAR;

  mouseShown: BOOLEAN;
  mouseDown: BOOLEAN;
  mouseX, mouseY, mouseButton: INTEGER;
  curX, curY: INTEGER;
  cursorVisible: BOOLEAN;

  userTimerInterval: INTEGER; (** User timer interval in ms, 0 = off *)

  (* Output buffer *)
  outBuf: ARRAY outBufSize OF SHORTCHAR;
  outLen: INTEGER;

  (* Input buffer *)
  inBuf: ARRAY inBufSize OF SHORTCHAR;
  inLen, inPos: INTEGER;

  (* ANSI SGR code tables *)
  ansiFg: ARRAY nofcolors OF INTEGER;
  ansiBg: ARRAY nofcolors OF INTEGER;

  (* Track current output state to minimize escape sequences *)
  lastFg, lastBg: INTEGER;

  Done*: BOOLEAN;

(* ====================== Output buffer ====================== *)

PROCEDURE FlushOut;
VAR n: INTEGER;
BEGIN
  IF outLen > 0 THEN
    n := TermVT.Write(outBuf, outLen);
    outLen := 0
  END
END FlushOut;

PROCEDURE PutByte(b: INTEGER);
BEGIN
  IF outLen >= outBufSize THEN FlushOut END;
  outBuf[outLen] := Utf8.ShortChr(b); INC(outLen)
END PutByte;

PROCEDURE PutCh(ch: CHAR);
BEGIN PutByte(ORD(ch))
END PutCh;

PROCEDURE PutStr(s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE s[i] # 0X DO PutByte(ORD(s[i])); INC(i) END
END PutStr;

PROCEDURE PutInt(n: INTEGER);
VAR buf: ARRAY 12 OF INTEGER;
  i, j, k, tmp: INTEGER;
BEGIN
  IF n # 0 THEN
    IF n < 0 THEN PutCh('-'); n := -n END;
    i := 0;
    WHILE n > 0 DO
      buf[i] := n MOD 10 + ORD('0'); INC(i); n := n DIV 10
    END;
    (* Reverse *)
    j := 0; k := i - 1;
    WHILE j < k DO
      tmp := buf[j]; buf[j] := buf[k]; buf[k] := tmp; INC(j); DEC(k)
    END;
    (* Write *)
    FOR j := 0 TO i - 1 DO PutByte(buf[j]) END
  ELSE PutCh('0')
  END
END PutInt;

PROCEDURE PutCSI(s: ARRAY OF CHAR);
BEGIN PutByte(1BH); PutCh('['); PutStr(s)
END PutCSI;

(** Encode a UTF-16 CHAR as UTF-8 bytes and write to output buffer *)
PROCEDURE PutChar(ch: CHAR);
VAR s: ARRAY 4 OF SHORTCHAR;
  len, i: INTEGER;
BEGIN
  (* Map CP437 graphics characters in the C0 control range to Unicode.
     In the CP437 font these codepoints are visible glyphs, but in a VT100
     terminal they are non-printing control codes and do not advance the
     cursor — causing corrupt output and wrong cursor-position tracking.
     Note: arrowLeft = 1BX = ESC is especially dangerous as it starts a
     spurious escape sequence. *)
  IF    ch = 001X THEN ch := 0263AX  (* ☺ *)
  ELSIF ch = 002X THEN ch := 0263BX  (* ☻ *)
  ELSIF ch = 003X THEN ch := 02665X  (* ♥ *)
  ELSIF ch = 004X THEN ch := 02666X  (* ♦ *)
  ELSIF ch = 005X THEN ch := 02663X  (* ♣ *)
  ELSIF ch = 006X THEN ch := 02660X  (* ♠ *)
  ELSIF ch = 007X THEN ch := 02022X  (* • *)
  ELSIF ch = 008X THEN ch := 025D8X  (* ◘ *)
  ELSIF ch = 009X THEN ch := 025CBX  (* ○ *)
  ELSIF ch = 00AX THEN ch := 025D9X  (* ◙ *)
  ELSIF ch = 00BX THEN ch := 02642X  (* ♂ *)
  ELSIF ch = 00CX THEN ch := 02640X  (* ♀ *)
  ELSIF ch = 00DX THEN ch := 0266AX  (* ♪ *)
  ELSIF ch = 00EX THEN ch := 0266BX  (* ♫ *)
  ELSIF ch = 00FX THEN ch := 0263CX  (* ☼ *)
  ELSIF ch = 010X THEN ch := 025BAX  (* ► triangleRight *)
  ELSIF ch = 011X THEN ch := 025C4X  (* ◄ triangleLeft *)
  ELSIF ch = 012X THEN ch := 02195X  (* ↕ arrowUpDown *)
  ELSIF ch = 013X THEN ch := 0203CX  (* ‼ *)
  ELSIF ch = 014X THEN ch := 000B6X  (* ¶ *)
  ELSIF ch = 015X THEN ch := 000A7X  (* § *)
  ELSIF ch = 016X THEN ch := 025ACX  (* ▬ *)
  ELSIF ch = 017X THEN ch := 021A8X  (* ↨ *)
  ELSIF ch = 018X THEN ch := 02191X  (* ↑ arrowUp / triangleUp old *)
  ELSIF ch = 019X THEN ch := 02193X  (* ↓ arrowDown / triangleDown old *)
  ELSIF ch = 01AX THEN ch := 02192X  (* → arrowRight *)
  ELSIF ch = 01BX THEN ch := 02190X  (* ← arrowLeft  !!! was ESC byte *)
  ELSIF ch = 01CX THEN ch := 0221FX  (* ∟ *)
  ELSIF ch = 01DX THEN ch := 02194X  (* ↔ arrowLeftRight *)
  ELSIF ch = 01EX THEN ch := 025B2X  (* ▲ triangleUp *)
  ELSIF ch = 01FX THEN ch := 025BCX  (* ▼ triangleDown *)
  END;
  Utf8.EncodeChar(ch, s, len);
  FOR i := 0 TO len - 1 DO PutByte(ORD(s[i])) END
END PutChar;

(* ====================== Cursor positioning ====================== *)

PROCEDURE MoveTo(col, row: INTEGER);
BEGIN
  PutByte(1BH); PutCh('[');
  PutInt(row + 1); PutCh(';'); PutInt(col + 1); PutCh('H')
END MoveTo;

PROCEDURE HideCursorSys;
BEGIN PutCSI('?25l')
END HideCursorSys;

PROCEDURE ShowCursorSys;
BEGIN PutCSI('?25h')
END ShowCursorSys;

(** Begin synchronized output: suppress terminal rendering until EndSync.
    Terminals that do not support mode 2026 simply ignore the sequence. *)
PROCEDURE BeginSync;
BEGIN PutCSI('?2026h')
END BeginSync;

PROCEDURE EndSync;
BEGIN PutCSI('?2026l')
END EndSync;

(* ====================== Colors ====================== *)

PROCEDURE SetSGR(fg, bg: INTEGER);
BEGIN
  fg := fg MOD nofcolors; bg := bg MOD nofcolors;
  IF (fg # lastFg) OR (bg # lastBg) THEN
    PutByte(1BH); PutCh('[');
    PutInt(ansiFg[fg]); PutCh(';');
    PutInt(ansiBg[bg]); PutCh('m');
    lastFg := fg; lastBg := bg
  END
END SetSGR;

PROCEDURE ResetSGR;
BEGIN PutCSI('0m'); lastFg := -1; lastBg := -1
END ResetSGR;

(* ====================== Screen management ====================== *)

PROCEDURE EnterAltScreen;
BEGIN PutCSI('?1049h')
END EnterAltScreen;

PROCEDURE ExitAltScreen;
BEGIN PutCSI('?1049l')
END ExitAltScreen;

PROCEDURE ClearScreen;
BEGIN PutCSI('2J'); PutCSI('H')
END ClearScreen;

PROCEDURE EnableMouse;
BEGIN
  PutCSI('?1000h'); (* Enable mouse tracking *)
  PutCSI('?1002h'); (* Enable button-event tracking (drag) *)
  PutCSI('?1006h')  (* Enable SGR extended mouse mode *)
END EnableMouse;

PROCEDURE DisableMouse;
BEGIN
  PutCSI('?1006l');
  PutCSI('?1002l');
  PutCSI('?1000l')
END DisableMouse;

(* ====================== Cell buffer ====================== *)

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

(** Clears the internal back buffer with grey foreground and black background *)
PROCEDURE Clear*;
BEGIN ClearTo(7, 0)
END Clear;

PROCEDURE InvertColor(color: INTEGER): INTEGER;
BEGIN IF color >= 8 THEN color := 15 - color ELSE color := 7 - color END
RETURN color END InvertColor;

PROCEDURE UpdateCell(x, y: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN p.cells[y, x].updated := 2; p.redraw := TRUE END
END UpdateCell;

(** Synchronizes the internal back buffer with the terminal *)
PROCEDURE Flush*;
VAR x, y, X, Y: INTEGER;
  l, p: Part;
  cell: Cell;
  fg, bg: INTEGER;
  penX, penY: INTEGER; (* tracks where the terminal cursor currently is *)
BEGIN
  BeginSync;
  HideCursorSys;
  lastFg := -1; lastBg := -1;
  penX := -1; penY := -1;
  l := buffer.first; Y := 0;
  WHILE l # NIL DO p := l; X := 0;
    WHILE p # NIL DO
      IF p.redraw OR buffer.redrawAll THEN
        FOR y := 0 TO p.h - 1 DO
          FOR x := 0 TO p.w - 1 DO
            IF buffer.redrawAll OR (p.cells[y, x].updated # 0) THEN
              cell := p.cells[y, x];
              IF mouseShown & (X + x = mouseX) & (Y + y = mouseY) THEN
                fg := InvertColor(cell.fg); bg := InvertColor(cell.bg)
              ELSE
                fg := cell.fg; bg := cell.bg
              END;
              (* Skip MoveTo if cursor is already at the right position.
                 Avoid relying on auto-wrap at the last column. *)
              IF (penX # X + x) OR (penY # Y + y) THEN
                MoveTo(X + x, Y + y)
              END;
              SetSGR(fg, bg);
              PutChar(cell.ch);
              ClearUpdated(p.cells[y, x]);
              (* After writing a char the terminal cursor advances by one.
                 Don't track auto-wrap (last column edge case). *)
              IF X + x < buffer.w - 1 THEN
                penX := X + x + 1; penY := Y + y
              ELSE
                penX := -1; penY := -1
              END
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
  IF cursorVisible & (curX >= 0) & (curY >= 0) THEN
    MoveTo(curX, curY);
    ShowCursorSys
  END;
  ResetSGR;
  EndSync;
  FlushOut
END Flush;

(** Forces a complete resync *)
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

(** Returns TRUE if fullscreen — always FALSE in VT100 mode *)
PROCEDURE IsFS*(): BOOLEAN;
RETURN FALSE END IsFS;

(** Switch to window mode — no-op in VT100 mode *)
PROCEDURE SwitchToWindow*;
END SwitchToWindow;

(** Switch to fullscreen mode — no-op in VT100 mode *)
PROCEDURE SwitchToFS*;
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
VAR cols, rows, n: INTEGER;
BEGIN
  n := TermVT.Size(cols, rows);
  IF n < 0 THEN cols := stdW; rows := stdH END;
  buffer.w := cols; buffer.h := rows;
  IF buffer.w > partW THEN buffer.w := partW END;
  IF buffer.h > partH THEN buffer.h := partH END;
  buffer.first := NewPart(buffer.w, buffer.h);
  curX := -1; curY := -1; buffer.redrawAll := TRUE
END InitBuffer;

PROCEDURE ResizeBuffer;
VAR cols, rows, nw, nh, n: INTEGER;
BEGIN
  n := TermVT.Size(cols, rows);
  IF n >= 0 THEN
    nw := cols; nh := rows;
    IF nw > partW THEN nw := partW END;
    IF nh > partH THEN nh := partH END;
    IF (nw # buffer.w) OR (nh # buffer.h) THEN
      buffer.w := nw; buffer.h := nh;
      ResizePart(buffer.first, nw, nh)
    END
  END
END ResizeBuffer;

(* ====================== Input parsing ====================== *)

PROCEDURE ReadMoreInput;
VAR n, i: INTEGER;
BEGIN
  IF inPos > 0 THEN
    i := 0;
    WHILE inPos + i < inLen DO
      inBuf[i] := inBuf[inPos + i]; INC(i)
    END;
    inLen := i; inPos := 0
  END;
  n := TermVT.Read(inBuf, inLen, inBufSize);
  IF n > 0 THEN INC(inLen, n) END
END ReadMoreInput;

PROCEDURE Avail(): INTEGER;
BEGIN
RETURN inLen - inPos END Avail;

PROCEDURE Peek(offset: INTEGER): CHAR;
VAR result: CHAR;
BEGIN
  IF inPos + offset < inLen THEN result := Utf8.Long(inBuf[inPos + offset])
  ELSE result := 0X
  END
RETURN result END Peek;

PROCEDURE Skip(n: INTEGER);
BEGIN INC(inPos, n)
END Skip;

PROCEDURE CharToKey(ch: CHAR; VAR k: INTEGER; VAR mod: SET);
VAR c: INTEGER;
BEGIN k := 0; mod := {};
  c := ORD(ch);
  IF (c >= ORD('a')) & (c <= ORD('z')) THEN
    k := kA + (c - ORD('a'))
  ELSIF (c >= ORD('A')) & (c <= ORD('Z')) THEN
    k := kA + (c - ORD('A')); INCL(mod, mShift)
  ELSIF (c >= ORD('0')) & (c <= ORD('9')) THEN
    k := k0 + (c - ORD('0'))
  ELSIF ch = ' ' THEN k := kSpace
  ELSIF ch = 0DX THEN k := kEnter
  ELSIF ch = 0AX THEN k := kEnter
  ELSIF ch = 09X THEN k := kTab
  ELSIF ch = 7FX THEN k := kBackspace
  ELSIF ch = 08X THEN k := kBackspace
  ELSIF ch = '~' THEN k := kTilde
  ELSIF ch = '-' THEN k := kMinus
  ELSIF ch = '=' THEN k := kEquals
  ELSIF ch = '[' THEN k := kOpenBrace
  ELSIF ch = ']' THEN k := kCloseBrace
  ELSIF ch = ';' THEN k := kColon
  ELSIF ch = ':' THEN k := kColon; INCL(mod, mShift)
  ELSIF ch = 27X THEN k := kQuote
  ELSIF ch = '\' THEN k := kBackslash
  ELSIF ch = ',' THEN k := kComma
  ELSIF ch = '.' THEN k := kStop
  ELSIF ch = '/' THEN k := kSlash
  END
END CharToKey;

PROCEDURE ParseCSIParam(VAR i: INTEGER): INTEGER;
VAR n: INTEGER;
  c: CHAR;
  done: BOOLEAN;
BEGIN n := 0; done := FALSE;
  WHILE ~done & (inPos + i < inLen) DO
    c := Utf8.Long(inBuf[inPos + i]);
    IF (c >= '0') & (c <= '9') THEN
      n := n * 10 + ORD(c) - ORD('0'); INC(i)
    ELSE done := TRUE
    END
  END
RETURN n END ParseCSIParam;

PROCEDURE DecodeModifier(m: INTEGER): SET;
VAR s: SET;
BEGIN s := {};
  IF m > 1 THEN DEC(m);
    IF ODD(m) THEN INCL(s, mShift) END;
    IF ODD(m DIV 2) THEN INCL(s, mAlt) END;
    IF ODD(m DIV 4) THEN INCL(s, mCtrl) END
  END
RETURN s END DecodeModifier;

PROCEDURE ParseCSI(VAR event: Event): BOOLEAN;
VAR i, p1, p2, p3: INTEGER;
  c, final: CHAR;
  ok, result: BOOLEAN;
BEGIN
  result := FALSE;
  ok := TRUE;
  i := 0;
  c := Peek(i);

  (* SGR mouse: ESC [ < Cb ; Cx ; Cy M/m *)
  IF c = '<' THEN INC(i);
    p1 := ParseCSIParam(i);
    IF Peek(i) = ';' THEN INC(i) END;
    p2 := ParseCSIParam(i);
    IF Peek(i) = ';' THEN INC(i) END;
    p3 := ParseCSIParam(i);
    final := Peek(i);
    IF (final = 'M') OR (final = 'm') THEN INC(i);
      event.type := mouse;
      event.x := p2 - 1; event.y := p3 - 1;
      IF event.x < 0 THEN event.x := 0 END;
      IF event.y < 0 THEN event.y := 0 END;
      IF event.x >= buffer.w THEN event.x := buffer.w - 1 END;
      IF event.y >= buffer.h THEN event.y := buffer.h - 1 END;
      IF final = 'M' THEN
        IF p1 = 64 THEN (* Wheel up *)
          event.button := kWheelUp;
          MoveMouse(event.x, event.y)
        ELSIF p1 = 65 THEN (* Wheel down *)
          event.button := kWheelDown;
          MoveMouse(event.x, event.y)
        ELSIF p1 >= 32 THEN (* Motion / drag *)
          event.button := mouseButton;
          MoveMouse(event.x, event.y)
        ELSE
          event.button := (p1 MOD 4) + 1;
          mouseDown := TRUE;
          mouseButton := event.button;
          MoveMouse(event.x, event.y)
        END
      ELSE
        event.button := 0;
        mouseDown := FALSE;
        MoveMouse(event.x, event.y)
      END;
      event.mod := {};
      IF ODD(p1 DIV 4) THEN INCL(event.mod, mShift) END;
      IF ODD(p1 DIV 8) THEN INCL(event.mod, mAlt) END;
      IF ODD(p1 DIV 16) THEN INCL(event.mod, mCtrl) END;
      Skip(i); result := TRUE
    ELSE ok := FALSE
    END
  END;

  IF ok & ~result THEN
    (* Arrow keys: ESC [ A-D *)
    IF (c >= 'A') & (c <= 'D') THEN
      event.type := key; event.ch := 0X; event.mod := {};
      IF c = 'A' THEN event.key := kUp
      ELSIF c = 'B' THEN event.key := kDown
      ELSIF c = 'C' THEN event.key := kRight
      ELSIF c = 'D' THEN event.key := kLeft
      END;
      Skip(1); result := TRUE
    ELSIF c = 'H' THEN
      event.type := key; event.key := kHome; event.ch := 0X; event.mod := {};
      Skip(1); result := TRUE
    ELSIF c = 'F' THEN
      event.type := key; event.key := kEnd; event.ch := 0X; event.mod := {};
      Skip(1); result := TRUE
    ELSIF c = 'Z' THEN (* Shift+Tab *)
      event.type := key; event.key := kTab; event.ch := 0X;
      event.mod := {mShift};
      Skip(1); result := TRUE
    ELSIF (c >= '0') & (c <= '9') THEN
      (* Numeric CSI sequences *)
      p1 := ParseCSIParam(i);
      c := Peek(i);
      IF c = '~' THEN INC(i);
        event.type := key; event.ch := 0X; event.mod := {};
        IF p1 = 1 THEN event.key := kHome
        ELSIF p1 = 2 THEN event.key := kInsert
        ELSIF p1 = 3 THEN event.key := kDel
        ELSIF p1 = 4 THEN event.key := kEnd
        ELSIF p1 = 5 THEN event.key := kPgUp
        ELSIF p1 = 6 THEN event.key := kPgDn
        ELSIF p1 = 11 THEN event.key := kF1
        ELSIF p1 = 12 THEN event.key := kF2
        ELSIF p1 = 13 THEN event.key := kF3
        ELSIF p1 = 14 THEN event.key := kF4
        ELSIF p1 = 15 THEN event.key := kF5
        ELSIF p1 = 17 THEN event.key := kF6
        ELSIF p1 = 18 THEN event.key := kF7
        ELSIF p1 = 19 THEN event.key := kF8
        ELSIF p1 = 20 THEN event.key := kF9
        ELSIF p1 = 21 THEN event.key := kF10
        ELSIF p1 = 23 THEN event.key := kF11
        ELSIF p1 = 24 THEN event.key := kF12
        ELSE event.type := noEvent
        END;
        Skip(i); result := event.type # noEvent
      ELSIF c = ';' THEN INC(i);
        p2 := ParseCSIParam(i);
        final := Peek(i); INC(i);
        event.type := key; event.ch := 0X;
        event.mod := DecodeModifier(p2);
        IF (final >= 'A') & (final <= 'D') THEN
          IF final = 'A' THEN event.key := kUp
          ELSIF final = 'B' THEN event.key := kDown
          ELSIF final = 'C' THEN event.key := kRight
          ELSIF final = 'D' THEN event.key := kLeft
          END
        ELSIF final = 'H' THEN event.key := kHome
        ELSIF final = 'F' THEN event.key := kEnd
        ELSIF final = '~' THEN
          IF p1 = 2 THEN event.key := kInsert
          ELSIF p1 = 3 THEN event.key := kDel
          ELSIF p1 = 5 THEN event.key := kPgUp
          ELSIF p1 = 6 THEN event.key := kPgDn
          ELSIF p1 = 11 THEN event.key := kF1
          ELSIF p1 = 12 THEN event.key := kF2
          ELSIF p1 = 13 THEN event.key := kF3
          ELSIF p1 = 14 THEN event.key := kF4
          ELSIF p1 = 15 THEN event.key := kF5
          ELSIF p1 = 17 THEN event.key := kF6
          ELSIF p1 = 18 THEN event.key := kF7
          ELSIF p1 = 19 THEN event.key := kF8
          ELSIF p1 = 20 THEN event.key := kF9
          ELSIF p1 = 21 THEN event.key := kF10
          ELSIF p1 = 23 THEN event.key := kF11
          ELSIF p1 = 24 THEN event.key := kF12
          ELSE event.type := noEvent
          END
        ELSIF final = 'P' THEN event.key := kF1
        ELSIF final = 'Q' THEN event.key := kF2
        ELSIF final = 'R' THEN event.key := kF3
        ELSIF final = 'S' THEN event.key := kF4
        ELSE event.type := noEvent
        END;
        Skip(i); result := event.type # noEvent
      ELSE
        WHILE (inPos + i < inLen) & ~((c >= '@') & (c <= '~')) DO
          INC(i); c := Peek(i)
        END;
        IF (c >= '@') & (c <= '~') THEN INC(i) END;
        Skip(i)
      END
    ELSE
      (* Unknown CSI: skip to final byte *)
      WHILE (inPos + i < inLen) & ~((c >= '@') & (c <= '~')) DO
        INC(i); c := Peek(i)
      END;
      IF (c >= '@') & (c <= '~') THEN INC(i) END;
      Skip(i)
    END
  ELSIF ~ok THEN Skip(i)
  END
RETURN result END ParseCSI;

PROCEDURE ParseSS3(VAR event: Event): BOOLEAN;
VAR c: CHAR;
  result: BOOLEAN;
BEGIN result := FALSE;
  IF Avail() > 0 THEN
    c := Peek(0);
    event.type := key; event.ch := 0X; event.mod := {};
    result := TRUE;
    IF c = 'P' THEN event.key := kF1
    ELSIF c = 'Q' THEN event.key := kF2
    ELSIF c = 'R' THEN event.key := kF3
    ELSIF c = 'S' THEN event.key := kF4
    ELSIF c = 'H' THEN event.key := kHome
    ELSIF c = 'F' THEN event.key := kEnd
    ELSIF c = 'A' THEN event.key := kUp
    ELSIF c = 'B' THEN event.key := kDown
    ELSIF c = 'C' THEN event.key := kRight
    ELSIF c = 'D' THEN event.key := kLeft
    ELSE event.type := noEvent; result := FALSE
    END;
    IF result THEN Skip(1) END
  END
RETURN result END ParseSS3;

PROCEDURE ParseEscape(VAR event: Event): BOOLEAN;
VAR c: CHAR;
  result: BOOLEAN;
BEGIN result := FALSE;
  IF Avail() > 0 THEN
    c := Peek(0);
    IF c = '[' THEN
      Skip(1);
      result := ParseCSI(event)
    ELSIF c = 'O' THEN
      Skip(1);
      result := ParseSS3(event)
    ELSIF c = 1BX THEN (* ESC ESC ... → Alt + escape sequence *)
      Skip(1);
      IF Avail() = 0 THEN
        IF TermVT.Poll(20) > 0 THEN ReadMoreInput END
      END;
      result := ParseEscape(event);
      IF result THEN INCL(event.mod, mAlt) END
    ELSIF (ORD(c) >= 20H) & (ORD(c) <= 7EH) THEN
      Skip(1);
      event.type := key;
      event.ch := c;
      CharToKey(event.ch, event.key, event.mod);
      INCL(event.mod, mAlt);
      result := TRUE
    END
  END
RETURN result END ParseEscape;

PROCEDURE ParseUtf8(first: CHAR; VAR ch: CHAR): BOOLEAN;
VAR c, val, needed, i: INTEGER;
  ok: BOOLEAN;
BEGIN
  c := ORD(first);
  ok := TRUE;
  IF c < 80H THEN ch := first; needed := 0
  ELSIF (c >= 0C0H) & (c < 0E0H) THEN needed := 1; val := c - 0C0H
  ELSIF (c >= 0E0H) & (c < 0F0H) THEN needed := 2; val := c - 0E0H
  ELSIF (c >= 0F0H) & (c < 0F8H) THEN needed := 3; val := c - 0F0H
  ELSE ch := '?'; needed := 0
  END;
  IF needed > 0 THEN
    IF Avail() < needed THEN ok := FALSE
    ELSE
      i := 0;
      WHILE ok & (i < needed) DO
        c := ORD(Peek(i));
        IF (c < 80H) OR (c >= 0C0H) THEN ch := '?'; Skip(i); needed := 0; ok := TRUE
        ELSE val := val * 64 + (c - 80H); INC(i)
        END
      END;
      IF ok & (needed > 0) THEN Skip(needed); ch := CHR(val) END
    END
  END
RETURN ok END ParseUtf8;

PROCEDURE ParseInputEvent(VAR event: Event): BOOLEAN;
VAR c: CHAR;
  b: INTEGER;
  ch: CHAR;
  result: BOOLEAN;
BEGIN result := FALSE;
  IF Avail() > 0 THEN
    event.type := noEvent; event.key := 0; event.ch := 0X;
    event.mod := {}; event.x := 0; event.y := 0;
    event.w := 0; event.h := 0; event.button := 0;

    c := Peek(0); Skip(1);
    b := ORD(c);

    IF c = 1BX THEN
      IF Avail() = 0 THEN (* Wait briefly for rest of escape sequence (e.g. arrow key) *)
        IF TermVT.Poll(20) > 0 THEN ReadMoreInput END
      END;
      IF Avail() > 0 THEN result := ParseEscape(event) END;
      IF ~result THEN
        event.type := key; event.key := kEsc; event.ch := 0X; event.mod := {};
        result := TRUE
      END
    ELSIF (b >= 1) & (b <= 26) THEN
      event.type := key;
      event.key := kA + (b - 1);
      event.ch := 0X;
      INCL(event.mod, mCtrl);
      IF b = 9 THEN event.key := kTab; event.ch := 09X; event.mod := {}
      ELSIF b = 13 THEN event.key := kEnter; event.ch := 0DX; event.mod := {}
      ELSIF b = 10 THEN event.key := kEnter; event.ch := 0AX; event.mod := {}
      ELSIF b = 8 THEN event.key := kBackspace; event.ch := 0X; event.mod := {}
      ELSIF b = 3 THEN event.type := quit
      END;
      result := TRUE
    ELSIF b = 127 THEN
      event.type := key; event.key := kBackspace; event.ch := 0X; event.mod := {};
      result := TRUE
    ELSIF b = 0 THEN
      event.type := key; event.key := kSpace; event.ch := 0X;
      INCL(event.mod, mCtrl);
      result := TRUE
    ELSIF b >= 20H THEN
      IF ParseUtf8(c, ch) THEN
        event.type := key; event.ch := ch;
        CharToKey(ch, event.key, event.mod);
        result := TRUE
      END
    END
  END
RETURN result END ParseInputEvent;

(** Waits for the next event *)
PROCEDURE WaitEvent*(VAR event: Event);
VAR n, timeout: INTEGER;
  done: BOOLEAN;
BEGIN done := FALSE;
  REPEAT
    IF ParseInputEvent(event) THEN done := TRUE
    ELSE
      IF userTimerInterval > 0 THEN timeout := userTimerInterval
      ELSE timeout := -1
      END;
      n := TermVT.Poll(timeout);
      IF n = -2 THEN
        ResizeBuffer;
        event.type := resize;
        event.w := buffer.w; event.h := buffer.h;
        Sync;
        done := TRUE
      ELSIF n = 0 THEN
        IF userTimerInterval > 0 THEN
          event.type := timer;
          done := TRUE
        END
      ELSIF n > 0 THEN
        ReadMoreInput
      END
    END
  UNTIL done
END WaitEvent;

(** Peeks at the next event without removing it *)
PROCEDURE PeekEvent*(VAR event: Event): BOOLEAN;
VAR n, savedPos, savedLen: INTEGER;
  result: BOOLEAN;
BEGIN result := FALSE;
  IF Avail() > 0 THEN
    savedPos := inPos; savedLen := inLen;
    IF ParseInputEvent(event) THEN
      inPos := savedPos; inLen := savedLen;
      result := TRUE
    ELSE
      inPos := savedPos; inLen := savedLen
    END
  END;
  IF ~result THEN
    n := TermVT.Poll(0);
    IF n = -2 THEN
      ResizeBuffer;
      event.type := resize;
      event.w := buffer.w; event.h := buffer.h;
      Sync;
      result := TRUE
    ELSIF n > 0 THEN
      ReadMoreInput;
      savedPos := inPos; savedLen := inLen;
      IF ParseInputEvent(event) THEN
        inPos := savedPos; inLen := savedLen;
        result := TRUE
      ELSE
        inPos := savedPos; inLen := savedLen
      END
    END
  END
RETURN result END PeekEvent;

(** Returns TRUE if there are events in the queue *)
PROCEDURE HasEvents*(): BOOLEAN;
VAR e: Event;
RETURN PeekEvent(e) END HasEvents;

(** Moves the text input cursor to cell (x; y) *)
PROCEDURE SetCursor*(x, y: INTEGER);
BEGIN
  IF (x # curX) OR (y # curY) THEN
    UpdateCell(curX, curY);
    IF (0 <= x) & (x < buffer.w) & (0 <= y) & (y < buffer.h) THEN
      curX := x; curY := y;
      cursorVisible := TRUE;
      UpdateCell(x, y)
    ELSE curX := -1; curY := -1; cursorVisible := FALSE
    END
  END
END SetCursor;

(** Hides the text input cursor *)
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

(** Sets background color *)
PROCEDURE SetBg*(x, y, bg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartBg(p, x, y, bg) END
END SetBg;

(** Sets foreground color *)
PROCEDURE SetFg*(x, y, fg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartFg(p, x, y, fg) END
END SetFg;

(** Fills the cell at (x; y) *)
PROCEDURE SetCell*(x, y: INTEGER; ch: CHAR; fg, bg: INTEGER);
VAR p: Part;
BEGIN p := GetPart(buffer, x, y);
  IF p # NIL THEN SetPartCell(p, x, y, ch, fg, bg) END
END SetCell;

(** Fill a rectangular area *)
PROCEDURE Fill*(x, y, w, h: INTEGER; ch: CHAR; fg, bg: INTEGER);
VAR X, Y: INTEGER;
BEGIN
  FOR Y := y TO y + h - 1 DO
    FOR X := x TO x + w - 1 DO
      SetCell(X, Y, ch, fg, bg)
    END
  END
END Fill;

(** Print a string *)
PROCEDURE Print*(x, y, limit: INTEGER; s: ARRAY OF CHAR; fg, bg: INTEGER);
VAR i: INTEGER;
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

(** Returns size of the terminal in characters *)
PROCEDURE Size*(VAR width, height: INTEGER);
BEGIN width := buffer.w; height := buffer.h
END Size;

(** Returns data of the terminal cell at (x; y) *)
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
VAR n: INTEGER;
BEGIN n := TermVT.Poll(ms)
END Delay;

(** Re-enables mouse tracking after a child process may have disabled it *)
PROCEDURE RestoreMouse*;
BEGIN
  IF ~(noMouse IN settings) THEN EnableMouse; FlushOut END
END RestoreMouse;

(** Closes TermBox *)
PROCEDURE Close*;
BEGIN
  DisableMouse;
  ResetSGR;
  ShowCursorSys;
  ExitAltScreen;
  FlushOut;
  Done := FALSE;
  IF TermVT.Close() < 0 THEN END
END Close;

(** Sets the title — uses xterm OSC title escape *)
PROCEDURE SetTitle*(title: ARRAY OF CHAR);
VAR s: ARRAY 256 OF SHORTCHAR;
  i: INTEGER;
BEGIN
  wantTitle := title;
  PutByte(1BH); PutCh(']'); PutCh('0'); PutCh(';');
  Utf8.Encode(title, s);
  i := 0; WHILE s[i] # 0X DO PutByte(ORD(s[i])); INC(i) END;
  PutByte(07H);
  FlushOut
END SetTitle;

(** SetZoomF — no-op in VT100 mode *)
PROCEDURE SetZoomF*(zoom: REAL);
END SetZoomF;

(** SetZoom — no-op in VT100 mode *)
PROCEDURE SetZoom*(zoom: INTEGER);
END SetZoom;

(** SetScale — no-op in VT100 mode *)
PROCEDURE SetScale*(x, y: REAL);
END SetScale;

(** Start TermBox timer *)
PROCEDURE StartTimer*(speed: REAL);
BEGIN
  IF speed > 0.0 THEN
    userTimerInterval := FLOOR(1000.0 * speed + 0.5);
    IF userTimerInterval < 1 THEN userTimerInterval := 1 END
  ELSE
    userTimerInterval := 0
  END
END StartTimer;

(** Initializes TermBox VT100 backend *)
PROCEDURE Init*;
BEGIN Done := FALSE;
  outLen := 0; inLen := 0; inPos := 0;
  lastFg := -1; lastBg := -1;
  userTimerInterval := 0;

  IF TermVT.Init() >= 0 THEN
    EnterAltScreen;
    ClearScreen;
    HideCursorSys;
    IF ~(noMouse IN settings) THEN EnableMouse END;
    FlushOut;

    InitBuffer;
    mouseDown := FALSE;
    mouseShown := ~(noMouse IN settings);
    cursorVisible := FALSE;

    Done := TRUE
  END
END Init;

(** Settings — stores width/height/flags for compatibility *)
PROCEDURE Settings*(w, h: INTEGER; flags: SET);
BEGIN
  IF w = 0 THEN wantW := stdW ELSE wantW := w END;
  IF h = 0 THEN wantH := stdH ELSE wantH := h END;
  settings := flags
END Settings;

(** SetIconFile — no-op in VT100 mode *)
PROCEDURE SetIconFile*(s: ARRAY OF CHAR);
END SetIconFile;

(** SetFontFile — no-op in VT100 mode *)
PROCEDURE SetFontFile*(s: ARRAY OF CHAR);
END SetFontFile;

(** GetClipboardText — stub in VT100 mode *)
PROCEDURE GetClipboardText*(VAR s: ARRAY OF CHAR);
BEGIN s[0] := 0X
END GetClipboardText;

(** SetClipboardText — stub in VT100 mode *)
PROCEDURE SetClipboardText*(s: ARRAY OF CHAR);
END SetClipboardText;

PROCEDURE InitColors;
BEGIN
  ansiFg[ 0] := 30;  ansiBg[ 0] := 40;
  ansiFg[ 1] := 34;  ansiBg[ 1] := 44;
  ansiFg[ 2] := 32;  ansiBg[ 2] := 42;
  ansiFg[ 3] := 36;  ansiBg[ 3] := 46;
  ansiFg[ 4] := 31;  ansiBg[ 4] := 41;
  ansiFg[ 5] := 35;  ansiBg[ 5] := 45;
  ansiFg[ 6] := 33;  ansiBg[ 6] := 43;
  ansiFg[ 7] := 37;  ansiBg[ 7] := 47;
  ansiFg[ 8] := 90;  ansiBg[ 8] := 100;
  ansiFg[ 9] := 94;  ansiBg[ 9] := 104;
  ansiFg[10] := 92;  ansiBg[10] := 102;
  ansiFg[11] := 96;  ansiBg[11] := 106;
  ansiFg[12] := 91;  ansiBg[12] := 101;
  ansiFg[13] := 95;  ansiBg[13] := 105;
  ansiFg[14] := 93;  ansiBg[14] := 103;
  ansiFg[15] := 97;  ansiBg[15] := 107
END InitColors;

BEGIN wantW := stdW; wantH := stdH;
  settings := {}; Done := FALSE;
  InitColors
END TermBox.
