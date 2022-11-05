MODULE AutodocParser;
IMPORT Files, Texts, Out, Args, Strings, Config, Platform, Int;
CONST
  (** Lexer constants **)
  null    = 0;

  ident   = 1;
  int     = 2;
  real    = 3;
  set     = 4;
  char    = 5;
  string  = 6;

  module    = 10;
  import    = 11;
  const     = 12;
  type      = 13;
  var       = 14;
  record    = 15;
  array     = 16;
  pointer   = 17;
  to        = 18;
  of        = 19;
  procedure = 20;
  begin     = 21;
  end       = 22;

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
    foreign*: BOOLEAN (** TRUE if module has a [foreign] mark *)
  END;

VAR
  curFname: Str; (** Set by SetFname and used in Mark for error output *)
  R: Files.Rider; (** Rider of the currently parsed module *)
  c: CHAR; (** One step ahead character read from rider R *)
  line, col: INTEGER; (** Position in R *)
  lastError: INTEGER; (** Position in R of last error, or -1 *)

  sym: INTEGER; (** One step ahead (syntactic) symbol read *)

  id: ARRAY 256 OF CHAR; (** Identifier read *)
  len: INTEGER; (** Actual length of id *)

  sval: Str; (** String read, when sym = string *)
  ival: INTEGER;

  writingDoc: BOOLEAN; (** TRUE when inside a doc comment *)
  doc: LongStr; (** Currently saved documentation comment *)
  docLen: INTEGER; (** Actual length of doc *)

(** Error Handling **)

(** Used for error output in Mark *)
PROCEDURE SetFname*(fname: ARRAY OF CHAR);
BEGIN curFname := fname
END SetFname;

PROCEDURE Mark(s: ARRAY OF CHAR);
VAR pos: INTEGER;
BEGIN
  pos := Files.Pos(R);
  IF (lastError = -1) OR (lastError + 7 < pos) THEN 
    Out.String(curFname); Out.Char(':');
    Out.Int(line, 0); Out.Char(':'); Out.Int(col, 0);
    Out.String(': error: '); Out.String(s); Out.Ln
  END;
  lastError := pos
END Mark;

