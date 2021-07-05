MODULE BrowserCmd;  (* RC 29.10.93 *)  (* object model 4.12.93, command line version jt 4.4.95 *)

 IMPORT
    OPM, OPS, OPT, OPV,
    Texts, Strings, Files, Out,
    Oberon, Modules, SYSTEM, Configuration;

  CONST
    OptionChar = "-";

  VAR
    W: Texts.Writer;
    option: CHAR;

  PROCEDURE Ws(s: ARRAY OF CHAR); BEGIN Texts.WriteString(W, s) END Ws;
  PROCEDURE Wc(ch: CHAR);         BEGIN Texts.Write(W, ch)      END Wc;
  PROCEDURE Wi(i: SYSTEM.INT64);  BEGIN Texts.WriteInt(W, i, 0) END Wi;
  PROCEDURE Wln;                  BEGIN Texts.WriteLn(W)        END Wln;

  PROCEDURE Wh(i: SYSTEM.INT64);
  BEGIN
    IF i >= 16 THEN Wh(i DIV 10H)
    ELSIF i >= 10 THEN Wc("0") END;
    i := i MOD 16;
    IF i < 10 THEN Wc(CHR(i+30H)) ELSE Wc(CHR(i+37H)) END
  END Wh;

  PROCEDURE Indent(i: INTEGER);
  BEGIN WHILE i > 0 DO Wc(" "); Wc(" "); DEC(i) END
  END Indent;

  PROCEDURE ^Wtype(typ: OPT.Struct);
  PROCEDURE ^Wstruct(typ: OPT.Struct);

  PROCEDURE Wsign(result: OPT.Struct; par: OPT.Object);
    VAR paren, res, first: BOOLEAN;
  BEGIN first := TRUE;
    res := (result # NIL) (* hidden mthd *) & (result # OPT.notyp);
    paren := res OR (par # NIL);
    IF paren THEN Wc("(") END;
    WHILE par # NIL DO
      IF ~first THEN Ws("; ") ELSE first := FALSE END;
      IF option = "x" THEN Wi(par^.adr); Wc(" ") END;
      IF par^.mode = OPT.VarPar THEN Ws("VAR ") END;
      Ws(par^.name); Ws(": "); Wtype(par^.typ);
      par := par^.link
    END;
    IF paren THEN Wc(")") END;
    IF res THEN Ws(": "); Wtype(result) END
  END Wsign;

  PROCEDURE HasForm(obj: OPT.Object; mode: SET): BOOLEAN;
  BEGIN
    RETURN (obj # NIL)
         & (   ((obj.mode IN mode) & (obj.name # ""))
            OR HasForm(obj.left, mode)
            OR HasForm(obj.right, mode));
  END HasForm;

  PROCEDURE Objects(obj: OPT.Object; mode: SET);
    VAR i: SYSTEM.INT64; m: INTEGER; s: SYSTEM.SET64; ext: OPT.ConstExt;
  BEGIN
    IF obj # NIL THEN
      Objects(obj^.left, mode);
      IF obj^.mode IN mode THEN
        CASE obj^.mode OF
        |OPT.Con:   Indent(2); Ws(obj^.name); Ws(" = ");
                    CASE obj^.typ^.form OF
                    |OPT.Bool:   IF obj^.conval^.intval = 1 THEN Ws("TRUE") ELSE Ws("FALSE") END
                    |OPT.Char:   IF (obj^.conval^.intval >= 32) & (obj^.conval^.intval <= 126) THEN
                                   Wc(22X); Wc(CHR(obj^.conval^.intval)); Wc(22X)
                                 ELSE
                                   i := obj^.conval^.intval DIV 16;
                                   IF i > 9 THEN Wc(CHR(55 + i)) ELSE Wc(CHR(48 + i)) END;
                                   i := obj^.conval^.intval MOD 16;
                                   IF i > 9 THEN Wc(CHR(55 + i)) ELSE Wc(CHR(48 + i)) END;
                                   Wc("X")
                                 END
                    |OPT.Int:    Wi(obj^.conval^.intval)
                    |OPT.Set:    Wc("{"); i := 0; s := obj^.conval^.setval;
                                 WHILE i <= MAX(SYSTEM.SET64) DO
                                   IF i IN s THEN Wi(i); EXCL(s, i);
                                     IF s # {} THEN Ws(", ") END
                                   END;
                                   INC(i)
                                 END;
                                 Wc("}")
                    |OPT.Real:   Texts.WriteReal(W, SHORT(obj^.conval^.realval), 16)
                    |OPT.LReal:  Texts.WriteLongReal(W, obj^.conval^.realval, 23)
                    |OPT.String: Wc('"'); Ws(obj^.conval^.ext^); Wc('"')
                    |OPT.NilTyp: Ws("NIL")
                    ELSE (* Ignore other forms *)
                    END;
                    Wc(";"); Wln
        |OPT.Typ:   IF obj^.name # "" THEN Indent(2);
                      IF obj^.typ^.strobj = obj THEN  (* canonical name *)
                        Wtype(obj^.typ); Ws(" = "); Wstruct(obj^.typ)
                      ELSE  (* alias *)
                        Ws(obj^.name); Ws(" = "); Wtype(obj^.typ)
                      END;
                      Wc(";"); Wln
                    END
        |OPT.Var:   Indent(2); Ws(obj^.name);
                    IF obj^.vis = OPT.externalR THEN Ws("-: ") ELSE Ws(": ") END;
                    Wtype(obj^.typ); Wc(";"); Wln
        |OPT.XProc,
         OPT.CProc,
         OPT.IProc: Indent(1); Ws("PROCEDURE ");
                    IF obj^.mode = OPT.IProc THEN Wc("+")
                    ELSIF obj^.mode = OPT.CProc THEN Wc("-")
                    END;
                    Ws(obj^.name);
                    Wsign(obj^.typ, obj^.link);
                    IF obj^.mode = OPT.CProc THEN
                      ext := obj^.conval^.ext; m := ORD(ext^[0]); i := 1; Ws('  "');
                      WHILE i <= m DO Wc(ext^[i]); INC(i) END;
                      Wc('"');
                    END;
                    Wc(";"); Wln
        ELSE (* Ignore other modes *)
        END
      END;
      Objects(obj^.right, mode)
    END
  END Objects;

  PROCEDURE Wmthd(obj: OPT.Object);
    VAR
  BEGIN
    IF obj # NIL THEN
      Wmthd(obj^.left);
      IF (obj^.mode = OPT.TProc) & ((obj^.name # OPM.HdTProcName) OR (option = "x")) THEN
        Indent(3); Ws("PROCEDURE (");
        IF obj^.name # OPM.HdTProcName THEN
          IF obj^.link^.mode = OPT.VarPar THEN Ws("VAR ") END;
          Ws(obj^.link^.name); Ws(": "); Wtype(obj^.link^.typ)
        END;
        Ws(") "); Ws(obj^.name);
        Wsign(obj^.typ, obj^.link^.link);
        Wc(";");
        IF option = "x" THEN Indent(1);
          Ws("(* methno: "); Wi(obj^.adr DIV 10000H);  Ws(" *)")
        END;
        Wln;
      END;
      Wmthd(obj^.right)
    END
  END Wmthd;

  PROCEDURE Wstruct(typ: OPT.Struct);
    VAR fld: OPT.Object;

    PROCEDURE SysFlag;
    BEGIN IF typ^.sysflag # 0 THEN Wc("["); Wh(typ^.sysflag); Ws("H] ") END
    END SysFlag;

  BEGIN
    CASE typ^.form OF
    |OPT.Undef:   Ws("Undef")
    |OPT.Pointer: Ws("POINTER "); SysFlag; Ws("TO "); Wtype(typ^.BaseTyp)
    |OPT.ProcTyp: Ws("PROCEDURE "); SysFlag; Wsign(typ^.BaseTyp, typ^.link)
    |OPT.Comp:    CASE typ^.comp OF
                  |OPT.Array:  Ws("ARRAY "); SysFlag; Wi(typ^.n); Ws(" OF "); Wtype(typ^.BaseTyp)
                  |OPT.DynArr: Ws("ARRAY "); SysFlag; Ws("OF "); Wtype(typ^.BaseTyp)
                  |OPT.Record: Ws("RECORD ");SysFlag;
                               IF typ^.BaseTyp # NIL THEN Wc("("); Wtype(typ^.BaseTyp); Wc(")") END;
                               Wln; fld := typ^.link;
                               WHILE (fld # NIL) & (fld^.mode = OPT.Fld) DO
                                 IF (option = "x") OR (fld^.name[0] # "@") THEN Indent(3);
                                   IF option = "x" THEN Wi(fld^.adr); Wc(" ") END;
                                   Ws(fld^.name);
                                   IF fld^.vis = OPT.externalR THEN Wc("-") END;
                                   Ws(": "); Wtype(fld^.typ); Wc(";");
                                   Wln
                                 END;
                                 fld := fld^.link
                               END;
                               Wmthd(typ^.link);
                               Indent(2); Ws("END");
                               IF option = "x" THEN Indent(1);
                                 Ws("(* size: "); Wi(typ^.size); Ws(" align: "); Wi(typ^.align);
                                 Ws(" nofm: "); Wi(typ^.n); Ws(" *)")
                               END
                  ELSE (* Ignore other comps *)
                  END
    ELSE (* Ignore other froms *)
    END
  END Wstruct;

  PROCEDURE Wtype(typ: OPT.Struct);
    VAR obj: OPT.Object;
  BEGIN
    obj := typ^.strobj;
    IF obj^.name # "" THEN
      IF typ^.mno # 0 THEN Ws(OPT.GlbMod[typ^.mno].name); Wc(".")
      ELSIF (typ = OPT.bytetyp) OR (typ = OPT.sysptrtyp) THEN Ws("SYSTEM.")
      ELSIF obj^.vis = OPT.internal THEN Wc("#")
      END;
      Ws(obj^.name)
    ELSE
      IF (option = "x") & (typ^.ref > OPM.MaxStruct) THEN Wc("#"); Wi(typ^.ref - OPM.MaxStruct); Wc(" ") END;
      Wstruct(typ)
    END
  END Wtype;

  PROCEDURE WModule(name: OPS.Name; T: Texts.Text);
    VAR
      i:           INTEGER;
      beg, end:    LONGINT;
      first, done: BOOLEAN;
      obj:         OPT.Object;

    PROCEDURE Header(s: ARRAY OF CHAR);
    BEGIN
      beg := W.buf.len; Indent(1); Ws(s); Wln; end := W.buf.len
    END Header;

    PROCEDURE CheckHeader;
       VAR len: LONGINT;
    BEGIN
      len := T.len;
      IF end = W.buf.len THEN Texts.Append(T, W.buf); Texts.Delete(T, len+beg, len+end)
      ELSE Wln
      END
    END CheckHeader;

  BEGIN
    OPT.Import("@notself", name, done);
    IF done THEN
      Ws("DEFINITION "); Ws(name); Wc(";"); Wln;

      IF OPT.nofGmod > 1 THEN
        Header("IMPORT"); i := 1; first := TRUE;
        WHILE i < OPT.nofGmod DO
          IF first THEN first := FALSE; Indent(2) ELSE Ws(", ") END;
          Ws(OPT.GlbMod[i].name);
          INC(i)
        END;
        IF ~first THEN Wc(";"); Wln END
      END;
      CheckHeader;
      obj := OPT.GlbMod[0].right;
      IF HasForm(obj, {OPT.Con}) THEN Header("CONST"); Objects(obj, {OPT.Con}); CheckHeader END;
      IF HasForm(obj, {OPT.Typ}) THEN Header("TYPE");  Objects(obj, {OPT.Typ}); CheckHeader END;
      IF HasForm(obj, {OPT.Var}) THEN Header("VAR");   Objects(obj, {OPT.Var}); CheckHeader END;
      Objects(obj, {OPT.XProc, OPT.IProc, OPT.CProc}); Wln;
      Ws("END "); Ws(name); Wc("."); Wln; Texts.Append(T, W.buf)
    ELSE
      Texts.WriteString(W, name); Texts.WriteString(W, " -- symbol file not found");
      Texts.WriteLn(W); Texts.Append(T, W.buf)
    END
  END WModule;

  PROCEDURE Ident(VAR name, first: ARRAY OF CHAR);
  VAR i, j: INTEGER; ch: CHAR;
  BEGIN i := 0;
    WHILE name[i] # 0X DO INC(i) END;
    WHILE (i >= 0) & (name[i] # "/") DO DEC(i) END;
    IF i > 0 THEN name[i] := 0X; Files.SetSearchPath(name) END;
    INC(i); j := 0; ch := name[i];
    WHILE (ch # ".") & (ch # 0X) DO first[j] := ch; INC(i); INC(j); ch := name[i] END;
    first[j] := 0X
  END Ident;

  PROCEDURE ShowDef*;
    VAR S, vname, name: OPS.Name;
  BEGIN
    option := 0X; Modules.GetArg(1, S);
    IF Modules.ArgCount > 2 THEN
      IF S[0] = OptionChar THEN option := S[1]; Modules.GetArg(2, S)
      ELSE Modules.GetArg(2, vname); option := vname[1]
      END
    END;
    IF Modules.ArgCount >= 2 THEN
      Ident(S, name);
      OPT.Init(name, {}); OPT.SelfName := "AvoidErr154";
      WModule(name, Oberon.Log);
      OPT.Close;
    ELSE
      Ws("showdef - Display module's public interface."); Wln;
      Wln;
      Ws("Usage: showdef module"); Wln;
      Wln;
      Ws("Where <module> is a symbol file name. The .sym may be omitted."); Wln;
      Ws("If no path is provided, and the module does not exist in the current directory,"); Wln;
      Ws("then showdef will also look for the module in the installed libraries."); Wln;
      Texts.Append(Oberon.Log, W.buf)
    END
  END ShowDef;

PROCEDURE SetDefaultPath;
VAR path: ARRAY 256 OF CHAR;
BEGIN
  path := ".;";
  Strings.Append(Configuration.installdir, path);
  Strings.Append("/2/sym", path);
  Files.SetSearchPath(path)
END SetDefaultPath;

BEGIN
  Texts.OpenWriter(W);
  SetDefaultPath;
  ShowDef
END BrowserCmd.
