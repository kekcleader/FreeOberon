MODULE AutodocParser;
IMPORT Files, Texts, Out, Args, Strings, Config, Platform;
CONST
  (** Lexer constants **)
  null    = 0;
  comment = 1;

  ident   = 1;
  int     = 2;
  real    = 3;
  set     = 4;
  char    = 5;
  string  = 6;

  module  = 10;
  record  = 11;
  array   = 12;
  pointer = 13;
  to      = 14;
  of      = 15;
  begin   = 16;
  end     = 17;

  lparen  = 30;
  rparen  = 31;
  lbrak   = 32;
  rbrak   = 33;
  lbrace  = 34;
  rbrace  = 35;
  period  = 36;
  comma   = 37;
  upto    = 38;
  colon   = 39;
  semicol = 40;
  equals  = 41;
  becomes = 42;
  plus    = 43;
  minus   = 44;
  times   = 45;
  div     = 46;
  mod     = 47;
  rdiv    = 48;
  not     = 49;

  eot     = 70;

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

VAR
  R: Files.Rider; (** Rider of the currently parsed module *)
  c: CHAR; (** One step ahead character read from rider R *)
  line, col: INTEGER; (** Position in R *)
  lastError: INTEGER; (** Position in R of last error, or -1 *)

  sym: INTEGER; (** One step ahead (syntactic) symbol read *)

  id: ARRAY 256 OF CHAR; (** Identifier read *)
  len: INTEGER; (** Actual length of id *)

  ival: INTEGER;

  writingDoc: BOOLEAN; (** TRUE when inside a doc comment *)
  doc: LongStr; (** Currently saved documentation comment *)
  docLen: INTEGER; (** Actual length of doc *)

(** Error Handling **)

PROCEDURE Mark(s: ARRAY OF CHAR);
VAR pos: INTEGER;
BEGIN
  pos := Files.Pos(R);
  IF (lastError = -1) OR (lastError + 7 < pos) THEN 
    Out.Int(line, 0); Out.Char(':'); Out.Int(col, 0);
    Out.String(': '); Out.String(s); Out.Ln
  END;
  lastError := pos
END Mark;

(** Handle Comments **)

PROCEDURE ClearComments;
BEGIN

END ClearComments;

(** Scanner **)

PROCEDURE Read;
BEGIN
  IF c = 0AX THEN INC(line); col := 0 END;
  IF ~R.eof THEN Files.ReadChar(R, c); INC(col) ELSE c := 0X END
END Read;

PROCEDURE IsLetter(x: CHAR): BOOLEAN;
RETURN ('a' <= x) & (x <= 'z') OR ('A' <= x) & (x <= 'Z') OR (x = '_')
END IsLetter;

PROCEDURE IsDec(x: CHAR): BOOLEAN;
RETURN ('0' <= x) & (x <= '9') END IsDec;

PROCEDURE IsHex(x: CHAR): BOOLEAN;
RETURN IsDec(x) OR ('a' <= x) & (x <= 'f') OR ('A' <= x) OR (x <= 'F')
END IsHex;

PROCEDURE FromHex(x: CHAR): INTEGER;
VAR n: INTEGER;
BEGIN
  IF ('A' <= x) & (x <= 'F') THEN n := 10 - ORD('A') + ORD(x)
  ELSIF ('a' <= x) & (x <= 'f') THEN n := 10 - ORD('a') + ORD(x)
  ELSIF ('0' <= x) & (x <= '9') THEN n := ORD(x) - ORD('0')
  ELSE ASSERT(FALSE)
  END
RETURN n END FromHex;

(** Identifies global var id and sets globar var sym. *)
PROCEDURE IdentifyKeyword;
BEGIN
  IF    id = 'MODULE'  THEN sym := module
  ELSIF id = 'RECORD'  THEN sym := record
  ELSIF id = 'ARRAY'   THEN sym := array
  ELSIF id = 'POINTER' THEN sym := pointer
  ELSIF id = 'TO'      THEN sym := to
  ELSIF id = 'OF'      THEN sym := of
  ELSIF id = 'BEGIN'   THEN sym := begin
  ELSIF id = 'END'     THEN sym := end
  ELSIF id = 'DIV'     THEN sym := div
  ELSIF id = 'MOD'     THEN sym := mod
  ELSE sym := ident
  END
END IdentifyKeyword;

(** Reads a decimal or hexadecimal number (or a hexadecimal char literal),
    puts it in id, len, ival, sym. *)
PROCEDURE ReadNumber;
VAR hex, isChar: BOOLEAN;
  i: INTEGER;
