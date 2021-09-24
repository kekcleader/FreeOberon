MODULE In;

(*!FIXME From the Oakwood guidlines:
  An unsuccessful input operation sets Done to FALSE;
  it remains FALSE until the next call to Open. *)

IMPORT Platform, SYSTEM, Strings, Out, Utf8;

CONST
  pending = 0; (* readstate when at start of input or end of line. Implies nextch undefined. *)
  ready   = 1; (* readstate when nextch is defined and contains next character on current line. *)
  eof     = 2; (* readstate when at end of file. *)

  (* Codepages, see cp below *)
  singleByte = 1;
  utf8       = 2; (*!TODO also add UTF16 = 2 *)

TYPE
  SBYTE = BYTE;
  BYTE* = UBYTE;

VAR
  Done-: BOOLEAN;
  nextch: CHAR; (* Maintains 1 character read ahaead except at end of line. *)
  readstate: INTEGER;
  cp: INTEGER; (* Input Code Page *)

PROCEDURE Open*;
VAR error: Platform.ErrorCode;
BEGIN
  error := Platform.Seek(Platform.StdIn, 0, Platform.SeekSet); (* Rewind STDIN to beginning of file. *)
  cp := utf8;
  nextch := 0X;
  readstate := pending;
  Done := error = 0
END Open;

PROCEDURE GetByte(): INTEGER;
VAR error: Platform.ErrorCode; x, n: INTEGER;
  m: ARRAY 1 OF SBYTE;
BEGIN
  error := Platform.ReadBuf(Platform.StdIn, m, n); x := m[0] MOD 256;
  Out.String('READ ');Out.Int(x, 0);Out.Ln;
  IF (error = 0) & (n = 1) THEN readstate := ready
  ELSE readstate := eof; x := 0
  END;
  RETURN x
END GetByte;

PROCEDURE Byte*(VAR x: BYTE);
BEGIN x := SYSTEM.VAL(BYTE, SHORT(SHORT(GetByte())))
END Byte;

PROCEDURE ReadChar;
VAR x, y: INTEGER;
BEGIN
  x := GetByte();
  IF readstate = ready THEN
    IF cp = utf8 THEN
      IF x > 80H THEN y := GetByte() MOD 64; (* Not 1 byte *)
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
END ReadChar;

PROCEDURE StartRead; (* Ensure either nextch is valid or we're at EOF. *)
BEGIN Out.Flush; IF readstate = pending THEN ReadChar END
END StartRead;

PROCEDURE StartAndSkip; (* Like StartRead, but also skip over blanks, CR, LF, tab. *)
BEGIN StartRead;
  WHILE (readstate = ready) & (nextch <= ' ') DO ReadChar END
END StartAndSkip;

PROCEDURE Char*(VAR ch: CHAR);
BEGIN StartRead;
  IF readstate = ready THEN ch := nextch;
    ;;;;;;;;;Out.String('readstate was ready. ch = '); Out.Int(ORD(ch), 0); Out.Ln;
    IF ch = 0AX THEN readstate := pending ELSE ReadChar END
  ELSE Done := FALSE; ch := 0X
    ;;;;;;;;;Out.String('readstate was not ready. ch = '); Out.Int(ORD(ch), 0); Out.Ln;
  END
END Char;

PROCEDURE HugeInt*(VAR h: LONGINT);
VAR ok, neg, hex, endofnum: BOOLEAN;
  decacc, hexacc, digit: LONGINT;
BEGIN StartAndSkip;
  ok := FALSE;
  IF readstate = ready THEN
    neg := nextch = '-'; IF neg THEN ReadChar END;
    hex := FALSE;
    endofnum := FALSE;
    decacc := 0;
    hexacc := 0;
    WHILE (readstate = ready) & ~endofnum DO
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
  IF ~ok THEN Done := FALSE END
END HugeInt;

PROCEDURE Int16*(VAR i: SHORTINT);
VAR h: LONGINT;
BEGIN HugeInt(h); i := SHORT(SHORT(h)) (*!FIXME check range?*)
END Int16;

PROCEDURE LongInt*(VAR i: INTEGER);
VAR h: LONGINT;
BEGIN HugeInt(h); i := SHORT(h) (*!FIXME check range?*)
END LongInt;

PROCEDURE Int*(VAR i: INTEGER); (*32-bit INTEGER alias*)
VAR h: LONGINT;
BEGIN HugeInt(h); i := SHORT(h) (*!FIXME check range?*)
END Int;

PROCEDURE Line*(VAR line: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartRead; i := 0;
  IF readstate # ready THEN Done := FALSE END;
  WHILE (readstate = ready) & (nextch # 0DX) & (nextch # 0AX) &
        (i < LEN(line) - 1) DO
    line[i] := nextch; INC(i); ReadChar
  END;
  line[i] := 0X;
  IF (readstate = ready) & (nextch = 0DX) THEN ReadChar END;
  IF (readstate = ready) & (nextch = 0AX) THEN readstate := pending END
END Line;

PROCEDURE String*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartAndSkip; i := 0;
  IF (readstate = ready) & (nextch = '"') THEN
    ReadChar;
    WHILE (readstate = ready) & (i < LEN(s) - 1) &
        (nextch >= ' ') & (nextch # '"') DO
      s[i] := nextch; ReadChar; INC(i)
    END
  END;
  IF (readstate = ready) & (i < LEN(s) - 1) & (nextch = '"') THEN
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
BEGIN StartAndSkip; Line(s);
  Strings.StrToReal(s, x)
  (*!FIXME Set Done*)
END Real;

PROCEDURE LongReal*(VAR y: REAL);
VAR s: ARRAY 16 OF CHAR;
BEGIN StartAndSkip; Line(s);
  Strings.StrToLongReal(s, y)
  (*!FIXME Set Done*)
END LongReal;

BEGIN
  cp := utf8;
  nextch := 0X;
  readstate := pending;
  Done := TRUE
END In.
