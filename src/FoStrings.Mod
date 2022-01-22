MODULE FoStrings;
IMPORT Strings, Texts, Int, Out;

TYPE String = ARRAY 128 OF CHAR;

VAR lang: ARRAY 6 OF CHAR;
  errorStr: ARRAY 500 OF String;

PROCEDURE GetErrorStr*(err: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN
  IF (0 <= err) & (err < LEN(errorStr)) THEN Strings.Copy(errorStr[err], s)
  ELSE s := 'Text of error #'; Int.Append(err, s); Strings.Append('.', s)
  END
  (*IF err = 41 THEN s := 'Пропущена точка с запятой.'
  ELSIF err = 257 THEN s := 'Файл содержит неверное имя модуля.'
  ELSE s := 'Текст '; Int.Append(err, s); Strings.Append('-й ошибки.', s)
  END*)
END GetErrorStr;

PROCEDURE MakeErrorStr*(err: INTEGER; VAR s: ARRAY OF CHAR);
VAR z: ARRAY 256 OF CHAR;
BEGIN
  GetErrorStr(err, z);
  s := 'Ошибка #';
  Int.Append(err, s);
  Strings.Append(': ', s);
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

PROCEDURE LoadStrings;
VAR T: Texts.Text;
  i: INTEGER;
  ok: BOOLEAN;
  S: Texts.Scanner;
  fname: ARRAY 256 OF CHAR;
BEGIN
  Clear;
  fname := 'Data/Texts/'; Strings.Append(lang, fname);
  Strings.Append('.dat', fname);
  NEW(T); Texts.Open(T, fname);
  Texts.OpenScanner(S, T, 0);
  Texts.Scan(S); ok := TRUE;
  WHILE ~S.eot & ok DO ok := FALSE;
    IF S.class = Texts.Int THEN i := S.i; Texts.Scan(S);
      IF (S.class = Texts.String) & (0 <= i) & (i < LEN(errorStr)) &
         (S.len < LEN(errorStr[0]) - 1)
      THEN Strings.Copy(S.s, errorStr[i]); ok := TRUE;
        Out.String('READ STRING  "'); Out.String(errorStr[i]);
        Out.String('", i='); Out.Int(i, 0); Out.Ln
      END
    END;
    Texts.Scan(S)
  END
END LoadStrings;

PROCEDURE SetLang*(language: ARRAY OF CHAR);
BEGIN lang := language; LoadStrings
END SetLang;

END FoStrings.
