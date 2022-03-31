MODULE FoStrings;
IMPORT Strings, Texts, Int, Dir, Env, Out;

CONST
  maxErrors* = 500;
  maxStrings* = 2000;
  keyLen* = 128;
  strLen* = 128;

TYPE String* = ARRAY strLen OF CHAR;
  Pair = RECORD
    key: ARRAY keyLen OF CHAR;
    value: ARRAY strLen OF CHAR
  END;

VAR lang*: ARRAY 6 OF CHAR;
  errorStr: ARRAY maxErrors OF String;
  strings: ARRAY maxStrings OF Pair;
  nofstrings: INTEGER; (* Actual length of strings *)

PROCEDURE Get*(key: ARRAY OF CHAR; VAR value: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (i # nofstrings) & (strings[i].key # key) DO INC(i) END;
  IF i # nofstrings THEN Strings.Copy(strings[i].value, value)
  ELSE Strings.Copy(key, value); Strings.Insert('#', 0, value)
  END
END Get;

PROCEDURE Append*(key: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR);
VAR s: ARRAY strLen OF CHAR;
BEGIN Get(key, s); Strings.Append(s, dest)
END Append;

PROCEDURE GetErrorStr*(err: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN
  IF (0 <= err) & (err < LEN(errorStr)) THEN Strings.Copy(errorStr[err], s)
  ELSE s := 'Text of error #'; Int.Append(err, s); Strings.Append('.', s)
  END
END GetErrorStr;

PROCEDURE MakeErrorStr*(err: INTEGER; VAR s: ARRAY OF CHAR);
VAR z: ARRAY 256 OF CHAR;
BEGIN
  GetErrorStr(err, z);
  s := '#';
  Int.Append(err, s);
  Strings.Append(' ', s);
  Strings.Append(z, s)
END MakeErrorStr;

PROCEDURE Clear;
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(errorStr) - 1 DO
    errorStr[i] := 'STR#';
    Int.Append(i, errorStr[i])
  END
END Clear;

PROCEDURE GetLangFname(lang: ARRAY OF CHAR; VAR fname: ARRAY OF CHAR);
BEGIN
  Env.GetAppDir(fname); Strings.Append('Data/Texts/', fname);
  Strings.Append(lang, fname); Strings.Append('.dat', fname)
END GetLangFname;

PROCEDURE LoadStrings;
VAR T: Texts.Text;
  i: INTEGER;
  ok: BOOLEAN;
  S: Texts.Scanner;
  fname: ARRAY 256 OF CHAR;
  key: ARRAY 64 OF CHAR;
BEGIN
  Clear;
  GetLangFname(lang, fname);
  NEW(T); Texts.Open(T, fname);
  Texts.OpenScanner(S, T, 0);
  Texts.Scan(S); ok := TRUE;
  WHILE ~S.eot & ok DO ok := FALSE;
    IF S.class = Texts.Int THEN i := S.i; Texts.Scan(S);
      IF (S.class = Texts.String) & (0 <= i) & (i < LEN(errorStr)) &
         (S.len < LEN(errorStr[0]) - 1)
      THEN Strings.Copy(S.s, errorStr[i]); ok := TRUE
      END
    ELSIF (S.class = Texts.Name) & (S.len < LEN(key) - 1) THEN
      Strings.Copy(S.s, key); Texts.Scan(S);
      IF (S.class = Texts.String) & (0 <= i) & (i < LEN(strings)) &
         (S.len < LEN(strings[0].value) - 1)
      THEN
        IF nofstrings < LEN(strings) THEN ok := TRUE;
          Strings.Copy(key, strings[nofstrings].key);
          Strings.Copy(S.s, strings[nofstrings].value);
          INC(nofstrings)
        ELSE Out.String('Too many strings in a language file.'); Out.Ln
        END
      END
    END;
    Texts.Scan(S)
  END;
  IF ~ok THEN
    Out.String('Bad format of "'); Out.String(fname);
    Out.String('". Line '); Out.Int(S.line, 0); Out.Ln
  END
END LoadStrings;

PROCEDURE LangExists*(language: ARRAY OF CHAR): BOOLEAN;
VAR fname: ARRAY 256 OF CHAR;
BEGIN GetLangFname(language, fname)
RETURN Dir.FileExists(fname) END LangExists;

PROCEDURE SetLang*(language: ARRAY OF CHAR);
BEGIN lang := language; LoadStrings
END SetLang;

BEGIN nofstrings := 0; Clear
END FoStrings.
