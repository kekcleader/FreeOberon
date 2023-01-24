MODULE Autodoc;
IMPORT Files, Texts, Out, Args, Strings, Platform, Dir,
  P := AutodocParser, H := AutodocHtml;

CONST
  version = '1.0.0-alpha.1';
  year = 2023;

  delim = Platform.PathDelimiter;

TYPE
  Module* = P.Module;

VAR
  indexTitle: ARRAY 256 OF CHAR;
  indexComment: P.LongStr;

PROCEDURE OpenFile(fname: ARRAY OF CHAR; VAR r: Files.Rider): BOOLEAN;
VAR F: Files.File;
BEGIN F := Files.Old(fname);
  IF F # NIL THEN Files.Set(r, F, 0) END
RETURN F # NIL END OpenFile;

PROCEDURE HandleFile*(in, out: ARRAY OF CHAR);
VAR err: ARRAY 1024 OF CHAR;
  r: Files.Rider;
  module: Module;
BEGIN
  IF OpenFile(in, r) THEN
    P.SetFname(in);
    module := P.ParseModule(r, err);
    IF module # NIL THEN
      IF indexTitle[0] = 0X THEN Strings.Copy(module.name, indexTitle) END;
      IF indexComment[0] = 0X THEN
        Strings.Copy(module.comment, indexComment)
      END;
      IF H.Save(module, out) THEN
        Out.String('## Created "'); Out.String(out);
        Out.String('".'); Out.Ln
      ELSE
        Out.String('## Error saving file "'); Out.String(out);
        Out.String('".'); Out.Ln
      END
    ELSE
      Out.String('## Error parsing file "');
      Out.String(in); Out.String('".'); Out.Ln
    END
  ELSE
    Out.String('## Error: Could not open file "');
    Out.String(in); Out.String('".'); Out.Ln
  END
END HandleFile;

(** Gets file name without path or extension.
    Example: 'a/b/c.txt' -> 'c' *)
