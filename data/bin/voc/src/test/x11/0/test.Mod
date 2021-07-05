MODULE test;

IMPORT p := oocXYplane, Out := Console;

VAR 
  ch : CHAR;
  i : INTEGER;

BEGIN
  p.Open;

  (*p.Clear;*)
  FOR i := 1 TO 555 DO
    p.Dot(i,300 ,p.draw)
  END;
  
  (*
  FOR i := 100 TO 500 DO
  p.Dot(i,300 ,p.erase)
  END;
  *)
  
  IF p.IsDot (5, 300) THEN Out.String("Yes") ELSE Out.String("No") END; Out.Ln;
  IF p.IsDot (5, 500) THEN Out.String("Yes") ELSE Out.String("No") END; Out.Ln;

  REPEAT
    ch := p.Key();
  UNTIL ch # 0X;

  p.Close;
END test.
