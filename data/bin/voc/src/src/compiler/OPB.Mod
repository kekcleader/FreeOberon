MODULE OPB;  (* RC 6.3.89 / 21.2.94 *)  (* object model 17.1.93 *)
(* build parse tree *)

  IMPORT OPT, OPS, OPM, SYSTEM;


  CONST
    AssertTrap = 0;  (* default trap number *)


  VAR
    exp:      INTEGER;       (* side effect of log*)
    maxExp:   SYSTEM.INT64;  (* max n in ASH(1, n) on this machine *)


  PROCEDURE err(n: INTEGER);
  BEGIN OPM.err(n)
  END err;


  PROCEDURE NewLeaf*(obj: OPT.Object): OPT.Node;
    VAR node: OPT.Node;
  BEGIN
    CASE obj^.mode OF
    | OPT.Var:    node := OPT.NewNode(OPT.Nvar);
                  node^.readonly := (obj^.vis = OPT.externalR) & (obj^.mnolev < 0)
    | OPT.VarPar: node := OPT.NewNode(OPT.Nvarpar)
    | OPT.Con:    node := OPT.NewNode(OPT.Nconst);
                  node^.conval := OPT.NewConst();
                  node^.conval^ := obj^.conval^  (* string is not copied, only its ref *)
    | OPT.Typ:    node := OPT.NewNode(OPT.Ntype)
    | OPT.LProc
    ..OPT.IProc:  node := OPT.NewNode(OPT.Nproc)
    ELSE          node := OPT.NewNode(OPT.Nvar); err(127)
    END ;
    node^.obj := obj; node^.typ := obj^.typ;
    RETURN node
  END NewLeaf;

  PROCEDURE Construct*(class: SHORTINT; VAR x: OPT.Node;  y: OPT.Node);
    VAR node: OPT.Node;
  BEGIN
    node := OPT.NewNode(class); node^.typ := OPT.notyp;
    node^.left := x; node^.right := y; x := node
  END Construct;

  PROCEDURE Link*(VAR x, last: OPT.Node; y: OPT.Node);
  BEGIN
    IF x = NIL THEN x := y ELSE last^.link := y END ;
    WHILE y^.link # NIL DO y := y^.link END ;
    last := y
  END Link;

  PROCEDURE BoolToInt(b: BOOLEAN): INTEGER;
  BEGIN
    IF b THEN RETURN 1 ELSE RETURN 0 END
  END BoolToInt;

  PROCEDURE IntToBool(i: SYSTEM.INT64): BOOLEAN;
  BEGIN RETURN i # 0
  END IntToBool;

  PROCEDURE NewBoolConst*(boolval: BOOLEAN): OPT.Node;
    VAR x: OPT.Node;
  BEGIN
    x := OPT.NewNode(OPT.Nconst); x^.typ := OPT.booltyp;
    x^.conval := OPT.NewConst(); x^.conval^.intval := BoolToInt(boolval); RETURN x
  END NewBoolConst;

  PROCEDURE OptIf*(VAR x: OPT.Node);  (* x^.link = NIL *)
    VAR if, pred: OPT.Node;
  BEGIN
    if := x^.left;
    WHILE if^.left^.class = OPT.Nconst DO
      IF IntToBool(if^.left^.conval^.intval) THEN x := if^.right; RETURN
      ELSIF if^.link = NIL THEN x := x^.right; RETURN
      ELSE if := if^.link; x^.left := if
      END
    END ;
    pred := if; if := if^.link;
    WHILE if # NIL DO
      IF if^.left^.class = OPT.Nconst THEN
        IF IntToBool(if^.left^.conval^.intval) THEN
          pred^.link := NIL; x^.right := if^.right; RETURN
        ELSE if := if^.link; pred^.link := if
        END
      ELSE pred := if; if := if^.link
      END
    END
  END OptIf;

  PROCEDURE Nil*(): OPT.Node;
    VAR x: OPT.Node;
  BEGIN
    x := OPT.NewNode(OPT.Nconst); x^.typ := OPT.niltyp;
    x^.conval := OPT.NewConst(); x^.conval^.intval := OPM.nilval; RETURN x
  END Nil;

  PROCEDURE EmptySet*(): OPT.Node;
    VAR x: OPT.Node;
  BEGIN
    x := OPT.NewNode(OPT.Nconst); x^.typ := OPT.settyp;
    x^.conval := OPT.NewConst(); x^.conval^.setval := {}; RETURN x
  END EmptySet;

  PROCEDURE SetIntType(node: OPT.Node);
  BEGIN node.typ := OPT.IntType(OPT.IntSize(node.conval.intval))
  END SetIntType;

  PROCEDURE SetSetType(node: OPT.Node);
    VAR i32: SYSTEM.INT32;
  BEGIN SYSTEM.GET(SYSTEM.ADR(node.conval.setval)+4, i32); (* See if upper 32 bits are zero *)
    IF i32 = 0 THEN node.typ := OPT.set32typ ELSE node.typ := OPT.set64typ END
  END SetSetType;

  PROCEDURE NewIntConst*(intval: SYSTEM.INT64): OPT.Node;
    VAR x: OPT.Node;
  BEGIN
    x := OPT.NewNode(OPT.Nconst);  x^.conval := OPT.NewConst();
    x^.conval^.intval := intval; SetIntType(x); RETURN x
  END NewIntConst;

  PROCEDURE NewRealConst*(realval: LONGREAL; typ: OPT.Struct): OPT.Node;
    VAR x: OPT.Node;
  BEGIN
    x := OPT.NewNode(OPT.Nconst); x^.conval := OPT.NewConst();
    x^.conval^.realval := realval; x^.typ := typ; x^.conval^.intval := OPM.ConstNotAlloc;
    RETURN x
  END NewRealConst;

  PROCEDURE NewString*(VAR str: OPS.String; len: SYSTEM.INT64): OPT.Node;
    VAR x: OPT.Node;
  BEGIN
    x := OPT.NewNode(OPT.Nconst); x^.conval := OPT.NewConst(); x^.typ := OPT.stringtyp;
    x^.conval^.intval := OPM.ConstNotAlloc; x^.conval^.intval2 := OPM.Longint(len);
    x^.conval^.ext := OPT.NewExt(); x^.conval^.ext^ := str;
    RETURN x
  END NewString;

  PROCEDURE CharToString(n: OPT.Node);
    VAR ch: CHAR;
  BEGIN
    n^.typ := OPT.stringtyp; ch := CHR(n^.conval^.intval); n^.conval^.ext := OPT.NewExt();
    IF ch = 0X THEN n^.conval^.intval2 := 1 ELSE n^.conval^.intval2 := 2; n^.conval^.ext[1] := 0X END ;
    n^.conval^.ext[0] := ch; n^.conval^.intval := OPM.ConstNotAlloc; n^.obj := NIL
  END CharToString;

  PROCEDURE BindNodes(class: SHORTINT; typ: OPT.Struct; VAR x: OPT.Node; y: OPT.Node);
    VAR node: OPT.Node;
  BEGIN
    node := OPT.NewNode(class); node^.typ := typ;
    node^.left := x; node^.right := y; x := node
  END BindNodes;

  PROCEDURE NotVar(x: OPT.Node): BOOLEAN;
  BEGIN RETURN (x^.class >= OPT.Nconst) & ((x^.class # OPT.Nmop) OR (x^.subcl # OPT.val) OR (x^.left^.class >= OPT.Nconst))
  END NotVar;

  PROCEDURE DeRef*(VAR x: OPT.Node);
    VAR strobj, bstrobj: OPT.Object; typ, btyp: OPT.Struct;
  BEGIN
    typ := x^.typ;
    IF x^.class >= OPT.Nconst THEN err(78)
    ELSIF typ^.form = OPT.Pointer THEN
      IF typ = OPT.sysptrtyp THEN err(57) END ;
      btyp := typ^.BaseTyp; strobj := typ^.strobj; bstrobj := btyp^.strobj;
      IF (strobj # NIL) & (strobj^.name # "") & (bstrobj # NIL) & (bstrobj^.name # "") THEN
        btyp^.pbused := TRUE
      END ;
      BindNodes(OPT.Nderef, btyp, x, NIL)
    ELSE err(84)
    END
  END DeRef;

  PROCEDURE Index*(VAR x: OPT.Node; y: OPT.Node);
    VAR f: INTEGER; typ: OPT.Struct;
  BEGIN
    f := y^.typ^.form;
    IF x^.class >= OPT.Nconst THEN err(79)
    ELSIF (f # OPT.Int) OR (y^.class IN {OPT.Nproc, OPT.Ntype}) THEN err(80); y^.typ := OPT.inttyp END ;
    IF x^.typ^.comp = OPT.Array THEN typ := x^.typ^.BaseTyp;
      IF (y^.class = OPT.Nconst) & ((y^.conval^.intval < 0) OR (y^.conval^.intval >= x^.typ^.n)) THEN err(81) END
    ELSIF x^.typ^.comp = OPT.DynArr THEN typ := x^.typ^.BaseTyp;
      IF (y^.class = OPT.Nconst) & (y^.conval^.intval < 0) THEN err(81) END
    ELSE err(82); typ := OPT.undftyp
    END ;
    BindNodes(OPT.Nindex, typ, x, y); x^.readonly := x^.left^.readonly
  END Index;

  PROCEDURE Field*(VAR x: OPT.Node; y: OPT.Object);
  BEGIN (*x^.typ^.comp = OPT.Record*)
    IF x^.class >= OPT.Nconst THEN err(77) END ;
    IF (y # NIL) & (y^.mode IN {OPT.Fld, OPT.TProc}) THEN
      BindNodes(OPT.Nfield, y^.typ, x, NIL); x^.obj := y;
      x^.readonly := x^.left^.readonly OR ((y^.vis = OPT.externalR) & (y^.mnolev < 0))
    ELSE err(83); x^.typ := OPT.undftyp
    END
  END Field;

  PROCEDURE TypTest*(VAR x: OPT.Node; obj: OPT.Object; guard: BOOLEAN);

    PROCEDURE GTT(t0, t1: OPT.Struct);
      VAR node: OPT.Node; t: OPT.Struct;
    BEGIN t := t0;
      WHILE (t # NIL) & (t # t1) & (t # OPT.undftyp) DO t := t^.BaseTyp END ;
      IF t # t1 THEN
        WHILE (t1 # NIL) & (t1 # t0) & (t1 # OPT.undftyp) DO t1 := t1^.BaseTyp END ;
        IF (t1 = t0) OR (t0.form = OPT.Undef (*SYSTEM.PTR*)) THEN
          IF guard THEN BindNodes(OPT.Nguard, NIL, x, NIL); x^.readonly := x^.left^.readonly
          ELSE node := OPT.NewNode(OPT.Nmop); node^.subcl := OPS.is; node^.left := x;
            node^.obj := obj; x := node
          END
        ELSE err(85)
        END
      ELSIF t0 # t1 THEN err(85)  (* prevent down guard *)
      ELSIF ~guard THEN
        IF x^.class = OPT.Nguard THEN  (* cannot skip guard *)
          node := OPT.NewNode(OPT.Nmop); node^.subcl := OPS.is; node^.left := x;
          node^.obj := obj; x := node
        ELSE x := NewBoolConst(TRUE)
        END
      END
    END GTT;

  BEGIN
    IF NotVar(x) THEN err(112)
    ELSIF x^.typ^.form = OPT.Pointer THEN
      IF (x^.typ^.BaseTyp^.comp # OPT.Record) & (x^.typ # OPT.sysptrtyp) THEN err(85)
      ELSIF obj^.typ^.form = OPT.Pointer THEN GTT(x^.typ^.BaseTyp, obj^.typ^.BaseTyp)
      ELSE err(86)
      END
    ELSIF (x^.typ^.comp = OPT.Record) & (x^.class = OPT.Nvarpar) & (obj^.typ^.comp = OPT.Record) THEN
      GTT(x^.typ, obj^.typ)
    ELSE err(87)
    END ;
    IF guard THEN x^.typ := obj^.typ ELSE x^.typ := OPT.booltyp END
  END TypTest;

  PROCEDURE In*(VAR x: OPT.Node; y: OPT.Node);
    VAR f: INTEGER; k: SYSTEM.INT64;
  BEGIN f := x^.typ^.form;
    IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) OR (y^.class = OPT.Ntype) OR (y^.class = OPT.Nproc) THEN err(126)
    ELSIF (f = OPT.Int) & (y^.typ^.form = OPT.Set) THEN
      IF x^.class = OPT.Nconst THEN
        k := x^.conval^.intval;
        IF (k < 0) OR (k >= y.typ.size*8) THEN err(202)
        ELSIF y^.class = OPT.Nconst THEN x^.conval^.intval := BoolToInt(k IN y^.conval^.setval); x^.obj := NIL
        ELSE BindNodes(OPT.Ndop, OPT.booltyp, x, y); x^.subcl := OPS.in
        END
      ELSE BindNodes(OPT.Ndop, OPT.booltyp, x, y); x^.subcl := OPS.in
      END
    ELSE err(92)
    END ;
    x^.typ := OPT.booltyp
  END In;

  PROCEDURE log(x: SYSTEM.INT64): SYSTEM.INT64;
  BEGIN exp := 0;
    IF x > 0 THEN
      WHILE ~ODD(x) DO x := x DIV 2; INC(exp) END
    END ;
    RETURN x
  END log;

  PROCEDURE CheckRealType(f, nr: INTEGER; x: OPT.Const);
    VAR min, max, r: LONGREAL;
  BEGIN
    IF f = OPT.Real THEN min := OPM.MinReal; max := OPM.MaxReal
    ELSE min := OPM.MinLReal; max := OPM.MaxLReal
    END ;
    r := ABS(x^.realval);
    IF (r > max) OR (r < min) THEN
        err(nr); x^.realval := 1.0
    ELSIF f = OPT.Real THEN x^.realval := SHORT(x^.realval)  (* single precision only *)
    END ;
    x^.intval := OPM.ConstNotAlloc
  END CheckRealType;

  PROCEDURE MOp*(op: SHORTINT; VAR x: OPT.Node);
    VAR f: INTEGER; typ: OPT.Struct; z: OPT.Node;

    PROCEDURE NewOp(op: SHORTINT; typ: OPT.Struct; z: OPT.Node): OPT.Node;
      VAR node: OPT.Node;
    BEGIN
      node := OPT.NewNode(OPT.Nmop); node^.subcl := op; node^.typ := typ;
      node^.left := z; RETURN node
    END NewOp;

  BEGIN z := x;
    IF (z^.class = OPT.Ntype) OR (z^.class = OPT.Nproc) THEN err(126)
    ELSE typ := z^.typ; f := typ^.form;
      CASE op OF
      |OPS.not:   IF f = OPT.Bool THEN
                    IF z^.class = OPT.Nconst THEN
                      z^.conval^.intval := BoolToInt(~IntToBool(z^.conval^.intval)); z^.obj := NIL
                    ELSE z := NewOp(op, typ, z)
                    END
                  ELSE err(98)
                  END
      |OPS.plus:  IF ~(f IN {OPT.Int} + OPT.realSet) THEN err(96) END
      |OPS.minus: IF f IN {OPT.Int, OPT.Set} + OPT.realSet THEN
                    IF z^.class = OPT.Nconst THEN
                      IF f = OPT.Int THEN
                        IF z^.conval^.intval = MIN(SYSTEM.INT64) THEN err(203)
                        ELSE z^.conval^.intval := -z^.conval^.intval; SetIntType(z)
                        END
                      ELSIF f IN OPT.realSet THEN z^.conval^.realval := -z^.conval^.realval
                      ELSE
                        IF z.typ.size = 8 THEN
                          z^.conval^.setval := -z^.conval^.setval
                        ELSE
                          z.conval.setval := z.conval.setval / {0..31}
                        END
                      END;
                      z^.obj := NIL
                    ELSE z := NewOp(op, typ, z)
                    END
                  ELSE err(97)
                  END
      |OPT.abs:   IF f IN {OPT.Int} + OPT.realSet THEN
                    IF z^.class = OPT.Nconst THEN
                      IF f = OPT.Int THEN
                        IF z^.conval^.intval = MIN(SYSTEM.INT64) THEN err(203)
                        ELSE z^.conval^.intval := ABS(z^.conval^.intval); SetIntType(z)
                        END
                      ELSE z^.conval^.realval := ABS(z^.conval^.realval)
                      END ;
                      z^.obj := NIL
                    ELSE z := NewOp(op, typ, z)
                    END
                  ELSE err(111)
                  END
      |OPT.cap:   IF f = OPT.Char THEN
                    IF z^.class = OPT.Nconst THEN
                      z^.conval^.intval := ORD(CAP(CHR(z^.conval^.intval))); z^.obj := NIL
                    ELSE z := NewOp(op, typ, z)
                    END
                  ELSE err(111); z^.typ := OPT.chartyp
                  END
      |OPT.odd:   IF f = OPT.Int THEN
                    IF z^.class = OPT.Nconst THEN
                      z^.conval^.intval := BoolToInt(ODD(z^.conval^.intval)); z^.obj := NIL
                    ELSE z := NewOp(op, typ, z)
                    END
                  ELSE err(111)
                  END ;
                  z^.typ := OPT.booltyp
      |OPT.adr:   IF (z^.class = OPT.Nconst) & (f = OPT.Char) & (z^.conval^.intval >= 20H) THEN    (*SYSTEM.ADR*)
                    CharToString(z); f := OPT.String
                  END;
                  IF (z^.class < OPT.Nconst) OR (f = OPT.String) THEN z := NewOp(op, typ, z)
                  ELSE err(127)
                  END ;
                  z^.typ := OPT.adrtyp
      |OPT.cc:    IF (f = OPT.Int) & (z^.class = OPT.Nconst) THEN                              (*SYSTEM.CC*)
                    IF (0 <= z^.conval^.intval) & (z^.conval^.intval <= OPM.MaxCC) THEN z := NewOp(op, typ, z) ELSE err(219) END
                  ELSE err(69)
                  END ;
                  z^.typ := OPT.booltyp
      ELSE OPM.LogWStr("unhandled case in OPB.MOp, op = "); OPM.LogWNum(op, 0); OPM.LogWLn;
      END
    END ;
    x := z
  END MOp;

  PROCEDURE CheckPtr(x, y: OPT.Node);
    VAR g: INTEGER; p, q, t: OPT.Struct;
  BEGIN g := y^.typ^.form;
    IF g = OPT.Pointer THEN
      p := x^.typ^.BaseTyp; q := y^.typ^.BaseTyp;
      IF (p^.comp = OPT.Record) & (q^.comp = OPT.Record) THEN
        IF p^.extlev < q^.extlev THEN t := p; p := q; q := t END ;
        WHILE (p # q) & (p # NIL) & (p # OPT.undftyp) DO p := p^.BaseTyp END ;
        IF p = NIL THEN err(100) END
      ELSE err(100)
      END
    ELSIF g # OPT.NilTyp THEN err(100)
    END
  END CheckPtr;

  PROCEDURE CheckParameters*(fp, ap: OPT.Object; checkNames: BOOLEAN);
    VAR ft, at: OPT.Struct;
  BEGIN
    WHILE fp # NIL DO
      IF ap # NIL THEN
        ft := fp^.typ; at := ap^.typ;
        WHILE (ft^.comp = OPT.DynArr) & (at^.comp = OPT.DynArr) DO
          ft := ft^.BaseTyp; at := at^.BaseTyp
        END ;
        IF ft # at THEN
          IF (ft^.form = OPT.ProcTyp) & (at^.form = OPT.ProcTyp) THEN
            IF ft^.BaseTyp = at^.BaseTyp THEN CheckParameters(ft^.link, at^.link, FALSE)
            ELSE err(117)
            END
          ELSE err(115)
          END
        END ;
        IF (fp^.mode # ap^.mode) OR checkNames & (fp^.name # ap^.name) THEN err(115) END ;
        ap := ap^.link
      ELSE err(116)
      END ;
      fp := fp^.link
    END ;
    IF ap # NIL THEN err(116) END
  END CheckParameters;

  PROCEDURE CheckProc(x: OPT.Struct; y: OPT.Object);  (* proc var x := proc y, check compatibility *)
  BEGIN
    IF y^.mode IN {OPT.XProc, OPT.IProc, OPT.LProc} THEN
      IF y^.mode = OPT.LProc THEN
        IF y^.mnolev = 0 THEN y^.mode := OPT.XProc
        ELSE err(73)
        END
      END ;
      IF x^.BaseTyp = y^.typ THEN CheckParameters(x^.link, y^.link, FALSE)
      ELSE err(117)
      END
    ELSE err(113)
    END
  END CheckProc;

  PROCEDURE ConstOp(op: INTEGER; x, y: OPT.Node);
    VAR f, g: INTEGER; xval, yval: OPT.Const; xv, yv: SYSTEM.INT64;
        temp: BOOLEAN; (* temp avoids err 215 *)

    PROCEDURE ConstCmp(): INTEGER;
      VAR res: INTEGER;
    BEGIN
      CASE f OF
      |OPT.Undef:   res := OPS.eql
      |OPT.Byte,
       OPT.Char
       ..OPT.Int:  IF xval^.intval < yval^.intval THEN res := OPS.lss
                    ELSIF xval^.intval > yval^.intval THEN res := OPS.gtr
                    ELSE res := OPS.eql
                    END
      |OPT.Real,
       OPT.LReal:   IF xval^.realval < yval^.realval THEN res := OPS.lss
                    ELSIF xval^.realval > yval^.realval THEN res := OPS.gtr
                    ELSE res := OPS.eql
                    END
      |OPT.Bool:    IF xval^.intval # yval^.intval THEN res := OPS.neq
                    ELSE res := OPS.eql
                    END
      |OPT.Set:     IF xval^.setval # yval^.setval THEN res := OPS.neq
                    ELSE res := OPS.eql
                    END
      |OPT.String:  IF xval^.ext^ < yval^.ext^ THEN res := OPS.lss
                    ELSIF xval^.ext^ > yval^.ext^ THEN res := OPS.gtr
                    ELSE res := OPS.eql
                    END
      |OPT.NilTyp,
       OPT.Pointer,
       OPT.ProcTyp: IF xval^.intval # yval^.intval THEN res := OPS.neq
                    ELSE res := OPS.eql
                    END
      ELSE OPM.LogWStr("unhandled case in OPB.ConstCmp, f = "); OPM.LogWNum(f, 0); OPM.LogWLn;
      END ;
      x^.typ := OPT.booltyp; RETURN res
    END ConstCmp;

  BEGIN
    (* f, x, xval are for left side; g, y, yval for right side. *)
    f := x^.typ^.form; g := y^.typ^.form; xval := x^.conval; yval := y^.conval;
    IF f # g THEN
      CASE f OF
      |OPT.Char:    IF g = OPT.String THEN CharToString(x)
                    ELSE err(100); y^.typ := x^.typ; yval^ := xval^
                    END ;
      |OPT.Int:     IF g = OPT.Int THEN
                      IF x.typ.size <= y.typ.size THEN x.typ := y.typ ELSE x.typ := OPT.IntType(x.typ.size) END
                    ELSIF g = OPT.Real THEN x^.typ := OPT.realtyp; xval^.realval := xval^.intval
                    ELSIF g = OPT.LReal THEN x^.typ := OPT.lrltyp; xval^.realval := xval^.intval
                    ELSE  err(100); y^.typ := x^.typ; yval^ := xval^
                    END
      |OPT.Real:    IF g = OPT.Int THEN y^.typ := x^.typ; yval^.realval := yval^.intval
                    ELSIF g = OPT.LReal THEN x^.typ := OPT.lrltyp
                    ELSE  err(100); y^.typ := x^.typ; yval^ := xval^
                    END
      |OPT.LReal:   IF g = OPT.Int THEN y^.typ := x^.typ; yval^.realval := yval^.intval
                    ELSIF g = OPT.Real THEN y^.typ := OPT.lrltyp
                    ELSE  err(100); y^.typ := x^.typ; yval^ := xval^
                    END
      |OPT.String:  IF g = OPT.Char THEN CharToString(y); g := OPT.String
                    ELSE err(100); y^.typ := x^.typ; yval^ := xval^
                    END ;
      |OPT.NilTyp:  IF ~(g IN {OPT.Pointer, OPT.ProcTyp}) THEN err(100) END
      |OPT.Pointer: CheckPtr(x, y)
      |OPT.ProcTyp: IF g # OPT.NilTyp THEN err(100) END
      ELSE err(100); y^.typ := x^.typ; yval^ := xval^
      END ;
      f := x^.typ^.form
    END ;  (* {x^.typ = y^.typ} *)
    CASE op OF
    |OPS.times: IF f = OPT.Int THEN xv := xval^.intval; yv := yval^.intval;
                  IF (xv = 0) OR (yv = 0) OR  (* division with negative numbers is not defined *)
                    (xv > 0) & (yv > 0) & (yv <= MAX(SYSTEM.INT64) DIV xv) OR
                    (xv > 0) & (yv < 0) & (yv >= MIN(SYSTEM.INT64) DIV xv) OR
                    (xv < 0) & (yv > 0) & (xv >= MIN(SYSTEM.INT64) DIV yv) OR
                    (xv < 0) & (yv < 0) & (xv  # MIN(SYSTEM.INT64)) & (yv # MIN(SYSTEM.INT64)) & (-xv <= MAX(SYSTEM.INT64) DIV (-yv)) THEN
                    xval^.intval := xv * yv; SetIntType(x)
                  ELSE err(204)
                  END
                ELSIF f IN OPT.realSet THEN
                  temp := ABS(yval^.realval) <= 1.0;
                  IF temp OR (ABS(xval^.realval) <= MAX(LONGREAL) / ABS(yval^.realval)) THEN
                    xval^.realval := xval^.realval * yval^.realval; CheckRealType(f, 204, xval)
                  ELSE err(204)
                  END
                ELSIF f = OPT.Set THEN
                  xval^.setval := xval^.setval * yval^.setval; SetSetType(x)
                ELSIF f # OPT.Undef THEN err(101)
                END
    |OPS.slash: IF f = OPT.Int THEN
                  IF yval^.intval # 0 THEN
                    xval^.realval := xval^.intval / yval^.intval; CheckRealType(OPT.Real, 205, xval)
                  ELSE err(205); xval^.realval := 1.0
                  END ;
                  x^.typ := OPT.realtyp
                ELSIF f IN OPT.realSet THEN
                  temp := ABS(yval^.realval) >= 1.0;
                  IF temp OR (ABS(xval^.realval) <= MAX(LONGREAL) * ABS(yval^.realval)) THEN
                    xval^.realval := xval^.realval / yval^.realval; CheckRealType(f, 205, xval)
                  ELSE err(205)
                  END
                ELSIF f = OPT.Set THEN
                  xval^.setval := xval^.setval / yval^.setval; SetSetType(x)
                ELSIF f # OPT.Undef THEN err(102)
                END
    |OPS.div:   IF f = OPT.Int THEN
                  IF yval^.intval # 0 THEN
                    xval^.intval := xval^.intval DIV yval^.intval; SetIntType(x)
                  ELSE err(205)
                  END
                ELSIF f # OPT.Undef THEN err(103)
                END
    |OPS.mod:   IF f = OPT.Int THEN
                  IF yval^.intval # 0 THEN
                    xval^.intval := xval^.intval MOD yval^.intval; SetIntType(x)
                  ELSE err(205)
                  END
                ELSIF f # OPT.Undef THEN err(104)
                END
    |OPS.and:   IF f = OPT.Bool THEN
                  xval^.intval := BoolToInt(IntToBool(xval^.intval) & IntToBool(yval^.intval))
                ELSE err(94)
                END
    |OPS.plus:  IF f = OPT.Int THEN
                  temp := (yval^.intval >= 0) & (xval^.intval <= MAX(SYSTEM.INT64) - yval^.intval);
                  IF temp OR (yval^.intval < 0) & (xval^.intval >= MIN(SYSTEM.INT64) - yval^.intval) THEN
                      INC(xval^.intval, yval^.intval); SetIntType(x)
                  ELSE err(206)
                  END
                ELSIF f IN OPT.realSet THEN
                  temp := (yval^.realval >= 0.0) & (xval^.realval <= MAX(LONGREAL) - yval^.realval);
                  IF temp OR (yval^.realval < 0.0) & (xval^.realval >= -MAX(LONGREAL) - yval^.realval) THEN
                      xval^.realval := xval^.realval + yval^.realval; CheckRealType(f, 206, xval)
                  ELSE err(206)
                  END
                ELSIF f = OPT.Set THEN
                  xval^.setval := xval^.setval + yval^.setval; SetSetType(x)
                ELSIF f # OPT.Undef THEN err(105)
                END
    |OPS.minus: IF f = OPT.Int THEN
                  IF (yval^.intval >= 0) & (xval^.intval >= MIN(SYSTEM.INT64) + yval^.intval) OR
                    (yval^.intval < 0) & (xval^.intval  <= MAX(SYSTEM.INT64) + yval^.intval) THEN
                      DEC(xval^.intval, yval^.intval); SetIntType(x)
                  ELSE err(207)
                  END
                ELSIF f IN OPT.realSet THEN
                  temp := (yval^.realval >= 0.0) & (xval^.realval >= -MAX(LONGREAL) + yval^.realval);
                  IF temp OR (yval^.realval < 0.0) & (xval^.realval <= MAX(LONGREAL) + yval^.realval) THEN
                      xval^.realval := xval^.realval - yval^.realval; CheckRealType(f, 207, xval)
                  ELSE err(207)
                  END
                ELSIF f = OPT.Set THEN
                  xval^.setval := xval^.setval - yval^.setval; SetSetType(x)
                ELSIF f # OPT.Undef THEN err(106)
                END
    |OPS.or:    IF f = OPT.Bool THEN
                  xval^.intval := BoolToInt(IntToBool(xval^.intval) OR IntToBool(yval^.intval))
                ELSE err(95)
                END
    |OPS.eql:   xval^.intval := BoolToInt(ConstCmp() = OPS.eql)
    |OPS.neq:   xval^.intval := BoolToInt(ConstCmp() # OPS.eql)
    |OPS.lss:   IF f IN {OPT.Bool, OPT.Set, OPT.NilTyp, OPT.Pointer} THEN err(108)
                ELSE xval^.intval := BoolToInt(ConstCmp() = OPS.lss)
                END
    |OPS.leq:   IF f IN {OPT.Bool, OPT.Set, OPT.NilTyp, OPT.Pointer} THEN err(108)
                ELSE xval^.intval := BoolToInt(ConstCmp() # OPS.gtr)
                END
    |OPS.gtr:   IF f IN {OPT.Bool, OPT.Set, OPT.NilTyp, OPT.Pointer} THEN err(108)
                ELSE xval^.intval := BoolToInt(ConstCmp() = OPS.gtr)
                END
    |OPS.geq:   IF f IN {OPT.Bool, OPT.Set, OPT.NilTyp, OPT.Pointer} THEN err(108)
                ELSE xval^.intval := BoolToInt(ConstCmp() # OPS.lss)
                END
    ELSE
       OPM.LogWStr("unhandled case in OPB.ConstOp, op = "); OPM.LogWNum(op, 0); OPM.LogWLn;
    END
  END ConstOp;

  PROCEDURE Convert(VAR x: OPT.Node; typ: OPT.Struct); (* Convert node x to new type typ *)
    VAR node: OPT.Node; f, g: INTEGER; k: SYSTEM.INT64; r: LONGREAL;
  BEGIN f := x^.typ^.form; g := typ^.form;  (* f: old form, g: new form *)
    IF x^.class = OPT.Nconst THEN
      IF (f = OPT.Set) & (g = OPT.Set) & (x.typ.size > typ.size) THEN
        SetSetType(x);
        IF x.typ.size > typ.size THEN err(203); x^.conval^.setval := {} END
      ELSIF f = OPT.Int THEN
        IF g = OPT.Int THEN
          IF x.typ.size > typ.size THEN SetIntType(x);
            IF x.typ.size > typ.size THEN err(203); x^.conval^.intval := 1 END
          END
        ELSIF g IN OPT.realSet THEN x^.conval^.realval := x^.conval^.intval; x^.conval^.intval := OPM.ConstNotAlloc
        ELSE (*g = OPT.Char*) k := x^.conval^.intval;
          IF (0 > k) OR (k > 0FFH) THEN err(220) END
        END
      ELSIF f IN OPT.realSet THEN
        IF g IN OPT.realSet THEN CheckRealType(g, 203, x^.conval)
        ELSE (* g = OPT.Int *)
          r := x^.conval^.realval;
          IF (r < MIN(SYSTEM.INT64)) OR (r > MAX(SYSTEM.INT64)) THEN err(203); r := 1 END ;
          x^.conval^.intval := ENTIER(r); SetIntType(x)
        END
      ELSE (* (f IN {OPT.Char, OPT.Byte}) & (g IN {OPT.Byte} + OPT.intSet) OR (f = OPT.Undef) *)
      END ;
      x^.obj := NIL
    ELSIF (x^.class = OPT.Nmop) & (x^.subcl = OPT.conv) & ((x^.left^.typ^.form < f) OR (f > g)) THEN
      (* don't create new node *)
      IF x^.left^.typ = typ THEN (* and suppress existing node *) x := x^.left END
    ELSE node := OPT.NewNode(OPT.Nmop); node^.subcl := OPT.conv; node^.left := x; x := node
    END ;
    x^.typ := typ
  END Convert;

  PROCEDURE Op*(op: SHORTINT; VAR x: OPT.Node; y: OPT.Node);
    VAR f, g: INTEGER; t, z: OPT.Node; typ: OPT.Struct; do: BOOLEAN; val: SYSTEM.INT64;

    PROCEDURE NewOp(op: SHORTINT; typ: OPT.Struct; VAR x: OPT.Node; y: OPT.Node);
      VAR node: OPT.Node;
    BEGIN
      node := OPT.NewNode(OPT.Ndop); node^.subcl := op; node^.typ := typ;
      node^.left := x; node^.right := y; x := node
    END NewOp;

    PROCEDURE strings(VAR x, y: OPT.Node): BOOLEAN;
      VAR ok, xCharArr, yCharArr: BOOLEAN;
    BEGIN
      xCharArr := ((x^.typ^.comp IN {OPT.Array, OPT.DynArr}) & (x^.typ^.BaseTyp^.form=OPT.Char)) OR (f=OPT.String);
      yCharArr := (((y^.typ^.comp IN {OPT.Array, OPT.DynArr}) & (y^.typ^.BaseTyp^.form=OPT.Char)) OR (g=OPT.String));
      IF xCharArr & (g = OPT.Char) & (y^.class = OPT.Nconst) THEN CharToString(y); g := OPT.String; yCharArr := TRUE END ;
      IF yCharArr & (f = OPT.Char) & (x^.class = OPT.Nconst) THEN CharToString(x); f := OPT.String; xCharArr := TRUE END ;
      ok := xCharArr & yCharArr;
      IF ok THEN  (* replace ""-string compare with 0X-char compare, if possible *)
        IF (f=OPT.String) & (x^.conval^.intval2 = 1) THEN  (* y is array of char *)
          x^.typ := OPT.chartyp; x^.conval^.intval := 0;
          Index(y, NewIntConst(0))
        ELSIF (g=OPT.String) & (y^.conval^.intval2 = 1) THEN  (* x is array of char *)
          y^.typ := OPT.chartyp; y^.conval^.intval := 0;
          Index(x, NewIntConst(0))
        END
      END ;
      RETURN ok
    END strings;


  BEGIN z := x;
    IF (z^.class = OPT.Ntype) OR (z^.class = OPT.Nproc) OR (y^.class = OPT.Ntype) OR (y^.class = OPT.Nproc) THEN err(126)
    ELSIF (z^.class = OPT.Nconst) & (y^.class = OPT.Nconst) THEN ConstOp(op, z, y); z^.obj := NIL
    ELSE
      IF z^.typ # y^.typ THEN
        g := y^.typ^.form;
        CASE z^.typ^.form OF
        |OPT.Char:    IF z^.class = OPT.Nconst THEN CharToString(z) ELSE err(100) END
        |OPT.Int:     IF (g = OPT.Int) & (y.typ.size < z.typ.size) THEN Convert(y, z.typ)
                      ELSIF g IN {OPT.Int} + OPT.realSet           THEN Convert(z, y.typ)
                      ELSE err(100)
                      END
        |OPT.Set:     IF (g = OPT.Set) & (y.typ.size < z.typ.size) THEN Convert(y, z.typ)
                      ELSIF (g = OPT.Set)                          THEN Convert(z, y.typ)
                      ELSE err(100)
                      END
        |OPT.Real:    IF g = OPT.Int THEN Convert(y, z^.typ)
                      ELSIF g IN OPT.realSet THEN Convert(z, y^.typ)
                      ELSE  err(100)
                      END
        |OPT.LReal:   IF g IN {OPT.Int} + OPT.realSet THEN Convert(y, z^.typ)
                      ELSIF g IN OPT.realSet THEN Convert(y, z^.typ)          (* DCWB: Surely this line does nothing. *)
                      ELSE  err(100)
                      END
        |OPT.NilTyp:  IF ~(g IN {OPT.Pointer, OPT.ProcTyp}) THEN err(100) END
        |OPT.Pointer: CheckPtr(z, y)
        |OPT.ProcTyp: IF g # OPT.NilTyp THEN err(100) END
        |OPT.String:
        |OPT.Comp:    IF z^.typ^.comp = OPT.Record THEN err(100) END
        ELSE err(100)
        END
      END ;  (* {z^.typ = y^.typ} *)
      typ := z^.typ; f := typ^.form; g := y^.typ^.form;
      CASE op OF
      |OPS.times: do := TRUE;
                  IF f = OPT.Int THEN
                    IF z^.class = OPT.Nconst THEN val := z^.conval^.intval;
                      IF val = 1 THEN do := FALSE; z := y
                      ELSIF val = 0 THEN do := FALSE
                      ELSIF log(val) = 1 THEN
                        t := y; y := z; z := t;
                        op := OPT.ash; y^.typ := OPT.sinttyp; y^.conval^.intval := exp; y^.obj := NIL
                      END
                    ELSIF y^.class = OPT.Nconst THEN val := y^.conval^.intval;
                      IF val = 1 THEN do := FALSE
                      ELSIF val = 0 THEN do := FALSE; z := y
                      ELSIF log(val) = 1 THEN
                        op := OPT.ash; y^.typ := OPT.sinttyp; y^.conval^.intval := exp; y^.obj := NIL
                      END
                    END
                  ELSIF ~(f IN {OPT.Undef, OPT.Real..OPT.Set}) THEN err(105); typ := OPT.undftyp
                  END ;
                  IF do THEN NewOp(op, typ, z, y) END
      |OPS.slash: IF f = OPT.Int THEN
                    IF (y^.class = OPT.Nconst) & (y^.conval^.intval = 0) THEN err(205) END ;
                    Convert(z, OPT.realtyp); Convert(y, OPT.realtyp);
                    typ := OPT.realtyp
                  ELSIF f IN OPT.realSet THEN
                    IF (y^.class = OPT.Nconst) & (y^.conval^.realval = 0.0) THEN err(205) END
                  ELSIF (f # OPT.Set) & (f # OPT.Undef) THEN err(102); typ := OPT.undftyp
                  END ;
                  NewOp(op, typ, z, y)
      |OPS.div:   do := TRUE;
                  IF f = OPT.Int THEN
                    IF y^.class = OPT.Nconst THEN val := y^.conval^.intval;
                      IF val = 0 THEN err(205)
                      ELSIF val = 1 THEN do := FALSE
                      ELSIF log(val) = 1 THEN
                        op := OPT.ash; y^.typ := OPT.sinttyp; y^.conval^.intval := -exp; y^.obj := NIL
                      END
                    END
                  ELSIF f # OPT.Undef THEN err(103); typ := OPT.undftyp
                  END ;
                  IF do THEN NewOp(op, typ, z, y) END
      |OPS.mod:   IF f = OPT.Int THEN
                    IF y^.class = OPT.Nconst THEN
                      IF y^.conval^.intval = 0 THEN err(205)
                      ELSIF log(y^.conval^.intval) = 1 THEN
                        op := OPT.msk; y^.conval^.intval := ASH(-1, exp); y^.obj := NIL
                      END
                    END
                  ELSIF f # OPT.Undef THEN err(104); typ := OPT.undftyp
                  END ;
                  NewOp(op, typ, z, y)
      |OPS.and:   IF f = OPT.Bool THEN
                    IF z^.class = OPT.Nconst THEN
                      IF IntToBool(z^.conval^.intval) THEN z := y END
                    ELSIF (y^.class = OPT.Nconst) & IntToBool(y^.conval^.intval) THEN (* optimize z & TRUE -> z *)
                  (*ELSIF (y^.class = OPT.Nconst) & ~IntToBool(y^.conval^.intval) THEN
                      don't optimize z & FALSE -> FALSE: side effects possible  *)
                    ELSE NewOp(op, typ, z, y)
                    END
                  ELSIF f # OPT.Undef THEN err(94); z^.typ := OPT.undftyp
                  END
      |OPS.plus:  IF ~(f IN {OPT.Undef, OPT.Int..OPT.Set}) THEN err(105); typ := OPT.undftyp END ;
                  do := TRUE;
                  IF f = OPT.Int THEN
                    IF (z^.class = OPT.Nconst) & (z^.conval^.intval = 0) THEN do := FALSE; z := y END ;
                    IF (y^.class = OPT.Nconst) & (y^.conval^.intval = 0) THEN do := FALSE END
                  END ;
                  IF do THEN NewOp(op, typ, z, y) END
      |OPS.minus: IF ~(f IN {OPT.Undef, OPT.Int..OPT.Set}) THEN err(106); typ := OPT.undftyp END ;
                  IF (f # OPT.Int) OR (y^.class # OPT.Nconst) OR (y^.conval^.intval # 0) THEN NewOp(op, typ, z, y) END
      |OPS.or:    IF f = OPT.Bool THEN
                    IF z^.class = OPT.Nconst THEN
                      IF ~IntToBool(z^.conval^.intval) THEN z := y END
                    ELSIF (y^.class = OPT.Nconst) & ~IntToBool(y^.conval^.intval) THEN (* optimize z OR FALSE -> z *)
                  (*ELSIF (y^.class = OPT.Nconst) & IntToBool(y^.conval^.intval) THEN
                      don't optimize z OR TRUE -> TRUE: side effects possible  *)
                    ELSE NewOp(op, typ, z, y)
                    END
                  ELSIF f # OPT.Undef THEN err(95); z^.typ := OPT.undftyp
                  END
      |OPS.eql,
       OPS.neq:   IF (f IN {OPT.Undef..OPT.Set, OPT.NilTyp, OPT.Pointer, OPT.ProcTyp}) OR strings(z, y) THEN typ := OPT.booltyp
                  ELSE err(107); typ := OPT.undftyp
                  END ;
                  NewOp(op, typ, z, y)
      |OPS.lss,
       OPS.leq,
       OPS.gtr,
       OPS.geq:   IF (f IN {OPT.Undef, OPT.Char..OPT.LReal}) OR strings(z, y) THEN typ := OPT.booltyp
                  ELSE
                    OPM.LogWLn; OPM.LogWStr("ELSE in Op()"); OPM.LogWLn;
                    err(108); typ := OPT.undftyp
                  END ;
                  NewOp(op, typ, z, y)
      ELSE OPM.LogWStr("unhandled case in OPB.Op, op = "); OPM.LogWNum(op, 0); OPM.LogWLn;
      END
    END ;
    x := z
  END Op;

  PROCEDURE SetRange*(VAR x: OPT.Node; y: OPT.Node);
    VAR k, l: SYSTEM.INT64;
  BEGIN
    IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) OR (y^.class = OPT.Ntype) OR (y^.class = OPT.Nproc) THEN err(126)
    ELSIF (x^.typ^.form = OPT.Int) & (y^.typ^.form = OPT.Int) THEN
      IF x^.class = OPT.Nconst THEN
        k := x^.conval^.intval;
        IF (0 > k) OR (k > MAX(SYSTEM.SET64)) THEN err(202) END
      END ;
      IF y^.class = OPT.Nconst THEN
        l := y^.conval^.intval;
        IF (0 > l) OR (l > MAX(SYSTEM.SET64)) THEN err(202) END
      END ;
      IF (x^.class = OPT.Nconst) & (y^.class = OPT.Nconst) THEN
        IF k <= l THEN
          x^.conval^.setval := {k..l}; SetSetType(x)
        ELSE err(201); x^.conval^.setval := {l..k}
        END ;
        x^.obj := NIL
      ELSE BindNodes(OPT.Nupto, OPT.settyp, x, y)
      END
    ELSE err(93)
    END ;
    x^.typ := OPT.settyp (* todo: syntax for specifying set type e.g. SYSTEM.SET64{n1..n2} *)
  END SetRange;

  PROCEDURE SetElem*(VAR x: OPT.Node);
    VAR k: SYSTEM.INT64;
  BEGIN
    IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
    ELSIF x^.typ^.form # OPT.Int THEN err(93)
    ELSIF x^.class = OPT.Nconst THEN
      k := x^.conval^.intval;
      IF (0 <= k) & (k <= MAX(SYSTEM.SET64)) THEN
        x^.conval^.setval := {}; INCL(x.conval.setval, k);
      ELSE err(202)
      END;
      SetSetType(x); x^.obj := NIL
    ELSE
      Convert(x, OPT.settyp);  x^.typ := OPT.settyp
    END;
  END SetElem;

  PROCEDURE CheckAssign(x: OPT.Struct; ynode: OPT.Node);  (* x := y *)
    VAR         (* x is designator (target) type *)
      y: OPT.Struct; (* expression (source) type *)
      f: INTEGER;    (* designator (target) form *)
      g: INTEGER;    (* expression (source) form *)
      p, q: OPT.Struct;
  BEGIN
    y := ynode^.typ; f := x^.form; g := y^.form;
    (*
    IF OPM.verbose IN OPM.Options THEN
       OPM.LogWLn; OPM.LogWStr("PROCEDURE CheckAssign"); OPM.LogWLn;
    END;
    IF OPM.verbose IN OPM.Options THEN
       OPM.LogWStr("y.form = "); OPM.LogWNum(y.form, 0); OPM.LogWLn;
       OPM.LogWStr("f = "); OPM.LogWNum(f, 0); OPM.LogWLn;
       OPM.LogWStr("g = "); OPM.LogWNum(g, 0); OPM.LogWLn;
       OPM.LogWStr("ynode.typ.syze = "); OPM.LogWNum(ynode.typ.size, 0); OPM.LogWLn;
    END;
    *)
    IF (ynode^.class = OPT.Ntype) OR (ynode^.class = OPT.Nproc) & (f # OPT.ProcTyp) THEN err(126) END ;
    CASE f OF
      OPT.Undef,
      OPT.String:
    | OPT.Byte:     IF ~((g IN {OPT.Byte, OPT.Char, OPT.Int}) & (y.size = 1)) THEN err(113) END
    | OPT.Bool,
      OPT.Char:     IF g # f THEN err(113) END
    | OPT.Int,
      OPT.Set:      IF (g # f) OR (x.size < y.size) THEN err(113) END
    | OPT.Real:     IF ~(g IN {OPT.Int..OPT.Real})  THEN err(113) END
    | OPT.LReal:    IF ~(g IN {OPT.Int..OPT.LReal}) THEN err(113) END
    | OPT.Pointer:  IF (x = y) OR (g = OPT.NilTyp) OR (x = OPT.sysptrtyp) & (g = OPT.Pointer) THEN (* ok *)
                    ELSIF g = OPT.Pointer THEN
                      p := x^.BaseTyp; q := y^.BaseTyp;
                      IF (p^.comp = OPT.Record) & (q^.comp = OPT.Record) THEN
                        WHILE (q # p) & (q # NIL) & (q # OPT.undftyp) DO q := q^.BaseTyp END ;
                        IF q = NIL THEN err(113) END
                      ELSE err(113)
                      END
                    ELSE err(113)
                    END
    | OPT.ProcTyp:  IF ynode^.class = OPT.Nproc THEN CheckProc(x, ynode^.obj)
                    ELSIF (x = y) OR (g = OPT.NilTyp) THEN (* ok *)
                    ELSE err(113)
                    END
    | OPT.NoTyp,
      OPT.NilTyp:   err(113)
    | OPT.Comp:     x^.pvused := TRUE;  (* idfp of y guarantees assignment compatibility with x *)
                    IF x^.comp = OPT.Array THEN
                      IF (ynode^.class = OPT.Nconst) & (g = OPT.Char) THEN CharToString(ynode); y := ynode^.typ; g := OPT.String END ;
                      IF x = y THEN (* ok *)
                      ELSIF (y.comp = OPT.Array) & (y.BaseTyp = x.BaseTyp) & (y.n <= x.n) THEN (* OK by Oberon-07/2013 *)
                      ELSIF (y.comp = OPT.DynArr) & (y.BaseTyp = x.BaseTyp) THEN (* OK by Oberon-07/2013, length tested at runtime *)
                      ELSIF x^.BaseTyp = OPT.chartyp THEN (* Assign to (static) ARRAY OF CHAR *)
                        IF g = OPT.String THEN (*check length of string*)
                          IF ynode^.conval^.intval2 > x^.n THEN err(114) END
                        ELSE err(113)
                        END
                      ELSE err(113)
                      END
                    ELSIF x^.comp = OPT.Record THEN
                      IF x = y THEN (* ok *)
                      ELSIF y^.comp = OPT.Record THEN
                        q := y^.BaseTyp;
                        WHILE (q # NIL) & (q # x) & (q # OPT.undftyp) DO q := q^.BaseTyp END ;
                        IF q = NIL THEN err(113) END
                      ELSE err(113)
                      END
                    ELSE (* Assign to dynamic array *) err(113)
                    END
    ELSE            OPM.LogWStr("unhandled case in OPB.CheckAssign, f = "); OPM.LogWNum(f, 0); OPM.LogWLn;
    END ;
    IF (ynode^.class = OPT.Nconst) & (g < f) & (g IN {OPT.Int..OPT.Real}) & (f IN {OPT.Int..OPT.LReal}) THEN
      Convert(ynode, x)
    END
  END CheckAssign;

  PROCEDURE CheckLeaf(x: OPT.Node; dynArrToo: BOOLEAN);
  BEGIN
(* avoid unnecessary intermediate variables in voc
    IF (x^.class = OPT.Nmop) & (x^.subcl = val) THEN x := x^.left END ;
    IF x^.class = OPT.Nguard THEN x := x^.left END ;  (* skip last (and unique) guard *)
    IF (x^.class = OPT.Nvar) & (dynArrToo OR (x^.typ^.comp # OPT.DynArr)) THEN x^.obj^.leaf := FALSE END
*)
  END CheckLeaf;

  PROCEDURE StPar0*(VAR par0: OPT.Node; fctno: INTEGER);  (* par0: first param of standard proc *)
    VAR f: INTEGER; typ: OPT.Struct; x: OPT.Node;
  BEGIN x := par0; f := x^.typ^.form;
    CASE fctno OF
    |OPT.haltfn:   (*HALT*)
                   IF (f = OPT.Int) & (x^.class = OPT.Nconst) THEN
                     IF (OPM.MinHaltNr <= x^.conval^.intval) & (x^.conval^.intval <= OPM.MaxHaltNr) THEN
                       BindNodes(OPT.Ntrap, OPT.notyp, x, x)
                     ELSE err(218)
                     END
                   ELSE err(69)
                   END ;
                   x^.typ := OPT.notyp
    |OPT.newfn:    (*NEW*)
                   typ := OPT.notyp;
                   IF NotVar(x) THEN err(112)
                   ELSIF f = OPT.Pointer THEN
                     IF OPM.NEWusingAdr THEN CheckLeaf(x, TRUE) END ;
                     IF x^.readonly THEN err(76) END ;
                     f := x^.typ^.BaseTyp^.comp;
                     IF f IN {OPT.Record, OPT.DynArr, OPT.Array} THEN
                       IF f = OPT.DynArr THEN typ := x^.typ^.BaseTyp END ;
                       BindNodes(OPT.Nassign, OPT.notyp, x, NIL); x^.subcl := OPT.newfn
                     ELSE err(111)
                     END
                   ELSE err(111)
                   END ;
                   x^.typ := typ
    |OPT.absfn:    (*ABS*)
                   MOp(OPT.abs, x)
    |OPT.capfn:    (*CAP*)
                   MOp(OPT.cap, x)
    |OPT.ordfn:    (*ORD*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f = OPT.Char THEN Convert(x, OPT.inttyp)
                   ELSE err(111)
                   END ;
                   x^.typ := OPT.inttyp
    |OPT.entierfn: (*ENTIER*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f IN OPT.realSet THEN Convert(x, OPT.linttyp)
                   ELSE err(111)
                   END ;
                   x^.typ := OPT.linttyp
    |OPT.floorfn:  (*FLOOR*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f IN OPT.realSet THEN Convert(x, OPT.inttyp)
                   ELSE err(111)
                   END ;
                   x^.typ := OPT.inttyp
    |OPT.oddfn:    (*ODD*)
                   MOp(OPT.odd, x)
    |OPT.minfn:    (*MIN*)
                   IF x^.class = OPT.Ntype THEN
                     CASE f OF
                       OPT.Bool:  x := NewBoolConst(FALSE)
                     | OPT.Char:  x := NewIntConst(0); x^.typ := OPT.chartyp
                     | OPT.Int:   x := NewIntConst(OPM.SignedMinimum(x.typ.size))
                     | OPT.Set:   x := NewIntConst(0); x^.typ := OPT.inttyp
                     | OPT.Real:  x := NewRealConst(OPM.MinReal, OPT.realtyp)
                     | OPT.LReal: x := NewRealConst(OPM.MinLReal, OPT.lrltyp)
                     ELSE err(111)
                     END
                   ELSE err(110)
                   END
    |OPT.maxfn:    (*MAX*)
                   IF x^.class = OPT.Ntype THEN
                     CASE f OF
                       OPT.Bool:  x := NewBoolConst(TRUE)
                     | OPT.Char:  x := NewIntConst(0FFH); x^.typ := OPT.chartyp
                     | OPT.Int:   x := NewIntConst(OPM.SignedMaximum(x.typ.size))
                     | OPT.Set:   x := NewIntConst(x.typ.size*8-1); x^.typ := OPT.inttyp
                     | OPT.Real:  x := NewRealConst(OPM.MaxReal, OPT.realtyp)
                     | OPT.LReal: x := NewRealConst(OPM.MaxLReal, OPT.lrltyp)
                     ELSE err(111)
                     END
                   ELSE err(110)
                   END
    |OPT.chrfn:    (*CHR*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f IN {OPT.Undef, OPT.Int} THEN Convert(x, OPT.chartyp)
                   ELSE err(111); x^.typ := OPT.chartyp
                   END
    |OPT.shortfn:  (*SHORT*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f = OPT.Int THEN
                     typ := OPT.ShorterOrLongerType(x.typ, -1);
                     IF typ = NIL THEN err(111) ELSE Convert(x, typ) END
                   ELSIF f = OPT.LReal THEN Convert(x, OPT.realtyp)
                   ELSE err(111)
                   END
    |OPT.longfn:   (*LONG*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f = OPT.Int THEN
                     typ := OPT.ShorterOrLongerType(x.typ, 1);
                     IF typ = NIL THEN err(111) ELSE Convert(x, typ) END
                   ELSIF f = OPT.Real THEN Convert(x, OPT.lrltyp)
                   ELSIF f = OPT.Char THEN Convert(x, OPT.linttyp)
                   ELSE err(111)
                   END
    |OPT.incfn,
     OPT.decfn:    (*INC, DEC*)
                   IF NotVar(x) THEN err(112)
                   ELSIF f # OPT.Int THEN err(111)
                   ELSIF x^.readonly THEN err(76)
                   END
    |OPT.inclfn,
     OPT.exclfn:   (*INCL, EXCL*)
                   IF NotVar(x) THEN err(112)
                   ELSIF x.typ.form # OPT.Set THEN err(111); x^.typ := OPT.settyp
                   ELSIF x^.readonly THEN err(76)
                   END
    |OPT.lenfn:    (*LEN*)
                   IF ~(x^.typ^.comp IN {OPT.DynArr, OPT.Array}) THEN err(131) END
    |OPT.copyfn:   (*COPY*)
                   IF (x^.class = OPT.Nconst) & (f = OPT.Char) THEN CharToString(x); f := OPT.String END ;
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF (~(x^.typ^.comp IN {OPT.DynArr, OPT.Array}) OR (x^.typ^.BaseTyp^.form # OPT.Char))
                      & (f # OPT.String) THEN err(111)
                   END
    |OPT.ashfn:    (*ASH*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f = OPT.Int THEN
                     IF x.typ.size < OPT.linttyp.size THEN Convert(x, OPT.linttyp) END
                   ELSE err(111); x^.typ := OPT.linttyp
                   END
    |OPT.adrfn:    (*SYSTEM.ADR*)
                   CheckLeaf(x, FALSE); MOp(OPT.adr, x)
    |OPT.sizefn:   (*SIZE*)
                   IF x^.class # OPT.Ntype THEN err(110); x := NewIntConst(1)
                   ELSIF (f IN {OPT.Byte..OPT.Set, OPT.Pointer, OPT.ProcTyp})
                      OR (x^.typ^.comp IN {OPT.Array, OPT.Record}) THEN
                     OPT.TypSize(x^.typ); x^.typ^.pvused := TRUE; x := NewIntConst(x^.typ^.size)
                   ELSE err(111); x := NewIntConst(1)
                   END
    |OPT.ccfn:     (*SYSTEM.CC*)
                   MOp(OPT.cc, x)
    |OPT.lshfn,
     OPT.rotfn:    (*SYSTEM.LSH, SYSTEM.ROT*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF ~(f IN {OPT.Int, OPT.Byte, OPT.Char, OPT.Set}) THEN err(111)
                   END
    |OPT.getfn,
     OPT.putfn,
     OPT.bitfn,
     OPT.movefn:   (*SYSTEM.GET, SYSTEM.PUT, SYSTEM.BIT, SYSTEM.MOVE*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF (x^.class = OPT.Nconst) & (f = OPT.Int) & (x.typ.size < OPT.adrtyp.size) THEN Convert(x, OPT.adrtyp)
                   ELSIF ~((x.typ.form IN {OPT.Pointer, OPT.Int}) & (x.typ.size = OPM.AddressSize)) THEN err(111); x^.typ := OPT.adrtyp
                   END
    |OPT.getrfn,
     OPT.putrfn:   (*SYSTEM.GETREG, SYSTEM.PUTREG*)
                   IF (f = OPT.Int) & (x^.class = OPT.Nconst) THEN
                     IF (x^.conval^.intval < OPM.MinRegNr) OR (x^.conval^.intval > OPM.MaxRegNr) THEN err(220) END
                   ELSE err(69)
                   END
    |OPT.valfn:    (*SYSTEM.VAL*)
                   IF x^.class # OPT.Ntype THEN err(110)
                   ELSIF (f IN {OPT.Undef, OPT.String, OPT.NoTyp}) OR (x^.typ^.comp = OPT.DynArr) THEN err(111)
                   END
    |OPT.sysnewfn: (*SYSTEM.NEW*)
                   IF NotVar(x) THEN err(112)
                   ELSIF f = OPT.Pointer THEN
                     IF OPM.NEWusingAdr THEN CheckLeaf(x, TRUE) END
                   ELSE err(111)
                   END
    |OPT.assertfn: (*ASSERT*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126); x := NewBoolConst(FALSE)
                   ELSIF f # OPT.Bool THEN err(120); x := NewBoolConst(FALSE)
                   ELSE MOp(OPS.not, x)
                   END
    ELSE OPM.LogWStr("unhandled case in OPB.StPar0, fctno = "); OPM.LogWNum(fctno, 0); OPM.LogWLn;
    END ;
    par0 := x
  END StPar0;

  PROCEDURE StPar1*(VAR par0: OPT.Node; x: OPT.Node; fctno: SHORTINT);  (* x: second parameter of standard proc *)
    VAR f, L: INTEGER; typ: OPT.Struct; p, t: OPT.Node;

    PROCEDURE NewOp(class, subcl: SHORTINT; left, right: OPT.Node): OPT.Node;
      VAR node: OPT.Node;
    BEGIN
      node := OPT.NewNode(class); node^.subcl := subcl;
      node^.left := left; node^.right := right; RETURN node
    END NewOp;

  BEGIN p := par0; f := x^.typ^.form;
    CASE fctno OF
    |OPT.incfn,
     OPT.decfn:    (*INC DEC*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126); p^.typ := OPT.notyp
                   ELSE
                     IF x^.typ # p^.typ THEN
                       IF (f = OPT.Int)
                        & (   (x^.class = OPT.Nconst)
                           OR (p.typ.form = OPT.Int) & (x.typ.size <= p.typ.size)) THEN Convert(x, p^.typ)
                       ELSE err(111)
                       END
                     END ;
                     p := NewOp(OPT.Nassign, fctno, p, x);
                     p^.typ := OPT.notyp
                   END
    |OPT.inclfn,
     OPT.exclfn:   (*INCL, EXCL*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f = OPT.Int THEN
                     IF (x^.class = OPT.Nconst) & ((0 > x^.conval^.intval) OR (x^.conval^.intval >= p.typ.size*8)) THEN err(202)
                     END;
                     p := NewOp(OPT.Nassign, fctno, p, x)
                   ELSE err(111)
                   END ;
                   p^.typ := OPT.notyp
    |OPT.lenfn:    (*LEN*)
                   IF ~(f = OPT.Int) OR (x^.class # OPT.Nconst) THEN err(69)
                   ELSIF x.typ.size = 1 THEN (* Hard limit of 127 dimensions *)
                     L := OPM.Integer(x^.conval^.intval); typ := p^.typ;
                     WHILE (L > 0) & (typ^.comp IN {OPT.DynArr, OPT.Array}) DO typ := typ^.BaseTyp; DEC(L) END ;
                     IF (L # 0) OR ~(typ^.comp IN {OPT.DynArr, OPT.Array}) THEN err(132)
                     ELSE x^.obj := NIL;
                       IF typ^.comp = OPT.DynArr THEN
                         WHILE p^.class = OPT.Nindex DO p := p^.left; INC(x^.conval^.intval) END ;  (* possible side effect ignored *)
                         p := NewOp(OPT.Ndop, OPT.len, p, x); p^.typ := OPT.linttyp
                       ELSE p := x; p^.conval^.intval := typ^.n; SetIntType(p)
                       END
                     END
                   ELSE err(132)
                   END
    |OPT.copyfn:   (*COPY*)
                   IF NotVar(x) THEN err(112)
                   ELSIF (x^.typ^.comp IN {OPT.Array, OPT.DynArr}) & (x^.typ^.BaseTyp^.form = OPT.Char) THEN
                     IF x^.readonly THEN err(76) END ;
                     t := x; x := p; p := t; p := NewOp(OPT.Nassign, OPT.copyfn, p, x)
                   ELSE err(111)
                   END ;
                   p^.typ := OPT.notyp
    |OPT.ashfn:    (*ASH*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f = OPT.Int THEN
                     IF (p^.class = OPT.Nconst) & (x^.class = OPT.Nconst) THEN
                       IF (-maxExp > x^.conval^.intval) OR (x^.conval^.intval > maxExp) THEN err(208); p^.conval^.intval := 1
                       ELSIF x^.conval^.intval >= 0 THEN
                         IF ABS(p^.conval^.intval) <= MAX(SYSTEM.INT64) DIV ASH(1, x^.conval^.intval) THEN
                           p^.conval^.intval := p^.conval^.intval * ASH(1, x^.conval^.intval)
                         ELSE err(208); p^.conval^.intval := 1
                         END
                       ELSE p^.conval^.intval := ASH(p^.conval^.intval, x^.conval^.intval)
                       END ;
                       p^.obj := NIL
                     ELSE p := NewOp(OPT.Ndop, OPT.ash, p, x); p^.typ := p.left.typ (* LONGINT, or INT64 if larger *)
                     END
                   ELSE err(111)
                   END
    |OPT.newfn:    (*NEW(p, x...)*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF p^.typ^.comp = OPT.DynArr THEN
                     IF f = OPT.Int THEN
                       IF (x^.class = OPT.Nconst) & ((x^.conval^.intval <= 0) OR (x^.conval^.intval > OPM.MaxIndex)) THEN err(63) END
                     ELSE err(111)
                     END ;
                     p^.right := x; p^.typ := p^.typ^.BaseTyp
                   ELSE err(64)
                   END
    |OPT.lshfn,
     OPT.rotfn:    (*SYSTEM.LSH, SYSTEM.ROT*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f # OPT.Int THEN err(111)
                   ELSE
                     IF fctno = OPT.lshfn THEN p := NewOp(OPT.Ndop, OPT.lsh, p, x) ELSE p := NewOp(OPT.Ndop, OPT.rot, p, x) END ;
                     p^.typ := p^.left^.typ
                   END
    |OPT.getfn,
     OPT.putfn,
     OPT.getrfn,
     OPT.putrfn:   (*SYSTEM.GET, SYSTEM.PUT, SYSTEM.GETREG, SYSTEM.PUTREG*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f IN {OPT.Undef..OPT.Set, OPT.Pointer, OPT.ProcTyp} THEN
                     IF (fctno = OPT.getfn) OR (fctno = OPT.getrfn) THEN
                       IF NotVar(x) THEN err(112) END ;
                       t := x; x := p; p := t
                     END ;
                     p := NewOp(OPT.Nassign, fctno, p, x)
                   ELSE err(111)
                   END ;
                   p^.typ := OPT.notyp
    |OPT.bitfn:    (*SYSTEM.BIT*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f = OPT.Int THEN
                     p := NewOp(OPT.Ndop, OPT.bit, p, x)
                   ELSE err(111)
                   END ;
                   p^.typ := OPT.booltyp
    |OPT.valfn:    (*SYSTEM.VAL*)  (* type is changed without considering the byte ordering on the target machine *)
                   (* p (1st param): desired type *)
                   (* x (2nd param): constant or value to be converted to p *)
                   IF (x^.class = OPT.Ntype)
                   OR (x^.class = OPT.Nproc)
                   OR (f IN {OPT.Undef, OPT.String, OPT.NoTyp})
                   OR (x^.typ^.comp = OPT.DynArr) THEN
                     err(126)
                   END;
                   (* Warn if the result type includes memory past the end of the source variable *)
                   OPT.TypSize(x.typ); OPT.TypSize(p.typ);
                   IF (x.class # OPT.Nconst) & (x.typ.size < p.typ.size) THEN err(-308) END;

                   IF (x.class = OPT.Nconst) & (x.typ.form = OPT.Int) & (p.typ.form = OPT.Int) THEN
                     (* Convert integer constants in place allowing usage in CONST section. *)
                     Convert(x, p.typ)
                   ELSE
                     t := OPT.NewNode(OPT.Nmop); t^.subcl := OPT.val; t^.left := x; x := t;
                     (*
                     IF (x^.class >= OPT.Nconst) OR ((f IN OPT.realSet) # (p^.typ^.form IN OPT.realSet)) THEN
                       t := OPT.NewNode(OPT.Nmop); t^.subcl := val; t^.left := x; x := t
                     ELSE x^.readonly := FALSE
                     END ;
                     *)
                     x^.typ := p^.typ;
                   END;
                   p := x
    |OPT.sysnewfn: (*SYSTEM.NEW*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF f = OPT.Int THEN
                     p := NewOp(OPT.Nassign, OPT.sysnewfn, p, x)
                   ELSE err(111)
                   END ;
                   p^.typ := OPT.notyp
    |OPT.movefn:   (*SYSTEM.MOVE*)
                   IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
                   ELSIF (x^.class = OPT.Nconst) & (f = OPT.Int) & (x.typ.size < OPT.adrtyp.size) THEN Convert(x, OPT.adrtyp)
                   ELSIF ~((x.typ.form IN {OPT.Pointer, OPT.Int}) & (x.typ.size = OPM.AddressSize)) THEN err(111); x^.typ := OPT.adrtyp
                   END;
                   p^.link := x
    |OPT.assertfn: (*ASSERT*)
                   IF (f = OPT.Int) & (x^.class = OPT.Nconst) THEN
                     IF (OPM.MinHaltNr <= x^.conval^.intval) & (x^.conval^.intval <= OPM.MaxHaltNr) THEN
                       BindNodes(OPT.Ntrap, OPT.notyp, x, x);
                       x^.conval := OPT.NewConst(); x^.conval^.intval := OPM.errpos;
                       Construct(OPT.Nif, p, x); p^.conval := OPT.NewConst(); p^.conval^.intval := OPM.errpos;
                       Construct(OPT.Nifelse, p, NIL); OptIf(p);
                       IF p = NIL THEN  (* ASSERT(TRUE) *)
                       ELSIF p^.class = OPT.Ntrap THEN err(99)
                       ELSE p^.subcl := OPT.assertfn
                       END
                     ELSE err(218)
                     END
                   ELSE err(69)
                   END
    ELSE err(64)
    END ;
    par0 := p
  END StPar1;

  PROCEDURE StParN*(VAR par0: OPT.Node; x: OPT.Node; fctno, n: INTEGER);  (* x: n+1-th param of standard proc *)
    VAR node: OPT.Node; f: INTEGER; p: OPT.Node;
  BEGIN p := par0; f := x^.typ^.form;
    IF fctno = OPT.newfn THEN (*NEW(p, ..., x...*)
      IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
      ELSIF p^.typ^.comp # OPT.DynArr THEN err(64)
      ELSIF f = OPT.Int THEN
        IF (x^.class = OPT.Nconst) & ((x^.conval^.intval <= 0) OR (x^.conval^.intval > OPM.MaxIndex)) THEN err(63) END ;
        node := p^.right; WHILE node^.link # NIL DO node := node^.link END;
        node^.link := x; p^.typ := p^.typ^.BaseTyp
      ELSE err(111)
      END
    ELSIF (fctno = OPT.movefn) & (n = 2) THEN (*SYSTEM.MOVE*)
      IF (x^.class = OPT.Ntype) OR (x^.class = OPT.Nproc) THEN err(126)
      ELSIF f = OPT.Int THEN
        node := OPT.NewNode(OPT.Nassign); node^.subcl := OPT.movefn; node^.right := p;
        node^.left := p^.link; p^.link := x; p := node
      ELSE err(111)
      END ;
      p^.typ := OPT.notyp
    ELSE err(64)
    END ;
    par0 := p
  END StParN;

  PROCEDURE StFct*(VAR par0: OPT.Node; fctno: SHORTINT; parno: INTEGER);
    VAR dim: INTEGER; x, p: OPT.Node;
  BEGIN p := par0;
    IF fctno <= OPT.ashfn THEN
      IF (fctno = OPT.newfn) & (p^.typ # OPT.notyp) THEN
        IF p^.typ^.comp = OPT.DynArr THEN err(65) END ;
        p^.typ := OPT.notyp
      ELSIF fctno <= OPT.sizefn THEN (* 1 param *)
        IF parno < 1 THEN err(65) END
      ELSE (* more than 1 param *)
        IF ((fctno = OPT.incfn) OR (fctno = OPT.decfn)) & (parno = 1) THEN (*INC, DEC*)
          BindNodes(OPT.Nassign, OPT.notyp, p, NewIntConst(1)); p^.subcl := fctno; p^.right^.typ := p^.left^.typ
        ELSIF (fctno = OPT.lenfn) & (parno = 1) THEN (*LEN*)
          IF p^.typ^.comp = OPT.DynArr THEN dim := 0;
            WHILE p^.class = OPT.Nindex DO p := p^.left; INC(dim) END ;  (* possible side effect ignored *)
            BindNodes(OPT.Ndop, OPT.linttyp, p, NewIntConst(dim)); p^.subcl := OPT.len
          ELSE
            p := NewIntConst(p^.typ^.n)
          END
        ELSIF parno < 2 THEN err(65)
        END
      END
    ELSIF fctno = OPT.assertfn THEN
      IF parno = 1 THEN x := NIL;
        BindNodes(OPT.Ntrap, OPT.notyp, x, NewIntConst(AssertTrap));
        x^.conval := OPT.NewConst(); x^.conval^.intval := OPM.errpos;
        Construct(OPT.Nif, p, x); p^.conval := OPT.NewConst(); p^.conval^.intval := OPM.errpos;
        Construct(OPT.Nifelse, p, NIL); OptIf(p);
        IF p = NIL THEN  (* ASSERT(TRUE) *)
        ELSIF p^.class = OPT.Ntrap THEN err(99)
        ELSE p^.subcl := OPT.assertfn
        END
      ELSIF parno < 1 THEN err(65)
      END
    ELSE (*SYSTEM*)
      IF (parno < 1) OR
        (fctno > OPT.ccfn) & (parno < 2) OR
        (fctno = OPT.movefn) & (parno < 3) THEN err(65)
      END
    END ;
    par0 := p
  END StFct;

  PROCEDURE DynArrParCheck(ftyp, atyp: OPT.Struct; fvarpar: BOOLEAN);
    VAR f: INTEGER;
  BEGIN (* ftyp^.comp = OPT.DynArr *)
    f := atyp^.comp; ftyp := ftyp^.BaseTyp; atyp := atyp^.BaseTyp;
    IF fvarpar & (ftyp = OPT.bytetyp) THEN (* ok, but ... *)
      IF ~(f IN {OPT.Array, OPT.DynArr}) OR ~((atyp.form IN {OPT.Byte..OPT.Char, OPT.Int}) & (atyp.size = 1)) THEN
        IF OPM.verbose IN OPM.Options THEN err(-301) END
      END
    ELSIF f IN {OPT.Array, OPT.DynArr} THEN
      IF ftyp^.comp = OPT.DynArr THEN DynArrParCheck(ftyp, atyp, fvarpar)
      ELSIF ftyp # atyp THEN
        IF ~fvarpar & (ftyp.form = OPT.Pointer) & (atyp.form = OPT.Pointer) THEN
          ftyp := ftyp^.BaseTyp; atyp := atyp^.BaseTyp;
          IF (ftyp^.comp = OPT.Record) & (atyp^.comp = OPT.Record) THEN
            WHILE (ftyp # atyp) & (atyp # NIL) & (atyp # OPT.undftyp) DO atyp := atyp^.BaseTyp END ;
            IF atyp = NIL THEN err(113) END
          ELSE err(66)
          END
        ELSE err(66)
        END
      END ;
    ELSE err(67)
    END
  END DynArrParCheck;

  PROCEDURE CheckReceiver(VAR x: OPT.Node; fp: OPT.Object);
  BEGIN
    IF fp^.typ^.form = OPT.Pointer THEN
      IF x^.class = OPT.Nderef THEN x := x^.left (*undo DeRef*) ELSE (*x^.typ^.comp = OPT.Record*) err(71) END
    END
  END CheckReceiver;

  PROCEDURE PrepCall*(VAR x: OPT.Node; VAR fpar: OPT.Object);
  BEGIN
    IF (x^.obj # NIL) & (x^.obj^.mode IN {OPT.LProc, OPT.XProc, OPT.TProc, OPT.CProc}) THEN
      fpar := x^.obj^.link;
      IF x^.obj^.mode = OPT.TProc THEN CheckReceiver(x^.left, fpar); fpar := fpar^.link END
    ELSIF (x^.class # OPT.Ntype) & (x^.typ # NIL) & (x^.typ^.form = OPT.ProcTyp) THEN
      fpar := x^.typ^.link
    ELSE err(121); fpar := NIL; x^.typ := OPT.undftyp
    END
  END PrepCall;

  PROCEDURE Param*(ap: OPT.Node; fp: OPT.Object);
    VAR q: OPT.Struct;
  BEGIN
    IF fp.typ.form # OPT.Undef THEN
      IF fp^.mode = OPT.VarPar THEN
        IF NotVar(ap) THEN err(122)
        ELSE CheckLeaf(ap, FALSE)
        END ;
        IF ap^.readonly THEN err(76) END ;
        IF fp^.typ^.comp = OPT.DynArr THEN DynArrParCheck(fp^.typ, ap^.typ, TRUE)
        ELSIF (fp^.typ^.comp = OPT.Record) & (ap^.typ^.comp = OPT.Record) THEN
          q := ap^.typ;
          WHILE (q # fp^.typ) & (q # NIL) & (q # OPT.undftyp) DO q := q^.BaseTyp END ;
          IF q = NIL THEN err(111) END
        ELSIF (fp^.typ = OPT.sysptrtyp) & (ap^.typ^.form = OPT.Pointer) THEN (* ok *)
        ELSIF (ap^.typ # fp^.typ)
            & ~(  (fp^.typ^.form = OPT.Byte)
                & (ap.typ.form IN {OPT.Byte..OPT.Char, OPT.Int})
                & (ap.typ.size = 1)) THEN err(123)
        ELSIF (fp^.typ^.form = OPT.Pointer) & (ap^.class = OPT.Nguard) THEN err(123)
        END
      ELSIF fp^.typ^.comp = OPT.DynArr THEN
        IF (ap^.class = OPT.Nconst) & (ap^.typ^.form = OPT.Char) THEN CharToString(ap) END ;
        IF (ap^.typ^.form = OPT.String) & (fp^.typ^.BaseTyp^.form = OPT.Char) THEN (* ok *)
        ELSIF ap^.class >= OPT.Nconst THEN err(59)
        ELSE DynArrParCheck(fp^.typ, ap^.typ, FALSE)
        END
      ELSE CheckAssign(fp^.typ, ap)
      END
    END
  END Param;

  PROCEDURE StaticLink*(dlev: SHORTINT);
    VAR scope: OPT.Object;
  BEGIN
    scope := OPT.topScope;
    WHILE dlev > 0 DO DEC(dlev);
      INCL(scope^.link^.conval^.setval, OPT.slNeeded);
      scope := scope^.left
    END
  END StaticLink;

  PROCEDURE Call*(VAR x: OPT.Node; apar: OPT.Node; fp: OPT.Object);
    VAR typ: OPT.Struct; p: OPT.Node; lev: SHORTINT;
  BEGIN
    IF x^.class = OPT.Nproc THEN typ := x^.typ;
      lev := x^.obj^.mnolev;
      IF lev > 0 THEN StaticLink(OPT.topScope^.mnolev-lev) END ;
      IF x^.obj^.mode = OPT.IProc THEN err(121) END
    ELSIF (x^.class = OPT.Nfield) & (x^.obj^.mode = OPT.TProc) THEN typ := x^.typ;
      x^.class := OPT.Nproc; p := x^.left; x^.left := NIL; p^.link := apar; apar := p; fp := x^.obj^.link
    ELSE typ := x^.typ^.BaseTyp
    END ;
    BindNodes(OPT.Ncall, typ, x, apar); x^.obj := fp
  END Call;

  PROCEDURE Enter*(VAR procdec: OPT.Node; stat: OPT.Node; proc: OPT.Object);
    VAR x: OPT.Node;
  BEGIN
    x := OPT.NewNode(OPT.Nenter); x^.typ := OPT.notyp; x^.obj := proc;
    x^.left := procdec; x^.right := stat; procdec := x
  END Enter;

  PROCEDURE Return*(VAR x: OPT.Node; proc: OPT.Object);
    VAR node: OPT.Node;
  BEGIN
    IF proc = NIL THEN (* return from module *)
      IF x # NIL THEN err(124) END
    ELSE
      IF x # NIL THEN CheckAssign(proc^.typ, x)
      ELSIF proc^.typ # OPT.notyp THEN err(124)
      END
    END ;
    node := OPT.NewNode(OPT.Nreturn); node^.typ := OPT.notyp; node^.obj := proc; node^.left := x; x := node
  END Return;

  PROCEDURE Assign*(VAR x: OPT.Node; y: OPT.Node);
    VAR z: OPT.Node;
  BEGIN
    IF x^.class >= OPT.Nconst THEN err(56) END ;
    CheckAssign(x^.typ, y);
    IF x^.readonly THEN err(76) END ;
    IF x^.typ^.comp = OPT.Record THEN
      IF x^.class = OPT.Nguard THEN z := x^.left ELSE z := x END ;
      IF (z^.class = OPT.Nderef) & (z^.left^.class = OPT.Nguard) THEN
        z^.left := z^.left^.left  (* skip guard before dereferencing *)
      END ;
      IF (x^.typ^.strobj # NIL) & ((z^.class = OPT.Nderef) OR (z^.class = OPT.Nvarpar)) THEN
        BindNodes(OPT.Neguard, x^.typ, z, NIL); x := z
      END
    ELSIF (x^.typ^.comp = OPT.Array) & (x^.typ^.BaseTyp = OPT.chartyp) &
        (y^.typ^.form = OPT.String) & (y^.conval^.intval2 = 1) THEN  (* replace array := "" with array[0] := 0X *)
      y^.typ := OPT.chartyp; y^.conval^.intval := 0;
      Index(x, NewIntConst(0))
    END;
    BindNodes(OPT.Nassign, OPT.notyp, x, y);
    x^.subcl := OPT.assign;
  END Assign;

  PROCEDURE Inittd*(VAR inittd, last: OPT.Node; typ: OPT.Struct);
    VAR node: OPT.Node;
  BEGIN
    node := OPT.NewNode(OPT.Ninittd); node^.typ := typ;
    node^.conval := OPT.NewConst(); node^.conval^.intval := typ^.txtpos;
    IF inittd = NIL THEN inittd := node ELSE last^.link := node END ;
    last := node
  END Inittd;

BEGIN
  maxExp := log(MAX(SYSTEM.INT64) DIV 2 + 1); maxExp := exp
END OPB.
