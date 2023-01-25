MODULE Args;
(** Access to command line arguments
%RU Доступ к аргументам командной строки *)
IMPORT CmdArgs, Int, Utf8;

TYPE SHORTCHAR = Utf8.SHORTCHAR;
VAR count: INTEGER;

(** Return the number of command line arguments.
     If Count() returns N, then you can call Get(x) with 0 <= x <= N.
%RU Возвращает количество аргументов командной строки.
     Если Count() возвращает N, то можно вызвать Get(x), где 0 <= x <= N. *)
PROCEDURE Count*(): INTEGER;
BEGIN
  IF count = -1 THEN count := CmdArgs.Count END
RETURN count END Count;

(** Given the number `n` returns the nth argument as string `s`.
     `n` must be in range 0 <= n <= Count().
     Argument 0 is the name of the program as it was executed
    from the console.
     The proper arguments start with index 1
%RU При заданном числе `n` возвращает n-й аргумент в виде строки `s`.
     `n` должно находиться в диапазоне 0 <= n <= Count().
     Аргумент 0 -- это имя программы в том виде, в котором она была запущена
    из консоли.
     Собственно аргументы начинаются с индекса 1 *)
PROCEDURE Get*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR q: ARRAY 4096 OF SHORTCHAR;
BEGIN
  CmdArgs.Get(n, q);
  Utf8.Decode(q, s)
END Get;

(** Given the number `n` returns the nth argument as integer `i`.
     If the argument is not a valid integer, returns 0
%RU При заданном числе `n` возвращает n-й аргумент в виде целого числа `i`.
     Если аргумент не является корректной записью целого числа, возвращает 0 *)
PROCEDURE GetInt*(n: INTEGER): INTEGER;
VAR s: ARRAY 30 OF CHAR;
  i: INTEGER;
  ok: BOOLEAN;
BEGIN
  Get(n, s);
  i := Int.ValEx(s, ok);
  IF ~ok THEN i := 0 END
RETURN i END GetInt;

BEGIN count := -1
END Args.
