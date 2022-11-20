MODULE TestFruits;
IMPORT Fruits, Oranges, B := Bananas, Out;
VAR F: Fruits.Fruit;
  s: Fruits.Name;
  L: Fruits.List;
  pmsg: Fruits.PrintMsg;
BEGIN
  L := Fruits.NewList();

  F := Fruits.NewFruit('Взморье');
  Fruits.Print(F);
  Fruits.GetName(F, s);
  Out.String('Имя: '); Out.String(s); Out.Ln; Out.Ln;
  Fruits.Append(L, F);

  F := Oranges.NewOrange('Деревенский', 15);
  Fruits.Print(F);
  Fruits.GetName(F, s);
  Out.String('Имя: '); Out.String(s); Out.Ln; Out.Ln;
  Fruits.Append(L, F);

  F := B.NewBanana('Эквадорский', B.red);
  Fruits.Print(F);
  Fruits.GetName(F, s);
  Out.String('Имя: '); Out.String(s); Out.Ln; Out.Ln;
  Fruits.Append(L, F);

  Out.String('Список:'); Out.Ln;
  Fruits.Broadcast(L, pmsg)
END TestFruits.
