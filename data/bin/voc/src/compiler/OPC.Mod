MODULE OPC;  (* copyright (c) J. Templ 12.7.95 / 3.7.96 *)
(* C source code generator version

  30.4.2000 jt, synchronized with BlackBox version, in particular
    various promotion rules changed (long) => (LONGINT), xxxL avoided
*)

  IMPORT OPT, OPM, Configuration, SYSTEM;

  CONST demoVersion = FALSE;


  CONST
    UndefinedType  = 0; (* named type not yet defined *)
    ProcessingType = 1; (* pointer type is being processed *)
    PredefinedType = 2; (* for all predefined types *)

    DefinedInHdr = 3+OPM.HeaderFile; (* named type has been defined in header file *)
    DefinedInBdy = 3+OPM.BodyFile;   (* named type has been defined in body file *)

    BasicIncludeFile = "SYSTEM";

    Export      = "export ";  (* particularily introduced for VC++ declspec() *)
    Extern      = "import ";  (* particularily introduced for VC++ declspec() *)
    LocalScope  = "_s";       (* name of a local intermediate scope (variable name) *)
    GlobalScope = "_s";       (* pointer to current scope extension *)
    LinkName    = "lnk";      (* pointer to previous scope field *)
    FlagExt     = "__h";
    LenExt      = "__len";
    DynTypExt   = "__typ";
    TagExt      = "__typ";
    Tab         = 9X;

    (* The following are defined as hex to avoid confusing editor syntax highlighting *)
    Backslash   = 5CX;
    DoubleQuote = 22X;


  VAR
    indentLevel: INTEGER;
    hashtab:     ARRAY 105 OF SHORTINT;
    keytab:      ARRAY 50, 9 OF CHAR;
    GlbPtrs:     BOOLEAN;
    BodyNameExt: ARRAY 13 OF CHAR;


  PROCEDURE Init*;
  BEGIN
    indentLevel := 0;
    BodyNameExt := "__init(void)"
  END Init;

  PROCEDURE Indent* (count: INTEGER);
  BEGIN INC(indentLevel, count)
  END Indent;

  PROCEDURE BegStat*;
    VAR i: INTEGER;
  BEGIN i := indentLevel;
    WHILE i > 0 DO OPM.Write(Tab); DEC (i) END
  END BegStat;

  PROCEDURE EndStat*;
  BEGIN OPM.Write(';'); OPM.WriteLn
  END EndStat;

  PROCEDURE BegBlk*;
  BEGIN OPM.Write('{'); OPM.WriteLn; INC(indentLevel)
  END BegBlk;

  PROCEDURE EndBlk*;
  BEGIN DEC(indentLevel); BegStat; OPM.Write('}'); OPM.WriteLn
  END EndBlk;

  PROCEDURE EndBlk0*;
  BEGIN DEC(indentLevel); BegStat; OPM.Write('}')
  END EndBlk0;

  PROCEDURE Str1(s: ARRAY OF CHAR; x: LONGINT);
    VAR ch: CHAR; i: INTEGER;
  BEGIN ch := s[0]; i := 0;
    WHILE ch # 0X DO
      IF ch = "#" THEN OPM.WriteInt(x)
      ELSE OPM.Write(ch);
      END ;
      INC(i); ch := s[i]
    END
  END Str1;

  PROCEDURE Length(VAR s: ARRAY OF CHAR): INTEGER;
    VAR i: INTEGER;
  BEGIN i := 0;
    WHILE s[i] # 0X DO INC(i) END ;
    RETURN i
  END Length;

  PROCEDURE PerfectHash (VAR s: ARRAY OF CHAR): INTEGER;
    VAR i, h: INTEGER;
  BEGIN i := 0; h := 0;
    WHILE (s[i] # 0X) & (i < 5) DO h := 3*h + ORD(s[i]); INC(i) END;
    RETURN h MOD 105
  END PerfectHash;

  PROCEDURE Ident* (obj: OPT.Object);
    VAR mode, level, h: INTEGER;
  BEGIN
    mode := obj^.mode; level := obj^.mnolev;
    IF (mode IN {OPT.Var, OPT.Typ, OPT.LProc}) & (level > 0) OR (mode IN {OPT.Fld, OPT.VarPar}) THEN
      OPM.WriteStringVar(obj^.name);
      h := PerfectHash(obj^.name);
      IF hashtab[h] >= 0 THEN
        IF keytab[hashtab[h]] = obj^.name THEN OPM.Write('_') END
      END
    ELSIF (mode = OPT.Typ) & (obj.typ.form IN {OPT.Int, OPT.Set}) THEN
      IF obj.typ = OPT.adrtyp THEN OPM.WriteString("ADDRESS")
      ELSE
        IF obj.typ.form = OPT.Int THEN OPM.WriteString("INT") ELSE OPM.WriteString("UINT") END;
        OPM.WriteInt(obj.typ.size*8)
      END
    ELSE
      IF (mode # OPT.Typ) OR (obj^.linkadr # PredefinedType) THEN
        IF mode = OPT.TProc THEN Ident(obj^.link^.typ^.strobj)
        ELSIF level < 0 THEN (* use unaliased module name *)
          OPM.WriteStringVar(OPT.GlbMod[-level].name);
          IF OPM.currFile = OPM.HeaderFile THEN OPT.GlbMod[-level].vis := 1 (*include in header file*) END ;
        ELSE OPM.WriteStringVar(OPM.modName)
        END ;
        OPM.Write('_')
      ELSIF (obj = OPT.sysptrtyp^.strobj)
         OR (obj = OPT.bytetyp^.strobj) THEN
        OPM.WriteString("SYSTEM_")
      END;
      OPM.WriteStringVar(obj^.name);
    END
  END Ident;

  PROCEDURE Stars (typ: OPT.Struct; VAR openClause: BOOLEAN);
    VAR pointers: INTEGER;
  BEGIN
    openClause := FALSE;
    IF ((typ^.strobj = NIL) OR (typ^.strobj^.name = "")) & (typ^.comp # OPT.Record) THEN
      IF typ^.comp IN {OPT.Array, OPT.DynArr} THEN
        Stars (typ^.BaseTyp, openClause);
        openClause := (typ^.comp = OPT.Array)
      ELSIF typ^.form = OPT.ProcTyp THEN
        OPM.Write('('); OPM.Write('*')
      ELSE
        pointers := 0;
        (*WHILE (typ^.strobj = NIL) & (typ^.form = OPT.Pointer) DO INC (pointers); typ := typ^.BaseTyp END ;
        IF (typ^.comp # OPT.DynArr) & (pointers # 0) THEN Stars (typ, openClause) END ;*)
        WHILE ((typ^.strobj = NIL) OR (typ^.strobj^.name = "")) & (typ^.form = OPT.Pointer) DO
           INC (pointers); typ := typ^.BaseTyp
        END ;
        IF pointers > 0 THEN
            IF typ^.comp # OPT.DynArr THEN Stars (typ, openClause) END ;
          IF openClause THEN OPM.Write('('); openClause := FALSE END ;
          WHILE pointers > 0 DO OPM.Write('*'); DEC (pointers) END
        END
      END
    END
  END Stars;

  PROCEDURE ^AnsiParamList (obj: OPT.Object; showParamNames: BOOLEAN);

  PROCEDURE DeclareObj(dcl: OPT.Object; scopeDef: BOOLEAN);
    VAR
      typ: OPT.Struct;
      varPar, openClause: BOOLEAN; form, comp: INTEGER;
  BEGIN
    typ := dcl^.typ;
    varPar := ((dcl^.mode = OPT.VarPar) & (typ^.comp # OPT.Array)) OR (typ^.comp = OPT.DynArr) OR scopeDef;
    Stars(typ, openClause);
    IF varPar THEN
      IF openClause THEN OPM.Write('(') END ;
      OPM.Write('*')
    END ;
    IF dcl.name # "" THEN Ident(dcl) END ;
    IF varPar & openClause THEN OPM.Write(')') END ;
    openClause := FALSE;
    LOOP
      form := typ^.form;
      comp := typ^.comp;
      IF ((typ^.strobj # NIL) & (typ^.strobj^.name # "")) OR (form = OPT.NoTyp) OR (comp = OPT.Record) THEN EXIT
      ELSIF (form = OPT.Pointer) & (typ^.BaseTyp^.comp # OPT.DynArr) THEN
        openClause := TRUE
      ELSIF (form = OPT.ProcTyp) OR (comp IN {OPT.Array, OPT.DynArr}) THEN
        IF openClause THEN OPM.Write(')'); openClause := FALSE END ;
        IF form = OPT.ProcTyp THEN
          OPM.Write(")"); AnsiParamList(typ^.link, FALSE);
          EXIT
        ELSIF comp = OPT.Array THEN
          OPM.Write('['); OPM.WriteInt(typ^.n); OPM.Write(']')
        END
      ELSE
        EXIT
      END ;
      typ := typ^.BaseTyp
    END
  END DeclareObj;

  PROCEDURE Andent*(typ: OPT.Struct);  (* ident of possibly anonymous record type *)
  BEGIN
    IF (typ^.strobj = NIL) OR (typ^.align >= 10000H) THEN
      OPM.WriteStringVar(OPM.modName); Str1("__#", typ^.align DIV 10000H)
    ELSE Ident(typ^.strobj)
    END
  END Andent;

  PROCEDURE Undefined(obj: OPT.Object): BOOLEAN;
  BEGIN
    (* imported anonymous types have obj^.name = "";
       used e.g. for repeating inherited fields *)
    RETURN (obj^.name = "")
        OR   (obj^.mnolev >= 0)
           & (obj^.linkadr # 3+OPM.currFile )
           & (obj^.linkadr # PredefinedType)
  END Undefined;

  PROCEDURE ^FieldList (typ: OPT.Struct; last: BOOLEAN; VAR off, n, curAlign: LONGINT);

  PROCEDURE DeclareBase(dcl: OPT.Object); (* declare the specifier of object dcl*)
    VAR typ, prev: OPT.Struct; obj: OPT.Object; nofdims: INTEGER; off, n, dummy: LONGINT;
  BEGIN
    typ := dcl^.typ; prev := typ;
    WHILE ((typ^.strobj = NIL) OR (typ^.comp = OPT.DynArr) OR Undefined(typ^.strobj))
        & (typ^.comp # OPT.Record)
        & (typ^.form # OPT.NoTyp)
        & ~((typ^.form = OPT.Pointer) & (typ^.BaseTyp^.comp = OPT.DynArr)) DO
      prev := typ; typ := typ^.BaseTyp;
    END ;
    obj := typ^.strobj;
    IF typ^.form = OPT.NoTyp THEN  (* proper procedure *)
      OPM.WriteString('void')
    ELSIF (obj # NIL) & ~Undefined(obj) THEN  (* named type, already declared *)
      Ident(obj)
    ELSIF typ^.comp = OPT.Record THEN
      OPM.WriteString('struct '); Andent(typ);
      IF (prev.form # OPT.Pointer) & ((obj # NIL) OR (dcl.name = "")) THEN
        (* named record type not yet declared OR anonymous record with empty name *)
        IF (typ^.BaseTyp # NIL) & (typ^.BaseTyp^.strobj.vis # OPT.internal) THEN
          OPM.WriteString(" { /* "); Ident(typ^.BaseTyp^.strobj); OPM.WriteString(" */"); OPM.WriteLn; Indent(1)
        ELSE OPM.Write(' '); BegBlk
        END ;
        FieldList(typ, TRUE, off, n, dummy);
        EndBlk0
      END
    ELSIF (typ^.form = OPT.Pointer) & (typ^.BaseTyp^.comp = OPT.DynArr) THEN
      typ := typ^.BaseTyp^.BaseTyp; nofdims := 1;
      WHILE typ^.comp = OPT.DynArr DO INC(nofdims); typ := typ^.BaseTyp END ;
      OPM.WriteString('struct '); BegBlk;
      BegStat; Str1("ADDRESS len[#]", nofdims); EndStat;
      BegStat; NEW(obj); NEW(obj.typ);  (* aux. object for easy declaration *)
      obj.typ.form := OPT.Comp; obj.typ.comp := OPT.Array; obj.typ.n := 1; obj.typ.BaseTyp := typ; obj.mode := OPT.Fld; obj.name := "data";
      obj.linkadr := UndefinedType; DeclareBase(obj); OPM.Write(' ');  DeclareObj(obj, FALSE);
      EndStat; EndBlk0
    END
  END DeclareBase;

  PROCEDURE NofPtrs* (typ: OPT.Struct): LONGINT;
    VAR fld: OPT.Object; btyp: OPT.Struct; n: LONGINT;
  BEGIN
    IF (typ^.form = OPT.Pointer) & (typ^.sysflag = 0) THEN RETURN 1
    ELSIF (typ^.comp = OPT.Record) & (typ^.sysflag MOD 100H = 0) THEN
      btyp := typ^.BaseTyp;
      IF btyp # NIL THEN n := NofPtrs(btyp) ELSE n := 0 END ;
      fld := typ^.link;
      WHILE (fld # NIL) & (fld^.mode = OPT.Fld) DO
        IF fld^.name # OPM.HdPtrName THEN n := n + NofPtrs(fld^.typ)
        ELSE INC(n)
        END ;
        fld := fld^.link
      END ;
      RETURN n
    ELSIF typ^.comp = OPT.Array THEN
      btyp := typ^.BaseTyp; n := typ^.n;
      WHILE btyp^.comp = OPT.Array DO n := btyp^.n * n; btyp := btyp^.BaseTyp END ;
      RETURN NofPtrs(btyp) * n
    ELSE RETURN 0
    END
  END NofPtrs;

  PROCEDURE PutPtrOffsets (typ: OPT.Struct; adr: LONGINT; VAR cnt: LONGINT);
    VAR fld: OPT.Object; btyp: OPT.Struct; n, i: LONGINT;
  BEGIN
    IF (typ^.form = OPT.Pointer) & (typ^.sysflag = 0) THEN
      OPM.WriteInt(adr); OPM.WriteString(", "); INC(cnt);
      IF cnt MOD 16 = 0 THEN OPM.WriteLn; OPM.Write(Tab) END
    ELSIF (typ^.comp = OPT.Record) & (typ^.sysflag MOD 100H = 0) THEN
      btyp := typ^.BaseTyp;
      IF btyp # NIL THEN PutPtrOffsets(btyp, adr, cnt) END ;
      fld := typ^.link;
      WHILE (fld # NIL) & (fld^.mode = OPT.Fld) DO
        IF fld^.name # OPM.HdPtrName THEN PutPtrOffsets(fld^.typ, adr + fld^.adr, cnt)
        ELSE
          OPM.WriteInt(adr + fld^.adr); OPM.WriteString(", "); INC(cnt);
          IF cnt MOD 16 = 0 THEN OPM.WriteLn; OPM.Write(Tab) END
        END ;
        fld := fld^.link
      END
    ELSIF typ^.comp = OPT.Array THEN
      btyp := typ^.BaseTyp; n := typ^.n;
      WHILE btyp^.comp = OPT.Array DO n := btyp^.n * n; btyp := btyp^.BaseTyp END ;
      IF NofPtrs(btyp) > 0 THEN i := 0;
        WHILE i < n DO PutPtrOffsets(btyp, adr + i * btyp^.size, cnt); INC(i) END
      END
    END
  END PutPtrOffsets;

  PROCEDURE InitTProcs(typ, obj: OPT.Object);
  BEGIN
    IF obj # NIL THEN
      InitTProcs(typ, obj^.left);
      IF obj^.mode = OPT.TProc THEN
        BegStat;
        OPM.WriteString("__INITBP(");
        Ident(typ); OPM.WriteString(', '); Ident(obj);
        Str1(", #)", obj^.adr DIV 10000H);
        EndStat
      END ;
      InitTProcs(typ, obj^.right)
    END
  END InitTProcs;

  PROCEDURE PutBase(typ: OPT.Struct);
  BEGIN
    IF typ # NIL THEN
      PutBase(typ^.BaseTyp);
      Ident(typ^.strobj); OPM.WriteString(DynTypExt); OPM.WriteString(", ")
    END
  END PutBase;

  PROCEDURE LenList(par: OPT.Object; ansiDefine, showParamName: BOOLEAN);
    VAR typ: OPT.Struct; dim: INTEGER;
  BEGIN
    IF showParamName THEN Ident(par); OPM.WriteString(LenExt) END ;
    dim := 1; typ := par^.typ^.BaseTyp;
    WHILE typ^.comp = OPT.DynArr DO
      IF ansiDefine THEN OPM.WriteString(", ADDRESS ") ELSE OPM.WriteString(', ') END ;
      IF showParamName THEN Ident(par); OPM.WriteString(LenExt); OPM.WriteInt(dim) END ;
      typ := typ^.BaseTyp; INC(dim)
    END
  END LenList;

  PROCEDURE DeclareParams(par: OPT.Object; macro: BOOLEAN);
  BEGIN
    OPM.Write('(');
    WHILE par # NIL DO
      IF macro THEN OPM.WriteStringVar(par.name)
      ELSE
        IF (par^.mode = OPT.Var) & (par^.typ^.form = OPT.Real) THEN OPM.Write("_") END ;
        Ident(par)
      END ;
      IF par^.typ^.comp = OPT.DynArr THEN
        OPM.WriteString(', '); LenList(par, FALSE, TRUE);
      ELSIF (par^.mode = OPT.VarPar) & (par^.typ^.comp = OPT.Record) THEN
        OPM.WriteString(', '); OPM.WriteStringVar(par.name); OPM.WriteString(TagExt)
      END ;
      par := par^.link;
      IF par # NIL THEN OPM.WriteString(', ') END
    END ;
    OPM.Write(')')
  END DeclareParams;

  PROCEDURE ^DefineType(str: OPT.Struct);
  PROCEDURE ^ProcHeader(proc: OPT.Object; define: BOOLEAN);

  PROCEDURE DefineTProcTypes(obj: OPT.Object);  (* define all types that are used in a OPT.TProc definition *)
    VAR par: OPT.Object;
  BEGIN
    IF obj^.typ # OPT.notyp THEN DefineType(obj^.typ) END ;
    par := obj^.link; WHILE par # NIL DO DefineType(par^.typ); par := par^.link END
  END DefineTProcTypes;

  PROCEDURE DeclareTProcs(obj: OPT.Object; VAR empty: BOOLEAN);
  BEGIN
    IF obj # NIL THEN
      DeclareTProcs(obj^.left, empty);
      IF obj^.mode = OPT.TProc THEN
        IF obj^.typ # OPT.notyp THEN DefineType(obj^.typ) END ;
        IF OPM.currFile = OPM.HeaderFile THEN
          IF obj^.vis = OPT.external THEN
            DefineTProcTypes(obj);
            OPM.WriteString(Extern); empty := FALSE;
            ProcHeader(obj, FALSE)
          END
        ELSE empty := FALSE;
          DefineTProcTypes(obj);
          IF obj^.vis = OPT.internal THEN OPM.WriteString('static ')
          ELSE OPM.WriteString(Export)
          END ;
          ProcHeader(obj, FALSE)
        END
      END ;
      DeclareTProcs(obj^.right, empty)
    END
  END DeclareTProcs;

  PROCEDURE BaseTProc*(obj: OPT.Object): OPT.Object;
    VAR typ, base: OPT.Struct; mno: LONGINT;
  BEGIN typ := obj^.link^.typ;  (* receiver type *)
    IF typ^.form = OPT.Pointer THEN typ := typ^.BaseTyp END ;
    base := typ^.BaseTyp; mno := obj^.adr DIV 10000H;
    WHILE (base # NIL) & (mno < base^.n) DO typ := base; base := typ^.BaseTyp END ;
    OPT.FindField(obj^.name, typ, obj);
    RETURN obj
  END BaseTProc;

  PROCEDURE DefineTProcMacros(obj: OPT.Object; VAR empty: BOOLEAN);
  BEGIN
    IF obj # NIL THEN
      DefineTProcMacros(obj^.left, empty);
      IF (obj^.mode = OPT.TProc) & (obj = BaseTProc(obj)) & ((OPM.currFile # OPM.HeaderFile) OR (obj^.vis = OPT.external)) THEN
        OPM.WriteString("#define __");
        Ident(obj);
        DeclareParams(obj^.link, TRUE);
        OPM.WriteString(" __SEND(");
        IF obj^.link^.typ^.form = OPT.Pointer THEN
          OPM.WriteString("__TYPEOF("); Ident(obj^.link); OPM.Write(")")
        ELSE Ident(obj^.link); OPM.WriteString(TagExt)
        END ;
        Str1(", #, ", obj^.adr DIV 10000H);
        IF obj^.typ = OPT.notyp THEN OPM.WriteString('void') ELSE Ident(obj^.typ^.strobj) END ;
        OPM.WriteString("(*)");
        AnsiParamList(obj^.link, FALSE);
        OPM.WriteString(", ");
        DeclareParams(obj^.link, TRUE);
        OPM.Write(")"); OPM.WriteLn
      END ;
      DefineTProcMacros(obj^.right, empty)
    END
  END DefineTProcMacros;

  PROCEDURE DefineType(str: OPT.Struct); (* define a type object *)
    VAR obj, field, par: OPT.Object; empty: BOOLEAN;
  BEGIN
    IF (OPM.currFile = OPM.BodyFile) OR (str^.ref < OPM.MaxStruct (*for hidden exports*) ) THEN
      obj := str^.strobj;
      IF (obj = NIL) OR Undefined(obj) THEN
        IF obj # NIL THEN (* check for cycles *)
          IF obj^.linkadr = ProcessingType THEN
            IF str^.form # OPT.Pointer THEN OPM.Mark(244, str^.txtpos); obj^.linkadr := PredefinedType END
          ELSE obj^.linkadr := ProcessingType
          END
        END ;
        IF str^.comp = OPT.Record THEN
          (* the following exports the base type of an exported type even if the former is non-exported *)
          IF str^.BaseTyp # NIL THEN DefineType(str^.BaseTyp) END ;
          field := str^.link;
          WHILE (field # NIL) & (field^.mode = OPT.Fld) DO
            IF (field^.vis # OPT.internal) OR (OPM.currFile = OPM.BodyFile) THEN DefineType(field^.typ) END ;
            field := field^.link
          END
        ELSIF str^.form = OPT.Pointer THEN
          IF str^.BaseTyp^.comp # OPT.Record THEN DefineType(str^.BaseTyp) END
        ELSIF str^.comp IN {OPT.Array, OPT.DynArr} THEN
          IF (str^.BaseTyp^.strobj # NIL) & (str^.BaseTyp^.strobj^.linkadr = ProcessingType) THEN (*cyclic base type*)
            OPM.Mark(244, str^ .txtpos); str^.BaseTyp^.strobj^.linkadr := PredefinedType
					END ;
          DefineType(str^.BaseTyp)
        ELSIF str^.form = OPT.ProcTyp THEN
          IF str^.BaseTyp # OPT.notyp THEN DefineType(str^.BaseTyp) END ;
          field := str^.link;
          WHILE field # NIL DO DefineType(field^.typ); field := field^.link END
        END
      END ;
      IF (obj # NIL) & Undefined(obj) THEN
        OPM.WriteString("typedef"); OPM.WriteLn; OPM.Write(Tab); Indent(1);
        obj^.linkadr := ProcessingType;
        DeclareBase(obj); OPM.Write(' ');
        obj^.typ^.strobj := NIL; (* SG: trick to make DeclareObj declare the type *)
        DeclareObj(obj, FALSE);
        obj^.typ^.strobj := obj; (* SG: revert trick *)
        obj^.linkadr := 3+OPM.currFile;
        EndStat; Indent(-1); OPM.WriteLn;
        IF obj^.typ^.comp = OPT.Record THEN empty := TRUE;
          DeclareTProcs(str^.link, empty); DefineTProcMacros(str^.link, empty);
          IF ~empty THEN OPM.WriteLn END
        END
      END
    END
  END DefineType;

  PROCEDURE Prefixed(x: OPT.ConstExt;  y: ARRAY OF CHAR): BOOLEAN;
    VAR i: INTEGER;
  BEGIN i := 0;
    WHILE x[i+1] = y[i] DO INC(i) END;
    RETURN y[i] = 0X;
  END Prefixed;

  PROCEDURE CProcDefs(obj: OPT.Object; vis: INTEGER);
    VAR i: INTEGER; ext: OPT.ConstExt;
  BEGIN
    IF obj # NIL THEN
      CProcDefs(obj^.left, vis);
      (* bug: obj.history cannot be used to cover unexported and deleted CProcs; use special flag obj.adr = 1 *)
      IF (obj^.mode = OPT.CProc) & (obj^.vis >= vis) & (obj^.adr = 1) THEN
        ext := obj.conval.ext; i := 1;
        IF (ext[1] # "#") & ~(Prefixed(ext, "extern ") OR Prefixed(ext, Extern)) THEN
          OPM.WriteString("#define "); Ident(obj);
          DeclareParams(obj^.link, TRUE);
          OPM.Write(Tab);
        END ;
        FOR i := i TO ORD(obj.conval.ext[0]) DO OPM.Write(obj.conval.ext[i]) END;
        OPM.WriteLn
      END ;
      CProcDefs(obj^.right, vis)
    END
  END CProcDefs;

  PROCEDURE TypeDefs* (obj: OPT.Object; vis(*replaced by test on currFile in DefineType*): INTEGER);
  BEGIN
    IF obj # NIL THEN
      TypeDefs(obj^.left, vis);
      (* test typ.txtpos to skip types that have been unexported; obj.history # removed is not enough!*)
      IF (obj^.mode = OPT.Typ) & (obj^.typ^.txtpos > 0) THEN DefineType(obj^.typ) END ;
      TypeDefs(obj^.right, vis)
    END
  END TypeDefs;

  PROCEDURE DefAnonRecs(n: OPT.Node);
    VAR o: OPT.Object; typ: OPT.Struct;
  BEGIN
    WHILE (n # NIL) & (n^.class = OPT.Ninittd) DO
      typ := n^.typ;
      IF (typ^.strobj = NIL) & ((OPM.currFile = OPM.BodyFile) OR (typ.ref < OPM.MaxStruct)) THEN
        DefineType(typ);  (* declare base and field types, if any *)
        NEW(o); o.typ := typ; o.name := ""; DeclareBase(o); EndStat; OPM.WriteLn
        (* simply defines a named struct, but not a type;
          o.name = "" signals field list expansion for DeclareBase in this very special case *)
      END ;
      n := n^.link
    END
  END DefAnonRecs;

  PROCEDURE TDescDecl* (typ: OPT.Struct);
    VAR nofptrs: LONGINT;
      o: OPT.Object;
  BEGIN
    BegStat; OPM.WriteString("__TDESC(");
    Andent(typ);
    Str1(", #", typ^.n + 1); Str1(", #) = {__TDFLDS(", NofPtrs(typ));
    OPM.Write(DoubleQuote);
    IF typ^.strobj # NIL THEN OPM.WriteStringVar(typ^.strobj^.name) END ;
    OPM.Write(DoubleQuote);
    Str1(', #), {', typ^.size);
    nofptrs := 0; PutPtrOffsets(typ, 0, nofptrs); Str1("#}}", -(nofptrs + 1) * OPM.AddressSize);
    EndStat
  END TDescDecl;

  PROCEDURE InitTDesc*(typ: OPT.Struct);
  BEGIN
    BegStat; OPM.WriteString("__INITYP(");
    Andent(typ); OPM.WriteString(", ");
    IF typ^.BaseTyp # NIL THEN Andent(typ^.BaseTyp) ELSE Andent(typ) END ;
    Str1(", #)", typ^.extlev);
    EndStat;
    IF typ^.strobj # NIL THEN InitTProcs(typ^.strobj, typ^.link) END
  END InitTDesc;

  PROCEDURE FillGap(gap, off, align: LONGINT; VAR n, curAlign: LONGINT);
  (* gap:      Required gap - already calculated based on alignment requirements
     off:      Current offset - where gap begins
     align:    Containing record type alignment
     n:        Next ordinal to use for private field names
     curAlign: Largest alignment of any field so far
  *)
    VAR adr: LONGINT;
  BEGIN
    adr := off; OPT.Align(adr, align);
    IF (curAlign < align) & (gap - (adr - off) >= align) THEN (* preserve alignment of the enclosing struct! *)
      DEC(gap, (adr - off) + align);
      BegStat;
      CASE align OF
      |2: OPM.WriteString("INT16")
      |4: OPM.WriteString("INT32")
      |8: OPM.WriteString("INT64")
      ELSE OPM.LogWLn; OPM.LogWStr("Unexpected enclosing alignment in FillGap.")
      END;
      Str1(" _prvt#", n); INC(n); EndStat;
      curAlign := align
    END ;
    IF gap > 0 THEN BegStat; Str1("char _prvt#", n); INC(n); Str1("[#]", gap); EndStat END
  END FillGap;

  PROCEDURE FieldList (typ: OPT.Struct; last: BOOLEAN; VAR off, n, curAlign: LONGINT);
    VAR fld: OPT.Object; base: OPT.Struct; gap, adr, align, fldAlign: LONGINT;
  BEGIN
    fld   := typ.link;
    align := typ^.align MOD 10000H;
    IF typ.BaseTyp # NIL THEN FieldList(typ.BaseTyp, FALSE, off, n, curAlign)
    ELSE off := 0; n := 0; curAlign := 1
    END;
    (* off:      Current offset into record
       align:    Overall (RECORD) alignment
       curAlign: Current alignment - largest alignment of any field so far
       n:        Next ordinal to use for private field names
    *)
    WHILE (fld # NIL) & (fld.mode = OPT.Fld) DO
      IF (OPM.currFile = OPM.HeaderFile) & (fld.vis = OPT.internal)
      OR (OPM.currFile = OPM.BodyFile)   & (fld.vis = OPT.internal) & (typ^.mno # 0) THEN
        (* Skip private fields *)
        fld := fld.link;
        WHILE (fld # NIL) & (fld.mode = OPT.Fld) & (fld.vis = OPT.internal) DO fld := fld.link END;
      ELSE
        (* mimic OPV.TypSize to detect gaps caused by private fields *)
        adr := off;
        fldAlign := OPT.BaseAlignment(fld^.typ);
        OPT.Align(adr, fldAlign);
        gap := fld.adr - adr;
        IF fldAlign > curAlign THEN curAlign := fldAlign END;
        IF gap > 0 THEN
          FillGap(gap, off, align, n, curAlign)
        END;
        BegStat; DeclareBase(fld); OPM.Write(' '); DeclareObj(fld, FALSE);
        off := fld.adr + fld.typ.size; base := fld.typ; fld := fld.link;
        WHILE (fld # NIL)
            & (fld.mode = OPT.Fld)
            & (fld.typ  = base)
            & (fld.adr  = off)
(* ?? *)    & ((OPM.currFile = OPM.BodyFile) OR (fld.vis # OPT.internal) OR (fld.typ.strobj = NIL)) DO
          OPM.WriteString(", "); DeclareObj(fld, FALSE); off := fld.adr + fld.typ.size; fld := fld.link
        END;
        EndStat
      END
    END;
    IF last THEN
      adr := typ.size - typ^.sysflag DIV 100H;
      IF adr = 0 THEN gap := 1 (* avoid empty struct *) ELSE gap := adr - off END ;
      IF gap > 0 THEN FillGap(gap, off, align, n, curAlign) END
    END
  END FieldList;

  PROCEDURE IdentList (obj: OPT.Object; vis: INTEGER);
  (* generate var and param lists; vis: 0 all global vars, local var, 1 exported(R) var, 2 par list, 3 scope var *)
    VAR base: OPT.Struct; first: BOOLEAN; lastvis: INTEGER;
  BEGIN
    base := NIL; first := TRUE;
    WHILE (obj # NIL) & (obj^.mode # OPT.TProc) DO
      IF (vis IN {0, 2}) OR ((vis = 1) & (obj^.vis # 0)) OR ((vis = 3) & ~obj^.leaf) THEN
        IF (obj^.typ # base) OR (obj^.vis # lastvis) THEN  (* new variable base type definition required *)
          IF ~first THEN EndStat END ;
          first := FALSE;
          base := obj^.typ; lastvis := obj^.vis;
          BegStat;
          IF (vis = 1) & (obj^.vis # OPT.internal) THEN OPM.WriteString(Extern)
          ELSIF (obj^.mnolev = 0) & (vis = 0) THEN
            IF obj^.vis = OPT.internal THEN OPM.WriteString('static ')
            ELSE OPM.WriteString(Export)
            END
          END ;
          IF (vis = 2) & (obj^.mode = OPT.Var) & (base^.form = OPT.Real) THEN OPM.WriteString("double")
          ELSE DeclareBase(obj)
          END
        ELSE OPM.Write(",");
        END ;
        OPM.Write(' ');
        IF (vis = 2) & (obj^.mode = OPT.Var) & (base^.form = OPT.Real) THEN OPM.Write("_") END ;
        DeclareObj(obj, vis = 3);
        IF obj^.typ^.comp = OPT.DynArr THEN (* declare len parameter(s) *)
          EndStat; BegStat;
          base := OPT.adrtyp;
          OPM.WriteString("ADDRESS "); LenList(obj, FALSE, TRUE)
        ELSIF (obj^.mode = OPT.VarPar) & (obj^.typ^.comp = OPT.Record) THEN
          EndStat; BegStat;
          OPM.WriteString("ADDRESS *"); Ident(obj); OPM.WriteString(TagExt);
          base := NIL
        ELSIF (OPM.ptrinit IN OPM.Options) & (vis = 0) & (obj^.mnolev > 0) & (obj^.typ^.form = OPT.Pointer) THEN
          OPM.WriteString(" = NIL")
        END
      END ;
      obj := obj^.link
    END ;
    IF ~first THEN EndStat END
  END IdentList;

  PROCEDURE AnsiParamList (obj: OPT.Object; showParamNames: BOOLEAN);
    VAR name: ARRAY 32 OF CHAR;
  BEGIN
    OPM.Write("(");
    IF (obj = NIL) OR (obj^.mode = OPT.TProc) THEN OPM.WriteString("void")
    ELSE
      LOOP
        DeclareBase(obj);
        IF showParamNames THEN
          OPM.Write(' '); DeclareObj(obj, FALSE)
        ELSE
          COPY(obj^.name, name);  obj^.name := ""; DeclareObj(obj, FALSE); COPY(name, obj^.name)
        END ;
        IF obj^.typ^.comp = OPT.DynArr THEN
          OPM.WriteString(", ADDRESS ");
          LenList(obj, TRUE, showParamNames)
        ELSIF (obj^.mode = OPT.VarPar) & (obj^.typ^.comp = OPT.Record) THEN
          OPM.WriteString(", ADDRESS *");
          IF showParamNames THEN Ident(obj); OPM.WriteString(TagExt) END
        END ;
        IF (obj^.link = NIL) OR (obj^.link.mode = OPT.TProc) THEN EXIT END ;
        OPM.WriteString(", ");
        obj := obj^.link
      END
    END ;
    OPM.Write(")")
  END AnsiParamList;

  PROCEDURE ProcHeader(proc: OPT.Object; define: BOOLEAN);
  BEGIN
    IF proc^.typ = OPT.notyp THEN OPM.WriteString('void') ELSE Ident(proc^.typ^.strobj) END ;
    OPM.Write(' '); Ident(proc); OPM.Write(' ');
    AnsiParamList(proc^.link, TRUE);
    IF ~define THEN OPM.Write(";") END ;
    OPM.WriteLn
  END ProcHeader;

  PROCEDURE ProcPredefs (obj: OPT.Object; vis: SHORTINT); (* forward declaration of procedures *)
  BEGIN
    IF obj # NIL THEN
      ProcPredefs(obj^.left, vis);
      IF (obj^.mode IN {OPT.LProc, OPT.XProc}) & (obj^.vis >= vis) & ((obj^.history # OPT.removed) OR (obj^.mode = OPT.LProc)) THEN
        (* previous OPT.XProc may be deleted or become OPT.LProc after interface change*)
        IF vis = OPT.external THEN OPM.WriteString(Extern)
        ELSIF obj^.vis = OPT.internal THEN OPM.WriteString('static ')
        ELSE OPM.WriteString(Export)
        END ;
        ProcHeader(obj, FALSE);
      END ;
      ProcPredefs(obj^.right, vis);
    END;
  END ProcPredefs;

  PROCEDURE Include(name: ARRAY OF CHAR);
  BEGIN
    OPM.WriteString("#include "); OPM.Write(DoubleQuote); OPM.WriteStringVar(name);
    OPM.WriteString(".h"); OPM.Write(DoubleQuote); OPM.WriteLn
  END Include;

  PROCEDURE IncludeImports(obj: OPT.Object; vis: INTEGER);
  BEGIN
    IF obj # NIL THEN
      IncludeImports(obj^.left, vis);
      IF (obj^.mode = OPT.Mod) & (obj^.mnolev # 0) & (OPT.GlbMod[-obj^.mnolev].vis >= vis) THEN  (* @self and SYSTEM have mnolev = 0 *)
        Include(OPT.GlbMod[-obj^.mnolev].name)  (* use unaliased module name *)
      END;
      IncludeImports(obj^.right, vis);
    END;
  END IncludeImports;

  PROCEDURE GenDynTypes (n: OPT.Node; vis: INTEGER);
    VAR typ: OPT.Struct;
  BEGIN
    WHILE (n # NIL) & (n^.class = OPT.Ninittd) DO
      typ := n^.typ;
      IF (vis = OPT.internal) OR (typ^.ref < OPM.MaxStruct (*type needed in symbol file*)) THEN
        BegStat;
        IF vis = OPT.external THEN OPM.WriteString(Extern)
        ELSIF (typ^.strobj # NIL) & (typ^.strobj^.mnolev > 0) THEN OPM.WriteString('static ')
        ELSE OPM.WriteString(Export)
        END ;
        OPM.WriteString("ADDRESS *"); Andent(typ); OPM.WriteString(DynTypExt);
        EndStat
      END ;
      n := n^.link
    END
  END GenDynTypes;

  PROCEDURE GenHdr*(n: OPT.Node);
  BEGIN
    (* includes are delayed until it is known which ones are needed in the header *)
    OPM.currFile := OPM.HeaderFile;
    DefAnonRecs(n);
    TypeDefs(OPT.topScope^.right, 1); OPM.WriteLn;
    IdentList(OPT.topScope^.scope, 1); OPM.WriteLn;
    GenDynTypes(n, OPT.external); OPM.WriteLn;
    ProcPredefs(OPT.topScope^.right, 1);
    OPM.WriteString(Extern); OPM.WriteString("void *");
    OPM.WriteStringVar(OPM.modName); OPM.WriteString(BodyNameExt);
    EndStat; OPM.WriteLn;
    CProcDefs(OPT.topScope^.right, 1); OPM.WriteLn;
    OPM.WriteString("#endif // "); OPM.WriteStringVar(OPM.modName); OPM.WriteLn
  END GenHdr;

  PROCEDURE GenHeaderMsg;
    VAR i: INTEGER;
  BEGIN
    OPM.WriteString("/* "); OPM.WriteString(Configuration.name);
    OPM.Write(" "); OPM.WriteString(Configuration.versionLong); OPM.Write (" "); (* noch *)
    FOR i := 0 TO MAX(SET) DO
      IF i IN OPM.Options THEN
        CASE i OF  (* c.f. ScanOptions in OPM *)
        | OPM.inxchk:         OPM.Write("x")
        | OPM.ranchk:         OPM.Write("r")
        | OPM.typchk:         OPM.Write("t")
        | OPM.newsf:          OPM.Write("s")
        | OPM.ptrinit:        OPM.Write("p")
        | OPM.assert:         OPM.Write("a")
        | OPM.extsf:          OPM.Write("e")
        | OPM.mainprog:       OPM.Write("m")
        | OPM.dontasm:        OPM.Write("S")
        | OPM.dontlink:       OPM.Write("c")
        | OPM.mainlinkstat:   OPM.Write("M")
        | OPM.notcoloroutput: OPM.Write("f")
        | OPM.forcenewsym:    OPM.Write("F")
        | OPM.verbose:        OPM.Write("v")
        ELSE OPM.LogWStr ("( more options defined in OPM than checked in OPC.GenHeaderMsg, if you are a compiler developer, add them to OPC.GenHeaderMsg"); OPM.LogWLn;
        END
      END
    END;
    OPM.WriteString(" */"); OPM.WriteLn
  END GenHeaderMsg;

  PROCEDURE GenHdrIncludes*;
  BEGIN
    OPM.currFile := OPM.HeaderInclude;
    GenHeaderMsg;
    OPM.WriteLn;
    OPM.WriteString("#ifndef "); OPM.WriteStringVar(OPM.modName); OPM.WriteString(FlagExt); OPM.WriteLn;
    OPM.WriteString("#define "); OPM.WriteStringVar(OPM.modName); OPM.WriteString(FlagExt); OPM.WriteLn;
    OPM.WriteLn;

    Include(BasicIncludeFile);
    IncludeImports(OPT.topScope^.right, 1); OPM.WriteLn
  END GenHdrIncludes;

  PROCEDURE GenBdy*(n: OPT.Node);
  BEGIN
    OPM.currFile := OPM.BodyFile;
    GenHeaderMsg;
    OPM.WriteLn;

    (* Define model dependent type sizes *)
    OPM.WriteString("#define SHORTINT INT");  OPM.WriteInt(OPT.sinttyp.size*8); OPM.WriteLn;
    OPM.WriteString("#define INTEGER  INT");  OPM.WriteInt(OPT.inttyp.size*8);  OPM.WriteLn;
    OPM.WriteString("#define LONGINT  INT");  OPM.WriteInt(OPT.linttyp.size*8); OPM.WriteLn;
    OPM.WriteString("#define SET      UINT"); OPM.WriteInt(OPT.settyp.size*8);  OPM.WriteLn;
    OPM.WriteLn;

    Include(BasicIncludeFile);
    IncludeImports(OPT.topScope^.right, 0); OPM.WriteLn;
    DefAnonRecs(n);
    TypeDefs(OPT.topScope^.right, 0); OPM.WriteLn;
    IdentList(OPT.topScope^.scope, 0); OPM.WriteLn;
    GenDynTypes(n, OPT.internal); OPM.WriteLn;
    ProcPredefs(OPT.topScope^.right, 0); OPM.WriteLn;
    CProcDefs(OPT.topScope^.right, 0); OPM.WriteLn
  END GenBdy;

  PROCEDURE RegCmds(obj: OPT.Object);
  BEGIN
    IF obj # NIL THEN
      RegCmds(obj^.left);
      IF (obj^.mode = OPT.XProc) & (obj^.history # OPT.removed) THEN
        IF (obj^.vis # 0) & (obj^.link = NIL) & (obj^.typ = OPT.notyp) THEN (*command*)
          BegStat; OPM.WriteString('__REGCMD("');
          OPM.WriteStringVar(obj.name); OPM.WriteString('", '); Ident(obj); OPM.Write(")"); EndStat
        END
      END ;
      RegCmds(obj^.right)
    END
  END RegCmds;

  PROCEDURE InitImports(obj: OPT.Object);
  BEGIN
    IF obj # NIL THEN
      InitImports(obj^.left);
      IF (obj^.mode = OPT.Mod) & (obj^.mnolev # 0) THEN
        BegStat; OPM.WriteString("__MODULE_IMPORT(");
        OPM.WriteStringVar(OPT.GlbMod[-obj^.mnolev].name);
        OPM.Write(')'); EndStat
      END ;
      InitImports(obj^.right)
    END
  END InitImports;

  PROCEDURE GenEnumPtrs* (var: OPT.Object);
    VAR typ: OPT.Struct; n: LONGINT;
  BEGIN GlbPtrs := FALSE;
    WHILE var # NIL DO
      typ := var^.typ;
      IF NofPtrs(typ) > 0 THEN
        IF ~GlbPtrs THEN GlbPtrs := TRUE;
          OPM.WriteString("static void EnumPtrs(void (*P)(void*))"); OPM.WriteLn;
          BegBlk
        END ;
        BegStat;
        IF typ^.form = OPT.Pointer THEN
          OPM.WriteString("P("); Ident(var); OPM.Write(")");
        ELSIF typ^.comp = OPT.Record THEN
          OPM.WriteString("__ENUMR(&"); Ident(var); OPM.WriteString(", ");
          Andent(typ); OPM.WriteString(DynTypExt); Str1(", #", typ^.size); OPM.WriteString(", 1, P)")
        ELSIF typ^.comp = OPT.Array THEN
          n := typ^.n; typ := typ^.BaseTyp;
          WHILE typ^.comp = OPT.Array DO n := n * typ^.n; typ := typ^.BaseTyp END ;
          IF typ^.form = OPT.Pointer THEN
            OPM.WriteString("__ENUMP("); Ident(var); Str1(", #, P)", n)
          ELSIF typ^.comp = OPT.Record THEN
            OPM.WriteString("__ENUMR("); Ident(var); OPM.WriteString(", ");
            Andent(typ); OPM.WriteString(DynTypExt); Str1(", #", typ^.size); Str1(", #, P)", n)
          END
        END ;
        EndStat
      END ;
      var := var^.link
    END ;
    IF GlbPtrs THEN
      EndBlk; OPM.WriteLn
    END
  END GenEnumPtrs;

  PROCEDURE EnterBody*;
  BEGIN
    OPM.WriteLn; OPM.WriteString(Export);
    IF OPM.mainprog IN OPM.Options THEN
      OPM.WriteString("int main(int argc, char **argv)"); OPM.WriteLn;
    ELSE
      OPM.WriteString("void *");
      OPM.WriteString(OPM.modName); OPM.WriteString(BodyNameExt); OPM.WriteLn;
    END ;
    BegBlk; BegStat;
    IF OPM.mainprog IN OPM.Options THEN OPM.WriteString("__INIT(argc, argv)") ELSE OPM.WriteString("__DEFMOD") END ;
    EndStat;
    IF (OPM.mainprog IN OPM.Options) & demoVersion THEN BegStat;
      OPM.WriteString('/*don`t do it!*/ printf("DEMO VERSION: DO NOT USE THIS PROGRAM FOR ANY COMMERCIAL PURPOSE\n")');
      EndStat
    END ;
    InitImports(OPT.topScope^.right);
    BegStat;
    IF OPM.mainprog IN OPM.Options THEN OPM.WriteString('__REGMAIN("') ELSE OPM.WriteString('__REGMOD("') END ;
    OPM.WriteString(OPM.modName);
    IF GlbPtrs THEN OPM.WriteString('", EnumPtrs)') ELSE OPM.WriteString('", 0)') END ;
    EndStat;
    IF OPM.modName # "SYSTEM" THEN RegCmds(OPT.topScope) END
  END EnterBody;

  PROCEDURE ExitBody*;
  BEGIN
    BegStat;
    IF OPM.mainprog IN OPM.Options THEN OPM.WriteString("__FINI;") ELSE OPM.WriteString("__ENDMOD;") END ;
    OPM.WriteLn; EndBlk
  END ExitBody;

  PROCEDURE DefineInter* (proc: OPT.Object); (* define intermediate scope record and variable *)
    VAR scope: OPT.Object;
  BEGIN
    scope := proc^.scope;
    OPM.WriteString('static '); OPM.WriteString('struct '); OPM.WriteStringVar(scope^.name); OPM.Write(' ');
    BegBlk;
    IdentList(proc^.link, 3); (* parameters *)
    IdentList(scope^.scope, 3); (* local variables *)
    BegStat; (* scope link field declaration *)
    OPM.WriteString('struct '); OPM.WriteStringVar (scope^.name);
    OPM.Write(' '); OPM.Write('*'); OPM.WriteString(LinkName); EndStat;
    EndBlk0; OPM.Write(' ');
    OPM.Write('*'); OPM.WriteStringVar (scope^.name); OPM.WriteString(GlobalScope); EndStat; OPM.WriteLn;
    ProcPredefs (scope^.right, 0);
    OPM.WriteLn;
  END DefineInter;

  PROCEDURE NeedsRetval*(proc: OPT.Object): BOOLEAN; (* aux. variable __retval needed for return *)
  BEGIN (* simple rule; ignores DUPlicated value arrays because they use alloca. *)
    RETURN (proc^.typ # OPT.notyp) & ~proc^.scope^.leaf
  END NeedsRetval;

  PROCEDURE EnterProc* (proc: OPT.Object);
    VAR var, scope: OPT.Object; typ: OPT.Struct; dim: INTEGER;
  BEGIN
    IF proc^.vis # OPT.external THEN OPM.WriteString('static ') END ;
    ProcHeader(proc, TRUE);
    BegBlk;
    scope := proc^.scope;
    IdentList(scope^.scope, 0);
    IF ~scope^.leaf THEN (* declare intermediate procedure scope record variable*)
      BegStat; OPM.WriteString('struct '); OPM.WriteStringVar (scope^.name);
      OPM.Write(' '); OPM.WriteString(LocalScope); EndStat
    END ;
    IF NeedsRetval(proc) THEN BegStat; Ident(proc^.typ^.strobj); OPM.WriteString(" __retval"); EndStat END;
    var := proc^.link;
    WHILE var # NIL DO (* declare copy of fixed size value array parameters *)
      IF (var^.typ^.comp = OPT.Array) & (var^.mode = OPT.Var) THEN
        BegStat;
        IF var^.typ^.strobj = NIL THEN OPM.Mark(200, var^.typ^.txtpos) ELSE Ident(var^.typ^.strobj) END ;
        OPM.Write(' '); Ident(var); OPM.WriteString("__copy");
        EndStat
      END ;
      var := var^.link
    END ;
    var := proc^.link;
    WHILE var # NIL DO (* copy value array parameters *)
      IF (var^.typ^.comp IN {OPT.Array, OPT.DynArr}) & (var^.mode = OPT.Var) & (var^.typ^.sysflag = 0) THEN
        BegStat;
        IF var^.typ^.comp = OPT.Array THEN
          OPM.WriteString("__DUPARR(");
          Ident(var); OPM.WriteString(', ');
          IF var^.typ^.strobj = NIL THEN OPM.Mark(200, var^.typ^.txtpos) ELSE Ident(var^.typ^.strobj) END
        ELSE
          OPM.WriteString('__DUP(');
          Ident(var); OPM.WriteString(', '); Ident(var); OPM.WriteString(LenExt);
          typ := var^.typ^.BaseTyp; dim := 1;
          WHILE typ^.comp = OPT.DynArr DO
            OPM.WriteString(" * "); Ident(var); OPM.WriteString(LenExt); OPM.WriteInt(dim);
            typ := typ^.BaseTyp; INC(dim)
          END ;
          OPM.WriteString(', ');
          IF (typ^.strobj = NIL) THEN OPM.Mark(200, typ^.txtpos)
          ELSE Ident(typ^.strobj)
          END
        END ;
        OPM.Write(')'); EndStat
      END ;
      var := var^.link
    END ;
    IF ~scope^.leaf THEN
      var := proc^.link; (* copy addresses of parameters into local scope record *)
      WHILE var # NIL DO
        IF ~var^.leaf THEN (* only if used by a nested procedure *)
          BegStat;
          OPM.WriteString(LocalScope); OPM.Write('.'); Ident(var);
          OPM.WriteString(' = ');
          IF var^.typ^.comp IN {OPT.Array, OPT.DynArr} THEN OPM.WriteString("(void*)")
            (* K&R and ANSI differ in the type: array or element type*)
          ELSIF var^.mode # OPT.VarPar THEN OPM.Write("&")
          END ;
          Ident(var);
          IF var^.typ^.comp = OPT.DynArr THEN
            typ := var^.typ; dim := 0;
            REPEAT (* copy len(s) *)
              OPM.WriteString("; ");
              OPM.WriteString(LocalScope); OPM.Write('.'); Ident(var); OPM.WriteString(LenExt);
              IF dim # 0 THEN OPM.WriteInt(dim) END ;
              OPM.WriteString(' = '); Ident(var); OPM.WriteString(LenExt);
              IF dim # 0 THEN OPM.WriteInt(dim) END ;
              typ := typ^.BaseTyp
            UNTIL typ^.comp # OPT.DynArr;
          ELSIF (var^.mode = OPT.VarPar) & (var^.typ^.comp = OPT.Record) THEN
            OPM.WriteString("; ");
            OPM.WriteString(LocalScope); OPM.Write('.'); Ident(var); OPM.WriteString(TagExt);
            OPM.WriteString(' = '); Ident(var); OPM.WriteString(TagExt)
          END ;
          EndStat
        END;
        var := var^.link;
      END;
      var := scope^.scope; (* copy addresses of local variables into scope record *)
      WHILE var # NIL DO
        IF ~var^.leaf THEN (* only if used by a nested procedure *)
          BegStat;
          OPM.WriteString(LocalScope); OPM.Write('.'); Ident(var); OPM.WriteString(' = ');
          IF var^.typ^.comp # OPT.Array THEN OPM.Write("&")
          ELSE OPM.WriteString("(void*)")  (* K&R and ANSI differ in the type: array or element type*)
          END ;
          Ident(var); EndStat
        END ;
        var := var^.link
      END;
      (* now link new scope *)
      BegStat; OPM.WriteString(LocalScope); OPM.Write('.'); OPM.WriteString(LinkName);
      OPM.WriteString(' = '); OPM.WriteStringVar(scope^.name); OPM.WriteString(GlobalScope); EndStat;
      BegStat; OPM.WriteStringVar(scope^.name); OPM.WriteString(GlobalScope); OPM.WriteString(' = ');
      OPM.Write("&"); OPM.WriteString(LocalScope); EndStat
    END
  END EnterProc;

  PROCEDURE ExitProc*(proc: OPT.Object; eoBlock, implicitRet: BOOLEAN);
    VAR var: OPT.Object; indent: BOOLEAN;
  BEGIN
    indent := eoBlock;
    IF implicitRet & (proc^.typ # OPT.notyp) THEN
      OPM.Write(Tab); OPM.WriteString("__RETCHK;"); OPM.WriteLn
    ELSIF ~eoBlock OR implicitRet THEN
      IF ~proc^.scope^.leaf THEN
        (* link scope pointer of nested proc back to previous scope *)
        IF indent THEN BegStat ELSE indent := TRUE END ;
        OPM.WriteStringVar(proc^.scope^.name); OPM.WriteString(GlobalScope);
        OPM.WriteString(' = '); OPM.WriteString(LocalScope); OPM.Write('.'); OPM.WriteString(LinkName);
        EndStat
      END;
      (* delete array value parameters *)
      var := proc^.link;
      WHILE var # NIL DO
        IF (var^.typ^.comp = OPT.DynArr) & (var^.mode = OPT.Var) & (var^.typ^.sysflag = 0) THEN
          IF indent THEN BegStat ELSE indent := TRUE END ;
          OPM.WriteString('__DEL('); Ident(var); OPM.Write(')'); EndStat
        END ;
        var := var^.link
      END
    END ;
    IF eoBlock THEN EndBlk; OPM.WriteLn
    ELSIF indent THEN BegStat
    END
  END ExitProc;

  PROCEDURE CompleteIdent*(obj: OPT.Object);
    VAR comp, level: INTEGER;
  BEGIN
    (* obj^.mode IN {OPT.Var, OPT.VarPar} *)
    level := obj^.mnolev;
    IF obj^.adr = 1 THEN  (* WITH-variable *)
      IF obj^.typ^.comp = OPT.Record THEN Ident(obj); OPM.WriteString("__")
      ELSE (* cast with guard pointer type *)
        OPM.WriteString("(*("); Ident(obj^.typ^.strobj); OPM.WriteString("*)&"); Ident(obj); OPM.Write(")")
      END
    ELSIF (level # OPM.level) & (level > 0) THEN (* intermediate var *)
      comp := obj^.typ^.comp;
      IF (obj^.mode # OPT.VarPar) & (comp # OPT.DynArr) THEN OPM.Write('*'); END;
      OPM.WriteStringVar(obj^.scope^.name); OPM.WriteString(GlobalScope);
      OPM.WriteString("->"); Ident(obj)
    ELSE
      Ident(obj)
    END
  END CompleteIdent;

  PROCEDURE TypeOf*(ap: OPT.Object);
    VAR i: INTEGER;
  BEGIN
    ASSERT(ap.typ.comp = OPT.Record);
    IF ap.mode = OPT.VarPar THEN
      IF ap.mnolev # OPM.level THEN  (*intermediate level var-par record; possible WITH-guarded*)
        OPM.WriteStringVar(ap^.scope^.name); OPM.WriteString("_s->"); Ident(ap)
      ELSE (*local var-par record*)
        Ident(ap)
      END ;
      OPM.WriteString(TagExt)
    ELSIF ap^.typ^.strobj # NIL THEN
      Ident(ap^.typ^.strobj); OPM.WriteString(DynTypExt)
    ELSE Andent(ap.typ)  (*anonymous ap type, p^ *)
    END
  END TypeOf;

  PROCEDURE Cmp*(rel: INTEGER);
  BEGIN
    CASE rel OF
    | OPT.eql: OPM.WriteString(" == ")
    | OPT.neq: OPM.WriteString(" != ")
    | OPT.lss: OPM.WriteString(" < ")
    | OPT.leq: OPM.WriteString(" <= ")
    | OPT.gtr: OPM.WriteString(" > ")
    | OPT.geq: OPM.WriteString(" >= ")
    ELSE OPM.LogWStr("unhandled case in OPC.Cmp, rel = "); OPM.LogWNum(rel, 0); OPM.LogWLn;
    END;
  END Cmp;

  PROCEDURE CharacterLiteral(c: SYSTEM.INT64);
  BEGIN
    IF (c < 32) OR (c > 126) THEN
      OPM.WriteString("0x"); OPM.WriteHex(c)
    ELSE
      OPM.Write("'");
      IF (c = ORD(Backslash)) OR (c = ORD("'"))  OR (c = ORD("?")) THEN
        OPM.Write(Backslash)
      END;
      OPM.Write(CHR(c));
      OPM.Write("'")
    END
  END CharacterLiteral;

  PROCEDURE StringLiteral(s: ARRAY OF CHAR; l: LONGINT);
    VAR i: LONGINT; c: INTEGER;
  BEGIN
    OPM.Write(DoubleQuote);
    i := 0; WHILE i < l DO
      c := ORD(s[i]);
      IF (c < 32) OR (c > 126) THEN
        (* Encode binary character value using exactly 3 octal digits.
           Use octal in preference to hex as only the octal escape
           syntax ensures a subsequent character will not be absorbed
           into this literal. *)
        OPM.Write(Backslash);
        OPM.Write(CHR(ORD("0") + c DIV 64)); c := c MOD 64;
        OPM.Write(CHR(ORD("0") + c DIV 8));  c := c MOD 8;
        OPM.Write(CHR(ORD("0") + c))
      ELSE
        IF (c = ORD(Backslash)) OR (c = ORD(DoubleQuote))  OR (c = ORD("?")) THEN
          OPM.Write(Backslash)
        END;
        OPM.Write(CHR(c));
      END;
      INC(i);
    END;
    OPM.Write(DoubleQuote)
  END StringLiteral;

  PROCEDURE Case*(caseVal: SYSTEM.INT64; form: INTEGER);
  VAR
    ch: CHAR;
  BEGIN
    OPM.WriteString('case ');
    CASE form OF
    | OPT.Char: CharacterLiteral(caseVal)
    | OPT.Int:  OPM.WriteInt(caseVal);
    ELSE OPM.LogWStr("unhandled case in OPC.Case, form = "); OPM.LogWNum(form, 0); OPM.LogWLn;
    END;
    OPM.WriteString(': ');
  END Case;

  PROCEDURE SetInclude* (exclude: BOOLEAN);
  BEGIN
    IF exclude THEN OPM.WriteString(" &= ~"); ELSE OPM.WriteString(" |= "); END;
  END SetInclude;

  PROCEDURE Increment* (decrement: BOOLEAN);
  BEGIN
    IF decrement THEN OPM.WriteString(" -= "); ELSE OPM.WriteString(" += "); END;
  END Increment;

  PROCEDURE Halt* (n: LONGINT);
  BEGIN
    Str1("__HALT(#)", n)
  END Halt;

  PROCEDURE IntLiteral*(n: SYSTEM.INT64; size: LONGINT);
  BEGIN
    IF (size > OPM.CIntSize) & (n <= OPM.CIntMax) & (n > OPM.CIntMin) THEN
      OPM.WriteString("((INT"); OPM.WriteInt(size*8); OPM.WriteString(")(");
      OPM.WriteInt(n); OPM.WriteString("))")
    ELSE
      OPM.WriteInt(n)
    END
  END IntLiteral;

  PROCEDURE Len* (obj: OPT.Object; array: OPT.Struct; dim: SYSTEM.INT64);
  VAR
    d: SYSTEM.INT64;
  BEGIN
    d := dim;
    WHILE d > 0 DO array := array^.BaseTyp; DEC(d) END;
    IF array^.comp = OPT.DynArr THEN
      CompleteIdent(obj); OPM.WriteString(LenExt);
      IF dim # 0 THEN OPM.WriteInt(dim) END
    ELSE (* array *)
      OPM.WriteInt(array.n)
    END
  END Len;

  PROCEDURE Constant* (con: OPT.Const; form: INTEGER);
    VAR i: INTEGER; s: SYSTEM.SET64;
      hex: SYSTEM.INT64; skipLeading: BOOLEAN;
  BEGIN
    CASE form OF
    | OPT.Byte:   OPM.WriteInt(con^.intval)
    | OPT.Bool:   OPM.WriteInt(con^.intval)
    | OPT.Char:   CharacterLiteral(con.intval)
    | OPT.Int:    OPM.WriteInt(con^.intval)
    | OPT.Real:   OPM.WriteReal(con^.realval, "f")
    | OPT.LReal:  OPM.WriteReal(con^.realval, 0X)
    | OPT.Set:    OPM.WriteString("0x");
                  skipLeading := TRUE;
                  s := con^.setval; i := MAX(SYSTEM.SET64) + 1;
                  REPEAT
                    hex := 0;
                    REPEAT
                      DEC(i); hex := 2 * hex;
                      IF i IN s THEN INC(hex) END
                    UNTIL i MOD 8 = 0;
                    IF (hex # 0) OR ~skipLeading THEN
                      OPM.WriteHex(hex);
                      skipLeading := FALSE
                    END
                  UNTIL i = 0;
                  IF skipLeading THEN OPM.Write("0") END
    | OPT.String: StringLiteral(con.ext^, con.intval2-1)
    | OPT.NilTyp: OPM.WriteString('NIL');
    ELSE OPM.LogWStr("unhandled case in OPC.Constant, form = "); OPM.LogWNum(form, 0); OPM.LogWLn;
    END;
  END Constant;


  PROCEDURE InitKeywords;
    VAR n, i: SHORTINT;

    PROCEDURE Enter(s: ARRAY OF CHAR);
      VAR h: INTEGER;
    BEGIN h := PerfectHash(s); hashtab[h] := n; COPY(s, keytab[n]); INC(n)
    END Enter;

  BEGIN n := 0;
    FOR i := 0 TO LEN(hashtab)-1 DO hashtab[i] := -1 END ;
    Enter("ADDRESS");  (* pseudo keyword used by voc *)
    Enter("INT16");    (* pseudo keyword used by voc *)
    Enter("INT32");    (* pseudo keyword used by voc *)
    Enter("INT64");    (* pseudo keyword used by voc *)
    Enter("INT8");     (* pseudo keyword used by voc *)
    Enter("UINT16");   (* pseudo keyword used by voc *)
    Enter("UINT32");   (* pseudo keyword used by voc *)
    Enter("UINT64");   (* pseudo keyword used by voc *)
    Enter("UINT8");    (* pseudo keyword used by voc *)

    Enter("asm");
    Enter("auto");
    Enter("break");
    Enter("case");
    Enter("char");
    Enter("const");
    Enter("continue");
    Enter("default");
    Enter("do");
    Enter("double");
    Enter("else");
    Enter("enum");
    Enter("extern");
    Enter("export");   (* pseudo keyword used by voc *)
    Enter("float");
    Enter("for");
    Enter("fortran");
    Enter("goto");
    Enter("if");
    Enter("import");   (* pseudo keyword used by voc *)
    Enter("int");
    Enter("long");
    Enter("register");
    Enter("return");
    Enter("short");
    Enter("signed");
    Enter("sizeof");
    Enter("size_t");
    Enter("static");
    Enter("struct");
    Enter("switch");
    Enter("typedef");
    Enter("union");
    Enter("unsigned");
    Enter("void");
    Enter("volatile");
    Enter("while");

(* what about common predefined names from cpp as e.g.
               Operating System:   ibm, gcos, os, tss and unix
               Hardware:           interdata, pdp11,  u370,  u3b,
                                   u3b2,   u3b5,  u3b15,  u3b20d,
                                   vax, ns32000,  iAPX286,  i386,
                                   sparc , and sun
               UNIX system variant:
                                   RES, and RT
               The lint(1V) command:
                                   lint
 *)
  END InitKeywords;

BEGIN InitKeywords
END OPC.
