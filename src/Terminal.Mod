MODULE Terminal;
(* Copyright 2017-2021 Arthur Yefimov

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
IMPORT G := Graph, Out;
CONST
  charW* = 8; charH* = 16;
  cursorTicks* = 10; (* Ticks before cursor flashes *)

TYPE
  CHAR = SHORTCHAR;
  ScreenChar* = RECORD
    ch*: CHAR;
    fg*, bg*: INTEGER; (* Цвет текста и цвет фона*)
    updated*: BOOLEAN
  END;
  ScreenChars* = POINTER TO ARRAY OF ARRAY OF ScreenChar;

VAR
  screen*: G.Bitmap;
  charsX-, charsY-: INTEGER;
  font: G.Font;

  chars: ScreenChars;
  cursorX-, cursorY-: INTEGER;
  cursorOn-, cursorShown: BOOLEAN;
  insertCursor: BOOLEAN;
  cursorTick: INTEGER; (* To show and hide cursor all the time *)
  mouseX-, mouseY-: INTEGER; (* In chars *)
  needRedraw: BOOLEAN;

  isFullscreen-: BOOLEAN;

PROCEDURE Redraw*;
BEGIN needRedraw := TRUE
END Redraw;

PROCEDURE ToggleFullscreen*;
BEGIN
  IF isFullscreen THEN G.SwitchToWindowed ELSE G.SwitchToFullscreen END;
  Redraw;
  isFullscreen := ~isFullscreen
END ToggleFullscreen;

PROCEDURE ExpandColor*(color: INTEGER): INTEGER;
VAR r, g, b: INTEGER;
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
  ELSE  b :=  85; g :=   0; r := 255
  END;
  RETURN G.MakeCol(r, g, b)
END ExpandColor;

PROCEDURE InvertColor*(color: INTEGER): INTEGER;
BEGIN
  ASSERT((color >= 0) & (color < 16), 59);
  IF color >= 8 THEN color := color - 8 END; (* Darken *)
  color := 7 - color; (* Invert *)
  RETURN color
END InvertColor;

PROCEDURE DrawChar*(ch: CHAR; x, y, fg, bg: INTEGER);
VAR color: INTEGER;
BEGIN
  G.RectFill(screen, x, y, x + charW - 1,
    y + charH - 1, ExpandColor(bg));
  IF ch # ' ' THEN
    G.DrawCharacter(screen, font, x, y, ch, ExpandColor(fg))
  END
END DrawChar;

PROCEDURE DrawMouse;
VAR x, y, bg, fg: INTEGER; ch: CHAR;
BEGIN
  IF (mouseX >= 0) & (mouseX < charsX) &
     (mouseY >= 0) & (mouseY < charsY) THEN
    bg := InvertColor(chars[mouseY, mouseX].bg);
    fg := InvertColor(chars[mouseY, mouseX].fg);
    ch := chars[mouseY, mouseX].ch
  ELSE bg := 6; fg := 0; ch := ' ' END;
  x := mouseX * charW; y := mouseY * charH;
  DrawChar(ch, x, y, fg, bg)
END DrawMouse;

(* Draws characters that have been changed, and the mouse.
   Returns TRUE if anything has been drawn. *)
PROCEDURE Draw*(): BOOLEAN;
VAR x, y, color: INTEGER;
    drawn: BOOLEAN;
BEGIN
  drawn := needRedraw;
  IF needRedraw THEN
    needRedraw := FALSE;
    (* Chars *)
    FOR y := 0 TO charsY - 1 DO
      FOR x := 0 TO charsX - 1 DO
        IF chars[y, x].updated THEN
          chars[y, x].updated := FALSE;
          DrawChar(chars[y, x].ch, x * charW, y * charH,
            chars[y, x].fg, chars[y, x].bg)
        END
      END
    END;
    (* Text Cursor *)
    IF cursorShown THEN
      color := ExpandColor(chars[cursorY, cursorX].fg);
      x := cursorX * charW; y := cursorY * charH;
      IF insertCursor THEN
        G.RectFill(screen, x, y, x + charW - 1, y + charH - 1, color) (*!FIXME*)
      ELSE
        INC(y, charH);
        G.RectFill(screen, x, y - 2, x + charW - 1, y - 1, color)
      END
    END;
    DrawMouse
  END;
  RETURN drawn
END Draw;

PROCEDURE Act*;
BEGIN
  IF cursorOn THEN (* Cursor blink: *)
    IF cursorTick >= cursorTicks THEN
      needRedraw := TRUE;
      IF cursorShown THEN chars[cursorY, cursorX].updated := TRUE END;
      cursorTick := 0; cursorShown := ~cursorShown
    ELSE INC(cursorTick)
    END
  END
END Act;

PROCEDURE ResetCursorBlink*;
BEGIN
  IF cursorOn THEN
    needRedraw := TRUE;
    chars[cursorY, cursorX].updated := TRUE;
    cursorTick := 0; cursorShown := TRUE
  END
END ResetCursorBlink;

PROCEDURE ShowCursor*(show: BOOLEAN);
BEGIN
  IF cursorOn # show THEN
    cursorOn := show; cursorShown := show;
    chars[cursorY, cursorX].updated := TRUE;
    needRedraw := TRUE
  END
END ShowCursor;

PROCEDURE GoToXY*(x, y: INTEGER);
BEGIN
  IF x < 0 THEN x := 0 ELSIF x >= charsX THEN x := charsX - 1 END;
  IF y < 0 THEN y := 0 ELSIF y >= charsY THEN y := charsY - 1 END;
  chars[cursorY, cursorX].updated := TRUE;
  cursorX := x; cursorY := y;
  needRedraw := TRUE
END GoToXY;

PROCEDURE MouseXY*(x, y: INTEGER);
BEGIN
  needRedraw := TRUE;
  chars[mouseY, mouseX].updated := TRUE;
  mouseX := x; mouseY := y;
  chars[mouseY, mouseX].updated := TRUE
END MouseXY;

PROCEDURE ResizeScreen;
BEGIN
  NEW(chars, charsY, charsX)
END ResizeScreen;

PROCEDURE SetCharColor*(x, y: INTEGER; fg, bg: INTEGER);
BEGIN
  IF (x >= 0) & (y >= 0) & (x < charsX) & (y < charsY) &
     ((chars[y, x].fg # fg) OR
      (chars[y, x].bg # bg)) THEN
    chars[y, x].fg := fg;
    chars[y, x].bg := bg;
    chars[y, x].updated := TRUE;
    needRedraw := TRUE
  END
END SetCharColor;

PROCEDURE PutChar*(x, y: INTEGER; ch: CHAR; fg, bg: INTEGER);
BEGIN
  IF (x >= 0) & (y >= 0) & (x < charsX) & (y < charsY) &
     ((chars[y, x].ch # ch) OR
      (chars[y, x].fg # fg) OR
      (chars[y, x].bg # bg) OR
      (cursorX = x) & (cursorY = y)) THEN
    chars[y, x].ch := ch;
    chars[y, x].fg := fg;
    chars[y, x].bg := bg;
    chars[y, x].updated := TRUE;
    needRedraw := TRUE
  END
END PutChar;

PROCEDURE PutString*(x, y: INTEGER; s: ARRAY OF CHAR; fg, bg, limit: INTEGER);
VAR i: INTEGER;
BEGIN
  needRedraw := TRUE;
  IF limit = 0 THEN limit := charsX END; 
  i := 0;
  WHILE (i < SHORT(LEN(s))) & (s[i] # 0X) & (x <= limit) DO
    PutChar(x, y, s[i], fg, bg);
    INC(i); INC(x)
  END
END PutString;

PROCEDURE CharFill*(x, y, w, h: INTEGER; ch: CHAR; fg, bg: INTEGER);
VAR X, Y: INTEGER;
BEGIN
  needRedraw := TRUE;
  FOR Y := y TO y + h - 1 DO
    FOR X := x TO x + w - 1 DO
      PutChar(X, Y, ch, fg, bg)
    END
  END
END CharFill;

PROCEDURE ClearScreen*;
VAR x, y: INTEGER;
BEGIN
  needRedraw := TRUE;
  FOR y := 0 TO charsY - 1 DO
    FOR x := 0 TO charsX - 1 DO
      IF (chars[y, x].ch # ' ') OR
         (chars[y, x].fg # 7) OR
         (chars[y, x].bg # 0) THEN
        chars[y, x].ch := ' ';
        chars[y, x].fg := 7;
        chars[y, x].bg := 0;
        chars[y, x].updated := TRUE
      END
    END
  END
END ClearScreen;

PROCEDURE ScrollScreen(lines: INTEGER);
VAR x, y: INTEGER;
BEGIN
  needRedraw := TRUE;
  FOR y := 0 TO charsY - 1 - lines DO
    FOR x := 0 TO charsX - 1 DO
      chars[y, x] := chars[y + lines, x];
      chars[y, x].updated := TRUE
    END
  END;
  CharFill(0, charsY - lines, charsX, lines, ' ', 7, 0) (*!FIXME colors*)
END ScrollScreen;

PROCEDURE Ln*;
BEGIN
  needRedraw := TRUE;
  chars[cursorY, cursorX].updated := TRUE;
  cursorX := 0;
  IF cursorY = charsY - 1 THEN ScrollScreen(1)
  ELSE INC(cursorY) END
END Ln;

PROCEDURE Backspace*;
BEGIN
  needRedraw := TRUE;
  chars[cursorY, cursorX].updated := TRUE;
  IF cursorX # 0 THEN DEC(cursorX)
  ELSIF cursorY # 0 THEN cursorX := charsX - 1; DEC(cursorY)
  END;
  chars[cursorY, cursorX].ch := ' ';
  chars[cursorY, cursorX].updated := TRUE
END Backspace;

PROCEDURE Write*(ch: CHAR);
BEGIN
  needRedraw := TRUE;
  IF ch = 0AX THEN Ln
  ELSIF ch # 0DX THEN
    PutChar(cursorX, cursorY, ch, 7, 0);
    IF cursorX = charsX - 1 THEN Ln
    ELSE INC(cursorX) END
  END
END Write;

PROCEDURE WriteString*(s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0; needRedraw := TRUE;
  IF cursorShown THEN chars[cursorY, cursorX].updated := TRUE END;
  WHILE s[i] # 0X DO Write(s[i]); INC(i) END
END WriteString;

PROCEDURE LoadMedia(): BOOLEAN;
VAR success: BOOLEAN;
BEGIN
  font := G.LoadFont('data/images/font.bmp', charW, charH);
  success := font # NIL;
  RETURN success
END LoadMedia;

PROCEDURE Init*(fullscreen, software: BOOLEAN): BOOLEAN;
VAR success: BOOLEAN; options: SET;
BEGIN
  success := FALSE; isFullscreen := fullscreen;
  options := {G.buffered, G.initMouse, G.spread};
  IF fullscreen THEN INCL(options, G.fullscreen) END;
  IF software THEN INCL(options, G.software) END;
  G.Settings(768, 432, options);
  G.SetSizeStep(charW, charH);
  screen := G.Init();
  IF screen # NIL THEN
    G.SetWindowTitle('Free Oberon');
    G.ShowMouse(FALSE);
    charsX := screen.w DIV charW;
    charsY := screen.h DIV charH;
    IF LoadMedia() THEN
      success := TRUE;
      needRedraw := TRUE;
      insertCursor := FALSE;
      cursorOn := FALSE;
      cursorShown := FALSE;
      cursorX := 1; cursorY := 2;
      mouseX := 0; mouseY := 0;
      ResizeScreen
    END
  END;
  RETURN success
END Init;

END Terminal.
