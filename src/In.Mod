MODULE In;
(** Module In provides a set of basic routines for formatted input of
    characters, character sequences, numbers, and names. It assumes a standard
    input stream with a current position that can be reset to the beginning of
    the stream (but may not always do so on Linux/Unix or Windows).

    Module In as in Oakwood Guidlines for  Oberon-2 Compiler Developers, 1995.
     With the following changes:
     LongInt, Int, Int16 read and parse minus signs first.
     Char reads a 2-byte character. On Linux it decodes input as UTF-8.
    On Windows it uses ReadConsoleW WinAPI call if console is attached,
    otherwise ReadFile is used and input is decoded from UTF-8.
     Open may not rewind.
     Extra procedures: Line, HugeInt, Int16.

%RU Модуль In предоставляет набор основных процедур для форматированного ввода
    литер, последовательностей литер, чисел и имён. Он предполагает наличие
    стандартного потока ввода с текущей позицией, которая может быть сброшена
    в начало потока (но не всегда это возможно в Linux/Unix или Windows).
    
    Модуль In как в Oakwood Guidlines for Oberon-2 Compiler Developers, 1995.
     Со следующими изменениями:         
     LongInt, Int, Int16 сначала читают и распознают знаки минус.         
     Char читает 2-байтовую литеру. В Linux он декодирует вводимые данные как
    UTF-8. В Windows используется вызов ReadConsoleW из WinAPI если консоль
    подключена, в противном случае используется ReadFile и ввод автоматически
    декодируется из UTF-8.
     Open не может перематывать.
     Дополнительные процедуры: Line, HugeInt, Int16. *)

IMPORT Platform, SYSTEM, Reals, Out, Utf8;

CONST
  pending = 0; (* readState when at start of input or end of line.
                  Implies nextch undefined. *)
  ready   = 1; (* readState when nextch is defined and contains
                  next character on current line. *)
  eof     = 2; (* readState when at end of file. *)

  (** Codepages, values of cp
%RU   Кодовые страницы, значения cp **)
  singleByte = 1;
  utf8       = 2; (*!TODO also add UTF16 *)

TYPE
  SBYTE = BYTE;
  BYTE* = UBYTE; (** 8-bit unsigned integer, 0..255
%RU                  8-битное беззнаковое целое, 0..255 *)

VAR
  (** TRUE after every Open, FALSE after the first error.
       Done indicates the success of an input operation. If Done is TRUE after
      an input operation, the operation was successful and its result is
      valid. An unsuccessful input operation sets Done to FALSE; it remains
      FALSE until the next call to Open. In particular, Done is set to FALSE
      if an attempt is made to read beyond the end of the input stream.
%RU   TRUE после каждого Open, FALSE после первой ошибки.
       Done выражает успешность операции ввода. Если Done равно TRUE после
      операции ввода, то операция была успешной и её результат считается
      действительным. Неудачная операция ввода устанавливает значение Done в
      FALSE; оно остается FALSE до следующего вызова Open. В частности, Done
      устанавливается в FALSE, если была предпринята попытка чтения за пределы
      конца входного потока. *)
  Done-: BOOLEAN;

  nextch: CHAR; (** Maintains 1 character read ahaead except at end of line *)
  readState: INTEGER;
  cp: INTEGER; (** Input Code Page *)

(** Initialization
%RU Инициализация **)

(** Open sets the current position to the beginning of the input stream.
    Done indicates if the operation was successful.
     Note that on Windows or Linux/Unix rewind may not be possible. Also on
    these OS Open is not strictly required before any other operation.
%RU Open устанавливает текущую позицию в начало входного потока.
    Done указывает, была ли операция успешной.
     Обратите внимание, что на Windows или Linux/Unix перемотка может быть
    невозможна. Кроме того, на этих ОС нет строгого требования вызывать Open
    перед любой другой операцией. *)
PROCEDURE Open*;
VAR error: Platform.ErrorCode;
BEGIN
  (* Rewind STDIN to beginning of file. *)
  error := Platform.Seek(Platform.StdIn, 0, Platform.SeekSet);
  cp := utf8;
  nextch := 0X;
  readState := pending;
  Done := error = 0
END Open;

(** Input operations
%RU Операции ввода **)

(** The following operations require Done = TRUE and guarantee (Done = TRUE
    and the result is valid) or (Done = FALSE). All operations except Char
    skip leading blanks, tabs or end-of-line characters. *)
PROCEDURE GetByte(): INTEGER;
VAR error: Platform.ErrorCode; x, n: INTEGER;
  m: ARRAY 1 OF SBYTE;
BEGIN
  error := Platform.ReadBuf(Platform.StdIn, m, n); x := m[0] MOD 256;
  IF (error = 0) & (n = 1) THEN readState := ready
  ELSE readState := eof; x := 0
  END;
  RETURN x
