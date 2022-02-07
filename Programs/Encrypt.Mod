MODULE Encrypt;
IMPORT Files, Out, SYSTEM;
VAR key: INTEGER;

PROCEDURE BITS(n: INTEGER): SET;
RETURN SYSTEM.VAL(SET, n) END BITS;

PROCEDURE Parse(VAR r, w: Files.Rider);
VAR b: BYTE;
  k: SET;
BEGIN
  k := BITS(key);
  Files.Read(r, b);
  WHILE ~r.eof DO
    b := ORD(BITS(b) / k);
    Files.Write(w, b);
    Files.Read(r, b)
  END
END Parse;

PROCEDURE Do;
VAR F, F2: Files.File;
  r, w: Files.Rider;
BEGIN
  key := 12;
  F := Files.Old('in.txt');
  IF F # NIL THEN
    Files.Set(r, F, 0);
    F2 := Files.New('out.txt');
    IF F2 # NIL THEN
      Files.Set(w, F2, 0);
      Parse(r, w);
      Files.Register(F2)
    ELSE
      Out.String('Не могу создать файл "out.txt".'); Out.Ln
    END
  ELSE
    Out.String('Не могу открыть файл "in.txt".'); Out.Ln
  END
END Do;

BEGIN
  Do
END Encrypt.