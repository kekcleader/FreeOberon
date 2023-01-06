MODULE In;

(*!FIXME From the Oakwood guidlines:
  An unsuccessful input operation sets Done to FALSE;
  it remains FALSE until the next call to Open. *)

IMPORT Platform, SYSTEM, Reals, Out, Utf8;

CONST
  pending = 0; (* readState when at start of input or end of line. Implies nextch undefined. *)
  ready   = 1; (* readState when nextch is defined and contains next character on current line. *)
  eof     = 2; (* readState when at end of file. *)

  (* Codepages, values of cp *)
  singleByte = 1;
  utf8       = 2; (*!TODO also add UTF16 *)

TYPE
  SBYTE = BYTE;
  BYTE* = UBYTE;

VAR
  Done-: BOOLEAN;
  nextch: CHAR; (* Maintains 1 character read ahaead except at end of line. *)
  readState: INTEGER;
  cp: INTEGER; (* Input Code Page *)

PROCEDURE Open*;
VAR error: Platform.ErrorCode;
BEGIN
  (* Rewind STDIN to beginning of file. *)
  error := Platform.Seek(Platform.StdIn, 0, Platform.SeekSet);
  cp := utf8;
  nextch := 0X;
  readState := pending;
  Done := error = 0
END Open;

PROCEDURE GetByte(): INTEGER;
VAR error: Platform.ErrorCode; x, n: INTEGER;
  m: ARRAY 1 OF SBYTE;
BEGIN
  error := Platform.ReadBuf(Platform.StdIn, m, n); x := m[0] MOD 256;
  IF (error = 0) & (n = 1) THEN readState := ready
  ELSE readState := eof; x := 0
  END;
  RETURN x
END GetByte;

PROCEDURE GetChar(VAR x: CHAR): BOOLEAN;
VAR error: Platform.ErrorCode; n: INTEGER; ok: BOOLEAN;
  m: ARRAY 1 OF CHAR;
BEGIN
  error := Platform.ReadBufW(Platform.StdIn, m, n); x := m[0];
  IF (error = 0) & (n = 1) THEN readState := ready; ok := TRUE
  ELSE readState := eof; x := 0X; ok := FALSE
  END ;
RETURN ok END GetChar;

PROCEDURE Byte*(VAR x: BYTE);
BEGIN x := SYSTEM.VAL(BYTE, SHORT(SHORT(GetByte())))
END Byte;

PROCEDURE ReadChar;
VAR x, y: INTEGER;
  c: CHAR;
BEGIN
  IF GetChar(c) THEN nextch := c
  ELSE x := GetByte();
    IF readState = ready THEN
      IF cp = utf8 THEN
        IF x >= 80H THEN y := GetByte() MOD 64; (* Not 1 byte *)
          IF x DIV 32 = 6 THEN (* 2 bytes *)
            x := x MOD 32 * 64 + y
          ELSIF y DIV 16 = 14 THEN (* 3 bytes *)
            x := (x MOD 16 * 64 + y) * 64 + GetByte() MOD 64
          ELSIF y DIV 8 = 30 THEN (* 4 bytes *)
            x := ((x MOD 8 * 64 + y) * 64 + GetByte() MOD 64) * 64 + GetByte() MOD 64
          ELSE x := 0
          END
        END
      END;
      nextch := CHR(x)
    END
  END
END ReadChar;

PROCEDURE StartRead; (* Ensure either nextch is valid or we are at EOF. *)
BEGIN Out.Flush; IF readState = pending THEN ReadChar END
END StartRead;

PROCEDURE StartAndSkip; (* Like StartRead, but also skip over blanks, CR, LF, tab. *)
BEGIN StartRead;
  WHILE (readState = ready) & (nextch <= ' ') DO ReadChar END
END StartAndSkip;

PROCEDURE Char*(VAR ch: CHAR);
BEGIN StartRead;
  IF readState = ready THEN ch := nextch;
    IF ch = 0AX THEN readState := pending ELSE ReadChar END
  ELSE Done := FALSE; ch := 0X
  END
END Char;

PROCEDURE HugeInt*(VAR h: LONGINT);
VAR ok, neg, hex, endofnum: BOOLEAN;
  decacc, hexacc, digit: LONGINT;
