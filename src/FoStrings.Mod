MODULE FoStrings;
IMPORT Strings, Int;

PROCEDURE GetErrorStr*(err: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN
  IF err = 41 THEN s := 'Пропущена точка с запятой.'
  ELSE
    s := 'Ошибка ';
    Int.Append(err, s);
    Strings.Append('.', s)
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

END FoStrings.
