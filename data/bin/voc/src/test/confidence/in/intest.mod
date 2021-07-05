MODULE intest;
IMPORT Out, In;

VAR ch: CHAR; i: INTEGER; s: ARRAY 100 OF CHAR;

BEGIN
  In.Char(ch); Out.String("chars:   ");
  WHILE In.Done & (ch # ".") DO Out.Char(ch); In.Char(ch) END;
  Out.Ln;
  In.Int(i);    IF In.Done THEN Out.String("integer: "); Out.Int(i,1); Out.Ln END;
  In.String(s); IF In.Done THEN Out.String('string:  "'); Out.String(s); Out.String('"'); Out.Ln END;
  In.Line(s);
  WHILE In.Done DO
    Out.String("line:    "); Out.String(s); Out.Ln; In.Line(s)
  END
END intest.
