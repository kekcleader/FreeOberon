MODULE A;
(** A module
     Recursive procedure to read (potentially nested) comments.
     toplevel is TRUE only for the top-level comments, only the top-level
    comments that are opened with two stars are being saved in doc.

    i and j are placed like so:
        [HELLO WORLD0]    <-- 0 is a 0X
         ^i         ^j
    Then i and j are moved right and left respectively.
     Ещё немного
    такого же:
      А Б В Г Д Е Ё
        ^   ^   ^
      ^   ^   ^   ^
         птички

  *)
IMPORT Out;

CONST
  (** Формы **)
  (** Различные формы, выраженные в числах *)
  (** Числа от 0 до 2 *)
  (** Треугольник *)
  triangle* = 0;
  box*      = 35 + 27; (** Квадрат *)
  (** Круг *)
  circle*   = 2;
  conus*    = 3; (** Конус *)

  (** Ещё **)
  (** Что-то **)
  (** Общие **)
  (** Здесь находятся буквы *)

  (** буква а *)
  a* = 'а';

  (** буква б *)
  b* = 'б'; (** также Б *)

  c* = 'ц'; (** буква Ц *)

  d* = 'Д'; (** буква Д *)

(** Управление **)
(** Процедура П *)
PROCEDURE P*;
BEGIN END P;
(** Функция Ф *)
(** ЫЫЫ *)
(** ЖЖЖ *)
PROCEDURE F*(): INTEGER;
RETURN 5 END F;

PROCEDURE Q*(a: INTEGER; b: PROCEDURE(x, y: INTEGER): REAL; c: CHAR);
(** Процедура принимает число, процедуру и литеру. А ищщё *)
(** А тут ещё коментарий *)
(** И ЕЩЁ ОДИН *)
BEGIN
END Q;

END A.