END GetByte;

PROCEDURE GetChar(VAR x: CHAR): BOOLEAN;
VAR error: Platform.ErrorCode; n: INTEGER; ok: BOOLEAN;
  m: ARRAY 1 OF CHAR;
BEGIN
  error := Platform.ReadBufW(Platform.StdIn, m, n); x := m[0];
  IF (error = 0) & (n = 1) THEN readState := ready; ok := TRUE
  ELSE readState := eof; x := 0X; ok := FALSE
  END ;
RETURN ok END GetChar;

(** Puts in `x` the byte at the current position *)
%RU  *)
PROCEDURE Byte*(VAR x: BYTE);
BEGIN x := SYSTEM.VAL(BYTE, SHORT(SHORT(GetByte())))
END Byte;

PROCEDURE ReadChar;
VAR x, y: INTEGER;
  c: CHAR;
BEGIN
  IF GetChar(c) THEN nextch := c
  ELSE x := GetByte();
    IF readState = ready THEN
      IF cp = utf8 THEN
        IF x >= 80H THEN y := GetByte() MOD 64; (* Not 1 byte *)
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
  END
END ReadChar;

PROCEDURE StartRead; (* Ensure either nextch is valid or we are at EOF. *)
BEGIN Out.Flush; IF readState = pending THEN ReadChar END
END StartRead;

PROCEDURE StartAndSkip; (* Like StartRead, but also skip over blanks, CR, LF, tab. *)
BEGIN StartRead;
  WHILE (readState = ready) & (nextch <= ' ') DO ReadChar END
END StartAndSkip;

(** Puts in `ch` the character at the current position. May read 1 to 4 bytes
    if decoding from UTF-8 (on Linux/Unix and on Windows if input
    is redirected).
%RU Помещает в `ch` литеру в текущей позиции. Может считывать от 1 до 4 байт
    при декодировании из UTF-8 (в Linux/Unix и в Windows, если ввод
    перенаправляется). *)
PROCEDURE Char*(VAR ch: CHAR);
BEGIN StartRead;
  IF readState = ready THEN ch := nextch;
    IF ch = 0AX THEN readState := pending ELSE ReadChar END
  ELSE Done := FALSE; ch := 0X
  END
END Char;

(** Returns 64-bit integer at the current position according to the format:
     IntConst = [-] (digit {digit} | digit {hexDigit} "H").
%RU Возвращает 64-битное целое число в текущей позиции согласно формату:
     IntConst = [-] (digit {digit} | digit {hexDigit} "H"). *)
PROCEDURE HugeInt*(VAR h: LONGINT);
VAR ok, neg, hex, endofnum: BOOLEAN;
  decacc, hexacc, digit: LONGINT;
