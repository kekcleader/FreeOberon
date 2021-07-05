(* ETH Oberon, Copyright 2000 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethUnicode;  (* be *)

IMPORT SYSTEM;

PROCEDURE AND(a,b: LONGINT): LONGINT;
BEGIN RETURN SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, a) * SYSTEM.VAL(SET, b))
END AND;

(** UCStoUTF8 - converts a single unicode-character to one UTF-8 character. The UTF-8 character is written
  into 'utf8' starting at position 'pos' that points immediatly behind the inserted character.
  Returns TRUE if the conversion was successful *)
PROCEDURE UCStoUTF8*(ucs: LONGINT; VAR utf8: ARRAY OF CHAR; VAR pos: LONGINT): BOOLEAN;
VAR len: LONGINT;
  byte, mask, max, i: INTEGER;
  buf: ARRAY 6 OF CHAR;
BEGIN
  len := LEN(utf8);
  
  IF (ucs <= 7FH) THEN
    IF (pos + 1 < len) THEN utf8[pos] := CHR(SHORT(ucs));
      utf8[pos+1] := 0X;
      pos := pos + 1
    ELSE RETURN FALSE
    END  
  ELSE
    byte := 0; mask := 7F80H; max := 3FH;

    WHILE (ucs > max) DO
      buf[byte] := CHR(80H + SHORT(AND(ucs, 3FH))); INC(byte);
      ucs := ucs DIV 64; (* SYSTEM.LSH(ucs, -6) *)
      mask := mask DIV 2; (* 80H + SYSTEM.LSH(mask, -1) *)
      max := max DIV 2; (* SYSTEM.LSH(max, -1) *)    
    END;
    buf[byte] := CHR(mask + SHORT(ucs));

    IF (pos + byte + 1 < len) THEN    
      FOR i := 0 TO byte DO utf8[pos + i] := buf[byte - i] END;
      utf8[pos+byte+1] := 0X;
      pos := pos + byte + 1
    ELSE RETURN FALSE
    END
  END;
  RETURN TRUE
END UCStoUTF8;

(** UCS2toUTF8 - converts an array of 16-bit unicode characters to a UTF-8 string *)
PROCEDURE UCS2toUTF8*(VAR ucs2: ARRAY OF INTEGER; VAR utf8: ARRAY OF CHAR);
VAR i, p: LONGINT;
  b: BOOLEAN;
BEGIN
  b := TRUE; i := 0; p := 0;
  WHILE (i < LEN(ucs2)) & b DO
    b := UCStoUTF8(ucs2[i], utf8, p);
    INC(i)  
  END
END UCS2toUTF8;

(** UCS4toUTF8 - converts an array of 32-bit unicode characters to an UTF-8 string *)
PROCEDURE UCS4toUTF8*(VAR ucs4: ARRAY OF LONGINT; VAR utf8: ARRAY OF CHAR);
VAR i, p: LONGINT;
  b: BOOLEAN;
BEGIN
  b := TRUE; i := 0; p := 0;
  WHILE (i < LEN(ucs4)) & b DO
    b := UCStoUTF8(ucs4[i], utf8, p);
    INC(i)  
  END  
END UCS4toUTF8;

(** UTF8toUCS - converts the UTF-8 character in the string 'utf8' at position 'p' into an unicode character.
  Returns TRUE if the conversion was successful *)
PROCEDURE UTF8toUCS*(VAR utf8: ARRAY OF CHAR; VAR p: LONGINT; VAR ucs: LONGINT): BOOLEAN;
VAR b: LONGINT;
  bytes, mask, i: INTEGER;
  s: SET;
  res: BOOLEAN;
BEGIN
  res := FALSE;
  IF (p < LEN(utf8)) THEN 
    b := ORD(utf8[p]);
    IF (b < 80H) THEN ucs := b; INC(p); res := TRUE
    ELSE
      bytes := 2; mask := 3FH; s := SYSTEM.VAL(SET, b);
      WHILE ((7-bytes) IN s) DO INC(bytes); mask := mask DIV 2 END;
      ucs := AND(b, mask);
      IF (p + bytes - 1 < LEN(utf8))THEN
        FOR i := 1 TO bytes-1 DO ucs := ucs * 64 + AND(ORD(utf8[p+i]), 3FH) END;
        p := p + bytes;
        res := TRUE
      END
    END
  END;
  RETURN res
END UTF8toUCS;

(** UTF8toUCS2 - converts an UTF-8 string into an array of 16-bit unicode characters. The first character is placed
  at position 'idx'. Returns TRUE if the conversion was successful *)
PROCEDURE UTF8toUCS2*(VAR utf8: ARRAY OF CHAR; VAR ucs2: ARRAY OF INTEGER; VAR idx: LONGINT): BOOLEAN;
VAR p, ucs: LONGINT;
BEGIN
  p := 0; 
  WHILE UTF8toUCS(utf8, p, ucs) & (ucs > 0) & (idx < LEN(ucs2)-1) DO
    IF (ucs <= MAX(INTEGER)) THEN ucs2[idx] := SHORT(ucs)
    ELSE ucs2[0] := 0; RETURN FALSE
    END;
    INC(idx)
  END;
  IF (idx < LEN(ucs2)) THEN ucs2[idx] := 0; INC(idx) END;
  RETURN TRUE
