MODULE Out;
(** Module Out provides a set of basic routines for formatted output of
    characters, numbers and strings. It assumes a standard output stream to
    which the symbols are written.
     The output is buffered. The buffer is flushed when and overflow occurres
    or when Flush or Ln are called.
%RU Модуль Out предоставляет набор базовых процедур для форматированного
    вывода литер, чисел и строк. Он предполагает наличие стандартного
    потока вывода, в который записываются литеры.
     Вывод осуществляется в буфер. Буфер очищается, когда происходит его
    переполнение, а также при вызове процедур Flush или Ln. *)

IMPORT SYSTEM, Platform, U := Utf8, Reals;

TYPE
  SHORTINT = SYSTEM.INT16; INTEGER = SYSTEM.INT32; HUGEINT = SYSTEM.INT64;
  REAL = SYSTEM.REAL32; LONGREAL = SYSTEM.REAL64; CHAR = SYSTEM.CHAR16;

VAR
  buf: ARRAY 128 OF CHAR;
  in: INTEGER;

(** Flushes the output buffer to the output device
%RU Сбрасывает буфер вывода на устройство вывода *)
PROCEDURE Flush*;
VAR error: Platform.ErrorCode;
BEGIN
  IF in > 0 THEN error := Platform.WriteW(buf, in) END;
  in := 0
END Flush;

(** Initializes the output stream.
     On Windows, Unix and Linux does nothing.
%RU Инициализирует выходной поток. 
     В Windows, Unix и Linux ничего не делает. *)
PROCEDURE Open*;
BEGIN
END Open;

(** Writes the character `ch` to the end of the output stream
%RU Записывает литеру `ch` в конец выходного потока *)
PROCEDURE Char*(ch: CHAR);
BEGIN
  IF in >= LEN(buf) THEN Flush END;
  buf[in] := ch; INC(in);
  IF ch = 0AX THEN Flush END
END Char;

