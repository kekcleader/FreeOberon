MODULE AutodocHtml;
IMPORT Texts, Out, Strings, P := AutodocParser;

CONST
  styleFname = 'style.css';

VAR
  PrintObject: PROCEDURE (o: P.Object; indent: INTEGER; inlined: BOOLEAN);

  TX: Texts.Text;
  W: Texts.Writer;
  
  preventSemicol: BOOLEAN;

  inlineStyle: BOOLEAN;

(** Printing **)

PROCEDURE Write(s: ARRAY OF CHAR);
BEGIN Texts.WriteString(W, s)
END Write;

PROCEDURE WriteLn(s: ARRAY OF CHAR);
BEGIN Write(s); Texts.WriteLn(W)
END WriteLn;

PROCEDURE WriteLn2(a, b: ARRAY OF CHAR);
BEGIN Write(a); WriteLn(b)
END WriteLn2;

PROCEDURE WriteLn3(a, b, c: ARRAY OF CHAR);
BEGIN Write(a); Write(b); WriteLn(c)
END WriteLn3;

PROCEDURE WriteParagraphs(s: ARRAY OF CHAR; marks: BOOLEAN);
VAR i: INTEGER;
  c: CHAR;
BEGIN
  i := 0; c := s[0];
  IF c # 0X THEN
    WriteLn('<p>');
    IF marks THEN Write('<span class="mark">(*</span> ') END;
    WHILE c # 0X DO
      IF c = 0AX THEN WriteLn(''); WriteLn('</p>'); WriteLn('<p>')
      ELSE Texts.Write(W, c)
      END;
      INC(i); c := s[i]
    END;
    WriteLn('');
    IF marks THEN Write(' <span class="mark">*)</span>') END;
    WriteLn('</p>')
  END
END WriteParagraphs;

PROCEDURE WriteStyle;
VAR T2: Texts.Text;
  buf: Texts.Buffer;
BEGIN
  NEW(T2); Texts.Open(T2, styleFname);
  IF T2.len # 0 THEN
    WriteLn('<style>');
    Texts.Append(TX, W.buf);
    NEW(buf); Texts.OpenBuf(buf);
    Texts.Save(T2, 0, T2.len, buf);
    Texts.Append(TX, buf);
    WriteLn(''); WriteLn('</style>')
  ELSE Out.String('Could not find stylesheet file "');
    Out.String(styleFname); Out.String('".'); Out.Ln
  END
END WriteStyle;

PROCEDURE OpenGroup(title: ARRAY OF CHAR);
BEGIN
  WriteLn('<article class="group">');
  Write('<h3 class="group-title">');
  IF title # '-' THEN Write(title) ELSE Write('* * *') END;
  WriteLn('</h3>');
  WriteLn('<div class="group-content">');
END OpenGroup;

PROCEDURE CloseGroup;
BEGIN WriteLn('</div>'); WriteLn('</article>')
END CloseGroup;

PROCEDURE PrintIndent(n: INTEGER);
BEGIN
  WHILE n > 0 DO Write('&nbsp; '); DEC(n) END
END PrintIndent;

PROCEDURE PrintComment(o: P.Object; marks: BOOLEAN);
BEGIN
  Write('<section class="comment">');
  WriteParagraphs(o.comment, marks);
  WriteLn('</section>')
END PrintComment;

