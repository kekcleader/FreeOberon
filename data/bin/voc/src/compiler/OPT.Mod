(* OPT - Oberon Portable Symbol Table (front end) *)
MODULE OPT;  (* NW, RC 6.3.89 / 23.1.92 *)  (* object model 24.2.94 *)

(*
2002-08-20 jt: NewStr: txtpos remains 0 for structs read from symbol file
*)

IMPORT OPS, OPM, SYSTEM;


(* Constants - value of literals *)
TYPE
  Const*     = POINTER TO ConstDesc;
  ConstExt*  = POINTER TO OPS.String;
  ConstDesc* = RECORD
    ext*:      ConstExt;      (* string or code for code proc *)
    intval*:   SYSTEM.INT64;  (* constant value or adr, proc par size, text position or least case label *)
    intval2*:  LONGINT;       (* string length, proc var size or larger case label *)
    setval*:   SYSTEM.SET64;  (* constant value, procedure body present or "ELSE" present in case *)
    realval*:  LONGREAL       (* real or longreal constant value *)
  END;

CONST
  MaxConstLen* = OPS.MaxStrLen;

  (* conval^.setval procedure flags *)
  hasBody* = 1; isRedef* = 2; slNeeded* = 3;




(* Objects - named items - constants, types, variables, procedures *)
TYPE
  Object*  = POINTER TO ObjDesc;
  Struct*  = POINTER TO StrDesc;
  ObjDesc* = RECORD
    left*, right*:  Object;
    link*, scope*:  Object;
    name*:          OPS.Name;
    leaf*:          BOOLEAN;
    mode*, mnolev*: SHORTINT;  (* mnolev < 0 -> mno = -mnolev *)
    vis*:           SHORTINT;  (* internal, external, externalR *)
    history*:       SHORTINT;  (* relevant if name # "" *)
    used*, fpdone*: BOOLEAN;
    fprint*:        LONGINT;
    typ*:           Struct;
    conval*:        Const;
    adr*, linkadr*: LONGINT;
    x*:             INTEGER    (* linkadr and x can be freely used by the backend *)
  END;

CONST
  (* Object.mode values *)
  Var*   = 1; VarPar* = 2; Con*   = 3;  Fld* = 4;  Typ* = 5;   LProc* = 6;  XProc* = 7;
  SProc* = 8; CProc*  = 9; IProc* = 10; Mod* = 11; Head* = 12; TProc* = 13;

  (* Object.vis - module visibility of objects *)
  internal* = 0; external* = 1; externalR* = 2;

  (* Object.history - History of imported objects *)
  inserted* = 0; same* = 1; pbmodified* = 2; pvmodified* = 3; removed* = 4; inconsistent* = 5;

  (* Object.adr Function numbers *)
  floorfn* = -1; (* Added by Free Oberon team in 2017 and 2021 *)
  haltfn*   = 0;  newfn*  = 1;  absfn*    = 2;  capfn*  = 3;  ordfn* = 4;
  entierfn* = 5;  oddfn*  = 6;  minfn*    = 7;  maxfn*  = 8;  chrfn* = 9;
  shortfn*  = 10; longfn* = 11; sizefn*   = 12; incfn*  = 13; decfn* = 14;
  inclfn*   = 15; exclfn* = 16; lenfn*    = 17; copyfn* = 18; ashfn* = 19;
  adrfn*    = 20; ccfn*   = 21; lshfn*    = 22; rotfn*  = 23; getfn* = 24; (* SYSTEM *)
  putfn*    = 25; getrfn* = 26; putrfn*   = 27; bitfn*  = 28; valfn* = 29; (* SYSTEM *)
  sysnewfn* = 30; movefn* = 31;                                            (* SYSTEM *)
  assertfn* = 32;




(* Structures - describe types independently of their name *)
TYPE
  StrDesc* = RECORD
    form*, comp*:        SHORTINT;
    mno*, extlev*:       SHORTINT;
    ref*, sysflag*:      INTEGER;
    n*, size*:           LONGINT;
    align*, txtpos*:     LONGINT;  (* align is alignment for records, len is offset for dynarrs *)
    allocated*:          BOOLEAN;
    pbused*, pvused*:    BOOLEAN;
    fpdone,  idfpdone:   BOOLEAN;
    idfp*, pbfp, pvfp:   LONGINT;
    BaseTyp*:            Struct;
    link*, strobj*:      Object
  END;

CONST
  (* Struct.form values *)
  Undef*   = 0;  Byte*    = 1;  Bool*    = 2;  Char*    = 3;
  Int*     = 4;
  Real*    = 5;  LReal*   = 6;  Set*     = 7;  String*  = 8;
  NilTyp*  = 9;  NoTyp*   = 10; Pointer* = 11; ProcTyp* = 12;
  Comp*    = 13;

  realSet* = {Real, LReal};

  (* Struct.comp - Composite structure forms *)
  Basic* = 1; Array* = 2; DynArr* = 3; Record* = 4;




(* Nodes - statements, expressions and sub-expressions *)
TYPE
  Node*     = POINTER TO NodeDesc;
  NodeDesc* = RECORD
    left*, right*, link*: Node;
    class*, subcl*:       SHORTINT;
    readonly*:            BOOLEAN;
    typ*:                 Struct;
    obj*:                 Object;
    conval*:              Const
  END;

CONST
  (* Node.class values *)
  Nvar*    = 0;  Nvarpar* = 1;  Nfield*   = 2;  Nderef*  = 3;  Nindex* = 4;  Nguard*  = 5;  Neguard* = 6;
  Nconst*  = 7;  Ntype*   = 8;  Nproc*    = 9;  Nupto*   = 10; Nmop*   = 11; Ndop*    = 12; Ncall*   = 13;
  Ninittd* = 14; Nif*     = 15; Ncaselse* = 16; Ncasedo* = 17; Nenter* = 18; Nassign* = 19;
  Nifelse* = 20; Ncase*   = 21; Nwhile*   = 22; Nrepeat* = 23; Nloop*  = 24; Nexit*   = 25;
  Nreturn* = 26; Nwith*   = 27; Ntrap*    = 28;


  (* Node.subcl values - general *)
  assign* = 0;  (* Pseudo function number for assignment *)
  super*  = 1;

  (* Node.subcl values - functions *)
  ash*   = 17; msk* = 18; len* = 19;
  conv*  = 20; abs* = 21; cap* = 22; odd* = 23;

  (* Node.subcl values - SYSTEM functions *)
  adr* = 24; cc* = 25; bit* = 26; lsh* = 27; rot* = 28; val* = 29;

  (* Note: some object.adr function numbers and some symbol types are
  also are used as Node.subcl function ids *)
  eql* = OPS.eql;  neq* = OPS.neq;  lss* = OPS.lss;
  leq* = OPS.leq;  gtr* = OPS.gtr;  geq* = OPS.geq;



CONST
  maxImps   = 64;             (* must be <= MAX(SHORTINT) *)
  maxStruct = OPM.MaxStruct;  (* must be < MAX(INTEGER) DIV 2 *)
  FirstRef  = Comp + 1;

VAR
  topScope*: Object;

  undftyp*, niltyp*,    notyp*,
  bytetyp*, cpbytetyp*, booltyp*,  chartyp*,
  sinttyp*, inttyp*,    linttyp*,  hinttyp*,
  int8typ*, int16typ*,  int32typ*, int64typ*,
  settyp*,  set32typ*,  set64typ*,
  realtyp*, lrltyp*,    stringtyp*,
  adrtyp*,  sysptrtyp*: Struct;

  sintobj*, intobj*, lintobj*, setobj*: Object;

  nofGmod*: SHORTINT;  (*nof imports*)
  GlbMod*:  ARRAY maxImps OF Object;  (* ^.right = first object, ^.name = module import name (not alias) *)

  SelfName*:    OPS.Name;  (* name of module being compiled *)
  SYSimported*: BOOLEAN;



CONST

  (* Symbol file items *)
  Smname* = 16; Send*    = 18; Stype*   = 19; Salias*  = 20; Svar*  = 21;
  Srvar*  = 22; Svalpar* = 23; Svarpar* = 24; Sfld*    = 25; Srfld* = 26;
  Shdptr* = 27; Shdpro*  = 28; Stpro*   = 29; Shdtpro* = 30; Sxpro* = 31;
  Sipro*  = 32; Scpro*   = 33; Sstruct* = 34; Ssys*    = 35; Sptr*  = 36;
  Sarr*   = 37; Sdarr*   = 38; Srec*    = 39; Spro*    = 40; Slink* = 37;

TYPE
  ImpCtxt = RECORD
    nextTag, reffp:   LONGINT;
    nofr, minr, nofm: INTEGER;
    self:             BOOLEAN;
    ref:              ARRAY maxStruct OF Struct;
    old:              ARRAY maxStruct OF Object;
    pvfp:             ARRAY maxStruct OF LONGINT;  (* set only if old # NIL *)
    glbmno:           ARRAY maxImps OF SHORTINT  (* index is local mno *)
  END;

  ExpCtxt = RECORD
    reffp:  LONGINT;
    ref:    INTEGER;
    nofm:   SHORTINT;
    locmno: ARRAY maxImps OF SHORTINT  (* index is global mno *)
  END;

VAR
  universe, syslink:   Object;
  impCtxt:             ImpCtxt;
  expCtxt:             ExpCtxt;
  nofhdfld:            LONGINT;
  newsf, findpc:       BOOLEAN;
  extsf, sfpresent:    BOOLEAN;
  symExtended, symNew: BOOLEAN;
  recno:               LONGINT;  (* number of anonymous record types *)


(* Linking control - modules whose object files will be required to link a module. *)

TYPE
  Link* = POINTER TO LinkDesc;
  LinkDesc* = RECORD
    name-: OPS.Name;
    next-: Link
  END;

VAR
  Links-: Link;


PROCEDURE InitRecno*; BEGIN recno := 0 END InitRecno;
PROCEDURE err(n: INTEGER); BEGIN OPM.err(n) END err;


PROCEDURE IntSize*(n: SYSTEM.INT64):INTEGER;
(* Determines number of bytes required to store signed value n. *)
  VAR bytes: INTEGER;
BEGIN
  IF n < 0 THEN n := -(n+1) END;
  bytes := 1; WHILE (bytes < 8) & (ASH(n, -(8*bytes-1)) # 0) DO INC(bytes) END;
  RETURN bytes
END IntSize;

PROCEDURE IntType*(size: LONGINT): Struct;
(* Selects smallest standard integer type for given size in bytes *)
BEGIN
  IF size <= int8typ.size  THEN RETURN int8typ  END;
  IF size <= int16typ.size THEN RETURN int16typ END;
  IF size <= int32typ.size THEN RETURN int32typ END;
  RETURN int64typ
END IntType;

PROCEDURE SetType*(size: LONGINT): Struct;
BEGIN
  IF size = set32typ.size THEN RETURN set32typ END;
  RETURN set64typ
END SetType;

PROCEDURE ShorterOrLongerType*(x: Struct; dir: INTEGER): Struct;
  VAR i: INTEGER;
BEGIN
  ASSERT(x.form = Int);
  ASSERT(x.BaseTyp = undftyp);
  ASSERT((dir = 1) OR (dir = -1));
  IF dir > 0 THEN
    IF x.size < sinttyp.size THEN RETURN sinttyp END;
    IF x.size < inttyp.size  THEN RETURN inttyp  END;
    IF x.size < linttyp.size THEN RETURN linttyp END;
    RETURN int64typ
  ELSE
    IF x.size > linttyp.size THEN RETURN linttyp END;
    IF x.size > inttyp.size  THEN RETURN inttyp  END;
    IF x.size > sinttyp.size THEN RETURN sinttyp END;
    RETURN int8typ
  END
END ShorterOrLongerType;


PROCEDURE Align*(VAR adr: LONGINT; base: LONGINT);
BEGIN
  CASE base OF
  |  2: INC(adr,   adr  MOD 2)
  |  4: INC(adr, (-adr) MOD 4)
  |  8: INC(adr, (-adr) MOD 8)
  | 16: INC(adr, (-adr) MOD 16)
  ELSE (*1*) (*OPM.LogWStr("unhandled case at OPC.Align, base = "); OPM.LogWNum(base, 0); OPM.LogWLn;*)
  END
END Align;

PROCEDURE SizeAlignment*(size: LONGINT): LONGINT;
  VAR alignment: LONGINT;
BEGIN
  IF size < OPM.Alignment THEN
    (* Round up to next power of 2 *)
    alignment := 1; WHILE alignment < size DO alignment := alignment * 2 END;
  ELSE
    alignment := OPM.Alignment
  END;
  RETURN alignment
END SizeAlignment;

PROCEDURE BaseAlignment*(typ: Struct): LONGINT;
  VAR alignment: LONGINT;
BEGIN
  IF typ.form = Comp THEN
    IF typ.comp = Record THEN
      alignment := typ.align MOD 10000H
    ELSE
      alignment := BaseAlignment(typ.BaseTyp)
    END
  ELSE
    alignment := SizeAlignment(typ.size)
  END;
  RETURN alignment
END BaseAlignment;

PROCEDURE TypSize*(typ: Struct);
  VAR
    f, c: INTEGER;
    offset, size, base, fbase, off0: LONGINT;
    fld: Object; btyp: Struct;
BEGIN
  IF typ = undftyp THEN OPM.err(58)
  ELSIF typ.size = -1 THEN
    f := typ.form;
    c := typ.comp;
    IF c = Record THEN btyp := typ.BaseTyp;
      IF btyp = NIL THEN offset := 0; base := 1;
      ELSE TypSize(btyp); offset := btyp.size - btyp.sysflag DIV 100H; base := btyp.align;
      END;
      fld := typ.link;
      WHILE (fld # NIL) & (fld.mode = Fld) DO
        btyp := fld.typ; TypSize(btyp);
        size := btyp.size;
        fbase := BaseAlignment(btyp);
        Align(offset, fbase);
        fld.adr := offset; INC(offset, size);
        IF fbase > base THEN base := fbase END;
        fld := fld.link
      END;
      (* base is now the largest alignment of any field *)
      off0 := offset;
      IF offset = 0 THEN offset := 1 END;  (* 1 byte filler to avoid empty struct *)
      Align(offset, base);
      IF (typ^.strobj = NIL) & (typ^.align MOD 10000H = 0) THEN INC(recno); INC(base, recno * 10000H) END;
      typ.size := offset;
      typ.align := base;
      (* encode the trailing gap into the symbol table to allow dense packing of extended records *)
      typ^.sysflag := typ^.sysflag MOD 100H + SHORT((offset - off0)*100H)
    ELSIF c = Array THEN
      TypSize(typ.BaseTyp);
      typ.size := typ.n * typ.BaseTyp.size;
    ELSIF f = Pointer THEN
      typ.size := OPM.AddressSize;
      IF typ.BaseTyp = undftyp THEN OPM.Mark(128, typ.n)
      ELSE TypSize(typ.BaseTyp)
      END
    ELSIF f = ProcTyp THEN
      typ.size := OPM.AddressSize;
    ELSIF c = DynArr THEN
      btyp := typ.BaseTyp; TypSize(btyp);
      IF btyp.comp = DynArr THEN typ.size := btyp.size + 4  (* describes dim not size *)
      ELSE typ.size := 8
      END
    END
  END
END TypSize;


PROCEDURE NewConst*(): Const;
  VAR const: Const;
BEGIN NEW(const); RETURN const
END NewConst;

PROCEDURE NewObj*(): Object;
  VAR obj: Object;
BEGIN NEW(obj); RETURN obj
END NewObj;

PROCEDURE NewStr*(form, comp: SHORTINT): Struct;
  VAR typ: Struct;
BEGIN NEW(typ); typ^.form := form; typ^.comp := comp; typ^.ref := maxStruct;  (* ref >= maxStruct: not exported yet *)
  IF form # Undef THEN typ^.txtpos := OPM.errpos END ;  (* txtpos remains 0 for structs read from symbol file *)
  typ^.size := -1; typ^.BaseTyp := undftyp; RETURN typ
END NewStr;

PROCEDURE NewNode*(class: SHORTINT): Node;
  VAR node: Node;
BEGIN NEW(node); node^.class := class; RETURN node
END NewNode;

PROCEDURE NewExt*(): ConstExt;
  VAR ext: ConstExt;
BEGIN NEW(ext); RETURN ext
END NewExt;

PROCEDURE OpenScope*(level: SHORTINT; owner: Object);
  VAR head: Object;
BEGIN head := NewObj();
  head^.mode := Head; head^.mnolev := level; head^.link := owner;
  IF owner # NIL THEN owner^.scope := head END;
  head^.left := topScope; head^.right := NIL; head^.scope := NIL; topScope := head
END OpenScope;

PROCEDURE CloseScope*;
BEGIN topScope := topScope^.left
END CloseScope;

PROCEDURE Init*(VAR name: OPS.Name; opt: SET);
  CONST nsf = 4; fpc = 8; esf = 9;
BEGIN
  topScope := universe; OpenScope(0, NIL); SYSimported := FALSE;
  SelfName := name; topScope^.name := name;
  GlbMod[0] := topScope; nofGmod := 1;
  newsf := nsf IN opt; findpc := fpc IN opt; extsf := newsf OR (esf IN opt); sfpresent := TRUE;
  NEW(Links); Links.name := name
END Init;

PROCEDURE Close*;
  VAR i: INTEGER;
BEGIN  (* garbage collection *)
  CloseScope;
  i := 0; WHILE i < maxImps DO GlbMod[i] := NIL; INC(i) END;
  i := FirstRef; WHILE i < maxStruct DO impCtxt.ref[i] := NIL; impCtxt.old[i] := NIL; INC(i) END
END Close;

PROCEDURE FindImport*(mod: Object; VAR res: Object);
  VAR obj: Object;
BEGIN obj := mod^.scope;
  LOOP
    IF obj = NIL THEN EXIT END;
    IF OPS.name < obj^.name THEN obj := obj^.left
    ELSIF OPS.name > obj^.name THEN obj := obj^.right
    ELSE (*found*)
      IF (obj^.mode = Typ) & (obj^.vis = internal) THEN obj := NIL
     ELSE obj^.used := TRUE
      END;
      EXIT
    END
  END;
  res := obj
END FindImport;

PROCEDURE Find*(VAR res: Object);
  VAR obj, head: Object;
BEGIN head := topScope;
  LOOP obj := head^.right;
    LOOP
      IF obj = NIL THEN EXIT END;
      IF OPS.name < obj^.name THEN obj := obj^.left
      ELSIF OPS.name > obj^.name THEN obj := obj^.right
      ELSE (* found, obj^.used not set for local objects *) EXIT
      END
    END;
    IF obj # NIL THEN EXIT END;
    head := head^.left;
    IF head = NIL THEN EXIT END
  END;
  res := obj
END Find;

PROCEDURE FindField*(VAR name: OPS.Name; typ: Struct; VAR res: Object);
  VAR obj: Object;
BEGIN
  WHILE typ # NIL DO obj := typ^.link;
    WHILE obj # NIL DO
      IF name < obj^.name THEN obj := obj^.left
      ELSIF name > obj^.name THEN obj := obj^.right
      ELSE (*found*) res := obj; RETURN
      END
    END;
    typ := typ^.BaseTyp
  END;
  res := NIL
END FindField;

PROCEDURE Insert*(VAR name: OPS.Name; VAR obj: Object);
  VAR ob0, ob1: Object; left: BOOLEAN; mnolev: SHORTINT;
BEGIN ob0 := topScope; ob1 := ob0^.right; left := FALSE;
  LOOP
    IF ob1 # NIL THEN
      IF name < ob1^.name THEN ob0 := ob1; ob1 := ob0^.left; left := TRUE
      ELSIF name > ob1^.name THEN ob0 := ob1; ob1 := ob0^.right; left := FALSE
      ELSE (*double def*) err(1); ob0 := ob1; ob1 := ob0^.right
      END
    ELSE (*insert*) ob1 := NewObj(); ob1^.leaf := TRUE;
      IF left THEN ob0^.left := ob1 ELSE ob0^.right := ob1 END;
      ob1^.left := NIL; ob1^.right := NIL; COPY(name, ob1^.name);
      mnolev := topScope^.mnolev; ob1^.mnolev := mnolev;
      EXIT
    END
  END;
  obj := ob1
END Insert;


(*-------------------------- Fingerprinting --------------------------*)

(* Fingerprints prevent structural type equivalence. *)

PROCEDURE FPrintName(VAR fp: LONGINT; VAR name: ARRAY OF CHAR);
  VAR i: INTEGER; ch: CHAR;
BEGIN i := 0;
  REPEAT ch := name[i]; OPM.FPrint(fp, ORD(ch)); INC(i) UNTIL ch = 0X
END FPrintName;

PROCEDURE ^IdFPrint*(typ: Struct);

PROCEDURE DebugStruct(btyp: Struct);
BEGIN
  OPM.LogWLn;
  IF btyp = NIL THEN OPM.LogWStr("btyp is nil"); OPM.LogWLn END;
  OPM.LogWStr("btyp^.strobji^.name = "); OPM.LogWStr(btyp^.strobj^.name); OPM.LogWLn;
  OPM.LogWStr("btyp^.form = ");   OPM.LogWNum(btyp^.form, 0);   OPM.LogWLn;
  OPM.LogWStr("btyp^.comp = ");   OPM.LogWNum(btyp^.comp, 0);   OPM.LogWLn;
  OPM.LogWStr("btyp^.mno = ");    OPM.LogWNum(btyp^.mno, 0);    OPM.LogWLn;
  OPM.LogWStr("btyp^.extlev = "); OPM.LogWNum(btyp^.extlev, 0); OPM.LogWLn;
  OPM.LogWStr("btyp^.size = ");   OPM.LogWNum(btyp^.size, 0);   OPM.LogWLn;
  OPM.LogWStr("btyp^.align = ");  OPM.LogWNum(btyp^.align, 0);  OPM.LogWLn;
  OPM.LogWStr("btyp^.txtpos = "); OPM.LogWNum(btyp^.txtpos, 0); OPM.LogWLn;
END DebugStruct;

PROCEDURE FPrintSign(VAR fp: LONGINT; result: Struct; par: Object);
(* depends on assignment compatibility of params only *)
BEGIN
   IdFPrint(result); OPM.FPrint(fp, result^.idfp);
   WHILE (par # NIL) (*& (par^.typ # NIL)*) DO (* !!! *)
      OPM.FPrint(fp, par^.mode);
      IdFPrint(par^.typ);
      OPM.FPrint(fp, par^.typ^.idfp);
      (* par^.name and par^.adr not considered *)
      par := par^.link
   END
END FPrintSign;

PROCEDURE IdFPrint*(typ: Struct);  (* idfp codifies assignment compatibility *)
VAR btyp: Struct; strobj: Object; idfp: LONGINT; f, c: INTEGER;
BEGIN
  IF ~typ^.idfpdone THEN
    typ^.idfpdone := TRUE;  (* may be recursive, temporary idfp is 0 in that case *)
    idfp := 0;
    f := typ^.form; OPM.FPrint(idfp, f); IF f IN {Int, Set} THEN OPM.FPrint(idfp, typ.size) END;
    c := typ^.comp; OPM.FPrint(idfp, c);
    btyp := typ^.BaseTyp; strobj := typ^.strobj;
    IF (strobj # NIL) & (strobj^.name # "") THEN
       FPrintName(idfp, GlbMod[typ^.mno]^.name); FPrintName(idfp, strobj^.name)
    END;
    IF (f = Pointer) OR (c = Record) & (btyp # NIL) OR (c = DynArr) THEN
       IdFPrint(btyp); OPM.FPrint(idfp, btyp^.idfp)
    ELSIF c = Array THEN
       IdFPrint(btyp); OPM.FPrint(idfp, btyp^.idfp); OPM.FPrint(idfp, typ^.n)
    ELSIF f = ProcTyp THEN FPrintSign(idfp, btyp, typ^.link)
    END;
    typ^.idfp := idfp
  END
END IdFPrint;

PROCEDURE FPrintStr*(typ: Struct);
  VAR f, c: INTEGER; btyp: Struct; strobj, bstrobj: Object; pbfp, pvfp: LONGINT;

  PROCEDURE ^FPrintFlds(fld: Object; adr: LONGINT; visible: BOOLEAN);

  PROCEDURE FPrintHdFld(typ: Struct; fld: Object; adr: LONGINT);  (* modifies pvfp only *)
    VAR i, j, n: LONGINT; btyp: Struct;
  BEGIN
    IF typ^.comp = Record THEN FPrintFlds(typ^.link, adr, FALSE)
    ELSIF typ^.comp = Array THEN btyp := typ^.BaseTyp; n := typ^.n;
      WHILE btyp^.comp = Array DO n := btyp^.n * n; btyp := btyp^.BaseTyp END;
      IF (btyp^.form = Pointer) OR (btyp^.comp = Record) THEN
        j := nofhdfld; FPrintHdFld(btyp, fld, adr);
        IF j # nofhdfld THEN i := 1;
          WHILE (i < n) & (nofhdfld <= OPM.MaxHdFld) DO
            INC(adr, btyp^.size); FPrintHdFld(btyp, fld, adr); INC(i)
          END
        END
      END
    ELSIF OPM.ExpHdPtrFld & ((typ^.form = Pointer) OR (fld^.name = OPM.HdPtrName)) THEN
      OPM.FPrint(pvfp, Pointer); OPM.FPrint(pvfp, adr); INC(nofhdfld)
    ELSIF OPM.ExpHdProcFld & ((typ^.form = ProcTyp) OR (fld^.name = OPM.HdProcName)) THEN
      OPM.FPrint(pvfp, ProcTyp); OPM.FPrint(pvfp, adr); INC(nofhdfld)
    END
  END FPrintHdFld;

  PROCEDURE FPrintFlds(fld: Object; adr: LONGINT; visible: BOOLEAN);  (* modifies pbfp and pvfp *)
  BEGIN
    WHILE (fld # NIL) & (fld^.mode = Fld) DO
      IF (fld^.vis # internal) & visible THEN
        OPM.FPrint(pbfp, fld^.vis); FPrintName(pbfp, fld^.name); OPM.FPrint(pbfp, fld^.adr);
        FPrintStr(fld^.typ); OPM.FPrint(pbfp, fld^.typ^.pbfp); OPM.FPrint(pvfp, fld^.typ^.pvfp)
      ELSE
        FPrintHdFld(fld^.typ, fld, fld^.adr + adr)
      END;
      fld := fld^.link
    END;
  END FPrintFlds;

  PROCEDURE FPrintTProcs(obj: Object);  (* modifies pbfp and pvfp *)
  BEGIN
    IF obj # NIL THEN
      FPrintTProcs(obj^.left);
      IF obj^.mode = TProc THEN
        IF obj^.vis # internal THEN
          OPM.FPrint(pbfp, TProc); OPM.FPrint(pbfp, obj^.adr DIV 10000H);
          FPrintSign(pbfp, obj^.typ, obj^.link); FPrintName(pbfp, obj^.name)
        ELSIF OPM.ExpHdTProc THEN
          OPM.FPrint(pvfp, TProc); OPM.FPrint(pvfp, obj^.adr DIV 10000H)
        END
      END;
      FPrintTProcs(obj^.right)
    END;
  END FPrintTProcs;

BEGIN
  IF ~typ^.fpdone THEN
    IdFPrint(typ); pbfp := typ^.idfp;
    IF typ^.sysflag # 0 THEN OPM.FPrint(pbfp, typ^.sysflag) END;
    pvfp := pbfp; typ^.pbfp := pbfp; typ^.pvfp := pvfp;  (* initial fprints may be used recursively *)
    typ^.fpdone := TRUE;
    f := typ^.form; c := typ^.comp; btyp := typ^.BaseTyp;
    IF f = Pointer THEN
      strobj := typ^.strobj; bstrobj := btyp^.strobj;
      IF (strobj = NIL) OR (strobj^.name = "") OR (bstrobj = NIL) OR (bstrobj^.name = "") THEN
        FPrintStr(btyp); OPM.FPrint(pbfp, btyp^.pbfp); pvfp := pbfp
        (* else use idfp as pbfp and as pvfp, do not call FPrintStr(btyp) here, else cycle not broken *)
      END
    ELSIF f = ProcTyp THEN (* use idfp as pbfp and as pvfp *)
    ELSIF c IN {Array, DynArr} THEN FPrintStr(btyp); OPM.FPrint(pbfp, btyp^.pvfp); pvfp := pbfp
    ELSE (* c = Record *)
      IF btyp # NIL THEN FPrintStr(btyp); OPM.FPrint(pbfp, btyp^.pbfp); OPM.FPrint(pvfp, btyp^.pvfp) END;
      OPM.FPrint(pvfp, typ^.size); OPM.FPrint(pvfp, typ^.align); OPM.FPrint(pvfp, typ^.n);
      nofhdfld := 0; FPrintFlds(typ^.link, 0, TRUE);
      IF nofhdfld > OPM.MaxHdFld THEN OPM.Mark(225, typ^.txtpos) END;
      FPrintTProcs(typ^.link); OPM.FPrint(pvfp, pbfp); strobj := typ^.strobj;
      IF (strobj = NIL) OR (strobj^.name = "") THEN pbfp := pvfp END
    END;
    typ^.pbfp := pbfp; typ^.pvfp := pvfp
  END
END FPrintStr;

PROCEDURE FPrintObj*(obj: Object);
VAR fprint: LONGINT; f, m: INTEGER; rval: REAL; ext: ConstExt;
BEGIN
  IF ~obj^.fpdone THEN
    fprint := 0; obj^.fpdone := TRUE;
    OPM.FPrint(fprint, obj^.mode);
    IF obj^.mode = Con THEN
      f := obj^.typ^.form; OPM.FPrint(fprint, f);
      CASE f OF
      | Bool,
        Char,
        Int:    OPM.FPrint(fprint, obj^.conval^.intval)
      | Set:    OPM.FPrintSet(fprint, obj^.conval^.setval)
      | Real:   rval := SHORT(obj^.conval^.realval); OPM.FPrintReal(fprint, rval)
      | LReal:  OPM.FPrintLReal(fprint, obj^.conval^.realval)
      | String: FPrintName(fprint, obj^.conval^.ext^)
      | NilTyp:
      ELSE err(127)
      END
    ELSIF obj^.mode = Var THEN
      OPM.FPrint(fprint, obj^.vis); FPrintStr(obj^.typ); OPM.FPrint(fprint, obj^.typ^.pbfp)
    ELSIF obj^.mode IN {XProc, IProc}  THEN
      FPrintSign(fprint, obj^.typ, obj^.link)
    ELSIF obj^.mode = CProc THEN
      FPrintSign(fprint, obj^.typ, obj^.link); ext := obj^.conval^.ext;
      m := ORD(ext^[0]); f := 1; OPM.FPrint(fprint, m);
      WHILE f <= m DO OPM.FPrint(fprint, ORD(ext^[f])); INC(f) END;
    ELSIF obj^.mode = Typ THEN
      FPrintStr(obj^.typ); OPM.FPrint(fprint, obj^.typ^.pbfp)
    END;
    obj^.fprint := fprint
  END
END FPrintObj;

PROCEDURE FPrintErr*(obj: Object; errcode: INTEGER);
VAR i, j: INTEGER; ch: CHAR;
BEGIN
  IF obj^.mnolev # 0 THEN
    COPY(GlbMod[-obj^.mnolev]^.name, OPM.objname); i := 0;
    WHILE OPM.objname[i] # 0X DO INC(i) END;
    OPM.objname[i] := "."; j := 0; INC(i);
    REPEAT ch := obj^.name[j]; OPM.objname[i] := ch; INC(j); INC(i) UNTIL ch = 0X;
  ELSE
    COPY(obj^.name, OPM.objname)
  END;
  IF errcode = 249 THEN
    IF OPM.noerr THEN err(errcode) END
  ELSIF errcode = 253 THEN  (* extension *)
    IF ~symNew & ~symExtended & ~extsf THEN err(errcode) END;
    symExtended := TRUE
  ELSE
    IF ~symNew & ~newsf THEN err(errcode) END;
    symNew := TRUE
  END
END FPrintErr;

(*-------------------------- Import --------------------------*)

PROCEDURE InsertImport*(obj: Object; VAR root, old: Object);
  VAR ob0, ob1: Object; left: BOOLEAN;
BEGIN
  IF root = NIL THEN root := obj; old := NIL
  ELSE
    ob0 := root; ob1 := ob0^.right; left := FALSE;
    IF    obj^.name < ob0^.name THEN ob1 := ob0^.left;  left := TRUE
    ELSIF obj^.name > ob0^.name THEN ob1 := ob0^.right; left := FALSE
    ELSE old := ob0; RETURN
    END;
    LOOP
      IF ob1 # NIL THEN
        IF obj^.name < ob1^.name THEN ob0 := ob1; ob1 := ob1^.left; left := TRUE
        ELSIF obj^.name > ob1^.name THEN ob0 := ob1; ob1 := ob1^.right; left := FALSE
        ELSE old := ob1; EXIT
        END
      ELSE ob1 := obj;
        IF left THEN ob0^.left := ob1 ELSE ob0^.right := ob1 END;
        ob1^.left := NIL; ob1^.right := NIL; old := NIL; EXIT
      END
    END
  END
END InsertImport;

PROCEDURE InName(VAR name: ARRAY OF CHAR);
VAR i: INTEGER; ch: CHAR;
BEGIN i := 0;
  REPEAT
    OPM.SymRCh(ch); name[i] := ch; INC(i)
  UNTIL ch = 0X
END InName;

PROCEDURE InMod(VAR mno: SHORTINT);  (* mno is global *)
  VAR head: Object; name: OPS.Name; mn: LONGINT; i: SHORTINT;
BEGIN
  mn := OPM.SymRInt();
  IF mn = 0 THEN mno := impCtxt.glbmno[0]
  ELSE
    IF mn = Smname THEN
      InName(name);
      IF (name = SelfName) & ~impCtxt.self THEN err(154) END;
      i := 0;
      WHILE (i < nofGmod) & (name # GlbMod[i].name) DO INC(i) END;
      IF i < nofGmod THEN mno := i  (*module already present*)
      ELSE
        head := NewObj(); head^.mode := Head; COPY(name, head^.name);
        mno := nofGmod; head^.mnolev := -mno;
        IF nofGmod < maxImps THEN
          GlbMod[mno] := head; INC(nofGmod)
        ELSE err(227)
        END
      END;
      impCtxt.glbmno[impCtxt.nofm] := mno; INC(impCtxt.nofm)
    ELSE
      mno := impCtxt.glbmno[-mn]
    END
  END
END InMod;

PROCEDURE InLinks;  (* Load a list of all modules whose object files we will need to link with *)
  VAR linkname: OPS.Name; l: Link;
BEGIN
  InName(linkname);
  WHILE linkname[0] # 0X DO
    l := Links; WHILE (l # NIL) & (l.name # linkname) DO l := l.next END;
    IF l = NIL THEN
      l := Links; NEW(Links);
      Links.next := l; Links.name := linkname
    END;
    InName(linkname)
  END
END InLinks;

PROCEDURE InConstant(f: LONGINT; conval: Const);
  VAR ch: CHAR; i: INTEGER; ext: ConstExt; rval: REAL;
BEGIN
  CASE f OF
  | Byte,
    Char,
    Bool:   OPM.SymRCh(ch); conval^.intval := ORD(ch)
  | Int:    conval^.intval := OPM.SymRInt()
  | Set:    OPM.SymRSet(conval^.setval)
  | Real:   OPM.SymRReal(rval); conval^.realval := rval;
            conval^.intval := OPM.ConstNotAlloc
  | LReal:  OPM.SymRLReal(conval^.realval);
            conval^.intval := OPM.ConstNotAlloc
  | String: ext := NewExt(); conval^.ext := ext; i := 0;
            REPEAT
              OPM.SymRCh(ch); ext^[i] := ch; INC(i)
            UNTIL ch = 0X;
            conval^.intval2 := i;
            conval^.intval := OPM.ConstNotAlloc
  | NilTyp: conval^.intval := OPM.nilval
  ELSE          OPM.LogWStr("unhandled case in InConstant(), f = "); OPM.LogWNum(f, 0); OPM.LogWLn;
  END
END InConstant;

PROCEDURE ^InStruct(VAR typ: Struct);

PROCEDURE InSign(mno: SHORTINT; VAR res: Struct; VAR par: Object);
  VAR last, new: Object; tag: LONGINT;
BEGIN
  InStruct(res);
  tag := OPM.SymRInt(); last := NIL;
  WHILE tag # Send DO
    new := NewObj(); new^.mnolev := -mno;
    IF last = NIL THEN par := new ELSE last^.link := new END;
    IF tag = Svalpar THEN new^.mode := Var ELSE new^.mode := VarPar END;
    InStruct(new^.typ); new^.adr := OPM.SymRInt(); InName(new^.name);
    last := new; tag := OPM.SymRInt()
  END
END InSign;

PROCEDURE InFld(): Object;  (* first number in impCtxt.nextTag, mno set outside *)
  VAR tag: LONGINT; obj: Object;
BEGIN
  tag := impCtxt.nextTag; obj := NewObj();
  IF tag <= Srfld THEN
    obj^.mode := Fld;
    IF tag = Srfld THEN obj^.vis := externalR ELSE obj^.vis := external END;
    InStruct(obj^.typ); InName(obj^.name);
    obj^.adr := OPM.SymRInt()
  ELSE
    obj^.mode := Fld;
    IF tag = Shdptr THEN obj^.name := OPM.HdPtrName ELSE obj^.name := OPM.HdProcName END;
    obj^.typ := undftyp; obj^.vis := internal;
    obj^.adr := OPM.SymRInt()
  END;
  RETURN obj
END InFld;

PROCEDURE InTProc(mno: SHORTINT): Object;  (* first number in impCtxt.nextTag *)
  VAR tag: LONGINT; obj: Object;
BEGIN
  tag := impCtxt.nextTag;
  obj := NewObj(); obj^.mnolev := -mno;
  IF tag = Stpro THEN
    obj^.mode := TProc; obj^.conval := NewConst(); obj^.conval^.intval := -1;
    InSign(mno, obj^.typ, obj^.link); obj^.vis := external; InName(obj^.name);
    obj^.adr := 10000H*OPM.SymRInt()
  ELSE  (* tag = Shdtpro *)
    obj^.mode := TProc; obj^.name := OPM.HdTProcName;
    obj^.link := NewObj();  (* dummy, easier in Browser *)
    obj^.typ := undftyp; obj^.vis := internal;
    obj^.adr := 10000H*OPM.SymRInt()
  END;
  RETURN obj
END InTProc;


PROCEDURE InTyp(tag: LONGINT): Struct;
BEGIN
  IF    tag = Int THEN RETURN IntType(OPM.SymRInt())
  ELSIF tag = Set THEN RETURN SetType(OPM.SymRInt())
  ELSE RETURN impCtxt.ref[tag]
  END
END InTyp;


PROCEDURE InStruct(VAR typ: Struct);
  VAR mno: SHORTINT; ref: INTEGER; tag: LONGINT; name: OPS.Name;
      t: Struct; obj, last, fld, old, dummy: Object;
BEGIN
  tag := OPM.SymRInt();
  IF tag # Sstruct THEN typ := InTyp(-tag)
  ELSE
    ref := impCtxt.nofr; INC(impCtxt.nofr);
    IF ref < impCtxt.minr THEN impCtxt.minr := ref END;
    InMod(mno); InName(name); obj := NewObj();
    IF name = "" THEN
      IF impCtxt.self THEN
        old := NIL  (* do not insert type desc anchor here, but in OPL *)
      ELSE
        obj^.name := "@"; InsertImport(obj, GlbMod[mno].right, old(*=NIL*)); obj^.name := ""
      END;
      typ := NewStr(Undef, Basic)
    ELSE
      obj^.name := name; InsertImport(obj, GlbMod[mno].right, old);
      IF old # NIL THEN  (* recalculate fprints to compare with old fprints *)
        FPrintObj(old); impCtxt.pvfp[ref] := old^.typ^.pvfp;
        IF impCtxt.self THEN  (* do not overwrite old typ *)
          typ := NewStr(Undef, Basic)
        ELSE  (* overwrite old typ for compatibility reason *)
          typ := old^.typ; typ^.link := NIL; typ^.sysflag := 0;
          typ^.fpdone := FALSE; typ^.idfpdone := FALSE
        END
      ELSE
        typ := NewStr(Undef, Basic)
      END
    END;
    impCtxt.ref[ref] := typ; impCtxt.old[ref] := old;
    typ^.ref := ref + maxStruct;
    (* ref >= maxStruct: not exported yet, ref used for err 155 *)
    typ^.mno := mno; typ^.allocated := TRUE;
    typ^.strobj := obj; obj^.mode := Typ; obj^.typ := typ;
    obj^.mnolev := -mno; obj^.vis := internal; (* name not visible here *)
    tag := OPM.SymRInt();
    IF tag = Ssys THEN typ^.sysflag := SHORT(OPM.SymRInt()); tag := OPM.SymRInt() END;
    CASE tag OF
    | Sptr:  typ^.form := Pointer; typ^.size := OPM.AddressSize;
             typ^.n := 0; InStruct(typ^.BaseTyp)
    | Sarr:  typ^.form := Comp; typ^.comp := Array;
             InStruct(typ^.BaseTyp); typ^.n := OPM.SymRInt();
             TypSize(typ) (* no bounds address !! *)
    | Sdarr: typ^.form := Comp; typ^.comp := DynArr; InStruct(typ^.BaseTyp);
             IF typ^.BaseTyp^.comp = DynArr THEN
               typ^.n := typ^.BaseTyp^.n + 1
             ELSE
               typ^.n := 0
             END;
             TypSize(typ)
    | Srec:  typ^.form := Comp; typ^.comp := Record;
             InStruct(typ^.BaseTyp);
             IF typ^.BaseTyp = notyp THEN typ^.BaseTyp := NIL END;
             typ.extlev := 0; t := typ.BaseTyp;
             (* do not take extlev from base type due to possible cycles! *)
             WHILE (t # NIL) (*& (t^.BaseTyp # t)*)(*(t^.(*BaseTyp^.*)form # 0)*) DO
               INC(typ^.extlev); t := t.BaseTyp
             END; (* !!! *)
             typ^.size := OPM.SymRInt(); typ^.align := OPM.SymRInt();
             typ^.n := OPM.SymRInt();
             impCtxt.nextTag := OPM.SymRInt(); last := NIL;
             WHILE (impCtxt.nextTag >= Sfld) & (impCtxt.nextTag <= Shdpro) DO
               fld := InFld(); fld^.mnolev := -mno;
               IF last # NIL THEN last^.link := fld END;
               last := fld; InsertImport(fld, typ^.link, dummy);
               impCtxt.nextTag := OPM.SymRInt()
             END;
             WHILE impCtxt.nextTag # Send DO
               fld := InTProc(mno);
               InsertImport(fld, typ^.link, dummy);
               impCtxt.nextTag := OPM.SymRInt()
             END
    | Spro:  typ^.form := ProcTyp; typ^.size := OPM.AddressSize;
             InSign(mno, typ^.BaseTyp, typ^.link)
    ELSE     OPM.LogWStr("unhandled case at InStruct, tag = "); OPM.LogWNum(tag, 0); OPM.LogWLn;
    END;
    IF ref = impCtxt.minr THEN
      WHILE (ref < impCtxt.nofr) DO
        t := InTyp(ref); FPrintStr(t);
        obj := t^.strobj;  (* obj^.typ^.strobj = obj, else obj^.fprint differs (alias) *)
        IF obj^.name # "" THEN FPrintObj(obj) END;
        old := impCtxt.old[ref];
        IF old # NIL THEN
          t^.strobj := old;  (* restore strobj *)
          IF impCtxt.self THEN
            IF old^.mnolev < 0 THEN
              IF old^.history # inconsistent THEN
                IF old^.fprint # obj^.fprint THEN
                  old^.history := pbmodified
                ELSIF impCtxt.pvfp[ref] # t^.pvfp THEN
                  old^.history := pvmodified
                END
              (* ELSE remain inconsistent *)
              END
            ELSIF old^.fprint # obj^.fprint THEN
              old^.history := pbmodified
            ELSIF impCtxt.pvfp[ref] # t^.pvfp THEN
              old^.history := pvmodified
            ELSIF old^.vis = internal THEN
              old^.history := same  (* may be changed to "removed" in InObj *)
            ELSE
              old^.history := inserted  (* may be changed to "same" in InObj *)
            END
          ELSE
            (* check private part, delay error message until really used *)
            IF impCtxt.pvfp[ref] # t^.pvfp THEN
              old^.history := inconsistent
            END;
            IF old^.fprint # obj^.fprint THEN
              FPrintErr(old, 249)
            END
          END
        ELSIF impCtxt.self THEN
          obj^.history := removed
        ELSE
          obj^.history := same
        END;
        INC(ref)
      END;
      impCtxt.minr := maxStruct
    END
  END
END InStruct;

PROCEDURE InObj(mno: SHORTINT): Object;  (* first number in impCtxt.nextTag *)
  VAR i, s: INTEGER; ch: CHAR; obj, old: Object; typ: Struct;
      tag: LONGINT; ext: ConstExt;
BEGIN
  tag := impCtxt.nextTag;
  IF tag = Stype THEN
    InStruct(typ); obj := typ^.strobj;
    IF ~impCtxt.self THEN obj^.vis := external END  (* type name visible now, obj^.fprint already done *)
  ELSE
    obj := NewObj(); obj^.mnolev := -mno; obj^.vis := external;
    IF tag <= Pointer THEN  (* Constant *)
      obj^.mode := Con; obj^.conval := NewConst(); InConstant(tag, obj^.conval);
      obj^.typ := InTyp(tag)
    ELSIF tag >= Sxpro THEN
      obj^.conval := NewConst();
      obj^.conval^.intval := -1;
      InSign(mno, obj^.typ, obj^.link);
      CASE tag OF
      | Sxpro: obj^.mode := XProc
      | Sipro: obj^.mode := IProc
      | Scpro: obj^.mode := CProc;
               ext := NewExt(); obj^.conval^.ext := ext;
               s := SHORT(OPM.SymRInt()); ext^[0] := CHR(s); i := 1;
               WHILE i <= s DO OPM.SymRCh(ext^[i]); INC(i) END
      ELSE     OPM.LogWStr("unhandled case at InObj, tag = "); OPM.LogWNum(tag, 0); OPM.LogWLn;
      END
    ELSIF tag = Salias THEN
      obj^.mode := Typ; InStruct(obj^.typ)
    ELSE
      obj^.mode := Var;
      IF tag = Srvar THEN obj^.vis := externalR END;
      InStruct(obj^.typ)
    END;
    InName(obj^.name)
  END;
  FPrintObj(obj);
  IF (obj^.mode = Var) & ((obj^.typ^.strobj = NIL) OR (obj^.typ^.strobj^.name = "")) THEN
    (* compute a global fingerprint to avoid structural type equivalence for anonymous types *)
    OPM.FPrint(impCtxt.reffp, obj^.typ^.ref - maxStruct)
  END;
  IF tag # Stype THEN
    InsertImport(obj, GlbMod[mno].right, old);
    IF impCtxt.self THEN
      IF old # NIL THEN
        (* obj is from old symbol file, old is new declaration *)
        IF old^.vis = internal THEN old^.history := removed
        ELSE FPrintObj(old);  (* FPrint(obj) already called *)
          IF obj^.fprint # old^.fprint THEN old^.history := pbmodified
          ELSIF obj^.typ^.pvfp # old^.typ^.pvfp THEN old^.history := pvmodified
          ELSE old^.history := same
          END
        END
      ELSE obj^.history := removed  (* OutObj not called if mnolev < 0 *)
      END
    (* ELSE old = NIL, or file read twice, consistent, OutObj not called *)
    END
  ELSE  (* obj already inserted in InStruct *)
    IF impCtxt.self THEN  (* obj^.mnolev = 0 *)
      IF obj^.vis = internal THEN obj^.history := removed
      ELSIF obj^.history = inserted THEN obj^.history := same
      END
    (* ELSE OutObj not called for obj with mnolev < 0 *)
    END
  END;
RETURN obj
END InObj;

PROCEDURE Import*(aliasName: OPS.Name; VAR name: OPS.Name; VAR done: BOOLEAN);
  VAR obj: Object; mno: SHORTINT;  (* done used in Browser *)
BEGIN
  IF name = "SYSTEM" THEN SYSimported := TRUE;
    Insert(aliasName, obj); obj^.mode := Mod; obj^.mnolev := 0; obj^.scope := syslink; obj^.typ := notyp
  ELSE
    impCtxt.nofr := FirstRef(*Comp+1*); impCtxt.minr := maxStruct; impCtxt.nofm := 0;
    impCtxt.self := aliasName = "@self"; impCtxt.reffp := 0;
    IF impCtxt.self & (OPM.forcenewsym IN OPM.Options) THEN
      OPM.DeleteSym(name); done := FALSE
    ELSE
      OPM.OldSym(name, done)
    END;
    IF done THEN
      InMod(mno); InLinks;
      impCtxt.nextTag := OPM.SymRInt();
      WHILE ~OPM.eofSF() DO
        obj := InObj(mno); impCtxt.nextTag := OPM.SymRInt()
      END;
      Insert(aliasName, obj);
      obj^.mode := Mod; obj^.scope := GlbMod[mno].right;
      GlbMod[mno].link := obj;
      obj^.mnolev  := -mno; obj^.typ := notyp;
      OPM.CloseOldSym
    ELSIF impCtxt.self THEN
      newsf := TRUE; extsf := TRUE; sfpresent := FALSE
    ELSE err(152)  (*sym file not found*)
    END
  END
END Import;

(*-------------------------- Export --------------------------*)

  PROCEDURE OutName(VAR name: ARRAY OF CHAR);
    VAR i: INTEGER; ch: CHAR;
  BEGIN i := 0;
    REPEAT ch := name[i]; OPM.SymWCh(ch); INC(i) UNTIL ch = 0X
  END OutName;

  PROCEDURE OutMod(mno: INTEGER);
  BEGIN
    IF expCtxt.locmno[mno] < 0 THEN (* new mod *)
      OPM.SymWInt(Smname);
      expCtxt.locmno[mno] := expCtxt.nofm; INC(expCtxt.nofm);
      OutName(GlbMod[mno].name)
    ELSE OPM.SymWInt(-expCtxt.locmno[mno])
    END
  END OutMod;

  PROCEDURE OutLinks;
    VAR l: Link;
  BEGIN
   l := Links; WHILE l # NIL DO OutName(l.name); l := l.next END;
   OPM.SymWCh(0X)
  END OutLinks;

  PROCEDURE ^OutStr(typ: Struct);
  PROCEDURE ^OutFlds(fld: Object; adr: LONGINT; visible: BOOLEAN);

  PROCEDURE OutHdFld(typ: Struct; fld: Object; adr: LONGINT);
    VAR i, j, n: LONGINT; btyp: Struct;
  BEGIN
    IF typ^.comp = Record THEN OutFlds(typ^.link, adr, FALSE)
    ELSIF typ^.comp = Array THEN btyp := typ^.BaseTyp; n := typ^.n;
      WHILE btyp^.comp = Array DO n := btyp^.n * n; btyp := btyp^.BaseTyp END;
      IF (btyp^.form = Pointer) OR (btyp^.comp = Record) THEN
        j := nofhdfld; OutHdFld(btyp, fld, adr);
        IF j # nofhdfld THEN i := 1;
          WHILE (i < n) & (nofhdfld <= OPM.MaxHdFld) DO
            INC(adr, btyp^.size); OutHdFld(btyp, fld, adr); INC(i)
          END
        END
      END
    ELSIF OPM.ExpHdPtrFld & ((typ^.form = Pointer) OR (fld^.name = OPM.HdPtrName)) THEN
      OPM.SymWInt(Shdptr); OPM.SymWInt(adr); INC(nofhdfld)
    ELSIF OPM.ExpHdProcFld & ((typ^.form = ProcTyp) OR (fld^.name = OPM.HdProcName)) THEN
      OPM.SymWInt(Shdpro); OPM.SymWInt(adr); INC(nofhdfld)
    END
  END OutHdFld;

  PROCEDURE OutFlds(fld: Object; adr: LONGINT; visible: BOOLEAN);
  BEGIN
    WHILE (fld # NIL) & (fld^.mode = Fld) DO
      IF (fld^.vis # internal) & visible THEN
        IF fld^.vis = externalR THEN OPM.SymWInt(Srfld) ELSE OPM.SymWInt(Sfld) END;
        OutStr(fld^.typ); OutName(fld^.name); OPM.SymWInt(fld^.adr)
      ELSE OutHdFld(fld^.typ, fld, fld^.adr + adr)
      END;
      fld := fld^.link
    END
  END OutFlds;

  PROCEDURE OutSign(result: Struct; par: Object);  (* Procedure signature *)
  BEGIN
    OutStr(result);
    WHILE par # NIL DO
      IF par^.mode = Var THEN OPM.SymWInt(Svalpar) ELSE OPM.SymWInt(Svarpar) END;
      OutStr(par^.typ);
      OPM.SymWInt(par^.adr);
      OutName(par^.name); par := par^.link
    END;
    OPM.SymWInt(Send)
  END OutSign;

  PROCEDURE OutTProcs(typ: Struct; obj: Object); (* Type bound procedures *)
  BEGIN
    IF obj # NIL THEN
      OutTProcs(typ, obj^.left);
      IF obj^.mode = TProc THEN
        IF (typ^.BaseTyp # NIL) & (obj^.adr DIV 10000H < typ^.BaseTyp^.n) & (obj^.vis = internal) THEN
          OPM.Mark(109, typ^.txtpos)
          (* hidden and overriding, not detected in OPP because record exported indirectly or via aliasing *)
        END;
        IF OPM.ExpHdTProc OR (obj^.vis # internal) THEN
          IF obj^.vis # internal THEN
            OPM.SymWInt(Stpro); OutSign(obj^.typ, obj^.link); OutName(obj^.name);
            OPM.SymWInt(obj^.adr DIV 10000H)
          ELSE
            OPM.SymWInt(Shdtpro);
            OPM.SymWInt(obj^.adr DIV 10000H)
          END
        END
      END;
      OutTProcs(typ, obj^.right)
    END
  END OutTProcs;

  PROCEDURE OutStr(typ: Struct);  (* OPV.TypeAlloc already applied *)
    VAR strobj: Object;
  BEGIN
    IF (typ^.ref < expCtxt.ref) THEN OPM.SymWInt(-typ^.ref);
      IF typ.ref IN {Int, Set} THEN OPM.SymWInt(typ.size) END
    ELSE
      OPM.SymWInt(Sstruct);
      typ^.ref := expCtxt.ref; INC(expCtxt.ref);
      IF expCtxt.ref >= maxStruct THEN err(228) END;
      OutMod(typ^.mno); strobj := typ^.strobj;

      IF (strobj # NIL) & (strobj^.name # "") THEN OutName(strobj^.name);
        CASE strobj^.history OF
        | pbmodified:   FPrintErr(strobj, 252)
        | pvmodified:   FPrintErr(strobj, 251)
        | inconsistent: FPrintErr(strobj, 249)
        ELSE (* checked in OutObj or correct indirect export *)
             (* OPM.LogWStr("unhandled case at OutStr, strobj^.history = "); OPM.LogWNum(strobj^.history, 0); OPM.LogWLn;*)
        END
      ELSE OPM.SymWCh(0X)  (* anonymous => never inconsistent, pvfp influences the client fp *)
      END;
      IF typ^.sysflag # 0 THEN OPM.SymWInt(Ssys); OPM.SymWInt(typ^.sysflag) END;
      CASE typ^.form OF
      | Pointer: OPM.SymWInt(Sptr); OutStr(typ^.BaseTyp)
      | ProcTyp: OPM.SymWInt(Spro); OutSign(typ^.BaseTyp, typ^.link)
      | Comp:    CASE typ^.comp OF
                 | Array:  OPM.SymWInt(Sarr); OutStr(typ^.BaseTyp); OPM.SymWInt(typ^.n)
                 | DynArr: OPM.SymWInt(Sdarr); OutStr(typ^.BaseTyp)
                 | Record: OPM.SymWInt(Srec);
                           IF typ^.BaseTyp = NIL THEN OutStr(notyp) ELSE OutStr(typ^.BaseTyp) END;
                           (* BaseTyp should be Notyp, too late to change *)
                           OPM.SymWInt(typ^.size); OPM.SymWInt(typ^.align); OPM.SymWInt(typ^.n);
                           nofhdfld := 0; OutFlds(typ^.link, 0, TRUE);
                           IF nofhdfld > OPM.MaxHdFld THEN OPM.Mark(223, typ^.txtpos) END;
                           OutTProcs(typ, typ^.link); OPM.SymWInt(Send)
                 ELSE      OPM.LogWStr("unhandled case at OutStr, typ^.comp = "); OPM.LogWNum(typ^.comp, 0); OPM.LogWLn;
                 END
      ELSE       OPM.LogWStr("unhandled case at OutStr, typ^.form = "); OPM.LogWNum(typ^.form, 0); OPM.LogWLn;
      END
    END
  END OutStr;

  PROCEDURE OutConstant(obj: Object);
    VAR f: INTEGER; rval: REAL;
  BEGIN
    f := obj^.typ^.form; OPM.SymWInt(f);
    CASE f OF
    | Bool,
      Char:   OPM.SymWCh(CHR(obj^.conval^.intval))
    | Int:    OPM.SymWInt(obj^.conval^.intval); OPM.SymWInt(obj.typ.size)
    | Set:    OPM.SymWSet(obj^.conval^.setval); OPM.SymWInt(obj.typ.size)
    | Real:   rval := SHORT(obj^.conval^.realval); OPM.SymWReal(rval)
    | LReal:  OPM.SymWLReal(obj^.conval^.realval)
    | String: OutName(obj^.conval^.ext^)
    | NilTyp:
    ELSE      err(127)
    END
  END OutConstant;

  PROCEDURE OutObj(obj: Object);
    VAR i, j: INTEGER; ext: ConstExt;
  BEGIN
    IF obj # NIL THEN
      OutObj(obj^.left);
      IF obj^.mode IN {Con, Typ, Var, LProc, XProc, CProc, IProc} THEN
        IF obj^.history = removed THEN FPrintErr(obj, 250)
        ELSIF obj^.vis # internal THEN
          CASE obj^.history OF
          | inserted:   FPrintErr(obj, 253)
          | same:       (* ok *)
          | pbmodified: FPrintErr(obj, 252)
          | pvmodified: FPrintErr(obj, 251)
          ELSE          OPM.LogWStr("unhandled case at OutObj, obj^.history = "); OPM.LogWNum(obj^.history, 0); OPM.LogWLn;
          END;
          CASE obj^.mode OF
          | Con:   OutConstant(obj); OutName(obj^.name)
          | Typ:   IF obj^.typ^.strobj = obj THEN OPM.SymWInt(Stype); OutStr(obj^.typ)
                   ELSE OPM.SymWInt(Salias); OutStr(obj^.typ); OutName(obj^.name)
                   END
          | Var:   IF obj^.vis = externalR THEN OPM.SymWInt(Srvar) ELSE OPM.SymWInt(Svar) END;
                   OutStr(obj^.typ); OutName(obj^.name);
                   IF (obj^.typ^.strobj = NIL) OR (obj^.typ^.strobj^.name = "") THEN
                     (* compute fingerprint to avoid structural type equivalence *)
                     OPM.FPrint(expCtxt.reffp, obj^.typ^.ref)
                   END
          | XProc: OPM.SymWInt(Sxpro); OutSign(obj^.typ, obj^.link); OutName(obj^.name)
          | IProc: OPM.SymWInt(Sipro); OutSign(obj^.typ, obj^.link); OutName(obj^.name)
          | CProc: OPM.SymWInt(Scpro); OutSign(obj^.typ, obj^.link); ext := obj^.conval^.ext;
                   j := ORD(ext^[0]); i := 1; OPM.SymWInt(j);
                   WHILE i <= j DO OPM.SymWCh(ext^[i]); INC(i) END;
                   OutName(obj^.name)
          ELSE     OPM.LogWStr("unhandled case at OutObj, obj.mode = "); OPM.LogWNum(obj.mode, 0); OPM.LogWLn;
          END
        END
      END;
      OutObj(obj^.right)
    END
  END OutObj;

  PROCEDURE Export*(VAR ext, new: BOOLEAN);
    VAR i: INTEGER; nofmod: SHORTINT; done: BOOLEAN;
  BEGIN
    symExtended := FALSE; symNew := FALSE; nofmod := nofGmod;
    Import("@self", SelfName, done); nofGmod := nofmod;
    IF OPM.noerr THEN  (* ~OPM.noerr => ~done *)
      OPM.NewSym(SelfName);
      IF OPM.noerr THEN
        OPM.SymWInt(Smname); OutName(SelfName); OutLinks;
        expCtxt.reffp := 0; expCtxt.ref := FirstRef(*Comp+1*);
        expCtxt.nofm := 1; expCtxt.locmno[0] := 0;
        i := 1; WHILE i < maxImps DO expCtxt.locmno[i] := -1; INC(i) END;
        OutObj(topScope^.right);
        ext := sfpresent & symExtended;
        new := ~sfpresent OR symNew OR (OPM.forcenewsym IN OPM.Options);
        IF OPM.noerr & sfpresent & (impCtxt.reffp # expCtxt.reffp) THEN
          new := TRUE;
          IF ~extsf THEN err(155) END
        END;
        newsf := FALSE; symNew := FALSE;  (* because of call to FPrintErr from OPL *)
        IF ~OPM.noerr OR findpc THEN
          OPM.DeleteSym(SelfName)
        END
        (* OPM.RegisterNewSym is called in OP2 after writing the object file *)
      END
    END
  END Export;  (* no new symbol file if ~OPM.noerr or findpc *)


(*------------------------- Initialise types --------------------------*)

  PROCEDURE InitStruct(VAR typ: Struct; form: SHORTINT);
  BEGIN
    typ := NewStr(form, Basic); typ^.ref := form; typ^.size := 1; typ^.allocated := TRUE;
    typ^.strobj := NewObj(); typ^.pbfp := form; typ^.pvfp := form; typ^.fpdone := TRUE;
    typ^.idfp := form; typ^.idfpdone := TRUE
  END InitStruct;

  PROCEDURE EnterBoolConst(name: OPS.Name; value: LONGINT);
    VAR obj: Object;
  BEGIN
    Insert(name, obj); obj^.conval := NewConst();
    obj^.mode := Con; obj^.typ := booltyp; obj^.conval^.intval := value
  END EnterBoolConst;

  PROCEDURE EnterTyp(name: OPS.Name; form: SHORTINT; size: INTEGER; VAR res: Struct);
    VAR obj: Object; typ: Struct;
  BEGIN
    Insert(name, obj);
    typ := NewStr(form, Basic); obj^.mode := Typ; obj^.typ := typ; obj^.vis := external;
    typ^.strobj := obj; typ^.size := size; typ^.ref := form; typ^.allocated := TRUE;
    typ^.pbfp := form; typ^.pvfp := form; typ^.fpdone := TRUE;
    typ^.idfp := form; typ^.idfpdone := TRUE;
    IF form IN {Int, Set} THEN OPM.FPrint(typ.idfp, typ.size) END;
    res := typ
  END EnterTyp;

  PROCEDURE EnterTypeAlias(name: OPS.Name; VAR res: Object);
    VAR obj: Object;
  BEGIN
    Insert(name, obj); obj^.mode := Typ; obj^.typ := NIL; obj^.vis := external;
    res := obj
  END EnterTypeAlias;

  PROCEDURE EnterProc(name: OPS.Name; num: INTEGER);
    VAR obj: Object;
  BEGIN Insert(name, obj);
    obj^.mode := SProc; obj^.typ := notyp; obj^.adr := num
  END EnterProc;



BEGIN topScope := NIL; OpenScope(0, NIL); OPM.errpos := 0;
  InitStruct(undftyp,   Undef);  undftyp^.BaseTyp := undftyp;
  InitStruct(notyp,     NoTyp);
  InitStruct(stringtyp, String);
  InitStruct(niltyp,    NilTyp);

  (*initialization of module SYSTEM*)
  EnterTyp("BYTE",    Byte,     1, bytetyp);
  EnterTyp("PTR",     Pointer, -1, sysptrtyp);  (* Size set in Compiler.PropagateElementaryTypeSize *)
  EnterTyp("ADDRESS", Int,     -1, adrtyp);     (* Size set in Compiler.PropagateElementaryTypeSize *)
  EnterTyp("INT8",    Int,      1, int8typ);
  EnterTyp("INT16",   Int,      2, int16typ);
  EnterTyp("INT32",   Int,      4, int32typ);
  EnterTyp("INT64",   Int,      8, int64typ);
  EnterTyp("SET32",   Set,      4, set32typ);
  EnterTyp("SET64",   Set,      8, set64typ);

  EnterProc("ADR",    adrfn);
  EnterProc("CC",     ccfn);
  EnterProc("LSH",    lshfn);
  EnterProc("ROT",    rotfn);
  EnterProc("GET",    getfn);
  EnterProc("PUT",    putfn);
  EnterProc("GETREG", getrfn);
  EnterProc("PUTREG", putrfn);
  EnterProc("BIT",    bitfn);
  EnterProc("VAL",    valfn);
  EnterProc("NEW",    sysnewfn);
  EnterProc("MOVE",   movefn);


  syslink  := topScope^.right;
  universe := topScope; topScope^.right := NIL;

  EnterTyp("BOOLEAN",  Bool,   1, booltyp);
  EnterTyp("CHAR",     Char,   1, chartyp);
  EnterTyp("REAL",     Real,   4, realtyp);
  EnterTyp("LONGREAL", LReal,  8, lrltyp);
  EnterTyp("HUGEINT",  Int,    8, hinttyp);
  EnterTyp("BYTE@",    Int,    1, cpbytetyp);  (* Component Pascal byte type, enabled in Compiler.PropagateElementaryTypeSize *)

  (* Type aliases for standard integer and set types are linked to real types in Compiler.PropagateElementaryTypeSize *)
  EnterTypeAlias("SHORTINT", sintobj);
  EnterTypeAlias("INTEGER",  intobj);
  EnterTypeAlias("LONGINT",  lintobj);
  EnterTypeAlias("SET",      setobj);


  EnterBoolConst("FALSE", 0);  (* 0 and 1 are compiler internal representation only *)
  EnterBoolConst("TRUE",  1);

  EnterProc("HALT",   haltfn);
  EnterProc("NEW",    newfn);
  EnterProc("ABS",    absfn);
  EnterProc("CAP",    capfn);
  EnterProc("ORD",    ordfn);
  EnterProc("ENTIER", entierfn);
  EnterProc("FLOOR",  floorfn);
  EnterProc("ODD",    oddfn);
  EnterProc("MIN",    minfn);
  EnterProc("MAX",    maxfn);
  EnterProc("CHR",    chrfn);
  EnterProc("SHORT",  shortfn);
  EnterProc("LONG",   longfn);
  EnterProc("SIZE",   sizefn);
  EnterProc("INC",    incfn);
  EnterProc("DEC",    decfn);
  EnterProc("INCL",   inclfn);
  EnterProc("EXCL",   exclfn);
  EnterProc("LEN",    lenfn);
  EnterProc("COPY",   copyfn);
  EnterProc("ASH",    ashfn);
  EnterProc("ASSERT", assertfn);

  impCtxt.ref[Undef]   := undftyp;
  impCtxt.ref[Byte]    := bytetyp;
  impCtxt.ref[Bool]    := booltyp;
  impCtxt.ref[Char]    := chartyp;
  impCtxt.ref[Int]     := int32typ;
  impCtxt.ref[Real]    := realtyp;
  impCtxt.ref[LReal]   := lrltyp;
  impCtxt.ref[Set]     := settyp;
  impCtxt.ref[String]  := stringtyp;
  impCtxt.ref[NilTyp]  := niltyp;
  impCtxt.ref[NoTyp]   := notyp;
  impCtxt.ref[Pointer] := sysptrtyp;

END OPT.

Objects:

    mode  | adr    conval  link     scope    leaf
   ------------------------------------------------
    Undef |                                         Not used
    Var   | vadr           next              regopt Glob or loc var or proc value parameter
    VarPar| vadr           next              regopt Procedure var parameter
    Con   |        val                              Constant
    Fld   | off            next                     Record field
    Typ   |                                         Named type
    LProc | entry  sizes   firstpar scope    leaf   Local procedure, entry adr set in back-end
    XProc | entry  sizes   firstpar scope    leaf   External procedure, entry adr set in back-end
    SProc | fno    sizes                            Standard procedure
    CProc |        code    firstpar scope           Code procedure
    IProc | entry  sizes            scope    leaf   Interrupt procedure, entry adr set in back-end
    Mod   |                         scope           Module
    Head  | txtpos         owner    firstvar        Scope anchor
    TProc | index  sizes   firstpar scope    leaf   Bound procedure, index = 10000H*mthno+entry, entry adr set in back-end

    Structures:

    form    comp  | n      BaseTyp   link     mno  txtpos   sysflag
  ----------------------------------------------------------------------------------
    Undef   Basic |
    Byte    Basic |
    Bool    Basic |
    Char    Basic |
    Int     Basic |                                                                   size determine SHORT vs LONG
    XInt    Basic | bits
    Real    Basic |
    LReal   Basic |
    Set     Basic |
    String  Basic |
    NilTyp  Basic |
    NoTyp   Basic |
    Pointer Basic |        PBaseTyp           mno  txtpos   sysflag
    ProcTyp Basic |        ResTyp    params   mno  txtpos   sysflag
    Comp    Array | nofel  ElemTyp            mno  txtpos   sysflag
    Comp    DynArr| dim    ElemTyp            mno  txtpos   sysflag
    Comp    Record| nofmth RBaseTyp  fields   mno  txtpos   sysflag

Nodes:

design   = Nvar|Nvarpar|Nfield|Nderef|Nindex|Nguard|Neguard|Ntype|Nproc.
expr     = design|Nconst|Nupto|Nmop|Ndop|Ncall.
nextexpr = NIL|expr.
ifstat   = NIL|Nif.
casestat = Ncaselse.
sglcase  = NIL|Ncasedo.
stat     = NIL|Ninittd|Nenter|Nassign|Ncall|Nifelse|Ncase|Nwhile|Nrepeat|
           Nloop|Nexit|Nreturn|Nwith|Ntrap.


              class     subcl     obj      left      right     link
              ---------------------------------------------------------

design        Nvar                var                          nextexpr
              Nvarpar             varpar                       nextexpr
              Nfield              field    design              nextexpr
              Nderef                       design              nextexpr
              Nindex                       design    expr      nextexpr
              Nguard                       design              nextexpr (typ = guard type)
              Neguard                      design              nextexpr (typ = guard type)
              Ntype               type                         nextexpr
              Nproc     normal    proc                         nextexpr
                        super     proc                         nextexpr


expr          design
              Nconst              const                                 (val = node^.conval)
              Nupto                        expr      expr      nextexpr
              Nmop      not                expr                nextexpr
                        minus              expr                nextexpr
                        is        tsttype  expr                nextexpr
                        conv               expr                nextexpr
                        abs                expr                nextexpr
                        cap                expr                nextexpr
                        odd                expr                nextexpr
                        adr                expr                nextexpr SYSTEM.ADR
                        cc                 Nconst              nextexpr SYSTEM.CC
                        val                expr                nextexpr SYSTEM.VAL
              Ndop      times              expr      expr      nextexpr
                        slash              expr      expr      nextexpr
                        div                expr      expr      nextexpr
                        mod                expr      expr      nextexpr
                        and                expr      expr      nextexpr
                        plus               expr      expr      nextexpr
                        minus              expr      expr      nextexpr
                        or                 expr      expr      nextexpr
                        eql                expr      expr      nextexpr
                        neq                expr      expr      nextexpr
                        lss                expr      expr      nextexpr
                        leq                expr      expr      nextexpr
                        grt                expr      expr      nextexpr
                        geq                expr      expr      nextexpr
                        in                 expr      expr      nextexpr
                        ash                expr      expr      nextexpr
                        msk                expr      Nconst    nextexpr
                        len                design    Nconst    nextexpr
                        bit                expr      expr      nextexpr SYSTEM.BIT
                        lsh                expr      expr      nextexpr SYSTEM.LSH
                        rot                expr      expr      nextexpr SYSTEM.ROT
              Ncall               fpar     design    nextexpr  nextexpr

nextexpr      NIL
              expr

ifstat        NIL
              Nif                          expr      stat      ifstat

casestat      Ncaselse                     sglcase   stat            (minmax = node^.conval)

sglcase       NIL
              Ncasedo                      Nconst    stat      sglcase

stat          NIL
              Ninittd                                          stat     (of node^.typ)
              Nenter              proc     stat      stat      stat     (proc=NIL for mod)
              Nassign   assign             design    expr      stat
                        newfn              design              stat
                        incfn              design    expr      stat
                        decfn              design    expr      stat
                        inclfn             design    expr      stat
                        exclfn             design    expr      stat
                        copyfn             design    expr      stat
                        getfn              design    expr      stat     SYSTEM.GET
                        putfn              expr      expr      stat     SYSTEM.PUT
                        getrfn             design    Nconst    stat     SYSTEM.GETREG
                        putrfn             Nconst    expr      stat     SYSTEM.PUTREG
                        sysnewfn           design    expr      stat     SYSTEM.NEW
                        movefn             expr      expr      stat     SYSTEM.MOVE
                                                                        (right^.link = 3rd par)
              Ncall               fpar     design    nextexpr  stat
              Nifelse                      ifstat    stat      stat
              Ncase                        expr      casestat  stat
              Nwhile                       expr      stat      stat
              Nrepeat                      stat      expr      stat
              Nloop                        stat                stat
              Nexit                                            stat
              Nreturn             proc     nextexpr            stat     (proc = NIL for mod)
              Nwith                        ifstat    stat      stat
              Ntrap                                  expr      stat
