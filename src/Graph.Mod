MODULE Graph;
(* Copyright 2017 Arthur Yefimov

This file is part of Free Oberon.

Free Oberon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Free Oberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*)
IMPORT SDL := SDL2, (* Mix := SDL2mixer, Net := SDL2net,*)
       SYSTEM, Platform, Out;

CONST
  (* Flip Flags *)
  flipNone* = {};
  flipH*    = 0;
  flipV*    = 1;
  flipHV*   = flipH + flipV;

  (* Draw Mode Flags *)
  drawSpriteNormal* = 0;
  drawSpriteLit*    = 1;
  drawSpriteTrans*  = 2;

  (* Settings *)
  fullscreen*  = 0;
  buffered*    = 1;
  spread*      = 2;
  sharpPixels* = 3;
  software*    = 4;
  initMouse*   = 8;
  initSound*   = 9;
  initNet*     = 10;

  (* Event Types *)
  quit*        = 1;
  windowEvent* = 2;
  keyDown*     = 3;
  keyUp*       = 4;
  textInput*        = 5;
  mouseMove*   = 6;
  mouseDown*   = 7;
  mouseUp*     = 8;
  mouseWheel*  = 9;

  (* Mouse Buttons *)
  btnLeft*  = 0;
  btnRight* = 1;
  btnMid*   = 2;

  (* Random Modulo *)
  randomModulo* = 2147483647; (* =2^31-1 *)

  (* Key Codes *)
  kA*           = 4;
  kB*           = 5;
  kC*           = 6;
  kD*           = 7;
  kE*           = 8;
  kF*           = 9;
  kG*           = 10;
  kH*           = 11;
  kI*           = 12;
  kJ*           = 13;
  kK*           = 14;
  kL*           = 15;
  kM*           = 16;
  kN*           = 17;
  kO*           = 18;
  kP*           = 19;
  kQ*           = 20;
  kR*           = 21;
  kS*           = 22;
  kT*           = 23;
  kU*           = 24;
  kV*           = 25;
  kW*           = 26;
  kX*           = 27;
  kY*           = 28;
  kZ*           = 29;
  k1*           = 30;
  k2*           = 31;
  k3*           = 32;
  k4*           = 33;
  k5*           = 34;
  k6*           = 35;
  k7*           = 36;
  k8*           = 37;
  k9*           = 38;
  k0*           = 39;
  k1Pad*        = 89;
  k2Pad*        = 90;
  k3Pad*        = 91;
  k4Pad*        = 92;
  k5Pad*        = 93;
  k6Pad*        = 94;
  k7Pad*        = 95;
  k8Pad*        = 96;
  k9Pad*        = 97;
  k0Pad*        = 98;
  kF1*          = 58;
  kF2*          = 59;
  kF3*          = 60;
  kF4*          = 61;
  kF5*          = 62;
  kF6*          = 63;
  kF7*          = 64;
  kF8*          = 65;
  kF9*          = 66;
  kF10*         = 67;
  kF11*         = 68;
  kF12*         = 69;
  kEsc*         = 41;
  kTilde*       = 53;
  kMinus*       = 45;
  kEquals*      = 46;
  kBackspace*   = 42;
  kTab*         = 43;
  kOpenBrace*   = 47;
  kCloseBrace*  = 48;
  kEnter*       = 40;
  kColon*       = 51;
  kQuote*       = 52;
  kBackslash*   = 49;
  kBackslash2*  = 100;
  kComma*       = 54;
  kStop*        = 55;
  kSlash*       = 56;
  kSpace*       = 44;
  kInsert*      = 73;
  kDel*         = 76;
  kHome*        = 74;
  kEnd*         = 77;
  kPgUp*        = 75;
  kPgDn*        = 78;
  kLeft*        = 80;
  kRight*       = 79;
  kUp*          = 82;
  kDown*        = 81;
  kSlashPad*    = 84;
  kAsterisk*    = 85;
  kMinusPad*    = 86;
  kPlusPad*     = 87;
  kDelPad*      = 99;
  kEnterPad*    = 88;
  kPrtScr*      = 70;
  kPause*       = 72;

  kModifiers*   = 115;

  kLShift*      = 225;
  kRShift*      = 229;
  kLCtrl*       = 224;
  kRCtrl*       = 228;
  kAlt*         = 226;
  kAltGr*       = 230;
  kLWin*        = 227;
  kRWin*        = 231;
  kMenu*        = 123;
  kScrLock*     = 124;
  kNumLock*     = 125;
  kCapsLock*    = 126;

  kMax*         = 127;

  (* Modifiers Set *)
  mLShift*   = 0;
  mRShift*   = 1;
  mLCtrl*    = 6;
  mRCtrl*    = 7;
  mLAlt*     = 8;
  mRAlt*     = 9;
  mLGui*     = 10;
  mRGui*     = 11;
  mNum*      = 12;
  mCaps*     = 13;
  mMode*     = 14;
  mReserved* = 15;
  mCtrl*  = {mLCtrl, mRCtrl};
  mShift* = {mLShift, mRShift};
  mAlt*   = {mLAlt, mRAlt};
  mGui*   = {mLGui, mRGui};

TYPE
  SET32 = SYSTEM.SET32;

  Bitmap* = POINTER TO BitmapDesc;
  BitmapDesc* = RECORD
    surface: SDL.Surface;
    w*, h*: INTEGER
  END;

  Font* = POINTER TO FontDesc;
  FontDesc* = RECORD
    bmp*: Bitmap;
    charW*, charH*: INTEGER;
    charRows*, charsInRow*: INTEGER;
    sprites*: POINTER TO ARRAY OF ARRAY OF SDL.Rect
  END;

  KeyArray = SDL.KeyArray;

  Key* = RECORD
    code*: INTEGER; (* Physical key code *)
    sym*: INTEGER; (* Virtual key code *)
    mod*: SET; (* Key modifiers *)
    repeat*: BOOLEAN
  END;

  (*
  Sample* = POINTER TO SampleDesc;
  SampleDesc* = RECORD
    chunk*: Mix.Chunk
  END;

  Music* = POINTER TO MusicDesc;
  MusicDesc* = RECORD
    music*: Mix.Music
  END;
  *)

  Region* = RECORD
    x*, y*, w*, h*: INTEGER
  END;

  (* SDL Net *)
  (*
  IPAddress* = Net.IPAddress;
  Socket* = Net.TCPSocket;

  SocketSet* = Net.SocketSet;

  PStr* = POINTER TO ARRAY OF CHAR;

  NetBuf* = POINTER TO NetBufDesc;
  NetBufDesc* = RECORD
    s: PStr;
    len: INTEGER; (* Actual used length of the buffer *)
    lastLen: INTEGER
  END;
  *)

  Event* = RECORD
    type*: INTEGER;
    key*: Key;
    x*, y*: INTEGER;
    xRel*, yRel*: INTEGER;
    button*: INTEGER;
    buttons*: SET; (* What mouse buttons are pressed *)
    down*: BOOLEAN;
    s*: ARRAY 32 OF CHAR
  END;

  EventQueue* = RECORD
    buf: ARRAY 256 OF Event;
    first, last: INTEGER; (* Index of first and last element *)
    len: INTEGER (* Amount of elements currently in queue *)
  END;

  CloseBtnProc* = PROCEDURE;

