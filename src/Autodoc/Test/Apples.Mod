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
    call Init and other procedures on it *)
MODULE Apples;
(** Это тестовый модуль. *)
IMPORT Out, Fruits;

CONST
  str4* = "В двойных кавычках.";
  str5* = "Кавычки 'в' кавычках.";
  str1* =  '';
  appleJuice='сок';
  appleLen=15;
  appleLen2=15  ;
  str2* = 'H';
  str3* = 'Привет   Как  дела?';
  str6* = 'Кавычки "в двойных" кавычках.';

  (** Общие постоянные **)

  (** Start amount of apples. Used in Reset *)
  startApples =  0;

  maxApples*  =  5; (** Maximum amount of apples*)
  maxSeeds*   = 3; (** Currently not in use *)

  (** Качество яблока **)
  good*    = 1; (** Сносное качество *)
  unknown* = 0; (** Неизвестное качество *)
  bad*     = 2; (** Отвратное качество *)
  
  (** Литерные коды **)
  (** Компьютер *)
  computer*  = 'c';
  (**Человек*)
  human*     = 'H';
  (**    Игрок    *)
  player*    = 'i'; (** во что-то *)
  rusLetter* = 'а'; (** Буква русская, а, маленькая! *)
  engLetter* = 'a';
  (** Игра       просто игра *)
  game*      = 'I';
  tableRow1* = '1';
  tableRow2* = '2';

TYPE

  LetterA = CHAR;
  LetterB = CHAR;

  (** ФРУКТЫ **)

  (**Тип яблоко *)
  Apple* = RECORD(Fruits.Fruit) (** Represents an apple with some seeds *)
    seeds*: INTEGER;   (** Amount of seeds in the apple *)
    quality*: INTEGER; (** Качество продукта, см. @Качество яблока *)
    added: BOOLEAN     (** Whether Add was called on this seed after Init *)
  END;

  (** - **)
  LetterC = CHAR;
  LetterD = CHAR;

  (** ВСЯКОЕ **)

  INT32* = SYSTEM.INT32; (** Четырёхбайтовик *)
  INT64 = LONGINT; (** Длинное целое *)
  (** Просто массив *)
  Array* = POINTER TO ARRAY OF RECORD i: INTEGER END;

  Point = RECORD x, y: REAL (**Координаты!*) END; (** Точка? *)
  
  P1* = PROCEDURE; (** Процедура без ничего *)
  P2* = PROCEDURE(); (** Процедура с пустыми скобками *)
  P3* = PROCEDURE(): BOOLEAN; (** Булева процедура без параметров *)
  P4* = PROCEDURE(a, b: INTEGER): BOOLEAN; (** Булева процедура *)
  P5* = PROCEDURE(x: INTEGER; y: CHAR; z: CHAR); (** Процедура с параметрами *)

VAR
  applesCreated*: INTEGER; (** How many apples were created using Init *)
  (** If FALSE, Show shows a welcome message and sets shown to TRUE *)
  shown: BOOLEAN;
  lastAdded*: INTEGER; (** How many seeds were added the last time, or -1 *)
  (** ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ЗАПИСНЫХ ТИПОВ **)
  R: RECORD
    t, x: INTEGER; (** Время в секундах и мс *)
    z, y: Array    (** Z-буфер, показатель светимости  *)
  END;
  T: RECORD END;


  (*: PROCEDURE;
  b*: PROCEDURE(): INTEGER;
  y: ARRAY N, M OF PROCEDURE (VAR n: ARRAY OF BOOLEAN; VAR x, y: INTEGER): REAL;
  p*: POINTER TO Bird;*)

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
(*PROCEDURE Add*(VAR a: ARRAY 25 OF Fruits.Fruit23; VAR x, y, z, n: INTEGER);*)
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
