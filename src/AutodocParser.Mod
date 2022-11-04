MODULE AutodocParser;
IMPORT Files, Texts, Out, Args, Strings, Config, Platform;
CONST
  (** Lexer constants **)
  null*    = 0;
  comment* = 1;

  ident*   = 1;
  int*     = 2;
  real*    = 3;
  set*     = 4;
  string*  = 5;

  module*  = 10;
  record*  = 11;
  array*   = 12;
  pointer* = 13;
  to*      = 14;
  of*      = 15;
  begin*   = 16;
  end*     = 17;

  lparen*  = 30;
  rparen*  = 31;
  lbrak*   = 32;
  rbrak*   = 33;
  lbrace*  = 34;
  rbrace*  = 35;
  period*  = 36;
  comma*   = 37;
  upto*    = 38;
  colon*   = 39;
  semicol* = 40;
  equals*  = 41;
  plus*    = 42;
  minus*   = 43;
  times*   = 44;
  div*     = 45;
  mod*     = 46;
  rdiv*    = 47;

  eot*     = 70;

  (** Forms of Types **)

  undefType*     = 0;
  namedType*     = 1;
  recordType*    = 2;
  arrayType*     = 3;
  pointerType*   = 4;
  procedureType* = 5;

  (** See @Pass Kinds of Parameters *)
  byValue* = 0;
  byVar*   = 1;

TYPE
  Str* = ARRAY 256 OF CHAR;
  LongStr* = ARRAY 40960 OF CHAR;

  Object* = POINTER TO ObjectDesc;
  ObjectDesc* = RECORD
    name*: Str;
    comment*: LongStr;
    next: Object
  END;

  List* = POINTER TO ListDesc;
  ListDesc* = RECORD
    first*, last: Object
  END;

  Group* = POINTER TO GroupDesc;
  GroupDesc* = RECORD(ObjectDesc)
    body*: List
  END;

  Const* = POINTER TO ConstDesc;
  ConstDesc* = RECORD(ObjectDesc)
    value*: Str;
    isOrdinal*: BOOLEAN; (** TRUE if type of const is integer or char *)
    intVal*: INTEGER (** If isOrdinal, holds value in integer format *)
  END;

  Type* = POINTER TO TypeDesc;
  TypeDesc* = RECORD(ObjectDesc)
    form*: INTEGER; (** See @Form of Types *)
    len*: INTEGER;
    base*: Type; (** Base type of record, array or pointer *)
    fields*: List
  END;

  Var* = POINTER TO VarDesc;
  VarDesc* = RECORD(ObjectDesc)
    type*: Type
  END;

  Param* = POINTER TO ParamDesc;
  ParamDesc* = RECORD(ObjectDesc)
    pass*: INTEGER; (** See @Pass Kinds of Parameters *)
    type*: Type
  END;

  Procedure* = POINTER TO ProcedureDesc;
  ProcedureDesc* = RECORD(ObjectDesc)
    returnType*: Type;
    params*: List
  END;

  Module* = POINTER TO ModuleDesc;
  ModuleDesc* = RECORD(ObjectDesc)
  END;

PROCEDURE ParseModule*(VAR r: Files.Rider; VAR err: ARRAY OF CHAR): Module;
VAR module: Module;
BEGIN
  NEW(module);
  RETURN module
END ParseModule;

END AutodocParser.