VAR
  window: SDL.Window;
  renderer: SDL.Renderer;
  screen: Bitmap;
  screenTexture: SDL.Texture;
  events: EventQueue;
  keyPressed: INTEGER;

  sizeStepX, sizeStepY: INTEGER;
  wantW, wantH: INTEGER;
  wantFullscreen, wantBuffer, wantSpread: BOOLEAN;
  wantSharpPixels, wantSoftware: BOOLEAN;
  wantMouse, wantSound, wantNet: BOOLEAN;
  wantFPS: INTEGER;
  buffer: Bitmap;
  lastFlip: INTEGER;
  frames, framesT: INTEGER;

  (* Flip Region *)
  flipRegion: Region;

  (* Mouse *)
  mouseX, mouseY: INTEGER;
  mouseFocusX, mouseFocusY: INTEGER;
  lastBlitMouseOutside: BOOLEAN;
  lastBlitMouseX, lastBlitMouseY: INTEGER;
  needRedrawMouse: BOOLEAN; (* True if mouse has moved since last redraw *)
  showMouse: BOOLEAN; (* Whether to show mouse pointer on screen *)
  stdMousePointer: Bitmap;
  mousePointer: Bitmap;
  underMouse: Bitmap; (* Buffer to copy part of image under the mouse *)

  randomSeed-: INTEGER;

PROCEDURE -AAIncludeSDL2h0 '#include "SDL2.h0"';

(* C Macros *)

PROCEDURE LoadBmp(filename: ARRAY OF CHAR): SDL.Surface;
BEGIN
  RETURN SDL.LoadBmpRW(SDL.RWFromFile(filename, 'rb'), 1)
END LoadBmp;

(* Misc *)

PROCEDURE Str*(n: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN
  (*IntStr.IntToStr(n, s)*)
  s[0] := '4'; s[1] := '2'; s[2] := 0X (*!FIXME*)
END Str;

PROCEDURE Val*(s: ARRAY OF CHAR): INTEGER;
VAR n: INTEGER; (*res: IntStr.ConvResults;*)
BEGIN
  (*IntStr.StrToInt(s, n, res);
  IF res # IntStr.strAllRight THEN n := 0 END;
  RETURN n*)
  RETURN 42 (*!FIXME*)
END Val;

PROCEDURE AppendN*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR sn: ARRAY 30 OF CHAR;
BEGIN
  (*Str(n, sn); S.Append(sn, s) !FIXME *)
END AppendN;

(* General *)

PROCEDURE GetError*(VAR s: ARRAY OF CHAR);
TYPE P = POINTER TO ARRAY 10240 OF CHAR;
VAR p: P;
BEGIN
  p := SYSTEM.VAL(P, SDL.GetError());
  COPY(p^, s)
END GetError;

PROCEDURE Settings*(w, h: INTEGER; flags: SET);
BEGIN (*!TODO: Refactor, save options in a SET*)
  wantW := w; wantH := h;
  wantFullscreen := fullscreen IN flags;
  wantBuffer := buffered IN flags;
  wantSpread := spread IN flags;
  wantSharpPixels := sharpPixels IN flags;
  wantSoftware := software IN flags;
  wantMouse := initMouse IN flags;
  showMouse := wantMouse;
  wantNet := initNet IN flags;
  wantSound := initSound IN flags
END Settings;

PROCEDURE SetSizeStep*(w, h: INTEGER);
BEGIN
  sizeStepX := w; sizeStepY := h
END SetSizeStep;

PROCEDURE SetFPS*(fps: INTEGER);
BEGIN
  IF fps <= 0 THEN fps := -1 END;
  wantFPS := fps
END SetFPS;

PROCEDURE GetDesktopResolution*(VAR w, h: INTEGER);
VAR mode: SDL.DisplayMode;
BEGIN
  SDL.GetDesktopDisplayMode(0, mode);
  w := mode.w; h := mode.h
END GetDesktopResolution;

PROCEDURE CheckWantedScreenSize;
BEGIN
  IF (wantW = -1) OR (wantH = -1) THEN
    GetDesktopResolution(wantW, wantH);
    IF ~wantFullscreen THEN
      DEC(wantW, 20); DEC(wantH, 50)
    END
  END
END CheckWantedScreenSize;

(* Flip Region *)
PROCEDURE SetRegion*(x, y, w, h: INTEGER);
BEGIN
  flipRegion.x := x;  flipRegion.y := y;
  flipRegion.w := w;  flipRegion.h := h
END SetRegion;

PROCEDURE UnsetRegion*;
BEGIN
  flipRegion.w := -1
END UnsetRegion;

PROCEDURE AddRegion*(x, y, w, h: INTEGER);
BEGIN
  IF flipRegion.w = -1 THEN (* No flip region yet *)
    SetRegion(x, y, w, h) (* Just set it *)
  ELSE (* Flip Region exists, add to it *)
    IF x < flipRegion.x THEN flipRegion.x := x END;
    IF y < flipRegion.y THEN flipRegion.y := y END;
    IF x + w > flipRegion.x + flipRegion.w THEN
      flipRegion.w := w + x - flipRegion.x END;
    IF y + h > flipRegion.y + flipRegion.h THEN
      flipRegion.h := h + y - flipRegion.y END
  END
END AddRegion;

(* Drawing *)

PROCEDURE MakeCol*(r, g, b: INTEGER): INTEGER;
BEGIN (*!FIXME use MOD and ASH? *)
  r := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET32, r) * {0..7});
  g := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET32, g) * {0..7});
  b := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET32, b) * {0..7});
  RETURN SHORT(ASH(ASH(0FF00H + b, 8) + g, 8)) + r
END MakeCol;

PROCEDURE ColorToRGB*(color: INTEGER; VAR r, g, b: INTEGER);
BEGIN (*!FIXME use MOD and ASH? *)
  r := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET32, color) * {0..7});
  g := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET32, ASH(color, -8)) * {0..7});
  b := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET32, ASH(color, -16)) * {0..7})
END ColorToRGB;

PROCEDURE BmpCol*(bmp: Bitmap; r, g, b: INTEGER): INTEGER;
BEGIN
  RETURN SDL.MapRGB(bmp.surface.format, SHORT(r), SHORT(g), SHORT(b))
END BmpCol;

