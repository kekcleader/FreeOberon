MODULE EditorText;
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
IMPORT Config, Files, Strings, Out;

CONST
  lineLen = 256;

TYPE
  String* = ARRAY lineLen OF CHAR;

  Line* = POINTER TO LineDesc;
  LineDesc* = RECORD
    s*: String;
    len*: INTEGER; (* Actual amount characters before 0X *)
    lineEndLen*: INTEGER; (* Character count of "CRLF" (1 or 2) *)
    comLevel*: INTEGER; (* Comment level in start of string *)
    prev*, next*: Line
  END;

  Text* = POINTER TO TextDesc;
  TextDesc* = RECORD
    x*, y*, scrY*: INTEGER; (* Cursor coordinates *)
    first*, last*, cur*: Line; (* First, last and current lines *)
    scrFirst*: Line; (* First line seen on screen *)
    selected*: BOOLEAN; (* Is something selected *)
    selL*, selR*, selT*, selB*: INTEGER; (* Selection left, right, top and bottom *)
    changed*: BOOLEAN
  END;

(* Line *)

PROCEDURE InitLine*(L: Line);
BEGIN
  L.s[0] := 0X; L.len := 0; L.comLevel := 0;
  L.prev := NIL; L.next := NIL
END InitLine;

PROCEDURE NewLine*(): Line;
VAR L: Line;
BEGIN
  NEW(L); InitLine(L); RETURN L
END NewLine;

PROCEDURE (L: Line) InsertChar*(ch: CHAR; pos: INTEGER);
VAR i: INTEGER;
BEGIN
  IF L.len + 1 < LEN(L.s) THEN (*!FIXME*)
    FOR i := L.len TO pos + 1 BY -1 DO L.s[i] := L.s[i - 1] END;
    L.s[pos] := ch;
    IF L.len = LEN(L.s) - 1 THEN L.s[L.len] := 0X
    ELSE INC(L.len); L.s[L.len] := 0X END
  END
END InsertChar;

