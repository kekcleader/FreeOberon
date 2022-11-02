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
  F := Files.Old('Data/in.txt');
  IF F # NIL THEN
    Files.Set(r, F, 0);
    F2 := Files.New('Data/out.txt');
    IF F2 # NIL THEN
      Files.Set(w, F2, 0);
      Parse(r, w);
      Files.Register(F2);
      Out.String('Создан файл "Data/out.txt" с зашифрованным'); Out.Ln;
      Out.String('содержимым файла "Data/in.txt".')
    ELSE
      Out.String('Не могу создать файл "Data/out.txt".')
    END
  ELSE
    Out.String('Не могу открыть файл "Data/in.txt".')
  END;
  Out.Ln
END Do;

BEGIN
  Do
END Encrypt.