MODULE Sets;

IMPORT Texts;

CONST (*size* = 32;*)
      size* = MAX(SET) + 1;

PROCEDURE Clear*(VAR s: ARRAY OF SET);
  VAR i: INTEGER;
BEGIN
  i := 0; WHILE i < LEN(s) DO s[i] := {}; INC(i) END
END Clear;


PROCEDURE Fill*(VAR s: ARRAY OF SET);
  VAR i: INTEGER;
BEGIN
  i := 0; WHILE i < LEN(s) DO s[i] := {0 .. size-1}; INC(i) END
END Fill;


PROCEDURE Incl*(VAR s: ARRAY OF SET; x: INTEGER);
BEGIN INCL(s[x DIV size], x MOD size)
END Incl;


PROCEDURE Excl*(VAR s: ARRAY OF SET; x: INTEGER);
BEGIN EXCL(s[x DIV size], x MOD size)
END Excl;


PROCEDURE In*(VAR s: ARRAY OF SET; x: INTEGER): BOOLEAN;
BEGIN RETURN x MOD size IN s[x DIV size]
END In;


PROCEDURE Includes*(VAR s1, s2: ARRAY OF SET): BOOLEAN;
  VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE i < LEN(s1) DO
    IF s1[i] + s2[i] # s1[i] THEN RETURN FALSE END ;
    INC(i)
  END ;
  RETURN TRUE;
END Includes;


PROCEDURE Elements*(VAR s: ARRAY OF SET; VAR lastElem: INTEGER): INTEGER;
  VAR i, n, max: INTEGER;
BEGIN
  i := 0; n := 0; max := SHORT(LEN(s)) * size;
  WHILE i < max DO
    IF (i MOD size) IN s[i DIV size] THEN INC(n); lastElem := i END ;
    INC(i)
  END ;
  RETURN n
END Elements;


PROCEDURE Empty*(VAR s: ARRAY OF SET): BOOLEAN;
  VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE i < LEN(s) DO
    IF s[i] # {} THEN RETURN FALSE END ;
    INC(i)
  END ;
  RETURN TRUE
END Empty;


PROCEDURE Equal*(VAR s1, s2: ARRAY OF SET): BOOLEAN;
  VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE i < LEN(s1) DO
    IF s1[i] # s2[i] THEN RETURN FALSE END ;
    INC(i)
  END ;
  RETURN TRUE
END Equal;


PROCEDURE Different*(VAR s1, s2: ARRAY OF SET): BOOLEAN;
  VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE i < LEN(s1) DO
    IF s1[i] * s2[i] # {} THEN RETURN FALSE END ;
    INC(i)
  END ;
  RETURN TRUE
END Different;


PROCEDURE Unite*(VAR s1, s2: ARRAY OF SET);
  VAR i: INTEGER; s: SET;
BEGIN
  i := 0; WHILE i < LEN(s1) DO s := s1[i] + s2[i]; s1[i] := s; INC(i) END
END Unite;


PROCEDURE Differ*(VAR s1, s2: ARRAY OF SET);
  VAR i: INTEGER; s: SET;
BEGIN
  i := 0; WHILE i < LEN(s1) DO s := s1[i] - s2[i]; s1[i] := s; INC(i) END
END Differ;


PROCEDURE Intersect*(VAR s1, s2, s3: ARRAY OF SET);
  VAR i: INTEGER; s: SET;
BEGIN
  i := 0; WHILE i < LEN(s1) DO s := s1[i] * s2[i]; s3[i] := s; INC(i) END
END Intersect;


PROCEDURE Print*(VAR f: Texts.Writer; s: ARRAY OF SET; w, indent: INTEGER);
  VAR col, i, max: INTEGER;
BEGIN
  i := 0; col := indent; max := SHORT(LEN(s)) * size;
  Texts.Write(f, "{");
  WHILE i < max DO
    IF In(s, i) THEN
      IF col + 4 > w THEN
        Texts.WriteLn(f);
        col := 0; WHILE col < indent DO Texts.Write(f, " "); INC(col) END
      END ;
      Texts.WriteInt(f, i, 3); Texts.Write(f, ",");
      INC(col, 4)
    END ;
    INC(i)
  END ;
  Texts.Write(f, "}")
END Print;

END Sets.