PROCEDURE ClearToColor*(bmp: Bitmap; color: INTEGER);
BEGIN
  SDL.FillRectNil(bmp.surface, color)
END ClearToColor;

PROCEDURE ClearBitmap*(bmp: Bitmap);
BEGIN
  ClearToColor(bmp, MakeCol(0, 0, 0))
END ClearBitmap;

PROCEDURE ClearScreenToColor*(color: INTEGER);
BEGIN
  ClearToColor(screen, color)
END ClearScreenToColor;

PROCEDURE ClearScreen*;
BEGIN
  ClearToColor(screen, MakeCol(0, 0, 0))
END ClearScreen;

PROCEDURE LockBitmap*(bmp: Bitmap);
BEGIN
  SDL.LockSurface(bmp.surface)
END LockBitmap;

PROCEDURE UnlockBitmap*(bmp: Bitmap);
BEGIN
  SDL.UnlockSurface(bmp.surface)
END UnlockBitmap;

PROCEDURE PutPixelFast*(bmp: Bitmap; x, y, color: INTEGER);
VAR n: SYSTEM.ADDRESS;
BEGIN n := SYSTEM.VAL(SYSTEM.ADDRESS, bmp.surface.pixels);
  INC(n, (y * bmp.w + x) * 4);
  SYSTEM.PUT(n, color)
END PutPixelFast;

PROCEDURE PutPixel*(bmp: Bitmap; x, y, color: INTEGER);
VAR n: SYSTEM.ADDRESS;
BEGIN
  IF (x >= 0) & (x < bmp.w) &
     (y >= 0) & (y < bmp.h) THEN
    SDL.LockSurface(bmp.surface);
    n := SYSTEM.VAL(SYSTEM.ADDRESS, bmp.surface.pixels);
    INC(n, (y * bmp.w + x) * 4);
    SYSTEM.PUT(n, color);
    SDL.UnlockSurface(bmp.surface)
  END
END PutPixel;

PROCEDURE GetPixel*(bmp: Bitmap; x, y: INTEGER): INTEGER;
VAR color: INTEGER;
  n: SYSTEM.ADDRESS;
BEGIN
  IF (x >= 0) & (x < bmp.w) &
     (y >= 0) & (y < bmp.h) THEN
    SDL.LockSurface(bmp.surface);
    n := SYSTEM.VAL(SYSTEM.ADDRESS, bmp.surface.pixels);
    INC(n, (y * bmp.w + x) * 4);
    SYSTEM.GET(n, color);
    SDL.UnlockSurface(bmp.surface)
  ELSE color := 0 END;
  RETURN color
END GetPixel;

PROCEDURE HLine*(bmp: Bitmap; x1, y, x2, color: INTEGER);
VAR rect: SDL.Rect; t: INTEGER;
BEGIN
  IF x1 > x2 THEN t := x1; x1 := x2; x2 := t END;
  rect.x := x1; rect.y := y;
  rect.w := x2 - x1 + 1; rect.h := 1;
  SDL.FillRect(bmp.surface, rect, color)
END HLine;

PROCEDURE VLine*(bmp: Bitmap; x, y1, y2, color: INTEGER);
VAR rect: SDL.Rect; t: INTEGER;
BEGIN
  IF y1 > y2 THEN t := y1; y1 := y2; y2 := t END;
  rect.x := x; rect.y := y1;
  rect.w := 1; rect.h := y2 - y1 + 1;
  SDL.FillRect(bmp.surface, rect, color)
END VLine;

PROCEDURE Line*(bmp: Bitmap; x1, y1, x2, y2, color: INTEGER);
VAR x, y, i, dx, dy, sx, sy, e: INTEGER; vert: BOOLEAN;
BEGIN
  IF x1 = x2 THEN VLine(bmp, x1, y1, y2, color)
  ELSIF y1 = y2 THEN HLine(bmp, x1, y1, x2, color)
  ELSE
    SDL.LockSurface(bmp.surface);
    dx := ABS(x1 - x2); dy := ABS(y1 - y2);
    IF x2 > x1 THEN sx := 1 ELSE sx := -1 END;
    IF y2 > y1 THEN sy := 1 ELSE sy := -1 END;
    x := x1; y := y1; vert := dy > dx;
    IF vert THEN i := dx; dx := dy; dy := i END;
    e := 2 * dy - dx;
    FOR i := 0 TO dx DO
      IF (x >= 0) & (x < bmp.w) &
         (y >= 0) & (y < bmp.h) THEN
        PutPixelFast(bmp, x, y, color)
      END;
      IF e >= 0 THEN
        IF vert THEN INC(x, sx) ELSE INC(y, sy) END;
        DEC(e, 2 * dx)
      END;
      IF vert THEN INC(y, sy) ELSE INC(x, sx) END;
      INC(e, 2 * dy)
    END;
    SDL.UnlockSurface(bmp.surface)
  END
END Line;

PROCEDURE FastLine*(bmp: Bitmap; x1, y1, x2, y2, color: INTEGER);
BEGIN
  (*Al.FastLine(bmp.bmp, x1, y1, x2, y2, color)*)
END FastLine;

PROCEDURE Rect*(bmp: Bitmap; x1, y1, x2, y2, color: INTEGER); (*!FIXME*)
VAR rect: SDL.Rect;
BEGIN
  rect.x := x1; rect.y := y1;
  rect.w := 1; rect.h := y2 - y1 + 1;
  SDL.FillRect(bmp.surface, rect, color);
  rect.x := x2;
  SDL.FillRect(bmp.surface, rect, color);
  rect.x := x1; rect.w := x2 - x1 + 1; rect.h := 1;
  SDL.FillRect(bmp.surface, rect, color);
  rect.y := y2;
  SDL.FillRect(bmp.surface, rect, color)
END Rect;

PROCEDURE RectFill*(bmp: Bitmap; x1, y1, x2, y2, color: INTEGER);
VAR rect: SDL.Rect;
BEGIN
  rect.x := x1; rect.y := y1;
  rect.w := x2 - x1 + 1; rect.h := y2 - y1 + 1;
  SDL.FillRect(bmp.surface, rect, color)
END RectFill;

PROCEDURE Circle*(bmp: Bitmap; x, y, r, color: INTEGER);
BEGIN
END Circle;

PROCEDURE CircleFill*(bmp: Bitmap; x, y, r, color: INTEGER);
BEGIN
END CircleFill;

PROCEDURE Ellipse*(bmp: Bitmap; x, y, rx, ry, color: INTEGER);
BEGIN
END Ellipse;

PROCEDURE EllipseFill*(bmp: Bitmap; x, y, rx, ry, color: INTEGER);
BEGIN
END EllipseFill;

PROCEDURE FloodFill*(bmp: Bitmap; x, y, color: INTEGER);
BEGIN
END FloodFill;

