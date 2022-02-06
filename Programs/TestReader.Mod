MODULE TestReader;
IMPORT Out, Texts;
VAR T: Texts.Text; R: Texts.Reader; S: Texts.Scanner;
  ch: CHAR;
BEGIN
  NEW(T); Texts.Open(T, 'TEXT.DAT');

  Texts.OpenScanner(S, T, 1); Texts.Scan(S);
  Out.String(S.s); Out.Char(';'); Out.Ln;

  Texts.OpenReader(R, T, 0);
  Texts.Read(R, ch);
  WHILE ~R.eot DO
    Out.Int(ORD(R.eot), 5);
    Out.Int(ORD(ch), 5); Out.String('   ');
    Out.Char(ch); Out.Ln;
    Texts.Read(R, ch)
  END
END TestReader.