PROCEDURE PrintList(L: P.List; indent: INTEGER; inlined: BOOLEAN);
VAR o: P.Object;
BEGIN
  IF (L # NIL) & (L.first # NIL) THEN
    IF L.comment[0] # 0X THEN OpenGroup(L.comment) END;
    o := L.first;
    WHILE o # NIL DO
      PrintObject(o, indent, FALSE);
      o := o.next
    END;
    IF L.comment[0] # 0X THEN CloseGroup END
  END
END PrintList;

PROCEDURE PrintConst(C: P.Const; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  WriteLn ('<article class="object const">');
  WriteLn ('  <div class="def">');
  WriteLn3('    <span class="name">', C.name, '</span> =');
  WriteLn3('    <span class="value">', C.value, '</span>;');
  WriteLn ('  </div>');
  PrintComment(C, FALSE);
  WriteLn ('</article>')
END PrintConst;

PROCEDURE PrintParam(par: P.Param; indent: INTEGER; inlined: BOOLEAN);
VAR tmp: BOOLEAN;
BEGIN tmp := preventSemicol; preventSemicol := FALSE;
  Write('<span class="param">');
  IF par.passed = P.byVar THEN
    Write('<span class="passed by-var">VAR</span>&nbsp;')
  END;
  Write('<span class="name">'); Write(par.name); Write('</span>');
  Write(': <span class="type">');
  PrintObject(par.type, indent, TRUE);
  IF ~tmp THEN WriteLn(';') END;
  Write('</span></span></span>')
END PrintParam;

PROCEDURE PrintVar(v: P.Var; indent: INTEGER; inlined: BOOLEAN);
VAR tmp: BOOLEAN;
BEGIN tmp := preventSemicol; preventSemicol := FALSE;
  IF inlined THEN
    Write('<span class="var">');
    PrintIndent(indent);
    Write('<span class="name">'); Write(v.name);
    Write('</span>: <span class="type">');
    PrintObject(v.type, indent, TRUE);
    IF ~tmp THEN Write('; &nbsp;') END;
    Write('</span></span>');
    PrintComment(v, TRUE);
  ELSE
    WriteLn ('<article class="object var">');
    WriteLn ('  <div class="def">');
    WriteLn3('    <span class="name">', v.name, '</span>:');
    WriteLn ('    <span class="type">');
    PrintObject(v.type, indent, TRUE); WriteLn('</span>;');
    WriteLn ('  </div>');
    PrintComment(v, FALSE);
    WriteLn ('</article>')
  END
END PrintVar;

PROCEDURE PrintType(T: P.Type; indent: INTEGER; inlined: BOOLEAN);
VAR x: P.Object;
BEGIN
  IF inlined THEN
    IF T.form = P.namedType THEN Write(T.name)
    ELSIF T.form = P.arrayType THEN Write('ARRAY ');
      IF T.len[0] # 0X THEN Write(T.len); Write(' ') END;
      Write('OF '); PrintObject(T.base, indent + 1, TRUE)
    ELSIF T.form = P.recordType THEN Write('RECORD');
      IF T.base # NIL THEN Write('(<span class="record-base">');
        Write(T.base.name); Write('</span>)')
      END;
      x := T.fields.first;
      IF x # NIL THEN WriteLn('<span class="record-fields">') END;
      WHILE x # NIL DO
        IF x = T.fields.last THEN preventSemicol := TRUE END;
        PrintObject(x, indent + 1, TRUE);
        x := x.next
      END;
      IF T.fields.first # NIL THEN WriteLn('</span>') END;
      Write(' END')
    END
  ELSE
    WriteLn ('<article class="object type">');
    WriteLn ('  <div class="def">');
    WriteLn3('    <span class="name">', T.name, '</span> =');
    WriteLn ('    <span class="typedef">');
    PrintObject(T.base, indent, TRUE); WriteLn('</span>;');
    WriteLn ('  </div>');
    PrintComment(T, FALSE);
    WriteLn ('</article>');
  END
END PrintType;

PROCEDURE PrintType2(T: P.Type; indent: INTEGER; inlined: BOOLEAN);
VAR x: P.Object;
BEGIN
  PrintIndent(indent);
  IF T = NIL THEN Out.String('NIL')
  ELSIF T.form = P.namedType THEN
    Out.String('type '); Out.String(T.name);
    IF T.base # NIL THEN
      Out.String(' is '); PrintType(T.base, indent, TRUE)
    END
  ELSIF T.form = P.arrayType THEN
    IF T.len[0] = 0X THEN Out.String('open ') END;
    Out.String('array type ');
    IF T.len[0] # 0X THEN Out.String('with length ');
      Out.String(T.len); Out.Char(' ')
    END;
    Out.String('of '); PrintObject(T.base, indent, TRUE)
  ELSIF T.form = P.recordType THEN Out.String('record type ');
    IF T.base # NIL THEN Out.String('that extends ');
      Out.String(T.base.name); Out.Char(' ')
    END;
    IF T.fields.first # NIL THEN Out.String('with fields:'); Out.Ln;
      PrintList(T.fields, indent + 1, FALSE)
    ELSE Out.String('with no fields')
    END
  ELSIF T.form = P.procedureType THEN Out.String('procedure type ');
    IF T.fields.first # NIL THEN
      PrintIndent(indent); Out.Char('(');
      PrintList(T.fields, indent + 1, TRUE);
      Out.String(') ')
    END;
    IF T.base # NIL THEN
      Out.String('that returns '); PrintObject(T.base, indent, TRUE)
    END
  ELSIF T.form = P.pointerType THEN Out.String('pointer type to ');
    PrintObject(T.base, indent, TRUE)
  ELSE Out.String('?')
  END;
  IF ~inlined THEN Out.Ln; PrintComment(T, FALSE) END
END PrintType2;

PROCEDURE PrintProcedure(p: P.Procedure; indent: INTEGER; inlined: BOOLEAN);
VAR x: P.Object;
BEGIN
  WriteLn ('<article class="object procedure">');
  WriteLn ('  <div class="def">');
  WriteLn ('    PROCEDURE');
  Write   ('    <span class="name">'); Write(p.name);
  Write('</span><span class="params">');
  x := p.params.first;
  IF (x # NIL) OR (p.returnType # NIL) THEN Write('(');
    WHILE x # NIL DO
      IF x = p.params.last THEN preventSemicol := TRUE END;
      PrintObject(x, indent + 1, TRUE);
      x := x.next
    END;
    Write(')')
  END;
  IF p.returnType # NIL THEN
    Write(': '); PrintType(p.returnType, indent, TRUE)
  END;
  WriteLn(';</span></div>');
  PrintComment(p, FALSE);
  WriteLn('</article>')
END PrintProcedure;

PROCEDURE BigTitle(text: ARRAY OF CHAR);
BEGIN WriteLn3('<h2 class="heading">', text, '</h2>')
END BigTitle;

PROCEDURE Header(modName: ARRAY OF CHAR);
BEGIN
  WriteLn('<!DOCTYPE html>');
  WriteLn('<html>');
  WriteLn('<head>');
  WriteLn('<meta charset="utf-8">');
  WriteLn('<title>'); Write(modName);
  WriteLn(' Module Reference</title>');
  WriteLn('<meta name="viewport" content="width=device-width,initial-scale=1.0">');
  WriteLn('</head>');
  WriteLn('<body>');
  WriteLn('<header class="header"><div class="inner">');
  Write('<h1>Module <span class="module-name">'); Write(modName);
  WriteLn('</span> <span class="subtitle">Reference</span></h1>');
  WriteLn('</div></header>');
  WriteLn('<main class="main"><div class="inner">');
END Header;

PROCEDURE Footer;
BEGIN
  WriteLn('</div></main><footer class="footer"><div class="inner">');
  WriteLn('<p>Generated automatically by Free Oberon Autodoc</p>');
 
  WriteLn('</div></footer>');

  IF inlineStyle THEN WriteStyle
  ELSE WriteLn('<link rel="stylesheet" href="style.css">')
  END;

  WriteLn('</body></html>')
END Footer;

PROCEDURE PrintModule(M: P.Module; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  Header(M.name);
  PrintComment(M, FALSE);
  BigTitle('Constants');
  PrintList(M.consts, 0, FALSE);
  BigTitle('Types');
  PrintList(M.types, 0, FALSE);
  BigTitle('Variables');
  PrintList(M.vars, 0, FALSE);
  BigTitle('Procedures');
  PrintList(M.procedures, 0, FALSE);
  Footer
END PrintModule;

PROCEDURE PrintObject0(o: P.Object; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  IF o = NIL THEN WriteLn('NIL')
  ELSIF o IS P.Module THEN PrintModule(o(P.Module), indent, inlined)
  ELSIF o IS P.Var THEN PrintVar(o(P.Var), indent, inlined)
  ELSIF o IS P.Const THEN PrintConst(o(P.Const), indent, inlined)
  ELSIF o IS P.Type THEN PrintType(o(P.Type), indent, inlined)
  ELSIF o IS P.Procedure THEN PrintProcedure(o(P.Procedure), indent, inlined)
  ELSIF o IS P.Param THEN PrintParam(o(P.Param), indent, inlined)
  ELSIF o IS P.List THEN PrintList(o(P.List), indent, inlined)
  ELSE Out.String('?')
  END;
  IF ~inlined THEN Out.Ln END
END PrintObject0;

(** - **)

PROCEDURE SetInlineStyle*(inline: BOOLEAN);
BEGIN inlineStyle := inline
END SetInlineStyle;

PROCEDURE Save*(module: P.Module; fname: ARRAY OF CHAR): BOOLEAN;
BEGIN
  NEW(TX); Texts.Open(TX, ''); Texts.OpenWriter(W);
  preventSemicol := FALSE;
  PrintObject(module, 0, FALSE);
  Texts.Append(TX, W.buf); Texts.Close(TX, fname)
RETURN TRUE END Save;

BEGIN
  PrintObject := PrintObject0;
  inlineStyle := FALSE
END AutodocHtml.
