MODULE In;

IMPORT Platform, SYSTEM, Strings, Out;

VAR
  Done-:     BOOLEAN;
  nextch:    CHAR;      (* Maintains 1 character read ahaead except at end of line. *)
  readstate: INTEGER;

CONST
  pending = 0;  (* readstate when at start of input or end of line. Implies nextch undefined. *)
  ready   = 1;  (* readstate when nextch is defined and contains next character on current line. *)
  eof     = 2;  (* readstate when at end of file. *)

PROCEDURE Open*;
VAR error: Platform.ErrorCode;
BEGIN
  error     := Platform.Seek(Platform.StdIn, 0, Platform.SeekSet); (* Rewind STDIN to beginning of file. *)
  readstate := pending;
  Done      := TRUE;
END Open;

PROCEDURE ReadChar;
VAR error: Platform.ErrorCode; n: LONGINT;
BEGIN
  error := Platform.ReadBuf(Platform.StdIn, nextch, n);
  IF (error = 0) & (n = 1) THEN readstate := ready ELSE readstate := eof END
END ReadChar;

PROCEDURE StartRead;  (* Ensure either nextch is valid or we're at EOF. *)
BEGIN Out.Flush; IF readstate = pending THEN ReadChar END;
END StartRead;

PROCEDURE StartAndSkip; (* Like StartRead, but also skip over blanks, CR, LF, tab. *)
BEGIN StartRead;
  WHILE (readstate = ready) & (nextch <= " ") DO ReadChar END
END StartAndSkip;

PROCEDURE Char*(VAR ch: CHAR);
BEGIN
  StartRead;
  Done := readstate = ready;
  IF Done THEN
    ch := nextch;
    IF ch = 0AX THEN readstate := pending ELSE ReadChar END
  ELSE
    ch := 0X
  END
END Char;

PROCEDURE HugeInt*(VAR h: HUGEINT);
VAR
  neg, hex, endofnum: BOOLEAN;
  decacc, hexacc, digit: HUGEINT;
BEGIN
  StartAndSkip;
  Done := FALSE;
  IF readstate = ready THEN
    neg      := nextch = '-'; IF neg THEN ReadChar END;
    hex      := FALSE;
    endofnum := FALSE;
    decacc   := 0;
    hexacc   := 0;
    WHILE (readstate = ready) & ~endofnum DO
      digit := -1;
      IF (nextch >= "0") & (nextch <= "9") THEN
        digit := ORD(nextch) MOD 16
      ELSIF (nextch >= "a") & (nextch <= "f")
         OR (nextch >= "A") & (nextch <= "F") THEN
        digit := ORD(nextch) MOD 16 + 9; hex := TRUE
      END;
      IF digit >= 0 THEN
        Done   := TRUE;
        decacc := decacc * 10 + digit;
        hexacc := hexacc * 16 + digit;
        ReadChar
      ELSIF nextch = "H" THEN
        hex := TRUE; endofnum := TRUE; ReadChar
      ELSE
        endofnum := TRUE
      END
    END;
    IF Done THEN
      IF hex THEN h := hexacc ELSE h := decacc END;
      IF neg THEN h := -h END
    ELSE
      h := 0
    END
  END
END HugeInt;

PROCEDURE Int*(VAR i: INTEGER);
VAR h: HUGEINT;
BEGIN HugeInt(h); i := SYSTEM.VAL(INTEGER, h)
END Int;

PROCEDURE LongInt*(VAR i: LONGINT);
VAR h: HUGEINT;
BEGIN HugeInt(h); i := SYSTEM.VAL(LONGINT, h)
END LongInt;

PROCEDURE Line*(VAR line: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartRead; i := 0; Done := readstate = ready;
  WHILE (readstate = ready) & (nextch # 0DX) & (nextch # 0AX) & (i < LEN(line)-1) DO
    line[i] := nextch; INC(i); ReadChar
  END;
  line[i] := 0X;
  IF (readstate = ready) & (nextch = 0DX) THEN ReadChar END;
  IF (readstate = ready) & (nextch = 0AX) THEN readstate := pending END;
END Line;

PROCEDURE String*(VAR str: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartAndSkip; i := 0;
  IF (readstate = ready) & (nextch = '"') THEN                         (* " *)
    ReadChar;
    WHILE (readstate = ready)
        & (i < LEN(str)-1)
        & (nextch >= " ")
        & (nextch # '"') DO                                            (* " *)
      str[i] := nextch; ReadChar; INC(i)
    END
  END;
  Done := (readstate = ready)
        & (i < LEN(str)-1)
        & (nextch = '"');                                              (* " *)
  IF Done THEN
    ReadChar; str[i] := 0X
  ELSE
    str[0] := 0X
  END
END String;

PROCEDURE Name*(VAR name: ARRAY OF CHAR); (* Read filename. Presumably using shell semantics. *)
BEGIN HALT(99) (* Not implemented *)
END Name;

PROCEDURE Real*(VAR x: REAL);
VAR
  str: ARRAY 16 OF CHAR;
BEGIN
  Line(str);
  Strings.StrToReal(str, x);
END Real;

PROCEDURE LongReal*(VAR y: LONGREAL);
VAR
  str: ARRAY 16 OF CHAR;
BEGIN
  Line(str);
  Strings.StrToLongReal(str, y);
END LongReal;



BEGIN
  nextch    := 0X;
  readstate := pending;
  Done      := TRUE;
END In.
