MODULE LSB;  (*Lola System Compiler Base LSBX, 26.9.2015*)
  IMPORT Texts, Oberon;

  CONST
    bit* = 0; array* = 1; unit* = 2;   (*type forms*)

    (*tags in output*) const* = 1; typ* = 2; var* = 3; lit* = 4; sel* = 7; range* = 8; cons* = 9;
    repl* = 10; not* = 11; and* = 12; mul* = 13; div* = 14; or* = 15; xor* = 16; add* = 17; sub* = 18;
    eql* = 20; neq* = 21; lss* = 22; geq* = 23; leq* = 24; gtr* = 25;
    then* = 30; else* = 31; ts* = 32; next* = 33;

  TYPE
    Item* = POINTER TO ItemDesc;
    Object* = POINTER TO ObjDesc;
    Type* = POINTER TO TypeDesc;
    ArrayType* = POINTER TO ArrayTypeDesc;
    UnitType* = POINTER TO UnitTypeDesc;

    ItemDesc* = RECORD
      tag*: INTEGER;
      type*: Type;
      val*, size*: LONGINT;
      a*, b*: Item
    END ;

    ObjDesc* = RECORD (ItemDesc)
      next*: Object;
      name*: ARRAY 32 OF CHAR;
      marked*: BOOLEAN
    END ;

    TypeDesc* = RECORD len*, size*: LONGINT; typobj*: Object END ;
    ArrayTypeDesc* = RECORD (TypeDesc) eltyp*: Type END ;
    UnitTypeDesc* = RECORD (TypeDesc) firstobj*: Object END ;

  VAR root*, top*: Object;
    bitType*, integer*, string*: Type;
    byteType*, wordType*: ArrayType;
    modname*: ARRAY 32 OF CHAR;

  PROCEDURE Register*(name: ARRAY OF CHAR; list: Object);
  BEGIN (*modname := name*) COPY(name, modname); top := list
  END Register;

BEGIN NEW(bitType); bitType.len := 0; bitType.size := 1; NEW(integer); NEW(string);
  NEW(byteType); byteType.len := 8; byteType.size := 8; byteType.eltyp := bitType;
  NEW(wordType); wordType.len := 32; wordType.size := 32; wordType.eltyp := bitType;
  NEW(root); root.tag := typ; root.name := "WORD"; root.type := wordType; root.next := NIL;
  NEW(top); top.tag := typ; top.name := "BYTE"; top.type := byteType; top.next := root; root := top;
  NEW(top); top.tag := typ; top.name := "BIT"; top.type := bitType; top.next := root; root := top
END LSB.

