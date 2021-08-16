MODULE DirTest;
IMPORT Dir, Out;

PROCEDURE Do;
VAR r: Dir.Rec;
  name: ARRAY 512 OF CHAR;
BEGIN
  Dir.First(r, 'C:\');
  IF r.res = 0 THEN (* Есть такой каталог *)
    WHILE ~r.eod DO (* Выводим только каталоги *)
      IF r.isDir THEN Out.Char('['); Out.String(r.name); Out.Char(']'); Out.Ln END;
      Dir.Next(r)
    END;
    Dir.Rewind(r); (* Возвращаемся и *)
    WHILE ~r.eod DO (* выводим только файлы *)
      IF ~r.isDir THEN Out.String(r.name); Out.Ln END;
      Dir.Next(r)
    END;
    Dir.Close(r)
  ELSE Out.String('Could not find directory.'); Out.Ln
  END
END Do;

BEGIN
  Do
END DirTest.