PROCEDURE Length(IN s: ARRAY OF CHAR): INTEGER;
VAR n: INTEGER;
BEGIN n := 0; WHILE (n < LEN(s)) & (s[n] # 0X) DO INC(n) END; RETURN n
END Length;

(** Writes the null-terminated character sequence `s` to the end of the
    output stream (without 0X).
%RU Записывает нуль-терминированную последовательность литер `s` в конец
    выходного потока (без 0X). *)
PROCEDURE String*(IN s: ARRAY OF CHAR);
VAR l: INTEGER; error: Platform.ErrorCode;
BEGIN
  l := Length(s);
  IF in + l > LEN(buf) THEN Flush END;
  IF l >= LEN(buf) THEN
    (* Doesn't fit buf or no sence. Bypass buffering. *)
    error := Platform.WriteW(s, l)
  ELSE
    SYSTEM.MOVE(SYSTEM.ADR(s), SYSTEM.ADR(buf[in]), l * 2); INC(in, l)
  END
END String;

(** Writes the null-terminated 1-byte-character sequence `s` encoded in UTF-8
    to the end of the output stream (without 0X).
%RU Записывает нуль-терминированную последовательность 1-байтовых литер `s`,
    закодированную в UTF-8 в конец выходного потока (без 0X). *)
PROCEDURE Utf8*(IN s: ARRAY OF SHORTCHAR);
VAR q: ARRAY 4096 OF CHAR;
  p: POINTER TO ARRAY OF CHAR;
  i: INTEGER;
BEGIN
  IF LEN(s) <= LEN(q) THEN U.Decode(s, q); String(q)
  ELSE i := 0; WHILE s[i] # 0X DO INC(i) END;
    IF i < LEN(q) THEN U.Decode(s, q); String(q)
    ELSE NEW(p, i + 1); U.Decode(s, p^); String(p^)
    END
  END
END Utf8;

(** Writes the integer number `x` to the end of the output stream.
     `n` is the minimum amount of characters that should be written. If the
    textual representation of `x` takes less characters, then spaces
    are written first. If `n` is 0 or 1, `n` means nothing.
%RU Записывает целое число `x` в конец выходного потока.
     `n` -- это минимальное количество литер, которое должно быть записано.
    Если текстовое представление `x` занимает меньше литер, то сначала
    записываются пробелы. Если `n` равно 0 или 1, то `n` ничего не означает. *)
PROCEDURE Int*(x, n: HUGEINT);
  CONST zero = ORD('0');
  VAR s: ARRAY 22 OF CHAR; i: INTEGER; negative: BOOLEAN;
BEGIN
  negative := x < 0;
  IF x = MIN(HUGEINT) THEN
    s := '8085774586302733229'; i := 19
  ELSE
    IF x < 0 THEN x := - x END;
    s[0] := SHORT(CHR(zero + (x MOD 10))); x := x DIV 10;
    i := 1; WHILE x # 0 DO
      s[i] := SHORT(CHR(zero + (x MOD 10)));
      x := x DIV 10;
      INC(i)
    END
  END;
  IF negative THEN s[i] := '-'; INC(i) END;
  WHILE n > i DO Char(' '); DEC(n) END;
  WHILE i > 0 DO DEC(i); Char(s[i]) END
END Int;

(** Writes `x` as hexadecimal integer to the end of the output stream.
     `n` is the minimum amount of characters that should be written. If the
    textual representation of `x` takes less characters, then zeroes
    are written first. If `n` is 0 or 1, `n` means nothing.
%RU Записывает `x` как шестнадцатеричное целое число в конец выходного потока.
     `n` -- это минимальное количество литер, которое должно быть записано.
    Если текстовое представление `x` занимает меньше литер, то сначала
    записываются нули. Если `n` равно 0 или 1, то `n` ничего не означает. *)
PROCEDURE Hex*(x, n: HUGEINT);
BEGIN
  IF n < 1 THEN n := 1 ELSIF n > 16 THEN n := 16 END;
  IF x >= 0 THEN
    WHILE (n < 16) & (SYSTEM.LSH(x, -4 * n) # 0) DO INC(n) END
  END;
  x := SYSTEM.ROT(x, 4 * (16 - n));
  WHILE n > 0 DO
    x := SYSTEM.ROT(x, 4); DEC(n);
    IF x MOD 16 < 10 THEN Char(SHORT(CHR((x MOD 16) + ORD('0'))))
    ELSE Char(SHORT(CHR((x MOD 16) - 10 + ORD('A'))))
    END
  END
END Hex;

(** Writes an end-of-line symbol to the end of the output stream.
     On Linux/Unix it is 0AX. On Windows it is a pair: 0DX, 0AX.
%RU Записывает литеру конца строки в конец выходного потока.
     В Linux/Unix это 0AX. В Windows это пара: 0DX, 0AX. *)
PROCEDURE Ln*;
BEGIN String(Platform.NewLine); Flush
END Ln;

(** Writes the real number `x` to the end of the output stream in an
    exponential form.
     `n` is the minimum amount of characters that should be written. If the
    textual representation of `x` takes less characters, then spaces
    are written first.
%RU Записывает вещественное число `x` в конец выходного потока в
    экспоненциальном виде.
     `n` -- это минимальное количество литер, которое должно быть записано.
    Если текстовое представление `x` занимает меньше литер, то сначала
    записываются пробелы. *)
PROCEDURE Real*(x: REAL; n: INTEGER);
VAR s: ARRAY 256 OF CHAR;
BEGIN Reals.Str(x, n, s); String(s)
END Real;

(** Writes the long real number `x` to the end of the output stream in an
    exponential form.
     `n` is the minimum amount of characters that should be written. If the
    textual representation of `x` takes less characters, then spaces
    are written first.
%RU Записывает длинное вещественное число `x` в конец выходного потока в
    экспоненциальном виде.
     `n` -- это минимальное количество литер, которое должно быть записано.
    Если текстовое представление `x` занимает меньше литер, то сначала
    записываются пробелы. *)
PROCEDURE LongReal*(x: LONGREAL; n: INTEGER);
VAR s: ARRAY 256 OF CHAR;
BEGIN Reals.LongStr(x, n, s); String(s)
END LongReal;

(** Writes the real number `x` to the end of the output stream in a normal
    form.
     `n` is the minimum amount of characters that should be written. If the
    textual representation of `x` takes less characters, then spaces
    are written first.
     `k` is the number of digits after a decimal point.
%RU Записывает вещественное число `x` в конец выходного потока в обычном
    виде.
     `n` -- это минимальное количество литер, которое должно быть записано.
    Если текстовое представление `x` занимает меньше литер, то сначала
    записываются пробелы.
     `k` -- количество цифр после запятой (которая выводится как точка). *)
PROCEDURE RealFix*(x: REAL; n, k: INTEGER);
VAR s: ARRAY 256 OF CHAR;
BEGIN Reals.StrFix(x, n, k, s); String(s)
END RealFix;

(** Writes the long real number `x` to the end of the output stream in a
    normal form.
     `n` is the minimum amount of characters that should be written. If the
    textual representation of `x` takes less characters, then spaces
    are written first.
     `k` is the number of digits after a decimal point.
%RU Записывает длинное вещественное число `x` в конец выходного потока в
    обычном виде.
     `n` -- это минимальное количество литер, которое должно быть записано.
    Если текстовое представление `x` занимает меньше литер, то сначала
    записываются пробелы.
     `k` -- количество цифр после запятой (которая выводится как точка). *)
PROCEDURE LongRealFix*(x: LONGREAL; n, k: INTEGER);
VAR s: ARRAY 256 OF CHAR;
BEGIN Reals.LongStrFix(x, n, k, s); String(s)
END LongRealFix;

BEGIN
  in := 0
END Out.