PROCEDURE SymToStr(sym: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN
  IF    sym = null      THEN s := 'nothing'
  ELSIF sym = ident     THEN Strings.Copy(id, s)
  ELSIF sym = int       THEN Int.Str(ival, s)
  ELSIF sym = real      THEN s := 'real number'
  ELSIF sym = set       THEN s := 'set'
  ELSIF sym = string    THEN s := 'string'
  ELSIF sym = module    THEN s := 'MODULE'
  ELSIF sym = import    THEN s := 'IMPORT'
  ELSIF sym = const     THEN s := 'CONST'
  ELSIF sym = type      THEN s := 'TYPE'
  ELSIF sym = var       THEN s := 'VAR'
  ELSIF sym = record    THEN s := 'RECORD'
  ELSIF sym = array     THEN s := 'ARRAY'
  ELSIF sym = pointer   THEN s := 'POINTER'
  ELSIF sym = to        THEN s := 'TO'
  ELSIF sym = of        THEN s := 'OF'
  ELSIF sym = procedure THEN s := 'PROCEDURE'
  ELSIF sym = begin     THEN s := 'BEGIN'
  ELSIF sym = end       THEN s := 'END'
  ELSIF sym = div       THEN s := 'DIV'
  ELSIF sym = mod       THEN s := 'MOD'
  ELSIF sym = lparen    THEN s := '('
  ELSIF sym = rparen    THEN s := ')'
  ELSIF sym = lbrak     THEN s := '['
  ELSIF sym = rbrak     THEN s := ']'
  ELSIF sym = lbrace    THEN s := '{'
  ELSIF sym = rbrace    THEN s := '}'
  ELSIF sym = period    THEN s := '.'
  ELSIF sym = comma     THEN s := ','
  ELSIF sym = upto      THEN s := '..'
  ELSIF sym = colon     THEN s := ':'
  ELSIF sym = semicol   THEN s := ';'
  ELSIF sym = equals    THEN s := '='
  ELSIF sym = becomes   THEN s := ':='
  ELSIF sym = plus      THEN s := '+'
  ELSIF sym = minus     THEN s := '-'
  ELSIF sym = times     THEN s := '*'
  ELSIF sym = rdiv      THEN s := '/'
  ELSIF sym = not       THEN s := '~'
  ELSIF sym = eot       THEN s := 'end of text'
  ELSE s := 'Symbol #'; Int.Append(sym, s)
  END
END SymToStr;

PROCEDURE MarkExp(name: ARRAY OF CHAR);
VAR s, word: ARRAY 256 OF CHAR;
BEGIN
  s := name; Strings.Append(' expected, but ', s);
  SymToStr(sym, word); Strings.Append(word, s);
  Strings.Append(' found', s);
  Mark(s)
END MarkExp;

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
RETURN IsDec(x) OR ('a' <= x) & (x <= 'f') OR ('A' <= x) & (x <= 'F')
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

  ival := 0; i := 0;
  IF hex THEN
    WHILE id[i] # 0X DO ival := ival * 16 + FromHex(id[i]); INC(i) END;
    IF isChar THEN sym := char ELSE sym := int END
  ELSE
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

(** Identifies global var id and sets globar var sym. *)
PROCEDURE IdentifyKeyword;
BEGIN
  IF    id = 'MODULE'  THEN sym := module
  ELSIF id = 'IMPORT'  THEN sym := import
  ELSIF id = 'CONST'   THEN sym := const
  ELSIF id = 'TYPE'    THEN sym := type
  ELSIF id = 'VAR'     THEN sym := var
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

PROCEDURE GetSym;
BEGIN
  sym := null;
  REPEAT
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
    ELSE Read
    END
  UNTIL sym # null
END GetSym;

(** Object **)

PROCEDURE InitObject(o: Object);
BEGIN o.name[0] := 0X; o.comment[0] := 0X; o.next := NIL
END InitObject;

(** Parser **)

PROCEDURE ParseConstDecl(o: Object);
BEGIN
  GetSym
END ParseConstDecl;

PROCEDURE ParseTypeDecl(o: Object);
BEGIN
  GetSym
END ParseTypeDecl;

PROCEDURE ParseVarDecl(o: Object);
BEGIN
  GetSym
END ParseVarDecl;

PROCEDURE Declarations(o: Object);
BEGIN
  IF sym = const THEN ParseConstDecl(o) END;
  IF sym = type THEN ParseTypeDecl(o) END;
  IF sym = var THEN ParseVarDecl(o) END
  ;GetSym
END Declarations;

PROCEDURE ParseImport(M: Module);
BEGIN
  GetSym
END ParseImport;

PROCEDURE ParseModule*(VAR r: Files.Rider; VAR err: ARRAY OF CHAR): Module;
VAR M: Module;
BEGIN NEW(M); InitObject(M); M.foreign := FALSE;
  R := r; c := 0X; line := 1; col := 0; lastError := -1;
  Read; ClearComments; GetSym;
  IF sym = module THEN GetSym;
    IF sym = lbrak THEN GetSym;
      IF (sym = ident) & (id = 'foreign') THEN M.foreign := TRUE END;
      REPEAT GetSym UNTIL (sym = eot) OR (sym = rbrak);
      GetSym
    END;
    IF sym = ident THEN Strings.Copy(id, M.name); GetSym
    ELSE MarkExp('module name')
    END;
    IF sym = semicol THEN GetSym ELSE MarkExp(';') END;
    IF sym = import THEN ParseImport(M) END;
    Declarations(M);
    IF sym = begin THEN
      REPEAT GetSym UNTIL (sym = eot) OR (sym = end)
    END;
    IF sym = end THEN GetSym
    ELSE
      MarkExp('END of module');
      REPEAT GetSym UNTIL (sym = eot) OR (sym = end)
    END;
    IF sym = ident THEN
      IF M.name # id THEN Mark('Module name mismatch') END
    ELSE MarkExp('module name')
    END;
    IF sym # period THEN MarkExp('.') END
  ELSE MarkExp('MODULE')
  END;
  IF lastError # -1 THEN M := NIL; err := 'Error' (*!FIXME*) END
RETURN M END ParseModule;

BEGIN curFname[0] := 0X
END AutodocParser.