BEGIN StartAndSkip;
  ok := FALSE;
  IF readState = ready THEN
    neg := nextch = '-'; IF neg THEN ReadChar END;
    hex := FALSE;
    endofnum := FALSE;
    decacc := 0;
    hexacc := 0;
    WHILE (readState = ready) & ~endofnum DO
      digit := -1;
      IF (nextch >= '0') & (nextch <= '9') THEN
        digit := ORD(nextch) MOD 16
      ELSIF (nextch >= 'a') & (nextch <= 'f') OR
            (nextch >= 'A') & (nextch <= 'F') THEN
        digit := ORD(nextch) MOD 16 + 9; hex := TRUE
      END;
      IF digit >= 0 THEN
        ok := TRUE;
        decacc := decacc * 10 + digit;
        hexacc := hexacc * 16 + digit;
        ReadChar
      ELSIF nextch = 'H' THEN
        hex := TRUE; endofnum := TRUE; ReadChar
      ELSE
        endofnum := TRUE
      END
    END;
    IF ok THEN
      IF hex THEN h := hexacc ELSE h := decacc END;
      IF neg THEN h := -h END
    ELSE h := 0
    END
  END;
  WHILE (readState = ready) & (nextch <= ' ') & (nextch # 0AX) DO ReadChar END;
  IF (readState = ready) & (nextch = 0AX) THEN readState := pending END;
  IF ~ok THEN Done := FALSE END
END HugeInt;

PROCEDURE Int16*(VAR i: SHORTINT);
VAR h: LONGINT;
BEGIN HugeInt(h); i := SHORT(SHORT(h)) (*!FIXME check range, update Done*)
END Int16;

PROCEDURE Int*(VAR i: INTEGER); (*32-bit INTEGER alias*)
VAR h: LONGINT;
BEGIN HugeInt(h); i := SHORT(h) (*!FIXME check range, update Done*)
END Int;

PROCEDURE LongInt*(VAR i: INTEGER);
BEGIN Int(i)
END LongInt;

PROCEDURE Line*(VAR line: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartRead; i := 0;
  IF readState # ready THEN Done := FALSE END;
  WHILE (readState = ready) & (nextch # 0DX) & (nextch # 0AX) DO
    IF i < LEN(line) - 1 THEN line[i] := nextch; INC(i) ELSE Done := FALSE END;
    ReadChar
  END;
  line[i] := 0X;
  IF (readState = ready) & (nextch = 0DX) THEN ReadChar END;
  IF (readState = ready) & (nextch = 0AX) THEN readState := pending END
END Line;

(** Skip whitespaces, read characters until a whitespace, skip whitespaces
    until a new line character. *)
PROCEDURE Word*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartRead; i := 0;
  IF readState # ready THEN Done := FALSE END;
  WHILE (readState = ready) & (nextch > ' ') & (i < LEN(s) - 1) DO
    s[i] := nextch; INC(i); ReadChar
  END;
  s[i] := 0X;
  WHILE (readState = ready) & (nextch <= ' ') & (nextch # 0AX) DO ReadChar END;
  IF (readState = ready) & (nextch = 0AX) THEN readState := pending END
END Word;

PROCEDURE String*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartAndSkip; i := 0;
  IF (readState = ready) & (nextch = '"') THEN
    ReadChar;
    WHILE (readState = ready) & (i < LEN(s) - 1) &
        (nextch >= ' ') & (nextch # '"') DO
      s[i] := nextch; ReadChar; INC(i)
    END
  END;
  IF (readState = ready) & (i < LEN(s) - 1) & (nextch = '"') THEN
    ReadChar; s[i] := 0X
  ELSE s[0] := 0X; Done := FALSE
  END
END String;

(** Read a file name *)
PROCEDURE Name*(VAR name: ARRAY OF CHAR);
VAR c: CHAR;
  i: INTEGER;
BEGIN i := 0; Char(c);
  WHILE c > ' ' DO
    IF i < LEN(name) - 1 THEN name[i] := c; INC(i) ELSE Done := FALSE END;
    Char(c)
  END;
  name[i] := 0X;
  IF c = 0AX THEN Char(c) END
END Name;

PROCEDURE Real*(VAR x: SHORTREAL);
VAR s: ARRAY 16 OF CHAR;
BEGIN StartAndSkip; Word(s);
  x := Reals.Val(s);
  IF ~Reals.Done THEN Done := FALSE END
END Real;

PROCEDURE LongReal*(VAR x: REAL);
VAR s: ARRAY 16 OF CHAR;
BEGIN StartAndSkip; Word(s);
  x := Reals.LongVal(s);
  IF ~Reals.Done THEN Done := FALSE END
END LongReal;

BEGIN
  cp := utf8;
  nextch := 0X;
  readState := pending;
  Done := TRUE
END In.