PROCEDURE (L: Line) Delete(start, count: INTEGER);
VAR i: INTEGER;
BEGIN
  IF count > 0 THEN
    i := start;
    WHILE (i + count <= LEN(L.s)) & (L.s[i + count] # 0X) DO
      L.s[i] := L.s[i + count];
      INC(i)
    END;
    L.s[i] := 0X;
    DEC(L.len, count)
  END
END Delete;

(* Text *)

PROCEDURE InitText*(t: Text);
BEGIN
  t.cur := NewLine();
  t.first := t.cur; t.last := t.cur;
  t.scrFirst := t.cur;
  t.x := 0; t.y := 0; t.scrY := 0;
  t.selected := FALSE; t.changed := FALSE
END InitText;

PROCEDURE NewText*(): Text;
VAR t: Text;
BEGIN
  NEW(t); InitText(t); RETURN t
END NewText;

PROCEDURE (t: Text) RemoveLine(L: Line);
BEGIN
  IF L.prev # NIL THEN L.prev.next := L.next END;
  IF L.next # NIL THEN L.next.prev := L.prev END;
  t.changed := TRUE
END RemoveLine;

(* Объединить данную строку со следующей, прицепив её к данной *)
PROCEDURE (t: Text) Combine2Lines(L: Line);
VAR i: INTEGER;
BEGIN
  ASSERT(L.next # NIL, 101);
  i := 0;
  WHILE i <= L.next.len DO L.s[i + L.len] := L.next.s[i]; INC(i) END;
  INC(L.len, L.next.len);
  IF L.next = t.last THEN t.last := L END;
  t.RemoveLine(L.next)
END Combine2Lines;

PROCEDURE (t: Text) GetFirstSelLine*(): Line;
VAR y: INTEGER; L: Line;
BEGIN
  y := t.y; L := t.cur;
  WHILE y > t.selT DO L := L.prev; DEC(y) END;
  WHILE y < t.selT DO L := L.next; INC(y) END;
  RETURN L
END GetFirstSelLine;

PROCEDURE (t: Text) SelectAll*;
VAR count: INTEGER; L: Line;
BEGIN t.selected := TRUE;
  t.selT := 0; t.selL := 0;
  L := t.first; WHILE L # NIL DO INC(count); L := L.next END;
  t.selB := count;
  t.selR := 5
END SelectAll;

(**Returns true if at least one whole line is selected,
   but leading spaces may still be unselected*)
PROCEDURE (t: Text) WholeLineSelected*(): BOOLEAN;
VAR L: Line;
  i: INTEGER;
  res: BOOLEAN;
BEGIN res := FALSE;
  IF t.selected THEN
    IF t.selT # t.selB THEN res := TRUE
    ELSE
      L := t.GetFirstSelLine();
      IF t.selR = L.len THEN
        i := 0;
        WHILE (i # t.selL) & (L.s[i] = ' ') DO INC(i) END;
        IF i = t.selL THEN res := TRUE END
      END
    END
  END;
RETURN res END WholeLineSelected;

PROCEDURE (t: Text) RemoveIndent*;
VAR L: Line;
  i, y, endY: INTEGER;
BEGIN
  L := t.GetFirstSelLine(); y := t.selT;
  endY := t.selB;
  IF t.selR = 0 THEN DEC(endY) END;
  WHILE y <= endY DO
    FOR i := 1 TO 2 DO
      IF L.s[0] = ' ' THEN
        L.Delete(0, 1);
        IF (y = t.selT) & (t.selL # 0) THEN
          DEC(t.selL);
          IF t.y = t.selT THEN DEC(t.x) END
        ELSIF (y = t.selB) & (t.selR # 0) THEN
          DEC(t.selR);
          IF (t.y # t.selT) & (t.y = t.selB) THEN DEC(t.x) END
        END
      END
    END;
    L := L.next; INC(y)
  END
END RemoveIndent;

PROCEDURE (t: Text) AddIndent*;
VAR L: Line;
  i, y, endY: INTEGER;
BEGIN
  L := t.GetFirstSelLine();
  y := t.selT;
  endY := t.selB;
  IF t.selR = 0 THEN DEC(endY) END;
  WHILE y <= endY DO
    FOR i := 1 TO 2 DO IF L.len # 0 THEN L.InsertChar(' ', 0) END END;
    L := L.next; INC(y)
  END;
  INC(t.selL, 2);
  IF t.selT = t.y THEN INC(t.x, 2) END;
  IF t.selR # 0 THEN
    INC(t.selR, 2);
    IF (t.selT # t.y) & (t.selB = t.y) THEN INC(t.x, 2) END
  END
END AddIndent;

PROCEDURE (t: Text) DeleteSelection*;
VAR x0, x, y: INTEGER; L0, L: Line;
BEGIN
  IF t.selected THEN
    L := t.GetFirstSelLine();
    L0 := L; y := t.selT; 
    WHILE y < t.selB DO L := L.next; INC(y) END;
    L0.next := L.next;
    IF L.next = NIL THEN t.last := L0
    ELSE L.next.prev := L0 END;

    x0 := t.selL; x := t.selR;
    WHILE L.s[x] # 0X
    DO L0.s[x0] := L.s[x]; INC(x0); INC(x) END;
    L0.s[x0] := 0X; L0.len := x0;

    t.cur := L0; t.y := t.selT; t.x := t.selL;
    IF (t.scrY >= t.selT) & (t.scrY <= t.selB) THEN
      t.scrFirst := t.cur; t.scrY := t.y
    END;
    t.selected := FALSE;
    t.changed := TRUE
  END
END DeleteSelection;

PROCEDURE (t: Text) HandleBackspace*;
BEGIN
  IF t.selected THEN t.DeleteSelection
  ELSIF t.x > 0 THEN
    DEC(t.x); t.cur.Delete(t.x, 1);
    t.changed := TRUE
  ELSIF t.cur.prev # NIL THEN (* Курсор в начале строки и перед ней есть ещё строка *)
    t.cur := t.cur.prev;
    DEC(t.y); t.x := t.cur.len;
    t.Combine2Lines(t.cur);
    t.changed := TRUE
  END
END HandleBackspace;

PROCEDURE (t: Text) HandleDelete*;
BEGIN
  IF t.selected THEN
    t.DeleteSelection;
    t.selected := FALSE
  ELSIF t.x < t.cur.len THEN
    t.cur.Delete(t.x, 1)
  ELSIF t.cur.next # NIL THEN (* Курсор в конце строки и после неё есть ещё строка *)
    t.Combine2Lines(t.cur)
  END
END HandleDelete;

PROCEDURE (t: Text) HandleEnter*(autoIndent: BOOLEAN);
VAR L: Line; i, spaces: INTEGER;
BEGIN
  L := NewLine(); spaces := 0;
  IF t.x = 0 THEN (* Начало строки *)
    IF t.cur.prev # NIL THEN t.cur.prev.next := L END;
    L.next := t.cur; L.prev := t.cur.prev;
    t.cur.prev := L;
    IF t.first = t.cur THEN t.first := L END;
    IF t.scrFirst = t.cur THEN t.scrFirst := L END
  ELSE (* Середина или конец строки *)
    IF autoIndent THEN
      WHILE (spaces < t.cur.len) & (t.cur.s[spaces] = ' ')
      DO INC(spaces) END;
      FOR i := 0 TO spaces - 1 DO L.s[i] := ' ' END
    END;
    IF t.x < t.cur.len THEN (* Перенести вторую часть строки *)
      FOR i := 0 TO t.cur.len - t.x - 1 DO
        L.s[i + spaces] := t.cur.s[i + t.x]
      END
    END;
    L.len := t.cur.len + spaces - t.x;
    t.cur.s[t.x] := 0X; t.cur.len := t.x;
    IF t.cur.next # NIL THEN t.cur.next.prev := L END;
    L.next := t.cur.next; L.prev := t.cur; t.cur.next := L;
    IF t.last = t.cur THEN t.last := L END;
    t.cur := L
  END;
  t.x := spaces; INC(t.y);
  t.changed := TRUE
END HandleEnter;

PROCEDURE (t: Text) InsertChar*(ch: CHAR);
BEGIN
  t.cur.InsertChar(ch, t.x);
  INC(t.x);
  t.changed := TRUE
END InsertChar;

PROCEDURE (t: Text) Insert*(s: ARRAY OF CHAR; autoIndent: BOOLEAN);
VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) DO
    IF s[i] = 0AX THEN (* Line Feed *)
      t.HandleEnter(autoIndent)
    ELSE
      t.InsertChar(s[i])
    END;
    INC(i)
  END
END Insert;

PROCEDURE (t: Text) Clear*;
BEGIN
  t.cur := NewLine(); t.first := t.cur;
  t.last := t.cur; t.scrFirst := t.cur;
  t.x := 0; t.y := 0;
  t.selected := FALSE;
  t.changed := TRUE
END Clear;

PROCEDURE (t: Text) CopySelection*(VAR buf: ARRAY OF CHAR);
VAR i, x, len, y: INTEGER; L: Line;
BEGIN
  L := t.GetFirstSelLine();
  y := t.selT; i := 0; x := t.selL;
  WHILE y <= t.selB DO (* TODO: Use Dijkstra's loop *)
    IF y = t.selB THEN len := t.selR
    ELSE len := L.len END;
    WHILE (i < LEN(buf) - 1) & (x < len) DO
      buf[i] := L.s[x]; INC(i); INC(x)
    END;
    L := L.next; INC(y); x := 0;
    IF (y <= t.selB) & (i < LEN(buf) - 1) THEN
      buf[i] := 0AX; INC(i)
    END
  END;
  buf[i] := 0X
END CopySelection;

PROCEDURE WriteString(VAR r: Files.Rider; s: ARRAY OF CHAR);
VAR i: INTEGER; ch: CHAR;
BEGIN
  i := 0; s[LEN(s) - 1] := 0X;
  WHILE s[i] # 0X DO
    ch := s[i];
    IF ORD(ch) < 128 THEN Files.Write(r, ch) (* ASCII *)
    ELSIF ORD(ch) = 240 THEN (* Big cyrillic Yo *)
      Files.Write(r, 0D0X); Files.Write(r, 81X)
    ELSIF ORD(ch) < 224 THEN (* Before small cyrillic R *)
      Files.Write(r, 0D0X);
      Files.Write(r, CHR(ORD(ch) - 128 + 090H))
    ELSE
      Files.Write(r, 0D1X);
      Files.Write(r, CHR(ORD(ch) - 224 + 080H))
    END;
    INC(i)
  END
END WriteString;

PROCEDURE WriteLn(VAR r: Files.Rider);
BEGIN
  IF Config.isWindows THEN Files.Write(r, 0DX) END;
  Files.Write(r, 0AX)
END WriteLn;

PROCEDURE (t: Text) SaveToFile*(fName: ARRAY OF CHAR): BOOLEAN;
VAR f: Files.File; r: Files.Rider;
  success: BOOLEAN;
  fPath: ARRAY 1024 OF CHAR;
  L: Line;
BEGIN
  success := FALSE;
  COPY('Programs/', fPath);
  Strings.Append(fName, fPath);
  f := Files.New(fPath);
  IF f # NIL THEN (*!FIXME error checking is wrong *)
    Files.Set(r, f, 0);
    L := t.first;
    WHILE L # NIL DO
      WriteString(r, L.s);
      IF L.next # NIL THEN
        WriteLn(r);
        IF Config.isWindows THEN L.lineEndLen := 2 (*!FIXME*)
        ELSE L.lineEndLen := 1
        END
      END;
      L := L.next
    END;
    Files.Register(f);
    Files.Close(f);
    t.changed := FALSE;
    success := TRUE
  END;
  RETURN success
END SaveToFile;

PROCEDURE ReadLine(VAR r: Files.Rider; L: Line);
VAR ch: CHAR; i: INTEGER;
BEGIN
  i := 0;
  Files.Read(r, ch);
  WHILE ~r.eof & (i < LEN(L.s) - 1) & (ch # 0AX) & (ch # 0DX) DO
    IF ORD(ch) < 128 THEN L.s[i] := ch
    ELSIF ch = 0D0X THEN
      Files.Read(r, ch);
      IF ch = 081X THEN L.s[i] := CHR(240) (* Big Yo *)
      ELSE L.s[i] := CHR(ORD(ch) - 16)
      END
    ELSIF ch = 0D1X THEN
      Files.Read(r, ch); L.s[i] := CHR(ORD(ch) + 96)
    END;
    Files.Read(r, ch);
    INC(i)
  END;
  L.s[i] := 0X;
  IF ch = 0DX THEN
    L.lineEndLen := 2; (* Assume CRLF (DOS) *)
    Files.Read(r, ch) (* Skip LF *)
  ELSE L.lineEndLen := 1 (* Assume LF (UNIX) *)
  END
END ReadLine;

PROCEDURE (t: Text) LoadFromFile*(fName: ARRAY OF CHAR): BOOLEAN;
VAR f: Files.File; r: Files.Rider;
  success: BOOLEAN;
  fPath: ARRAY 1024 OF CHAR;
  L: Line;
BEGIN
  success := FALSE;
  IF fName[0] # 0X THEN
    COPY('Programs/', fPath);
    Strings.Append(fName, fPath);
    f := Files.Old(fPath);
    IF f # NIL THEN
      Files.Set(r, f, 0);
      L := NewLine();
      t.first := L; t.cur := L; t.scrFirst := L;
      ReadLine(r, L);
      L.len := Strings.Length(L.s);
      WHILE ~r.eof DO
        L.next := NewLine();
        L.next.prev := L;
        L := L.next;
        ReadLine(r, L);
        L.len := Strings.Length(L.s)
      END;
      t.last := L; t.x := 0; t.y := 0; t.scrY := 0;
      t.selected := FALSE;
      Files.Close(f);
      t.changed := FALSE;
      success := TRUE
    END
  END;
  RETURN success
END LoadFromFile; 

PROCEDURE (t: Text) MoveToPos*(pos: INTEGER);
CONST centerY = 6;
VAR i: INTEGER; L: Line;
BEGIN
  L := t.first; t.x := 0; t.y := 0;
  REPEAT
    WHILE (L.s[t.x] # 0X) & (pos > 0) DO
      IF (ORD(L.s[t.x]) > 127) & (pos >= 2) THEN DEC(pos, 2)
      ELSE DEC(pos)
      END;
      INC(t.x)
    END;
    IF (pos >= L.lineEndLen) & (L.next # NIL) THEN
      DEC(pos, L.lineEndLen); L := L.next; INC(t.y); t.x := 0
    END
  UNTIL (L.next = NIL) OR (pos = 0);
  IF t.x < L.len THEN INC(t.x) END;
  t.cur := L;

  i := centerY;
  WHILE (L.prev # NIL) & (i > 0) DO L := L.prev; DEC(i) END;
  t.scrY := t.y - centerY + i; t.scrFirst := L
END MoveToPos;

END EditorText.