BEGIN
  len := 0;
  REPEAT
    IF len < LEN(id) - 1 THEN id[len] := c; INC(len) END;
    Read
  UNTIL ~IsHex(c);
  id[len] := 0X;

  isChar := c = 'X';
  IF (c = 'H') OR (c = 'X') THEN hex := TRUE; Read ELSE hex := FALSE END;

  ival := 0;
  IF hex THEN
    i := 0;
    WHILE id[i] # 0X DO ival := ival * 16 + FromHex(id[i]); INC(i) END;
    IF isChar THEN sym := char ELSE sym := int END
  ELSE
    i := 0;
    WHILE id[i] # 0X DO
      IF IsDec(id[i]) THEN ival := ival * 10 + ORD(id[i]) - ORD('0')
      ELSE Mark('Not a hexadecimal number')
      END;
      INC(i)
    END;
    sym := int
  END
END ReadNumber;

PROCEDURE WriteDoc(c: CHAR);
BEGIN
  IF writingDoc THEN
    IF docLen < LEN(doc) - 1 THEN
      IF (c > ' ') OR (docLen # 0) & (doc[docLen - 1] > ' ') THEN
        IF c < ' ' THEN c := ' ' END;
        doc[docLen] := c; INC(docLen)
      END
    END
  END
END WriteDoc;

PROCEDURE ReadComment(toplevel: BOOLEAN);
VAR closed, tmp: BOOLEAN;
BEGIN Read; closed := FALSE; writingDoc := FALSE;
  IF c = '*' THEN Read; (* Second star *)
    IF c = ')' THEN Read; closed := TRUE
    ELSIF toplevel THEN writingDoc := TRUE; docLen := 0
    END
  END;
  IF ~closed THEN
    REPEAT
      WHILE (c # 0X) & (c # '*') DO
        IF c = '(' THEN Read;
          IF c = '*' THEN
            tmp := writingDoc;
            ReadComment(FALSE);
            writingDoc := tmp
          ELSE WriteDoc('(')
          END
        END;
        WriteDoc(c); Read
      END;
      IF c = '*' THEN Read;
        IF c # ')' THEN WriteDoc(c) END
      END
    UNTIL (c = 0X) OR (c = ')');
    IF c = ')' THEN Read END
  END;
  IF writingDoc & (docLen # 0) THEN
    REPEAT DEC(docLen) UNTIL (docLen = -1) OR (doc[docLen] > ' ');
    doc[docLen + 1] := 0X;
    Out.Char('"'); Out.String(doc); Out.Char('"'); Out.Ln
  END
END ReadComment;

PROCEDURE Get(VAR sym: INTEGER);
BEGIN
  WHILE (c # 0X) & (c <= ' ') DO Read END;
  IF IsLetter(c) THEN
    len := 0;
    REPEAT
      IF len < LEN(id) - 1 THEN id[len] := c; INC(len) END;
      Read
    UNTIL ~IsLetter(c) & ~IsDec(c);
    id[len] := 0X;
    IdentifyKeyword
  ELSIF IsDec(c) THEN ReadNumber
  ELSIF c = '+' THEN Read; sym := plus
  ELSIF c = '-' THEN Read; sym := minus
  ELSIF c = '*' THEN Read; sym := times
  ELSIF c = '/' THEN Read; sym := rdiv
  ELSIF c = '~' THEN Read; sym := not
  ELSIF c = ',' THEN Read; sym := comma
  ELSIF c = ':' THEN Read;
    IF c = '=' THEN Read; sym := becomes ELSE sym := colon END
  ELSIF c = '.' THEN Read;
    IF c = '.' THEN Read; sym := upto ELSE sym := period END
  ELSIF c = '(' THEN Read;
    IF c = '*' THEN ReadComment(TRUE) ELSE Read; sym := lparen END
  ELSIF c = ')' THEN Read; sym := rparen
  ELSIF c = '[' THEN Read; sym := lbrak
  ELSIF c = ']' THEN Read; sym := rbrak
  ELSIF c = '{' THEN Read; sym := lbrace
  ELSIF c = '}' THEN Read; sym := rbrace
  ELSIF c = ';' THEN Read; sym := semicol
  ELSIF c = '=' THEN Read; sym := equals
  ELSIF c = 0X THEN sym := eot
  ELSE Read; sym := null
  END;
  sym := module
END Get;

(** Parser **)

PROCEDURE ParseModule*(VAR r: Files.Rider; VAR err: ARRAY OF CHAR): Module;
VAR M: Module;
  sym: INTEGER;
BEGIN
  R := r; c := 0X; line := 1; col := 0; lastError := -1;
  Read; ClearComments; Get(sym);
  IF sym = module THEN
    Get(sym)
  ELSE Mark('MODULE expected')
  END;
  NEW(M)
RETURN M END ParseModule;

END AutodocParser.
