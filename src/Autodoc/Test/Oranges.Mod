MODULE Oranges;
(** Модуль содержит тип Orange -- расширение класса Fruits.Fruit *)
IMPORT Fruits, Strings, Int;

TYPE
  Orange* = POINTER TO OrangeDesc; (** Апельсин *)
  OrangeDesc* = RECORD(Fruits.FruitDesc) (** Запись-апельсин *)
    size*: INTEGER (** Диаметр апельсина в сантиметрах *)
  END;

PROCEDURE GetNameHandler(o: Orange; VAR s: Fruits.Name);
BEGIN
  s := 'Апельсин "';
  Strings.Append(o.name, s);
  Strings.Append('" размера ', s);
  Int.Append(o.size, s)
END GetNameHandler;

(** Обработчик сообщений. Обрабатывает некоторые сообщения,
    остальные передаёт в Fruits.FruitHandler.
    
    Вызывается процедурой Fruits.Handle через f.do(f, ...) *)
PROCEDURE OrangeHandler*(f: Fruits.Fruit; VAR msg: Fruits.Message);
BEGIN
  IF msg IS Fruits.GetNameMsg THEN
    GetNameHandler(f(Orange), msg(Fruits.GetNameMsg).s)
  ELSE Fruits.FruitHandler(f, msg)
  END
END OrangeHandler;

(** Инициалиазтор. Задаёт начальные значения банану.
    Вызывается конструктором NewOrange.
     Обработчик handle устанавливается в OrangeHandler *)
PROCEDURE InitOrange*(o: Orange; name: Fruits.Name; size: INTEGER);
BEGIN Fruits.InitFruit(o, name); o.size := size; o.handle := OrangeHandler
END InitOrange;

(** Конструктор *)
PROCEDURE NewOrange*(name: Fruits.Name; size: INTEGER): Orange;
VAR o: Orange;
BEGIN NEW(o); InitOrange(o, name, size)
RETURN o END NewOrange;

END Oranges.
