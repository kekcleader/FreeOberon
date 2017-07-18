MODULE ulmIO;

  IMPORT SYS := ulmSYSTEM, SYSTEM, Platform, Types := ulmTypes;

  CONST nl = 0AX;

  (* conversions *)

  CONST
    oct = 0;
    dec = 1;
    hex = 2;
  TYPE
    Basetype = Types.Int8; (* oct..hex *)

  (* basic IO *)

  VAR
    Done*: BOOLEAN;
    oldch: CHAR;
    readAgain: BOOLEAN;

  (* ==================== conversions ================================= *)

  PROCEDURE ConvertNumber(num, len: Types.Int32; btyp: Basetype; neg: BOOLEAN;
    VAR str: ARRAY OF CHAR);

    (* conversion of a number into a string of characters *)
    (* num must get the absolute value of the number      *)
    (* len is the minimal length of the generated string  *)
    (* neg means: "the number is negative" for btyp = dec *)

    (*CONST
      NumberLen = 11;*)
      (* we need it as variable to change the value depending on architecture; -- noch *)
    VAR
    (*digits    : ARRAY NumberLen+1 OF CHAR;*)
      digits    : POINTER TO ARRAY OF CHAR;
      base      : Types.Int32;
      cnt, ix   : Types.Int32;
      maxlen    : Types.Int32;
      dig       : Types.Int32;
      NumberLen : Types.Int8;
  BEGIN
    IF  SIZE(Types.Int32) = 8 THEN
      NumberLen := 21
    ELSE
      NumberLen := 11 (* default value, corresponds to 32 bit *)
    END;
    NEW(digits, NumberLen + 1 );
    ASSERT(num >= 0);
    ix := 1;
    WHILE ix <= NumberLen DO
      digits[ix] := "0";
      INC(ix);
    END;                              (* initialisation *)
    IF btyp = oct THEN
      base := 8;
    ELSIF btyp = dec THEN
      base := 10;
    ELSIF btyp = hex THEN
      base := 10H;
    END;
    cnt := 0;
    REPEAT
      INC(cnt);
      dig := num MOD base;
      num := num DIV base;
      IF dig < 10 THEN
        dig := dig + ORD("0");
      ELSE
        dig := dig - 10 + ORD("A");
      END;
      digits[cnt] := CHR(dig);
    UNTIL num = 0;
    (* (* i don't like this *)
    IF btyp = oct THEN
      cnt := 11;
    ELSIF btyp = hex THEN
      cnt := 8;
    ELSIF neg THEN
    *)
    IF neg THEN
      INC(cnt);
      digits[cnt] := "-";
    END;
    maxlen := LEN(str);          (* get maximal length *)
    IF len > maxlen THEN
      len := SHORT(maxlen);
    END;
    IF cnt > maxlen THEN
      cnt := SHORT(maxlen);
    END;
    ix := 0;
    WHILE len > cnt DO
      str[ix] := " ";
      INC(ix);
      DEC(len);
    END;
    WHILE cnt > 0 DO
      str[ix] := digits[cnt];
      INC(ix);
      DEC(cnt);
    END;
    IF ix < maxlen THEN
      str[ix] := 0X;
    END;
  END ConvertNumber;

  PROCEDURE ConvertInteger(num: Types.Int32; len: Types.Int32; VAR str: ARRAY OF
    CHAR);
  (* conversion of an integer decimal number to a string *)
  BEGIN
      ConvertNumber(ABS(num),len,dec,num < 0,str);
  END ConvertInteger;

  (* ========================= terminal ============================ *)

(*
  PROCEDURE ReadChar(VAR ch: CHAR) : BOOLEAN;
    CONST read = 3;
    (*VAR r0, r1: Types.Int32;*)
    VAR r0, r1: Types.Int32; (* in ulm system Types.Int32 and Types.Int32 have the same 4 byte size; -- noch *)
  BEGIN
    RETURN SYS.UNIXCALL(read, r0, r1, 0, SYSTEM.ADR(ch), 1) & (r0 > 0)
  END ReadChar;
*)

  PROCEDURE ReadChar(VAR ch: CHAR) : BOOLEAN;
  (* Read one byte, returning success flag *)
    VAR error: Platform.ErrorCode; readcount: Types.Int32;
  BEGIN
    error := Platform.ReadBuf(Platform.StdIn, ch, readcount);
    RETURN readcount > 0
  END ReadChar;

(*
  PROCEDURE WriteChar(ch: CHAR) : BOOLEAN;
    CONST write = 4;
    (*VAR r0, r1: Types.Int32;*)
    VAR r0, r1: Types.Int32;     (* same here *)
  BEGIN
    RETURN SYS.UNIXCALL(write, r0, r1, 1, SYSTEM.ADR(ch), 1)
  END WriteChar;
*)

  PROCEDURE WriteChar(ch: CHAR) : BOOLEAN;
  (* Write one byte, returning success flag *)
  BEGIN
    RETURN Platform.Write(Platform.StdOut, SYSTEM.ADR(ch), 1) = 0
  END WriteChar;

  PROCEDURE Read*(VAR ch: CHAR);
  BEGIN
    Done := TRUE;
    IF readAgain THEN
      ch := oldch;
      readAgain := FALSE;
    ELSIF ~ReadChar(ch) THEN
      Done := FALSE;
      ch := 0X;
    ELSE
      oldch := ch;
    END;
  END Read;

  PROCEDURE ReadAgain*;
  BEGIN
    IF readAgain THEN
      Done := FALSE;
    ELSE
      Done := TRUE;
      readAgain := TRUE;
    END;
  END ReadAgain;

  PROCEDURE Write*(ch: CHAR);
  BEGIN
    Done := WriteChar(ch);
  END Write;

  PROCEDURE WriteLn*;
    CONST nl = 0AX;
  BEGIN
    Write(nl);
  END WriteLn;

  PROCEDURE WriteString*(s: ARRAY OF CHAR);
    VAR i: Types.Int32;
  BEGIN
    i := 0;
    WHILE (i < LEN(s)) & (s[i] # 0X) DO
      Write(s[i]);
      INC(i);
    END;
  END WriteString;

  PROCEDURE InitIO;
  BEGIN
    readAgain := FALSE;
    Done := TRUE;
  END InitIO;

  PROCEDURE WriteInt*(arg: Types.Int32);
    VAR field: ARRAY 23 OF CHAR;
  BEGIN (* the field size should be big enough to hold the long number. it was 12 to hold just 32 bit numbers, now it can hold 64 bit numbers; need to be more for 128bit numbers; -- noch *)
    ConvertInteger(arg, 1, field);
    WriteString(field);
  END WriteInt;

  PROCEDURE ReadInt*(VAR arg: Types.Int32);
    VAR ch: CHAR;
       minus: BOOLEAN;
  BEGIN
    minus := FALSE;
    REPEAT
      Read(ch);
      IF ~Done THEN RETURN END;
      IF ch = "-" THEN
        minus := TRUE;
      ELSIF (ch # " ") & (ch # nl) & ((ch < "0") OR (ch > "9")) THEN
        WriteString("--- Integer expected on input"); WriteLn;
      END;
    UNTIL (ch >= "0") & (ch <= "9");
    arg := ORD(ch) - ORD("0");
    REPEAT
      Read(ch);
      IF ~Done THEN RETURN END;
      IF (ch >= "0") & (ch <= "9") THEN
        arg := arg*10 + (ORD(ch) - ORD("0"));
      END;
    UNTIL (ch < "0") OR (ch > "9");
    ReadAgain;
    IF minus THEN arg := -arg; END;
  END ReadInt;

  PROCEDURE ReadLine*(VAR string: ARRAY OF CHAR);
    VAR
      index: Types.Int32;
      ch: CHAR;
      ok: BOOLEAN;
  BEGIN
    index := 0; ok := TRUE;
    LOOP
      IF ~ReadChar(ch) THEN ok := FALSE; EXIT END;
      IF ch = nl THEN EXIT END;
      IF index < LEN(string) THEN
        string[index] := ch; INC(index);
      END;
    END;
    IF index < LEN(string) THEN
      string[index] := 0X;
    END;
    Done := ok OR (index > 0);
  END ReadLine;

BEGIN
  InitIO;
END ulmIO.
