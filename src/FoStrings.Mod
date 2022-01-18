MODULE FoStrings;
IMPORT Strings, Int;

PROCEDURE GetErrorStr*(err: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN
  IF err = 41 THEN s := 'Ожидается точка с запятой'
  ELSE
    s := 'Ошибка ';
    Int.Append(err, s);
    Strings.Append('.', s)
  END
END GetErrorStr;

END FoStrings.
