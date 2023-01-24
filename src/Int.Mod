MODULE Int;
(** Module for conversion of integers to and from a string
%RU Модуль для преобразования целых чисел в строку и из строки *)
IMPORT Strings;

(** Converts integer `n` to string `s`
%RU Преобразует целое число `n` в строку `s` *)
PROCEDURE Str*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR i, j: INTEGER; tmp: CHAR; neg: BOOLEAN;
BEGIN
  IF n = 0 THEN s := '0'
  ELSIF n = MIN(LONGINT) THEN s := '-2147483648'
  ELSE i := 0;
    IF n < 0 THEN neg := TRUE; n := -n ELSE neg := FALSE END;
    WHILE (n # 0) & (i # LEN(s) - 1) DO
      s[i] := CHR(ORD('0') + n MOD 10);
      n := n DIV 10; INC(i)
    END;
    IF neg & (i # LEN(s) - 1) THEN s[i] := '-'; INC(i) END;
    s[i] := 0X; j := 0; DEC(i);
    WHILE j < i DO
      tmp := s[j]; s[j] := s[i]; s[i] := tmp;
      INC(j); DEC(i)
    END
  END
END Str;

(** Returns the contents of string `s` converted to an integer. Sets `ok` to
    TRUE if `s` contains a valid representation of an integer number,
    otherwise sets `ok` to FALSE and returns 0
%RU Возвращает содержимое строки `s` в виде целого числа. Устанавливает `ok` в
    TRUE, если `s` содержит правильное представление целого числа, в противном
    случае устанавливает `ok` в FALSE и возвращает 0 *)
PROCEDURE ValEx*(IN s: ARRAY OF CHAR; VAR ok: BOOLEAN): INTEGER;
VAR i, n: INTEGER;
  c: CHAR;
  neg: BOOLEAN;
BEGIN n := 0; c := s[0]; ok := FALSE;
  IF c = '-' THEN neg := TRUE; i := 1; c := s[1] ELSE neg := FALSE; i := 0 END;
  WHILE ('0' <= c) & (c <= '9') DO ok := TRUE;
    n := n * 10 + ORD(c) - ORD('0');
    INC(i); c := s[i]
  END;
  IF s[i] # 0X THEN ok := FALSE; n := 0 ELSIF neg THEN n := -n END ;
RETURN n END ValEx;

(** Returns the contents of string `s` converted to an integer. If `s`
    does not contain a valid representation of an integer number, returns 0
%RU Возвращает содержимое строки `s`, преобразованное в целое число. Если `s`
    не содержит правильного представления целого числа, возвращается 0 *)
PROCEDURE Val*(IN s: ARRAY OF CHAR): INTEGER;
VAR ok: BOOLEAN;
BEGIN RETURN ValEx(s, ok) END Val;

(** Inserts a textual representation of integer `n` in position `pos` of
    string `s`
%RU Вставляет текстовое представление целого числа `n` в позицию `pos`
    строки `s` *)
PROCEDURE Insert*(n: INTEGER; pos: INTEGER; VAR s: ARRAY OF CHAR);
VAR sn: ARRAY 30 OF CHAR;
BEGIN Str(n, sn); Strings.Insert(sn, pos, s)
END Insert;

(** Appends a textual representation of integer `n` to the end of string `s`
%RU Добавляет текстовое представление целого числа `n` в конец строки `s` *)
PROCEDURE Append*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR sn: ARRAY 30 OF CHAR;
BEGIN Str(n, sn); Strings.Append(sn, s)
END Append;

END Int.
