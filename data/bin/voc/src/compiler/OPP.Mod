(* OPP - Oberon Portable Parser (front end) *)
MODULE OPP;  (* NW, RC 6.3.89 / 10.2.94 *)  (* object model 4.12.93 *)

  IMPORT
    OPB, OPT, OPS, OPM, SYSTEM;

  TYPE
    CaseTable = ARRAY OPM.MaxCases OF
      RECORD
        low, high: LONGINT
      END ;

  VAR
    sym, level: SHORTINT;
    LoopLevel: INTEGER;
    TDinit, lastTDinit: OPT.Node;
    nofFwdPtr: INTEGER;
    FwdPtr: ARRAY 64 OF OPT.Struct;

  PROCEDURE^ Type(VAR typ, banned: OPT.Struct);
  PROCEDURE^ Expression(VAR x: OPT.Node);
  PROCEDURE^ Block(VAR procdec, statseq: OPT.Node);

  PROCEDURE err(n: INTEGER);
  BEGIN OPM.err(n)
  END err;

  PROCEDURE CheckSym(s: INTEGER);
  BEGIN
    IF sym = s THEN OPS.Get(sym) ELSE OPM.err(s) END
  END CheckSym;

  PROCEDURE qualident(VAR id: OPT.Object);
    VAR obj: OPT.Object; lev: SHORTINT;
  BEGIN (*sym = OPS.ident*)
    OPT.Find(obj); OPS.Get(sym);
    IF (sym = OPS.period) & (obj # NIL) & (obj^.mode = OPT.Mod) THEN
      OPS.Get(sym);
      IF sym = OPS.ident THEN
        OPT.FindImport(obj, obj); OPS.Get(sym)
      ELSE err(OPS.ident); obj := NIL
      END
    END ;
    IF obj = NIL THEN err(0);
      obj := OPT.NewObj(); obj^.mode := OPT.Var; obj^.typ := OPT.undftyp; obj^.adr := 0
    ELSE lev := obj^.mnolev;
      IF (obj^.mode IN {OPT.Var, OPT.VarPar}) & (lev # level) THEN
        obj^.leaf := FALSE;
        IF lev > 0 THEN OPB.StaticLink(level-lev) END
      END
    END ;
    id := obj
  END qualident;

  PROCEDURE ConstExpression(VAR x: OPT.Node);
  BEGIN Expression(x);
    IF x^.class # OPT.Nconst THEN
      err(50); x := OPB.NewIntConst(1)
    END
  END ConstExpression;

  PROCEDURE CheckMark(VAR vis: SHORTINT);
  BEGIN OPS.Get(sym);
    IF (sym = OPS.times) OR (sym = OPS.minus) THEN
      IF level > 0 THEN err(47) END ;
      IF sym = OPS.times THEN vis := OPT.external ELSE vis := OPT.externalR END ;
      OPS.Get(sym)
    ELSE vis := OPT.internal
    END
  END CheckMark;

  PROCEDURE CheckSysFlag(VAR sysflag: INTEGER; default: INTEGER);
    VAR x: OPT.Node; sf: SYSTEM.INT64;
  BEGIN
    IF sym = OPS.lbrak THEN OPS.Get(sym);
    IF ~OPT.SYSimported THEN err(135) END;
    ConstExpression(x);
      IF x^.typ^.form = OPT.Int THEN sf := x^.conval^.intval;
        IF (sf < 0) OR (sf > OPM.MaxSysFlag) THEN err(220); sf := 0 END
      ELSE err(51); sf := 0
      END ;
      sysflag := OPM.Integer(sf); CheckSym(OPS.rbrak)
    ELSE sysflag := default
    END
  END CheckSysFlag;

  PROCEDURE RecordType(VAR typ, banned: OPT.Struct);
    VAR fld, first, last, base: OPT.Object;
      ftyp: OPT.Struct; sysflag: INTEGER;
  BEGIN typ := OPT.NewStr(OPT.Comp, OPT.Record); typ^.BaseTyp := NIL;
    CheckSysFlag(sysflag, -1);
    IF sym = OPS.lparen THEN
      OPS.Get(sym); (*record extension*)
      IF sym = OPS.ident THEN
        qualident(base);
        IF (base^.mode = OPT.Typ) & (base^.typ^.comp = OPT.Record) THEN
          IF base^.typ = banned THEN err(58)
          ELSE base^.typ^.pvused := TRUE;
            typ^.BaseTyp := base^.typ; typ^.extlev := base^.typ^.extlev + 1; typ^.sysflag := base^.typ^.sysflag
          END
        ELSE err(52)
        END
      ELSE err(OPS.ident)
      END ;
      CheckSym(OPS.rparen)
    END ;
    IF sysflag >= 0 THEN typ^.sysflag := sysflag END ;
    OPT.OpenScope(0, NIL); first := NIL; last := NIL;
    LOOP
      IF sym = OPS.ident THEN
        LOOP
          IF sym = OPS.ident THEN
            IF typ^.BaseTyp # NIL THEN
              OPT.FindField(OPS.name, typ^.BaseTyp, fld);
              IF fld # NIL THEN err(1) END
            END ;
            OPT.Insert(OPS.name, fld); CheckMark(fld^.vis);
            fld^.mode := OPT.Fld; fld^.link := NIL; fld^.typ := OPT.undftyp;
            IF first = NIL THEN first := fld END ;
            IF last = NIL THEN typ^.link := fld ELSE last^.link := fld END ;
            last := fld
          ELSE err(OPS.ident)
          END ;
          IF sym = OPS.comma THEN OPS.Get(sym)
          ELSIF sym = OPS.ident THEN err(OPS.comma)
          ELSE EXIT
          END
        END ;
        CheckSym(OPS.colon); Type(ftyp, banned);
        ftyp^.pvused := TRUE;
        IF ftyp^.comp = OPT.DynArr THEN ftyp := OPT.undftyp; err(88) END ;
        WHILE first # NIL DO
          first^.typ := ftyp; first := first^.link
        END
      END ;
      IF sym = OPS.semicolon THEN OPS.Get(sym)
      ELSIF sym = OPS.ident THEN err(OPS.semicolon)
      ELSE EXIT
      END
    END ;
    OPT.CloseScope
  END RecordType;

  PROCEDURE ArrayType(VAR typ, banned: OPT.Struct);
    VAR x: OPT.Node; n: SYSTEM.INT64; sysflag: INTEGER;
  BEGIN CheckSysFlag(sysflag, 0);
    IF sym = OPS.of THEN  (*dynamic array*)
      typ := OPT.NewStr(OPT.Comp, OPT.DynArr); typ^.mno := 0; typ^.sysflag := sysflag;
      OPS.Get(sym); Type(typ^.BaseTyp, banned);
      typ^.BaseTyp^.pvused := TRUE;
      IF typ^.BaseTyp^.comp = OPT.DynArr THEN typ^.n := typ^.BaseTyp^.n + 1
      ELSE typ^.n := 0
      END
    ELSE
      typ := OPT.NewStr(OPT.Comp, OPT.Array); typ^.sysflag := sysflag; ConstExpression(x);
      IF x^.typ^.form = OPT.Int THEN n := x^.conval^.intval;
        IF (n <= 0) OR (n > OPM.MaxIndex) THEN err(63); n := 1 END
      ELSE err(51); n := 1
      END ;
      typ^.n := OPM.Longint(n);
      IF sym = OPS.of THEN
        OPS.Get(sym); Type(typ^.BaseTyp, banned);
        typ^.BaseTyp^.pvused := TRUE
      ELSIF sym = OPS.comma THEN
        OPS.Get(sym); IF sym # OPS.of THEN ArrayType(typ^.BaseTyp, banned) END
      ELSE err(35)
      END ;
      IF typ^.BaseTyp^.comp = OPT.DynArr THEN typ^.BaseTyp := OPT.undftyp; err(88) END
    END
  END ArrayType;

  PROCEDURE PointerType(VAR typ: OPT.Struct);
    VAR id: OPT.Object;
  BEGIN typ := OPT.NewStr(OPT.Pointer, OPT.Basic); CheckSysFlag(typ^.sysflag, 0);
    CheckSym(OPS.to);
    IF sym = OPS.ident THEN OPT.Find(id);
      IF id = NIL THEN
        IF nofFwdPtr < LEN(FwdPtr) THEN FwdPtr[nofFwdPtr] := typ; INC(nofFwdPtr)
        ELSE err(224)
        END ;
        typ^.link := OPT.NewObj(); COPY(OPS.name, typ^.link^.name);
        typ^.BaseTyp := OPT.undftyp; OPS.Get(sym) (*forward ref*)
      ELSE qualident(id);
        IF id^.mode = OPT.Typ THEN
          IF id^.typ^.comp IN {OPT.Array, OPT.DynArr, OPT.Record} THEN
            typ^.BaseTyp := id^.typ
          ELSE typ^.BaseTyp := OPT.undftyp; err(57)
          END
        ELSE typ^.BaseTyp := OPT.undftyp; err(52)
        END
      END
    ELSE Type(typ^.BaseTyp, OPT.notyp);
      IF ~(typ^.BaseTyp^.comp IN {OPT.Array, OPT.DynArr, OPT.Record}) THEN
        typ^.BaseTyp := OPT.undftyp; err(57)
      END
    END
  END PointerType;

  PROCEDURE FormalParameters(VAR firstPar: OPT.Object; VAR resTyp: OPT.Struct);
    VAR mode: SHORTINT;
        par, first, last, res: OPT.Object; typ: OPT.Struct;
  BEGIN first := NIL; last := firstPar;
    IF (sym = OPS.ident) OR (sym = OPS.var) THEN
      LOOP
        IF sym = OPS.var THEN OPS.Get(sym); mode := OPT.VarPar ELSE mode := OPT.Var END ;
        LOOP
          IF sym = OPS.ident THEN
            OPT.Insert(OPS.name, par); OPS.Get(sym);
            par^.mode := mode; par^.link := NIL;
            IF first = NIL THEN first := par END ;
            IF firstPar = NIL THEN firstPar := par ELSE last^.link := par END ;
            last := par
          ELSE err(OPS.ident)
          END ;
          IF sym = OPS.comma THEN OPS.Get(sym)
          ELSIF sym = OPS.ident THEN err(OPS.comma)
          ELSIF sym = OPS.var THEN err(OPS.comma); OPS.Get(sym)
          ELSE EXIT
          END
        END ;
        CheckSym(OPS.colon); Type(typ, OPT.notyp);
        IF ((typ.comp = OPT.Array) OR (typ.comp = OPT.Record))
         & (typ.strobj = NIL) THEN
          err(-309)
        END;
        IF mode = OPT.Var THEN typ^.pvused := TRUE END ;
        (* typ^.pbused is set when parameter type name is parsed *)
        WHILE first # NIL DO first^.typ := typ; first := first^.link END ;
        IF sym = OPS.semicolon THEN OPS.Get(sym)
        ELSIF sym = OPS.ident THEN err(OPS.semicolon)
        ELSE EXIT
        END
      END
    END ;
    CheckSym(OPS.rparen);
    IF sym = OPS.colon THEN
      OPS.Get(sym); resTyp := OPT.undftyp;
      IF sym = OPS.ident THEN qualident(res);
        IF res^.mode = OPT.Typ THEN
          IF (res^.typ^.form < OPT.Comp) (*OR (res^.typ^.form >= Int8) & (res^.typ^.form <= Int64)*) THEN resTyp := res^.typ;
          ELSE err(54)
          END
        ELSE err(52)
        END
      ELSE err(OPS.ident)
      END
    ELSE resTyp := OPT.notyp
    END
  END FormalParameters;

  PROCEDURE TypeDecl(VAR typ, banned: OPT.Struct);
    VAR id: OPT.Object;
  BEGIN typ := OPT.undftyp;
    IF sym < OPS.lparen THEN err(12);
      REPEAT OPS.Get(sym) UNTIL sym >= OPS.lparen
    END ;
    IF sym = OPS.ident THEN qualident(id);
      IF id^.mode = OPT.Typ THEN
        IF id^.typ = banned THEN err(58) ELSE
          typ := id.typ
        END
      ELSE err(52)
      END
    ELSIF sym = OPS.array THEN
      OPS.Get(sym); ArrayType(typ, banned)
    ELSIF sym = OPS.record THEN
      OPS.Get(sym); RecordType(typ, banned);
      OPB.Inittd(TDinit, lastTDinit, typ); CheckSym(OPS.end)
    ELSIF sym = OPS.pointer THEN
      OPS.Get(sym); PointerType(typ)
    ELSIF sym = OPS.procedure THEN
      OPS.Get(sym); typ := OPT.NewStr(OPT.ProcTyp, OPT.Basic); CheckSysFlag(typ^.sysflag, 0);
      IF sym = OPS.lparen THEN
        OPS.Get(sym); OPT.OpenScope(level, NIL);
        FormalParameters(typ^.link, typ^.BaseTyp); OPT.CloseScope
      ELSE typ^.BaseTyp := OPT.notyp; typ^.link := NIL
      END
    ELSE err(12)
    END ;
    LOOP
      IF (sym >= OPS.semicolon) & (sym <= OPS.else) OR (sym = OPS.rparen) OR (sym = OPS.eof) THEN EXIT END;
      err(15); IF sym = OPS.ident THEN EXIT END;
      OPS.Get(sym)
    END
  END TypeDecl;

  PROCEDURE Type(VAR typ, banned: OPT.Struct);
  BEGIN TypeDecl(typ, banned);
    IF (typ^.form = OPT.Pointer) & (typ^.BaseTyp = OPT.undftyp) & (typ^.strobj = NIL) THEN err(0) END
  END Type;

  PROCEDURE selector(VAR x: OPT.Node);
    VAR obj, proc: OPT.Object; y: OPT.Node; typ: OPT.Struct; name: OPS.Name;
  BEGIN
    LOOP
      IF sym = OPS.lbrak THEN OPS.Get(sym);
        LOOP
          IF (x^.typ # NIL) & (x^.typ^.form = OPT.Pointer) THEN OPB.DeRef(x) END ;
          Expression(y); OPB.Index(x, y);
          IF sym = OPS.comma THEN OPS.Get(sym) ELSE EXIT END
        END ;
        CheckSym(OPS.rbrak)
      ELSIF sym = OPS.period THEN OPS.Get(sym);
        IF sym = OPS.ident THEN name := OPS.name; OPS.Get(sym);
          IF x^.typ # NIL THEN
            IF x^.typ^.form = OPT.Pointer THEN OPB.DeRef(x) END ;
            IF x^.typ^.comp = OPT.Record THEN
              OPT.FindField(name, x^.typ, obj); OPB.Field(x, obj);
              IF (obj # NIL) & (obj^.mode = OPT.TProc) THEN
                IF sym = OPS.arrow THEN  (* super call *) OPS.Get(sym);
                  y := x^.left;
                  IF y^.class = OPT.Nderef THEN y := y^.left END ;  (* y = record variable *)
                  IF y^.obj # NIL THEN
                    proc := OPT.topScope;  (* find innermost scope which owner is a OPT.TProc *)
                    WHILE (proc^.link # NIL) & (proc^.link^.mode # OPT.TProc) DO proc := proc^.left END ;
                    IF (proc^.link = NIL) OR (proc^.link^.link # y^.obj) THEN err(75) END ;
                    typ := y^.obj^.typ;
                    IF typ^.form = OPT.Pointer THEN typ := typ^.BaseTyp END ;
                    OPT.FindField(x^.obj^.name, typ^.BaseTyp, proc);
                    IF proc # NIL THEN x^.subcl := OPT.super ELSE err(74) END
                  ELSE err(75)
                  END
                END ;
                IF (obj^.typ # OPT.notyp) & (sym # OPS.lparen) THEN err(OPS.lparen) END
              END
            ELSE err(53)
            END
          ELSE err(52)
          END
        ELSE err(OPS.ident)
        END
      ELSIF sym = OPS.arrow THEN OPS.Get(sym); OPB.DeRef(x)
      ELSIF (sym = OPS.lparen) & (x^.class < OPT.Nconst) & (x^.typ^.form # OPT.ProcTyp) &
          ((x^.obj = NIL) OR (x^.obj^.mode # OPT.TProc)) THEN
        OPS.Get(sym);
        IF sym = OPS.ident THEN
          qualident(obj);
          IF obj^.mode = OPT.Typ THEN OPB.TypTest(x, obj, TRUE)
          ELSE err(52)
          END
        ELSE err(OPS.ident)
        END ;
        CheckSym(OPS.rparen)
      ELSE EXIT
      END
    END
  END selector;

  PROCEDURE ActualParameters(VAR aparlist: OPT.Node; fpar: OPT.Object);
    VAR apar, last: OPT.Node;
  BEGIN aparlist := NIL; last := NIL;
    IF sym # OPS.rparen THEN
      LOOP Expression(apar);
        IF fpar # NIL THEN
          OPB.Param(apar, fpar); OPB.Link(aparlist, last, apar);
          fpar := fpar^.link;
        ELSE err(64)
        END ;
        IF sym = OPS.comma THEN OPS.Get(sym)
        ELSIF (OPS.lparen <= sym) & (sym <= OPS.ident) THEN err(OPS.comma)
        ELSE EXIT
        END
      END
    END ;
    IF fpar # NIL THEN err(65) END
  END ActualParameters;

  PROCEDURE StandProcCall(VAR x: OPT.Node);
    VAR y: OPT.Node; m: SHORTINT; n: INTEGER;
  BEGIN m := SHORT(SHORT(x^.obj^.adr)); n := 0;
    IF sym = OPS.lparen THEN OPS.Get(sym);
      IF sym # OPS.rparen THEN
        LOOP
          IF n = 0 THEN Expression(x); OPB.StPar0(x, m); n := 1
          ELSIF n = 1 THEN Expression(y); OPB.StPar1(x, y, m); n := 2
          ELSE Expression(y); OPB.StParN(x, y, m, n); INC(n)
          END ;
          IF sym = OPS.comma THEN OPS.Get(sym)
          ELSIF (OPS.lparen <= sym) & (sym <= OPS.ident) THEN err(OPS.comma)
          ELSE EXIT
          END
        END ;
        CheckSym(OPS.rparen)
      ELSE OPS.Get(sym)
      END ;
      OPB.StFct(x, m, n)
    ELSE err(OPS.lparen)
    END ;
    IF (level > 0) & ((m = OPT.newfn) OR (m = OPT.sysnewfn)) THEN OPT.topScope^.link^.leaf := FALSE END
  END StandProcCall;

  PROCEDURE Element(VAR x: OPT.Node);
    VAR y: OPT.Node;
  BEGIN Expression(x);
    IF sym = OPS.upto THEN
      OPS.Get(sym); Expression(y); OPB.SetRange(x, y)
    ELSE OPB.SetElem(x)
    END
  END Element;

  PROCEDURE Sets(VAR x: OPT.Node);
    VAR y: OPT.Node;
  BEGIN
    IF sym # OPS.rbrace THEN
      Element(x);
      LOOP
        IF sym = OPS.comma THEN OPS.Get(sym)
        ELSIF (OPS.lparen <= sym) & (sym <= OPS.ident) THEN err(OPS.comma)
        ELSE EXIT
        END ;
        Element(y); OPB.Op(OPS.plus, x, y)
      END
    ELSE x := OPB.EmptySet()
    END ;
    CheckSym(OPS.rbrace)
  END Sets;

  PROCEDURE Factor(VAR x: OPT.Node);
    VAR fpar, id: OPT.Object; apar: OPT.Node;
  BEGIN
    IF sym < OPS.lparen THEN err(13);
      REPEAT OPS.Get(sym) UNTIL sym >= OPS.lparen
    END ;
    IF sym = OPS.ident THEN
      qualident(id); x := OPB.NewLeaf(id); selector(x);
      IF (x^.class = OPT.Nproc) & (x^.obj^.mode = OPT.SProc) THEN StandProcCall(x)  (* x may be NIL *)
      ELSIF sym = OPS.lparen THEN
        OPS.Get(sym); OPB.PrepCall(x, fpar);
        ActualParameters(apar, fpar);
        OPB.Call(x, apar, fpar);
        CheckSym(OPS.rparen);
        IF level > 0 THEN OPT.topScope^.link^.leaf := FALSE END
      END
    ELSIF sym = OPS.number THEN
      CASE OPS.numtyp OF
      | OPS.char:     x := OPB.NewIntConst(OPS.intval); x^.typ := OPT.chartyp
      | OPS.integer:  x := OPB.NewIntConst(OPS.intval)
      | OPS.real:     x := OPB.NewRealConst(OPS.realval, OPT.realtyp)
      | OPS.longreal: x := OPB.NewRealConst(OPS.lrlval, OPT.lrltyp)
      ELSE
         OPM.LogWStr("unhandled case in OPP.Factor, OPS.numtyp = "); OPM.LogWNum(OPS.numtyp, 0); OPM.LogWLn;
      END ;
      OPS.Get(sym)
    ELSIF sym = OPS.string THEN
      x := OPB.NewString(OPS.str, OPS.intval); OPS.Get(sym)
    ELSIF sym = OPS.nil THEN
      x := OPB.Nil(); OPS.Get(sym)
    ELSIF sym = OPS.lparen THEN
      OPS.Get(sym); Expression(x); CheckSym(OPS.rparen)
    ELSIF sym = OPS.lbrak THEN
      OPS.Get(sym); err(OPS.lparen); Expression(x); CheckSym(OPS.rparen)
    ELSIF sym = OPS.lbrace THEN OPS.Get(sym); Sets(x)
    ELSIF sym = OPS.not THEN
      OPS.Get(sym); Factor(x); OPB.MOp(OPS.not, x)
    ELSE err(13); OPS.Get(sym); x := NIL
    END ;
    IF x = NIL THEN x := OPB.NewIntConst(1); x^.typ := OPT.undftyp END
  END Factor;

  PROCEDURE Term(VAR x: OPT.Node);
    VAR y: OPT.Node; mulop: SHORTINT;
  BEGIN Factor(x);
    WHILE (OPS.times <= sym) & (sym <= OPS.and) DO
      mulop := sym; OPS.Get(sym);
      Factor(y); OPB.Op(mulop, x, y)
    END
  END Term;

  PROCEDURE SimpleExpression(VAR x: OPT.Node);
    VAR y: OPT.Node; addop: SHORTINT;
  BEGIN
    IF sym = OPS.minus THEN OPS.Get(sym); Term(x); OPB.MOp(OPS.minus, x)
    ELSIF sym = OPS.plus THEN OPS.Get(sym); Term(x); OPB.MOp(OPS.plus, x)
    ELSE Term(x)
    END ;
    WHILE (OPS.plus <= sym) & (sym <= OPS.or) DO
      addop := sym; OPS.Get(sym);
      Term(y); OPB.Op(addop, x, y)
    END
  END SimpleExpression;

  PROCEDURE Expression(VAR x: OPT.Node);
    VAR y: OPT.Node; obj: OPT.Object; relation: SHORTINT;
  BEGIN SimpleExpression(x);
    IF (OPS.eql <= sym) & (sym <= OPS.geq) THEN
      relation := sym; OPS.Get(sym);
      SimpleExpression(y); OPB.Op(relation, x, y)
    ELSIF sym = OPS.in THEN
      OPS.Get(sym); SimpleExpression(y); OPB.In(x, y)
    ELSIF sym = OPS.is THEN
      OPS.Get(sym);
      IF sym = OPS.ident THEN
        qualident(obj);
        IF obj^.mode = OPT.Typ THEN OPB.TypTest(x, obj, FALSE)
        ELSE err(52)
        END
      ELSE err(OPS.ident)
      END
    END
  END Expression;

  PROCEDURE Receiver(VAR mode: SHORTINT; VAR name: OPS.Name; VAR typ, rec: OPT.Struct);
    VAR obj: OPT.Object;
  BEGIN typ := OPT.undftyp; rec := NIL;
    IF sym = OPS.var THEN OPS.Get(sym); mode := OPT.VarPar ELSE mode := OPT.Var END ;
    name := OPS.name; CheckSym(OPS.ident); CheckSym(OPS.colon);
    IF sym = OPS.ident THEN OPT.Find(obj); OPS.Get(sym);
      IF obj = NIL THEN err(0)
      ELSIF obj^.mode # OPT.Typ THEN err(72)
      ELSE typ := obj^.typ; rec := typ;
        IF rec^.form = OPT.Pointer THEN rec := rec^.BaseTyp END ;
        IF ~((mode = OPT.Var) & (typ^.form = OPT.Pointer) & (rec^.comp = OPT.Record) OR
          (mode = OPT.VarPar) & (typ^.comp = OPT.Record)) THEN err(70); rec := NIL END ;
        IF (rec # NIL) & (rec^.mno # level) THEN err(72); rec := NIL END
      END
    ELSE err(OPS.ident)
    END ;
    CheckSym(OPS.rparen);
    IF rec = NIL THEN rec := OPT.NewStr(OPT.Comp, OPT.Record); rec^.BaseTyp := NIL END
  END Receiver;

  PROCEDURE Extends(x, b: OPT.Struct): BOOLEAN;
  BEGIN
    IF (b^.form = OPT.Pointer) & (x^.form = OPT.Pointer) THEN b := b^.BaseTyp; x := x^.BaseTyp END ;
    IF (b^.comp = OPT.Record) & (x^.comp = OPT.Record) THEN
      REPEAT x := x^.BaseTyp UNTIL (x = NIL) OR (x = b)
    END ;
    RETURN x = b
  END Extends;

  PROCEDURE ProcedureDeclaration(VAR x: OPT.Node);
    VAR proc, fwd: OPT.Object;
      name: OPS.Name;
      mode, vis: SHORTINT;
      forward: BOOLEAN;

    PROCEDURE GetCode;
      VAR ext: OPT.ConstExt; n: INTEGER; c: SYSTEM.INT64;
    BEGIN
      ext := OPT.NewExt(); proc^.conval^.ext := ext; n := 0;
      IF sym = OPS.string THEN
        WHILE OPS.str[n] # 0X DO ext[n+1] := OPS.str[n]; INC(n) END ;
        ext^[0] := CHR(n); OPS.Get(sym);
        (*
          Console.String("Code procedure, length "); Console.Int(n,1); Console.Ln;
          Console.String('  "'); Console.String(ext^); Console.String('"'); Console.Ln;
        *)
      ELSE
        LOOP
          IF sym = OPS.number THEN c := OPS.intval; INC(n);
            IF (c < 0) OR (c > 255) OR (n = OPT.MaxConstLen) THEN
              err(64); c := 1; n := 1
            END ;
            OPS.Get(sym); ext^[n] := CHR(c)
          END ;
          IF sym = OPS.comma THEN OPS.Get(sym)
          ELSIF sym = OPS.number THEN err(OPS.comma)
          ELSE ext^[0] := CHR(n); EXIT
          END
        END
      END ;
      INCL(proc^.conval^.setval, OPT.hasBody)
    END GetCode;

    PROCEDURE GetParams;
    BEGIN
      proc^.vis := vis; proc^.mode := mode; proc^.typ := OPT.notyp;
      proc^.conval := OPT.NewConst(); proc^.conval^.setval := {};
      IF sym = OPS.lparen THEN
        OPS.Get(sym); FormalParameters(proc^.link, proc^.typ)
      END ;
      IF fwd # NIL THEN
        OPB.CheckParameters(proc^.link, fwd^.link, TRUE);
        IF proc^.typ # fwd^.typ THEN err(117) END ;
        proc := fwd; OPT.topScope := proc^.scope;
        IF mode = OPT.IProc THEN proc^.mode := OPT.IProc END
      END
    END GetParams;

    PROCEDURE Body;
      VAR procdec, statseq: OPT.Node; c: LONGINT;
    BEGIN
      c := OPM.errpos;
      INCL(proc^.conval^.setval, OPT.hasBody);
      CheckSym(OPS.semicolon); Block(procdec, statseq);
      OPB.Enter(procdec, statseq, proc); x := procdec;
      x^.conval := OPT.NewConst(); x^.conval^.intval := c;
      IF sym = OPS.ident THEN
        IF OPS.name # proc^.name THEN err(4) END ;
        OPS.Get(sym)
      ELSE err(OPS.ident)
      END
    END Body;

    PROCEDURE TProcDecl;
      VAR baseProc: OPT.Object;
        objTyp, recTyp: OPT.Struct;
        objMode: SHORTINT;
        objName: OPS.Name;
    BEGIN
      OPS.Get(sym); mode := OPT.TProc;
      IF level > 0 THEN err(73) END ;
      Receiver(objMode, objName, objTyp, recTyp);
      IF sym = OPS.ident THEN
        name := OPS.name; CheckMark(vis);
        OPT.FindField(name, recTyp, fwd);
        OPT.FindField(name, recTyp^.BaseTyp, baseProc);
        IF (baseProc # NIL) & (baseProc^.mode # OPT.TProc) THEN baseProc := NIL END ;
        IF fwd = baseProc THEN fwd := NIL END ;
        IF (fwd # NIL) & (fwd^.mnolev # level) THEN fwd := NIL END ;
        IF (fwd # NIL) & (fwd^.mode = OPT.TProc) & ~(OPT.hasBody IN fwd^.conval^.setval) THEN
          (* there exists a corresponding forward declaration *)
          proc := OPT.NewObj(); proc^.leaf := TRUE;
          IF fwd^.vis # vis THEN err(118) END
        ELSE
          IF fwd # NIL THEN err(1); fwd := NIL END ;
          OPT.OpenScope(0, NIL); OPT.topScope^.right := recTyp^.link; OPT.Insert(name, proc);
          recTyp^.link := OPT.topScope^.right; OPT.CloseScope;
        END ;
        INC(level); OPT.OpenScope(level, proc);
        OPT.Insert(objName, proc^.link); proc^.link^.mode := objMode; proc^.link^.typ := objTyp;
        GetParams;
        IF baseProc # NIL THEN
          IF (objMode # baseProc^.link^.mode) OR ~Extends(objTyp, baseProc^.link^.typ) THEN err(115) END ;
          OPB.CheckParameters(proc^.link^.link, baseProc^.link^.link, FALSE);
          IF proc^.typ # baseProc^.typ THEN err(117) END ;
          IF (baseProc^.vis = OPT.external) & (proc^.vis = OPT.internal) &
            (recTyp^.strobj # NIL) & (recTyp^.strobj^.vis = OPT.external) THEN err(109)
          END ;
          INCL(proc^.conval^.setval, OPT.isRedef)
        END ;
        IF ~forward THEN Body END ;
        DEC(level); OPT.CloseScope
      ELSE err(OPS.ident)
      END
    END TProcDecl;

  BEGIN proc := NIL; forward := FALSE; x := NIL; mode := OPT.LProc;
    IF (sym # OPS.ident) & (sym # OPS.lparen) THEN
      IF sym = OPS.times THEN  (* mode set later in OPB.CheckAssign *)
      ELSIF sym = OPS.arrow THEN forward := TRUE
      ELSIF sym = OPS.plus THEN mode := OPT.IProc
      ELSIF sym = OPS.minus THEN mode := OPT.CProc
      ELSE err(OPS.ident)
      END ;
      IF (mode IN {OPT.IProc, OPT.CProc}) & ~OPT.SYSimported THEN err(135) END ;
      OPS.Get(sym)
    END ;
    IF sym = OPS.lparen THEN TProcDecl
    ELSIF sym = OPS.ident THEN OPT.Find(fwd);
      name := OPS.name; CheckMark(vis);
      IF (vis # OPT.internal) & (mode = OPT.LProc) THEN mode := OPT.XProc END ;
      IF (fwd # NIL) & ((fwd^.mnolev # level) OR (fwd^.mode = OPT.SProc)) THEN fwd := NIL END ;
      IF (fwd # NIL) & (fwd^.mode IN {OPT.LProc, OPT.XProc}) & ~(OPT.hasBody IN fwd^.conval^.setval) THEN
        (* there exists a corresponding forward declaration *)
        proc := OPT.NewObj(); proc^.leaf := TRUE;
        IF fwd^.vis # vis THEN err(118) END
      ELSE
        IF fwd # NIL THEN err(1); fwd := NIL END ;
        OPT.Insert(name, proc)
      END ;
      IF (mode # OPT.LProc) & (level > 0) THEN err(73) END ;
      INC(level); OPT.OpenScope(level, proc);
      proc^.link := NIL; GetParams;
      IF mode = OPT.CProc THEN GetCode
      ELSIF ~forward THEN Body
      END ;
      DEC(level); OPT.CloseScope
    ELSE err(OPS.ident)
    END
  END ProcedureDeclaration;

  PROCEDURE CaseLabelList(VAR lab: OPT.Node; LabelTyp: OPT.Struct; VAR n: INTEGER; VAR tab: CaseTable);
    VAR x, y, lastlab: OPT.Node; i, f: INTEGER; xval, yval: LONGINT;
  BEGIN lab := NIL; lastlab := NIL;
    LOOP ConstExpression(x); f := x^.typ^.form;
      IF f IN {OPT.Int, OPT.Char} THEN  xval := OPM.Longint(x^.conval^.intval)
      ELSE err(61); xval := 1
      END;
      IF f = OPT.Int THEN
        IF ~(LabelTyp.form = OPT.Int) OR (LabelTyp.size < x.typ.size) THEN err(60) END
      ELSIF LabelTyp.form # f THEN err(60)
      END ;
      IF sym = OPS.upto THEN
        OPS.Get(sym); ConstExpression(y); yval := OPM.Longint(y^.conval^.intval);
        IF (y^.typ^.form # f) & ~((f = OPT.Int) & (y^.typ^.form = OPT.Int)) THEN err(60) END ;
        IF yval < xval THEN err(63); yval := xval END
      ELSE yval := xval
      END ;
      x^.conval^.intval2 := yval;
      (*enter label range into ordered table*)  i := n;
      IF i < OPM.MaxCases THEN
        LOOP
          IF i = 0 THEN EXIT END ;
          IF tab[i-1].low <= yval THEN
            IF tab[i-1].high >= xval THEN err(62) END ;
            EXIT
          END ;
          tab[i] := tab[i-1]; DEC(i)
        END ;
        tab[i].low := xval; tab[i].high := yval; INC(n)
      ELSE err(213)
      END ;
      OPB.Link(lab, lastlab, x);
      IF sym = OPS.comma THEN OPS.Get(sym)
      ELSIF (sym = OPS.number) OR (sym = OPS.ident) THEN err(OPS.comma)
      ELSE EXIT
      END
    END
  END CaseLabelList;

  PROCEDURE StatSeq(VAR stat: OPT.Node);
    VAR fpar, id, t, obj: OPT.Object; idtyp: OPT.Struct; e: BOOLEAN;
        s, x, y, z, apar, last, lastif: OPT.Node; pos: LONGINT; name: OPS.Name;

    PROCEDURE CasePart(VAR x: OPT.Node);
      VAR n: INTEGER; low, high: LONGINT; e: BOOLEAN;
          tab: CaseTable; cases, lab, y, lastcase: OPT.Node;
    BEGIN
      Expression(x); pos := OPM.errpos;
      IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
      ELSIF ~(x^.typ^.form IN {OPT.Char..OPT.Int}) THEN err(125)
      END ;
      CheckSym(OPS.of); cases := NIL; lastcase := NIL; n := 0;
      LOOP
        IF sym < OPS.bar THEN
          CaseLabelList(lab, x^.typ, n, tab);
          CheckSym(OPS.colon); StatSeq(y);
          OPB.Construct(OPT.Ncasedo, lab, y); OPB.Link(cases, lastcase, lab)
        END ;
        IF sym = OPS.bar THEN OPS.Get(sym) ELSE EXIT END
      END ;
      IF n > 0 THEN low := tab[0].low; high := tab[n-1].high;
        IF high - low > OPM.MaxCaseRange THEN err(209) END
      ELSE low := 1; high := 0
      END ;
      e := sym = OPS.else;
      IF e THEN OPS.Get(sym); StatSeq(y)
      ELSE
         y := NIL;
   OPM.Mark(-307, OPM.curpos); (* notice about no OPS.else symbol; -- noch *)
      END ;
      OPB.Construct(OPT.Ncaselse, cases, y); OPB.Construct(OPT.Ncase, x, cases);
      cases^.conval := OPT.NewConst();
      cases^.conval^.intval := low; cases^.conval^.intval2 := high;
      IF e THEN cases^.conval^.setval := {1} ELSE cases^.conval^.setval := {} END
    END CasePart;

    PROCEDURE SetPos(x: OPT.Node);
    BEGIN
      x^.conval := OPT.NewConst(); x^.conval^.intval := pos
    END SetPos;

    PROCEDURE CheckBool(VAR x: OPT.Node);
    BEGIN
      IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126); x := OPB.NewBoolConst(FALSE)
      ELSIF x^.typ^.form # OPT.Bool THEN err(120); x := OPB.NewBoolConst(FALSE)
      END ;
      pos := OPM.errpos
    END CheckBool;

  BEGIN stat := NIL; last := NIL;
    LOOP x := NIL;
      IF sym < OPS.ident THEN err(14);
        REPEAT OPS.Get(sym) UNTIL sym >= OPS.ident
      END ;
      IF sym = OPS.ident THEN
        qualident(id); x := OPB.NewLeaf(id); selector(x);
        IF sym = OPS.becomes THEN
          OPS.Get(sym); Expression(y); OPB.Assign(x, y)
        ELSIF sym = OPS.eql THEN
          err(OPS.becomes); OPS.Get(sym); Expression(y); OPB.Assign(x, y)
        ELSIF (x^.class = OPT.Nproc) & (x^.obj^.mode = OPT.SProc) THEN
          StandProcCall(x);
          IF (x # NIL) & (x^.typ # OPT.notyp) THEN err(55) END
        ELSE OPB.PrepCall(x, fpar);
          IF sym = OPS.lparen THEN
            OPS.Get(sym); ActualParameters(apar, fpar); CheckSym(OPS.rparen)
          ELSE apar := NIL;
            IF fpar # NIL THEN err(65) END
          END ;
          OPB.Call(x, apar, fpar);
          IF x^.typ # OPT.notyp THEN err(55) END ;
          IF level > 0 THEN OPT.topScope^.link^.leaf := FALSE END
        END ;
        pos := OPM.errpos
      ELSIF sym = OPS.if THEN
        OPS.Get(sym); Expression(x); CheckBool(x); CheckSym(OPS.then); StatSeq(y);
        OPB.Construct(OPT.Nif, x, y); SetPos(x); lastif := x;
        WHILE sym = OPS.elsif DO
          OPS.Get(sym); Expression(y); CheckBool(y); CheckSym(OPS.then); StatSeq(z);
          OPB.Construct(OPT.Nif, y, z); SetPos(y); OPB.Link(x, lastif, y)
        END ;
        IF sym = OPS.else THEN OPS.Get(sym); StatSeq(y) ELSE y := NIL END ;
        OPB.Construct(OPT.Nifelse, x, y); CheckSym(OPS.end); OPB.OptIf(x); pos := OPM.errpos
      ELSIF sym = OPS.case THEN
        OPS.Get(sym); CasePart(x); CheckSym(OPS.end)
      ELSIF sym = OPS.while THEN
        OPS.Get(sym); Expression(x); CheckBool(x); CheckSym(OPS.do); StatSeq(y);
        OPB.Construct(OPT.Nwhile, x, y); CheckSym(OPS.end)
      ELSIF sym = OPS.repeat THEN
        OPS.Get(sym); StatSeq(x);
        IF sym = OPS.until THEN OPS.Get(sym); Expression(y); CheckBool(y)
        ELSE err(OPS.until)
        END ;
        OPB.Construct(OPT.Nrepeat, x, y)
      ELSIF sym = OPS.for THEN
        OPS.Get(sym);
        IF sym = OPS.ident THEN qualident(id);
          IF ~(id^.typ^.form = OPT.Int) THEN err(68) END ;
          CheckSym(OPS.becomes); Expression(y); pos := OPM.errpos;
          x := OPB.NewLeaf(id); OPB.Assign(x, y); SetPos(x);
          CheckSym(OPS.to); Expression(y); pos := OPM.errpos;
          IF y^.class # OPT.Nconst THEN
            name := "@@"; OPT.Insert(name, t); t^.name := "@for";  (* avoid err 1 *)
            t^.mode := OPT.Var; t^.typ := x^.left^.typ;
            obj := OPT.topScope^.scope;
            IF obj = NIL THEN OPT.topScope^.scope := t
            ELSE
              WHILE obj^.link # NIL DO obj := obj^.link END ;
              obj^.link := t
            END ;
            z := OPB.NewLeaf(t); OPB.Assign(z, y); SetPos(z); OPB.Link(stat, last, z);
            y := OPB.NewLeaf(t)
          ELSIF ~(y^.typ^.form = OPT.Int) OR (y.typ.size > x.left.typ.size) THEN err(113)
          END ;
          OPB.Link(stat, last, x);
          IF sym = OPS.by THEN OPS.Get(sym); ConstExpression(z) ELSE z := OPB.NewIntConst(1) END ;
          pos := OPM.errpos; x := OPB.NewLeaf(id);
          IF z^.conval^.intval > 0 THEN OPB.Op(OPS.leq, x, y)
          ELSIF z^.conval^.intval < 0 THEN OPB.Op(OPS.geq, x, y)
          ELSE err(63); OPB.Op(OPS.geq, x, y)
          END ;
          CheckSym(OPS.do); StatSeq(s);
          y := OPB.NewLeaf(id); OPB.StPar1(y, z, OPT.incfn); SetPos(y);
          IF s = NIL THEN s := y
          ELSE z := s;
            WHILE z^.link # NIL DO z := z^.link END ;
            z^.link := y
          END ;
          CheckSym(OPS.end); OPB.Construct(OPT.Nwhile, x, s)
        ELSE err(OPS.ident)
        END
      ELSIF sym = OPS.loop THEN
        OPS.Get(sym); INC(LoopLevel); StatSeq(x); DEC(LoopLevel);
        OPB.Construct(OPT.Nloop, x, NIL); CheckSym(OPS.end); pos := OPM.errpos
      ELSIF sym = OPS.with THEN
        OPS.Get(sym); idtyp := NIL; x := NIL;
        LOOP
          IF sym = OPS.ident THEN
            qualident(id); y := OPB.NewLeaf(id);
            IF (id # NIL) & (id^.typ^.form = OPT.Pointer) & ((id^.mode = OPT.VarPar) OR ~id^.leaf) THEN
              err(245)  (* jt: do not allow WITH on non-local pointers *)
            END ;
            CheckSym(OPS.colon);
            IF sym = OPS.ident THEN qualident(t);
              IF t^.mode = OPT.Typ THEN
                IF id # NIL THEN
                  idtyp := id^.typ; OPB.TypTest(y, t, FALSE); id^.typ := t^.typ
                ELSE err(130)
                END
              ELSE err(52)
              END
            ELSE err(OPS.ident)
            END
          ELSE err(OPS.ident)
          END ;
          pos := OPM.errpos; CheckSym(OPS.do); StatSeq(s); OPB.Construct(OPT.Nif, y, s); SetPos(y);
          IF idtyp # NIL THEN id^.typ := idtyp; idtyp := NIL END ;
          IF x = NIL THEN x := y; lastif := x ELSE OPB.Link(x, lastif, y) END ;
          IF sym = OPS.bar THEN OPS.Get(sym) ELSE EXIT END
        END;
        e := sym = OPS.else;
        IF e THEN OPS.Get(sym); StatSeq(s) ELSE s := NIL END ;
        OPB.Construct(OPT.Nwith, x, s); CheckSym(OPS.end);
        IF e THEN x^.subcl := 1 END
      ELSIF sym = OPS.exit THEN
        OPS.Get(sym);
        IF LoopLevel = 0 THEN err(46) END ;
        OPB.Construct(OPT.Nexit, x, NIL);
        pos := OPM.errpos
      ELSIF sym = OPS.return THEN OPS.Get(sym);
        IF sym < OPS.semicolon THEN Expression(x) END ;
        IF level > 0 THEN OPB.Return(x, OPT.topScope^.link)
        ELSE (* not standard Oberon *) OPB.Return(x, NIL)
        END ;
        pos := OPM.errpos
      END ;
      IF x # NIL THEN SetPos(x); OPB.Link(stat, last, x) END ;
      IF sym = OPS.semicolon THEN OPS.Get(sym)
      ELSIF (sym <= OPS.ident) OR (OPS.if <= sym) & (sym <= OPS.return) THEN err(OPS.semicolon)
      ELSE EXIT
      END
    END
  END StatSeq;

  PROCEDURE Block(VAR procdec, statseq: OPT.Node);
    VAR typ: OPT.Struct;
      obj, first, last: OPT.Object;
      x, lastdec: OPT.Node;
      i: INTEGER;

  BEGIN first := NIL; last := NIL; nofFwdPtr := 0;
    LOOP
      IF sym = OPS.const THEN
        OPS.Get(sym);
        WHILE sym = OPS.ident DO
          OPT.Insert(OPS.name, obj); CheckMark(obj^.vis);
          obj^.typ := OPT.sinttyp; obj^.mode := OPT.Var;  (* OPT.Var to avoid recursive definition *)
          IF sym = OPS.eql THEN
            OPS.Get(sym); ConstExpression(x)
          ELSIF sym = OPS.becomes THEN
            err(OPS.eql); OPS.Get(sym); ConstExpression(x)
          ELSE err(OPS.eql); x := OPB.NewIntConst(1)
          END ;
          obj^.mode := OPT.Con; obj^.typ := x^.typ; obj^.conval := x^.conval; (* ConstDesc ist not copied *)
          CheckSym(OPS.semicolon)
        END
      END ;
      IF sym = OPS.type THEN
        OPS.Get(sym);
        WHILE sym = OPS.ident DO
          OPT.Insert(OPS.name, obj); obj^.mode := OPT.Typ; obj^.typ := OPT.undftyp;
          CheckMark(obj^.vis);
          IF sym = OPS.eql THEN
            IF (obj^.name = "SHORTINT") OR
               (obj^.name = "INTEGER") OR
               (obj^.name = "LONGINT") OR
               (obj^.name = "HUGEINT") OR
               (obj^.name = "REAL") OR
               (obj^.name = "LONGREAL") OR
               (obj^.name = "SET") OR
               (obj^.name = "CHAR") OR
               (obj^.name = "TRUE") OR (obj^.name = "FALSE") THEN
              OPM.Mark(-310, OPM.curpos); (* notice about aliasing of predefined type *)
            END;
           OPS.Get(sym); TypeDecl(obj^.typ, obj^.typ)
          ELSIF (sym = OPS.becomes) OR (sym = OPS.colon) THEN
            err(OPS.eql); OPS.Get(sym); TypeDecl(obj^.typ, obj^.typ)
          ELSE err(OPS.eql)
          END ;
          IF obj^.typ^.strobj = NIL THEN obj^.typ^.strobj := obj END ;
          IF obj^.typ^.comp IN {OPT.Record, OPT.Array, OPT.DynArr} THEN
            i := 0;
            WHILE i < nofFwdPtr DO typ := FwdPtr[i]; INC(i);
              IF typ^.link^.name = obj^.name THEN typ^.BaseTyp := obj^.typ; typ^.link^.name := "" END
            END
          END ;
          CheckSym(OPS.semicolon)
        END
      END ;
      IF sym = OPS.var THEN
        OPS.Get(sym);
        WHILE sym = OPS.ident DO
          LOOP
            IF sym = OPS.ident THEN
              OPT.Insert(OPS.name, obj); CheckMark(obj^.vis);
              obj^.mode := OPT.Var; obj^.link := NIL; obj^.leaf := obj^.vis = OPT.internal; obj^.typ := OPT.undftyp;
              IF first = NIL THEN first := obj END ;
              IF last = NIL THEN OPT.topScope^.scope := obj ELSE last^.link := obj END ;
              last := obj
            ELSE err(OPS.ident)
            END ;
            IF sym = OPS.comma THEN OPS.Get(sym)
            ELSIF sym = OPS.ident THEN err(OPS.comma)
            ELSE EXIT
            END
          END ;
          CheckSym(OPS.colon); Type(typ, OPT.notyp);
          typ^.pvused := TRUE;
          IF typ^.comp = OPT.DynArr THEN typ := OPT.undftyp; err(88) END ;
          WHILE first # NIL DO first^.typ := typ; first := first^.link END ;
          CheckSym(OPS.semicolon)
        END
      END ;
      IF (sym < OPS.const) OR (sym > OPS.var) THEN EXIT END ;
    END ;
    i := 0;
    WHILE i < nofFwdPtr DO
      IF FwdPtr[i]^.link^.name # "" THEN err(128) END ;
      FwdPtr[i] := NIL;  (* garbage collection *)
      INC(i)
    END ;
    OPT.topScope^.adr := OPM.errpos;
    procdec := NIL; lastdec := NIL;
    WHILE sym = OPS.procedure DO
      OPS.Get(sym); ProcedureDeclaration(x);
      IF x # NIL THEN
        IF lastdec = NIL THEN procdec := x ELSE lastdec^.link := x END ;
        lastdec := x
      END ;
      CheckSym(OPS.semicolon)
    END ;
    IF sym = OPS.begin THEN OPS.Get(sym); StatSeq(statseq)
    ELSE statseq := NIL
    END ;
    IF (level = 0) & (TDinit # NIL) THEN
      lastTDinit^.link := statseq; statseq := TDinit
    END ;
    CheckSym(OPS.end)
  END Block;

  PROCEDURE Module*(VAR prog: OPT.Node; opt: SET);
    VAR impName, aliasName: OPS.Name;
        procdec, statseq: OPT.Node;
        c: LONGINT; done: BOOLEAN;
  BEGIN
    OPS.Init; LoopLevel := 0; level := 0; OPS.Get(sym);
    IF sym = OPS.module THEN OPS.Get(sym) ELSE err(16) END;
    IF sym = OPS.ident THEN
      OPM.LogCompiling(OPS.name);
      OPT.Init(OPS.name, opt); OPS.Get(sym); CheckSym(OPS.semicolon);
      IF sym = OPS.import THEN OPS.Get(sym);
        LOOP
          IF sym = OPS.ident THEN
            COPY(OPS.name, aliasName); COPY(aliasName, impName); OPS.Get(sym);
            IF sym = OPS.becomes THEN OPS.Get(sym);
              IF sym = OPS.ident THEN COPY(OPS.name, impName); OPS.Get(sym) ELSE err(OPS.ident) END
            END ;
            OPT.Import(aliasName, impName, done)
          ELSE err(OPS.ident)
          END ;
          IF sym = OPS.comma THEN OPS.Get(sym)
          ELSIF sym = OPS.ident THEN err(OPS.comma)
          ELSE EXIT
          END
        END ;
        CheckSym(OPS.semicolon)
      END ;
      IF OPM.noerr THEN TDinit := NIL; lastTDinit := NIL; c := OPM.errpos;
        Block(procdec, statseq); OPB.Enter(procdec, statseq, NIL); prog := procdec;
        prog^.conval := OPT.NewConst(); prog^.conval^.intval := c;
        IF sym = OPS.ident THEN
          IF OPS.name # OPT.SelfName THEN err(4) END ;
          OPS.Get(sym)
        ELSE err(OPS.ident)
        END ;
        IF sym # OPS.period THEN err(OPS.period) END
      END
    ELSE err(OPS.ident)
    END ;
    TDinit := NIL; lastTDinit := NIL
  END Module;

END OPP.
