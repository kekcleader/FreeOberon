MODULE StrList;

TYPE
  Item = POINTER TO ItemDesc;
  ItemDesc = RECORD
    s: ARRAY 256 OF CHAR;
    next: Item
  END;

  List* = POINTER TO ListDesc;
  ListDesc* = RECORD
    eol*: BOOLEAN;
    first, last, cur: Item;
    count: INTEGER
  END;

PROCEDURE Clear*(L: List);
BEGIN L.first := NIL; L.last := NIL; L.cur := NIL;
  L.count := 0; L.eol := FALSE
END Clear;

PROCEDURE New*(): List;
VAR L: List;
BEGIN NEW(L); Clear(L)
RETURN L END New;

PROCEDURE Append*(L: List; s: ARRAY OF CHAR);
VAR p: Item;
BEGIN NEW(p); p.s := s; p.next := NIL; INC(L.count);
  IF L.count = 1 THEN L.first := p; L.last := p
  ELSE L.last.next := p; L.last := p
  END
END Append;

PROCEDURE Count*(L: List): INTEGER;
RETURN L.count END Count;

PROCEDURE GetCur(L: List; VAR s: ARRAY OF CHAR);
VAR i: INTEGER; p: Item;
BEGIN
  IF L.cur # NIL THEN L.eol := FALSE; p := L.cur; i := 0;
    WHILE (i < LEN(s) - 1) & (p.s[i] # 0X) DO s[i] := p.s[i]; INC(i) END;
    s[i] := 0X
  ELSE s[0] := 0X; L.eol := TRUE
  END
END GetCur;

PROCEDURE First*(L: List; VAR s: ARRAY OF CHAR);
BEGIN L.cur := L.first; GetCur(L, s);
  IF L.cur # NIL THEN L.cur := L.cur.next END
END First;

PROCEDURE Next*(L: List; VAR s: ARRAY OF CHAR);
BEGIN GetCur(L, s);
  IF L.cur # NIL THEN L.cur := L.cur.next END
END Next;

PROCEDURE SetPos*(L: List; pos: INTEGER);
VAR p: Item;
BEGIN p := L.first;
  WHILE (pos > 0) & (p # NIL) DO p := p.next; DEC(pos) END;
  L.cur := p
END SetPos;

END StrList.