BEGIN StartAndSkip;
  ok := FALSE;
  IF readState = ready THEN
    neg := nextch = '-'; IF neg THEN ReadChar END;
    hex := FALSE;
    endofnum := FALSE;
    decacc := 0;
    hexacc := 0;
    WHILE (readState = ready) & ~endofnum DO
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
  WHILE (readState = ready) & (nextch <= ' ') & (nextch # 0AX) DO ReadChar END;
  IF (readState = ready) & (nextch = 0AX) THEN readState := pending END;
  IF ~ok THEN Done := FALSE END
END HugeInt;

(** Returns 16-bit integer in the same way as HugeInt does
%RU Возвращает 16-битное целое число так же, как это делает HugeInt *)
PROCEDURE Int16*(VAR i: SHORTINT);
VAR h: LONGINT;
BEGIN HugeInt(h); i := SHORT(SHORT(h)) (*!FIXME check range, update Done*)
END Int16;

(** Returns 32-bit integer in the same way as HugeInt does
%RU Возвращает 32-битное целое число так же, как это делает HugeInt *)
PROCEDURE Int*(VAR i: INTEGER); (*32-bit INTEGER alias*)
VAR h: LONGINT;
BEGIN HugeInt(h); i := SHORT(h) (*!FIXME check range, update Done*)
END Int;

(** Alias for Int. Does the same thing
%RU Псевдоним для Int. Делает то же самое *)
PROCEDURE LongInt*(VAR i: INTEGER);
BEGIN Int(i)
END LongInt;

(** Reads a line of characters until CR, LF or end of file
%RU Считывает строку литер до первого CR, LF или конца файла *)
PROCEDURE Line*(VAR line: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartRead; i := 0;
  IF readState # ready THEN Done := FALSE END;
  WHILE (readState = ready) & (nextch # 0DX) & (nextch # 0AX) DO
    IF i < LEN(line) - 1 THEN line[i] := nextch; INC(i) ELSE Done := FALSE END;
    ReadChar
  END;
  line[i] := 0X;
  IF (readState = ready) & (nextch = 0DX) THEN ReadChar END;
  IF (readState = ready) & (nextch = 0AX) THEN readState := pending END
END Line;

(** Reads a word and put it in `s`.
     Skips whitespaces, reads characters until the next whitespace
    and puts the read word in `s`, then skips whitespaces until the next
    non-whitespace or a new line character. Skips the new line character
%RU Читает слово и помещает его в `s`.
     Пропускает пробельные литеры, считывает литеры до следующей пробельной
    литеры и помещает прочитанное слово в `s`, затем пропускает литеры до
    следующей непробельной литеры или литеры новой строки.
    Пропускает символ новой строки *)
PROCEDURE Word*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN StartRead; i := 0;
  IF readState # ready THEN Done := FALSE END;
  WHILE (readState = ready) & (nextch > ' ') DO
    IF i < LEN(s) - 1 THEN s[i] := nextch; INC(i) ELSE Done := FALSE END;
    ReadChar
  END;
  s[i] := 0X;
  WHILE (readState = ready) & (nextch <= ' ') & (nextch # 0AX) DO ReadChar END;
  IF (readState = ready) & (nextch = 0AX) THEN readState := pending END
END Word;

(** Reads a string literal and puts it in `s`.
     A string literal is a quoted sequence of characters that may include
    spaces but not other whitespaces (tabs, new lines etc.). The quotes can
    be single or double quotes. The string must begin and end with the same
    quotation marks.
%RU Считывает строковый литерал и помещает его в `s`.
     Строковый литерал -- это заключенная в кавычки последовательность литер,
    которая может включать в себя пробелы, но не другие пробельные литеры
    (табуляции, новые строки и т. п.). Кавычки могут быть одинарные или
    двойные. Строка должна начинаться и заканчиваться одинаковыми кавычками. *)
PROCEDURE String*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
  q: CHAR; (* ' or " *)
BEGIN StartAndSkip; i := 0;
  IF (readState = ready) & ((nextch = '"') OR (nextch = "'")) THEN
    q := nextch; ReadChar;
    WHILE (readState = ready) & (nextch >= ' ') & (nextch # q) DO
      IF i < LEN(s) - 1 THEN s[i] := nextch; INC(i) ELSE Done := FALSE END;
      ReadChar
    END;
    IF (readState = ready) & (nextch = q) THEN ReadChar
    ELSE Done := FALSE
    END
  END;
  s[i] := 0X
END String;

(** Reads the name `s` at the current position according to the file name
    format of the operating system (e.g. "lib/My.Mod" under Unix).
    Skips the 0AX in the end (if any).
%RU Считывает имя `s` в текущей позиции в соответствии с форматом имени файла
    операционной системы (например, "lib/My.Mod" под Unix).
    Пропускает 0AX в конце (если есть). *)
PROCEDURE Name*(VAR s: ARRAY OF CHAR);
VAR c: CHAR;
  i: INTEGER;
BEGIN i := 0; Char(c);
  WHILE c > ' ' DO
    IF i < LEN(s) - 1 THEN s[i] := c; INC(i) ELSE Done := FALSE END;
    Char(c)
  END;
  s[i] := 0X;
  IF c = 0AX THEN Char(c) END
END Name;

(** Reads and puts in `x` a 32-bit real number (REAL) in format:
      ["-"] digit {digit} [{digit} ["E" ("+" | "-") digit {digit}]].
%RU Считывает и помещает в `x` 32-битное вещественное число (REAL)
    согласно формату:
      ["-"] digit {digit} [{digit} ["E" ("+" | "-") digit {digit}]]. *)
PROCEDURE Real*(VAR x: SHORTREAL);
VAR s: ARRAY 16 OF CHAR;
BEGIN StartAndSkip; Word(s);
  x := Reals.Val(s);
  IF ~Reals.Done THEN Done := FALSE END
END Real;

(** Reads and puts in `x` a 64-bit real number (LONGREAL) in format:
      ["-"] digit {digit} [{digit} ["E" ("+" | "-") digit {digit}]].
%RU Считывает и помещает в `x` 64-битное вещественное число (LONGREAL)
    согласно формату:
      ["-"] digit {digit} [{digit} ["E" ("+" | "-") digit {digit}]]. *)
%RU  *)
PROCEDURE LongReal*(VAR x: REAL);
VAR s: ARRAY 16 OF CHAR;
BEGIN StartAndSkip; Word(s);
  x := Reals.LongVal(s);
  IF ~Reals.Done THEN Done := FALSE END
END LongReal;

BEGIN
  cp := utf8;
  nextch := 0X;
  readState := pending;
  Done := TRUE
END In.
