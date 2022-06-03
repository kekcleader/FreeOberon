(*
Файл -> модуль
  (название)

Объекты:
  - константы
  - типы
  - переменные
  - процедуры

(только эспортированное)

Комментарии вида (**...*):
  - перед объектами
  - перед группами объектов
*)


(**
Module Apples helps in counting apples.
One can create a variable of type Apples.Apple,
call Init and other procedures on it.
*)
MODULE Apples;
IMPORT Out;

CONST
  maxApples* = 5;  (** Maximum amount of apples. Currently unused *)
  startApples = 0; (** Start amount of apples. Used in Reset *)

TYPE
  Apple* = RECORD    (** Represents an apple with maybe some seeds *)
    seeds*: INTEGER; (** Amount of seeds in the apple *)
    added: BOOLEAN   (** Whether Add was called on this seed after Init *)
  END;

VAR
  applesCreated*: INTEGER; (** How many apples were created using Init *)
  (** If FALSE, Show shows a welcome message and sets shown to TRUE *)
  shown: BOOLEAN;
  lastAdded*: INTEGER; (** How many seeds were added the last time *)

(** Sets the given amount of seeds to apple a. *)
PROCEDURE Set(VAR a: Apple; seeds: INTEGER);
BEGIN
  a.seeds := seeds
END Set;

PROCEDURE Init*(VAR a: Apple; seeds: INTEGER);
(** Initializes apple a with the specified amount of seeds. *)
BEGIN
  INC(applesCreated);
  Set(a, seeds);
  a.added := FALSE
END Init;

(** Adds n seeds to apple a. *)
PROCEDURE Add*(VAR a: Apple; n: INTEGER);
BEGIN
  lastAdded := n;
  Set(a, a.seeds + n);
  a.added := TRUE
END Add;

PROCEDURE Show*(a: Apple);
(** Dispalys a message about the apple. *)
BEGIN
  IF ~shown THEN
    Out.String('Welcome to Apples!');
    Out.Ln;
    shown := TRUE
  END;
  IF a.added THEN
    Out.String('Added apple with ')
  ELSE
    Out.String('Apple with ')
  END;
  Out.Int(a.seeds, 0);
  Out.String(' seeds.');
  Out.Ln
END Show;

(** Resets internal apple counter. *)
PROCEDURE Reset*;
BEGIN
  lastAdded := -1;
  applesCreated := startApples;
  shown := FALSE
END Reset;

BEGIN
  Reset
END Apples.