(* Bitmap *)

PROCEDURE (bmp: Bitmap) Finalize*;
BEGIN
END Finalize;

PROCEDURE CreateBitmap*(w, h: INTEGER): Bitmap;
VAR bmp: Bitmap;
    s: ARRAY 2560 OF CHAR;
BEGIN
  NEW(bmp);
  bmp.surface := SDL.CreateRGBSurface(0, w, h, 32,
    000000FFH, 0000FF00H, 00FF0000H, -1000000H);
  IF bmp.surface = NIL THEN
    GetError(s); Out.String(s); Out.Ln
  END;
  bmp.w := w;  bmp.h := h;
  RETURN bmp
END CreateBitmap;

PROCEDURE DestroyBitmap*(bmp: Bitmap);
BEGIN
  SDL.FreeSurface(bmp.surface)
END DestroyBitmap;

PROCEDURE LoadBitmap*(filename: ARRAY OF CHAR): Bitmap;
VAR bmp: Bitmap;
BEGIN        (* LoadBmp(filename) for BMP-only *)
  NEW(bmp); bmp.surface := SDL.ImgLoad(filename);
  IF bmp.surface = NIL THEN bmp := NIL
  ELSE bmp.w := bmp.surface.w; bmp.h := bmp.surface.h END;
  RETURN bmp
END LoadBitmap;

PROCEDURE Blit*(src, dest: Bitmap; sx, sy, sw, sh, dx, dy: INTEGER);
VAR a, b: SDL.Rect;
BEGIN a.x := sx; a.y := sy; a.w := sw; a.h := sh;
  b.x := dx; b.y := dy;
  SDL.BlitSurface(src.surface, a, dest.surface, b)
END Blit;

PROCEDURE BlitWhole*(src, dest: Bitmap; x, y: INTEGER);
VAR b: SDL.Rect;
BEGIN b.x := x; b.y := y;
  SDL.BlitSurfaceNil(src.surface, dest.surface, b)
END BlitWhole;

PROCEDURE StretchBlit*(src, dest: Bitmap; sx, sy, sw, sh, dx, dy, dw, dh: INTEGER);
VAR a, b: SDL.Rect;
BEGIN
  a.x := sx; a.y := sy; a.w := sw; a.h := sh;
  b.x := dx; b.y := dy; b.w := dw; b.h := dh;
  SDL.BlitScaled(src.surface, a, dest.surface, b)
END StretchBlit;

PROCEDURE MaskedBlit*(src, dest: Bitmap; sx, sy, dx, dy, w, h: INTEGER);
BEGIN
  (*Al.MaskedBlit(src.bmp, dest.bmp, sx, sy, dx, dy, w, h)*)
END MaskedBlit;

PROCEDURE DrawSpriteEx*(dest, sprite: Bitmap; x, y, mode: INTEGER; flip: SET);
BEGIN
  (*Al.DrawSpriteEx(dest.bmp, sprite.bmp, x, y, mode, flip)*)
END DrawSpriteEx;

PROCEDURE DrawCharacterEx*(dest, sprite: Bitmap; x, y, color, bg: INTEGER);
BEGIN
  (*Al.DrawCharacterEx(dest.bmp, sprite.bmp, x, y, color, bg)*)
END DrawCharacterEx;

PROCEDURE SetColorKey*(bmp: Bitmap; color: INTEGER);
BEGIN
  SDL.SetColorKey(bmp.surface, 1, color)
END SetColorKey;

(* Font *)

PROCEDURE LoadFont*(filename: ARRAY OF CHAR; charW, charH: INTEGER): Font;
VAR bmp: Bitmap; font: Font;
    x, y, sx, sy, tmp: INTEGER;
BEGIN
  bmp := LoadBitmap(filename);
  IF bmp = NIL THEN font := NIL
  ELSE
    bmp.surface := SDL.ConvertSurface(bmp.surface,
      screen.surface.format, 0);
    SetColorKey(bmp, BmpCol(bmp, 0, 0, 0));
    NEW(font); font.bmp := bmp;
    font.charW := charW; font.charH := charH;
    font.charsInRow := font.bmp.w DIV charW;
    font.charRows := font.bmp.h DIV charH;
    NEW(font.sprites, font.charRows, font.charsInRow);
    sy := 0;
    FOR y := 0 TO font.charRows - 1 DO
      sx := 0;
      FOR x := 0 TO font.charsInRow - 1 DO
        font.sprites[y, x].x := sx;
        font.sprites[y, x].y := sy;
        font.sprites[y, x].w := charW;
        font.sprites[y, x].h := charH;
        INC(sx, charW)
      END;
      INC(sy, charH)
    END
  END;
  RETURN font
END LoadFont;

PROCEDURE DrawCharacter*(dest: Bitmap; font: Font;
  x, y: INTEGER; ch: CHAR; fg: INTEGER);
VAR fx, fy, r, g, b: INTEGER; dstRect: SDL.Rect;
BEGIN
  dstRect.x := x; dstRect.y := y;
  fx := ORD(ch) MOD font.charsInRow;
  fy := ORD(ch) DIV font.charsInRow;
  ColorToRGB(fg, r, g, b);
  SDL.SetSurfaceColorMod(font.bmp.surface, r, g, b);
  SDL.BlitSurface(font.bmp.surface, font.sprites[fy, fx],
    screen.surface, dstRect)
END DrawCharacter;

PROCEDURE DrawString*(dest: Bitmap; font: Font;
  x, y: INTEGER; s: ARRAY OF CHAR; fg: INTEGER);
