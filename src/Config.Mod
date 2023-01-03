MODULE Config;
IMPORT Platform;
CONST
  isWindows* = Platform.Windows;
  pathDelimiter* = Platform.PathDelimiter;
  stdPath* = 'Programs/';
  startInFullscreen* = FALSE; (** Should Free Oberon start in full screen *)

  version* = '1.1.0-alpha.7';
  year* = 2023;

VAR
  debug*: BOOLEAN;

PROCEDURE SetDebug*(deb: BOOLEAN);
BEGIN debug := deb
END SetDebug;

(** Replace all / with \ if on Windows *)
PROCEDURE FixFname*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  IF pathDelimiter = '\' THEN i := 0;
    WHILE (i # LEN(s)) & (s[i] # 0X) DO
      IF s[i] = '/' THEN s[i] := '\' END;
      INC(i)
    END
  END
END FixFname;

BEGIN
  debug := FALSE
END Config.
