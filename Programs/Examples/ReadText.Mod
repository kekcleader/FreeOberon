MODULE ReadText;
(* Program reads an identifier, and 2 integers from a text file. *)
IMPORT Tx := Texts, Out;
VAR T: Tx.Text; S: Tx.Scanner;
  n: INTEGER;
BEGIN
  NEW(T); Tx.Open(T, 'Data/TEXT.DAT');
  IF T.len >= 0 THEN
    Tx.OpenScanner(S, T, 0);
    Tx.Scan(S);
    Out.Int(S.class, 5); Out.String('   ---> ');
    Out.String(S.s); Out.Ln;
    Tx.Scan(S);
    Out.Int(S.class, 5); Out.String('   ---> ');
    n := S.i; Out.Int(n, 0); Out.Ln;
    Tx.Scan(S); INC(n, S.i);
    Out.Int(S.class, 5); Out.String('   ---> ');
    Out.Int(S.i, 0); Out.Ln;
    Out.String('     Сумма = '); Out.Int(n, 0); Out.Ln
  ELSE Out.String('Файл не найден.'); Out.Ln
  END
END ReadText.