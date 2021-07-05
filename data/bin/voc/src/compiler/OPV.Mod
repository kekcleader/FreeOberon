(* OPV - parse tree traverser (back end) *)
MODULE OPV;  (* J. Templ 16.2.95 / 3.7.96

  26.7.2002 jt bug fix OPS.in Len: wrong result if called for fixed OPT.Array
  31.1.2007 jt synchronized with BlackBox version, in particular:
    various promotion rules changed (long) => (LONGINT), xxxL avoided
*)

  IMPORT OPT, OPC, OPM, OPS, SYSTEM;

  CONST
    UndefinedType  = 0; (* named type not yet defined *)
    ProcessingType = 1; (* pointer type is being processed *)
    PredefinedType = 2; (* for all predefined types *)
    DefinedInHdr   = 3+OPM.HeaderFile; (* named type has been defined in header file *)
    DefinedInBdy   = 3+OPM.BodyFile; (* named type has been defined in body file *)

    OpenParen    = "(";
    CloseParen   = ")";
    OpenBracket  = "[";
    CloseBracket = "]";
    Blank        = " ";
    Comma        = ", ";
    Deref        = "*";
    EntierFunc   = "__ENTIER(";
    FloorFunc    = "__FLOOR(";
    IsFunc       = "__IS(";
    IsPFunc      = "__ISP(";
    GuardPtrFunc = "__GUARDP(";
    GuardRecFunc = "__GUARDR(";
    TypeFunc     = "__TYPEOF(";
    CopyFunc     = "__COPY(";
    MoveFunc     = "__MOVE(";
    GetFunc      = "__GET(";
    PutFunc      = "__PUT(";
    DynTypExt    = "__typ";
    WithChk      = "__WITHCHK";
    Break        = "break";
    ElseStat     = "else ";

    MinPrec     = -1;
    MaxPrec     = 12;
    ProcTypeVar = 11; (* precedence number when a call is made with a proc type variable *)


  TYPE
    ExitInfo = RECORD level, label: INTEGER END ;


  VAR
    stamp: INTEGER;  (* unique number for nested objects *)

    exit: ExitInfo;  (* to check if EXIT is simply a break *)
    nofExitLabels: INTEGER;


  PROCEDURE Init*;
  BEGIN
    stamp := 0; nofExitLabels := 0;
  END Init;

  PROCEDURE ^Traverse (obj, outerScope: OPT.Object; exported: BOOLEAN);

  PROCEDURE GetTProcNum(obj: OPT.Object);
    VAR oldPos: LONGINT; typ: OPT.Struct; redef: OPT.Object;
  BEGIN
    oldPos := OPM.errpos; OPM.errpos := obj^.scope^.adr;
    typ := obj^.link^.typ;
    IF typ^.form = OPT.Pointer THEN typ := typ^.BaseTyp END ;
    OPT.FindField(obj^.name, typ^.BaseTyp, redef);
    IF redef # NIL THEN obj^.adr := 10000H*(redef^.adr DIV 10000H) (*mthno*);
      IF ~(OPT.isRedef IN obj^.conval^.setval) THEN OPM.err(119) END
    ELSE INC(obj^.adr, 10000H*typ^.n); INC(typ^.n)
    END ;
    OPM.errpos := oldPos
  END GetTProcNum;

  PROCEDURE TraverseRecord(typ: OPT.Struct);
  BEGIN
    IF ~typ^.allocated THEN
      IF typ^.BaseTyp # NIL THEN TraverseRecord(typ^.BaseTyp); typ^.n := typ^.BaseTyp^.n END ;
       typ^.allocated := TRUE; Traverse(typ^.link, typ^.strobj, FALSE)
    END
  END TraverseRecord;

  PROCEDURE Stamp(VAR s: OPS.Name);
    VAR i, j, k: INTEGER; n: ARRAY 10 OF CHAR;
  BEGIN INC(stamp);
    i := 0; j := stamp;
    WHILE s[i] # 0X DO INC(i) END ;
    IF i > 25 THEN i := 25 END ;
    s[i] := "_"; s[i+1] := "_"; INC(i, 2); k := 0;
    REPEAT n[k] := CHR((j MOD 10) + ORD("0")); j := j DIV 10; INC(k) UNTIL j = 0;
    REPEAT DEC(k); s[i] := n[k]; INC(i) UNTIL k = 0;
    s[i] := 0X;
  END Stamp;

  PROCEDURE Traverse (obj, outerScope: OPT.Object; exported: BOOLEAN);
    VAR mode: INTEGER; scope: OPT.Object; typ: OPT.Struct;
  BEGIN
    IF obj # NIL THEN
      Traverse(obj^.left, outerScope, exported);
      IF obj^.name[0] = "@" THEN obj^.name[0] := "_"; Stamp(obj^.name) END ;  (* translate and make unique @for, ... *)
      obj^.linkadr := UndefinedType;
      mode := obj^.mode;
      IF (mode = OPT.Typ) & ((obj^.vis # OPT.internal) = exported) THEN
        typ := obj^.typ; OPT.TypSize(obj^.typ);
        IF typ^.form = OPT.Pointer THEN typ := typ^.BaseTyp END ;
        IF typ^.comp = OPT.Record THEN TraverseRecord(typ) END
      ELSIF mode = OPT.TProc THEN GetTProcNum(obj)
      ELSIF mode = OPT.Var THEN OPT.TypSize(obj^.typ)
      END ;
      IF ~exported THEN (* do this only once *)
        IF (mode IN {OPT.LProc, OPT.Typ}) & (obj^.mnolev > 0) THEN Stamp(obj^.name) END ;
        IF mode IN {OPT.Var, OPT.VarPar, OPT.Typ} THEN
          obj^.scope := outerScope
        ELSIF mode IN {OPT.LProc, OPT.XProc, OPT.TProc, OPT.CProc, OPT.IProc} THEN
          IF obj^.conval^.setval = {} THEN OPM.err(129) END ;
          scope := obj^.scope;
          scope^.leaf := TRUE;
          scope^.name := obj^.name; Stamp(scope^.name);
          IF mode = OPT.CProc THEN obj^.adr := 1 (* c.f. OPC.CProcDefs *) END ;
          IF scope^.mnolev > 1 THEN outerScope^.leaf := FALSE END ;
          Traverse (obj^.scope^.right, obj^.scope, FALSE)
        END
      END;
      Traverse(obj^.right, outerScope, exported);
    END
  END Traverse;

  PROCEDURE AdrAndSize* (topScope: OPT.Object);
  BEGIN
    ASSERT(OPT.sinttyp # NIL); ASSERT(OPT.inttyp # NIL); ASSERT(OPT.linttyp # NIL);

    OPM.errpos := topScope^.adr;  (* text position of scope used if error *)
    topScope^.leaf := TRUE;
    Traverse(topScope^.right, topScope, TRUE);  (* first pass only on exported types and procedures  *)
    Traverse(topScope^.right, topScope, FALSE);  (* second pass *)

    (* mark basic types as predefined, OPC.Ident can avoid qualification*)
    OPT.chartyp^.strobj^.linkadr   := PredefinedType;
    OPT.cpbytetyp^.strobj^.linkadr := PredefinedType;
    OPT.settyp^.strobj^.linkadr    := PredefinedType;
    OPT.realtyp^.strobj^.linkadr   := PredefinedType;
    OPT.adrtyp^.strobj^.linkadr    := PredefinedType;
    OPT.int8typ^.strobj^.linkadr   := PredefinedType;
    OPT.int16typ^.strobj^.linkadr  := PredefinedType;
    OPT.int32typ^.strobj^.linkadr  := PredefinedType;
    OPT.int64typ^.strobj^.linkadr  := PredefinedType;
    OPT.set32typ^.strobj^.linkadr  := PredefinedType;
    OPT.set64typ^.strobj^.linkadr  := PredefinedType;
    OPT.hinttyp.strobj.linkadr     := PredefinedType;
    OPT.lrltyp^.strobj^.linkadr    := PredefinedType;
    OPT.booltyp^.strobj^.linkadr   := PredefinedType;
    OPT.bytetyp^.strobj^.linkadr   := PredefinedType;
    OPT.sysptrtyp^.strobj^.linkadr := PredefinedType;
  END AdrAndSize;

(* ____________________________________________________________________________________________________________________________________________________________________ *)

  PROCEDURE Precedence (class, subclass, form, comp: INTEGER): INTEGER;
  BEGIN
    CASE class OF
    | OPT.Nconst,
      OPT.Nvar,
      OPT.Nfield,
      OPT.Nindex,
      OPT.Nproc,
      OPT.Ncall:   RETURN 10
    | OPT.Nguard:  IF OPM.typchk IN OPM.Options THEN RETURN 10 ELSE RETURN 9 (*cast*) END
    | OPT.Nvarpar: IF comp IN {OPT.Array, OPT.DynArr} THEN RETURN 10 ELSE RETURN 9 END (* arrays don't need deref *)
    | OPT.Nderef:  RETURN 9
    | OPT.Nmop:    CASE subclass OF
                   | OPS.not, OPS.minus, OPT.adr, OPT.val, OPT.conv: RETURN 9
                   | OPS.is, OPT.abs, OPT.cap, OPT.odd, OPT.cc:      RETURN 10
                   ELSE OPM.LogWStr("unhandled case in OPV.Precedence OPT.Nmop, subclass = "); OPM.LogWNum(subclass, 0); OPM.LogWLn;
                   END
    | OPT.Ndop:    CASE subclass OF
                   | OPS.times: IF form = OPT.Set THEN RETURN 4 ELSE RETURN 8 END
                   | OPS.slash: IF form = OPT.Set THEN RETURN 3 ELSE RETURN 8 END
                   | OPS.div,
                     OPS.mod:   RETURN 10 (* div/mod are replaced by functions *)
                   | OPS.plus:  IF form = OPT.Set THEN RETURN 2 ELSE RETURN 7 END
                   | OPS.minus: IF form = OPT.Set THEN RETURN 4 ELSE RETURN 7 END
                   | OPS.lss,
                     OPS.leq,
                     OPS.gtr,
                     OPS.geq:   RETURN 6
                   | OPS.eql,
                     OPS.neq:   RETURN 5
                   | OPS.and:   RETURN 1
                   | OPS.or:    RETURN 0
                   | OPT.len,
                     OPS.in,
                     OPT.ash,
                     OPT.msk,
                     OPT.bit,
                     OPT.lsh,
                     OPT.rot:   RETURN 10
      	           ELSE OPM.LogWStr("unhandled case in OPV.Precedence OPT.Ndop, subclass = "); OPM.LogWNum(subclass, 0); OPM.LogWLn;
                   END;
    | OPT.Nupto:   RETURN 10
    | OPT.Ntype,
      OPT.Neguard: (* ignored anyway *) RETURN MaxPrec
    ELSE OPM.LogWStr("unhandled case in OPV.Precedence, class = "); OPM.LogWNum(class, 0); OPM.LogWLn;
    END;
  END Precedence;

  PROCEDURE^ expr  (n: OPT.Node; prec: INTEGER);
  PROCEDURE^ design(n: OPT.Node; prec: INTEGER);

  PROCEDURE Len(n: OPT.Node; dim: SYSTEM.INT64);
  VAR
    d: SYSTEM.INT64; array: OPT.Struct;
  BEGIN
    WHILE (n^.class = OPT.Nindex) & (n^.typ^.comp = OPT.DynArr(*26.7.2002*)) DO INC(dim); n := n^.left END ;
    IF (n^.class = OPT.Nderef) & (n^.typ^.comp = OPT.DynArr) THEN
	  d := dim; array := n^.typ;
	  WHILE d > 0 DO array := array^.BaseTyp; DEC(d) END;
	  IF array^.comp = OPT.DynArr THEN
        design(n^.left, 10); OPM.WriteString("->len["); OPM.WriteInt(dim); OPM.Write("]")
	  ELSE
        OPM.WriteInt(array^.n)
	  END
    ELSE
      OPC.Len(n^.obj, n^.typ, dim)
    END
  END Len;

  PROCEDURE SideEffects(n: OPT.Node): BOOLEAN;
  BEGIN
    IF n # NIL THEN RETURN (n^.class = OPT.Ncall) OR SideEffects(n^.left) OR SideEffects(n^.right)
    ELSE RETURN FALSE
    END
  END SideEffects;

  PROCEDURE Entier(n: OPT.Node; prec: INTEGER);
  BEGIN
    IF n^.typ^.form IN {OPT.Real, OPT.LReal} THEN
      OPM.WriteString(EntierFunc); expr(n, MinPrec); OPM.Write(CloseParen)
    ELSE expr(n, prec)
    END
  END Entier;

  PROCEDURE SizeCast(n: OPT.Node; to: LONGINT);
  BEGIN
    IF (to < n.typ.size) & (OPM.ranchk IN OPM.Options) THEN
      OPM.WriteString("__SHORT"); IF SideEffects(n) THEN OPM.Write("F") END;
      OPM.Write(OpenParen); Entier(n, MinPrec); OPM.WriteString(Comma);
      OPM.WriteInt(OPM.SignedMaximum(to) + 1); OPM.Write(CloseParen)
    ELSE
      IF (n.typ.size # to) & ((n.typ.size > OPM.CIntSize) OR (to # OPM.CIntSize)) THEN
        OPM.WriteString("(INT"); OPM.WriteInt(to*8); OPM.WriteString(")")
      END;
      Entier(n, 9)
    END
  END SizeCast;

  PROCEDURE Convert(n: OPT.Node; newtype: OPT.Struct; prec: INTEGER);
    VAR from, to: INTEGER;
  BEGIN from := n^.typ^.form; to := newtype.form;
    IF to = OPT.Set THEN
      IF from = OPT.Set THEN (* Sets of different size *)
        SizeCast(n, newtype.size);
      ELSE (* Set from integer *)
        OPM.WriteString("__SETOF("); Entier(n, MinPrec);
        OPM.WriteString(","); OPM.WriteInt(newtype.size*8); OPM.Write(CloseParen)
      END
    ELSIF to = OPT.Int THEN (* integers of different size *)
      SizeCast(n, newtype.size);
    ELSIF to = OPT.Char THEN
      IF OPM.ranchk IN OPM.Options THEN OPM.WriteString("__CHR");
        IF SideEffects(n) THEN OPM.Write("F") END ;
        OPM.Write(OpenParen); Entier(n, MinPrec); OPM.Write(CloseParen)
      ELSE OPM.WriteString("(CHAR)"); Entier(n, 9)
      END
    ELSE expr(n, prec)
    END
  END Convert;

  PROCEDURE TypeOf(n: OPT.Node);
  BEGIN
    IF n^.typ^.form = OPT.Pointer THEN
      OPM.WriteString(TypeFunc); expr(n, MinPrec); OPM.Write(")")
    ELSIF n^.class IN {OPT.Nvar, OPT.Nindex, OPT.Nfield} THEN  (* dyn rec type = stat rec type *)
      OPC.Andent(n^.typ); OPM.WriteString(DynTypExt)
    ELSIF n^.class = OPT.Nderef THEN  (* p^ *)
      OPM.WriteString(TypeFunc); expr(n^.left, MinPrec); OPM.Write(")")
    ELSIF n^.class = OPT.Nguard THEN  (* r(T) *)
      TypeOf(n^.left)  (* skip guard *)
    ELSIF (n^.class = OPT.Nmop) & (n^.subcl = OPT.val) THEN
      (*SYSTEM.VAL(typ, var par rec)*)
      OPC.TypeOf(n^.left^.obj)
    ELSE  (* var par rec *)
      OPC.TypeOf(n^.obj)
    END
  END TypeOf;

  PROCEDURE Index(n, d: OPT.Node; prec, dim: INTEGER);
  BEGIN
    IF ~(OPM.inxchk IN OPM.Options)
    OR (n^.right^.class = OPT.Nconst) & ((n^.right^.conval^.intval = 0) OR (n^.left^.typ^.comp # OPT.DynArr)) THEN
      expr(n^.right, prec)
    ELSE
      IF SideEffects(n^.right) THEN OPM.WriteString("__XF(") ELSE OPM.WriteString("__X(") END ;
      expr(n^.right, MinPrec); OPM.WriteString(Comma); Len(d, dim); OPM.Write(CloseParen)
    END
  END Index;

  PROCEDURE design(n: OPT.Node; prec: INTEGER);
    VAR obj: OPT.Object; typ: OPT.Struct;
      class, designPrec, comp: INTEGER;
      d, x: OPT.Node; dims, i: INTEGER;
  BEGIN
    comp := n^.typ^.comp; obj := n^.obj; class := n^.class;
    designPrec := Precedence(class, n^.subcl, n^.typ^.form, comp);
    IF (class = OPT.Nvar) & (obj^.mnolev > 0) & (obj^.mnolev # OPM.level) & (prec = 10) THEN designPrec := 9 END ;
    IF prec > designPrec THEN OPM.Write(OpenParen) END;
    IF prec = ProcTypeVar THEN OPM.Write(Deref) END; (* proc var calls must be dereferenced in K&R C *)
    CASE class OF
    | OPT.Nproc:   OPC.Ident(n^.obj)
    | OPT.Nvar:    OPC.CompleteIdent(n^.obj)
    | OPT.Nvarpar: IF ~(comp IN {OPT.Array, OPT.DynArr}) THEN OPM.Write(Deref) END; (* deref var parameter *)
                   OPC.CompleteIdent(n^.obj)
    | OPT.Nfield:  IF n^.left^.class = OPT.Nderef THEN design(n^.left^.left, designPrec); OPM.WriteString("->")
                   ELSE design(n^.left, designPrec); OPM.Write(".")
                   END ;
                   OPC.Ident(n^.obj)
    | OPT.Nderef:  IF n^.typ^.comp = OPT.DynArr THEN design(n^.left, 10); OPM.WriteString("->data")
                   ELSE OPM.Write(Deref); design(n^.left, designPrec)
                   END
    | OPT.Nindex:  d := n^.left;
                   IF d^.typ^.comp = OPT.DynArr THEN dims := 0;
                     WHILE d^.class = OPT.Nindex DO d := d^.left; INC(dims) END ;
                     IF n^.typ^.comp = OPT.DynArr THEN OPM.Write("&") END ;
                     design(d, designPrec);
                     OPM.Write(OpenBracket);
                     IF n^.typ^.comp = OPT.DynArr THEN OPM.Write("(") END ;
                     i := dims; x := n;
                     WHILE x # d DO  (* apply Horner schema *)
                       IF x^.left # d THEN Index(x, d, 7, i); OPM.WriteString(" + "); Len(d, i);  OPM.WriteString(" * ("); DEC(i)
                       ELSE Index(x, d, MinPrec, i)
                       END ;
                       x := x^.left
                     END ;
                     FOR i := 1 TO dims DO OPM.Write(")") END ;
                     IF n^.typ^.comp = OPT.DynArr THEN
                       (*  element type is OPT.DynArr; finish Horner schema with virtual indices = 0*)
                       OPM.Write(")");
                       WHILE i < (d^.typ^.size - 4) DIV 4 DO
                         OPM.WriteString(" * "); Len(d, i);
                         INC(i)
                       END
                     END ;
                     OPM.Write(CloseBracket)
                   ELSE
                     design(n^.left, designPrec);
                     OPM.Write(OpenBracket);
                     Index(n, n^.left, MinPrec, 0);
                     OPM.Write(CloseBracket)
                   END
    | OPT.Nguard:  typ := n^.typ; obj := n^.left^.obj;
                   IF OPM.typchk IN OPM.Options THEN
                     IF typ^.comp = OPT.Record THEN OPM.WriteString(GuardRecFunc);
                       IF obj^.mnolev # OPM.level THEN (*intermediate level var-par record*)
                         OPM.WriteStringVar(obj^.scope^.name); OPM.WriteString("__curr->"); OPC.Ident(obj)
                       ELSE (*local var-par record*)
                         OPC.Ident(obj)
                       END ;
                     ELSE (*Pointer*)
                       IF typ^.BaseTyp^.strobj = NIL THEN OPM.WriteString("__GUARDA(") ELSE OPM.WriteString(GuardPtrFunc) END ;
                       expr(n^.left, MinPrec); typ := typ^.BaseTyp
                     END ;
                     OPM.WriteString(Comma);
                     OPC.Andent(typ); OPM.WriteString(Comma);
                     OPM.WriteInt(typ^.extlev); OPM.Write(")")
                   ELSE
                     IF typ^.comp = OPT.Record THEN (* do not cast record directly, cast pointer to record *)
                       OPM.WriteString("*("); OPC.Ident(typ^.strobj); OPM.WriteString("*)"); OPC.CompleteIdent(obj)
                     ELSE (*simply cast pointer*)
                       OPM.Write("("); OPC.Ident(typ^.strobj); OPM.Write(")"); expr(n^.left, designPrec)
                     END
                   END
    | OPT.Neguard: IF OPM.typchk IN OPM.Options THEN
                     IF n^.left^.class = OPT.Nvarpar THEN OPM.WriteString("__GUARDEQR(");
                       OPC.CompleteIdent(n^.left^.obj); OPM.WriteString(Comma); TypeOf(n^.left);
                     ELSE OPM.WriteString("__GUARDEQP("); expr(n^.left^.left, MinPrec)
                     END ; (* __GUARDEQx includes deref *)
                     OPM.WriteString(Comma); OPC.Ident(n^.left^.typ^.strobj); OPM.Write(")")
                   ELSE
                     expr(n^.left, MinPrec)  (* always lhs of assignment *)
                   END
    | OPT.Nmop:    IF n^.subcl = OPT.val THEN design(n^.left, prec) END
    ELSE OPM.LogWStr("unhandled case in OPV.design, class = "); OPM.LogWNum(class, 0); OPM.LogWLn;
    END ;
    IF prec > designPrec THEN OPM.Write(CloseParen) END
  END design;

  PROCEDURE ParIntLiteral(n: SYSTEM.INT64; size: LONGINT);
  BEGIN
    (* Literal parameters (other than varargs) do not need an explicit size cast on ansi C compilers. *)
    OPM.WriteInt(n)
  END ParIntLiteral;

  PROCEDURE ActualPar(n: OPT.Node; fp: OPT.Object);
    VAR typ, aptyp: OPT.Struct; comp, form, mode, prec, dim: INTEGER;
  BEGIN
    OPM.Write(OpenParen);
    WHILE n # NIL DO typ := fp^.typ;
      comp := typ^.comp; form := typ^.form; mode := fp^.mode; prec := MinPrec;
      IF (mode = OPT.VarPar) & (n^.class = OPT.Nmop) & (n^.subcl = OPT.val) THEN  (* avoid cast in lvalue *)
        OPM.Write(OpenParen); OPC.Ident(n^.typ^.strobj); OPM.WriteString("*)"); prec := 10
      END ;
      IF ~(n^.typ^.comp IN {OPT.Array, OPT.DynArr}) THEN
        IF mode = OPT.VarPar THEN
          IF typ # n^.typ THEN OPM.WriteString("(void*)") END;
          OPM.Write("&"); prec := 9
        ELSE
          IF (comp IN {OPT.Array, OPT.DynArr}) & (n^.class = OPT.Nconst) THEN
            OPM.WriteString("(CHAR*)")  (* force to unsigned char *)
          ELSIF (form = OPT.Pointer) & (typ # n^.typ) & (n^.typ # OPT.niltyp) THEN
            OPM.WriteString("(void*)")  (* type extension *)
          END
        END
      ELSE
        (* casting of params should be simplified eventually *)
        IF (mode = OPT.VarPar) & (typ # n^.typ) & (prec = MinPrec) THEN OPM.WriteString("(void*)") END
      END;
      IF (mode = OPT.VarPar) & (n^.class = OPT.Nmop) & (n^.subcl = OPT.val) THEN
        expr(n^.left, prec)  (* avoid cast in lvalue *)
      ELSIF (form = OPT.Int) & (n^.class = OPT.Nconst) THEN
        ParIntLiteral(n.conval.intval, n.typ.size)
      ELSE
        expr(n, prec)
      END;
      IF (comp = OPT.Record) & (mode = OPT.VarPar) THEN
        OPM.WriteString(", "); TypeOf(n)
      ELSIF comp = OPT.DynArr THEN
        IF n^.class = OPT.Nconst THEN (* ap is string constant *)
          OPM.WriteString(Comma); ParIntLiteral(n.conval.intval2, OPM.AddressSize)
        ELSE
          aptyp := n^.typ; dim := 0;
          WHILE (typ^.comp = OPT.DynArr) & (typ^.BaseTyp^.form # OPT.Byte) DO
            OPM.WriteString(Comma); Len(n, dim);
            typ := typ^.BaseTyp; aptyp := aptyp^.BaseTyp; INC(dim)
          END ;
          IF (typ^.comp = OPT.DynArr) & (typ^.BaseTyp^.form = OPT.Byte) THEN
            OPM.WriteString(Comma);
            WHILE aptyp^.comp = OPT.DynArr DO
              Len(n, dim); OPM.WriteString(" * "); INC(dim); aptyp := aptyp^.BaseTyp
            END ;
            (*OPM.WriteString("((LONGINT)("); OPM.WriteInt(aptyp^.size); OPM.WriteString("))");*)
            ParIntLiteral(aptyp.size, OPM.AddressSize)
          END
        END
      END ;
      n := n^.link; fp := fp^.link;
      IF n # NIL THEN OPM.WriteString(Comma) END
    END ;
    OPM.Write(CloseParen)
  END ActualPar;

  PROCEDURE SuperProc(n: OPT.Node): OPT.Object;
    VAR obj: OPT.Object; typ: OPT.Struct;
  BEGIN typ := n^.right^.typ;  (* receiver type *)
    IF typ^.form = OPT.Pointer THEN typ := typ^.BaseTyp END ;
    OPT.FindField(n^.left^.obj^.name, typ^.BaseTyp, obj);
    RETURN obj
  END SuperProc;

  PROCEDURE expr (n: OPT.Node; prec: INTEGER);
    VAR
      class: INTEGER;
      subclass: INTEGER;
      form: INTEGER;
      exprPrec: INTEGER;
      typ: OPT.Struct;
      l, r: OPT.Node;
      proc: OPT.Object;
  BEGIN
    class := n^.class; subclass := n^.subcl; form := n^.typ^.form;
    l := n^.left; r := n^.right;
    exprPrec := Precedence (class, subclass, form, n^.typ^.comp);
    IF (exprPrec <= prec) & (class IN {OPT.Nconst, OPT.Nupto, OPT.Nmop, OPT.Ndop, OPT.Ncall, OPT.Nguard, OPT.Neguard}) THEN
      OPM.Write(OpenParen);
    END;
    CASE class OF
    | OPT.Nconst: OPC.Constant(n^.conval, form)
    | OPT.Nupto:  (* n^.typ = OPT.settyp *)
                  OPM.WriteString("__SETRNG("); expr(l, MinPrec); OPM.WriteString(Comma); expr(r, MinPrec);
                  OPM.WriteString(Comma); OPM.WriteInt(n.typ.size*8); OPM.Write(CloseParen)
    | OPT.Nmop:
                  CASE subclass OF
                  | OPS.not:   OPM.Write("!"); expr(l, exprPrec)
                  | OPS.minus: IF form = OPT.Set THEN OPM.Write("~") ELSE OPM.Write("-") END;
                               expr(l, exprPrec)
                  | OPS.is:    typ := n^.obj^.typ;
                               IF l^.typ^.comp = OPT.Record THEN OPM.WriteString(IsFunc); OPC.TypeOf(l^.obj)
                               ELSE OPM.WriteString(IsPFunc); expr(l, MinPrec); typ := typ^.BaseTyp
                               END ;
                               OPM.WriteString(Comma);
                               OPC.Andent(typ); OPM.WriteString(Comma);
                               OPM.WriteInt(typ^.extlev); OPM.Write(")")
                  | OPT.conv:  Convert(l, n.typ, exprPrec)
                  | OPT.abs:   IF SideEffects(l) THEN
                                 IF l^.typ^.form < OPT.Real THEN
                                   IF l.typ.size <= OPM.CIntSize THEN OPM.WriteString("(int)") END ;
                                   OPM.WriteString("__ABSF(")
                                 ELSE OPM.WriteString("__ABSFD(")
                                 END
                               ELSE OPM.WriteString("__ABS(")
                               END ;
                               expr(l, MinPrec); OPM.Write(CloseParen)
                  | OPT.cap:   OPM.WriteString("__CAP("); expr(l, MinPrec); OPM.Write(CloseParen)
                  | OPT.odd:   OPM.WriteString("__ODD("); expr(l, MinPrec); OPM.Write(CloseParen)
                  | OPT.adr:   OPM.WriteString("(ADDRESS)");                             (*SYSTEM*)
                               IF l^.class = OPT.Nvarpar THEN OPC.CompleteIdent(l^.obj)
                               ELSE
                                 IF (l^.typ^.form # OPT.String) & ~(l^.typ^.comp IN {OPT.Array, OPT.DynArr}) THEN OPM.Write("&") END ;
                                 expr(l, exprPrec)
                               END
                  | OPT.val:   IF ~(l^.class IN {OPT.Nvar, OPT.Nvarpar, OPT.Nfield, OPT.Nindex})    (*SYSTEM*)
                               OR   (n^.typ^.form IN {OPT.Int, OPT.Pointer, OPT.Set, OPT.ProcTyp})
                                  & (l^.typ^.form IN {OPT.Int, OPT.Pointer, OPT.Set, OPT.ProcTyp})
                                  & (n^.typ^.size = l^.typ^.size)
                               THEN
                                 OPM.Write(OpenParen); OPC.Ident(n^.typ^.strobj); OPM.Write(CloseParen);
                                 IF (n^.typ^.form IN {OPT.Pointer, OPT.ProcTyp}) OR (l^.typ^.form IN {OPT.Pointer, OPT.ProcTyp}) THEN
                                   OPM.WriteString("(ADDRESS)")
                                 END;
                                 expr(l, exprPrec)
                               ELSE
                                 OPM.WriteString("__VAL(");
                                 OPC.Ident(n^.typ^.strobj); OPM.WriteString(Comma);
                                 expr(l, MinPrec); OPM.Write(CloseParen)
                               END
                  ELSE OPM.err(200)
                  END
    | OPT.Ndop:   CASE subclass OF
                  | OPT.len:  Len(l, r^.conval^.intval)
                  | OPS.in,
                    OPT.ash,
                    OPT.msk,
                    OPT.bit,
                    OPT.lsh,
                    OPT.rot,
                    OPS.div,
                    OPS.mod:  CASE subclass OF
                              | OPS.in:   OPM.WriteString("__IN(")
                              | OPT.ash:  IF r^.class = OPT.Nconst THEN
                                            IF r^.conval^.intval >= 0 THEN OPM.WriteString("__ASHL(")
                                            ELSE OPM.WriteString("__ASHR(")
                                            END
                                          ELSIF SideEffects(r) THEN OPM.WriteString("__ASHF(")
                                          ELSE OPM.WriteString("__ASH(")
                                          END
                              | OPT.msk:  OPM.WriteString("__MASK(");
                              | OPT.bit:  OPM.WriteString("__BIT(")
                              | OPT.lsh:  IF r^.class = OPT.Nconst THEN
                                            IF r^.conval^.intval >= 0 THEN OPM.WriteString("__LSHL(")
                                            ELSE OPM.WriteString("__LSHR(")
                                            END
                                          ELSE OPM.WriteString("__LSH(")
                                          END
                              | OPT.rot:  IF r^.class = OPT.Nconst THEN
                                            IF r^.conval^.intval >= 0 THEN OPM.WriteString("__ROTL(")
                                            ELSE OPM.WriteString("__ROTR(")
                                            END
                                          ELSE OPM.WriteString("__ROT(")
                                          END
                              | OPS.div:  IF SideEffects(n) THEN
                                            IF n.typ.size <= OPM.CIntSize THEN OPM.WriteString("(int)") END;
                                            OPM.WriteString("__DIVF(")
                                          ELSE OPM.WriteString("__DIV(")
                                          END
                              | OPS.mod:  IF n.typ.size <= OPM.CIntSize THEN OPM.WriteString("(int)") END;
                                          IF SideEffects(n) THEN OPM.WriteString("__MODF(")
                                          ELSE OPM.WriteString("__MOD(")
                                          END;
	                            ELSE OPM.LogWStr("unhandled case in OPV.expr, subclass = "); OPM.LogWNum(subclass, 0); OPM.LogWLn;
                              END ;
                              expr(l, MinPrec);
                              OPM.WriteString(Comma);
                              IF (subclass IN {OPT.ash, OPT.lsh, OPT.rot}) & (r^.class = OPT.Nconst) & (r^.conval^.intval < 0) THEN
                                OPM.WriteInt(-r^.conval^.intval)
                              ELSE expr(r, MinPrec)
                              END;
                              IF subclass IN {OPS.in, OPT.lsh, OPT.rot} THEN
                                OPM.WriteString(Comma);
                                IF subclass = OPS.in THEN OPM.WriteInt(r.typ.size*8) ELSE OPM.WriteInt(l.typ.size*8) END
                              END;
                              OPM.Write(CloseParen)
                  | OPS.eql
                  .. OPS.geq: IF l^.typ^.form IN {OPT.String, OPT.Comp} THEN
                                OPM.WriteString("__STRCMP(");
                                expr(l, MinPrec); OPM.WriteString(Comma); expr(r, MinPrec); OPM.Write(CloseParen);
                                OPC.Cmp(subclass); OPM.Write("0")
                              ELSE
                                expr(l, exprPrec); OPC.Cmp(subclass);
                                typ := l^.typ;
                                IF (typ^.form = OPT.Pointer) & (r^.typ.form # OPT.NilTyp) & (r^.typ # typ) & (r^.typ # OPT.sysptrtyp) THEN
                                  OPM.WriteString("(void *) ")
                                END ;
                                expr(r, exprPrec)
                              END
                  ELSE        IF (subclass = OPS.and) OR ((form = OPT.Set) & ((subclass = OPS.times) OR (subclass = OPS.minus))) THEN OPM.Write(OpenParen); END; (* to silence clang warnings; -- noch *)
                              expr(l, exprPrec);
                              CASE subclass OF
                              | OPS.times: IF form = OPT.Set THEN OPM.WriteString(" & ")
                                             ELSE OPM.WriteString(" * ")
                                           END
                              | OPS.slash: IF form = OPT.Set THEN OPM.WriteString(" ^ ")
                                           ELSE OPM.WriteString(" / ");
                                             IF (r^.obj = NIL) OR (r^.obj^.typ^.form = OPT.Int) THEN
                                               OPM.Write(OpenParen); OPC.Ident(n^.typ^.strobj); OPM.Write(CloseParen)
                                             END
                                           END
                              | OPS.and:   OPM.WriteString(" && ")
                              | OPS.plus:  IF form = OPT.Set THEN OPM.WriteString(" | ")
                                           ELSE OPM.WriteString(" + ")
                                           END
                              | OPS.minus: IF form = OPT.Set THEN OPM.WriteString(" & ~")
                                           ELSE OPM.WriteString(" - ")
                                           END;
                              | OPS.or:    OPM.WriteString(" || ");
	                            ELSE OPM.LogWStr("unhandled case in OPV.expr, subclass = "); OPM.LogWNum(subclass, 0); OPM.LogWLn;
                              END;
                              expr(r, exprPrec);
	                            IF (subclass = OPS.and) OR ((form = OPT.Set) & ((subclass = OPS.times) OR (subclass = OPS.minus))) THEN OPM.Write(CloseParen) END; (* to silence clang warnings, -- noch*)
                  END
    | OPT.Ncall:  IF (l^.obj # NIL) & (l^.obj^.mode = OPT.TProc) THEN
                    IF l^.subcl = OPT.super THEN proc := SuperProc(n)
                    ELSE OPM.WriteString("__"); proc := OPC.BaseTProc(l^.obj)
                    END ;
                    OPC.Ident(proc);
                    n^.obj := proc^.link
                  ELSIF l^.class = OPT.Nproc THEN design(l, 10)
                  ELSE design(l, ProcTypeVar)
                  END ;
                  ActualPar(r, n^.obj)
    ELSE          design(n, prec); (* not exprPrec! *)
    END;
    IF (exprPrec <= prec) & (class IN {OPT.Nconst, OPT.Nupto, OPT.Nmop, OPT.Ndop, OPT.Ncall, OPT.Nguard}) THEN
      OPM.Write(CloseParen)
    END
  END expr;

  PROCEDURE^ stat(n: OPT.Node; outerProc: OPT.Object);

  PROCEDURE IfStat(n: OPT.Node; withtrap: BOOLEAN; outerProc: OPT.Object);
    VAR if: OPT.Node; obj: OPT.Object; typ: OPT.Struct; adr: LONGINT;
  BEGIN  (* n^.class IN {OPT.Nifelse, OPT.Nwith} *)
    if := n^.left; (* name := ""; *)
    WHILE if # NIL DO
      OPM.WriteString("if "); expr(if^.left, MaxPrec);  (* if *)
      OPM.Write(Blank); OPC.BegBlk;
      IF (n^.class = OPT.Nwith) & (if^.left^.left # NIL) THEN (* watch out for const expr *)
        obj := if^.left^.left^.obj; typ := obj^.typ; adr := obj^.adr;
        IF typ^.comp = OPT.Record THEN
          (* introduce alias pointer for var records; T1 *name__ = rec; *)
          OPC.BegStat; OPC.Ident(if^.left^.obj); OPM.WriteString(" *");
          OPM.WriteString(obj.name); OPM.WriteString("__ = (void*)");
          obj^.adr := 0; (* for nested WITH with same variable; always take the original name *)
          OPC.CompleteIdent(obj);
          OPC.EndStat
        END ;
        obj^.adr := 1;  (* signal special handling of variable name to OPC.CompleteIdent *)
        obj^.typ := if^.left^.obj^.typ;
        stat(if^.right, outerProc);
        obj^.typ := typ; obj^.adr := adr
      ELSE
        stat(if^.right, outerProc)
      END ;
      if := if^.link;
      IF (if # NIL) OR (n^.right # NIL) OR withtrap THEN OPC.EndBlk0(); OPM.WriteString(" else ");
      ELSE OPC.EndBlk()
      END
    END ;
    IF withtrap THEN OPM.WriteString(WithChk); OPC.EndStat()
    ELSIF n^.right # NIL THEN OPC.BegBlk; stat(n^.right, outerProc); OPC.EndBlk
    END
  END IfStat;

  PROCEDURE CaseStat(n: OPT.Node; outerProc: OPT.Object);
    VAR switchCase, label: OPT.Node;
      low, high: SYSTEM.INT64; form, i: INTEGER;
  BEGIN
    OPM.WriteString("switch "); expr(n^.left, MaxPrec);
    OPM.Write(Blank); OPC.BegBlk;
    form := n^.left^.typ^.form;
    switchCase := n^.right^.left;
    WHILE switchCase # NIL DO  (* switchCase^.class = Ncasedo *)
      label := switchCase^.left;
      i := 0;
      WHILE label # NIL DO (* label^.class = NConst *)
        low := label^.conval^.intval;
        high := label^.conval^.intval2;
        WHILE low <= high DO
          IF i = 0 THEN OPC.BegStat END ;
          OPC.Case(low, form);
          INC(low); INC(i);
          IF i = 5 THEN OPM.WriteLn; i := 0 END
        END ;
        label := label^.link
      END ;
      IF i > 0 THEN OPM.WriteLn END ;
      OPC.Indent(1);
      stat(switchCase^.right, outerProc);
      OPC.BegStat; OPM.WriteString(Break); OPC.EndStat;
      OPC.Indent(-1);
      switchCase := switchCase^.link
    END ;
    OPC.BegStat; OPM.WriteString("default: ");
    IF n^.right^.conval^.setval # {} THEN  (* else branch *)
      OPC.Indent(1); OPM.WriteLn; stat(n^.right^.right, outerProc);
      OPC.BegStat; OPM.WriteString(Break); OPC.Indent(-1)
    ELSE
      OPM.WriteString("__CASECHK")
    END ;
    OPC.EndStat; OPC.EndBlk
  END CaseStat;

  PROCEDURE ImplicitReturn(n: OPT.Node): BOOLEAN;
  BEGIN
    WHILE (n # NIL) & (n.class # OPT.Nreturn) DO n := n^.link END ;
    RETURN n = NIL
  END ImplicitReturn;

  PROCEDURE NewArr(d, x: OPT.Node);
    VAR typ, base: OPT.Struct; nofdim, nofdyn: INTEGER;
  BEGIN
    typ := d^.typ^.BaseTyp; base := typ; nofdim := 0; nofdyn := 0;
    WHILE base^.comp = OPT.DynArr DO INC(nofdim); INC(nofdyn); base := base^.BaseTyp END ;
    design(d, MinPrec); OPM.WriteString(" = __NEWARR(");
    WHILE base^.comp = OPT.Array DO INC(nofdim); base := base^.BaseTyp END ;
    IF (base^.comp = OPT.Record) & (OPC.NofPtrs(base) # 0) THEN
      OPC.Andent(base); OPM.WriteString(DynTypExt)
    ELSIF base^.form = OPT.Pointer THEN OPM.WriteString("POINTER__typ")
    ELSE OPM.WriteString("NIL")
    END ;
    OPM.WriteString(", "); OPM.WriteInt(base.size);
    OPM.WriteString(", "); OPM.WriteInt(OPT.BaseAlignment(base));  (* element alignment *)
    OPM.WriteString(", "); OPM.WriteInt(nofdim);  (* total number of dimensions = number of additional parameters *)
    OPM.WriteString(", "); OPM.WriteInt(nofdyn);  (* number of dynamic dimensions *)
    WHILE typ # base DO
      OPM.WriteString(", ");
      IF typ^.comp = OPT.DynArr THEN
        IF x^.class = OPT.Nconst THEN
          OPC.IntLiteral(x.conval.intval, OPM.AddressSize)
        ELSE OPM.WriteString("((ADDRESS)("); expr(x, 10); OPM.WriteString("))")
        END ;
        x := x^.link
      ELSE
        OPC.IntLiteral(typ.n, OPM.AddressSize)
      END ;
      typ := typ^.BaseTyp
    END ;
    OPM.Write(")")
  END NewArr;

  PROCEDURE DefineTDescs(n: OPT.Node);
  BEGIN
    WHILE (n # NIL) & (n^.class = OPT.Ninittd) DO OPC.TDescDecl(n^.typ); n := n^.link END
  END DefineTDescs;

  PROCEDURE InitTDescs(n: OPT.Node);
  BEGIN
    WHILE (n # NIL) & (n^.class = OPT.Ninittd) DO OPC.InitTDesc(n^.typ); n := n^.link END
  END InitTDescs;

  PROCEDURE stat(n: OPT.Node; outerProc: OPT.Object);
    VAR proc: OPT.Object; saved: ExitInfo; l, r: OPT.Node;
  BEGIN
    WHILE (n # NIL) & OPM.noerr DO
      OPM.errpos := OPM.Longint(n^.conval^.intval);
      IF n^.class # OPT.Ninittd THEN OPC.BegStat END;
      CASE n^.class OF
      | OPT.Nenter:  IF n^.obj = NIL THEN (* enter module *)
                       INC(OPM.level); stat(n^.left, outerProc); DEC(OPM.level);
                       OPC.GenEnumPtrs(OPT.topScope^.scope);
                       DefineTDescs(n^.right); OPC.EnterBody; InitTDescs(n^.right);
                       OPM.WriteString("/* BEGIN */"); OPM.WriteLn;
                       stat(n^.right, outerProc); OPC.ExitBody
                     ELSE (* enter proc *)
                       proc := n^.obj;
                       OPC.TypeDefs(proc^.scope^.right, 0);
                       IF ~proc^.scope^.leaf THEN OPC.DefineInter (proc) END ; (* define intermediate procedure scope *)
                       INC(OPM.level); stat(n^.left, proc); DEC(OPM.level);
                       OPC.EnterProc(proc); stat(n^.right, proc);
                       OPC.ExitProc(proc, TRUE, ImplicitReturn(n^.right));
                     END
      | OPT.Ninittd: (* done in enter module *)
      | OPT.Nassign: CASE n^.subcl OF
                     | OPT.assign:    l := n^.left; r := n^.right;
                                      IF l^.typ^.comp = OPT.Array THEN (* includes string assignment but not COPY *)
                                        OPM.WriteString(MoveFunc);
                                        expr(r, MinPrec); OPM.WriteString(Comma); expr(l, MinPrec); OPM.WriteString(Comma);
                                        IF r^.typ = OPT.stringtyp THEN OPM.WriteInt(r^.conval^.intval2)
                                        ELSIF r.typ.comp = OPT.DynArr THEN
                                          (* Dynamic array to array copy *)
                                          OPM.WriteString("__X(");
                                          OPC.Len(r.obj, r.typ, 0); OPM.WriteString(" * "); OPM.WriteInt(r.typ.BaseTyp.size);
                                          OPM.WriteString(", ");
                                          OPM.WriteInt(l.typ.size+1); (* _X validates 0 .. n-1 so we need top+1. *)
                                          OPM.Write(")")
                                        ELSE (* Array to array copy. *)
                                          ASSERT(r.typ.comp = OPT.Array); ASSERT(r.typ.size <= l.typ.size);
                                          OPM.WriteInt(r^.typ^.size)
                                        END;
                                        OPM.Write(CloseParen)
                                      ELSE
                                        IF (l^.typ^.form = OPT.Pointer) & (l^.obj # NIL) & (l^.obj^.adr = 1) & (l^.obj^.mode = OPT.Var) THEN
                                          l^.obj^.adr := 0; design(l, MinPrec); l^.obj^.adr := 1;      (* avoid cast of WITH-variable *)
                                          IF r^.typ^.form # OPT.NilTyp THEN OPM.WriteString(" = (void*)")
                                          ELSE OPM.WriteString(" = ")
                                          END
                                        ELSE
                                          design(l, MinPrec); OPM.WriteString(" = ")
                                        END ;
                                        IF l^.typ = r^.typ THEN expr(r, MinPrec)
                                        ELSIF (l^.typ^.form = OPT.Pointer) & (r^.typ^.form # OPT.NilTyp) & (l^.typ^.strobj # NIL) THEN
                                          OPM.Write("("); OPC.Ident(l^.typ^.strobj); OPM.Write(")"); expr(r, MinPrec)
                                        ELSIF l^.typ^.comp = OPT.Record THEN
                                          OPM.WriteString("*("); OPC.Andent(l^.typ); OPM.WriteString("*)&"); expr(r, 9)
                                        ELSE expr(r, MinPrec)
                                        END
                                      END
                     | OPT.newfn:     IF n^.left^.typ^.BaseTyp^.comp = OPT.Record THEN
                                        OPM.WriteString("__NEW("); design(n^.left, MinPrec); OPM.WriteString(", ");
                                        OPC.Andent(n^.left^.typ^.BaseTyp); OPM.WriteString(")")
                                      ELSIF n^.left^.typ^.BaseTyp^.comp IN {OPT.Array, OPT.DynArr} THEN
                                        NewArr(n^.left, n^.right)
                                      END
                     | OPT.incfn,
                       OPT.decfn:     expr(n^.left, MinPrec); OPC.Increment(n^.subcl = OPT.decfn); expr(n^.right, MinPrec)
                     | OPT.inclfn,
                       OPT.exclfn:    expr(n^.left, MinPrec); OPC.SetInclude(n^.subcl = OPT.exclfn);
                                      OPM.WriteString("__SETOF("); expr(n^.right, MinPrec);
                                      OPM.WriteString(","); OPM.WriteInt(n.left.typ.size*8); OPM.Write(CloseParen)
                     | OPT.copyfn:    OPM.WriteString(CopyFunc);
                                      expr(n^.right, MinPrec); OPM.WriteString(Comma); expr(n^.left, MinPrec); OPM.WriteString(Comma);
                                      Len(n^.left, 0); OPM.Write(CloseParen)
                     |  OPT.movefn:   (*SYSTEM*)
                                      OPM.WriteString(MoveFunc);
                                      expr(n^.right, MinPrec); OPM.WriteString(Comma); expr(n^.left, MinPrec); OPM.WriteString(Comma);
                                      expr(n^.right^.link, MinPrec);
                                      OPM.Write(CloseParen)
                     |  OPT.getfn:    (*SYSTEM*)
                                      OPM.WriteString(GetFunc); expr(n^.right, MinPrec); OPM.WriteString(Comma); expr(n^.left, MinPrec);
                                      OPM.WriteString(Comma); OPC.Ident(n^.left^.typ^.strobj); OPM.Write(CloseParen)
                     |  OPT.putfn:    (*SYSTEM*)
                                      OPM.WriteString(PutFunc); expr(n^.left, MinPrec); OPM.WriteString(Comma); expr(n^.right, MinPrec);
                                      OPM.WriteString(Comma); OPC.Ident(n^.right^.typ^.strobj); OPM.Write(CloseParen)
                     |  OPT.getrfn,   (*SYSTEM*)
                        OPT.putrfn:   (*SYSTEM*) OPM.err(200)
                     |  OPT.sysnewfn: (*SYSTEM*)
                                      OPM.WriteString("__SYSNEW(");
                                      design(n^.left, MinPrec); OPM.WriteString(", ");
                                      expr(n^.right, MinPrec);
                                      OPM.Write(")")
	                   ELSE OPM.LogWStr("unhandled case in OPV.expr, n^.subcl = "); OPM.LogWNum(n^.subcl, 0); OPM.LogWLn;
                     END
      | OPT.Ncall:   IF (n^.left^.obj # NIL) & (n^.left^.obj^.mode = OPT.TProc) THEN
                       IF n^.left^.subcl = OPT.super THEN proc := SuperProc(n)
                       ELSE OPM.WriteString("__"); proc := OPC.BaseTProc(n^.left^.obj)
                       END ;
                       OPC.Ident(proc);
                       n^.obj := proc^.link
                     ELSIF n^.left^.class = OPT.Nproc THEN design(n^.left, 10)
                     ELSE design(n^.left, ProcTypeVar)
                     END ;
                     ActualPar(n^.right, n^.obj)
      | OPT.Nifelse: IF n^.subcl # OPT.assertfn THEN IfStat(n, FALSE, outerProc)
                     ELSIF OPM.assert IN OPM.Options THEN
                       OPM.WriteString("__ASSERT("); expr(n^.left^.left^.left, MinPrec); OPM.WriteString(Comma);
                       OPM.WriteInt(n^.left^.right^.right^.conval^.intval); OPM.Write(CloseParen); OPC.EndStat
                     END
      | OPT.Ncase:   INC(exit.level); CaseStat(n, outerProc); DEC(exit.level)
      | OPT.Nwhile:  INC(exit.level); OPM.WriteString("while "); expr(n^.left, MaxPrec);
                     OPM.Write(Blank); OPC.BegBlk; stat(n^.right, outerProc); OPC.EndBlk;
                     DEC(exit.level)
      | OPT.Nrepeat: INC(exit.level); OPM.WriteString("do "); OPC.BegBlk; stat(n^.left, outerProc); OPC.EndBlk0;
                     OPM.WriteString(" while (!");  expr(n^.right, 9); OPM.Write(CloseParen);
                     DEC(exit.level)
      | OPT.Nloop:   saved := exit; exit.level := 0; exit.label := -1;
                     OPM.WriteString("for (;;) "); OPC.BegBlk; stat(n^.left, outerProc); OPC.EndBlk;
                     IF exit.label # -1 THEN
                       OPC.BegStat; OPM.WriteString("exit__"); OPM.WriteInt(exit.label); OPM.Write(":"); OPC.EndStat
                     END ;
                     exit := saved
      | OPT.Nexit:   IF exit.level = 0 THEN OPM.WriteString(Break)
                     ELSE
                       IF exit.label = -1 THEN exit.label := nofExitLabels; INC(nofExitLabels) END ;
                       OPM.WriteString("goto exit__"); OPM.WriteInt(exit.label)
                     END
      | OPT.Nreturn: IF OPM.level = 0 THEN
                       IF OPM.mainprog IN OPM.Options THEN OPM.WriteString("__FINI") ELSE OPM.WriteString("__ENDMOD") END
                     ELSIF OPC.NeedsRetval(outerProc) THEN
                       OPM.WriteString("__retval = ");
                       IF (n^.left^.typ^.form = OPT.Pointer) & (n^.obj^.typ # n^.left^.typ) THEN
                         OPM.WriteString("(void*)"); expr(n^.left, 10)
                       ELSE
                         expr(n^.left, MinPrec)
                       END ;
                       OPC.EndStat;
                       OPC.BegStat; OPC.ExitProc(outerProc, FALSE, FALSE); OPC.EndStat;
                       OPC.BegStat; OPM.WriteString("return __retval");
                     ELSE
                       OPC.ExitProc(outerProc, FALSE, FALSE);
                       OPM.WriteString("return");
                       IF n^.left # NIL THEN
                         OPM.Write(Blank);
                         IF (n^.left^.typ^.form = OPT.Pointer) & (n^.obj^.typ # n^.left^.typ) THEN
                           OPM.WriteString("(void*)"); expr(n^.left, 10)
                         ELSE
                           expr(n^.left, MinPrec)
                         END
                       END
                     END
      | OPT.Nwith:   IfStat(n, n^.subcl = 0, outerProc)
      | OPT.Ntrap:   OPC.Halt(OPM.Longint(n^.right^.conval^.intval))
      ELSE OPM.LogWStr("unhandled case in OPV.expr, n^.class = "); OPM.LogWNum(n^.class, 0); OPM.LogWLn;
      END;
      IF ~(n^.class IN {OPT.Nenter, OPT.Ninittd, OPT.Nifelse, OPT.Nwith, OPT.Ncase, OPT.Nwhile, OPT.Nloop}) THEN OPC.EndStat END ;
      n := n^.link
    END
  END stat;

  PROCEDURE Module*(prog: OPT.Node);
  BEGIN
    IF ~(OPM.mainprog IN OPM.Options) THEN OPC.GenHdr(prog^.right); OPC.GenHdrIncludes END ;
    OPC.GenBdy(prog^.right); stat(prog, NIL)
  END Module;

END OPV.