PROCEDURE GetBaseName(s: ARRAY OF CHAR; VAR name: ARRAY OF CHAR);
VAR i, j, len: INTEGER;
BEGIN
  (* len := Length of s *)
  len := 0; WHILE s[len] # 0X DO INC(len) END;
  (* j := position of last '.' in s, or -1 *)
  j := len - 1; WHILE (j # -1) & (s[j] # '.') DO DEC(j) END;
  (* i := position of last slash in s, or 0 *)
  i := len; WHILE (i # -1) & (s[i] # '/') & (s[i] # '\') DO DEC(i) END;
  INC(i);
  IF j < i THEN j := len END;
  Strings.Extract(s, i, j - i, name)
END GetBaseName;

PROCEDURE HandleFileToDir*(in, dir: ARRAY OF CHAR);
VAR name, out: ARRAY 512 OF CHAR;
  len: INTEGER;
BEGIN
  out := dir;
  len := Strings.Length(out);
  IF (len # 0) & (out[len - 1] # '/') & (out[len - 1] # '\') THEN
    Strings.Append(delim, out)
  END;
  GetBaseName(in, name);
  Strings.Append(name, out);
  Strings.Append('.html', out);
  HandleFile(in, out)
END HandleFileToDir;

PROCEDURE Usage;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  Out.String('Free Oberon AutoDoc tool version ');
  Out.String(version); Out.Ln;
  Out.String('Copyright (c) 2022-'); Out.Int(year, 0);
  Out.String(' by Arthur Yefimov and others.'); Out.Ln;
  Out.String('Usage:'); Out.Ln; Args.Get(0, s);
  Out.String('  '); Out.String(s);
  Out.String(' { "-o" outputPath | "--lang" code | otherParam | sourceFile}');
  Out.Ln; Out.Ln;
  Out.String('outputPath may be a file name or a directory. It must be');
  Out.Ln;
  Out.String('           a directory if several source files are given.');
  Out.Ln;
  Out.String('Other parameters:'); Out.Ln;
  Out.String('-a ....... Get all objects, not only exported'); Out.Ln;
  Out.String('-k ....... Keep module import aliases'); Out.Ln;
  Out.String('--external-style   or'); Out.Ln;
  Out.String('-e ....... Do not put CSS in HTML, link with style.css'); Out.Ln;
  Out.String('-L ....... Add a directory with modules to link to in HTML.');
  Out.Ln;
  Out.String('           Put extension in the end to change it: Program/.cp');
  Out.Ln;
  Out.String('--pal <pal> .............. Supply a named palette.'); Out.Ln;
  Out.String('  <pal> is one of: default, bw, horror'); Out.Ln;
  Out.String('--template <filename> .... Use <filename> as HTML-file'); Out.Ln;
  Out.String('  with placeholders: %TITLE% %HEADING% %MENU% %BODY% %DATE%');
  Out.Ln;
  Out.String('--debug .................. Produce debug output in console.');
  Out.Ln; Out.Ln; Out.Ln;
  Out.String('Examples:'); Out.Ln;
  Out.String('  '); Out.String(s);
  Out.String(' -o Apples.Mod'); Out.Ln;
  Out.String('  '); Out.String(s);
  Out.String(' -o doc.html --lang ru Apples.Mod'); Out.Ln;
  Out.String('  '); Out.String(s);
  Out.String(' -o docs/ Fruits.Mod Apples.Mod'); Out.Ln
END Usage;

(** Changes extension of the file to '.html'. Puts result is out. *)
PROCEDURE FnameToHtml(fname: ARRAY OF CHAR; VAR out: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := Strings.Length(fname);
  IF i # 0 THEN
    (* Find last '.' in fname *)
    DEC(i); WHILE (i # -1) & (fname[i] # '.') DO DEC(i) END;
    IF i # -1 THEN Strings.Extract(fname, 0, i, out)
    ELSE Strings.Copy(fname, out)
    END;
    Strings.Append('.html', out)
  ELSE
    out[0] := 0X
  END
END FnameToHtml;

(** Returns TRUE if s ends with with. *)
PROCEDURE EndsWith(s, with: ARRAY OF CHAR): BOOLEAN;
VAR i, j: INTEGER;
BEGIN
  i := 0; WHILE s[i] # 0X DO INC(i) END;
  j := 0; WHILE with[j] # 0X DO INC(j) END;
  IF i >= j THEN
    REPEAT DEC(i); DEC(j) UNTIL (j = -1) OR (s[i] # with[j])
  END
RETURN j = -1 END EndsWith;

(** s can be in form of 'Dir', 'Dir/' or 'Dir/*.cp' *)
PROCEDURE ParseLinkDir(s: ARRAY OF CHAR);
VAR r: Dir.Rec;
  z: ARRAY 256 OF CHAR; (* Copy of s *)
  ext: ARRAY 32 OF CHAR; (* Custom file extension, i.e. '.Mod' *)
  extLen, i: INTEGER;
  ok: BOOLEAN;
BEGIN Strings.Copy(s, z); ok := TRUE; ext := '.Mod';
  i := 0; WHILE (z[i] # 0X) & ~((z[i] = '/') & (z[i + 1] = '.')) DO INC(i) END;
  IF z[i] # 0X THEN
    IF z[i + 2] # 0X THEN
      Strings.Extract(z, i + 1, LEN(ext), ext);
      z[i] := 0X
    END
  END;
  extLen := Strings.Length(ext);
  IF Dir.IsDir(z) THEN
    Dir.First(r, z);
    WHILE ~r.eod DO
      IF (r.name[0] # '.') & EndsWith(r.name, ext) THEN
        Strings.Copy(r.name, z);
        z[Strings.Length(z) - extLen] := 0X;
        H.AddLinkMod(z)
      END;
      Dir.Next(r)
    END
  END
END ParseLinkDir;

PROCEDURE CreateIndex*(title, comment, out: ARRAY OF CHAR): BOOLEAN;
VAR len: INTEGER;
  s: ARRAY 4096 OF CHAR;
  ok: BOOLEAN;
BEGIN
  Strings.Copy(out, s);
  len := Strings.Length(s);
  IF (len # 0) & (s[len - 1] # '/') & (s[len - 1] # '\') THEN
    Strings.Append(delim, s)
  END;
  Strings.Append('index.html', s);

  IF H.CreateIndex(title, comment, s) THEN
    ok := TRUE;
    Out.String('## Created "'); Out.String(s); Out.String('".'); Out.Ln
  ELSE ok := FALSE
  END
RETURN ok END CreateIndex;

PROCEDURE AddFname(VAR m: ARRAY OF ARRAY OF CHAR; VAR len: INTEGER;
  s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := 0; (* Search for duplicate *)
  WHILE (i # len) & (m[i] # s) DO INC(i) END;
  IF i = len THEN Strings.Copy(s, m[i]); INC(len) END
END AddFname;

PROCEDURE Do;
VAR i, count, len: INTEGER;
  out, s: ARRAY 256 OF CHAR;
  fnames: ARRAY 64, 256 OF CHAR;
  fnameCount: INTEGER;
  createIndex: BOOLEAN;
BEGIN
  count := Args.Count();
  IF count = 0 THEN
    Usage
  ELSE
    out[0] := 0X; i := 1; fnameCount := 0;
    indexTitle[0] := 0X; indexComment[0] := 0X;
    H.ClearLinkMods; createIndex := TRUE;
    WHILE i <= count DO
      Args.Get(i, s);
      IF s = '-o' THEN (* Output file or dir *)
        IF i < count THEN INC(i); Args.Get(i, out) END
      ELSIF s = '-L' THEN (* Link directory *)
        IF i < count THEN INC(i); Args.Get(i, s); ParseLinkDir(s) END
      ELSIF s = '-a' THEN (* All *)
        P.SetExportedOnly(FALSE)
      ELSIF s = '-k' THEN (* Keep module aliases *)
        P.SetKeepAliases(TRUE)
      ELSIF s = '--debug' THEN
        P.SetDebug(TRUE)
      ELSIF (s = '--external-style') OR (s = '-e') THEN
        H.SetExternalStyle(TRUE)
      ELSIF (s = '--no-index') OR (s = '-n') THEN
        createIndex := FALSE
      ELSIF (s = '--title') OR (s = '-t') THEN
        IF i < count THEN INC(i); Args.Get(i, indexTitle); END
      ELSIF s = '--pal' THEN
        IF i < count THEN INC(i); Args.Get(i, s); H.SetPalette(s) END
      ELSIF s = '--template' THEN (* Template HTML file *)
        IF i < count THEN INC(i); Args.Get(i, s); H.SetTemplate(s) END
      ELSIF s = '--lang' THEN (* Output language *)
        IF i < count THEN
          INC(i); Args.Get(i, s); P.SetLang(s); H.SetLang(s)
        END
      ELSIF fnameCount < LEN(fnames) THEN (* One of the module file names *)
        AddFname(fnames, fnameCount, s); H.AddLinkModExt(s)
      END;
      INC(i)
    END;
    len := Strings.Length(out);
    IF fnameCount = 0 THEN
      Out.String('No files supplied.'); Out.Ln
    ELSIF (fnameCount > 1) OR
          (len # 0) & ((out[len - 1] = '/') OR (out[len - 1] = '\')) OR
          Dir.IsDir(out)
    THEN (* treat "-o" parameter as directory *)
      IF Dir.IsDir(out) THEN
        FOR i := 0 TO fnameCount - 1 DO
          HandleFileToDir(fnames[i], out)
        END;
        IF createIndex & ~CreateIndex(indexTitle, indexComment, out) THEN
          Out.String('Could not create an index file.'); Out.Ln
        END
      ELSE
        Out.String('Directory does not exist: "'); Out.String(out);
        Out.String('".'); Out.Ln
      END
    ELSE (* Single file given and "-o" is a file name *)
      IF out[0] = 0X THEN FnameToHtml(fnames[0], out) END;
      HandleFile(fnames[0], out)
    END
  END
END Do;

BEGIN
  Do
END Autodoc.
