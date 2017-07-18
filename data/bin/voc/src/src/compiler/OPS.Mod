MODULE OPS;  (* NW, RC 6.3.89 / 18.10.92 *)    (* object model 3.6.92 *)

  IMPORT OPM, SYSTEM;

  CONST
    MaxStrLen* = 256;
    MaxIdLen = 256;


    (* Symbols values (also used as op values):
       |  0          1          2          3          4
    ---|--------------------------------------------------------
     0 |  null       *          /          DIV        MOD
     5 |  &          +          -          OR         =
    10 |  #          <          <=         >          >=
    15 |  IN         IS         ^          .          ,
    20 |  :          ..         )          ]          }
    25 |  OF         THEN       DO         TO         BY
    30 |  (          [          {          ~          :=
    35 |  number     NIL        string     ident      ;
    40 |  |          END        ELSE       ELSIF      UNTIL
    45 |  IF         CASE       WHILE      REPEAT     FOR
    50 |  LOOP       WITH       EXIT       RETURN     ARRAY
    55 |  RECORD     POINTER    BEGIN      CONST      TYPE
    60 |  VAR        PROCEDURE  IMPORT     MODULE     eof
    *)

    null*   = 0;  times*     = 1;  slash*   = 2;  div*    = 3;  mod*       = 4;
    and*    = 5;  plus*      = 6;  minus*   = 7;  or*     = 8;  eql*       = 9;
    neq*    = 10; lss*       = 11; leq*     = 12; gtr*    = 13; geq*       = 14;
    in*     = 15; is*        = 16; arrow*   = 17; period* = 18; comma*     = 19;
    colon*  = 20; upto*      = 21; rparen*  = 22; rbrak*  = 23; rbrace*    = 24;
    of*     = 25; then*      = 26; do*      = 27; to*     = 28; by*        = 29;
    lparen* = 30; lbrak*     = 31; lbrace*  = 32; not*    = 33; becomes*   = 34;
    number* = 35; nil*       = 36; string*  = 37; ident*  = 38; semicolon* = 39;
    bar*    = 40; end*       = 41; else*    = 42; elsif*  = 43; until*     = 44;
    if*     = 45; case*      = 46; while*   = 47; repeat* = 48; for*       = 49;
    loop*   = 50; with*      = 51; exit*    = 52; return* = 53; array*     = 54;
    record* = 55; pointer*   = 56; begin*   = 57; const*  = 58; type*      = 59;
    var*    = 60; procedure* = 61; import*  = 62; module* = 63; eof*       = 64;

    (* Symbol numtyp values *)
    char* = 1; integer* = 2; real* = 3; longreal* = 4;


  TYPE
    Name* = ARRAY MaxIdLen OF CHAR;
    String* = ARRAY MaxStrLen OF CHAR;

  VAR
    (* name, str, numtyp, intval, realval, lrlval are implicit results of Get *)
    name*:    Name;
    str*:     String;
    numtyp*:  INTEGER;       (* 1 = char, 2 = integer, 3 = real, 4 = longreal *)
    intval*:  SYSTEM.INT64;  (* integer value or string length *)
    realval*: REAL;
    lrlval*:  LONGREAL;

    ch: CHAR;     (*current character*)

  PROCEDURE err(n: INTEGER);
  BEGIN OPM.err(n)
  END err;

  PROCEDURE Str(VAR sym: SHORTINT);
    VAR i: INTEGER; och: CHAR;
  BEGIN i := 0; och := ch;
    LOOP OPM.Get(ch);
      IF ch = och THEN EXIT END ;
      IF ch < " " THEN err(3); EXIT END ;
      IF i = MaxStrLen-1 THEN err(241); EXIT END ;
      str[i] := ch; INC(i)
    END ;
    OPM.Get(ch); str[i] := 0X; intval := i + 1;
    IF intval = 2 THEN
      sym := number; numtyp := 1; intval := ORD(str[0])
    ELSE sym := string
    END
  END Str;

  PROCEDURE Identifier(VAR sym: SHORTINT);
    VAR i: INTEGER;
  BEGIN i := 0;
    REPEAT
      name[i] := ch; INC(i); OPM.Get(ch)
    UNTIL (ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch)) OR (i = MaxIdLen);
    IF i = MaxIdLen THEN err(240); DEC(i) END ;
    name[i] := 0X; sym := ident
  END Identifier;

  PROCEDURE Number;
    CONST maxhexdigits = 16;
    VAR i, m, n, d, e: INTEGER; dig: ARRAY 24 OF CHAR; f: LONGREAL; expCh: CHAR; neg: BOOLEAN;

    PROCEDURE Ten(e: INTEGER): LONGREAL;
      VAR x, p: LONGREAL;
    BEGIN x := 1; p := 10;
      WHILE e > 0 DO
        IF ODD(e) THEN x := x*p END;
        e := e DIV 2;
        IF e > 0 THEN p := p*p END (* prevent overflow *)
      END;
      RETURN x
    END Ten;

    PROCEDURE Ord(ch: CHAR; hex: BOOLEAN): INTEGER;
    BEGIN (* ("0" <= ch) & (ch <= "9") OR ("A" <= ch) & (ch <= "F") *)
      IF ch <= "9" THEN RETURN ORD(ch) - ORD("0")
      ELSIF hex THEN RETURN ORD(ch) - ORD("A") + 10
      ELSE err(2); RETURN 0
      END
    END Ord;

  BEGIN (* ("0" <= ch) & (ch <= "9") *)
    i := 0; m := 0; n := 0; d := 0;
    LOOP (* read mantissa *)
      IF ("0" <= ch) & (ch <= "9") OR (d = 0) & ("A" <= ch) & (ch <= "F") THEN
        IF (m > 0) OR (ch # "0") THEN (* ignore leading zeros *)
          IF n < LEN(dig) THEN dig[n] := ch; INC(n) END;
          INC(m)
        END;
        OPM.Get(ch); INC(i)
      ELSIF ch = "." THEN OPM.Get(ch);
        IF ch = "." THEN (* ellipsis *) ch := 7FX; EXIT
        ELSIF d = 0 THEN (* i > 0 *) d := i
        ELSE err(2)
        END
      ELSE EXIT
      END
    END; (* 0 <= n <= m <= i, 0 <= d <= i *)
    IF d = 0 THEN (* integer *)
      IF n = m THEN intval := 0; i := 0;
        IF ch = "X" THEN (* character *) OPM.Get(ch); numtyp := char;
          IF n <= 2 THEN
            WHILE i < n DO intval := intval*10H + Ord(dig[i], TRUE); INC(i) END
          ELSE err(203)
          END
        ELSIF ch = "H" THEN (* hexadecimal *) OPM.Get(ch); numtyp := integer;
          IF n <= maxhexdigits THEN
            IF (n = maxhexdigits) & (dig[0] > "7") THEN (* prevent overflow *) intval := -1 END;
            WHILE i < n DO intval := intval*10H + Ord(dig[i], TRUE); INC(i) END
          ELSE err(203)
          END
        ELSE (* decimal *) numtyp := integer;
          WHILE i < n DO d := Ord(dig[i], FALSE); INC(i);
            IF intval <= (MAX(SYSTEM.INT64) - d) DIV 10 THEN intval := intval*10 + d
            ELSE err(203)
            END
          END
        END
      ELSE err(203)
      END
    ELSE (* fraction *)
      f := 0; e := 0; expCh := "E";
      WHILE n > 0 DO (* 0 <= f < 1 *) DEC(n); f := (Ord(dig[n], FALSE) + f)/10 END;
      IF (ch = "E") OR (ch = "D") THEN expCh := ch; OPM.Get(ch); neg := FALSE;
        IF ch = "-" THEN neg := TRUE; OPM.Get(ch)
        ELSIF ch = "+" THEN OPM.Get(ch)
        END;
        IF ("0" <= ch) & (ch <= "9") THEN
          REPEAT n := Ord(ch, FALSE); OPM.Get(ch);
            IF e <= (MAX(INTEGER) - n) DIV 10 THEN e := e*10 + n
            ELSE err(203)
            END
          UNTIL (ch < "0") OR ("9" < ch);
          IF neg THEN e := -e END
        ELSE err(2)
        END
      END;
      DEC(e, i-d-m); (* decimal point shift *)
      IF expCh = "E" THEN numtyp := real;
        IF (1-OPM.MaxRExp < e) & (e <= OPM.MaxRExp) THEN
          IF e < 0 THEN realval := SHORT(f / Ten(-e))
          ELSE realval := SHORT(f * Ten(e))
          END
        ELSE err(203)
        END
      ELSE numtyp := longreal;
        IF (1-OPM.MaxLExp < e) & (e <= OPM.MaxLExp) THEN
          IF e < 0 THEN lrlval := f / Ten(-e)
          ELSE lrlval := f * Ten(e)
          END
        ELSE err(203)
        END
      END
    END
  END Number;

  PROCEDURE Get*(VAR sym: SHORTINT);
    VAR s: SHORTINT;

    PROCEDURE Comment;  (* do not read after end of file *)
    BEGIN OPM.Get(ch);
      LOOP
        LOOP
          WHILE ch = "(" DO OPM.Get(ch);
            IF ch = "*" THEN Comment END
          END ;
          IF ch = "*" THEN OPM.Get(ch); EXIT END ;
          IF ch = OPM.Eot THEN EXIT END ;
          OPM.Get(ch)
        END ;
        IF ch = ")" THEN OPM.Get(ch); EXIT END ;
        IF ch = OPM.Eot THEN err(5); EXIT END
      END
    END Comment;

  BEGIN
    OPM.errpos := OPM.curpos-1;
    WHILE ch <= " " DO (*ignore control characters*)
      IF ch = OPM.Eot THEN sym := eof; RETURN
      ELSE OPM.Get(ch)
      END
    END ;
    CASE ch OF   (* ch > " " *)
    | 22X,
      27X:      Str(s)
    | "#":      s := neq; OPM.Get(ch)
    | "&":      s := and; OPM.Get(ch)
    | "(":      OPM.Get(ch);
                IF ch = "*" THEN Comment; Get(s) ELSE s := lparen END
    | ")":      s := rparen; OPM.Get(ch)
    | "*":      s := times;  OPM.Get(ch)
    | "+":      s := plus;   OPM.Get(ch)
    | ",":      s := comma;  OPM.Get(ch)
    | "-":      s := minus;  OPM.Get(ch)
    | ".":      OPM.Get(ch);
                IF ch = "." THEN OPM.Get(ch); s := upto ELSE s := period END
    | "/":      s := slash;  OPM.Get(ch)
    | "0".."9": Number; s := number
    | ":":      OPM.Get(ch);
                IF ch = "=" THEN OPM.Get(ch); s := becomes ELSE s := colon END
    | ";":      s := semicolon; OPM.Get(ch)
    | "<":      OPM.Get(ch);
                IF ch = "=" THEN OPM.Get(ch); s := leq ELSE s := lss END
    | "=":      s :=  eql; OPM.Get(ch)
    | ">":      OPM.Get(ch);
                IF ch = "=" THEN OPM.Get(ch); s := geq ELSE s := gtr END
    | "A":      Identifier(s); IF name = "ARRAY" THEN s := array END
    | "B":      Identifier(s);
                IF    name = "BEGIN" THEN s := begin
                ELSIF name = "BY"    THEN s := by
                END
    | "C":      Identifier(s);
                IF    name = "CASE"  THEN s := case
                ELSIF name = "CONST" THEN s := const
                END
    | "D":      Identifier(s);
                IF    name = "DO"  THEN s := do
                ELSIF name = "DIV" THEN s := div
                END
    | "E":      Identifier(s);
                IF    name = "END"   THEN s := end
                ELSIF name = "ELSE"  THEN s := else
                ELSIF name = "ELSIF" THEN s := elsif
                ELSIF name = "EXIT"  THEN s := exit
                END
    | "F":      Identifier(s); IF name = "FOR" THEN s := for END
    | "I":      Identifier(s);
                IF    name = "IF"     THEN s := if
                ELSIF name = "IN"     THEN s := in
                ELSIF name = "IS"     THEN s := is
                ELSIF name = "IMPORT" THEN s := import
                END
    | "L":      Identifier(s); IF name = "LOOP" THEN s := loop END
    | "M":      Identifier(s);
                IF    name = "MOD"    THEN s := mod
                ELSIF name = "MODULE" THEN s := module
                END
    | "N":      Identifier(s); IF name = "NIL" THEN s := nil END
    | "O":      Identifier(s);
                IF    name = "OR" THEN s := or
                ELSIF name = "OF" THEN s := of
                END
    | "P":      Identifier(s);
                IF    name = "PROCEDURE" THEN s := procedure
                ELSIF name = "POINTER"   THEN s := pointer
                END
    | "R":      Identifier(s);
                IF    name = "RECORD" THEN s := record
                ELSIF name = "REPEAT" THEN s := repeat
                ELSIF name = "RETURN" THEN s := return
                END
    | "T":      Identifier(s);
                IF    name = "THEN" THEN s := then
                ELSIF name = "TO"   THEN s := to
                ELSIF name = "TYPE" THEN s := type
                END
    | "U":      Identifier(s); IF name = "UNTIL" THEN s := until END
    | "V":      Identifier(s); IF name = "VAR"   THEN s := var END
    | "W":      Identifier(s);
                IF    name = "WHILE" THEN s := while
                ELSIF name = "WITH"  THEN s := with
                END
    | "G".."H",
      "J".."K",
      "Q", "S",
      "X".."Z": Identifier(s)
    | "[":      s := lbrak;  OPM.Get(ch)
    | "]":      s := rbrak;  OPM.Get(ch)
    | "^":      s := arrow;  OPM.Get(ch)
    | "a".."z": Identifier(s)
    | "{":      s := lbrace; OPM.Get(ch)
    | "|":      s := bar;    OPM.Get(ch)
    | "}":      s := rbrace; OPM.Get(ch)
    | "~":      s := not;    OPM.Get(ch)
    | 7FX:      s := upto;   OPM.Get(ch)
    ELSE        s := null;   OPM.Get(ch)
    END ;
    sym := s
  END Get;

  PROCEDURE Init*;
  BEGIN ch := " "
  END Init;

END OPS.
