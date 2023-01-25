MODULE AutodocHtml;
IMPORT Texts, Out, Strings, P := AutodocParser, Env, Lang := SimpleLangs,
  Time;

CONST
  styleFname = 'Data/style.css'; (** Where to take stylesheet from *)
  defLang = 'en'; (** Default language code. Lang files are in Data/Lang/ *)
  defPal = 'default'; (** Default palette name. *)

  (** Color Array Indices **)
  (** Every const is a background color and
      every (const + 1) is a foreground color *)
  main      =  0; (** Main backgrund color and main foreground color *)
  head      =  2; (** Header/footer color *)
  head2     =  4; (** Header secondary text color (bg also used as fg) *)
  tab       =  6; (** Main table color *)
  tabRow    =  8; (** Highlighted rows (or columns) *)
  tabHead   = 10; (** Table header color *)
  title     = 12; (** Group title color *)
  high      = 14; (** bg - highlighted text color, fg - string text color *)
  box       = 16; (** bg - group title shadow, fg - table border color *)
  comment   = 18; (** bg - comment parenthesis, fg - comment text color *)
  nofcolors = 20; (** Number of colors. Last color is high + 1 = 15 *)

  (** Misc **)

  TAB = 09X; (** Tab ASCII code *)

TYPE
  Color = ARRAY 10 OF CHAR; (** Example: 'FF000080' (HEX RGBA) *)
  Palette = ARRAY nofcolors OF Color;

VAR
  PrintObject: PROCEDURE (o: P.Object; indent: INTEGER; inlined: BOOLEAN);

  (** HTML File Output
      |
      This is to output HTML **)
  TX: Texts.Text; (** Text object of generated HTML file *)
  W: Texts.Writer; (** Writer on TX *)

  isLastItem: BOOLEAN;
  isLastListItem: BOOLEAN;

  (** Render Settings **)
  showExportMarks: BOOLEAN; (** Value is exactly ~M.exportedOnly *)
  externalStyle: BOOLEAN; (** If TRUE, do not put CSS code right in HTML *)
  lang: ARRAY 6 OF CHAR;

  palette: Palette; (** Current palette, is set by SetColors *)
  curColor: INTEGER; (** Current color for palette, used by SetColors *)

(** Link Module List **)

  (** Module names of modules to which <a href> will work *)
  linkMods: ARRAY 256 OF ARRAY 64 OF CHAR;
  linkModCount: INTEGER; (** Actual length of array linkMods *)
  linkToIndex: BOOLEAN; (** TRUE if link to "Get Started" should be added *)

(** List of Declared Names **)

  (** Names declared in the same module to which <a href> will work *)
  declNames: ARRAY 256 OF ARRAY 64 OF CHAR;
  declNameCount: INTEGER; (** Actual length of array declNames *)

(** HTML Template **)
  tpl: ARRAY 40960 OF CHAR;
  renderingIndex: BOOLEAN;
  indexTitle: P.Str;
  indexComment: P.LongStr;

(** Link Module List **)

