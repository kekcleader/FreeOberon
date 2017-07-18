MODULE LSV;  (*Lola System: display Verilog; generate txt-File; NW 31.8.2015*)
  IMPORT Files, Texts, Oberon, LSB;

  VAR W: Texts.Writer;
    nofgen: INTEGER;
    Constructor: PROCEDURE (VAR x: LSB.Item);   (*to avoid forward reference*)
    F: Files.File; R: Files.Rider;
    C: ARRAY 64, 6 OF CHAR;

  PROCEDURE Write(ch: CHAR);
  BEGIN Files.Write(R, ch)
  END Write;

  PROCEDURE WriteLn;
  BEGIN Files.Write(R, 0DX); Files.Write(R, 0AX)
  END WriteLn;

  PROCEDURE WriteInt(x: LONGINT);  (* x >= 0 *)
    VAR i: INTEGER; d: ARRAY 14 OF LONGINT;
  BEGIN i := 0;
    IF x < 0 THEN Files.Write(R, "-"); x := -x END ;
    REPEAT d[i] := x MOD 10; x := x DIV 10; INC(i) UNTIL x = 0;
    REPEAT DEC(i); Files.Write(R, CHR(d[i] + 30H)) UNTIL i = 0
  END WriteInt;

  PROCEDURE WriteHex(x: LONGINT);  (*x >= 0*)
    VAR i: INTEGER; d: ARRAY 8 OF LONGINT;
  BEGIN i := 0;
    REPEAT d[i] := x MOD 10H; x := x DIV 10H; INC(i) UNTIL (x = 0) OR (i = 8);
    REPEAT DEC(i);
      IF d[i] >= 10 THEN Files.Write(R, CHR(d[i] + 37H)) ELSE Files.Write(R, CHR(d[i] + 30H)) END
    UNTIL i = 0
  END WriteHex;

  PROCEDURE WriteString(s: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN i := 0;
    WHILE s[i] # 0X DO Files.Write(R, s[i]); INC(i) END
  END WriteString;

  (* ------------------------------- *)

  PROCEDURE Type(typ: LSB.Type);
    VAR obj: LSB.Object;
  BEGIN
    IF typ IS LSB.ArrayType THEN
      IF typ(LSB.ArrayType).eltyp # LSB.bitType THEN
        Write("["); WriteInt(typ.len - 1); WriteString(":0]"); Type(typ(LSB.ArrayType).eltyp)
      END
    ELSIF typ IS LSB.UnitType THEN (* obj := typ(LSB.UnitType).firstobj; *)
    END
  END Type;

  PROCEDURE BitArrLen(typ: LSB.Type);
    VAR eltyp: LSB.Type;
  BEGIN
    IF typ IS LSB.ArrayType THEN
      eltyp := typ(LSB.ArrayType).eltyp;
      WHILE eltyp IS LSB.ArrayType DO typ := eltyp; eltyp := typ(LSB.ArrayType).eltyp END ;
      IF eltyp = LSB.bitType THEN
        Write("["); WriteInt(typ.len - 1);WriteString(":0] ")
      END
    END
  END BitArrLen;

  PROCEDURE Expression(x: LSB.Item);
    VAR z: LSB.Item;
  BEGIN
    IF x # NIL THEN
      IF x IS LSB.Object THEN WriteString(x(LSB.Object).name)
      ELSIF x.tag = LSB.cons THEN
        Write("{"); Constructor(x); Write("}")
      ELSE
        IF x.tag = LSB.repl THEN
          Write("{"); WriteInt(x.b.val); Write("{"); Expression(x.a);
          Write("}"); Write("}")
        ELSE
          IF (x.tag >= LSB.and) & (x.tag <= LSB.gtr) THEN Write("(") END ;
          Expression(x.a);
          IF x.tag = LSB.sel THEN Write("["); Expression(x.b); Write("]")
          ELSIF x.tag = LSB.lit THEN
            IF x.size # 0 THEN WriteInt(x.size); Write("'"); Write("h"); WriteHex(x.val)
            ELSE WriteInt(x.val)
            END
          ELSE WriteString(C[x.tag]); Expression(x.b)
          END ;
          IF (x.tag >= LSB.and) & (x.tag <= LSB.gtr) THEN Write(")") END
        END
      END
    END
  END Expression;

  PROCEDURE Elem(VAR x: LSB.Item);
  BEGIN
    IF x.tag = LSB.repl THEN
      Write("{"); WriteInt(x.b.val); Write("{"); Expression(x.a);  WriteString("}}")
    ELSE Expression(x)
    END
  END Elem;

  PROCEDURE Constructor0(VAR x: LSB.Item);
  BEGIN
    IF x.tag = LSB.cons THEN Constructor(x.a); WriteString(", "); Elem(x.b) ELSE Elem(x) END
  END Constructor0;

  PROCEDURE Declaration(obj: LSB.Object);
    VAR apar: LSB.Item; typ: LSB.Type;
  BEGIN typ := obj.type;
    IF obj.type IS LSB.UnitType THEN WriteString("unit ") ELSE Type(obj.type) END ;
    IF obj.tag = LSB.var THEN
      IF obj.type IS LSB.UnitType THEN
        apar := obj.a; WriteLn; Write("[");
        WHILE apar # NIL DO Expression(apar.b); apar := apar.a END ;
        Write("]")
      END
    ELSIF obj.tag = LSB.const THEN WriteString(" = "); WriteInt(obj.val)
    END
  END Declaration;

  PROCEDURE ObjList0(obj: LSB.Object);  (*declarations*)
    VAR obj1: LSB.Object; param: BOOLEAN;
  BEGIN param := TRUE;
    WHILE obj # LSB.root DO
      IF (obj.tag = LSB.var) & ~(obj.type IS LSB.UnitType) THEN
        IF obj.val <= 1 THEN WriteString("reg ")
        ELSIF obj.val = 2 THEN WriteString("wire ")
        ELSIF obj.val = 3 THEN WriteString("output ")
        ELSIF obj.val = 4 THEN WriteString("output reg ")
        ELSIF obj.val = 5 THEN WriteString("inout ")
        ELSIF obj.val = 6 THEN WriteString("input ")
        ELSE WriteString("??? ")
        END ;
        BitArrLen(obj.type); WriteString(obj.name);
        obj1 := obj.next;
        WHILE (obj1 # LSB.top) & (obj1.type = obj.type) & (obj1.val = obj.val) DO
          WriteString(", "); obj := obj1; WriteString(obj.name); obj1 := obj.next
        END ;
        IF param & (obj.val >= 3) & (obj1.val < 3) THEN  (*end param list*) param := FALSE; Write(")")
        END ;
        IF (obj.type # LSB.bitType) & (obj.type(LSB.ArrayType).eltyp # LSB.bitType) THEN Type(obj.type) END ;
        IF param THEN Write(",") ELSE Write(";") END ;
        WriteLn
      ELSIF obj.tag = LSB.const THEN
      END ;
      obj := obj.next
    END
  END ObjList0;

  PROCEDURE ActParam(VAR x: LSB.Item; fpar: LSB.Object);
  BEGIN Write("."); WriteString(fpar.name); Write("("); Expression(x); Write(")")
  END ActParam;

  PROCEDURE ObjList1(obj: LSB.Object);  (*assignments to variables*)
    VAR apar, x: LSB.Item; fpar: LSB.Object; size: LONGINT;
  BEGIN
    WHILE obj # LSB.root DO
      IF (obj.tag = LSB.var) OR (obj.tag = LSB.const) THEN
        IF obj.type IS LSB.UnitType THEN
          WriteString(obj.type.typobj.name); Write(" "); WriteString(obj.name);
          apar := obj.b; fpar := obj.type(LSB.UnitType).firstobj;
          Write("("); ActParam(apar.b, fpar); apar := apar.a; fpar := fpar.next;  (*actual param list*)
          WHILE apar # NIL DO WriteString(", "); ActParam(apar.b, fpar); apar := apar.a; fpar := fpar.next END ;
          Write(")"); Write(";"); WriteLn
        ELSIF (obj.b # NIL) & (obj.val = 5) THEN  (*tri-state*)
          size := obj.type.size; x := obj.b;
        IF x.tag = LSB.ts THEN
            IF obj.type = LSB.bitType THEN
              WriteString("IOBUF block"); INC(nofgen); WriteInt(nofgen); WriteString(" (.IO("); WriteString(obj.name);
              WriteString("), .O("); WriteString(x.a(LSB.Object).name); WriteString("), .I("); x := x.b;
              IF x.a.type = LSB.bitType THEN Expression(x.a) ELSE WriteString(x.a(LSB.Object).name) END ;
              WriteString("), .T(");
              IF x.b.type = LSB.bitType THEN Expression(x.b) ELSE  WriteString(x.b(LSB.Object).name) END ;
              WriteString("));")
            ELSE  (*array type*)
              IF nofgen = 0 THEN WriteString("genvar i;"); WriteLn END ;
              INC(nofgen); WriteString("generate"); WriteLn;
              WriteString("for (i = 0; i < "); WriteInt(size); WriteString("; i = i+1) begin : bufblock"); WriteInt(nofgen); WriteLn;
              WriteString("IOBUF block (.IO("); WriteString(obj.name);
              WriteString("[i]), .O("); WriteString(x.a(LSB.Object).name); WriteString("[i]), .I("); x := x.b;
              WriteString(x.a(LSB.Object).name); WriteString("[i]), .T(");
              IF x.b.type = LSB.bitType THEN Expression(x.b) ELSE WriteString(x.b(LSB.Object).name); WriteString("[i]") END ;
              WriteString("));"); WriteLn; WriteString("end"); WriteLn; WriteString("endgenerate")
            END ;
            WriteLn
          END
        ELSIF (obj.b # NIL) & (obj.val >= 2) THEN
          WriteString("assign "); WriteString(obj.name);
          IF (obj.a # NIL) THEN Write("["); Expression(obj.a); Write("]") END ;
          WriteString(" = "); Expression(obj.b); Write(";"); WriteLn
        END
      ELSIF obj.tag = LSB.typ THEN (*instantiation; actual parameters*)
      END ;
      obj := obj.next
    END
  END ObjList1;

  PROCEDURE ObjList2(obj: LSB.Object);  (*assignments to registers*)
    VAR apar: LSB.Item; kind: LONGINT; clk: LSB.Item;
  BEGIN
    WHILE obj # LSB.root DO
      IF (obj.tag = LSB.var) & ~(obj.type IS LSB.UnitType) & (obj.val < 2) THEN
        WriteString("always @ (posedge "); kind := obj.val;
        IF kind = 0 THEN Expression(obj.a)
        ELSE (*kind = 1*) WriteString("clk")
        END ;
        WriteString(") begin ");
        REPEAT WriteString(obj.name);
          IF (kind = 1) & (obj.a # NIL) THEN Write("["); Expression(obj.a); Write("]") END ;
          WriteString(" <= "); Expression(obj.b); Write(";"); WriteLn; obj := obj.next
        UNTIL (obj = LSB.top) OR (obj.val # kind);
        WriteString("end"); WriteLn
      ELSE obj := obj.next
      END
    END
  END ObjList2;

  PROCEDURE List*;
    VAR S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF (S.class = Texts.Name) OR (S.class = Texts.String) THEN
      Texts.WriteString(W, LSB.modname); Texts.WriteString(W, " translating to  "); Texts.WriteString(W, S.s);
      F := Files.New(S.s); Files.Set(R, F, 0);
      WriteString("`timescale 1ns / 1 ps"); WriteLn; nofgen := 0;
      WriteString("module "); WriteString(LSB.modname); WriteString("(   // translated from Lola"); WriteLn;
      ObjList0(LSB.top); ObjList1(LSB.top); ObjList2(LSB.top);
      WriteString("endmodule"); WriteLn;
      Files.Register(F); Texts.WriteString(W, " done"); Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END List;

BEGIN Texts.OpenWriter(W); Constructor := Constructor0;
  C[LSB.const] := "CONST"; C[LSB.typ] := "TYPE"; C[LSB.var] := "VAR";
  C[LSB.lit] := "LIT"; C[LSB.sel] := "SEL"; C[LSB.range] := ":"; C[LSB.cons] := ",";
  C[LSB.or] := " | "; C[LSB.xor] := " ^ "; C[LSB.and] := " & ";  C[LSB.not] := "~";
  C[LSB.add] := " + "; C[LSB.sub] := " - "; C[LSB.mul] := " * "; C[LSB.div] := " / ";
  C[LSB.eql] := " == "; C[LSB.neq] := " != "; C[LSB.lss] := " <  "; C[LSB.geq] := " >= "; C[LSB.leq] := " <= "; C[LSB.gtr] := " >  ";
  C[LSB.then] := " ? "; C[LSB.else] := " : "; C[LSB.ts] := "TS"; C[LSB.next] := "--"
END LSV.