VAR i, cx: INTEGER;
BEGIN
  i := 0; cx := x;
  WHILE (s[i] # 0X) & (cx < dest.w) DO
    DrawCharacter(dest, font, cx, y, s[i], fg);
    INC(i); INC(cx, font.charW)
  END
END DrawString;

PROCEDURE StartTextInput*;
BEGIN SDL.StartTextInput
END StartTextInput;

PROCEDURE StopTextInput*;
BEGIN SDL.StopTextInput
END StopTextInput;

PROCEDURE QueueEvent;
BEGIN
  INC(events.len); INC(events.last);
  IF events.last = LEN(events.buf) THEN events.last := 0 END
END QueueEvent;

PROCEDURE PumpKeyDown(VAR event: SDL.Event);
VAR e: SDL.KeyboardEvent;
  n: INTEGER; mod: SET;
BEGIN
  IF events.len < LEN(events.buf) THEN
    e := SYSTEM.VAL(SDL.KeyboardEvent, SYSTEM.ADR(event));
    n := e.keysym.mod; mod := SYSTEM.VAL(SET32, n);
    QueueEvent;
    events.buf[events.last].type := keyDown;
    events.buf[events.last].key.code := e.keysym.scancode;
    events.buf[events.last].key.sym := e.keysym.sym;
    events.buf[events.last].key.mod := mod;
    events.buf[events.last].key.repeat := e.repeat # 0;
    INC(keyPressed)
  END
END PumpKeyDown;

PROCEDURE PumpTextEvent(event: SDL.Event);
VAR sym: INTEGER;
    e: SDL.TextInputEvent;
BEGIN
  IF events.len < LEN(events.buf) THEN
    e := SYSTEM.VAL(SDL.TextInputEvent, SYSTEM.ADR(event));
    IF e.text[1] = 0X THEN (* ASCII character *)
      sym := ORD(e.text[0])
    ELSE (* Unicode character. Assuming 2 bytes *)
      sym := ORD(e.text[1]);
      (* UTF-8 cyrillic *)
      IF (e.text[0] = 0D0X) OR (e.text[0] = 0D1X) THEN
        IF e.text[0] = 0D0X THEN DEC(sym, 090H)
        ELSE DEC(sym, 060H - 16)
        END;
        (* Convert to CP866 *)
        IF sym = 65 THEN sym := 0F1H (* jo *)
        ELSIF sym = -15 THEN sym := 0F0H (* JO *)
        ELSIF sym < 48 THEN INC(sym, 80H) (* A..JA, a..p *)
        ELSE INC(sym, 0E0H - 48) (* r..ja *)
        END
      END
    END;
    QueueEvent;
    events.buf[events.last].type := textInput;
    events.buf[events.last].key.sym := sym; (*!FIXME sym needed?*)
    COPY(e.text, events.buf[events.last].s)
  END
END PumpTextEvent;

PROCEDURE UpdateMousePos(event: SDL.Event);
VAR e: SDL.MouseMotionEvent; newX, newY: INTEGER;
BEGIN
  e := SYSTEM.VAL(SDL.MouseMotionEvent, SYSTEM.ADR(event));
  newX := e.x; newY := e.y;
  IF newX < 0 THEN newX := 0
  ELSIF newX >= screen.w THEN newX := screen.w - 1 END;
  IF newY < 0 THEN newY := 0
  ELSIF newY >= screen.h THEN newY := screen.h - 1 END;
  IF (newX # mouseX) OR (newY # mouseY) THEN
    mouseX := newX;  mouseY := newY;
    needRedrawMouse := TRUE
  END
END UpdateMousePos;

(* Keyboard *)

PROCEDURE GetKeyArray(): KeyArray;
BEGIN
  RETURN SYSTEM.VAL(KeyArray, SDL.GetKeyboardStateNil())
END GetKeyArray;

PROCEDURE KeyDown*(key: INTEGER): BOOLEAN;
VAR keys: KeyArray;
BEGIN
  keys := GetKeyArray();
  RETURN keys[key]
END KeyDown;

PROCEDURE AltPressed*(): BOOLEAN;
VAR keys: KeyArray;
BEGIN
  keys := GetKeyArray();
  RETURN keys[kAlt] OR keys[kAltGr]
END AltPressed;

PROCEDURE ShiftPressed*(): BOOLEAN;
VAR keys: KeyArray;
BEGIN
  keys := GetKeyArray();
  RETURN keys[kLShift] OR keys[kRShift]
END ShiftPressed;

PROCEDURE CtrlPressed*(): BOOLEAN;
VAR keys: KeyArray;
BEGIN
  keys := GetKeyArray();
  RETURN keys[kLCtrl] OR keys[kRCtrl]
END CtrlPressed;

(* Mouse *)

PROCEDURE MouseOnScreen*(): BOOLEAN;
VAR flags: SET;
BEGIN
  flags := SDL.GetWindowFlags(window);
  RETURN SDL.windowMouseFocus IN flags
END MouseOnScreen;

PROCEDURE ShowMouse*(show: BOOLEAN);
BEGIN
  showMouse := show
END ShowMouse;

PROCEDURE GetRealMousePos*(VAR x, y: INTEGER);
BEGIN
  IF SDL.GetMouseState(x, y) = 0 THEN END
END GetRealMousePos;

PROCEDURE GetMousePos*(VAR x, y: INTEGER);
BEGIN
  x := mouseX; y := mouseY
END GetMousePos;

PROCEDURE GetMouseButtons*(): SET;
VAR x, y: INTEGER;
BEGIN RETURN SYSTEM.VAL(SET32, SDL.GetMouseState(x, y))
END GetMouseButtons;

PROCEDURE CreateStdMousePointer*;
VAR b: Bitmap; fg, bg: INTEGER;
BEGIN b := CreateBitmap(12, 19);
  bg := MakeCol(255, 0, 255); fg := MakeCol(0, 0, 0);
  ClearToColor(b, bg); SetColorKey(b, bg);
  Line(b, 0, 0, 10, 10, fg); Line(b, 0, 0, 0, 14, fg);
  Line(b, 0, 14, 3, 11, fg); Line(b, 10, 10, 6, 10, fg);
  Line(b, 4, 12, 6, 17, fg); Line(b, 6, 11, 9, 17, fg);
  Line(b, 7, 18, 8, 18, fg); bg := MakeCol(255, 255, 255);
  VLine(b, 1, 2, 12, bg); VLine(b, 2, 3, 11, bg);
  VLine(b, 3, 4, 10, bg); VLine(b, 4, 5, 11, bg);
  VLine(b, 5, 6, 13, bg); VLine(b, 6, 7, 9, bg);
  VLine(b, 7, 8, 9, bg); VLine(b, 8, 9, 9, bg);
  VLine(b, 6, 12, 15, bg); VLine(b, 7, 14, 17, bg);
  VLine(b, 8, 16, 17, bg);
  stdMousePointer := b
END CreateStdMousePointer;

PROCEDURE SetMousePointer*(bmp: Bitmap);
BEGIN
  mousePointer := bmp;
  underMouse := CreateBitmap(mousePointer.w, mousePointer.h);
  needRedrawMouse := TRUE
END SetMousePointer;

PROCEDURE GetMousePointer*(): Bitmap;
BEGIN
  RETURN mousePointer
END GetMousePointer;

PROCEDURE SetMouseFocus*(x, y: INTEGER);
BEGIN
  mouseFocusX := x; mouseFocusY := y;
  needRedrawMouse := TRUE
END SetMouseFocus;

PROCEDURE SetStdMousePointer*;
BEGIN
  SetMousePointer(stdMousePointer);
  SetMouseFocus(0, 0)
END SetStdMousePointer;

PROCEDURE InitMouseData;
BEGIN
  CreateStdMousePointer;
  SetStdMousePointer
END InitMouseData;

(* Misc *)
PROCEDURE SetWindowTitle*(title: ARRAY OF CHAR);
BEGIN
  SDL.SetWindowTitle(window, title)
END SetWindowTitle;

PROCEDURE SwitchToWindowed*;
BEGIN
  IF wantFullscreen THEN
    SDL.SetWindowSize(window, screen.w, screen.h);
    IF SDL.SetWindowFullscreen(window, {}) = 0 THEN
      wantFullscreen := FALSE
    END
  END
END SwitchToWindowed;

PROCEDURE SwitchToFullscreen*;
BEGIN
  IF ~wantFullscreen THEN
    IF SDL.SetWindowFullscreen(window, SDL.windowFullscreenDesktop) = 0 THEN
      wantFullscreen := TRUE
    END
  END
END SwitchToFullscreen;

PROCEDURE ToggleFullscreen*;
BEGIN
  IF wantFullscreen THEN SwitchToWindowed
  ELSE SwitchToFullscreen
  END
END ToggleFullscreen;

PROCEDURE Delay*(n: INTEGER);
BEGIN
  SDL.Delay(n)
END Delay;

PROCEDURE HandleMouseButton(VAR event: SDL.Event);
VAR e: SDL.MouseButtonEvent;
BEGIN

END HandleMouseButton;

PROCEDURE PumpQuit;
BEGIN
  IF events.len < LEN(events.buf) THEN
    QueueEvent;
    events.buf[events.last].type := quit
  END
END PumpQuit;

PROCEDURE PumpMouseMove(VAR event: SDL.Event);
VAR e: SDL.MouseMotionEvent;
    newX, newY: INTEGER;
BEGIN
  e := SYSTEM.VAL(SDL.MouseMotionEvent, SYSTEM.ADR(event));
  newX := e.x; newY := e.y;
  IF newX < 0 THEN newX := 0
  ELSIF newX >= screen.w THEN newX := screen.w - 1
  END;
  IF newY < 0 THEN newY := 0
  ELSIF newY >= screen.h THEN newY := screen.h - 1
  END;
  IF (newX # mouseX) OR (newY # mouseY) THEN
    mouseX := newX; mouseY := newY;
    needRedrawMouse := TRUE;
    IF events.len < LEN(events.buf) THEN
      QueueEvent;
      events.buf[events.last].type := mouseMove;
      events.buf[events.last].x := newX;
      events.buf[events.last].y := newY;
      events.buf[events.last].xRel := e.xRel;
      events.buf[events.last].yRel := e.yRel;
      events.buf[events.last].buttons := SYSTEM.VAL(SET32, e.state)
    END
  END
END PumpMouseMove;

PROCEDURE PumpMouseButton(VAR event: SDL.Event; type: INTEGER);
VAR e: SDL.MouseButtonEvent;
BEGIN
  e := SYSTEM.VAL(SDL.MouseButtonEvent, SYSTEM.ADR(event));
  IF events.len < LEN(events.buf) THEN
    QueueEvent;
    events.buf[events.last].type := type;
    events.buf[events.last].button := e.button - 1;
    events.buf[events.last].down := e.state # 0;
    IF e.x < 0 THEN e.x := 0
    ELSIF e.x >= screen.w THEN e.x := screen.w - 1
    END;
    IF e.y < 0 THEN e.y := 0
    ELSIF e.y >= screen.h THEN e.y := screen.h - 1
    END;
    events.buf[events.last].x := e.x;
    events.buf[events.last].y := e.y
  END
END PumpMouseButton;

PROCEDURE RepeatFlip*;
BEGIN
  IF screenTexture # NIL THEN
    SDL.SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL.RenderClear(renderer);
    SDL.RenderCopyNil(renderer, screenTexture);
    SDL.RenderPresent(renderer)
  END
END RepeatFlip;

PROCEDURE WaitEvents*(timeout: INTEGER);
VAR event: SDL.Event; n: INTEGER;
BEGIN
  n := SDL.PollEvent(event);
  IF (n # 0) OR (events.len = 0) THEN
    IF n = 0 THEN
      IF timeout > 0 THEN n := SDL.WaitEventTimeout(event, timeout)
      ELSIF timeout < 0 THEN n := SDL.WaitEvent(event)
      END
    END;
    IF n # 0 THEN
      REPEAT
        IF event.type = SDL.mouseMotion THEN
          PumpMouseMove(event)
        ELSIF event.type = SDL.mouseButtonDown THEN
          PumpMouseButton(event, mouseDown)
        ELSIF event.type = SDL.mouseButtonUp THEN
          PumpMouseButton(event, mouseUp)
        ELSIF event.type = SDL.keyDown THEN
          PumpKeyDown(event)
        ELSIF event.type = SDL.textInput THEN
          PumpTextEvent(event)
        ELSIF event.type = SDL.quit THEN
          PumpQuit
        END
      UNTIL SDL.PollEvent(event) = 0
    END
  END
END WaitEvents;

PROCEDURE PollEvent*(VAR event: Event): BOOLEAN;
VAR hasEvent: BOOLEAN;
BEGIN
  IF events.len > 0 THEN
    event := events.buf[events.first];
    IF event.type = keyDown THEN DEC(keyPressed) END;
    DEC(events.len); INC(events.first);
    IF events.first = LEN(events.buf) THEN events.first := 0 END;
    hasEvent := TRUE
  ELSE hasEvent := FALSE
  END;
  RETURN hasEvent
END PollEvent;

PROCEDURE KeyPressed*(): BOOLEAN;
BEGIN
  WaitEvents(0);
  RETURN keyPressed > 0
END KeyPressed;

PROCEDURE ReadKey*(): CHAR;
VAR event: Event; done: BOOLEAN; ch: CHAR;
BEGIN done := FALSE;
  REPEAT
    WaitEvents(-1);
    WHILE PollEvent(event) DO
      CASE event.type OF
        keyDown: ch := CHR(event.key.sym); done := TRUE
      | quit: ch := 0X; done := TRUE
      ELSE
      END
    END
  UNTIL done;
  RETURN ch
END ReadKey;

PROCEDURE Pause*;
BEGIN IF ReadKey() = 0X THEN END
END Pause;

PROCEDURE WindowShown*(): BOOLEAN;
VAR flags: SET;
BEGIN
  flags := SDL.GetWindowFlags(window);
  RETURN SDL.windowShown IN flags
END WindowShown;

PROCEDURE GetTicks(): INTEGER;
BEGIN
  RETURN SDL.GetTicks()
END GetTicks;

PROCEDURE Flip*;
VAR mx, my: INTEGER; (* Mouse bitmap X Y *)
    blitMouse: BOOLEAN;
    dt: INTEGER; (* Delta time *)

  PROCEDURE PrepareMouse;
  BEGIN
    mx := mouseX - mouseFocusX;
    my := mouseY - mouseFocusY;
    (* Save image under mouse from buffer *)
    Blit(screen, underMouse, mx, my,
      underMouse.w, underMouse.h, 0, 0);
    (* Blit mouse pointer onto buffer *)
    Blit(mousePointer, screen, 0, 0,
      mousePointer.w, mousePointer.h, mx, my)
  END PrepareMouse;

  PROCEDURE CleanMouse;
  BEGIN
    (* Restore image under mouse in buffer *)
    Blit(underMouse, screen, 0, 0,
      underMouse.w, underMouse.h, mx, my);
    needRedrawMouse := FALSE
  END CleanMouse;

BEGIN
  IF wantFPS # -1 THEN
    IF lastFlip # -1 THEN
      dt := 1000 DIV wantFPS - (GetTicks() - lastFlip);
      IF (dt > 0) & (dt < 1000) THEN Delay(dt) END
    END;
    lastFlip := GetTicks()
  END;
  IF WindowShown() THEN
    mx := 0; my := 0;
    blitMouse := showMouse & MouseOnScreen();
    IF blitMouse THEN PrepareMouse END;

    (* Blit buffer on screen *)
    SDL.SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL.RenderClear(renderer);
    IF screenTexture # NIL THEN
      SDL.DestroyTexture(screenTexture);
      screenTexture := NIL
    END;
    screenTexture := SDL.CreateTextureFromSurface(renderer, screen.surface);
    SDL.RenderCopyNil(renderer, screenTexture);
    SDL.RenderPresent(renderer);

    IF blitMouse THEN CleanMouse END
  END
END Flip;

(* Sound *)

(*
PROCEDURE LoadSample*(filename: ARRAY OF CHAR): Sample;
VAR spl: Sample;
BEGIN
  NEW(spl);
  spl.chunk := Mix.LoadWavRW(SDL.RWFromFile(filename, 'rb'), 1);
  IF spl.chunk = NIL THEN spl := NIL END;
  RETURN spl
END LoadSample;

PROCEDURE PlayChannel*(spl: Sample; channel: INTEGER);
BEGIN
  IF spl # NIL THEN
    IF Mix.PlayChannelTimed(channel, spl.chunk, 0, -1) = 0 THEN END
  END
END PlayChannel;

PROCEDURE PlaySample*(spl: Sample);
BEGIN
  IF spl # NIL THEN PlayChannel(spl, -1) END
END PlaySample;

PROCEDURE StopSample*(spl: Sample);
BEGIN
  (*SDL.StopSample(spl)*)
END StopSample;

PROCEDURE LoadMusic*(filename: ARRAY OF CHAR): Music;
VAR mus: Music;
BEGIN
  NEW(mus); mus.music := Mix.LoadMus(filename);
  IF mus.music = NIL THEN mus := NIL END;
  RETURN mus
END LoadMusic;

PROCEDURE PlayMusic*(mus: Music);
BEGIN
  IF (mus # NIL) & (mus.music # NIL) THEN
    IF Mix.PlayMusic(mus.music, -1) = 0 THEN END
  END
END PlayMusic;

PROCEDURE StopMusic*;
BEGIN
  Mix.HaltMusic
END StopMusic;
*)

(* Net *)

(*
PROCEDURE OpenServer*(port: INTEGER): Socket;
VAR addr: IPAddress; socket: Socket;
BEGIN
  IF Net.ResolveHost(addr, NIL, SHORT(port)) = 0
  THEN socket := Net.TCPOpen(addr)
  ELSE socket := NIL END;
  RETURN socket
END OpenServer;

PROCEDURE CloseConn*(VAR socket: Socket);
BEGIN
  IF Net.TCPClose(socket) = 0 THEN socket := NIL END
END CloseConn;

PROCEDURE Accept*(server: Socket): Socket;
BEGIN
  RETURN Net.TCPAccept(server)
END Accept;

PROCEDURE ConnectTo*(ip: ARRAY OF CHAR; port: INTEGER): Socket;
VAR addr: IPAddress; socket: Socket;
BEGIN
  IF Net.ResolveHost(addr, ip, SHORT(port)) = 0
  THEN socket := Net.TCPOpen(addr)
  ELSE socket := NIL END;
  RETURN socket
END ConnectTo;

PROCEDURE SocketReady*(socket: Socket): BOOLEAN;
BEGIN
  RETURN (socket # NIL) & (socket.ready # 0)
END SocketReady;

PROCEDURE Send*(socket: Socket;
  data: ARRAY OF CHAR; len: INTEGER): INTEGER;
BEGIN
  RETURN Net.TCPSend(socket, data, len)
END Send;

PROCEDURE SendStr*(socket: Socket; s: ARRAY OF CHAR): INTEGER;
VAR len: INTEGER;
BEGIN len := 0;
  WHILE (len < LEN(s)) & (s[len] # 0X) DO INC(len) END;
  RETURN Net.TCPSend(socket, s, len)
END SendStr;

PROCEDURE Recv*(socket: Socket;
  VAR data: ARRAY OF CHAR; len: INTEGER): INTEGER;
BEGIN
  RETURN Net.TCPRecv(socket,
    SYSTEM.VAL(SYSTEM.PTR, SYSTEM.ADR(data[0])), len)
END Recv;

PROCEDURE RecvStr*(socket: Socket; VAR s: ARRAY OF CHAR): INTEGER;
VAR n: INTEGER;
BEGIN
  n := Recv(socket, s, LEN(s) - 1);
  IF n >= 0 THEN
    IF n >= LEN(s) THEN n := LEN(s) END;
    s[n] := 0X
  END;
  RETURN n
END RecvStr;
*)

(* Socket Set *)

(*
PROCEDURE AllocSocketSet*(maxSockets: INTEGER): SocketSet;
BEGIN
  RETURN Net.AllocSocketSet(maxSockets)
END AllocSocketSet;

PROCEDURE FreeSocketSet*(set: SocketSet);
BEGIN
  Net.FreeSocketSet(set)
END FreeSocketSet;

PROCEDURE AddSocket*(set: SocketSet; socket: Socket): INTEGER;
BEGIN
  RETURN Net.AddSocket(set, SYSTEM.VAL(Net.Socket, socket))
END AddSocket;

PROCEDURE DelSocket*(set: SocketSet; socket: Socket): INTEGER;
BEGIN
  RETURN Net.DelSocket(set, SYSTEM.VAL(Net.Socket, socket))
END DelSocket;

PROCEDURE CheckSockets*(set: SocketSet; timeout: INTEGER): BOOLEAN;
BEGIN
  RETURN Net.CheckSockets(set, timeout) # 0
END CheckSockets;
*)

(* NetBuf *)

(*
PROCEDURE InitNetBuf*(buf: NetBuf; size: INTEGER);
BEGIN
  NEW(buf.s, size); buf.len := 0; buf.lastLen := 0
END InitNetBuf;

PROCEDURE NewNetBuf*(size: INTEGER): NetBuf;
VAR buf: NetBuf;
BEGIN
  NEW(buf); InitNetBuf(buf, size); RETURN buf
END NewNetBuf;

PROCEDURE RecvBuf*(socket: Socket; buf: NetBuf);
VAR n, len: INTEGER; s: PStr;
BEGIN
  len := LEN(buf.s^) - buf.len;
  IF len = 0 THEN
    NEW(s, LEN(buf.s^) * 2); COPY(buf.s^, s^);
    buf.s := s
  END;
  n := Net.TCPRecv(socket,
    SYSTEM.VAL(SYSTEM.PTR, SYSTEM.ADR(buf.s[buf.len])),
    len);
  buf.lastLen := buf.len;
  IF n > 0 THEN
    INC(buf.len, n);
    IF buf.len > LEN(buf.s^) THEN buf.len := LEN(buf.s^) END
  END
END RecvBuf;

PROCEDURE BufGet*(buf: NetBuf; sep: CHAR;
  VAR s: ARRAY OF CHAR): BOOLEAN;
VAR i: INTEGER; found: BOOLEAN;
BEGIN i := SHORT(buf.lastLen);
  WHILE (i < buf.len) & (buf.s[i] # sep) DO INC(i) END;
  found := i < buf.len;
  IF found THEN
    S.Extract(buf.s^, 0, i, s);
    S.Delete(buf.s^, 0, i + 1);
    DEC(buf.len, i + 1); buf.lastLen := 0
  END;
  RETURN found
END BufGet;
*)

(* Random *)

PROCEDURE Time(): INTEGER;
BEGIN
  RETURN SHORT(Platform.Time())
END Time;

(* Set random seed value. Any values are allowed, although
   values not in [1..2^31-2] will be mapped into this range. *)
PROCEDURE PutSeed*(newSeed: INTEGER);
BEGIN
  newSeed := newSeed MOD randomModulo;
  IF newSeed = 0 THEN randomSeed := 1
  ELSE randomSeed := newSeed
  END
END PutSeed;

PROCEDURE NextRND;
CONST
  a = 16807;
  q = 127773; (* m div a *)
  r = 2836;   (* m mod a *)
VAR
  lo, hi, test: INTEGER;
BEGIN
  hi := randomSeed DIV q;
  lo := randomSeed MOD q;
  test := a * lo - r * hi;
  IF test > 0 THEN randomSeed := test
  ELSE randomSeed := test + randomModulo
  END
END NextRND;

(* Calculates a new number. range has to be in the intervall
   [1..2^31-2]. Result is a number from 0, 1, ... , range-1. *)
PROCEDURE Random*(range: INTEGER): INTEGER;
BEGIN
  NextRND;
  RETURN randomSeed MOD range
END Random;

(* Calculates a number x with 0.0 <= x < 1.0. *)
PROCEDURE Uniform*(): REAL;
BEGIN
  NextRND;
  RETURN (randomSeed - 1) * (1 / (randomModulo - 1))
END Uniform;

PROCEDURE Randomize*;
BEGIN
  PutSeed(Time())
END Randomize;

(* Init *)

PROCEDURE Init*(): Bitmap;
VAR flags: SET; success: BOOLEAN; w, h, nw, nh: INTEGER;
    s: ARRAY 2000 OF CHAR;
BEGIN screen := NIL;
  IF SDL.Init({SDL.initVideo}) = 0 THEN
    flags := {};
    IF wantFullscreen THEN
      flags := flags + SDL.windowFullscreenDesktop;
      IF (wantW <= 0) OR (wantH <= 0) THEN
        GetDesktopResolution(wantW, wantH)
      ELSIF wantSpread THEN
        GetDesktopResolution(w, h);
        IF wantSharpPixels THEN
          nw := w DIV wantW; nh := h DIV wantH;
          IF nw < nh THEN
            wantW := w DIV nw; wantH := h DIV nw;
          ELSE
            wantW := w DIV nh; wantH := h DIV nh;
          END
        END;
        IF w / h > wantW / wantH THEN wantW := w * wantH DIV h
        ELSE wantH := h * wantW DIV w
        END
      END
    ELSIF (wantW <= 0) OR (wantH <= 0) THEN wantW := 640; wantH := 400
    END;
    IF sizeStepX # 1 THEN wantW := wantW DIV sizeStepX * sizeStepX END;
    IF sizeStepY # 1 THEN wantH := wantH DIV sizeStepY * sizeStepY END;
    window := SDL.CreateWindow('',
      SDL.windowPosUndefined, SDL.windowPosUndefined,
      wantW, wantH, flags);
    IF window # NIL THEN
      IF wantSoftware THEN flags := {SDL.rendererSoftware}
      ELSE flags := {SDL.rendererAccelerated}
      END;
      INCL(flags, SDL.rendererPresentVsync);
      renderer := SDL.CreateRenderer(window, -1, flags);
      IF wantSharpPixels THEN
        SDL.SetHint(SDL.hintRenderScaleQuality, '0')
      ELSE
        SDL.SetHint(SDL.hintRenderScaleQuality, '1')
      END;
      SDL.RenderSetLogicalSize(renderer, wantW, wantH);
      screen := CreateBitmap(wantW, wantH);
      screenTexture := NIL;
      UnsetRegion;
      SDL.ShowCursor(0);
      IF wantMouse THEN InitMouseData END;
      flags := {SDL.imgInitPng, SDL.imgInitJpg};
      IF flags - SDL.ImgInit(flags) # {} THEN
        Out.String('Could not initialize PNG or JPG: ');
        GetError(s); Out.String(s); Out.Ln
      END;
      (*
      IF wantSound THEN
        IF Mix.Init({}) = 0 THEN
          IF Mix.OpenAudio(22050, Mix.defaultFormat,
             4, 1024) = 0 THEN END
        END
      END;
      IF wantNet THEN
        IF Net.Init() = 0 THEN END
      END
      *)
      Randomize;
      keyPressed := 0;
      lastFlip := -1
    END
  END;
  RETURN screen
END Init;

PROCEDURE Close*;
BEGIN
  IF screenTexture # NIL THEN
    SDL.DestroyTexture(screenTexture);
    screenTexture := NIL
  END;
  (*
  IF wantSound THEN Mix.Quit END;
  IF wantNet THEN Net.Quit END;
  *)
  SDL.Quit
END Close;

BEGIN
  wantW := 640; wantH := 400;
  sizeStepX := 1; sizeStepY := 1;
  wantFullscreen := TRUE; wantSpread := TRUE;
  wantBuffer := FALSE; buffer := NIL; wantFPS := 60;
  wantSharpPixels := TRUE;
  mousePointer := NIL; lastBlitMouseOutside := FALSE;
  mouseFocusX := 0; mouseFocusY := 0;
  events.first := 0; events.last := -1; events.len := 0;
  randomSeed := 1; keyPressed := 0
END Graph.