PROCEDURE AddLinkMod*(name: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  IF P.debug THEN P.Debug('Adding link module name:'); P.Debug(name) END;
  i := 0; (* Search for duplicate *)
  WHILE (i # linkModCount) & (linkMods[i] # name) DO INC(i) END;
  IF i = linkModCount THEN
    IF linkModCount < LEN(linkMods) THEN
      Strings.Copy(name, linkMods[linkModCount]); INC(linkModCount)
    ELSE Out.String('Too many link module names.'); Out.Ln
    END
  END
END AddLinkMod;

(** Calls AddLinkMod, but removes the last period and everyting after it,
    also removing the last '/' (or '\') and everything before it. *)
PROCEDURE AddLinkModExt*(name: ARRAY OF CHAR);
VAR s: ARRAY 256 OF CHAR;
  i, j: INTEGER;
BEGIN i := Strings.Length(name);
  REPEAT DEC(i) UNTIL (i = -1) OR (name[i] = '.');
  IF i # -1 THEN j := i;
    REPEAT DEC(j) UNTIL (j = -1) OR (name[j] = '/') OR (name[j] = '\');
    Strings.Extract(name, j + 1, i - j - 1, s); AddLinkMod(s)
  ELSE AddLinkMod(name)
  END
END AddLinkModExt;

PROCEDURE ClearLinkMods*;
BEGIN linkModCount := 0;
END ClearLinkMods;

PROCEDURE LinkToIndex*(yes: BOOLEAN);
BEGIN linkToIndex := yes
END LinkToIndex;

(** Language **)

PROCEDURE TryLoadLang(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN ok := FALSE;
  IF (lang[0] # 0X) & Lang.LangExists(lang) THEN
    Lang.SetLang(lang); ok := Lang.Done
  END
RETURN ok END TryLoadLang;

PROCEDURE LoadLang;
BEGIN
  IF ~TryLoadLang() THEN
    Env.GetLang(lang); lang[2] := 0X;
    IF ~TryLoadLang() THEN
      lang := defLang;
      IF ~TryLoadLang() THEN
        lang[0] := 0X;
        Out.String('Could not load language file.'); Out.Ln
      END
    END
  END
END LoadLang;

(** Text Output Routines **)

PROCEDURE WriteInt(i: INTEGER);
BEGIN Texts.WriteInt(W, i, 0)
END WriteInt;

PROCEDURE WriteChar(x: CHAR);
BEGIN Texts.Write(W, x)
END WriteChar;

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

PROCEDURE WriteExpr(s: ARRAY OF CHAR);
VAR i: INTEGER;
  x, q: CHAR;
  string: BOOLEAN;
BEGIN string := FALSE; i := 0; x := s[0];
  WHILE x # 0X DO
    IF string & (x = q) THEN string := FALSE; WriteChar(x); Write('</i>')
    ELSIF ~string & ((x = '"') OR (x = "'")) THEN
      string := TRUE; q := x; Write('<i>'); WriteChar(x)
    ELSIF (x = ' ') & (i # 0) & (s[i - 1] = ' ') THEN Write('&nbsp;')
    ELSE WriteChar(x)
    END;
    INC(i); x := s[i]
  END;
  IF string THEN Write('</i>') END
END WriteExpr;

PROCEDURE WriteExport(o: P.Object);
BEGIN
  IF showExportMarks & (o # NIL) & o.exported THEN
    Write('<span class="export">*</span>')
  END
END WriteExport;

PROCEDURE WriteParagraphs(s: ARRAY OF CHAR; marks: BOOLEAN);
VAR i: INTEGER;
  c: CHAR;
  closed, pre, code: BOOLEAN;
BEGIN
  i := 0; c := s[0]; pre := FALSE; code := FALSE;
  IF c # 0X THEN
    WriteLn('<p>'); closed := FALSE;
    IF marks THEN Write('<span class="mark">(*</span> ') END;
    WHILE c # 0X DO
      IF c = 0AX THEN WriteLn('');
        IF ~pre THEN WriteLn('</p>'); closed := TRUE END
      ELSIF (c = '`') & (i < LEN(s) - 4) &
            (s[i + 1] = '`') & (s[i + 2] = '`') & (pre OR (s[i + 3] = 0AX))
      THEN
        IF pre THEN WriteLn('</pre>'); closed := TRUE; pre := FALSE
        ELSE
          IF ~closed THEN WriteLn('</p>') END;
          WriteLn('<pre>'); closed := FALSE; pre := TRUE
        END;
        INC(i, 3);
        IF s[i - 1] = 0AX THEN INC(i) END
      ELSIF ~pre & (c = '`') & (s[i + 1] # '`') &
            ((i = 0) OR (s[i - 1] # '`')) THEN
        IF code THEN Write('</code>'); code := FALSE
        ELSE Write('<code>'); code := TRUE
        END
      ELSE
        IF closed THEN WriteLn('<p>'); closed := FALSE END;
        IF c = '<' THEN Texts.WriteString(W, '&lt;')
        ELSIF c = '>' THEN Texts.WriteString(W, '&gt;')
        ELSIF c = '&' THEN Texts.WriteString(W, '&amp;')
        ELSIF c = '"' THEN Texts.WriteString(W, '&quot;')
        ELSIF c = "'" THEN Texts.WriteString(W, '&#39;')
        ELSIF ~pre & (c = '-') & (s[i + 1] = '-') THEN
          Texts.WriteString(W, '&mdash;'); INC(i)
        ELSE Texts.Write(W, c)
        END
      END;
      INC(i); c := s[i]
    END;
    IF pre THEN WriteLn('</pre>') ELSIF code THEN WriteLn('</code>') END;
    IF ~closed THEN WriteLn('') END;
    IF marks THEN Write(' <span class="mark">*)</span>') END;
    IF ~closed THEN WriteLn('</p>') END
  END
END WriteParagraphs;

PROCEDURE WriteStyle;
VAR T2: Texts.Text;
  buf: Texts.Buffer;
  path: ARRAY 1024 OF CHAR;
BEGIN
  Env.GetAppDir(path);
  Strings.Append(styleFname, path);
  NEW(T2); Texts.Open(T2, path);
  IF T2.len # 0 THEN
    WriteLn('<style>');
    Texts.Append(TX, W.buf);
    NEW(buf); Texts.OpenBuf(buf);
    Texts.Save(T2, 0, T2.len, buf);
    Texts.Append(TX, buf);
    WriteLn(''); WriteLn('</style>')
  ELSE Out.String('Could not find stylesheet file "');
    Out.String(path); Out.String('".'); Out.Ln
  END
END WriteStyle;

(** HTML Printing Procedures **)

PROCEDURE PrintComment(comment: P.LongStr; marks: BOOLEAN);
BEGIN
  Write('<section class="comment">');
  WriteParagraphs(comment, marks);
  WriteLn('</section>')
END PrintComment;

(** If modName is an empty string, the index page is considered current *)
PROCEDURE PrintModIndex(modName: ARRAY OF CHAR; showIndex: BOOLEAN);
VAR i: INTEGER;
  s: ARRAY 64 OF CHAR;
BEGIN
  WriteLn('<ul class="modules-index">');
  Write('<li');
  IF modName[0] = 0X THEN Write(' class="cur"') END;
  Write('><a href="index.html">');
  Lang.Get('indexLink', s); Write(s); WriteLn('</a></li>');
  FOR i := 0 TO linkModCount - 1 DO
    Write('<li');
    IF linkMods[i] = modName THEN Write(' class="cur"') END;
    Write('><a href="'); Write(linkMods[i]); Write('.html">');
    Write(linkMods[i]); WriteLn('</a></li>')
  END;
  WriteLn('</ul>')
END PrintModIndex;

PROCEDURE OpenGroup(G: P.Group; ordinalConsts: BOOLEAN);
VAR s: ARRAY 256 OF CHAR;
BEGIN
  WriteLn('<article class="group">');
  Write('<h3 class="group-title">');
  IF G.name # '-' THEN Write(G.name) END;
  WriteLn('</h3>');
  PrintComment(G.comment, FALSE);
  IF ordinalConsts THEN
    WriteLn('<div class="ordinal-consts">');
    WriteLn('<table>');
    WriteLn('<thead><tr>');
    Write('<th class="name">');
    Lang.Get('tableColName', s); Write(s); WriteLn('</th>');
    Write('<th class="value">');
    Lang.Get('tableColValue', s); Write(s); WriteLn('</th>');
    Write('<th class="desc">');
    Lang.Get('tableColDesc', s); Write(s); WriteLn('</th>');
    WriteLn('</tr></thead><tbody>');
  ELSE
    WriteLn('<div class="group-content">')
  END
END OpenGroup;

PROCEDURE CloseGroup(ordinalConsts: BOOLEAN);
BEGIN
  IF ordinalConsts THEN WriteLn('</tbody></table></div>')
  ELSE WriteLn('</div>')
  END;
  WriteLn('</article>')
END CloseGroup;

PROCEDURE IsAlphanum(c: CHAR): BOOLEAN;
RETURN P.IsLetter(c) OR P.IsDec(c) END IsAlphanum;

(** First i characters of s is a module name that exists in linkMods *)
PROCEDURE IsLinkedMod(s: ARRAY OF CHAR; len: INTEGER): BOOLEAN;
VAR i: INTEGER;
z: ARRAY 256 OF CHAR;
BEGIN Strings.Extract(s, 0, len, z); i := 0;
WHILE (i # linkModCount) & (linkMods[i] # z) DO INC(i) END
RETURN i # linkModCount END IsLinkedMod;

PROCEDURE IsNameDeclared(s: ARRAY OF CHAR): BOOLEAN;
VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE (i # declNameCount) & (declNames[i] # s) DO INC(i) END
RETURN i # declNameCount END IsNameDeclared;

(** Writes `s`, and maybe adds <a href> around it to another module or
    to another place in this module *)
PROCEDURE PrintLink(s: ARRAY OF CHAR);
VAR i, j, k: INTEGER;
  written: BOOLEAN;
BEGIN written := FALSE;
  (* Find first '.', put in i *)
  i := 0; WHILE IsAlphanum(s[i]) DO INC(i) END;
  IF s[i] = '.' THEN (* First '.' found *)
    (* Find second '.', put in j *)
    j := i + 1; WHILE IsAlphanum(s[j]) DO INC(j) END;
    IF (s[j] = 0X) & IsLinkedMod(s, i) THEN (* No 2nd '.', all is alphanum *)
      Write('<a href="');
      FOR k := 0 TO i - 1 DO WriteChar(s[k]) END;
      Write('.html#');
      FOR k := i + 1 TO j - 1 DO WriteChar(s[k]) END;
      Write('">'); Write(s); Write('</a>'); written := TRUE
    END
  ELSIF (s[i] = 0X) & IsNameDeclared(s) THEN (* No '.' in s *)
    Write('<a href="#'); Write(s); Write('">'); Write(s); Write('</a>');
    written := TRUE
  END;
  IF ~written THEN Write(s) END
END PrintLink;

(** Prints a href to a module name *)
PROCEDURE PrintModLink(s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := 0; WHILE IsAlphanum(s[i]) DO INC(i) END;
  IF (s[i] = 0X) & IsLinkedMod(s, i) THEN
    Write('<a href="'); Write(s); Write('.html">'); Write(s); Write('</a>')
  ELSE Write(s)
  END
END PrintModLink;

PROCEDURE PrintIndent(n: INTEGER);
BEGIN
  WHILE n > 0 DO Write('&nbsp; '); DEC(n) END
END PrintIndent;

PROCEDURE PrintImport(I: P.Import; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  Write('<span class="import">');
  IF I.name # I.alias THEN
    Write('<span class="alias">'); Write(I.alias); Write('</span> := ')
  END;
  Write('<span class="name">'); PrintModLink(I.name); Write('</span></span>');
  IF ~isLastListItem THEN WriteLn(', ') END;
  isLastListItem := FALSE
END PrintImport;

PROCEDURE PrintOrdinalConst(C: P.Const);
BEGIN
  Write('<tr><td class="name">'); Write(C.name); WriteExport(C);
  WriteLn('</td><td class="value">');
  WriteExpr(C.value); WriteLn('</td><td class="desc">');
  PrintComment(C.comment, FALSE); WriteLn('</td></tr>')
END PrintOrdinalConst;

PROCEDURE PrintConst(C: P.Const; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  Write   ('<div class="anchor" id="'); Write(C.name); WriteLn('"></div>');
  Write   ('<article class="object const">');
  WriteLn ('  <div class="def">');
  Write   ('    <span class="name">'); Write(C.name);
  Write   ('</span>'); WriteExport(C); WriteLn(' =');
  Write('    <span class="value">'); WriteExpr(C.value); WriteLn('</span>;');
  WriteLn ('  </div>');
  PrintComment(C.comment, FALSE);
  WriteLn ('</article>')
END PrintConst;

PROCEDURE PrintList(L: P.List; indent: INTEGER; inlined: BOOLEAN);
VAR o: P.Object;
  ordinalConsts: BOOLEAN;
BEGIN
  IF (L # NIL) & (L.first # NIL) THEN
    ordinalConsts := (L IS P.Group) & L(P.Group).ordinalConsts &
                     (L.first # L.last);
    IF (L IS P.Group) & (L.name[0] # 0X) THEN
      OpenGroup(L(P.Group), ordinalConsts)
    END;
    o := L.first;
    WHILE o # NIL DO
      IF ordinalConsts THEN PrintOrdinalConst(o(P.Const))
      ELSE
        IF o = L.last THEN isLastListItem := TRUE END;
        PrintObject(o, indent, FALSE)
      END;
      o := o.next
    END;
    IF (L IS P.Group) & (L.name[0] # 0X) THEN
      CloseGroup(ordinalConsts)
    END
  END
END PrintList;

PROCEDURE PrintParam(par: P.Param; indent: INTEGER; inlined: BOOLEAN);
VAR tmp: BOOLEAN;
BEGIN tmp := isLastItem; isLastItem := FALSE;
  Write('<span class="param">');
  IF par.passed = P.byVar THEN
    Write('<span class="passed by-var">VAR</span>&nbsp;')
  END;
  Write('<span class="name">'); Write(par.name); Write('</span>');
  Write(': <span class="type">');
  PrintObject(par.type, indent, TRUE);
  IF ~tmp THEN WriteLn(';') END;
  Write('</span></span>')
END PrintParam;

PROCEDURE PrintVar(v: P.Var; indent: INTEGER; inlined: BOOLEAN);
VAR tmp: BOOLEAN;
BEGIN tmp := isLastItem; isLastItem := FALSE;
  IF inlined THEN
    Write('<span class="var">');
    PrintIndent(indent);
    Write('<span class="name">'); Write(v.name);
    Write('</span>'); WriteExport(v); Write(': <span class="type">');
    PrintObject(v.type, indent, TRUE);
    IF ~tmp THEN Write(';') END;
    Write(' &nbsp;</span></span>');
    PrintComment(v.comment, TRUE);
  ELSE
    Write   ('<div class="anchor" id="'); Write(v.name); WriteLn('"></div>');
    Write   ('<article class="object var">');
    WriteLn ('  <div class="def">');
    Write   ('    <span class="name">'); Write(v.name);
    WriteExport(v); WriteLn('</span>:');
    WriteLn ('    <span class="type">');
    PrintObject(v.type, indent, TRUE); WriteLn('</span>;');
    WriteLn ('  </div>');
    PrintComment(v.comment, FALSE);
    WriteLn ('</article>')
  END
END PrintVar;

PROCEDURE PrintType(T: P.Type; indent: INTEGER; inlined: BOOLEAN);
VAR x: P.Object;
BEGIN
  IF inlined THEN
    IF T.form = P.namedType THEN PrintLink(T.name)
    ELSIF T.form = P.arrayType THEN Write('ARRAY ');
      IF T.len[0] # 0X THEN Write(T.len); Write(' ') END;
      Write('OF '); PrintObject(T.base, indent, TRUE)
    ELSIF T.form = P.recordType THEN Write('RECORD');
      IF T.base # NIL THEN Write('(<span class="record-base">');
        PrintLink(T.base.name); Write('</span>)')
      END;
      x := T.fields.first;
      IF x # NIL THEN WriteLn('<span class="record-fields">') END;
      WHILE x # NIL DO
        IF x = T.fields.last THEN isLastItem := TRUE END;
        PrintObject(x, indent + 1, TRUE);
        x := x.next
      END;
      IF T.fields.first # NIL THEN WriteLn('</span>') END;
      Write(' END')
    ELSIF T.form = P.pointerType THEN Write('POINTER TO ');
      PrintObject(T.base, indent, TRUE)
    ELSIF T.form = P.procedureType THEN Write('PROCEDURE');
      x := T.fields.first;
      IF (x # NIL) OR (T.base # NIL) THEN Write(' (');
        WHILE x # NIL DO
          IF x = T.fields.last THEN isLastItem := TRUE END;
          PrintObject(x, indent, TRUE);
          x := x.next
        END;
        Write(')')
      END;
      IF T.base # NIL THEN
        Write(': '); PrintObject(T.base, indent, TRUE)
      END
    END
  ELSE
    Write   ('<div class="anchor" id="'); Write(T.name); WriteLn('"></div>');
    Write   ('<article class="object type">');
    WriteLn ('  <div class="def">');
    Write   ('    <span class="name">'); Write(T.name); Write('</span>');
    WriteExport(T); WriteLn(' =');
    WriteLn ('    <span class="typedef">');
    PrintObject(T.base, indent, TRUE); WriteLn('</span>;');
    WriteLn ('  </div>');
    PrintComment(T.comment, FALSE);
    WriteLn ('</article>');
  END
END PrintType;

PROCEDURE PrintProcedure(p: P.Procedure; indent: INTEGER; inlined: BOOLEAN);
VAR x: P.Object;
BEGIN
  Write   ('<div class="anchor" id="'); Write(p.name); WriteLn('"></div>');
  WriteLn ('<article class="object procedure">');
  WriteLn ('  <div class="def">');
  WriteLn ('    PROCEDURE');
  IF p.receiver # NIL THEN
    WriteLn('    <span class="receiver">');
    Write  ('      (<span class="name">'); Write(p.receiver.name);
    WriteLn('</span>:');
    PrintType(p.receiver.type, indent, TRUE);
    WriteLn(')');
    WriteLn('    </span>')
  END;
  Write('    ');
  IF p.external THEN Write('-') END;
  Write('<span class="name">'); Write(p.name);
  Write('</span>'); WriteExport(p);
  x := p.params.first;
  IF (x # NIL) OR (p.returnType # NIL) THEN
    Write('<span class="params">');
    IF (x # NIL) OR (p.returnType # NIL) THEN Write(' (');
      WHILE x # NIL DO
        IF x = p.params.last THEN isLastItem := TRUE END;
        PrintObject(x, indent, TRUE);
        x := x.next
      END;
      Write(')')
    END;
    IF p.returnType # NIL THEN
      Write(': '); PrintType(p.returnType, indent, TRUE)
    END;
    Write('</span>')
  END;
  Write(';');
  IF p.external THEN
    WriteLn(''); Write('<div class="value"><i>&nbsp; ');
    Write("'"); Write(p.code); Write("'"); WriteLn('</i></div>')
  END;
  WriteLn('</div>');
  PrintComment(p.comment, FALSE);
  WriteLn('</article>')
END PrintProcedure;

PROCEDURE BigTitle(text, anchor: ARRAY OF CHAR);
BEGIN
  Write   ('<div class="anchor" id="'); Write(anchor); WriteLn('"></div>');
  WriteLn3('<h2 class="heading">', text, '</h2>')
END BigTitle;

PROCEDURE Title(modName: ARRAY OF CHAR; index: BOOLEAN);
VAR s: ARRAY 64 OF CHAR;
BEGIN
  IF index THEN
    Lang.Get('indexTitleBefore', s); Write(s); Write(modName);
    Lang.Get('indexTitleAfter', s); Write(s)
  ELSE
    Lang.Get('titleBefore', s); Write(s); Write(modName);
    Lang.Get('titleAfter', s); Write(s)
  END
END Title;

PROCEDURE Heading(modName: ARRAY OF CHAR; index: BOOLEAN);
VAR s: ARRAY 64 OF CHAR;
BEGIN
  IF ~index THEN Lang.Get('headingBefore', s); Write(s) END;
  Write('<span class="module-name">'); Write(modName);
  IF ~index THEN Lang.Get('headingAfter', s); Write(s) END;
  Write('</span> <span class="subtitle">');

  IF index THEN Lang.Get('indexHeadingSubtitle', s); Write(s)
  ELSE Lang.Get('headingSubtitle', s); Write(s)
  END;
  WriteLn('</span>')
END Heading;

PROCEDURE Header(modName: ARRAY OF CHAR; index: BOOLEAN);
VAR s: ARRAY 256 OF CHAR;
BEGIN
  WriteLn('<!DOCTYPE html>');
  WriteLn('<html>');
  WriteLn('<head>');
  WriteLn('<meta charset="utf-8">');
  WriteLn('<title>');
  Title(modName, index);
  WriteLn('</title>');
  Write  ('<meta name="viewport" content="');
  WriteLn('width=device-width,initial-scale=1.0">');
  WriteLn('</head>');
  IF index THEN WriteLn('<body class="index">') ELSE WriteLn('<body>') END;
  WriteLn('<header class="header"><div class="inner">');

  Write('<h1>');
  Heading(modName, index);
  WriteLn('</h1>');

  IF ~index THEN
    WriteLn('<nav class="module-menu">');
    PrintModIndex(modName, TRUE);
    WriteLn('</nav>')
  END;
  WriteLn('</div></header>');
  WriteLn('<main class="main"><div class="inner">')
END Header;

PROCEDURE PrintColorValue(s: ARRAY OF CHAR);
VAR i: INTEGER;
  PROCEDURE Q(s: ARRAY OF CHAR; i: INTEGER): INTEGER;
  RETURN P.FromHex(s[i]) * 16 + P.FromHex(s[i + 1]) END Q;
BEGIN
  IF Strings.Length(s) = 8 THEN Write('rgba(');
    FOR i := 0 TO 4 BY 2 DO WriteInt(Q(s, i)); Write(', ') END;
    i := Q(s, 6) * 100 DIV 256;
    IF i = 255 THEN Write('1.0')
    ELSE Write('0.'); WriteInt(i DIV 10 MOD 10); WriteInt(i MOD 10)
    END;
    Write(')')
  ELSE Write('#'); Write(s)
  END
END PrintColorValue;

PROCEDURE PrintColor(i: INTEGER; var, fgOrBg: ARRAY OF CHAR);
BEGIN
  Write('  --'); Write(var); Write('-'); Write(fgOrBg);
  Write(': '); PrintColorValue(palette[i]); WriteLn(';')
END PrintColor;

PROCEDURE PrintColors(i: INTEGER; var: ARRAY OF CHAR);
BEGIN PrintColor(i, var, 'bg');
  PrintColor(i + 1, var, 'fg')
END PrintColors;

PROCEDURE PrintPalette;
VAR i: INTEGER;
BEGIN
  WriteLn('<style> /* Palette */');
  WriteLn(':root {');
  PrintColors(main,    'main');
  PrintColors(head,    'head');
  PrintColors(head2,   'head2');
  PrintColors(tab,     'tab');
  PrintColors(tabRow,  'tab-row');
  PrintColors(tabHead, 'tab-head');
  PrintColors(title,   'title');
  PrintColors(high,    'high');
  PrintColors(box,     'box');
  PrintColors(comment, 'comment');
  WriteLn('}');
  WriteLn('</style>')
END PrintPalette;

PROCEDURE PrintDate;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  Time.GetDateStr(s);
  Write(s)
END PrintDate;

PROCEDURE Footer;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  WriteLn('</div></main><footer class="footer"><div class="inner">');
  Write('<p>'); Lang.Get('generatedMsg', s); Write(s); WriteLn('</p>');
  Write('<p class="date">'); PrintDate; WriteLn('</p>');
 
  WriteLn('</div></footer>');

  IF ~externalStyle THEN WriteStyle
  ELSE WriteLn('<link rel="stylesheet" href="style.css">')
  END;
  PrintPalette;

  WriteLn('</body></html>')
END Footer;

PROCEDURE PrintSection(L: P.List; name: ARRAY OF CHAR; showEmpty: BOOLEAN);
VAR s: ARRAY 64 OF CHAR;
  empty: BOOLEAN;
BEGIN
  empty := ~((L # NIL) & (L.first # NIL) &
             (~(L.first IS P.Group) OR (L.first(P.Group).first # NIL)));

  IF ~empty OR showEmpty THEN
    Write  ('<article class="list-wrap '); Write(name); WriteLn('-list">');
    Lang.Get(name, s); BigTitle(s, name);
    WriteLn('  <section class="list-items">');
    IF empty THEN
      Write('  <section class="empty-section">');
      Lang.Get('sectionEmpty', s); Write(s); WriteLn('</section>')
    ELSE PrintList(L, 0, FALSE)
    END;
    WriteLn('  </section>');
    WriteLn('</article>')
  END
END PrintSection;

PROCEDURE DeclareNamesInSection(L: P.List);
VAR g, p: P.Object;
BEGIN
  g := L.first;
  WHILE g # NIL DO
    p := g(P.Group).first;
    WHILE p # NIL DO
      IF declNameCount # LEN(declNames) THEN
        Strings.Copy(p.name, declNames[declNameCount]);
        INC(declNameCount)
      END;
      p := p.next
    END;
    g := g.next
  END
END DeclareNamesInSection;

PROCEDURE DeclareNames(M: P.Module);
BEGIN
  declNameCount := 0;
  DeclareNamesInSection(M.consts);
  DeclareNamesInSection(M.types)
END DeclareNames;

PROCEDURE PrintBody(M: P.Module);
BEGIN
  PrintComment(M.comment, FALSE);
  PrintSection(M.imports, 'import', FALSE);
  PrintSection(M.consts, 'constants', TRUE);
  PrintSection(M.types, 'types', TRUE);
  PrintSection(M.vars, 'variables', TRUE);
  PrintSection(M.procedures, 'procedures', TRUE);
END PrintBody;

PROCEDURE PrintIndexComment;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  Write('<h2>');
  Lang.Get('overview', s); Write(s);
  WriteLn('</h2>');
  PrintComment(indexComment, FALSE)
END PrintIndexComment;

PROCEDURE RunTag(M: P.Module; tag: ARRAY OF CHAR);
BEGIN
  IF tag = 'TITLE' THEN
    IF renderingIndex THEN Title(indexTitle, TRUE)
    ELSE Title(M.name, FALSE)
    END
  ELSIF tag = 'HEADING' THEN
    IF renderingIndex THEN Heading(indexTitle, TRUE)
    ELSE Heading(M.name, FALSE)
    END
  ELSIF tag = 'MENU' THEN
    IF renderingIndex THEN PrintModIndex('', FALSE)
    ELSE PrintModIndex(M.name, TRUE)
    END
  ELSIF tag = 'BODY' THEN
    IF renderingIndex THEN PrintIndexComment
    ELSE PrintBody(M)
    END
  ELSIF tag = 'BODYCLASSES' THEN
    IF renderingIndex THEN Write('index') END
  ELSIF tag = 'DATE' THEN PrintDate
  ELSE Write('{{#ERROR:Uknown tag:'); Write(tag); Write('}}')
  END
END RunTag;

PROCEDURE Trim(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  (* Remove leading spaces/tabs *)
  i := 0; WHILE (s[i] = ' ') OR (s[i] = TAB) DO INC(i) END;
  Strings.Delete(s, 0, i);

  (* Remove trailing spaces/tabs *)
  i := Strings.Length(s) - 1;
  IF i # 0 THEN
    WHILE (i # -1) & ((s[i] = ' ') OR (s[i] = TAB)) DO DEC(i) END;
    Strings.Delete(s, i + 1, LEN(s))
  END
END Trim;

PROCEDURE ReadTag(M: P.Module; VAR pos: INTEGER);
VAR i: INTEGER;
  c: CHAR;
  wasBrace: BOOLEAN;
  tag: ARRAY 64 OF CHAR;
BEGIN
  i := pos; wasBrace := FALSE;
  IF tpl[i + 1] # 0X THEN
    REPEAT
      INC(i); c := tpl[i];
      IF c = '}' THEN
        IF wasBrace THEN
          Strings.Extract(tpl, pos + 1, i - pos - 2, tag);
          Trim(tag); Strings.Cap(tag);
          RunTag(M, tag);
          c := 0X
        ELSE wasBrace := TRUE
        END
      ELSIF ~(('a' <= c) & (c <= 'z') OR ('A' <= c) & (c <= 'Z') OR
              (c = TAB) OR (c = ' '))
      THEN c := 0X; Write('{{#ERROR:Bad tag}}'); i := pos
      END
    UNTIL c = 0X;
  END;
  pos := i
END ReadTag;

PROCEDURE PrintTemplate(M: P.Module; index: BOOLEAN);
VAR i: INTEGER;
  c: CHAR;
  wasBrace: BOOLEAN;
BEGIN
  renderingIndex := index;
  i := 0; c := tpl[0]; wasBrace := FALSE;
  WHILE c # 0X DO
    IF c = '{' THEN
      IF wasBrace THEN ReadTag(M, i); c := tpl[i]; wasBrace := FALSE
      ELSE wasBrace := TRUE
      END
    ELSE
      IF wasBrace THEN Write('{'); wasBrace := FALSE END;
      WriteChar(c)
    END;
    INC(i); c := tpl[i]
  END
END PrintTemplate;

PROCEDURE PrintModule(M: P.Module; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  DeclareNames(M);
  showExportMarks := ~M.exportedOnly;
  IF tpl[0] = 0X THEN
    Header(M.name, FALSE);
    PrintBody(M);
    Footer
  ELSE PrintTemplate(M, FALSE)
  END
END PrintModule;

PROCEDURE PrintObject0(o: P.Object; indent: INTEGER; inlined: BOOLEAN);
BEGIN
  IF o = NIL THEN WriteLn('NIL')
  ELSIF o IS P.Module THEN PrintModule(o(P.Module), indent, inlined)
  ELSIF o IS P.Import THEN PrintImport(o(P.Import), indent, inlined)
  ELSIF o IS P.Const THEN PrintConst(o(P.Const), indent, inlined)
  ELSIF o IS P.Type THEN PrintType(o(P.Type), indent, inlined)
  ELSIF o IS P.Var THEN PrintVar(o(P.Var), indent, inlined)
  ELSIF o IS P.Procedure THEN PrintProcedure(o(P.Procedure), indent, inlined)
  ELSIF o IS P.Param THEN PrintParam(o(P.Param), indent, inlined)
  ELSIF o IS P.List THEN PrintList(o(P.List), indent, inlined)
  ELSE Out.String('?')
  END
END PrintObject0;

(** Generator Settings **)

PROCEDURE SetExternalStyle*(yes: BOOLEAN);
BEGIN externalStyle := yes
END SetExternalStyle;

PROCEDURE SetLang*(L: ARRAY OF CHAR);
BEGIN Strings.Copy(L, lang)
END SetLang;

(** Palette **)

(** Used by SetPalette *)
PROCEDURE ClearColors;
BEGIN curColor := 0
END ClearColors;

(** Used by SetPalette. First must call ClearColors, then one or more calls
    to SetColors is possible *)
PROCEDURE SetColors(s: ARRAY OF CHAR);
VAR i, begin: INTEGER;
BEGIN
  i := 0;
  WHILE s[i] # 0X DO
    WHILE (s[i] # 0X) & (s[i] < '0') DO INC(i) END; (* Skip separators *)
    begin := i;
    WHILE s[i] >= '0' DO INC(i) END; (* Stop on 0X, ' ', or ',' *)
    Strings.Extract(s, begin, i - begin, palette[curColor]);
    INC(curColor)
  END
END SetColors;

PROCEDURE SetPalette*(pal: ARRAY OF CHAR);
BEGIN ClearColors;
  IF pal = defPal THEN
    SetColors('FBC5AA-12365D,12365D-FFF,93B2D3-3D74AC,FFF-000');
    SetColors('FFBF44-B91E0C,B91E0C-FFF,12365D-FFF,872D0C-277FC0');
    SetColors('00000024-808080,D1702C-2D5E90')
  ELSIF pal = 'horror' THEN
    SetColors('AFF-00C,C00-FE0,FA0-FCC,0C0-0F0,00F-0FF');
    SetColors('606-F8F,0CC-066,833-0F0,0000FFC0-F00,F88-88F')
  ELSIF pal = 'bw' THEN
    SetColors('FFF-000,FFF-000,000-000,FFF-000,FFF-000');
    SetColors('FFF-000,000-FFF,000-000,FFF-FFF,888-000')
  ELSE Out.String('Palette "'); Out.String(pal);
    Out.String('" does not exist.'); Out.Ln;
    SetPalette(defPal)
  END
END SetPalette;

(** Set template HTML-file *)
PROCEDURE SetTemplate*(fname: ARRAY OF CHAR);
VAR T: Texts.Text;
  R: Texts.Reader;
  i: INTEGER;
  c: CHAR;
BEGIN
  NEW(T); Texts.Open(T, fname); i := 0;
  IF T.len # 0 THEN
    Texts.OpenReader(R, T, 0);
    Texts.Read(R, c);
    WHILE ~R.eot & (i # LEN(tpl) - 1) DO
      tpl[i] := c; INC(i);
      Texts.Read(R, c)
    END
  END;
  tpl[i] := 0X
END SetTemplate;

(** Main procedure *)
PROCEDURE Save*(module: P.Module; fname: ARRAY OF CHAR): BOOLEAN;
BEGIN
  IF palette[0] = 0X THEN SetPalette(defPal) END;
  LoadLang; NEW(TX); Texts.Open(TX, ''); Texts.OpenWriter(W);
  isLastItem := FALSE; isLastListItem := FALSE;
  PrintObject(module, 0, FALSE);
  Texts.Append(TX, W.buf); Texts.Close(TX, fname)
RETURN TRUE END Save;

PROCEDURE CreateIndex*(title, comment, fname: ARRAY OF CHAR): BOOLEAN;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  NEW(TX); Texts.Open(TX, ''); Texts.OpenWriter(W);

  IF tpl[0] = 0X THEN
    Header(title, TRUE);

    Write('<h2>');
    Lang.Get('indexHeading', s); Write(s);
    WriteLn('</h2>');
    PrintModIndex('', FALSE);

    Write('<h2>');
    Lang.Get('overview', s); Write(s);
    WriteLn('</h2>');
    PrintComment(comment, FALSE);

    Footer
  ELSE
    Strings.Copy(title, indexTitle);
    Strings.Copy(comment, indexComment);
    PrintTemplate(NIL, TRUE)
  END;
  Texts.Append(TX, W.buf); Texts.Close(TX, fname)
RETURN TRUE END CreateIndex;

BEGIN
  PrintObject := PrintObject0;
  externalStyle := FALSE; linkToIndex := TRUE;
  lang[0] := 0X; palette[0] := 0X; tpl[0] := 0X
END AutodocHtml.
