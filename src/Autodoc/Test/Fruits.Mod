MODULE Fruits;
(** Здесь объявлен абстрактный тип данных (класс) Fruit, который можно
    расширять с помощью обработчика сообщений в поле Fruit.handle
    (см., например, модули Oranges и Bananas), список фруктов List
    и процедуры к ним. *)
IMPORT Strings, Out;
CONST nameLen* = 64; (** Длина строки для названия фрукта *)
TYPE
  Name* = ARRAY nameLen OF CHAR; (** Тип-строка для имени фрукта *)

  (** Фрукт **)

  Fruit* = POINTER TO FruitDesc; (** Фрукт *)
  Message* = RECORD END; (** Абстрактное сообщение. Обрабатывается в Handler *)
  Handler* = PROCEDURE (f: Fruit; VAR msg: Message);

  (** Фрукт **)
  FruitDesc* = RECORD (** Фрукт *)
    next*: Fruit;
    x*, y*: INTEGER; (** Координаты *)
    name*: Name;
    handle*: Handler (** Обработчик события *)
  END;

  (** Список фруктов **)
  List* = POINTER TO ListDesc;
  ListDesc* = RECORD
    first*, last*: Fruit
  END;

  (** Сообщения для обработчика **)

  (** Напечатать в консоли приветствие фрукта и его X, Y *)
  PrintMsg* = RECORD(Message) END;

  (** Получть приветствие фрутка, т. е. наименование и имя *)
  GetNameMsg* = RECORD(Message) s*: Name END;

(** ООП Фруктов **)

(** Обработать сообщение фрукта *)
PROCEDURE Handle*(f: Fruit; VAR msg: Message);
BEGIN f.handle(f, msg)
END Handle;

(** Печать фрукта.
     Печатаются наименование фрукта (в расширениях типа Fruit может быть
    переопределено через GetNameMsg) и его координаты. Строка переносится *)
PROCEDURE Print*(f: Fruit);
VAR M: PrintMsg;
BEGIN f.handle(f, M)
END Print;

(** Получить наименование фрукта *)
PROCEDURE GetName*(f: Fruit; VAR s: ARRAY OF CHAR);
VAR M: GetNameMsg;
BEGIN f.handle(f, M); Strings.Copy(M.s, s)
END GetName;

(** Обработчик сообщения печати. Извне вызывается через процедуру Print *)
PROCEDURE PrintHandler(f: Fruit);
VAR M: GetNameMsg;
BEGIN
  f.handle(f, M);
  Out.String(M.s);
  Out.String(' X:'); Out.Int(f.x, 0);
  Out.String(' Y:'); Out.Int(f.y, 0); Out.Ln
END PrintHandler;

(** Обработчик сообщения "получить наименование".
     Пишет в s вид фрукта и его имя.
     В расширениях может выводить и другую информацию. *)
PROCEDURE GetNameHandler(f: Fruit; VAR s: Name);
BEGIN
  s := 'Фрукт "';
  Strings.Append(f.name, s);
  Strings.Append('"', s)
END GetNameHandler;

(** Обработчик сообщений. Вызывается процедурой Handle через f.do(f, ...),
    а также обработчиками в расширениях типа Fruit. *)
PROCEDURE FruitHandler*(f: Fruit; VAR msg: Message);
BEGIN
  IF msg IS PrintMsg THEN PrintHandler(f)
  ELSIF msg IS GetNameMsg THEN GetNameHandler(f, msg(GetNameMsg).s)
  END
END FruitHandler;

(** Инициалиазтор. Задаёт начальные значения фрукту. Вызывается
    конструктором NewFruit и инициализаторами всех расширений типа Fruit.
     Обработчик handle устанавливается в FruitHandler *)
PROCEDURE InitFruit*(f: Fruit; name: Name);
BEGIN f.x := 0; f.y := 0; f.handle := FruitHandler; Strings.Copy(name, f.name)
END InitFruit;

(** Конструктор *)
PROCEDURE NewFruit*(name: Name): Fruit;
VAR f: Fruit;
BEGIN NEW(f); InitFruit(f, name)
RETURN f END NewFruit;

(** Список фруктов **)

(** Создаёт и возвращает новый пустой список *)
PROCEDURE NewList*(): List;
VAR L: List;
BEGIN NEW(L)
RETURN L END NewList;

(** Опустошает список *)
PROCEDURE Clear*(L: List);
BEGIN L.first := NIL; L.last := NIL
END Clear;

(** Добавляет фрукт f в конец списка L.
     f.next получает значение NIL *)
PROCEDURE Append*(L: List; f: Fruit);
BEGIN
  IF L.last = NIL THEN L.first := f ELSE L.last.next := f END;
  L.last := f; f.next := NIL
END Append;

(** Каждому фрукту из списка L передаёт сообщение msg *)
PROCEDURE Broadcast*(L: List; VAR msg: Message);
VAR f: Fruit;
BEGIN
  f := L.first;
  WHILE f # NIL DO Handle(f, msg); f := f.next END
END Broadcast;

END Fruits.
