(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethStrings;  (** portable *) (* ejz,  *)

(** Strings is a utility module that provides procedures to manipulate strings.
    Note: All strings MUST be 0X terminated. *)

  IMPORT Texts, Dates := ethDates, Reals := ethReals;
  
  CONST
    CR* = 0DX; (** the Oberon end of line character *)
    Tab* = 09X; (** the horizontal tab character *)
    LF* = 0AX; (** the UNIX end of line character *) 

  VAR
    isAlpha*: ARRAY 256 OF BOOLEAN; (** all letters in the oberon charset *)
    ISOToOberon*, OberonToISO*: ARRAY 256 OF CHAR; (** Translation tables for iso-8859-1 to oberon ascii code. *)
    CRLF*: ARRAY 4 OF CHAR; (** end of line "string" used by MS-DOS and most TCP protocols *)
    sDayName: ARRAY 7, 4 OF CHAR;
    lDayName: ARRAY 7, 12 OF CHAR;
    sMonthName: ARRAY 12, 4 OF CHAR;
    lMonthName: ARRAY 12, 12 OF CHAR;
    dateform, timeform: ARRAY 32 OF CHAR;

(** Length of str. *)
  PROCEDURE Length*(VAR str(** in *): ARRAY OF CHAR): LONGINT;
    VAR i, l: LONGINT;
  BEGIN
    l := LEN(str); i := 0;
    WHILE (i < l) & (str[i] # 0X) DO
      INC(i)
    END;
    RETURN i
  END Length;

(** Append this to to. *)
  PROCEDURE Append*(VAR to(** in/out *): ARRAY OF CHAR; this: ARRAY OF CHAR);
    VAR i, j, l: LONGINT;
  BEGIN
    i := 0;
    WHILE to[i] # 0X DO
      INC(i)
    END;
    l := LEN(to)-1; j := 0;
    WHILE (i < l) & (this[j] # 0X) DO
      to[i] := this[j]; INC(i); INC(j)
    END;
    to[i] := 0X
  END Append;

(** Append this to to. *)
  PROCEDURE AppendCh*(VAR to(** in/out *): ARRAY OF CHAR; this: CHAR);
    VAR i: LONGINT;
  BEGIN
    i := 0;
    WHILE to[i] # 0X DO
      INC(i)
    END;
    IF i < (LEN(to)-1) THEN
      to[i] := this; to[i+1] := 0X
    END
  END AppendCh;

(** TRUE if ch is a hexadecimal digit. *)
  PROCEDURE IsHexDigit*(ch: CHAR): BOOLEAN;
  BEGIN
    RETURN ((ch >= "0") & (ch <= "9")) OR ((CAP(ch) >= "A") & (CAP(ch) <= "F"))
  END IsHexDigit;

(** TRUE if ch is a decimal digit. *)
  PROCEDURE IsDigit*(ch: CHAR): BOOLEAN;
  BEGIN
    RETURN (ch >= "0") & (ch <= "9")
  END IsDigit;

(** TRUE if ch is a letter. *)
  PROCEDURE IsAlpha*(ch: CHAR): BOOLEAN;
  BEGIN
    RETURN isAlpha[ORD(ch)]
  END IsAlpha;

(** If ch is an upper-case letter return the corresponding lower-case letter. *)
  PROCEDURE LowerCh*(ch: CHAR): CHAR;
  BEGIN
    CASE ch OF
      "A" .. "Z": ch := CHR(ORD(ch)-ORD("A")+ORD("a"))
      |"€": ch := "ƒ"
      |"": ch := "„"
      |"‚": ch := "…"
    ELSE
    END;
    RETURN ch
  END LowerCh;

(** If ch is an lower-case letter return the corresponding upper-case letter. *)
  PROCEDURE UpperCh*(ch: CHAR): CHAR;
  BEGIN
    CASE ch OF
      "a" .. "z": ch := CAP(ch)
      |"ƒ": ch := "€"
      |"„": ch := ""
      |"…": ch := "‚"
      |"†": ch := "A"
      |"‡": ch := "E"
      |"ˆ": ch := "I"
      |"‰": ch := "O"
      |"Š": ch := "U"
      |"‹": ch := "A"
      |"Œ": ch := "E"
      |"": ch := "I"
      |"Ž": ch := "O"
      |"": ch := "U"
      |"": ch := "E"
      |"‘": ch := "E"
      |"’": ch := "I"
      |"“": ch := "C"
      |"”": ch := "A"
      |"•": ch := "N"
      |"–": ch := "S"
    ELSE
    END;
    RETURN ch
  END UpperCh;

(** Convert str to all lower-case letters. *)
  PROCEDURE Lower*(VAR str(** in *), lstr(** out *): ARRAY OF CHAR);
    VAR i: LONGINT;
  BEGIN
    i := 0;
    WHILE str[i] # 0X DO
      lstr[i] := LowerCh(str[i]); INC(i)
    END;
    lstr[i] := 0X
  END Lower;

(** Convert str to all upper-case letters. *)
  PROCEDURE Upper*(VAR str(** in *), ustr(** out *): ARRAY OF CHAR);
    VAR i: LONGINT;
  BEGIN
    i := 0;
    WHILE str[i] # 0X DO
      ustr[i] := UpperCh(str[i]); INC(i)
    END;
    ustr[i] := 0X
  END Upper;

(** Is str prefixed by pre? *)
  PROCEDURE Prefix*(pre: ARRAY OF CHAR; VAR str(** in *): ARRAY OF CHAR): BOOLEAN;
    VAR i: LONGINT;
  BEGIN
    i := 0;
    WHILE (pre[i] # 0X) & (pre[i] = str[i]) DO
      INC(i)
    END;
    RETURN pre[i] = 0X
  END Prefix;

(** Checks if str is prefixed by pre. The case is ignored. *)
  PROCEDURE CAPPrefix*(pre: ARRAY OF CHAR; VAR str(** in *): ARRAY OF CHAR): BOOLEAN;
    VAR i: LONGINT;
  BEGIN
    i := 0;
    WHILE (pre[i] # 0X) & (CAP(pre[i]) = CAP(str[i])) DO
      INC(i)
    END;
    RETURN pre[i] = 0X
  END CAPPrefix;

(** Compare str1 to str2. The case is ignored. *)
  PROCEDURE CAPCompare*(VAR str1(** in *), str2(** in *): ARRAY OF CHAR): BOOLEAN;
    VAR i: LONGINT;
  BEGIN
    i := 0;
    WHILE (str1[i] # 0X) & (str2[i] # 0X) & (CAP(str1[i]) = CAP(str2[i])) DO
      INC(i)
    END;
    RETURN str1[i] = str2[i]
  END CAPCompare;

(** Get the parameter-value on line. The parameter value is started behind the first colon character. *)
  PROCEDURE GetPar*(VAR line(** in *), par(** out *): ARRAY OF CHAR);
    VAR i, j, l: LONGINT;
  BEGIN
    i := 0;
    WHILE (line[i] # 0X) & (line[i] # ":") DO
      INC(i)
    END;
    IF line[i] = ":" THEN
      INC(i)
    END;
    WHILE (line[i] # 0X) & (line[i] <= " ") DO
      INC(i)
    END;
    l := LEN(par)-1; j := 0;
    WHILE (j < l) & (line[i] # 0X) DO
      par[j] := line[i]; INC(j); INC(i)
    END;
    par[j] := 0X
  END GetPar;

(** Get the suffix of str. The suffix is started by the last dot in str. *)
  PROCEDURE GetSuffix*(VAR str(** in *), suf(** out *): ARRAY OF CHAR);
    VAR i, j, l, dot: LONGINT;
  BEGIN
    dot := -1; i := 0;
    WHILE str[i] # 0X DO
      IF str[i] = "." THEN
        dot := i
      ELSIF str[i] = "/" THEN
        dot := -1
      END;
      INC(i)
    END;
    j := 0;
    IF dot > 0 THEN
      l := LEN(suf)-1; i := dot+1;
      WHILE (j < l) & (str[i] # 0X) DO
        suf[j] := str[i]; INC(j); INC(i)
      END
    END;
    suf[j] := 0X
  END GetSuffix;

(** Change the suffix of str to suf. *)
  PROCEDURE ChangeSuffix*(VAR str(** in/out *): ARRAY OF CHAR; suf: ARRAY OF CHAR);
    VAR i, j, l, dot: LONGINT;
  BEGIN
    dot := -1; i := 0;
    WHILE str[i] # 0X DO
      IF str[i] = "." THEN
        dot := i
      ELSIF str[i] = "/" THEN
        dot := -1
      END;
      INC(i)
    END;
    IF dot > 0 THEN
      l := LEN(str)-1; i := dot+1; j := 0;
      WHILE (i < l) & (suf[j] # 0X) DO
        str[i] := suf[j]; INC(i); INC(j)
      END;
      str[i] := 0X
    END
  END ChangeSuffix;

(** Search in src starting at pos for the next occurrence of pat.  Returns pos=-1 if not found. *)
  PROCEDURE Search*(pat: ARRAY OF CHAR; VAR src(** in *): ARRAY OF CHAR; VAR pos(** in/out *): LONGINT);
    CONST MaxPat = 128;
    VAR
      buf: ARRAY MaxPat OF CHAR;
      len, i, srclen: LONGINT;
    PROCEDURE Find(beg: LONGINT);
      VAR
        i, j, b, e: LONGINT;
        ch: CHAR;
        ref: ARRAY MaxPat OF CHAR;
    BEGIN
      ch := src[pos]; INC(pos);
      ref[0] := ch;
      i := 0; j := 0; b := 0; e := 1;
      WHILE (pos <= srclen) & (i < len) DO
        IF buf[i] = ch THEN
          INC(i); j := (j + 1) MOD MaxPat
        ELSE
          i := 0; b := (b + 1) MOD MaxPat; j := b
        END;
        IF j # e THEN
          ch := ref[j]
        ELSE
          IF pos >= srclen THEN
            ch := 0X
          ELSE
            ch := src[pos]
          END;
          INC(pos); ref[j] := ch; e := (e + 1) MOD MaxPat; INC(beg);
        END
      END;
      IF i = len THEN
        pos := beg-len
      ELSE
        pos := -1
      END
    END Find;
  BEGIN
    len := Length(pat);
    IF MaxPat < len THEN
      len := MaxPat
    END;
    IF len <= 0 THEN
      pos := -1;
      RETURN
    END;
    i := 0;
    REPEAT
      buf[i] := pat[i]; INC(i)
    UNTIL i >= len;
    srclen := Length(src);
    IF pos < 0 THEN
      pos := 0
    ELSIF pos >= srclen THEN
      pos := -1;
      RETURN
    END;
    Find(pos)
  END Search;

(** Search in src starting at pos for the next occurrence of pat. *)
  PROCEDURE CAPSearch*(pat: ARRAY OF CHAR; VAR src(** in *): ARRAY OF CHAR; VAR pos(** in/out *): LONGINT);
    CONST MaxPat = 128;
    VAR
      buf: ARRAY MaxPat OF CHAR;
      len, i, srclen: LONGINT;
    PROCEDURE Find(beg: LONGINT);
      VAR
        i, j, b, e: LONGINT;
        ch: CHAR;
        ref: ARRAY MaxPat OF CHAR;
    BEGIN
      ch := UpperCh(src[pos]); INC(pos);
      ref[0] := ch;
      i := 0; j := 0; b := 0; e := 1;
      WHILE (pos <= srclen) & (i < len) DO
        IF buf[i] = ch THEN
          INC(i); j := (j + 1) MOD MaxPat
        ELSE
          i := 0; b := (b + 1) MOD MaxPat; j := b
        END;
        IF j # e THEN
          ch := ref[j]
        ELSE
          IF pos >= srclen THEN
            ch := 0X
          ELSE
            ch := UpperCh(src[pos])
          END;
          INC(pos); ref[j] := ch; e := (e + 1) MOD MaxPat; INC(beg);
        END
      END;
      IF i = len THEN
        pos := beg-len
      ELSE
        pos := -1
      END
    END Find;
  BEGIN
    len := Length(pat);
    IF MaxPat < len THEN
      len := MaxPat
    END;
    IF len <= 0 THEN
      pos := -1;
      RETURN
    END;
    i := 0;
    REPEAT
      buf[i] := UpperCh(pat[i]); INC(i)
    UNTIL i >= len;
    srclen := Length(src);
    IF pos < 0 THEN
      pos := 0
    ELSIF pos >= srclen THEN
      pos := -1;
      RETURN
    END;
    Find(pos)
  END CAPSearch;

(** Convert a string into an integer. Leading white space characters are ignored. *)
  PROCEDURE StrToInt*(VAR str: ARRAY OF CHAR; VAR val: LONGINT);
    VAR i, d: LONGINT; ch: CHAR; neg: BOOLEAN;
  BEGIN
    i := 0; ch := str[0];
    WHILE (ch # 0X) & (ch <= " ") DO
      INC(i); ch := str[i]
    END;
    neg := FALSE; IF ch = "+" THEN INC(i); ch := str[i] END;
    IF ch = "-" THEN neg := TRUE; INC(i); ch := str[i] END;
    WHILE (ch # 0X) & (ch <= " ") DO
      INC(i); ch := str[i]
    END;
    val := 0;
    WHILE (ch >= "0") & (ch <= "9") DO
      d := ORD(ch)-ORD("0");
      INC(i); ch := str[i];
      IF val <= ((MAX(LONGINT)-d) DIV 10) THEN
        val := 10*val+d
      ELSIF neg & (val = 214748364) & (d = 8) & ((ch < "0") OR (ch > "9")) THEN
        val := MIN(LONGINT); neg := FALSE
      ELSE
        HALT(99)
      END
    END;
    IF neg THEN val := -val END
  END StrToInt;

(** Convert the substring beginning at position i in str into an integer. Any leading whitespace characters are ignored.
  After the conversion i pointes to the first character after the integer. *)
  PROCEDURE StrToIntPos*(VAR str: ARRAY OF CHAR; VAR val: LONGINT; VAR i: INTEGER);
    VAR noStr: ARRAY 16 OF CHAR;
  BEGIN
    WHILE (str[i] # 0X) & (str[i] <= " ") DO
      INC(i)
    END;
    val := 0;
    IF str[i] = "-" THEN
      noStr[val] := str[i]; INC(val); INC(i);
      WHILE (str[i] # 0X) & (str[i] <= " ") DO
        INC(i)
      END
    END;
    WHILE (str[i] >= "0") & (str[i] <= "9") DO
      noStr[val] := str[i]; INC(val); INC(i)
    END;
    noStr[val] := 0X;
    StrToInt(noStr, val)
  END StrToIntPos;

(** Convert an integer into a string. *)
  PROCEDURE IntToStr*(val: LONGINT; VAR str: ARRAY OF CHAR);
    VAR
      i, j: LONGINT;
      digits: ARRAY 16 OF LONGINT;
  BEGIN
    IF val = MIN(LONGINT) THEN
      COPY("-2147483648", str);
      RETURN
    END;
    IF val < 0 THEN
      val := -val; str[0] := "-"; j := 1
    ELSE
      j := 0
    END;
    i := 0;
    REPEAT
      digits[i] := val MOD 10; INC(i); val := val DIV 10
    UNTIL val = 0;
    DEC(i);
    WHILE i >= 0 DO
      str[j] := CHR(digits[i]+ORD("0")); INC(j); DEC(i)
    END;
    str[j] := 0X
  END IntToStr;

(** Converts a real to a string. *)
PROCEDURE RealToStr*(x: LONGREAL; VAR s: ARRAY OF CHAR);
VAR e, h, l, n, len: LONGINT; i, j, pos: INTEGER; z: LONGREAL; d: ARRAY 16 OF CHAR;
  
  PROCEDURE Wr(ch: CHAR);
  BEGIN
    IF ch = 0X THEN HALT(42) END;
    IF pos < len THEN s[pos] := ch; INC(pos) END;
  END Wr;
  
BEGIN
  len := LEN(s)-1; pos := 0;
  e:= Reals.ExpoL(x);
  IF e = 2047 THEN
    Wr("N"); Wr("a"); Wr("N")
  ELSE
    n := 14;
    IF (x < 0) & (e # 0) THEN Wr("-"); x:= - x END;
    IF e = 0 THEN h:= 0; l:= 0 (* no denormals *)
    ELSE e:= (e - 1023) * 301029 DIV 1000000; (* ln(2)/ln(10) = 0.301029996 *)
      z:= Reals.Ten(e+1);
      IF x >= z THEN x:= x/z; INC(e) ELSE x:= x * Reals.Ten(-e) END;
      IF x >= 10 THEN x:= x * Reals.Ten(-1) + 0.5D0 / Reals.Ten(n); INC(e)
      ELSE x:= x + 0.5D0 / Reals.Ten(n);
        IF x >= 10 THEN x:= x * Reals.Ten(-1); INC(e) END
      END;
      x:= x * Reals.Ten(7); h:= ENTIER(x); x:= (x-h) * Reals.Ten(8); l:= ENTIER(x)
    END;
    i := 15; WHILE i > 7 DO d[i]:= CHR(l MOD 10 + ORD("0")); l:= l DIV 10; DEC(i) END;
    WHILE i >= 0 DO d[i]:= CHR(h MOD 10 + ORD("0")); h:= h DIV 10; DEC(i) END;
    IF ABS(e) > 8 THEN (* scientific notation *)
      j := 15; WHILE (j > 0) & (d[j] = "0") DO DEC(j) END;
      Wr(d[0]); IF j # 0 THEN Wr(".") END; i := 1; WHILE i <= j DO Wr(d[i]); INC(i) END;
      IF e < 0 THEN Wr("D"); Wr("-"); e:= - e ELSE Wr("D"); Wr("+") END;
      Wr(CHR(e DIV 100 + ORD("0"))); e:= e MOD 100;
      Wr(CHR(e DIV 10 + ORD("0"))); Wr(CHR(e MOD 10 + ORD("0")))
    ELSE
      IF e < 0 THEN (* leading zeros *)
        j := (* !15*) 14; WHILE (j > 0) & (d[j] = "0") DO DEC(j) END;
        Wr("0"); Wr("."); INC(e);
        WHILE e < 0 DO Wr("0"); INC(e) END;
        i := 0; WHILE i <= j DO Wr(d[i]); INC(i) END
      ELSE
        i := 0; WHILE (e >= 0) & (i < 16 ) DO Wr(d[i]); INC(i); DEC(e) END;
        IF i < 16 THEN
          Wr(".");
          WHILE i < (*16*) 15 DO Wr(d[i]); INC(i); END;
          WHILE s[pos - 1] = "0" DO DEC(pos) END;
          IF s[pos - 1] = "." THEN DEC(pos) END;
        END
      END
    END
  END;
  s[pos] := 0X
END RealToStr;

PROCEDURE RealToFixStr*(x: LONGREAL; VAR str: ARRAY OF CHAR; n, f, D: LONGINT);
  VAR pos, len, e, i, h, l: LONGINT; r, z: LONGREAL; d: ARRAY 16 OF CHAR; s: CHAR;
  PROCEDURE Wr(ch: CHAR);
  BEGIN
    IF ch = 0X THEN HALT(42) END;
    IF pos < len THEN str[pos] := ch; INC(pos) END;
  END Wr;
BEGIN
  len := LEN(str)-1; pos := 0;
  e := Reals.ExpoL(x);
  IF (e = 2047) OR (ABS(D) > 308) THEN
    Wr("N"); Wr("a"); Wr("N")
  ELSE
    IF D = 0 THEN DEC(n, 2) ELSE DEC(n, 7) END;
    IF n < 2 THEN n := 2 END;
    IF f < 0 THEN f := 0 END;
    IF n < f + 2 THEN n := f + 2 END;
    DEC(n, f);
    IF (e # 0) & (x < 0) THEN s := "-"; x := - x ELSE s := " " END;
    IF e = 0 THEN
      h := 0; l := 0; DEC(e, D-1) (* no denormals *)
    ELSE
      e := (e - 1023) * 301029 DIV 1000000; (* ln(2)/ln(10) = 0.301029996 *)
      z := Reals.Ten(e+1);
      IF x >= z THEN x := x/z; INC(e) ELSE x:= x * Reals.Ten(-e) END;
      DEC(e, D-1); i := -(e+f);
      IF i <= 0 THEN r := 5 * Reals.Ten(i) ELSE r := 0 END;
      IF x >= 10 THEN
        x := x * Reals.Ten(-1) + r; INC(e)
      ELSE
        x := x + r;
        IF x >= 10 THEN x := x * Reals.Ten(-1); INC(e) END
      END;
      x := x * Reals.Ten(7); h:= ENTIER(x); x := (x-h) * Reals.Ten(8); l := ENTIER(x)
    END;
    i := 15;
    WHILE i > 7 DO d[i] := CHR(l MOD 10 + ORD("0")); l := l DIV 10; DEC(i) END;
    WHILE i >= 0 DO d[i] := CHR(h MOD 10 + ORD("0")); h := h DIV 10; DEC(i) END;
    IF n <= e THEN n := e + 1 END;
    IF e > 0 THEN
      WHILE n > e DO Wr(" "); DEC(n) END;
      Wr(s); e:= 0;
      WHILE n > 0 DO
        DEC(n);
        IF e < 16 THEN Wr(d[e]); INC(e) ELSE Wr("0") END
      END;
      Wr(".")
    ELSE
      WHILE n > 1 DO Wr(" "); DEC(n) END;
      Wr(s); Wr("0"); Wr(".");
      WHILE (0 < f) & (e < 0) DO Wr("0"); DEC(f); INC(e) END
    END;
    WHILE f > 0 DO
      DEC(f);
      IF e < 16 THEN Wr(d[e]); INC(e) ELSE Wr("0") END
    END;
    IF D # 0 THEN
      IF D < 0 THEN Wr("D"); Wr("-"); D := - D
      ELSE Wr("D"); Wr("+")
      END;
      Wr(CHR(D DIV 100 + ORD("0"))); D := D MOD 100;
      Wr(CHR(D DIV 10 + ORD("0"))); Wr(CHR(D MOD 10 + ORD("0")))
    END
  END;
  str[pos] := 0X
END RealToFixStr;

(** Convert a string into a real. Precondition: s has a well defined real syntax. Scientific notation with D and E to indicate exponents is allowed. *)
PROCEDURE StrToReal*(s: ARRAY OF CHAR; VAR r: LONGREAL);
VAR p, e: INTEGER; y, g: LONGREAL; neg, negE: BOOLEAN;
BEGIN
  p := 0;
  WHILE (s[p] = " ") OR (s[p] = "0") DO INC(p) END;
  IF s[p] = "-" THEN neg := TRUE; INC(p) ELSE neg := FALSE END;
  WHILE (s[p] = " ") OR (s[p] = "0") DO INC(p) END;
  
  y := 0;
  WHILE ("0" <= s[p]) & (s[p] <= "9") DO
    y := y * 10 + (ORD(s[p]) - 30H);
    INC(p);
  END;
  IF s[p] = "." THEN
    INC(p); g := 1; 
    WHILE ("0" <= s[p]) & (s[p] <= "9") DO
      g := g / 10; y := y + g * (ORD(s[p]) - 30H);
      INC(p);
    END;
  END;
  IF (s[p] = "D") OR (s[p] = "E") THEN
    INC(p); e := 0;
    IF s[p] = "-" THEN negE := TRUE; INC(p) ELSE negE := FALSE END;
    WHILE (s[p] = "0") DO INC(p) END;
    WHILE ("0" <= s[p]) & (s[p] <= "9") DO
      e := e * 10 + (ORD(s[p]) - 30H);
      INC(p);
    END;
    IF negE THEN y := y / Reals.Ten(e)
    ELSE y := y * Reals.Ten(e) END;
  END;
  IF neg THEN y := -y END;
  r := y;
END StrToReal;

(** Convert a string into a boolean. "Yes", "True" and "On" are TRUE all other strings are FALSE.
  Leading white space characters are ignored. *)
  PROCEDURE StrToBool*(VAR str: ARRAY OF CHAR; VAR b: BOOLEAN);
    VAR i: LONGINT;
  BEGIN
    i := 0;
    WHILE (str[i] # 0X) & (str[i] <= " ") DO
      INC(i)
    END;
    CASE CAP(str[i]) OF
      "Y", "T": b := TRUE
      |"O": b := CAP(str[i+1]) = "N"
    ELSE
      b := FALSE
    END
  END StrToBool;

(** Convert a boolean into "Yes" or "No". *)
  PROCEDURE BoolToStr*(b: BOOLEAN; VAR str: ARRAY OF CHAR);
  BEGIN
    IF b THEN
      COPY("Yes", str)
    ELSE
      COPY("No", str)
    END
  END BoolToStr;

(** Convert a string to a set *)
  PROCEDURE StrToSet* (str: ARRAY OF CHAR; VAR set: SET);
  VAR i, d, d1: INTEGER; ch: CHAR; dot: BOOLEAN;
  BEGIN
    set := {}; dot := FALSE;
    i := 0; ch := str[i];
    WHILE (ch # 0X) & (ch # "}") DO
      WHILE (ch # 0X) & ((ch < "0") OR (ch > "9")) DO INC(i); ch := str[i] END;
      d := 0; WHILE (ch >= "0") & (ch <= "9") DO d := d*10 + ORD(ch) - 30H; INC(i); ch := str[i] END;
      IF d <= MAX(SET) THEN INCL(set, d) END;
      IF dot THEN
        d1 := 0;
        WHILE (d1 <= MAX(SET)) & (d1 < d) DO INCL(set, d1); INC(d1) END;
        dot := FALSE
      END;
      WHILE ch = " " DO INC(i); ch := str[i] END;
      IF ch = "." THEN d1 := d + 1; dot := TRUE END
    END
  END StrToSet;

(** Convert a set to a string *)
  PROCEDURE SetToStr* (set: SET; VAR str: ARRAY OF CHAR);
  VAR i, j, k: INTEGER; noFirst: BOOLEAN;
  BEGIN
    str[0] := "{"; i := 0; k := 1; noFirst := FALSE;
    WHILE i <= MAX(SET) DO
      IF i IN set THEN
        IF noFirst THEN str[k] := ","; INC(k) ELSE noFirst := TRUE END;
        IF i >= 10 THEN str[k] := CHR(i DIV 10 + 30H); INC(k) END;
        str[k] := CHR(i MOD 10 + 30H); INC(k);
        j := i; INC(i);
        WHILE (i <= MAX(SET)) & (i IN set) DO INC(i) END;
        IF i-2 > j THEN
          str[k] := "."; str[k+1] := "."; INC(k, 2); j := i - 1;
          IF j >= 10 THEN str[k] := CHR(j DIV 10 + 30H); INC(k) END;
          str[k] := CHR(j MOD 10 + 30H); INC(k)
        ELSE i := j
        END
      END;
      INC(i)
    END;
    str[k] := "}"; str[k+1] := 0X
  END SetToStr;

(** Convert date (Oberon.GetClock) into specified format. *)
  PROCEDURE DateToStr*(date: LONGINT; VAR str: ARRAY OF CHAR);
    VAR i, j, k, x: LONGINT; form, name: ARRAY 32 OF CHAR;
  BEGIN
    COPY(dateform, form);
    IF form = "" THEN form := "DD.MM.YY" END;
    i := 0; j := 0;
    WHILE form[j] # 0X DO
      IF CAP(form[j]) = "D" THEN  (* Day *)
        INC(j); x := date MOD 32;
        IF CAP(form[j]) = "D" THEN
          INC(j);
          IF CAP(form[j]) = "D" THEN
            INC(j); x := Dates.DayOfWeek(date);
            IF CAP(form[j]) = "D" THEN INC(j); COPY(lDayName[x], name)
            ELSE COPY(sDayName[x], name)
            END;
            k := 0; WHILE name[k] # 0X DO str[i] := name[k]; INC(i); INC(k) END
          ELSE (* day with leading zero *)
            str[i] := CHR(x DIV 10 + ORD("0"));
            str[i + 1] := CHR(x MOD 10 + ORD("0"));
            INC(i, 2)
          END
        ELSE  (* no leading zero *)
          IF x > 9 THEN str[i] := CHR(x DIV 10 + ORD("0")); INC(i) END;
          str[i] := CHR(x MOD 10 + ORD("0")); INC(i)
        END
      ELSIF CAP(form[j]) = "M" THEN  (* Month *)
        INC(j); x := date DIV 32 MOD 16;
        IF CAP(form[j]) = "M" THEN
          INC(j);
          IF CAP(form[j]) = "M" THEN
            INC(j);
            IF CAP(form[j]) = "M" THEN INC(j); COPY(lMonthName[x-1], name)
            ELSE COPY(sMonthName[x-1], name) 
            END;
            k := 0; WHILE name[k] # 0X DO str[i] := name[k]; INC(i); INC(k) END
          ELSE
            str[i] := CHR(x DIV 10 + ORD("0"));
            str[i + 1] := CHR(x MOD 10 + ORD("0"));
            INC(i, 2)
          END
        ELSE
          IF x > 9 THEN str[i] := CHR(x DIV 10 + ORD("0")); INC(i) END;
          str[i] := CHR(x MOD 10 + ORD("0")); INC(i)
        END
      ELSIF CAP(form[j]) = "Y" THEN  (* Year *)
        INC(j,2); x := date DIV 512;
        IF CAP(form[j]) = "Y" THEN
          INC(j, 2); INC(x, 1900);
          str[i] := CHR(x DIV 1000 + ORD("0")); str[i + 1] := CHR(x DIV 100 MOD 10 + ORD("0"));
          str[i + 2] := CHR(x DIV 10 MOD 10 + ORD("0")); str[i + 3] := CHR(x MOD 10 + ORD("0"));
          INC(i, 4)
        ELSE
          str[i] := CHR(x DIV 10 MOD 10 + ORD("0")); str[i + 1] := CHR(x MOD 10 + ORD("0"));
          INC(i, 2)
        END
      ELSE str[i] := form[j]; INC(i); INC(j)
      END
    END;
    str[i] := 0X
  END DateToStr;

(** Returns a month's name (set short to get the abbreviation) *) 
  PROCEDURE MonthToStr* (month: INTEGER; VAR str: ARRAY OF CHAR; short: BOOLEAN);
  BEGIN
    month := (month - 1) MOD 12;
    IF short THEN COPY(sMonthName[month], str) ELSE COPY(lMonthName[month], str) END
  END MonthToStr;

(** Returns a day's name (set short to get the abbreviation) *) 
  PROCEDURE DayToStr* (day: INTEGER; VAR str: ARRAY OF CHAR; short: BOOLEAN);
  BEGIN
    IF short THEN COPY(sDayName[day MOD 7], str) ELSE COPY(lDayName[day MOD 7], str) END
  END DayToStr;

(** Convert time (Oberon.GetClock) into specified format. *)
  PROCEDURE TimeToStr*(time: LONGINT; VAR str: ARRAY OF CHAR);
    VAR i, j, x, h, hPos: LONGINT; form: ARRAY 32 OF CHAR; shortH, leadingH: BOOLEAN;
  BEGIN
    COPY(timeform, form);
    IF form = "" THEN form := "HH:MM:SS" END;
    i := 0; j := 0; h:= time DIV 4096 MOD 32; shortH := FALSE;
    WHILE form[j] # 0X DO
      IF ((CAP(form[j]) = "A") OR (CAP(form[j]) = "P")) & (CAP(form[j+1]) = "M") THEN
        shortH := TRUE;
        IF CAP(form[j]) = form[j] THEN x := 0 ELSE x := 32 END;
        IF  (h < 1) OR (h > 12) THEN str[i] := CHR(ORD("P") + x) ELSE str[i] := CHR(ORD("A") + x) END;
        h := h MOD 12; IF h = 0 THEN h := 12 END;
        str[i + 1] := CHR(ORD("M") + x);
        INC(i, 2);
        WHILE (CAP(form[j]) = "A") OR (CAP(form[j]) = "P") OR (CAP(form[j]) = "M") DO INC(j) END
      ELSIF form[j] = "H" THEN
        hPos := i; INC(i, 2); INC(j); leadingH := (form[j] = "H");
        IF leadingH THEN INC(j) END
      ELSIF form[j] = "M" THEN
        INC(j); x := time DIV 64 MOD 64;
        IF form[j] = "M" THEN str[i] := CHR(x DIV 10 + ORD("0")); INC(i); INC(j)
        ELSIF x > 9 THEN str[i] := CHR(x DIV 10 + ORD("0")); INC(i)
        END;
        str[i] := CHR(x MOD 10 + ORD("0")); INC(i)
      ELSIF form[j] = "S" THEN
        INC(j); x := time MOD 64;
        IF form[j] = "S" THEN str[i] := CHR(x DIV 10 + ORD("0")); INC(i); INC(j)
        ELSIF x > 9 THEN str[i] := CHR(x DIV 10 + ORD("0")); INC(i)
        END;
        str[i] := CHR(x MOD 10 + ORD("0")); INC(i)
      ELSE str[i] := form[j]; INC(i); INC(j)
      END
    END;
    str[i] := 0X;
    IF ~leadingH THEN
      IF h > 9 THEN str[hPos] := CHR(h DIV 10 + ORD("0")); INC(hPos)
      ELSE i := hPos + 1; WHILE str[i] # 0X DO str[i] := str[i + 1]; INC(i) END
      END;
      str[hPos] := CHR(h MOD 10 + ORD("0"))
    ELSE
      str[hPos] := CHR(h DIV 10 + ORD("0"));
      str[hPos + 1] := CHR(h MOD 10 + ORD("0"))
    END
  END TimeToStr;

(** Convert a string into an time value. Leading white space characters are ignored. *)
  PROCEDURE StrToTime*(str: ARRAY OF CHAR; VAR time: LONGINT);
    VAR
      h, m, s: LONGINT;
      i: INTEGER;
  BEGIN
    i := 0;
    WHILE (str[i] # 0X) & ((str[i] < "0") OR (str[i] > "9")) DO INC(i) END;
    StrToIntPos(str, h, i);
    WHILE (str[i] # 0X) & ((str[i] < "0") OR (str[i] > "9")) DO INC(i) END;
    StrToIntPos(str, m, i);
    WHILE (str[i] # 0X) & ((str[i] < "0") OR (str[i] > "9")) DO INC(i) END;
    StrToIntPos(str, s, i);
    time := (h*64 + m)*64 + s
  END StrToTime;

(** Convert a string into an date value. Leading white space characters are ignored. *)
  PROCEDURE StrToDate*(str: ARRAY OF CHAR; VAR date: LONGINT);
    VAR
      d, m, y: LONGINT;
      i: INTEGER;
  BEGIN
    i := 0;
    WHILE (str[i] # 0X) & ((str[i] < "0") OR (str[i] > "9")) DO INC(i) END;
    StrToIntPos(str, d, i);
    WHILE (str[i] # 0X) & ((str[i] < "0") OR (str[i] > "9")) DO INC(i) END;
    StrToIntPos(str, m, i);
    WHILE (str[i] # 0X) & ((str[i] < "0") OR (str[i] > "9")) DO INC(i) END;
    StrToIntPos(str, y, i); y := y-1900;
    date := (y*16 + m)*32 + d
  END StrToDate;

  PROCEDURE Init();
    VAR i: LONGINT;  s: Texts.Scanner; txt : Texts.Text; (* noch *)
  BEGIN
    NEW(txt);
    Texts.Open(txt, "System.DateFormat"); (* got rid of Oberon.OpenScanner -- noch *)
    Texts.OpenScanner(s, txt, 0);
    IF s.class = Texts.String THEN COPY(s.s, dateform) ELSE dateform := "" END;
    Texts.Open(txt, "System.TimeFormat");
    Texts.OpenScanner(s, txt, 0);
    IF s.class = Texts.String THEN COPY(s.s, timeform) ELSE timeform := "" END;
    sDayName[0] := "Mon";  sDayName[1] := "Tue";  sDayName[2] := "Wed";  sDayName[3] := "Thu";
    sDayName[4] := "Fri";  sDayName[5] := "Sat";  sDayName[6] := "Sun";

    lDayName[0] := "Monday";  lDayName[1] := "Tuesday";  lDayName[2] := "Wednesday";  lDayName[3] := "Thursday";
    lDayName[4] := "Friday";  lDayName[5] := "Saturday";  lDayName[6] := "Sunday";

    sMonthName[0] := "Jan"; sMonthName[1] := "Feb"; sMonthName[2] := "Mar"; sMonthName[3] := "Apr";
    sMonthName[4] := "May"; sMonthName[5] := "Jun"; sMonthName[6] := "Jul"; sMonthName[7] := "Aug";
    sMonthName[8] := "Sep"; sMonthName[9] := "Oct"; sMonthName[10] := "Nov"; sMonthName[11] := "Dec";

    lMonthName[0] := "January"; lMonthName[1] := "February"; lMonthName[2] := "March"; lMonthName[3] := "April";
    lMonthName[4] := "May"; lMonthName[5] := "June"; lMonthName[6] := "July"; lMonthName[7] := "August";
    lMonthName[8] := "September"; lMonthName[9] := "October"; lMonthName[10] := "November";
    lMonthName[11] := "December";

    FOR i := 0 TO 255 DO
      isAlpha[i] := ((i >= ORD("A")) & (i <= ORD("Z"))) OR ((i >= ORD("a")) & (i <= ORD("z")))
    END;
    isAlpha[ORD("€")] := TRUE; isAlpha[ORD("")] := TRUE; isAlpha[ORD("‚")] := TRUE;
    isAlpha[ORD("ƒ")] := TRUE; isAlpha[ORD("„")] := TRUE; isAlpha[ORD("…")] := TRUE;
    isAlpha[ORD("†")] := TRUE; isAlpha[ORD("‡")] := TRUE; isAlpha[ORD("ˆ")] := TRUE;
    isAlpha[ORD("‰")] := TRUE; isAlpha[ORD("Š")] := TRUE; isAlpha[ORD("‹")] := TRUE;
    isAlpha[ORD("Œ")] := TRUE; isAlpha[ORD("")] := TRUE; isAlpha[ORD("Ž")] := TRUE;
    isAlpha[ORD("")] := TRUE; isAlpha[ORD("")] := TRUE; isAlpha[ORD("‘")] := TRUE;
    isAlpha[ORD("’")] := TRUE; isAlpha[ORD("“")] := TRUE; isAlpha[ORD("”")] := TRUE;
    isAlpha[ORD("•")] := TRUE; isAlpha[ORD("–")] := TRUE;
    FOR i := 0 TO 255 DO
      ISOToOberon[i] := CHR(i); OberonToISO[i] := CHR(i)
    END;
    ISOToOberon[8] := CHR(127);
    ISOToOberon[146] := CHR(39);
    ISOToOberon[160] := CHR(32);
    ISOToOberon[162] := CHR(99);
    ISOToOberon[166] := CHR(124);
    ISOToOberon[168] := CHR(34);
    ISOToOberon[169] := CHR(99);
    ISOToOberon[170] := CHR(97);
    ISOToOberon[171] := CHR(60);
    ISOToOberon[173] := CHR(45);
    ISOToOberon[174] := CHR(114);
    ISOToOberon[175] := CHR(45);
    ISOToOberon[176] := CHR(111);
    ISOToOberon[178] := CHR(50);
    ISOToOberon[179] := CHR(51);
    ISOToOberon[180] := CHR(39);
    ISOToOberon[183] := CHR(46);
    ISOToOberon[185] := CHR(49);
    ISOToOberon[186] := CHR(48);
    ISOToOberon[187] := CHR(62);
    ISOToOberon[192] := CHR(65);
    ISOToOberon[193] := CHR(65);
    ISOToOberon[194] := CHR(65);
    ISOToOberon[195] := CHR(65);
    ISOToOberon[196] := CHR(128); OberonToISO[128] := CHR(196);
    ISOToOberon[197] := CHR(65);
    ISOToOberon[198] := CHR(65);
    ISOToOberon[199] := CHR(67);
    ISOToOberon[200] := CHR(69);
    ISOToOberon[201] := CHR(69);
    ISOToOberon[202] := CHR(69);
    ISOToOberon[203] := CHR(69);
    ISOToOberon[204] := CHR(73);
    ISOToOberon[205] := CHR(73);
    ISOToOberon[206] := CHR(73);
    ISOToOberon[207] := CHR(73);
    ISOToOberon[208] := CHR(68);
    ISOToOberon[209] := CHR(78);
    ISOToOberon[210] := CHR(79);
    ISOToOberon[211] := CHR(79);
    ISOToOberon[212] := CHR(79);
    ISOToOberon[213] := CHR(79);
    ISOToOberon[214] := CHR(129); OberonToISO[129] := CHR(214);
    ISOToOberon[215] := CHR(42);
    ISOToOberon[216] := CHR(79);
    ISOToOberon[217] := CHR(85);
    ISOToOberon[218] := CHR(85);
    ISOToOberon[219] := CHR(85);
    ISOToOberon[220] := CHR(130); OberonToISO[130] := CHR(220);
    ISOToOberon[221] := CHR(89);
    ISOToOberon[222] := CHR(80);
    ISOToOberon[223] := CHR(150); OberonToISO[150] := CHR(223);
    ISOToOberon[224] := CHR(139); OberonToISO[139] := CHR(224);
    ISOToOberon[225] := CHR(148); OberonToISO[148] := CHR(225);
    ISOToOberon[226] := CHR(134); OberonToISO[134] := CHR(226);
    ISOToOberon[227] := CHR(97);
    ISOToOberon[228] := CHR(131); OberonToISO[131] := CHR(228);
    ISOToOberon[229] := CHR(97);
    ISOToOberon[230] := CHR(97);
    ISOToOberon[231] := CHR(147); OberonToISO[147] := CHR(231);
    ISOToOberon[232] := CHR(140); OberonToISO[140] := CHR(232);
    ISOToOberon[233] := CHR(144); OberonToISO[144] := CHR(233);
    ISOToOberon[234] := CHR(135); OberonToISO[135] := CHR(234);
    ISOToOberon[235] := CHR(145); OberonToISO[145] := CHR(235);
    ISOToOberon[236] := CHR(141); OberonToISO[141] := CHR(236);
    ISOToOberon[237] := CHR(105);
    ISOToOberon[238] := CHR(136); OberonToISO[136] := CHR(238);
    ISOToOberon[239] := CHR(146); OberonToISO[146] := CHR(239);
    ISOToOberon[240] := CHR(100);
    ISOToOberon[241] := CHR(149); OberonToISO[149] := CHR(241);
    ISOToOberon[242] := CHR(142); OberonToISO[142] := CHR(242);
    ISOToOberon[243] := CHR(111);
    ISOToOberon[244] := CHR(137); OberonToISO[137] := CHR(244);
    ISOToOberon[245] := CHR(111);
    ISOToOberon[246] := CHR(132); OberonToISO[132] := CHR(246);
    ISOToOberon[248] := CHR(111);
    ISOToOberon[249] := CHR(143); OberonToISO[143] := CHR(249);
    ISOToOberon[250] := CHR(117);
    ISOToOberon[251] := CHR(138); OberonToISO[138] := CHR(251);
    ISOToOberon[252] := CHR(133); OberonToISO[133] := CHR(252);
    ISOToOberon[253] := CHR(121);
    ISOToOberon[254] := CHR(112);
    ISOToOberon[255] := CHR(121);
    CRLF[0] := CR; CRLF[1] := LF; CRLF[2] := 0X; CRLF[3] := 0X
  END Init;

BEGIN
  Init()
END ethStrings.
