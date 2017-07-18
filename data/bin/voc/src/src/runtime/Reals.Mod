MODULE Reals;
  (* JT, 5.2.90 / RC 9.12.91 conversion between reals and strings for HP-700, MB 9.12.91, JT for Ofront, 16.3. 95*)
  (* DCWB 20160817 Made independent of INTEGER size *)

  IMPORT SYSTEM;

  PROCEDURE Ten*(e: INTEGER): REAL;
  VAR r, power: LONGREAL;
  BEGIN r := 1.0;
    power := 10.0;
    WHILE e > 0 DO
      IF ODD(e) THEN r := r * power END ;
      power := power * power; e := e DIV 2
    END ;
    RETURN SHORT(r)
  END Ten;


  PROCEDURE TenL*(e: INTEGER): LONGREAL;
    VAR r, power: LONGREAL;
  BEGIN r := 1.0;
    power := 10.0;
    LOOP
      IF ODD(e) THEN r := r * power END ;
      e := e DIV 2;
      IF e <= 0 THEN RETURN r END ;
      power := power * power
    END
  END TenL;


  (* Real number format (IEEE 754)

    TYPE REAL - Single precision / binary32:
      1/sign, 8/exponent, 23/significand

    TYPE LONGREAL - Double precision / binary64:
      1/sign, 11/exponent, 52/significand

    exponent:
      stored as exponent value + 127.

    significand (fraction):
      excludes leading (most significant) bit which is assumed to be 1.
  *)


  PROCEDURE Expo*(x: REAL): INTEGER;
    VAR i: INTEGER;
  BEGIN
    SYSTEM.GET(SYSTEM.ADR(x)+2, i);
    RETURN (i DIV 128) MOD 256
  END Expo;

  PROCEDURE SetExpo*(VAR x: REAL; ex: INTEGER);
  VAR c: CHAR;
  BEGIN
    (* Replace exponent bits within top byte of REAL *)
    SYSTEM.GET(SYSTEM.ADR(x)+3, c);
    SYSTEM.PUT(SYSTEM.ADR(x)+3, CHR(((ORD(c) DIV 128) * 128) + ((ex DIV 2) MOD 128)));
    (* Replace exponent bits within 2nd byte of REAL *)
    SYSTEM.GET(SYSTEM.ADR(x)+2, c);
    SYSTEM.PUT(SYSTEM.ADR(x)+2, CHR((ORD(c) MOD 128) + ((ex MOD 2) * 128)))
  END SetExpo;

  PROCEDURE ExpoL*(x: LONGREAL): INTEGER;
    VAR i: INTEGER;
  BEGIN
    SYSTEM.GET(SYSTEM.ADR(x)+6, i);
    RETURN (i DIV 16) MOD 2048
  END ExpoL;

  (* Convert LONGREAL: Write positive integer value of x into array d.
     The value is stored backwards, i.e. least significant digit
     first. n digits are written, with trailing zeros fill.
     On entry x has been scaled to the number of digits required. *)
  PROCEDURE ConvertL*(x: LONGREAL; n: INTEGER; VAR d: ARRAY OF CHAR);
    VAR i, j, k: LONGINT;
  BEGIN
    IF x < 0 THEN x := -x END;
    k := 0;

    IF (SIZE(LONGINT) < 8) & (n > 9) THEN
      (* There are more decimal digits than can be held in a single LONGINT *)
      i := ENTIER(x /      1000000000.0D0);  (* The 10th and higher digits *)
      j := ENTIER(x - (i * 1000000000.0D0)); (* The low 9 digits *)
      (* First generate the low 9 digits. *)
      IF j < 0 THEN j := 0 END;
      WHILE k < 9 DO
        d[k] := CHR(j MOD 10 + 48); j := j DIV 10; INC(k)
      END;
      (* Fall through to generate the upper digits *)
    ELSE
      (* We can generate all the digits in one go. *)
      i := ENTIER(x);
    END;

    WHILE k < n DO
      d[k] := CHR(i MOD 10 + 48); i := i DIV 10; INC(k)
    END
  END ConvertL;


  PROCEDURE Convert*(x: REAL; n: INTEGER; VAR d: ARRAY OF CHAR);
  BEGIN ConvertL(x, n, d)
  END Convert;

  PROCEDURE ToHex(i: INTEGER): CHAR;
  BEGIN
    IF i < 10 THEN RETURN CHR(i+48)
    ELSE           RETURN CHR(i+55) END
  END ToHex;

  PROCEDURE BytesToHex(VAR b, d: ARRAY OF SYSTEM.BYTE);
    VAR i: INTEGER; l: LONGINT; by: CHAR;
  BEGIN
    i := 0; l := LEN(b);
    WHILE i < l DO
      by := SYSTEM.VAL(CHAR, b[i]);
      d[i*2]   := ToHex(ORD(by) DIV 16);
      d[i*2+1] := ToHex(ORD(by) MOD 16);
      INC(i)
    END
  END BytesToHex;

  (* Convert Hex *)
  PROCEDURE ConvertH*(y: REAL; VAR d: ARRAY OF CHAR);
  BEGIN BytesToHex(y, d)
  END ConvertH;

  (* Convert Hex Long *)
  PROCEDURE ConvertHL*(x: LONGREAL; VAR d: ARRAY OF CHAR);
  BEGIN BytesToHex(x, d)
  END ConvertHL;

END Reals.
