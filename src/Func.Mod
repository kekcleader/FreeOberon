MODULE Func;
(** Functions. Part of Free Oberon IDE internal code *)
IMPORT Config;

PROCEDURE FixFname*(VAR s: ARRAY OF CHAR);
(** Replace all / with \ if on Windows *)
VAR i: INTEGER;
BEGIN
  IF Config.pathDelimiter = '\' THEN i := 0;
    WHILE (i # LEN(s)) & (s[i] # 0X) DO
      IF s[i] = '/' THEN s[i] := '\' END;
      INC(i)
    END
  END
END FixFname;

END Func.
