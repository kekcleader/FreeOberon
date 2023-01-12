MODULE AutodocParser;
IMPORT Files, Texts, Out, Strings, Platform, Int;
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
  in        = 15;
  out       = 16;
  record    = 17;
  array     = 18;
  pointer   = 19;
  to        = 20;
  of        = 21;
  procedure = 22;
  begin     = 23;
  end       = 24;

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
  arrow   = 50;

  eot     = 70;

  (** Forms of Types **)
  undefType*     = 0;
  namedType*     = 1;
  recordType*    = 2;
  arrayType*     = 3;
  pointerType*   = 4;
  procedureType* = 5;

  (** Values of Param.passed **)
  byValue* = 0;
  byVar*   = 1; (** When a formal parameter has VAR, IN or OUT before it *)

  (** Comment separators **)
  tab  = 9X;  (** Separates two special comments *)
  vtab = 0BX; (** Separates two comments that related to different objects *)

TYPE
  Str* = ARRAY 256 OF CHAR;
  LongStr* = ARRAY 40960 OF CHAR;

  Object* = POINTER TO ObjectDesc;
  ObjectDesc* = RECORD
    name*: Str;
    comment*: LongStr;
    exported*: BOOLEAN;
    next*: Object
  END;

  List* = POINTER TO ListDesc;
  ListDesc* = RECORD(ObjectDesc)
    first*, last*: Object
  END;

  Group* = POINTER TO GroupDesc;
  GroupDesc* = RECORD(ListDesc)
    ordinalConsts*: BOOLEAN
  END;
  
  Import* = POINTER TO ImportDesc;
  ImportDesc* = RECORD(ObjectDesc)
    alias*: Str
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
    len*: Str;      (** Length of array (may be an expression), or '' *)
    base*: Type;    (** Base type of rec/arr/pointer, return of procedure *)
    fields*: List
  END;

  Var* = POINTER TO VarDesc; (** Global variables and record fields *)
  VarDesc* = RECORD(ObjectDesc)
    type*: Type
  END;

  Param* = POINTER TO ParamDesc;
  ParamDesc* = RECORD(ObjectDesc)
    passed*: INTEGER; (** See values of Param.pass *)
    type*: Type
  END;

  Procedure* = POINTER TO ProcedureDesc;
  ProcedureDesc* = RECORD(ObjectDesc)
    returnType*: Type;
    params*: List
  END;

  Module* = POINTER TO ModuleDesc;
  ModuleDesc* = RECORD(ObjectDesc)
    foreign*: BOOLEAN; (** TRUE if module has a [foreign] mark *)
    exportedOnly*: BOOLEAN; (** TRUE if only exported objects are included *)
    imports*: List; (** List of imports (no groups) *)
    consts*, types*, vars*: List; (** List of groups *)
    procedures*: List (** List of groups *)
  END;

VAR
  curModule: Module; (** Currently generated module data structure *)
  curFname: Str; (** Set by SetFname and used in Mark for error output *)
  R: Files.Rider; (** Rider of the currently parsed module *)
  c: CHAR; (** One step ahead character read from rider R *)
  line, col: INTEGER; (** Position in R *)
  lastError: INTEGER; (** Position in R of last error, or -1 *)
  constExprBeginPos: INTEGER; (** After '=' or 'ARRAY', see ParseConstExpr *)
  constExprBeginC: CHAR; (** Value of c the moment constExprBeginPos is set *)
  objectIsExported: BOOLEAN; (** The parsed variable/field/param is exported *)

  sym: INTEGER; (** One step ahead (syntactic) symbol read *)

  id: ARRAY 256 OF CHAR; (** Identifier read *)
  len: INTEGER; (** Actual length of id *)

  sval: Str; (** String read, when sym = string *)
  ival: INTEGER;

  writingDoc: BOOLEAN; (** TRUE when inside a doc comment *)
  docNewLine: BOOLEAN; (** 0AX reached and no non-spaces after it yet *)
  doc: LongStr; (** Currently saved documentation comment *)
  docLen: INTEGER; (** Actual length of doc *)
  docCol: INTEGER; (** Column of 1st non-space of 1st comment in doc, or -1 *)
  docLine: INTEGER; (** Line where the first doc-comment in doc started *)
  docEndLine: INTEGER; (** Line where the last doc-comment in doc ended *)
  pre: BOOLEAN; (** TRUE when the current comment line is pre-formatted *)
  (** Title of the current group of comments.
      A special value of '-' means an empty title. Assigned by ReadComment.
      Used by NewGroup and UpdateCurGroup. Reset by Parse* procedures. *)
  curTitle: Str;
  titleNotUsed: BOOLEAN; (** To clear curTitle between decl sections *)
  
  PrintObject: PROCEDURE (o: Object; indent: INTEGER; inlined: BOOLEAN);
  ParseType: PROCEDURE (docObj: Object): Type;
  ParseParamType: PROCEDURE (): Type;
  
  (** Parsing Parameters **)
  
  exportedOnly: BOOLEAN; (** If TRUE, only exported objects are added *)
  keepAliases: BOOLEAN; (** If FALSE, change alias to real module names *)
  
  (** Debug **)
  debug*: BOOLEAN;

(** Parsing Parameters **)

PROCEDURE SetExportedOnly*(yes: BOOLEAN);
BEGIN exportedOnly := yes
END SetExportedOnly;

PROCEDURE SetKeepAliases*(yes: BOOLEAN);
BEGIN keepAliases := yes
END SetKeepAliases;

(** Debug **)

PROCEDURE Debug*(s: ARRAY OF CHAR);
BEGIN
  IF debug THEN Out.String(s); Out.Ln END
END Debug;

PROCEDURE SetDebug*(yes: BOOLEAN);
BEGIN debug := yes
END SetDebug;

(** Error Handling **)

(** Used for error output in Mark *)
PROCEDURE SetFname*(fname: ARRAY OF CHAR);
BEGIN curFname := fname
END SetFname;

(** Show error s *)
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

(** Show error consisting of a + b + c *)
PROCEDURE Mark3(a, b, c: ARRAY OF CHAR);
VAR s: ARRAY 1024 OF CHAR;
BEGIN s := a; Strings.Append(b, s); Strings.Append(c, s); Mark(s)
END Mark3;

(** Put textual representation of sym in s *)
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
  ELSIF sym = in        THEN s := 'IN'
  ELSIF sym = out       THEN s := 'OUT'
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
  ELSIF sym = arrow     THEN s := '^'
  ELSIF sym = eot       THEN s := 'end of text'
  ELSE s := 'Symbol #'; Int.Append(sym, s)
  END
END SymToStr;

(** Show error that something is expected, but something else found. *)
PROCEDURE MarkExp(name: ARRAY OF CHAR);
VAR s, word: ARRAY 256 OF CHAR;
BEGIN
  s := name; Strings.Append(' expected, but ', s);
  SymToStr(sym, word); Strings.Append(word, s);
  Strings.Append(' found', s); Mark(s)
