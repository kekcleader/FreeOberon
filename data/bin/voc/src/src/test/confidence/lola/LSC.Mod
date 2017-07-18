MODULE LSC;  (*Lola System Compiler, NW 8.1.95 / 26.9.2015 for RISC (LSCX)*)
  IMPORT Texts, Oberon, LSB, LSS;

  VAR sym: INTEGER;
    err: BOOLEAN;  (*used at end of Unit*)
    top, bot, undef: LSB.Object;
    factor: PROCEDURE (VAR x: LSB.Item);  (*to avoid forward references*)
    expression: PROCEDURE (VAR x: LSB.Item);
    Unit: PROCEDURE (VAR locals: LSB.Object);
    W: Texts.Writer;

  PROCEDURE Err(n: INTEGER);
  BEGIN LSS.Mark("type error"); Texts.WriteInt(W, n, 4);
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END Err;

  PROCEDURE Log(m: LONGINT): LONGINT;
    VAR n: LONGINT;
  BEGIN n := 1;
    WHILE m > 1 DO m := m DIV 2; INC(n) END ;
    RETURN n
  END Log;

  PROCEDURE New(tag: INTEGER; a, b: LSB.Item): LSB.Item;
    VAR z: LSB.Item;
  BEGIN NEW(z); z.tag := tag; z.a := a; z.b := b; z.val := b.val; RETURN z
  END New;

  PROCEDURE NewObj(class: INTEGER): LSB.Object; (*insert at end, before BIT*)
    VAR new, x: LSB.Object;
  BEGIN x := top;
    WHILE (x.next # bot) & (x.next.name # LSS.id) DO x := x.next END ;
    IF x.next = bot THEN
      NEW(new); new.name := LSS.id; new.tag := class; new.next := bot; x.next := new
    ELSE LSS.Mark("mult def"); new := x
    END ;
    RETURN new
  END NewObj;

  PROCEDURE ThisObj(id: LSS.Ident): LSB.Object;  (*find object with name = identifier last read*)
    VAR x: LSB.Object;
  BEGIN x := top.next;
    WHILE (x # NIL) & (x.name # id) DO x := x.next END ;
    IF x = NIL THEN LSS.Mark("undef"); x := undef END ;
    RETURN x
  END ThisObj;

  PROCEDURE CheckTypes(x, y, z: LSB.Item);  (*z.type = result type*)
    VAR xtyp, ytyp: LSB.Type;
  BEGIN xtyp := x.type; ytyp := y.type; z.type := xtyp; z.size := x.size; z.val := x.val;
    IF xtyp = LSB.bitType THEN z.type := xtyp;
      IF ytyp = LSB.integer THEN  (* b + 0 *)
        IF y.val >= 2 THEN Err(20); LSS.Mark("only 0 or 1") END
      ELSIF ytyp = LSB.string THEN (* b + {...} *) Err(21)
      ELSIF ytyp # LSB.bitType THEN Err(22)
      END
    ELSIF xtyp IS LSB.ArrayType THEN
      IF xtyp(LSB.ArrayType).eltyp = LSB.bitType THEN
        IF (ytyp IS LSB.ArrayType) & (xtyp(LSB.ArrayType).eltyp = LSB.bitType) THEN
          IF xtyp.size # ytyp.size THEN Err(33) END  (* x + y *)
        ELSIF ytyp = LSB.integer THEN   (* w + 5 *)
          IF xtyp.size < Log(y.val) THEN Err(30) END
        ELSIF ytyp = LSB.string THEN   (*x + {...} *)
          IF xtyp.size # y.size THEN Err(31) END
        ELSIF ytyp # LSB.bitType THEN Err(34)
        END
      ELSIF (ytyp IS LSB.ArrayType) & (xtyp(LSB.ArrayType).eltyp = ytyp(LSB.ArrayType).eltyp) THEN
        IF (xtyp.size # ytyp.size) THEN Err(40) END
      ELSE Err(41)
      END
    ELSIF xtyp = LSB.string THEN
      IF ytyp = LSB.bitType THEN  (* {...} + b *) Err(12)
      ELSIF (ytyp IS LSB.ArrayType) & (ytyp(LSB.ArrayType).eltyp = LSB.bitType) THEN  (* {...} + w *)
        IF x.size # ytyp.size THEN Err(13) END
      ELSIF ytyp = LSB.integer THEN  (* {...} + 5*)
        IF x.size < Log(y.val) THEN Err(10) END
      ELSIF ytyp = LSB.string THEN  (* {...} + {...} *)
        IF x.size # y.size THEN Err(11) END ;
      ELSE Err(14)
      END
    ELSIF xtyp = LSB.integer THEN
      IF (ytyp IS LSB.ArrayType) & (ytyp(LSB.ArrayType).eltyp = LSB.bitType) THEN  (* 5 + w *)
        IF Log(x.val) > ytyp.size THEN Err(3); LSS.Mark("const too large") END
      ELSIF ytyp = LSB.bitType THEN (* 5 + b *)
        IF x.val >= 2 THEN Err(2) END
      ELSIF ytyp = LSB.integer THEN  (* 5 + 5 *)
      ELSIF ytyp = LSB.string THEN  (* 5 + {...} *)
        IF Log(x.val) > y.size THEN Err(12) END
      ELSE Err(4)
      END
    END
  END CheckTypes;

  PROCEDURE selector(VAR x: LSB.Item);
    VAR y, z: LSB.Item; obj: LSB.Object;
      eltyp: LSB.Type; len, kind: LONGINT;
  BEGIN
    WHILE (sym = LSS.lbrak) OR (sym = LSS.period) DO
      IF sym = LSS.lbrak THEN
        eltyp := x.type(LSB.ArrayType).eltyp; LSS.Get(sym); expression(y);
        IF sym = LSS.colon THEN (*range*)
          LSS.Get(sym); expression(z);
          IF (y.tag = LSB.lit) & (z.tag = LSB.lit) THEN
            len := y.val - z.val + 1; y := New(LSB.range, y, z); x := New(LSB.sel, x, y); x.type := LSB.string; x.size := len
          END
        ELSE kind := x.val; x := New(LSB.sel, x, y); x.type := eltyp; x.val := kind
        END ;
        IF sym = LSS.rbrak THEN LSS.Get(sym) ELSE LSS.Mark("rbrak ?") END
      ELSE (*sym = LSS.period*) LSS.Get(sym); factor(y);
        IF (y.tag = LSB.lit) & (y.val >= x.type.len) THEN LSS.Mark("too large") END ;
        eltyp := x.type(LSB.ArrayType).eltyp; kind := x.val; x := New(LSB.sel, x, y); x.type := eltyp; x.val := kind
      END
    END
  END selector;

  PROCEDURE elem(VAR x: LSB.Item; VAR len: LONGINT);
    VAR y, z: LSB.Item; m, n: LONGINT;
  BEGIN expression(x);
    IF (x.type = LSB.integer) OR (x.type = LSB.string) THEN m := x.size ELSE m := x.type.size END ;
    IF sym = LSS.repl THEN
      LSS.Get(sym);
      IF sym = LSS.integer THEN
        NEW(y); y.tag := LSB.lit; n := LSS.val; y.val := n; y.type := LSB.integer; LSS.Get(sym);
        x := New(LSB.repl, x, y)
      END
    ELSE n := 1
    END ;
    len := m*n
  END elem;

  PROCEDURE constructor(VAR x: LSB.Item);
    VAR y: LSB.Item; n, len: LONGINT;
  BEGIN elem(x, len);
    WHILE sym = LSS.comma DO
      LSS.Get(sym); elem(y, n); INC(len, n); x := New(LSB.cons, x, y); x.val := len
    END ;
    x.size := len; x.type := LSB.string;
    IF sym = LSS.rbrace THEN LSS.Get(sym) ELSE LSS.Mark("rbrace ?") END
  END constructor;

  PROCEDURE factor0(VAR x: LSB.Item);
    VAR obj: LSB.Object; y, z: LSB.Item;
      n, len: LONGINT; t: LSB.ArrayType;
  BEGIN
    IF sym = LSS.ident THEN
      x := ThisObj(LSS.id); LSS.Get(sym);
      IF x.tag = LSB.var THEN selector(x)
      ELSIF x.tag = LSB.const THEN n := x.b.val; NEW(x); x.tag := LSB.lit; x.val := n; x.type := LSB.integer
      ELSE LSS.Mark("bad factor")
      END
    ELSIF sym = LSS.lparen THEN
      LSS.Get(sym); expression(x);
      IF sym = LSS.rparen THEN LSS.Get(sym) ELSE LSS.Mark("rparen ?") END
    ELSIF sym = LSS.integer THEN
      NEW(x); x.tag := LSB.lit; x.val := LSS.val; x.type := LSB.integer; LSS.Get(sym);
      IF sym = LSS.apo THEN LSS.Get(sym);
        IF sym = LSS.integer THEN
          len := LSS.val; LSS.Get(sym);
          IF len < Log(x.val) THEN LSS.Mark("value too large") END
        ELSE LSS.Mark("integer ?"); len := 0
        END ;
        x.size := len
      ELSE len := 0
      END ;
      x.size := len
    ELSIF sym = LSS.not THEN
      LSS.Get(sym); factor(x); y := New(LSB.not, NIL, x); y.type := x.type; y.size := x.size; x := y
    ELSIF sym = LSS.lbrace THEN LSS.Get(sym); constructor(x)
    ELSE LSS.Mark("bad factor")
    END
  END factor0;

  PROCEDURE term(VAR x: LSB.Item);
    VAR y, z: LSB.Item; op: INTEGER;
  BEGIN factor(x);
    WHILE (sym >= LSS.times) & (sym <= LSS.and) DO
      IF sym = LSS.and THEN op := LSB.and
      ELSIF sym = LSS.times THEN op := LSB.mul
      ELSIF sym = LSS.div THEN op := LSB.div
      END ;
      LSS.Get(sym); factor(y); z := New(op, x, y); CheckTypes(x, y, z); x := z
    END
  END term;

  PROCEDURE SimpleExpression(VAR x: LSB.Item);
    VAR y, z: LSB.Item; op: INTEGER;
  BEGIN
    IF sym = LSS.minus THEN LSS.Get(sym); term(y);
      IF y.tag = LSB.lit THEN x := y; x.val := -y.val
      ELSE x := New(LSB.sub, NIL, y); x.type := y.type; x.size := y.size
      END
    ELSIF sym = LSS.plus THEN LSS.Get(sym); term(x);
    ELSE term(x)
    END ;
    WHILE (sym >= LSS.plus) & (sym <= LSS.xor) DO
      IF sym = LSS.or THEN op := LSB.or
      ELSIF sym = LSS.xor THEN op := LSB.xor
      ELSIF sym = LSS.plus THEN op := LSB.add
      ELSIF sym = LSS.minus THEN op := LSB.sub
      END ;
      LSS.Get(sym); term(y); z := New(op, x, y); CheckTypes(x, y, z); x := z
    END
  END SimpleExpression;

  PROCEDURE UncondExpression(VAR x: LSB.Item);
    VAR y, z: LSB.Item; rel: INTEGER;
  BEGIN SimpleExpression(x);
    IF (sym >= LSS.eql) & (sym <= LSS.geq) THEN
      IF sym = LSS.eql THEN rel := LSB.eql
      ELSIF sym = LSS.neq THEN rel := LSB.neq
      ELSIF sym = LSS.lss THEN rel := LSB.lss
      ELSIF sym = LSS.geq THEN rel := LSB.geq
      ELSIF sym = LSS.leq THEN rel := LSB.leq
      ELSE rel := LSB.gtr
      END ;
      LSS.Get(sym); SimpleExpression(y); z := New(rel, x, y); CheckTypes(x, y, z); z.type := LSB.bitType; x := z
    END
  END UncondExpression;

  PROCEDURE expression0(VAR x: LSB.Item);
    VAR y, z, w: LSB.Item;
  BEGIN UncondExpression(x);
    IF sym = LSS.then THEN
      IF x.type # LSB.bitType THEN LSS.Mark("Boolean?") END ;
      LSS.Get(sym); expression(y);
      IF sym = LSS.colon THEN
        LSS.Get(sym); expression(z); w := New(LSB.else, y, z); CheckTypes(y, z, w);
        x := New(LSB.then, x, w); x.type := w.type; x.size := w.size
      ELSE LSS.Mark("colon ?")
      END
    END
  END expression0;

  PROCEDURE CheckAssign(x, y: LSB.Item);
    VAR xtyp, ytyp: LSB.Type;
  BEGIN xtyp := x.type; ytyp := y.type;
    IF xtyp # ytyp THEN
      IF xtyp = LSB.bitType THEN
        IF (ytyp # LSB.integer) OR (y.val >= 2) THEN Err(70); END
      ELSIF xtyp IS LSB.ArrayType THEN
        IF xtyp(LSB.ArrayType).eltyp = LSB.bitType THEN
          IF (ytyp IS LSB.ArrayType) & (xtyp(LSB.ArrayType).eltyp = LSB.bitType) THEN (*w := w*)
            IF xtyp.size # ytyp.size THEN Err(71) END  (* x + y *)
          ELSIF ytyp = LSB.integer THEN   (* w := 5 *)
            IF xtyp.size < Log(y.val) THEN Err(72) END
          ELSIF ytyp = LSB.string THEN   (* w := {...} *)
            IF xtyp.size # y.size THEN Err(73) END
          ELSE Err(74)
          END
        ELSE Err(74)
        END
      END
    END
  END CheckAssign;

  PROCEDURE Param(fpar: LSB.Object; VAR apar: LSB.Item);
    VAR y, z: LSB.Item;
  BEGIN expression(y); apar := New(LSB.next, NIL, y); CheckAssign(fpar, y);
    IF fpar.val IN {3, 4} THEN  (*OUT or INOUT parameter*)
      IF ~(y.tag IN {3, 7}) THEN  (*actual param is expression?*) LSS.Mark("bad actual param")
      ELSIF y.b = NIL THEN y.b := undef
      END
    END
  END Param;

  PROCEDURE Statement;
    VAR w, x, y, z, apar, npar: LSB.Item;
      unit: LSB.UnitType; fpar: LSB.Object;
  BEGIN
    IF sym < LSS.ident THEN LSS.Mark("bad factor");
      REPEAT LSS.Get(sym) UNTIL sym >= LSS.ident
    END ;
    IF sym = LSS.ident THEN
      x := ThisObj(LSS.id); z := x; LSS.Get(sym); selector(z);
      IF sym = LSS.becomes THEN LSS.Get(sym);
        IF x.val >= 5 THEN LSS.Mark("assignment to read-only") END ;
        IF (x.b # NIL) & ~(x.type IS LSB.ArrayType) THEN LSS.Mark("mult assign") END ;
        expression(y); CheckAssign(z, y); x.b := y; (*tricky*)
        IF z # x THEN x.a := z.b; x.val := 1 (*overwriting clk field x.a *) END
      ELSIF sym = LSS.lparen THEN LSS.Get(sym);  (*unit instantiation*)
        IF x.type IS LSB.UnitType THEN
          unit := x.type(LSB.UnitType); fpar := unit.firstobj;
          IF sym # LSS.rparen THEN
            Param(fpar, apar); x.b := apar; fpar := fpar.next;
            WHILE sym # LSS.rparen DO
              IF sym = LSS.comma THEN LSS.Get(sym) END ;
              Param(fpar, npar);
              IF fpar.tag >= 3 THEN fpar := fpar.next; apar.a := npar; apar := npar
              ELSE LSS.Mark("too many params")
              END
            END ;
            IF fpar.val >= 3 THEN LSS.Mark("too few params") END
          END ;
          IF sym = LSS.rparen THEN LSS.Get(sym) ELSE LSS.Mark("rparen ?") END
        ELSE LSS.Mark("not a module")
        END
      ELSE LSS.Mark("bad statement")
      END
    ELSIF sym = LSS.ts THEN  (*tri-state*) LSS.Get(sym);
      IF sym = LSS.lparen THEN LSS.Get(sym) ELSE LSS.Mark("( missing") END ;
      IF sym = LSS.ident THEN
        x := ThisObj(LSS.id); x.b := undef;  (*INOUT parameter*)
        IF x.val # 5 THEN LSS.Mark("not INOUT") END ;
        LSS.Get(sym);
        IF sym = LSS.comma THEN LSS.Get(sym) END ;
        IF sym = LSS.ident THEN y := ThisObj(LSS.id); CheckAssign(x, y); y.b := undef END ;  (*output from gate*)
        LSS.Get(sym);
        IF sym = LSS.comma THEN LSS.Get(sym) END ;
        expression(z);
        IF (z.tag = LSB.lit) & (z.val <= 1) THEN z.type := LSB.bitType END ;
        CheckAssign(x, z); LSS.Get(sym);
        IF sym = LSS.comma THEN LSS.Get(sym) END ;
        expression(w);  (*control*)
        IF w.type # LSB.bitType THEN CheckAssign(x, w) END ;
        w := New(LSB.next, z, w); x.b := New(LSB.ts, y, w);
        IF sym = LSS.rparen THEN LSS.Get(sym) ELSE LSS.Mark(") missing") END
      END
    END
  END Statement;

  PROCEDURE StatSequence;
  BEGIN Statement;
    WHILE sym <= LSS.semicolon DO
      IF sym < LSS.semicolon THEN LSS.Mark("semicolon missing?") END ;
      WHILE sym = LSS.semicolon DO LSS.Get(sym) END ;
      Statement
    END ;
    IF sym = LSS.end THEN LSS.Get(sym) ELSE LSS.Mark("END ?") END
  END StatSequence;

  (*---------------------------------------------------*)

  (* for variables and registers,, obj.val has the meaning
    0  register
    1  register with imlicit clock "clk"
    2  variable
    3  output parameter
    4  output parameter with register
    5  inout parameter
    6  input parameter  *)

  PROCEDURE ConstDeclaration;
    VAR obj: LSB.Object;
  BEGIN
    IF sym = LSS.ident THEN
      obj := NewObj(LSB.const); LSS.Get(sym);
      IF (sym = LSS.becomes) OR (sym = LSS.eql) THEN LSS.Get(sym) ELSE LSS.Mark(":= ?") END ;
      expression(obj.b); obj.type := LSB.integer;
      IF sym = LSS.semicolon THEN LSS.Get(sym) ELSE LSS.Mark("semicolon ?") END
    ELSE LSS.Mark("ident ?")
    END
  END ConstDeclaration;

  PROCEDURE Type0(VAR type: LSB.Type);
    VAR obj: LSB.Object; len, size: LONGINT;
      eltyp: LSB.Type; arrtyp: LSB.ArrayType;
  BEGIN len := 1;
    IF sym = LSS.lbrak THEN (*array*) LSS.Get(sym);
      IF sym = LSS.integer THEN len := LSS.val; LSS.Get(sym)
      ELSIF sym = LSS.ident THEN obj := ThisObj(LSS.id); len := obj.val
      END ;
      IF sym = LSS.rbrak THEN LSS.Get(sym) ELSE LSS.Mark("rbrak ?") END ;
      Type0(eltyp); NEW(arrtyp); size := eltyp.size * len;
      arrtyp.eltyp := eltyp; type := arrtyp; type.len := len; type.size := size
    ELSIF sym = LSS.ident THEN
      obj := ThisObj(LSS.id); LSS.Get(sym);
      IF obj # NIL THEN
        IF obj.tag = LSB.typ THEN type := obj.type ELSE LSS.Mark("not a type"); type := LSB.bitType END
      ELSE LSS.Mark("type ?")
      END
    ELSE type := LSB.bitType; LSS.Mark("ident or [")
    END
  END Type0;

  PROCEDURE TypeDeclaration;
    VAR obj: LSB.Object; utyp: LSB.UnitType;
  BEGIN
    IF sym = LSS.ident THEN
      obj := NewObj(LSB.typ); LSS.Get(sym);
      IF (sym = LSS.becomes) OR (sym = LSS.eql) THEN LSS.Get(sym) ELSE LSS.Mark(":= ?") END ;
      IF sym = LSS.module THEN
        LSS.Get(sym); NEW(utyp); Unit(utyp.firstobj); obj.type := utyp; obj.type.typobj := obj
      ELSE Type0(obj.type)
      END ;
      IF sym = LSS.semicolon THEN LSS.Get(sym) ELSE LSS.Mark("semicolon ?") END
    ELSE LSS.Mark("ident ?")
    END
  END TypeDeclaration;

  PROCEDURE VarList(kind: INTEGER; clk: LSB.Item);
    VAR first, new, obj: LSB.Object; type: LSB.Type;
  BEGIN obj := NIL;
    WHILE sym = LSS.ident DO
      new := NewObj(LSB.var); new.name := LSS.id; new.val := kind; first := new; LSS.Get(sym);
      IF sym = LSS.comma THEN LSS.Get(sym) ELSIF sym = LSS.ident THEN LSS.Mark("comma missing") END ;
      WHILE sym = LSS.ident DO
        new := NewObj(LSB.var); new.name := LSS.id; new.val := kind; LSS.Get(sym);
        IF sym = LSS.comma THEN LSS.Get(sym) ELSIF sym = LSS.ident THEN LSS.Mark("comma missing") END
      END ;
      IF sym = LSS.colon THEN
        LSS.Get(sym); Type0(type); obj := first;
        WHILE obj # bot DO obj.type := type; obj.a := clk; obj := obj.next END
      ELSE LSS.Mark("colon ?")
      END ;
      IF sym = LSS.semicolon THEN LSS.Get(sym)
      ELSIF sym # LSS.rparen THEN LSS.Mark("semicolon or rparen missing")
      END
    END
  END VarList;

  PROCEDURE ParamList;
    VAR kind: INTEGER;
  BEGIN
    IF sym = LSS.in THEN LSS.Get(sym); kind := 6
    ELSIF sym = LSS.out THEN LSS.Get(sym);
      IF sym = LSS.reg THEN LSS.Get(sym); kind := 4 ELSE kind := 3 END
    ELSIF sym = LSS.inout THEN LSS.Get(sym); kind := 5
    END ;
    VarList(kind, NIL)
  END ParamList;

  PROCEDURE Traverse(x: LSB.Item);
  BEGIN
    IF x # NIL THEN
      IF x IS LSB.Object THEN
        IF (x.tag = LSB.var) & (x.val >= 2) THEN  (*not reg*)
          IF x(LSB.Object).marked THEN (*loop*)
            Texts.WriteString(W, x(LSB.Object).name); Texts.Write(W, " "); err := TRUE
          ELSIF x.b # NIL THEN x(LSB.Object).marked := TRUE; Traverse(x.b)
          END ;
          x(LSB.Object).marked := FALSE
        END
      ELSE Traverse(x.a); Traverse(x.b)
      END
    END
  END Traverse;

  PROCEDURE Unit0(VAR locals: LSB.Object);
    VAR obj, oldtop: LSB.Object; kind: INTEGER; clock: LSB.Item;
  BEGIN oldtop := top.next; top.next := LSB.root;  (*top is dummy*)
    IF sym = LSS.lparen THEN LSS.Get(sym) ELSE LSS.Mark("lparen ?") END ;
    WHILE (sym = LSS.in) OR (sym = LSS.out) OR (sym = LSS.inout) DO ParamList END ;
    IF sym = LSS.rparen THEN LSS.Get(sym) ELSE LSS.Mark("rparen ?") END ;
    IF sym = LSS.xor (*arrow*) THEN LSS.Get(sym); locals := top.next
    ELSE
      IF sym = LSS.semicolon THEN LSS.Get(sym) ELSE LSS.Mark("semicolon ?") END ;
      IF sym = LSS.const THEN LSS.Get(sym);
        WHILE sym = LSS.ident DO ConstDeclaration END
      END ;
      IF sym = LSS.type THEN LSS.Get(sym);
        WHILE sym = LSS.ident DO TypeDeclaration END
      END ;
      WHILE (sym = LSS.var) OR (sym = LSS.reg) DO
        IF sym = LSS.var THEN LSS.Get(sym);
          WHILE sym = LSS.ident DO VarList(2, NIL) END
        ELSE (*reg*) kind := 0; LSS.Get(sym);
          IF sym = LSS.lparen THEN (*clock*)
            LSS.Get(sym); expression(clock);
            IF clock.type # LSB.bitType THEN LSS.Mark("clock must be bitType") END ;
            IF (clock IS LSB.Object) & (clock(LSB.Object).name = "clk") THEN kind := 1; clock := NIL END ;
            IF sym = LSS.rparen THEN LSS.Get(sym) ELSE LSS.Mark("rparen ?") END
          ELSE LSS.Mark("lparen expected"); clock := undef
          END ;
          WHILE sym = LSS.ident DO VarList(kind, clock) END
        END
      END ;
      locals := top.next;
      IF sym = LSS.begin THEN LSS.Get(sym); StatSequence END ;
      obj := locals; err := FALSE;  (*find unassigned variables*)
      WHILE obj # LSB.root DO
        IF (obj.tag = LSB.var) & (obj.val < 5) THEN
          IF (obj.b = NIL) & (obj.val < 4) THEN Texts.WriteString(W, obj.name); Texts.Write(W, " "); err := TRUE
          ELSIF obj.b = undef THEN obj.b := NIL
          END
        END ;
        obj := obj.next
      END ;
      IF err THEN Texts.WriteString(W, " unassigned"); Texts.WriteLn(W)
      ELSE obj := locals; err := FALSE;  (*find combinatorial loops*)
        WHILE obj # LSB.root DO
          IF obj.tag = LSB.var THEN obj.marked := TRUE; Traverse(obj.b); obj.marked := FALSE END ;
          obj := obj.next
        END ;
        IF err THEN Texts.WriteString(W, "in loop"); Texts.WriteLn(W) END
      END
    END ;
    IF err THEN Texts.Append(Oberon.Log, W.buf) END ;
    top.next := oldtop
  END Unit0;

  PROCEDURE Module(T: Texts.Text; pos: LONGINT);
    VAR root: LSB.Object; modname: ARRAY 32 OF CHAR;
  BEGIN Texts.WriteString(W, "compiling Lola: ");
    bot := LSB.root; top.next := bot; LSS.Init(T, pos); LSS.Get(sym);
    IF sym = LSS.module THEN
      LSS.Get(sym);
      IF sym = LSS.ident THEN
        modname := LSS.id; Texts.WriteString(W, LSS.id); LSS.Get(sym);
        Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf);
      ELSE LSS.Mark("ident ?")
      END ;
      Unit(root);
      IF sym = LSS.ident THEN LSS.Get(sym);
        IF LSS.id # modname THEN LSS.Mark("no match") END
      END ;
      IF sym # LSS.period THEN LSS.Mark("period ?") END ;
      IF ~LSS.error THEN LSB.Register(modname, root)
      ELSE Texts.WriteString(W, "compilation failed"); Texts.WriteLn(W); LSB.Register("", LSB.root)
      END
    ELSE LSS.Mark("module ?")
    END ;
    Texts.Append(Oberon.Log, W.buf)
  END Module;

  PROCEDURE Compile*;
    VAR beg, end, time: LONGINT;
      S: Texts.Scanner; T: Texts.Text;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Char THEN
      IF S.c = "*" THEN
      ELSIF S.c = "@" THEN
        Oberon.GetSelection(T, beg, end, time);
        IF time >= 0 THEN Module(T, beg) END
      END
    ELSIF S.class = Texts.Name THEN
      NEW(T); Texts.Open(T, S.s); Module(T, 0)
    END ;
    Oberon.Par.pos := Texts.Pos(S);
    Texts.Append(Oberon.Log, W.buf)
  END Compile;

BEGIN Texts.OpenWriter(W);
  Texts.WriteString(W, "Lola compiler; NW 6.7.2015"); Texts.WriteLn(W);
  NEW(top); bot := LSB.root; NEW(undef); undef.tag := 2; undef.type := LSB.bitType;
  Unit := Unit0; factor := factor0; expression := expression0;
END LSC.