END UTF8toUCS2;

(** UTF8toUCS4 - converts an UTF-8 string into an array of 32-bit unicode characters. The first character is placed
  at position 'idx'. Returns TRUE if the conversion was successful *)
PROCEDURE UTF8toUCS4*(VAR utf8: ARRAY OF CHAR; VAR ucs4: ARRAY OF LONGINT; VAR idx: LONGINT);
VAR p: LONGINT;
BEGIN
  p := 0;
  WHILE (idx < LEN(ucs4)) & UTF8toUCS(utf8, p, ucs4[idx]) & (ucs4[idx] > 0)  DO
    INC(idx)
  END;
  IF (idx < LEN(ucs4)) THEN ucs4[idx] := 0; INC(idx) END
END UTF8toUCS4;

(** UTF8toASCII - converts an UTF8-string into an ASCII-string. 'lossy' is TRUE if some information was lost during the
  conversion. Returns TRUE if the conversion was successful *)
PROCEDURE UTF8toASCII*(utf8: ARRAY OF CHAR; VAR ascii: ARRAY OF CHAR; VAR lossy: BOOLEAN): BOOLEAN;
VAR p, idx, ucs: LONGINT;
BEGIN
  p := 0; idx := 0; ucs := -1;
  WHILE (ucs # 0) & UTF8toUCS(utf8, p, ucs) & (idx < LEN(ascii)) DO
    IF (ucs >= 0) & (ucs < 256) THEN ascii[idx] := CHR(ucs)
    ELSE ascii[idx] := "_"
    END;
    INC(idx)
  END;
  IF (ascii[idx-1] # 0X) & (idx < LEN(ascii)) THEN ascii[idx] := 0X; INC(idx) END;
  RETURN ascii[idx-1] = 0X
END UTF8toASCII;

(** ASCIItoUTF8 - converts an ASCII-string into an UTF8-string *)
PROCEDURE ASCIItoUTF8*(ascii: ARRAY OF CHAR; VAR utf8: ARRAY OF CHAR);
VAR l, i: LONGINT;
  ucs: POINTER TO ARRAY OF INTEGER;
BEGIN
  l := 0; WHILE (ascii[l] # 0X) DO INC(l) END;
  NEW(ucs, l);
  FOR i := 0 TO l-1 DO ucs[i] := ORD(ascii[i]) END;
  UCS2toUTF8(ucs^, utf8)
END ASCIItoUTF8;

(** UpperCh - returns the upper case of a character. 'lossy' is TRUE if some information was lost during the conversion. *)
PROCEDURE UpperCh*(ch: CHAR; VAR lossy: BOOLEAN): CHAR;
BEGIN
  lossy := TRUE;
  CASE ch OF
    "a" .. "z": ch := CAP(ch); lossy := FALSE |
    "0".."9", "A".."Z", "€", "", "‚", "$", ".", "%", "'", "-", "_", "@", "~", "`", "!", "(", ")", "{", "}", "^", "#", "&": lossy := FALSE |
    "ƒ": ch := "€"; lossy := FALSE |
    "„": ch := ""; lossy := FALSE |
    "…": ch := "‚"; lossy := FALSE |
    "†": ch := "A" |
    "‡": ch := "E" |
    "ˆ": ch := "I" |
    "‰": ch := "O" |
    "Š": ch := "U" |
    "‹": ch := "A" |
    "Œ": ch := "E" |
    "": ch := "I" |
    "Ž": ch := "O" |
    "": ch := "U" |
    "": ch := "E" |
    "‘": ch := "E" |
    "’": ch := "I" |
    "“": ch := "C" |
    "”": ch := "A" |
    "•": ch := "N" |
    "–": ch := "S"
    ELSE
  END;
  RETURN ch
END UpperCh;

(** Length - returns the length of a string *)
PROCEDURE Length*(VAR s: ARRAY OF CHAR): LONGINT;
VAR p, l: LONGINT;
BEGIN
  l := LEN(s); p := 0;
  WHILE (p < l) & (s[p] # 0X) DO INC(p) END;
  RETURN p  
END Length;

(** Append - appends 'this' to 'to' *)
PROCEDURE Append*(VAR to: ARRAY OF CHAR; this: ARRAY OF CHAR);
VAR i, j, l: LONGINT;
BEGIN
  i := 0; WHILE to[i] # 0X DO INC(i) END;
  l := LEN(to)-1; j := 0;
  WHILE (i < l) & (this[j] # 0X) DO to[i] := this[j]; INC(i); INC(j) END;
  to[i] := 0X
END Append;

(** Prepend - appends 'to' to 'this' *)
PROCEDURE Prepend*(VAR to: ARRAY OF CHAR; this: ARRAY OF CHAR);
VAR tmp: POINTER TO ARRAY OF CHAR;
BEGIN
  NEW(tmp, LEN(to));
  COPY(this, tmp^);
  Append(tmp^, to);
  COPY(tmp^, to)
END Prepend;

END ethUnicode.
ÛBIER¸Éx:ZÿÿÿÿCOberon10.Scn.Fnt29.03.01  17:55:31TimeStamps.New€