END MarkExp;

(** Show error that a module or a procedure was not closed *)
PROCEDURE MarkEnd(title, name: ARRAY OF CHAR);
VAR s, word: ARRAY 256 OF CHAR;
BEGIN
  Strings.Copy(title, s); Strings.Append(' ', s); Strings.Append(name, s);
  Strings.Append(' is not closed.', s); Mark(s)
END MarkEnd;

(** Handle Comments **)

(** Remove all comments from doc *)
PROCEDURE ClearComments;
BEGIN doc[0] := 0X; docLen := 0; docLine := -1; docEndLine := -1
END ClearComments;

(** Comments **)

(** Append the first comment from global variable doc to the the given string.
     If vertical tab exists in doc, the first comment spans from doc[0] till
    the first vertical tab, otherwise till the first tab or 0X character. *)
PROCEDURE AppendComment(VAR comment: ARRAY OF CHAR);
VAR L, i, j: INTEGER;
BEGIN
  L := 0; WHILE (doc[L] # 0X) & (doc[L] # vtab) DO INC(L) END;
  IF doc[L] = 0X THEN (** Vertical tab not found, find first tab *)
    L := 0; WHILE (doc[L] # 0X) & (doc[L] # tab) DO INC(L) END
  END;
  j := Strings.Length(comment); i := 0;
  WHILE (i # L) & (j < LEN(comment) - 1) DO
    comment[j] := doc[i]; INC(i); INC(j)
  END;
  comment[j] := 0X;
  IF doc[L] = 0X THEN ClearComments
  ELSE Strings.Delete(doc, 0, L + 1); DEC(docLen, L + 1)
  END
END AppendComment;

(** Put text of the last comment to varpar comment, remove it from doc,
    put in its place in doc the character vtab instead of tab. *)
PROCEDURE GetLastComment(VAR comment: ARRAY OF CHAR);
VAR L, i, j: INTEGER;
BEGIN
  IF docLen # 0 THEN L := docLen;
    WHILE (L # -1) & (doc[L] # tab) & (doc[L] # vtab) DO DEC(L) END;
    Strings.Extract(doc, L + 1, docLen - L - 1, comment);
    WHILE (L # -1) & ((doc[L] = tab) OR (doc[L] = vtab)) DO DEC(L) END;
    IF L # -1 THEN doc[L + 1] := vtab; doc[L + 2] := 0X; docLen := L + 2
    ELSE ClearComments
    END
  ELSE comment[0] := 0X
  END
END GetLastComment;

(** Join all comments and attach them to o *)
PROCEDURE SaveAllComments(o: Object);
VAR i: INTEGER;
BEGIN
  IF o # NIL THEN
    Strings.Copy(doc, o.comment); ClearComments;
    i := 0;
    WHILE o.comment[i] # 0X DO
      IF o.comment[i] < ' ' THEN o.comment[i] := 0AX END;
      INC(i)
    END
  ELSE ClearComments
  END
END SaveAllComments;

(** Stores the first comment from global variable doc in the given object o,
    but does that only if o does not yet have a comment or if lastLine = -1 or
    if lastLine is equal to the line where the comment started (= docLine).
     Parameter lastLine should be equal to the line number of the last symbol
    of the declaration (the semicolon), or -1 when saving a pre-comment.
     See AppendComment for more info on what "the first comment" means. *)
PROCEDURE SaveComment(o: Object; lastLine: INTEGER);
BEGIN
  IF (o # NIL) & (doc[0] # 0X) & ((lastLine = -1) OR (docLine = lastLine)) THEN
    IF o.comment[0] = 0X THEN AppendComment(o.comment)
    ELSIF docLine = lastLine THEN Strings.Append(0AX, o.comment);
      AppendComment(o.comment)
    END
  END
END SaveComment;

(** Scanner **)

(** Text Driver *)
PROCEDURE Read;
BEGIN
  IF c = 0AX THEN INC(line); col := 0 END;
  IF ~R.eof THEN Files.ReadChar(R, c); INC(col) ELSE c := 0X END
END Read;

PROCEDURE IsLetter*(x: CHAR): BOOLEAN;
RETURN ('a' <= x) & (x <= 'z') OR ('A' <= x) & (x <= 'Z') OR (x = '_')
END IsLetter;

PROCEDURE IsDec*(x: CHAR): BOOLEAN;
RETURN ('0' <= x) & (x <= '9') END IsDec;

PROCEDURE IsHex(x: CHAR): BOOLEAN;
RETURN IsDec(x) OR ('a' <= x) & (x <= 'f') OR ('A' <= x) & (x <= 'F')
END IsHex;

(** Also used in AutodocHtml.PrintColorValue *)
PROCEDURE FromHex*(x: CHAR): INTEGER;
VAR n: INTEGER;
BEGIN
  IF ('A' <= x) & (x <= 'F') THEN n := 10 - ORD('A') + ORD(x)
  ELSIF ('a' <= x) & (x <= 'f') THEN n := 10 - ORD('a') + ORD(x)
  ELSIF ('0' <= x) & (x <= '9') THEN n := ORD(x) - ORD('0')
  ELSE ASSERT(FALSE)
  END
RETURN n END FromHex;

PROCEDURE ToHex(n: INTEGER): CHAR;
VAR x: CHAR;
BEGIN
  IF (0 <= n) & (n < 10) THEN x := CHR(ORD('0') + n)
  ELSIF (10 <= n) & (n < 16) THEN x := CHR(ORD('A') - 10 + n)
  ELSE ASSERT(FALSE)
  END
RETURN x END ToHex;

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

(** Добавляет литеру в конец doc по следующей схеме:
     (был - что там на конце сейчас, доб - что добавляем, рез - результат)

      был   доб  рез
      ' '   ' '  ничего/замена
      ' '   0AX  замена
      0AX   ' '  ничего
      0AX   0AX  ничего/замена       *)
PROCEDURE AppendDocChar(x: CHAR);
VAR p: CHAR;
BEGIN
  IF pre & (x = ' ') THEN doc[docLen] := x; INC(docLen)
  ELSIF docLen # 0 THEN p := doc[docLen - 1];
    IF p > ' ' THEN doc[docLen] := x; INC(docLen)
    ELSIF (p # x) & (x = 0AX) THEN doc[docLen - 1] := x
    END
  END
END AppendDocChar;

PROCEDURE DocTrimRight;
BEGIN
  WHILE (docLen # 0) & (doc[docLen - 1] = ' ') DO DEC(docLen) END
END DocTrimRight;

PROCEDURE BeginPre;
BEGIN
  IF ~pre THEN
    IF docLen < LEN(doc) - 11 THEN
      doc[docLen] := '`'; INC(docLen); doc[docLen] := '`'; INC(docLen);
      doc[docLen] := '`'; INC(docLen); doc[docLen] := 0AX; INC(docLen)
    END;
    pre := TRUE
  END
END BeginPre;

PROCEDURE EndPre;
BEGIN
  IF pre THEN
    IF docLen < LEN(doc) - 4 THEN
      doc[docLen] := 0AX; INC(docLen); doc[docLen] := '`'; INC(docLen);
      doc[docLen] := '`'; INC(docLen); doc[docLen] := '`'; INC(docLen)
    END;
    pre := FALSE
  END
END EndPre;

(** Attach a character to the end of comment in global varaible doc *)
PROCEDURE WriteDoc(c: CHAR);
VAR i: INTEGER;
BEGIN
  IF writingDoc & (docLen < LEN(doc) - 1) THEN
    IF c = 0AX THEN
      IF ~docNewLine THEN docNewLine := TRUE
      ELSE AppendDocChar(0AX)
      END
    ELSE
      IF c <= ' ' THEN AppendDocChar(' ')
      ELSE
        IF docNewLine THEN
          IF (col = docCol) OR (col = 0) THEN
            IF pre THEN DocTrimRight; EndPre; AppendDocChar(0AX)
            ELSE AppendDocChar(' ')
            END
          ELSIF col = docCol + 1 THEN EndPre; AppendDocChar(0AX)
          ELSE DocTrimRight; AppendDocChar(0AX); BeginPre;
            FOR i := 1 TO col - docCol DO AppendDocChar(' ') END
          END;
          docNewLine := FALSE
        END;
        doc[docLen] := c; INC(docLen)
      END
    END
  END
END WriteDoc;

(** Recursive procedure to read (potentially nested) comments.
     toplevel is TRUE only for the top-level comments, only the top-level
    comments that are opened with two stars are being saved in doc.
    The procedure is called at '*' that comes after '(' *)
PROCEDURE ReadComment(toplevel: BOOLEAN);
VAR closed, tmp: BOOLEAN;
  x: CHAR;
  title: BOOLEAN;
BEGIN
  IF toplevel & (docLen = 0) THEN docLine := line END;
  Read; closed := FALSE; writingDoc := FALSE;
  docNewLine := FALSE; docCol := -1; pre := FALSE;
  IF c = '*' THEN Read; (* Second star *)
    IF c = ')' THEN Read; closed := TRUE
    ELSIF toplevel THEN writingDoc := TRUE;
      IF (docLen # 0) & (doc[docLen - 1] # tab) & (doc[docLen - 1] # vtab) THEN
        doc[docLen] := tab; INC(docLen)
      END
    END
  END;
  IF ~closed THEN
    WHILE (c # 0X) & (c = ' ') DO Read END;
    docCol := col;
    REPEAT
      WHILE (c # 0X) & (c # '*') DO
        IF c = '(' THEN Read;
          IF c = '*' THEN
            tmp := writingDoc;
            ReadComment(FALSE);
            writingDoc := tmp
          ELSE WriteDoc('(')
          END
        ELSE WriteDoc(c); Read
        END
      END;
      IF c = '*' THEN Read;
        IF c # ')' THEN WriteDoc('*') END
      END
    UNTIL (c = 0X) OR (c = ')');
    IF toplevel THEN docEndLine := line END;
    IF c = ')' THEN Read END
  END;
  IF writingDoc & (docLen # 0) THEN
    IF doc[docLen - 1] = '*' THEN (* Title comment *)
      DEC(docLen); doc[docLen] := 0X; title := TRUE
    ELSE title := FALSE
    END;
    REPEAT DEC(docLen) UNTIL (docLen = -1) OR (doc[docLen] > ' ');
    IF (docLen # -1) & (docLen < LEN(doc) - 2) THEN x := doc[docLen];
      IF ~title & (x # '!') & (x # ',') & (x # '.') &
         (x # ':') & (x # ';') & (x # '?') & (x # '*')
      THEN INC(docLen); doc[docLen] := '.'
      END
    END;
    INC(docLen); doc[docLen] := 0X;
    IF title THEN
      titleNotUsed := TRUE;
      IF doc[0] = 0X THEN curTitle := '-'
      ELSE curTitle[0] := 0X; GetLastComment(curTitle)
      END
    END
  END;
  IF pre & writingDoc THEN EndPre END
END ReadComment;

(** Uses global var id to set global var sym.
    Identifies such keywords as MODULE and BEGIN. *)
PROCEDURE IdentifyKeyword;
BEGIN
  IF    id = 'MODULE'    THEN sym := module
  ELSIF id = 'IMPORT'    THEN sym := import
  ELSIF id = 'CONST'     THEN sym := const
  ELSIF id = 'TYPE'      THEN sym := type
  ELSIF id = 'VAR'       THEN sym := var
  ELSIF id = 'IN'        THEN sym := in
  ELSIF id = 'OUT'       THEN sym := out
  ELSIF id = 'RECORD'    THEN sym := record
  ELSIF id = 'ARRAY'     THEN sym := array
  ELSIF id = 'POINTER'   THEN sym := pointer
  ELSIF id = 'TO'        THEN sym := to
  ELSIF id = 'OF'        THEN sym := of
  ELSIF id = 'PROCEDURE' THEN sym := procedure
  ELSIF id = 'BEGIN'     THEN sym := begin
  ELSIF id = 'END'       THEN sym := end
  ELSIF id = 'DIV'       THEN sym := div
  ELSIF id = 'MOD'       THEN sym := mod
  ELSE sym := ident
  END
END IdentifyKeyword;

PROCEDURE ReadIdentOrKeyword;
BEGIN
  len := 0;
  REPEAT
    IF len < LEN(id) - 1 THEN id[len] := c; INC(len) END;
    Read
  UNTIL ~IsLetter(c) & ~IsDec(c);
  id[len] := 0X;
  IdentifyKeyword
END ReadIdentOrKeyword;

PROCEDURE ReadString;
VAR q: CHAR;
BEGIN q := c; len := 0; Read;
  WHILE (c >= ' ') & (c # q) DO
    IF len < LEN(id) - 3 THEN
      id[len] := c; INC(len)
    END;
    Read
  END;
  id[len] := 0X;
  IF c = q THEN Read ELSE Mark('String not terminated') END;
  sym := string
END ReadString;

PROCEDURE GetSym;
VAR z: ARRAY 200 OF CHAR;
BEGIN
  sym := null;
  REPEAT
    WHILE (c # 0X) & (c <= ' ') DO Read END;
    IF IsLetter(c) THEN ReadIdentOrKeyword
    ELSIF IsDec(c) THEN ReadNumber
    ELSIF (c = '"') OR (c = "'") THEN ReadString
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
      IF c = '*' THEN ReadComment(TRUE) ELSE sym := lparen END
    ELSIF c = ')' THEN Read; sym := rparen
    ELSIF c = '[' THEN Read; sym := lbrak
    ELSIF c = ']' THEN Read; sym := rbrak
    ELSIF c = '{' THEN Read; sym := lbrace
    ELSIF c = '}' THEN Read; sym := rbrace
    ELSIF c = ';' THEN Read; sym := semicol
    ELSIF c = '=' THEN Read; sym := equals
    ELSIF c = '^' THEN Read; sym := arrow
    ELSIF c = 0X THEN sym := eot
    ELSE Read
    END
  UNTIL sym # null
END GetSym;

(** List **)

PROCEDURE NewList(): List;
VAR L: List;
BEGIN NEW(L)
RETURN L END NewList;

PROCEDURE NewGroup(): List;
VAR G: Group;
  i: INTEGER;
BEGIN NEW(G); G.comment[0] := 0X; G.ordinalConsts := FALSE;
  i := 0; WHILE (curTitle[i] # 0X) & (curTitle[i] # '|') DO INC(i) END;
  IF curTitle[i] # 0X THEN
    Strings.Extract(curTitle, 0, i, G.name);
    Strings.Extract(curTitle, i + 1, LEN(G.comment), G.comment)
  ELSE
    Strings.Copy(curTitle, G.name);
    G.comment[0] := 0X
  END
RETURN G END NewGroup;

(** Returns object with the minimum name from a non-empty list L *)
PROCEDURE FindMinName(L: List): Object;
VAR x, min: Object;
BEGIN
  min := L.first; x := min.next;
  WHILE x # NIL DO
    IF x.name < min.name THEN min := x END;
    x := x.next
  END
RETURN min END FindMinName;

(** Returns object with the minimum ordinal value from a non-empty list L *)
PROCEDURE FindMinIntVal(L: List): Object;
VAR x, min: Object;
  val, minVal: INTEGER;
BEGIN
  min := L.first; minVal := L.first(Const).intVal; x := min.next;
  WHILE x # NIL DO val := x(Const).intVal;
    IF val < minVal THEN min := x; minVal := val END;
    x := x.next
  END
RETURN min END FindMinIntVal;

PROCEDURE AddToList(L: List; o: Object);
BEGIN
  IF L.first = NIL THEN L.first := o ELSE L.last.next := o END;
  WHILE o.next # NIL DO o := o.next END;
  L.last := o
END AddToList;

(** Removes o from list L. *)
PROCEDURE RemoveFromList(L: List; o: Object);
VAR x: Object;
BEGIN
  IF L.first = o THEN L.first := L.first.next;
    IF L.first = NIL THEN L.last := NIL END
  ELSE x := L.first;
    WHILE x.next # o DO x := x.next END;
    x.next := x.next.next;
    IF x.next = NIL THEN L.last := x END
  END;
  o.next := NIL
END RemoveFromList;

(** Moves o from list L such that L.last = o. *)
PROCEDURE MoveToEndOfList(L: List; o: Object);
BEGIN IF L.last # o THEN RemoveFromList(L, o); AddToList(L, o) END
END MoveToEndOfList;

(** Append s to dst, replacing tabs with 0AX *)
PROCEDURE JoinAndAppend(s: ARRAY OF CHAR; VAR dst: ARRAY OF CHAR);
VAR i, j: INTEGER;
BEGIN
  i := 0; j := Strings.Length(dst);
  WHILE (s[i] # 0X) & (j < LEN(dst) - 1) DO
    IF s[i] < ' ' THEN dst[j] := 0AX ELSE dst[j] := s[i] END;
    INC(i); INC(j)
  END;
  dst[j] := 0X
END JoinAndAppend;

(** If L is empty, creates a group with title = curTitle in it.
     If L is not empty and last group's title is not curTitle,
    finds it in L and moves it to the last position.
     If it is not found, creates a new group in the end of L with
    title = curTitle.
     If a group is created or moved, saves comments in the group. If there is
    more then one comment, leaves the last one in doc. If there is a single
    comment (no tabs in doc), does not touch it in case its closing star
    is on the same line or exactly one line above the current line. *)
PROCEDURE UpdateCurGroup(L: List);
VAR x: Object;
  save: BOOLEAN;
  i: INTEGER;
BEGIN x := L.first; save := TRUE;
  WHILE (x # NIL) & (x.name # curTitle) DO x := x.next END;
  IF x = NIL THEN x := NewGroup(); AddToList(L, x)
  ELSIF x.next # NIL THEN MoveToEndOfList(L, x)
  ELSE save := FALSE
  END;
  titleNotUsed := FALSE;

  IF save & (docLen # 0) THEN
    i := docLen - 1;
    WHILE (i # -1) & (doc[i] # tab) DO DEC(i) END;
    IF i # -1 THEN (* More than one comment - leave the last *)
      doc[i] := 0X; JoinAndAppend(doc, x.comment); doc[i] := tab;
      Strings.Delete(doc, 0, i + 1); DEC(docLen, i + 1)
    ELSIF line - docEndLine > 1 THEN (* Single comment *)
      JoinAndAppend(doc, x.comment); ClearComments
    END
  END
END UpdateCurGroup;

(** Printing **)

PROCEDURE PrintIndent(n: INTEGER; inlined: BOOLEAN);
BEGIN
  IF ~inlined THEN
    WHILE n > 0 DO Out.String('  '); DEC(n) END
  END
END PrintIndent;

PROCEDURE PrintComment(o: Object; indent: INTEGER);
BEGIN
  IF o.comment[0] # 0X THEN
    PrintIndent(indent, FALSE);
    Out.String('(* '); Out.String(o.comment);
    Out.String(' *)'); Out.Ln
  END
END PrintComment;

PROCEDURE PrintList(L: List; indent: INTEGER; inlined: BOOLEAN);
VAR o: Object;
BEGIN
  IF (L # NIL) & (L.first # NIL) THEN
    IF L.comment[0] # 0X THEN
      Out.String('### '); Out.String(L.comment); Out.Ln
    END;
    o := L.first;
    WHILE o # NIL DO
      PrintObject(o, indent, FALSE);
      o := o.next
    END
  ELSE PrintIndent(indent, FALSE); Out.Char('-'); Out.Ln
  END
END PrintList;

PROCEDURE PrintConst(C: Const; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  PrintIndent(indent, inlined);
  Out.String('Const '); Out.String(C.name);
  Out.String(' with value '); Out.String(C.value); Out.Ln;
  PrintComment(C, indent)
END PrintConst;

PROCEDURE PrintParam(par: Param; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  PrintIndent(indent, inlined);
  IF par.passed = byVar THEN Out.String('Variable')
  ELSIF par.passed = byValue THEN Out.String('Value')
  END;
  Out.String(' parameter '); Out.String(par.name);
  Out.String(' of '); PrintObject(par.type, indent, TRUE)
END PrintParam;

PROCEDURE PrintVar(v: Var; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  PrintIndent(indent, inlined);
  Out.String(v.name);
  Out.String(' of '); PrintObject(v.type, indent, TRUE);
  IF ~inlined & (v.comment[0] # 0X) THEN Out.Ln END;
  PrintComment(v, indent)
END PrintVar;

PROCEDURE PrintType(T: Type; indent: INTEGER; inlined: BOOLEAN);
VAR x: Object;
BEGIN
  PrintIndent(indent, inlined);
  IF T = NIL THEN Out.String('NIL')
  ELSIF T.form = namedType THEN
    Out.String('type '); Out.String(T.name);
    IF T.base # NIL THEN
      Out.String(' is '); PrintType(T.base, indent, TRUE)
    END
  ELSIF T.form = arrayType THEN
    IF T.len[0] = 0X THEN Out.String('open ') END;
    Out.String('array type ');
    IF T.len[0] # 0X THEN Out.String('with length ');
      Out.String(T.len); Out.Char(' ')
    END;
    Out.String('of '); PrintObject(T.base, indent, TRUE)
  ELSIF T.form = recordType THEN Out.String('record type ');
    IF T.base # NIL THEN Out.String('that extends ');
      Out.String(T.base.name); Out.Char(' ')
    END;
    IF T.fields.first # NIL THEN Out.String('with fields:'); Out.Ln;
      PrintList(T.fields, indent + 1, FALSE)
    ELSE Out.String('with no fields')
    END
  ELSIF T.form = procedureType THEN Out.String('procedure type ');
    IF T.fields.first # NIL THEN
      PrintIndent(indent, FALSE); Out.Char('(');
      PrintList(T.fields, indent + 1, TRUE);
      Out.String(') ')
    END;
    IF T.base # NIL THEN
      Out.String('that returns '); PrintObject(T.base, indent, TRUE)
    END
  ELSIF T.form = pointerType THEN Out.String('pointer type to ');
    PrintObject(T.base, indent, TRUE)
  ELSE Out.String('?')
  END;
  IF ~inlined THEN Out.Ln; PrintComment(T, indent) END
END PrintType;

PROCEDURE PrintProcedure(P: Procedure; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  PrintIndent(indent, inlined);
  Out.String('Procedure '); Out.String(P.name);
  IF P.returnType # NIL THEN
    Out.String(' returns '); PrintType(P.returnType, indent, TRUE)
  END;
  IF P.params.first # NIL THEN
    Out.String(', parameters:'); Out.Ln;
    PrintList(P.params, indent + 1, FALSE)
  ELSE Out.Ln
  END;
  IF ~inlined THEN Out.Ln; PrintComment(P, indent) END
END PrintProcedure;

PROCEDURE PrintModule(M: Module; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  PrintIndent(indent, inlined);
  Out.String('Module '); Out.String(M.name); Out.Ln;
  PrintComment(M, indent);
  PrintIndent(indent, FALSE);
  Out.String('Constants:'); Out.Ln; PrintList(M.consts, indent + 1, FALSE);
  PrintIndent(indent, FALSE);
  Out.String('Types:'); Out.Ln; PrintList(M.types, indent + 1, FALSE);
  PrintIndent(indent, FALSE);
  Out.String('Variables:'); Out.Ln; PrintList(M.vars, indent + 1, FALSE);
  PrintIndent(indent, FALSE);
  Out.String('Procedures:'); Out.Ln; PrintList(M.procedures, indent + 1, FALSE)
END PrintModule;

PROCEDURE PrintObject0(o: Object; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  IF o = NIL THEN PrintIndent(indent, inlined); Out.String('NIL')
  ELSIF o IS Module THEN PrintModule(o(Module), indent, inlined)
  ELSIF o IS Var THEN PrintVar(o(Var), indent, inlined)
  ELSIF o IS Const THEN PrintConst(o(Const), indent, inlined)
  ELSIF o IS Type THEN PrintType(o(Type), indent, inlined)
  ELSIF o IS Procedure THEN PrintProcedure(o(Procedure), indent, inlined)
  ELSIF o IS Param THEN PrintParam(o(Param), indent, inlined)
  ELSIF o IS List THEN PrintList(o(List), indent, inlined)
  ELSE PrintIndent(indent, inlined); Out.String('?')
  END;
  IF ~inlined THEN Out.Ln END
END PrintObject0;

PROCEDURE Print*(o: Object);
BEGIN PrintObject(o, 0, FALSE)
END Print;

(** Object **)

PROCEDURE InitObject(o: Object);
BEGIN o.name[0] := 0X; o.comment[0] := 0X; o.next := NIL; o.exported := FALSE
END InitObject;

(** Sets exported field of object to TRUE or FALSE
    and skips the star (or minus) mark. *)
PROCEDURE CheckExportMark(o: Object);
BEGIN
  IF (sym = times) OR (sym = minus) THEN GetSym; o.exported := TRUE
  ELSE o.exported := FALSE
  END;
  objectIsExported := o.exported
END CheckExportMark;

(** Skips compiler directives such as [notag]
    after POINTER, ARRAY and RECORD symbols.
     Does not change o in any way (yet). *)
PROCEDURE CheckDirective(o: Object);
BEGIN
  IF sym = lbrak THEN GetSym;
    IF (sym = ident) OR (sym = int) THEN GetSym;
      IF sym = rbrak THEN GetSym END
    END
  END
END CheckDirective;

(** Finds import with the given alias in curModule. If parameter exported
    is TRUE, marks the import object as exported. Depending on keepAliases,
    on may replace value of VAR-parameter name from with the real name of
    the imported module. *)
PROCEDURE CheckImportedModule(VAR name: ARRAY OF CHAR; exported: BOOLEAN);
VAR x: Object;
BEGIN
  x := curModule.imports.first;
  WHILE (x # NIL) & (x(Import).alias # name) DO x := x.next END;
  IF x # NIL THEN
    IF exported THEN x.exported := TRUE END;
    IF ~keepAliases THEN Strings.Copy(x.name, name) END
  ELSE Mark3('Module "', name, '" not imported.')
  END
END CheckImportedModule;

(** Type **)

PROCEDURE NewType(form: INTEGER): Type;
VAR T: Type;
BEGIN NEW(T); T.form := form; T.len[0] := 0X; T.base := NIL
RETURN T END NewType;

(** Param **)

PROCEDURE NewParam(passed: INTEGER): Param;
VAR par: Param;
BEGIN NEW(par); InitObject(par); par.passed := passed; Strings.Copy(id, par.name)
RETURN par END NewParam;

(** Import **)

PROCEDURE NewImport(): Import;
VAR I: Import;
BEGIN NEW(I); InitObject(I); Strings.Copy(id, I.name)
RETURN I END NewImport;

(** Const **)

PROCEDURE NewConst(): Const;
VAR C: Const;
BEGIN NEW(C); InitObject(C); Strings.Copy(id, C.name);
  C.isOrdinal := FALSE; C.intVal := 0
RETURN C END NewConst;

(** Var **)

PROCEDURE NewVar(): Var;
VAR v: Var;
BEGIN NEW(v); InitObject(v); Strings.Copy(id, v.name)
RETURN v END NewVar;

(** Parser **)

PROCEDURE ConstructString(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
  x: CHAR;
BEGIN i := 0; x := id[0];
  WHILE (x # 0X) & (x # "'") DO INC(i); x := id[i] END;
  IF x # 0X THEN x := '"' ELSE x := "'" END;
  s[0] := x; i := 0;
  WHILE id[i] # 0X DO s[i + 1] := id[i]; INC(i) END;
  s[i + 1] := x; s[i + 2] := 0X 
END ConstructString;

PROCEDURE ConstructChar(VAR s: ARRAY OF CHAR);
VAR i, n: INTEGER;
  x: CHAR;
BEGIN n := ival; i := 0;
  REPEAT s[i] := ToHex(n MOD 16); n := n DIV 16; INC(i) UNTIL n = 0;
  s[i] := 'X'; s[i + 1] := 0X; DEC(i);
  WHILE n < i DO x := s[i]; s[i] := s[n]; s[n] := x; INC(n); DEC(i) END
END ConstructChar;

(** Reads const expression character by character, beginning with the
    character at position constExprBeginPos and up to but not including
    the next ';', comma or 'OF'. If end of text is reached, makes s empty.
    Puts in s the string that has been read. Sets isOrdinal to TRUE if
    the value is an integer number or a character literal, sets it to FALSE
    otherwise. If isOrdinal becomes TRUE, then the copy of the const value is
    cast to integer and stored in intVal. *)
PROCEDURE ParseConstExpr(VAR s: ARRAY OF CHAR;
    VAR isOrdinal: BOOLEAN; VAR intVal: INTEGER);
VAR start, end, i: INTEGER;
  x, tmpC: CHAR;
BEGIN isOrdinal := FALSE; intVal := 0; i := 0; x := constExprBeginC;
  REPEAT end := Files.Pos(R); tmpC := c; GetSym
  UNTIL (sym = semicol) OR (sym = of) OR (sym = eot) OR (sym = comma);
  IF sym # eot THEN
    IF constExprBeginPos < end THEN
      IF x > ' ' THEN s[i] := x; INC(i) END;
      Files.Set(R, Files.Base(R), constExprBeginPos);
      REPEAT
        Files.ReadChar(R, x);
        IF x < ' ' THEN x := ' ' END;
        IF (i < LEN(s) - 1) & ((x # ' ') OR (i # 0) & (s[i - 1] # ' ')) THEN
          s[i] := x; INC(i)
        END
      UNTIL Files.Pos(R) >= end;
      IF i > 0 THEN DEC(i) END
    END;
    Files.Set(R, Files.Base(R), end); c := tmpC;
    IF col # 0 THEN DEC(col) END;
    GetSym
  END;
  WHILE (i # 1) & (s[i - 1] <= ' ') DO DEC(i) END;
  s[i] := 0X
END ParseConstExpr;

PROCEDURE ParseVars(isVarDecl: BOOLEAN): List;
VAR first, v: Var;
  L: List;
  x: Object;
  passed, line2: INTEGER;
  T: Type;
  stop, added: BOOLEAN;
BEGIN L := NewList(); stop := FALSE;
  WHILE ~stop & (sym = ident) DO Debug(id);
    IF isVarDecl THEN UpdateCurGroup(L) END;
    first := NewVar(); SaveAllComments(first); GetSym; CheckExportMark(first);
    IF first.exported OR ~exportedOnly THEN
      IF isVarDecl THEN AddToList(L.last(List), first)
      ELSE AddToList(L, first)
      END;
      added := TRUE
    ELSE added := FALSE; first := NIL
    END;
    WHILE sym = comma DO GetSym;
      IF sym = ident THEN v := NewVar(); GetSym; CheckExportMark(v);
        IF v.exported OR ~exportedOnly THEN
          IF isVarDecl THEN AddToList(L.last(List), v)
          ELSE AddToList(L, v)
          END;
          IF ~added THEN first := v; added := TRUE END
        END
      ELSE MarkExp('variable (field) name')
      END
    END;
    IF sym = colon THEN GetSym ELSE MarkExp(':') END;
    T := ParseType(NIL);
    IF first # NIL THEN
      first.type := T; x := first.next;
      WHILE x # NIL DO x(Var).type := T; x := x.next END
    END;
    IF (sym = semicol) OR ~isVarDecl THEN line2 := line;
      IF sym = semicol THEN GetSym; SaveComment(first, line2)
      ELSE stop := TRUE; SaveAllComments(first)
      END;
      IF (first # NIL) & (first.comment[0] # 0X) THEN x := first.next;
        WHILE x # NIL DO
          Strings.Copy(first.comment, x.comment); x := x.next
        END
      END
    ELSE MarkExp(';')
    END
  END;
RETURN L END ParseVars;

(** Sets C.isOrdinal to TRUE if C.value is a single character literal in
    the form of 'x', "x" or 4AX or if C.value is an integer (dec, hex). *)
PROCEDURE CheckOrdinal(C: Const);
VAR x: CHAR;

  PROCEDURE IsInt(s: ARRAY OF CHAR; VAR val: INTEGER): BOOLEAN;
  VAR i, start: INTEGER;
    minus, ok: BOOLEAN;
    end: CHAR;
  BEGIN val := 0; start := 0; minus := FALSE; ok := TRUE;
    IF s[0] = '-' THEN minus := TRUE; start := 1
    ELSIF s[0] = '+' THEN start := 1
    END;
    i := start;
    WHILE IsHex(s[i]) DO INC(i) END; end := s[i];
    IF ((end = 'X') OR (end = 'H')) & (s[i + 1] = 0X) THEN i := 0;
      WHILE s[i] # end DO val := val * 16 + FromHex(s[i]); INC(i) END
    ELSIF s[i] = 0X THEN i := 0;
      WHILE s[i] # end DO val := val * 10 + ORD(s[i]) - ORD('0'); INC(i) END
    ELSE ok := FALSE
    END;
    IF minus THEN val := -val END
  RETURN ok & (s[0] # 0X) END IsInt;

BEGIN
  IF ~C.isOrdinal THEN x := C.value[0];
    (* Literal char 'x' or "x" *)
    IF ((x = '"') OR (x = "'")) & (C.value[1] # 0X) & (C.value[2] = x) THEN
      C.isOrdinal := TRUE; C.intVal := ORD(C.value[1])
    ELSIF IsInt(C.value, C.intVal) THEN C.isOrdinal := TRUE
    END
  END
END CheckOrdinal;

PROCEDURE ParseConstDecl(M: Module);
VAR C: Const;
  line2: INTEGER;
  isInt: BOOLEAN;
BEGIN curTitle := '-';
  IF sym = const THEN GetSym;
    WHILE sym = ident DO Debug(id);
      UpdateCurGroup(M.consts);
      C := NewConst();

      (* Сохранить все комментарии *)
      SaveComment(C, -1);

      GetSym; CheckExportMark(C);
      IF C.exported OR ~exportedOnly THEN
        AddToList(M.consts.last(List), C)
      END;
      constExprBeginPos := Files.Pos(R); constExprBeginC := c;
      IF sym = equals THEN GetSym ELSE MarkExp('=') END;
      ParseConstExpr(C.value, C.isOrdinal, C.intVal); CheckOrdinal(C);
      line2 := line;
      IF sym = semicol THEN GetSym ELSE MarkExp(';') END;

      (* СОХРАНИТЬ ВСЕ КОММЕНТАРИИ ДО [ВЕРТ.ТАБА, если он есть, иначе до ТАБА],
         ЕСЛИ (line2 совпадает) ИЛИ (у C нет комментария) *)
      SaveComment(C, line2)
    END
  END
END ParseConstDecl;

PROCEDURE ParseTypeDecl(M: Module);
VAR T: Type;
  line2: INTEGER;
BEGIN
  IF sym = type THEN GetSym;
    WHILE sym = ident DO Debug(id);
      UpdateCurGroup(M.types);
      T := NewType(namedType); SaveAllComments(T);
      Strings.Copy(id, T.name); GetSym; CheckExportMark(T);
      IF sym = equals THEN GetSym ELSE MarkExp('=') END;
      T.base := ParseType(T); line2 := line;
      IF sym = semicol THEN GetSym ELSE MarkExp(';') END;
      IF ~exportedOnly OR T.exported THEN
        AddToList(M.types.last(List), T)
      END;
      SaveComment(T, line2)
    END
  END
END ParseTypeDecl;

PROCEDURE ParseNamedType(): Type;
VAR T: Type;
BEGIN
  IF sym = ident THEN
    T := NewType(namedType);
    Strings.Copy(id, T.name); GetSym;
    IF sym = period THEN GetSym;
      IF sym = ident THEN
        CheckImportedModule(T.name, objectIsExported);
        Strings.Append('.', T.name); Strings.Append(id, T.name); GetSym
      ELSE MarkExp('identifier')
      END
    END
  ELSE T := NIL; MarkExp('type identifier')
  END
RETURN T END ParseNamedType;

PROCEDURE ParseArrayType(): Type;
VAR T, T1: Type;
  isInt: BOOLEAN;
  tmp: INTEGER;
BEGIN ASSERT(sym = array);
  constExprBeginPos := Files.Pos(R); constExprBeginC := c; GetSym;
  T := NewType(arrayType); T1 := T; CheckDirective(T);
  IF (sym # of) THEN
    ParseConstExpr(T.len, isInt, tmp)
  END;
  WHILE sym = comma DO
    constExprBeginPos := Files.Pos(R); constExprBeginC := c; GetSym;
    T1.base := NewType(arrayType); T1 := T1.base;
    ParseConstExpr(T1.len, isInt, tmp)
  END;
  IF sym = of THEN GetSym ELSE MarkExp('OF') END;
  T1.base := ParseType(NIL)
RETURN T END ParseArrayType;

PROCEDURE ParseRecordType(docObj: Object): Type;
VAR T: Type;
  line2: INTEGER;
BEGIN ASSERT(sym = record); line2 := line; GetSym;
  T := NewType(recordType); CheckDirective(T);
  IF sym = lparen THEN GetSym; T.base := ParseNamedType();
    IF sym = rparen THEN GetSym ELSE MarkExp(')') END
  END;
  SaveComment(docObj, line2);
  T.fields := ParseVars(FALSE);
  IF sym = end THEN GetSym ELSE MarkExp('END') END
RETURN T END ParseRecordType;

PROCEDURE ParsePointerType(docObj: Object): Type;
VAR T: Type;
BEGIN ASSERT(sym = pointer); GetSym;
  T := NewType(pointerType); CheckDirective(T);
  IF sym = to THEN GetSym ELSE MarkExp('TO') END;
  T.base := ParseType(docObj)
RETURN T END ParsePointerType;

PROCEDURE ParseFormalParamSection(L: List);
VAR first, par: Param;
  x: Object;
  T: Type;
  passed: INTEGER;
BEGIN
  IF (sym = var) OR (sym = in) OR (sym = out) THEN GetSym; passed := byVar;
    IF sym = lbrak THEN GetSym;
      IF (sym = ident) OR (sym = int) THEN GetSym ELSE MarkExp('hint') END;
      IF sym = rbrak THEN GetSym ELSE MarkExp(']') END
    END
  ELSE passed := byValue
  END;

  IF sym = ident THEN first := NewParam(passed); GetSym;
    AddToList(L, first);
    WHILE sym = comma DO GetSym;
      IF sym = ident THEN par := NewParam(passed); GetSym;
        AddToList(L, par)
      ELSE MarkExp('parameter name')
      END
    END
  ELSE first := NIL; MarkExp('parameter name')
  END;
  IF sym = colon THEN GetSym; T := ParseParamType();
    IF first # NIL THEN
      first.type := T;
      x := first.next;
      WHILE x # NIL DO x(Param).type := T; x := x.next END
    END
  ELSE MarkExp(':')
  END
END ParseFormalParamSection;

PROCEDURE ParseProcedureType(): Type;
VAR T: Type;
BEGIN ASSERT(sym = procedure); GetSym;
  T := NewType(procedureType); T.fields := NewList();
  IF sym = lparen THEN GetSym;
    IF sym # rparen THEN ParseFormalParamSection(T.fields);
      WHILE sym = semicol DO GetSym; ParseFormalParamSection(T.fields) END
    END;
    IF sym = rparen THEN GetSym ELSE MarkExp(')') END;
    IF sym = colon THEN GetSym; T.base := ParseNamedType() END
  END;
  (*!TODO*)
RETURN T END ParseProcedureType;

PROCEDURE ParseParamType0(): Type;
VAR T: Type;
BEGIN
  IF sym = array THEN T := ParseArrayType()
  ELSIF sym = ident THEN T := ParseNamedType()
  ELSIF sym = procedure THEN T := ParseProcedureType()
  ELSE T := NIL; MarkExp('type')
  END
RETURN T END ParseParamType0;

PROCEDURE ParseType0(docObj: Object): Type;
VAR T: Type;
BEGIN
  IF sym = array THEN T := ParseArrayType()
  ELSIF sym = record THEN T := ParseRecordType(docObj)
  ELSIF sym = pointer THEN T := ParsePointerType(docObj)
  ELSIF sym = procedure THEN T := ParseProcedureType()
  ELSIF sym = ident THEN T := ParseNamedType()
  ELSE T := NIL; MarkExp('type')
  END
RETURN T END ParseType0;

(** Reads input stream until "END name" is found.
    Stops on "name" (sym = ident), or sym = eot *)
PROCEDURE ReachEndOf(name: ARRAY OF CHAR);
BEGIN
  REPEAT
    WHILE (sym # eot) & (sym # end) DO GetSym END;
    IF sym = end THEN GetSym END
  UNTIL (sym = eot) OR (sym = ident) & (id = name)
END ReachEndOf;

PROCEDURE ParseProcedureDecl(M: Module);
VAR name: Str;
  P: Procedure;
  forward, foreign: BOOLEAN;
BEGIN
  IF ~titleNotUsed THEN curTitle := '-' END;
  WHILE sym = procedure DO UpdateCurGroup(M.procedures);
    NEW(P); InitObject(P); SaveComment(P, -1); GetSym; foreign := FALSE;
    forward := FALSE; P.params := NewList(); P.exported := FALSE;
    IF (sym = minus) OR (sym = arrow) THEN GetSym; forward := TRUE;
    ELSIF sym = times THEN GetSym
    END;
    IF sym = ident THEN Strings.Copy(id, P.name); GetSym
    ELSE MarkExp('procedure name')
    END;
    IF (sym = minus) OR (sym = arrow) THEN GetSym END;
    IF sym = times THEN GetSym; P.exported := TRUE END;
    IF sym = lbrak THEN GetSym; (* Foreign name *)
      foreign := TRUE;
      IF sym = string THEN GetSym ELSE MarkExp('foreign name of procedure') END;
      IF sym = rbrak THEN GetSym ELSE MarkExp(']') END
    END;
    IF sym = lparen THEN GetSym;
      IF sym # rparen THEN ParseFormalParamSection(P.params);
        WHILE sym = semicol DO GetSym; ParseFormalParamSection(P.params) END
      END;
      IF sym = rparen THEN GetSym ELSE MarkExp(')') END;
      IF sym = colon THEN GetSym; P.returnType := ParseNamedType() END
    END;
    IF sym = string THEN GetSym END; (* Foreign code *)
    IF sym = semicol THEN GetSym ELSE MarkExp(';') END;
    IF ~forward & ~foreign THEN
      ReachEndOf(P.name); SaveComment(P, -1);
      IF sym = ident THEN GetSym;
        IF sym = semicol THEN GetSym ELSE MarkExp(';') END
      ELSE (* sym = eot *) MarkEnd('Procedure', P.name)
      END;
      IF P.exported OR ~exportedOnly THEN AddToList(M.procedures.last(List), P) END
    END
  END
END ParseProcedureDecl;

PROCEDURE ParseVarDecl(M: Module);
BEGIN ASSERT(sym = var); curTitle := '-';
  GetSym; M.vars := ParseVars(TRUE)
END ParseVarDecl;

PROCEDURE Declarations(M: Module);
BEGIN
  titleNotUsed := TRUE;
  IF sym = const THEN ParseConstDecl(M) END;
  IF sym = type THEN ParseTypeDecl(M) END;
  IF sym = var THEN ParseVarDecl(M) END;
  ParseProcedureDecl(M)
END Declarations;

PROCEDURE ParseImport(M: Module);
VAR I: Import;
BEGIN
  IF sym = ident THEN
    I := NewImport(); GetSym;
    Strings.Copy(I.name, I.alias);
    IF sym = becomes THEN GetSym;
      Strings.Copy(id, I.name); GetSym
    END;
    AddToList(M.imports, I)
  END
END ParseImport;

PROCEDURE ParseImportList(M: Module);
BEGIN
  IF sym = import THEN
    GetSym; ParseImport(M);
    WHILE sym = comma DO GetSym; ParseImport(M) END;
    IF sym = semicol THEN GetSym ELSE MarkExp(';') END
  END
END ParseImportList;

PROCEDURE CleanImportList(M: Module);
VAR x, next: Object;
BEGIN
  x := M.imports.first;
  WHILE x # NIL DO next := x.next;
    IF ~x.exported THEN RemoveFromList(M.imports, x)
    ELSIF ~keepAliases THEN Strings.Copy(x.name, x(Import).alias)
    END;
    x := next
  END
END CleanImportList;

PROCEDURE FindMin(G: Group; ordinal: BOOLEAN): Object;
VAR x: Object;
BEGIN
  IF ordinal THEN x := FindMinIntVal(G) ELSE x := FindMinName(G) END
RETURN x END FindMin;

PROCEDURE GroupCheckOrdinalConsts(G: Group);
VAR x: Object;
BEGIN
  IF (G.name[0] # 0X) & (G.first # NIL) & (G.first IS Const) THEN x := G.first;
    WHILE (x # NIL) & x(Const).isOrdinal DO x := x.next END;
    G.ordinalConsts := x = NIL
  ELSE G.ordinalConsts := FALSE
  END
END GroupCheckOrdinalConsts;

PROCEDURE SortGroup(G: Group);
VAR x: Object;
  L: List;
  ordinal: BOOLEAN;
BEGIN
  IF G.first # NIL THEN L := NewList();
    GroupCheckOrdinalConsts(G);
    WHILE G.first # NIL DO
      x := FindMin(G, G.ordinalConsts);
      RemoveFromList(G, x);
      AddToList(L, x)
    END;
    G.first := L.first; G.last := L.last
  END
END SortGroup;

PROCEDURE SortGroups(L: List);
VAR x: Object;
  common: Group;
BEGIN 
  IF (L # NIL) & (L.first # NIL) THEN
    common := NIL; x := L.first;
    WHILE x # NIL DO
      SortGroup(x(Group));
      IF x.name = '-' THEN common := x(Group) END;
      x := x.next
    END;
    IF (common # NIL) & (common # L.first) THEN
      x := L.first; WHILE x.next # common DO x := x.next END;
      x.next := common.next;
      common.next := L.first;
      L.first := common
    END
  END
END SortGroups;

PROCEDURE SortModule(M: Module);
BEGIN
  SortGroups(M.consts);
  SortGroups(M.vars);
  SortGroups(M.types);
  SortGroups(M.procedures)
END SortModule;

PROCEDURE ParseModule*(VAR r: Files.Rider; VAR err: ARRAY OF CHAR): Module;
VAR M: Module;
BEGIN NEW(M); InitObject(M); curModule := M;
  M.foreign := FALSE; M.exportedOnly := exportedOnly;
  M.imports := NewList(); M.consts := NewList();
  M.types := NewList(); M.vars := NewList(); M.procedures := NewList();
  R := r; c := 0X; line := 1; col := 0; lastError := -1;
  objectIsExported := FALSE;
  Read; ClearComments; curTitle := '-'; GetSym;
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
    ParseImportList(M);
    SaveAllComments(M);
    Declarations(M);
    IF sym = begin THEN
      REPEAT GetSym UNTIL (sym = eot) OR (sym = end)
    END;
    ReachEndOf(M.name);
    IF sym = ident THEN GetSym;
      IF sym # period THEN MarkExp('.') END
    ELSE (* sym = eot *) MarkEnd('Module', M.name)
    END
  ELSE MarkExp('MODULE')
  END;
  IF exportedOnly THEN CleanImportList(M) END;
  IF lastError = -1 THEN SortModule(M)
  ELSE M := NIL; err := 'Error' (*!FIXME*)
  END
RETURN M END ParseModule;

BEGIN
  PrintObject := PrintObject0;
  ParseType := ParseType0;
  ParseParamType := ParseParamType0;

  curFname[0] := 0X; debug := FALSE;
  exportedOnly := TRUE; keepAliases := FALSE
END AutodocParser.
