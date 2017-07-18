MODULE isptest;

IMPORT Files, Texts, Out, Platform;

CONST path="isptest.mod";

VAR
  T: Texts.Text;
  R: Texts.Reader;
  ch: CHAR;
  i, j, k : LONGINT;
BEGIN
  NEW(T);
  IF Files.Old(path) # NIL THEN
    Texts.Open(T, path);
    Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
    WHILE ~R.eot DO
       Texts.Read(R, ch);
       i := Texts.Pos(R);
       Out.String("pos="); Out.Int(i,0); Out.String(" char="); Out.Char(ch); Out.Char(0AX);
       IF i = 21906 THEN
         Out.String("21906"); Out.Char(0AX);
         (*Platform.Delay(10000);*)
       END;
    END;
  END
END isptest.