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
  - начинающиеся на той же строке, на которой заканчивается объект
  - перед объектами (с одной звёздочкой на конце)
  - перед группами объектов (с двумя звёздочками на конце), "заголовки"
*)


(** Module Apples helps count apples.
    One can create a variable of type Apples.Apple,
    call Init and other procedures on it. *)
MODULE Apples;
(** Это тестовый модуль. *)
IMPORT Out, Fruits;

CONST
  (** Общие постоянные **)
  maxApples*  =  5; (** Maximum amount of apples. Currently unused *)
  maxSeeds*   = 10; (** Currently not in use *)
  startApples =  0; (** Start amount of apples. Used in Reset *)

  (** Качество яблока **)
  unknown* = 0; (** Неизвестное качество *)
  good*    = 1; (** Сносное качество *)
  bad*     = 2; (** Отвратное качество *)

TYPE
  (** Тип яблоко *)
  Apple* = RECORD(Fruits.Fruit) (** Represents an apple with some seeds *)
    seeds*: INTEGER;   (** Amount of seeds in the apple *)
    quality*: INTEGER; (** Качество продукта, см. @Качество яблока *)
    added: BOOLEAN     (** Whether Add was called on this seed after Init *)
  END;

VAR
  applesCreated*: INTEGER; (** How many apples were created using Init *)
  (** If FALSE, Show shows a welcome message and sets shown to TRUE *)
  shown: BOOLEAN;
  lastAdded*: INTEGER; (** How many seeds were added the last time, or -1 *)

(** Sets the given amount of seeds to apple a. *)
PROCEDURE Set(VAR a: Apple; seeds: INTEGER);
BEGIN
  a.seeds := seeds;
  IF seeds >= 3 THEN a.quality := good
  ELSIF seeds = 0 THEN a.quality := bad
  ELSE a.quality := unknown
  END
END Set;

PROCEDURE Init*(VAR a: Apple; seeds: INTEGER);
(** Initializes apple a with the specified amount of seeds. *)
BEGIN
  INC(applesCreated);
  Set(a, seeds);
  a.added := FALSE
END Init;

(** Apple manipulation **)

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

(** - **)

(** Resets internal apple counter. *)
PROCEDURE Reset*;
BEGIN
  lastAdded := -1;
  applesCreated := startApples;
  shown := FALSE
END Reset;

PROCEDURE Shown*(): BOOLEAN; RETURN shown END Shown; (** Было ли приветствие *)

BEGIN
  Reset
END Apples.
