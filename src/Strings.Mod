MODULE Strings;
(** This module provides a set of operations on strings (character arrays),
    that must contain 0X as a terminator.
     All positions in strings start at 0.
%RU Этот модуль предоставляет набор операций над строками (массивами литер),
    которые должны содержать нуль-терминатор (литеру 0X).
     Все позиции в строках начинаются с 0. *)
IMPORT Reals, SYSTEM, Out;

TYPE
  REAL = SYSTEM.REAL32;
  LONGREAL = SYSTEM.REAL64;

(** Returns the number of characters in `s` up to and excluding the first 0X
%RU Возвращает количество литер в `s` до первого 0X не включительно *)
PROCEDURE Length*(IN s: ARRAY OF CHAR): INTEGER;
VAR i: INTEGER;
BEGIN i := 0; WHILE (i < LEN(s)) & (s[i] # 0X) DO INC(i) END ;
RETURN i END Length;

(** Appends string `s` to the end of string `dst`.
     Has the same effect as Insert(s, Length(s), dst)
%RU Дописывает строку `s` в конец строки `dst`.
     Имеет тот же эффект, что и Insert(s, Length(s), dst) *)
PROCEDURE Append*(IN s: ARRAY OF CHAR; VAR dst: ARRAY OF CHAR);
VAR n1, n2, i: INTEGER;
BEGIN
  n1 := Length(dst); n2 := Length(s); i := 0;
  WHILE (i < n2) & (i + n1 < LEN(dst)) DO dst[i + n1] := s[i]; INC(i) END;
  IF i + n1 < LEN(dst) THEN dst[i + n1] := 0X
  ELSE dst[LEN(dst) - 1] := 0X
  END
END Append;

(** Inserts the string `src` into the string `dst` at position `pos`
    (0 <= pos <= Length(dst))
     If pos >= Length(dst), src is appended to dst.
     If the size of dst is not large enough to hold the result of the
    operation, the result is truncated so that dst is always terminated
    with a 0X.
%RU Вставляет строку `src` в строку `dst` в позиции `pos`.
    (0 <= pos <= Length(dst)).
     Если pos >= Length(dst), src дописывается к dst.
     Если размер dst недостаточно велик, чтобы вместить результат операции,
    результат усекается так, чтобы dst всегда завершался литерой 0X. *)
PROCEDURE Insert*(IN src: ARRAY OF CHAR; pos: INTEGER; VAR dst: ARRAY OF CHAR);
VAR n1, n2, len, i, j: INTEGER;
BEGIN
  n1 := Length(dst); n2 := Length(src); len := LEN(dst);
  IF pos < 0 THEN pos := 0 END;
  IF pos > n1 THEN Append(src, dst); RETURN END;
  (*--- make room for src*)
  IF pos + n2 < len THEN
    i := n1; j := i + n2; (*move also 0X if it is there*)
    WHILE i >= pos DO
      IF j < len THEN dst[j] := dst[i] END;
      DEC(i); DEC(j)
    END
  END;
  (*--- copy src to dst*)
  i := 0; j := pos;
  WHILE (i < n2) & (j < len) DO
    dst[j] := src[i];
    INC(i); INC(j)
  END;
  IF j >= len THEN dst[len - 1] := 0X END
END Insert;

(** Deletes `n` characters from `s` starting at position `pos`
    (0 <= pos < Length(s)).
     If n > Length(s) - pos, the new length of s is pos.
%RU Удаляет `n` символов из `s`, начиная с позиции `pos`.
    (0 <= pos < Length(s)).
     Если n > Length(s) - pos, то новая длина s равна pos. *)
PROCEDURE Delete*(VAR s: ARRAY OF CHAR; pos, n: INTEGER);
VAR len, i: INTEGER;
BEGIN
  len := Length(s);
  IF pos < 0 THEN pos := 0 ELSIF pos >= len THEN RETURN END;
  IF pos + n < len THEN
    i := pos + n; WHILE i < len DO s[i - n] := s[i]; INC(i) END;
    IF i - n < LEN(s) THEN s[i - n] := 0X END
  ELSE s[pos] := 0X
  END
END Delete;

(** Has the same effect as Delete(dst, pos, Length(src)) followed by an
    Insert(src, pos, dst)
%RU Имеет тот же эффект, что и Delete(dst, pos, Length(src)), за которым
    следует команда Insert(src, pos, dst) *)
PROCEDURE Replace*(IN src: ARRAY OF CHAR;
    pos: INTEGER; VAR dst: ARRAY OF CHAR);
BEGIN
  Delete(dst, pos, pos + Length(src));
  Insert(src, pos, dst)
END Replace;

(** Extracts a substring `dst` with `n` characters from position `pos` in `src`
    (0 <= pos < Length(src)).
     If n > Length(src) - pos, dst is only the part of src from pos to
    Length(src) - 1.
     If the size of dst is not large enough to hold the result of the
    operation, the result is truncated so that dst is always terminated
    with a 0X.
%RU Извлекает подстроку `dst` длиной `n` литер из позиции `pos` в `src`
    (0 <= pos < Length(src)).
     Если n > Length(src) - pos, то в dst помещается только часть src от pos
    до Length(src) - 1.
     Если длина dst недостаточна, чтобы вместить результат операции, он
    усекается так, чтобы dst всегда завершался литерой 0X. *)
PROCEDURE Extract*(IN src: ARRAY OF CHAR; pos, n: INTEGER;
    VAR dst: ARRAY OF CHAR);
VAR len, dstLen, i: INTEGER;
BEGIN len := Length(src);
  IF pos < 0 THEN pos := 0 ELSIF pos >= len THEN dst[0] := 0X
  ELSE i := 0; dstLen := LEN(dst) - 1;
    IF n >= dstLen THEN n := dstLen - 1 END;
    WHILE (pos + i <= len) & (src[pos + i] # 0X) & (i < n) DO
      IF i < dstLen THEN dst[i] := src[pos + i] END;
      INC(i)
    END;
    dst[i] := 0X
  END
END Extract;

(** Copies `src` to `dst`.
     If the size of dst is not large enough to hold the copy, the result is
    truncated so that dst is always terminated with a 0X.
     Has the same effect as Extract(src, 0, LEN(dst), dst)
%RU Копирует `src` в `dst`.
     Если длина dst недостаточна, чтобы вместить копию, он усекается так,
    чтобы dst всегда завершался литерой 0X.
     Имеет тот же эффект, что и Extract(src, 0, LEN(dst), dst) *)
PROCEDURE Copy*(IN src: ARRAY OF CHAR; VAR dst: ARRAY OF CHAR);
VAR i, len: INTEGER;
BEGIN
  IF LEN(src) < LEN(dst) THEN len := LEN(src) - 1 ELSE len := LEN(dst) - 1 END;
  i := 0;
  WHILE (i # len) & (src[i] # 0X) DO dst[i] := src[i]; INC(i) END;
  dst[i] := 0X
END Copy;

(** Returns the position of the first occurrence of `pat` in `s` after
    position `pos` (inclusive).
     If pat is not found, returns -1.
%RU Возвращает позицию первого вхождения `pat` в `s` после позиции `pos`
    (включительно).
     Если pat не найден, возвращает -1. *)
PROCEDURE Pos*(IN pattern, s: ARRAY OF CHAR; pos: INTEGER): INTEGER;
VAR n1, n2, i, j: INTEGER;
BEGIN
  n1 := Length(s); n2 := Length(pattern);
  IF n2 = 0 THEN RETURN 0 END;
  i := pos;
  WHILE i <= n1 - n2 DO
    IF s[i] = pattern[0] THEN
      j := 1; WHILE (j < n2) & (s[i + j] = pattern[j]) DO INC(j) END;
      IF j = n2 THEN RETURN i END
    END;
    INC(i)
  END;
  RETURN -1
END Pos;

(** Replaces each lower case latin letter
    in `s` by its upper case equivalent.
%RU Заменяет каждую строчную латинскую букву в `s` на
    её эквивалент в верхнем регистре. *)
PROCEDURE Cap*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE s[i] # 0X DO
    IF ('a' <= s[i]) & (s[i] <= 'z') THEN s[i] := CAP(s[i]) END;
    INC(i)
  END
END Cap;

(** Performs a pattern match on a given string. Returns TRUE on match.
     Parameter pattern may include wildcard characters '*'.
%RU Выполняет поиск совпадения шаблона для заданной строки. Возвращает TRUE
    при совпадении.
     Параметр шаблона может включать литеры подстановки '*'. *)
PROCEDURE Match*(IN string, pattern: ARRAY OF CHAR): BOOLEAN;

  PROCEDURE M (IN name, mask: ARRAY OF CHAR; n, m: INTEGER): BOOLEAN;
  BEGIN
    WHILE (n >= 0) & (m >= 0) & (mask[m] # '*') DO
      IF name[n] # mask[m] THEN RETURN FALSE END;
      DEC(n); DEC(m)
    END;
    (* ----- name empty | mask empty | mask ends with '*' *)
    IF m < 0 THEN RETURN n < 0 END;
    (* ----- name empty | mask ends with '*' *)
    WHILE (m >= 0) & (mask[m] = '*') DO DEC(m) END;
    IF m < 0 THEN RETURN TRUE END;
    (* ----- name empty | mask still to be matched *)
    WHILE n >= 0 DO
      IF M(name, mask, n, m) THEN RETURN TRUE END;
      DEC(n)
    END;
    RETURN FALSE
  END M;

BEGIN
  RETURN M(string, pattern, Length(string) - 1, Length(pattern) - 1)
END Match;

END Strings.
