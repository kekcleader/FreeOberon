MODULE Reals;
(** Module for REAL and LONGREAL conversion from and to a string
%RU Модуль для преобразования REAL и LONGREAL из строки и в строку *)
IMPORT SYSTEM;

TYPE
  SHORTINT = SYSTEM.INT16;
  INTEGER = SYSTEM.INT32;
  HUGEINT = SYSTEM.INT64;
  REAL = SYSTEM.REAL32;
  CHAR = SYSTEM.CHAR16;

  LONGREAL* = SYSTEM.REAL64;

VAR Done-: BOOLEAN; (* Indicates the success of the last conversion operation
%RU                    Указывает на успешность последней операции перевода *)

PROCEDURE Ten(e: INTEGER): LONGREAL;
VAR r, power: LONGREAL;
BEGIN r := 1.0E0; power := 1.0E1;
  WHILE e > 0 DO
    IF ODD(e) THEN r := r*power END;
    power := power*power; e := SHORT(e DIV 2)
  END;
  RETURN r
END Ten;

(** Returns a long real number converted from string `s`
%RU Возвращает длинное вещественное число, преобразованное из строки `s` *)
PROCEDURE LongVal*(IN s: ARRAY OF CHAR): LONGREAL;
VAR p, e: INTEGER; y, g: LONGREAL; neg, negE: BOOLEAN;
BEGIN Done := FALSE;
  p := 0;
  WHILE (s[p] # 0X) & (s[p] <= ' ') DO INC(p) END;
  IF s[p] = '-' THEN neg := TRUE; INC(p) ELSE neg := FALSE END;

  IF ('0' <= s[p]) & (s[p] <= '9') THEN
    y := 0;
    REPEAT y := y * 10 + (ORD(s[p]) - ORD('0')); INC(p)
    UNTIL ~(('0' <= s[p]) & (s[p] <= '9'));

    IF s[p] = '.' THEN
      INC(p); g := 1;
      WHILE ('0' <= s[p]) & (s[p] <= '9') DO
        g := g * 0.1; y := y + g * (ORD(s[p]) - ORD('0'));
        INC(p)
      END;

      IF (s[p] = 'D') OR (s[p] = 'E') THEN
        INC(p); e := 0;
        IF s[p] = '-' THEN negE := TRUE; INC(p)
        ELSE negE := FALSE;
          IF s[p] = '+' THEN INC(p) END
        END;
        IF ('0' <= s[p]) & (s[p] <= '9') THEN
          WHILE ('0' <= s[p]) & (s[p] <= '9') DO
            e := e * 10 + ORD(s[p]) - ORD('0');
            INC(p)
          END;
          IF negE THEN y := y / Ten(e) ELSE y := y * Ten(e) END;
        END
      END;
      IF neg THEN y := -y END;
      Done := TRUE
    END
  END ;
RETURN y END LongVal;

(** Returns a real number converted from string `s`
%RU Возвращает вещественное число, преобразованное из строки `s` *)
PROCEDURE Val*(IN s: ARRAY OF CHAR): REAL;
VAR y: LONGREAL;
BEGIN
  RETURN SHORT(LongVal(s))
END Val;

PROCEDURE digit(n: HUGEINT; VAR s: ARRAY OF CHAR; VAR i: INTEGER);
BEGIN
  DEC(i); s[i] := SHORT(CHR(n MOD 10 + 48));
END digit;

PROCEDURE Length(IN s: ARRAY OF CHAR): INTEGER;
VAR n: INTEGER;
BEGIN n := 0; WHILE (n < LEN(s)) & (s[n] # 0X) DO INC(n) END; RETURN n
END Length;

PROCEDURE prepend(IN t: ARRAY OF CHAR; VAR s: ARRAY OF CHAR; VAR i: INTEGER);
  VAR j: INTEGER; l: INTEGER;
BEGIN
  l := Length(t); IF l > i THEN l := i END;
  DEC(i, SHORT(l)); j := 0;
  WHILE j < l DO s[i+j] := t[j]; INC(j) END
END prepend;

PROCEDURE -Entier64(x: LONGREAL): HUGEINT '(LONGINT)(x)';

PROCEDURE RealP(x: LONGREAL; n: INTEGER; long: BOOLEAN; VAR s: ARRAY OF CHAR);
(** Writes the long real number x to the end of the output
    stream using an exponential form. If the textual representation of x
    requires m characters (including a three-digit signed exponent), x is right
    adjusted in a field of Max(n, m) characters padded with blanks at the left
    end. A plus sign of the mantissa is not written.  LONGREAL is 1/sign,
    11/exponent, 52/significand *)
VAR
  e:   SHORTINT; (* Exponent field *)
  f:   HUGEINT;  (* Fraction field *)
  z:   ARRAY 30 OF CHAR; (* Buffer built backwards *)
  i:   INTEGER;  (* Index into z *)
  el:  INTEGER;  (* Exponent length *)
  x0:  LONGREAL;
  nn:  BOOLEAN;  (* Number negative *)
  en:  BOOLEAN;  (* Exponent negative *)
  m:   HUGEINT;  (* Mantissa digits *)
  d:   INTEGER;  (* Significant digit count to display *)
  dr:  INTEGER;  (* Number of insignificant digits that can be dropped *)
  si:  INTEGER;  (* Runner pointing to s *)

  PROCEDURE OutC(ch: CHAR);
  BEGIN IF si < LEN(s) - 1 THEN s[si] := ch; INC(si) ELSE Done := FALSE END
  END OutC;

BEGIN si := 0; Done := TRUE;
  e  := SYSTEM.VAL(SHORTINT, (SYSTEM.VAL(HUGEINT, x) DIV 10000000000000L) MOD 800H);
  f  := SYSTEM.VAL(HUGEINT, x) MOD 10000000000000L;
  nn := (SYSTEM.VAL(HUGEINT, x) < 0) & ~((e = 7FFH) & (f # 0)); (* Ignore sign on NaN *)
  IF nn THEN DEC(n) END;

  i := LEN(z);
  IF e = 7FFH THEN (* NaN / Infinity *)
    IF f = 0 THEN prepend('Infinity', z, i) ELSE prepend('NaN', z, i) END
  ELSE
    (* Calculate number of significant digits caller has proposed space for, and
       number of digits to generate. *)
    IF long THEN
      el := 3;
      dr := SHORT(n-6);             (* Leave room for dp and '+D000' *)
      IF dr > 17 THEN dr := 17 END; (* Limit to max useful significant digits *)
      d := dr;                      (* Number of digits to generate *)
      IF d < 15 THEN d := 15 END    (* Generate enough digits to do trailing zero suppression *)
    ELSE
      el := 2;
      dr := SHORT(n-5);             (* Leave room for dp and '+E00' *)
      IF dr > 9 THEN dr := 9 END;   (* Limit to max useful significant digits *)
      d := dr;                      (* Number of digits to generate *)
      IF d < 6 THEN d := 6 END      (* Generate enough digits to do trailing zero suppression *)
    END;

    IF e = 0 THEN
      WHILE el > 0 DO DEC(i); z[i] := '0'; DEC(el) END;
      DEC(i); z[i] := '+';
      m := 0;
    ELSE
      IF nn THEN x := -x END;

      (* Scale e to be an exponent of 10 rather than 2 *)
      e := SHORT(SHORT(LONG(e - 1023) * 77 DIV 256));
      IF e >= 0 THEN x := x / Ten(e) ELSE x := Ten(SHORT(-e)) * x END;
      IF x >= 10.0E0 THEN x := 0.1E0 * x; INC(e) END;

      (* Scale x to enough significant digits to reliably test for trailing
         zeroes or to the amount of space available, if greater. *)
      x0 := Ten(SHORT(d - 1));
      x  := x0 * x;
      x  := x + 0.5E0; (* Do not combine with previous line as doing so
                          introduces a least significant bit difference
                          between 32 bit and 64 bit builds. *)
      IF x >= 10.0E0 * x0 THEN x := 0.1E0 * x; INC(e) END;

      (* Generate the exponent digits *)
      IF e < 0 THEN en := TRUE; e := SHORT(-e) ELSE en := FALSE END;
      WHILE el > 0 DO digit(e, z, i); e := SHORT(e DIV 10); DEC(el) END;
      DEC(i); IF en THEN z[i] := '-' ELSE z[i] := '+' END;

      m := Entier64(x)
    END;

    DEC(i); IF long THEN z[i] := 'D' ELSE z[i] := 'E' END;

    (* Drop trailing zeroes where caller proposes to use less space *)
    IF dr < 2 THEN dr := 2 END;
    WHILE (d > dr) & (m MOD 10 = 0) DO m := m DIV 10; DEC(d) END;

    (* Render significant digits *)
    WHILE d > 1 DO digit(m, z, i); m := m DIV 10; DEC(d) END;
    DEC(i); z[i] := '.';
    digit(m, z, i);
  END;

  (* Generate leading padding *)
  DEC(n, SHORT(LEN(z)-i)); WHILE n > 0 DO OutC(' '); DEC(n) END;

  (* Render prepared number from right end of buffer z *)
  IF nn THEN OutC('-') END;
  WHILE i < LEN(z) DO OutC(z[i]); INC(i) END;
  s[si] := 0X
END RealP;

(** Converts real number `x` to string `s`.
     `n` is the minimum number of charactes (`s` is prepended with spaces).
%RU Преобразует вещественное число `x` в строку `s`.
     `n` -- минимальное количество литер (`s` дополняется пробелами слева). *)
PROCEDURE Str*(x: REAL; n: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN RealP(x, n, FALSE, s)
END Str;

(** Converts long real number `x` to string `s`.
     `n` is the minimum number of charactes (`s` is prepended with spaces).
%RU Преобразует длинное вещественное число `x` в строку `s`.
     `n` -- минимальное количество литер (`s` дополняется пробелами слева). *)
PROCEDURE LongStr*(x: LONGREAL; n: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN RealP(x, n, TRUE, s)
END LongStr;

(* Convert LONGREAL: Write positive integer value of x into array d.
   The value is stored backwards, i.e. least significant digit
   first. n digits are written, with trailing zeros fill.
   On entry x has been scaled to the number of digits required. *)
PROCEDURE ConvertL(x: LONGREAL; n: INTEGER; VAR d: ARRAY OF CHAR);
  VAR i, j, k: HUGEINT;
BEGIN
  IF x < 0 THEN x := -x END;
  k := 0;

  IF (SIZE(INTEGER) < 8) & (n > 9) THEN
    (* There are more decimal digits than can be held in a single INTEGER *)
    i := ENTIER(x /      1000000000.0E0);  (* The 10th and higher digits *)
    j := ENTIER(x - (i * 1000000000.0E0)); (* The low 9 digits *)
    (* First generate the low 9 digits. *)
    IF j < 0 THEN j := 0 END;
    WHILE k < 9 DO
      d[k] := SHORT(CHR(j MOD 10 + 48)); j := j DIV 10; INC(k)
    END;
    (* Fall through to generate the upper digits *)
  ELSE
    (* We can generate all the digits in one go. *)
    i := ENTIER(x);
  END;

  WHILE k < n DO
    d[k] := SHORT(CHR(i MOD 10 + 48)); i := i DIV 10; INC(k)
  END
END ConvertL;

PROCEDURE Expo(x: REAL): INTEGER;
VAR i: INTEGER;
BEGIN SYSTEM.GET(SYSTEM.ADR(x), i);
  RETURN SHORT(ASH(i, -23) MOD 100H)
END Expo;

PROCEDURE LongExpo(x: LONGREAL): INTEGER;
VAR i: HUGEINT;
BEGIN SYSTEM.GET(SYSTEM.ADR(x), i);
  RETURN SHORT(ASH(i, -52) MOD 800H)
END LongExpo;

(** Converts real number `x` to string `s`.
     `n` means the minimum number of charactes (`s` is prepended with spaces).
     `k` means the number of digits after a decimal point
%RU Преобразует вещественное число `x` в строку `s`.
     `n` -- минимальное количество литер (`s` дополняется пробелами слева).
     `k` -- количество цифр после запятой (которая выводится как точка) *)
PROCEDURE StrFix*(x: REAL; n, k: INTEGER; VAR s: ARRAY OF CHAR);
CONST maxD = 9;
VAR e, si, i, minus, p, N: INTEGER; x0: REAL;
  d: ARRAY maxD OF CHAR;

  PROCEDURE OutC(ch: CHAR);
  BEGIN IF si < LEN(s) - 1 THEN s[si] := ch; INC(si) ELSE Done := FALSE END
  END OutC;

  PROCEDURE Chars(ch: CHAR; n: INTEGER);
  BEGIN WHILE n > 0 DO OutC(ch); DEC(n) END
  END Chars;

  PROCEDURE DigitsOut(n: INTEGER);
  BEGIN WHILE n > 0 DO DEC(i); OutC(d[i]); DEC(n) END
  END DigitsOut;

BEGIN Done := TRUE; si := 0; e := Expo(x);
  IF k < 0 THEN k := 0 END;
  IF e = 0 THEN
    IF k = 0 THEN Chars(' ', n - 1); OutC('0')
    ELSE Chars(' ', n - k - 2); OutC('0'); OutC('.'); Chars('0', k)
    END
  ELSIF e = 255 THEN Chars(' ', n - 3); OutC('N'); OutC('a'); OutC('N')
  ELSE e := (e - 127) * 77 DIV 256;
    IF x < 0 THEN minus := 1; x := -x ELSE minus := 0 END;
    IF e >= 0 THEN (* x >= 1.0, 77/256 = log 2 *) x := SHORT(x / Ten(e))
      ELSE (*x < 1.0*) x := SHORT(Ten(-e) * x)
    END;
    IF x >= 10.0 THEN x := 0.1 * x; INC(e) END;
    (* 1 <= x < 10 *)
    IF k + e >= maxD - 1 THEN k := maxD - 1 - e
    ELSIF k + e < 0 THEN (* k := -e; !FIXME Why??? *) x := 0.0
    END;
    x0 := SHORT(Ten(k + e)); x := x0 * x + 0.5;
    IF x >= 10.0 * x0 THEN INC(e) END;
    (* e = no. of digits before decimal point *)
    INC(e); i := k + e; ConvertL(x, i, d);
    IF e > 0 THEN
      IF k > 0 THEN p := 0 ELSE p := 1 END;
      Chars(' ', n - e - k - 1 - minus + p);
      IF minus # 0 THEN OutC('-') END;
      DigitsOut(e);
      IF k > 0 THEN OutC('.'); DigitsOut(k) END
    ELSE
      IF k + e > 0 THEN p := 0 ELSE p := 1 END;
      N := n - k - 2 - minus + p;
      IF (k > 0) & (k + e < 0) THEN DEC(N) END;
      Chars(' ', N);
      IF minus # 0 THEN OutC('-') END;
      OutC('0');
      IF k + e > 0 THEN OutC('.'); Chars('0', -e); DigitsOut(k + e)
      ELSIF k > 0 THEN OutC('.'); Chars('0', k)
      END
    END
  END;
  s[si] := 0X
END StrFix;

(** Converts long real number `x` to string `s`.
     `n` is the minimum number of charactes (`s` is prepended with spaces).
     `k` is the number of digits after a decimal point
%RU Преобразует длинное вещественное число `x` в строку `s`.
     `n` -- минимальное количество литер (`s` дополняется пробелами слева).
     `k` -- количество цифр после запятой (которая выводится как точка) *)
PROCEDURE LongStrFix*(x: LONGREAL; n, k: INTEGER; VAR s: ARRAY OF CHAR);
CONST maxD = 20;
VAR e, si, i, minus, p, N: INTEGER; x0: LONGREAL;
  d: ARRAY maxD OF CHAR;

  PROCEDURE OutC(ch: CHAR);
  BEGIN IF si < LEN(s) - 1 THEN s[si] := ch; INC(si) ELSE Done := FALSE END
  END OutC;

  PROCEDURE Chars(ch: CHAR; n: INTEGER);
  BEGIN WHILE n > 0 DO OutC(ch); DEC(n) END
  END Chars;

  PROCEDURE DigitsOut(n: INTEGER);
  BEGIN WHILE n > 0 DO DEC(i); OutC(d[i]); DEC(n) END
  END DigitsOut;

BEGIN Done := TRUE; si := 0; e := LongExpo(x);
  IF k < 0 THEN k := 0 END;
  IF e = 0 THEN
    IF k = 0 THEN Chars(' ', n - 1); OutC('0')
    ELSE Chars(' ', n - k - 2); OutC('0'); OutC('.'); Chars('0', k)
    END
  ELSIF e = 2047 THEN Chars(' ', n - 3); OutC('N'); OutC('a'); OutC('N')
  ELSE e := (e - 1023) * 77 DIV 256;
    IF x < 0 THEN minus := 1; x := -x ELSE minus := 0 END;
    IF e >= 0 THEN (* x >= 1.0, 77/256 = log 2 *) x := x / Ten(e)
      ELSE (*x < 1.0*) x := Ten(-e) * x
    END;
    IF x >= 10.0 THEN x := 0.1 * x; INC(e) END;
    (* 1 <= x < 10 *)
    IF k + e >= maxD - 1 THEN k := maxD - 1 - e
    ELSIF k + e < 0 THEN (* k := -e; !FIXME Why??? *) x := 0.0
    END;
    x0 := Ten(k + e); x := x0 * x + 0.5;
    IF x >= 10.0 * x0 THEN INC(e) END;
    (* e = no. of digits before decimal point *)
    INC(e); i := k + e; ConvertL(x, i, d);
    IF e > 0 THEN
      IF k > 0 THEN p := 0 ELSE p := 1 END;
      Chars(' ', n - e - k - 1 - minus + p);
      IF minus # 0 THEN OutC('-') END;
      DigitsOut(e);
      IF k > 0 THEN OutC('.'); DigitsOut(k) END
    ELSE
      IF k + e > 0 THEN p := 0 ELSE p := 1 END;
      N := n - k - 2 - minus + p;
      IF (k > 0) & (k + e < 0) THEN DEC(N) END;
      Chars(' ', N);
      IF minus # 0 THEN OutC('-') END;
      OutC('0');
      IF k + e > 0 THEN OutC('.'); Chars('0', -e); DigitsOut(k + e)
      ELSIF k > 0 THEN OutC('.'); Chars('0', k)
      END
    END
  END;
  s[si] := 0X
END LongStrFix;

BEGIN Done := TRUE
END Reals.
