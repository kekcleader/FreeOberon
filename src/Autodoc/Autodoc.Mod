MODULE Autodoc;
IMPORT Files, Texts, Out, Args, Strings, Platform,
  P := AutodocParser, H := AutodocHtml;

CONST
  version = '1.0.0-alpha.1';
  year = 2022;

  delim = Platform.PathDelimiter;

TYPE
  Module* = P.Module;

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
  (*Out.String(' (name=');Out.String(name);Out.Ln;*)
  Strings.Append(name, out);
  Strings.Append('.html', out);
  (*Out.String(in);Out.Ln;  Out.String('   -> ');Out.String(out);Out.Ln;*)
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
  Out.String(' { "-o" outputPath | "--lang" code | sourceFile}'); Out.Ln; Out.Ln;
  Out.String('outputPath is a file name if a single source file is given.');
  Out.Ln;
  Out.String('outputPath is a directory if many source files are given.');
  Out.Ln; Out.Ln;
  Out.String('Examples:'); Out.Ln;
  Out.String('  '); Out.String(s);
  Out.String(' -o Apples.Mod'); Out.Ln;
  Out.String('  '); Out.String(s);
  Out.String(' -o doc.html --lang ru Apples.Mod'); Out.Ln;
  Out.String('  '); Out.String(s);
  Out.String(' -o docs Fruits.Mod Apples.Mod'); Out.Ln
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

PROCEDURE Do;
VAR i: INTEGER;
  out, s: ARRAY 256 OF CHAR;
  fnames: ARRAY 64, 256 OF CHAR;
  fnameCount: INTEGER;
BEGIN
  IF Args.Count = 0 THEN
    Usage
  ELSE
    out[0] := 0X; i := 1; fnameCount := 0;
    WHILE i <= Args.Count DO
      Args.Get(i, s);
      IF s = '-o' THEN (* Output file or dir *)
        IF i < Args.Count THEN INC(i); Args.Get(i, out) END
      ELSIF s = '-a' THEN (* All *)
        P.SetExportedOnly(FALSE)
      ELSIF s = '--debug' THEN
        P.SetDebug(TRUE)
      ELSIF (s = '--inline-style') OR (s = '-i') THEN
        H.SetInlineStyle(TRUE)
      ELSIF s = '--lang' THEN (* Output language *)
        IF i < Args.Count THEN INC(i); Args.Get(i, s); H.SetLang(s) END
      ELSE (* On of the file names with Oberon modules *)
        IF fnameCount < LEN(fnames) THEN
          Strings.Copy(s, fnames[fnameCount]);
          INC(fnameCount)
        END
      END;
      INC(i)
    END;
    IF fnameCount = 1 THEN (* Single file given *)
      IF out[0] = 0X THEN FnameToHtml(fnames[0], out) END;
      HandleFile(fnames[0], out)
    ELSE (* Multiple file given, treat "-o" parameter as directory *)
      FOR i := 0 TO fnameCount - 1 DO
        HandleFileToDir(fnames[i], out)
      END
    END
  END
END Do;

BEGIN
  Do
END Autodoc.
