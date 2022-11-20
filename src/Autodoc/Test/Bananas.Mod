MODULE Bananas;
(** Модуль содержит тип Banana -- расширение класса Fruits.Fruit *)
IMPORT Fr := Fruits, S := Strings, Int;

CONST
  (** Цвета бананов **)
  yellow* = 1; (** Желтый *)
  red*    = 2; (** Красный *)
  brown*  = 0; (** Коричневый *)

TYPE
  Banana* = POINTER TO BananaDesc; (** Банан *)
  BananaDesc* = RECORD(Fr.FruitDesc) (** Запись-банан *)
    color*: INTEGER (** Цвет банана, см. Цвета бананов *)
  END;

PROCEDURE GetNameHandler(o: Banana; VAR s: Fr.Name);
BEGIN
  s := 'Банан "'; S.Append(o.name, s); S.Append('" ', s);
  IF o.color = yellow THEN S.Append('жёлтого', s)
  ELSIF o.color = red THEN S.Append('красного', s)
  ELSIF o.color = brown THEN S.Append('коричневого', s)
  ELSE S.Append('непонятного', s)
  END;
  S.Append(' цвета', s)
END GetNameHandler;

(** Обработчик сообщений. Обрабатывает некоторые сообщения,
    остальные передаёт в Fruits.FruitHandler.
    
    Вызывается процедурой Fruits.Handle через f.do(f, ...) *)
PROCEDURE BananaHandler*(f: Fr.Fruit; VAR msg: Fr.Message);
BEGIN
  IF msg IS Fr.GetNameMsg THEN
    GetNameHandler(f(Banana), msg(Fr.GetNameMsg).s)
  ELSE Fr.FruitHandler(f, msg)
  END
END BananaHandler;

(** Инициалиазтор. Задаёт начальные значения банану.
    Вызывается конструктором NewBanana.
     Обработчик handle устанавливается в BananaHandler *)
PROCEDURE InitBanana*(o: Banana; name: Fr.Name; color: INTEGER);
BEGIN Fr.InitFruit(o, name); o.color := color; o.handle := BananaHandler
END InitBanana;

(** Конструктор *)
PROCEDURE NewBanana*(name: Fr.Name; color: INTEGER): Banana;
VAR o: Banana;
BEGIN NEW(o); InitBanana(o, name, color)
RETURN o END NewBanana;

END Bananas.
