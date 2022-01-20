MODULE FoStrings;
IMPORT Strings, Texts, Int, Out;

VAR lang: ARRAY 6 OF CHAR;

PROCEDURE GetErrorStr*(err: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN
  IF err = 41 THEN s := 'Пропущена точка с запятой.'
  ELSIF err = 257 THEN s := 'Файл содержит неверное имя модуля.'
  ELSE s := 'Текст '; Int.Append(err, s); Strings.Append('-й ошибки.', s)
  END
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

PROCEDURE LoadStrings;
VAR T: Texts.Text;
  S: Texts.Scanner;
  fname: ARRAY 256 OF CHAR;
BEGIN
  fname := 'Data/Texts/'; Strings.Append(lang, fname);
  Strings.Append('.dat', fname);
  NEW(T); Texts.Open(T, fname);
  Texts.OpenScanner(S, T, 0);
  Texts.Scan(S);
  IF S.class = Texts.Int THEN
    Out.String('READ INTEGER '); Out.Int(S.i, 0); Out.Ln
  ELSE
    Out.String('READ CLASS '); Out.Int(S.class, 0); Out.Ln
  END
END LoadStrings;

PROCEDURE SetLang*(language: ARRAY OF CHAR);
BEGIN lang := language; LoadStrings
END SetLang;

END FoStrings.
