(* This module is obsolete.  Don't use it. *)
MODULE oocStrings2;

IMPORT
  Strings := oocStrings;
  
  
PROCEDURE AppendChar* (ch: CHAR; VAR dst: ARRAY OF CHAR);
(* Appends 'ch' to string 'dst' (if Length(dst)<LEN(dst)-1). *)
  VAR
    len: INTEGER;
  BEGIN
    len := Strings.Length (dst);
    IF (len < SHORT (LEN (dst))-1) THEN
      dst[len] := ch;
      dst[len+1] := 0X
    END
  END AppendChar;

PROCEDURE InsertChar* (ch: CHAR; pos: INTEGER; VAR dst: ARRAY OF CHAR);
(* Inserts the character ch into the string dst at position pos (0<=pos<= 
   Length(dst)).  If pos=Length(dst), src is appended to dst.  If the size of
   dst is not large enough to hold the result of the operation, the result is
   truncated so that dst is always terminated with a 0X. *)
  VAR
    src: ARRAY 2 OF CHAR;
  BEGIN
    src[0] := ch; src[1] := 0X;
    Strings.Insert (src, pos, dst)
  END InsertChar;
  
PROCEDURE PosChar* (ch: CHAR; str: ARRAY OF CHAR): INTEGER;
(* Returns the first position of character 'ch' in 'str' or
   -1 if 'str' doesn't contain the character.
   Ex.: PosChar ("abcd", "c") = 2
        PosChar ("abcd", "D") = -1  *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    LOOP
      IF (str[i] = ch) THEN
        RETURN i
      ELSIF (str[i] = 0X) THEN
        RETURN -1
      ELSE
        INC (i)
      END
    END
  END PosChar;

PROCEDURE Match* (pat, s: ARRAY OF CHAR): BOOLEAN;
(* Returns TRUE if the string in s matches the string in pat.
   The pattern may contain any number of the wild characters '*' and '?'
   '?' matches any single character
   '*' matches any sequence of characters (including a zero length sequence)
   E.g. '*.?' will match any string with two or more characters if it's second
   last character is '.'. *)
  VAR
    lenSource,
    lenPattern: INTEGER;

   PROCEDURE RecMatch(VAR src: ARRAY OF CHAR; posSrc: INTEGER;
                      VAR pat: ARRAY OF CHAR; posPat: INTEGER): BOOLEAN;
     (* src = to be tested ,    posSrc = position in src *)
     (* pat = pattern to match, posPat = position in pat *)
     VAR
       i: INTEGER;
     BEGIN
       LOOP
         IF (posSrc = lenSource) & (posPat = lenPattern) THEN
           RETURN TRUE
         ELSIF (posPat = lenPattern) THEN
           RETURN FALSE
         ELSIF (pat[posPat] = "*") THEN
           IF (posPat = lenPattern-1) THEN
             RETURN TRUE
           ELSE
             FOR i := posSrc TO lenSource DO
               IF RecMatch (src, i, pat, posPat+1) THEN
                 RETURN TRUE
               END
             END;
             RETURN FALSE
           END
         ELSIF (pat[posPat] # "?") & (pat[posPat] # src[posSrc]) THEN
           RETURN FALSE
         ELSE
           INC(posSrc); INC(posPat)
         END
       END
     END RecMatch;

  BEGIN
    lenPattern := Strings.Length (pat);
    lenSource := Strings.Length (s);
    RETURN RecMatch (s, 0, pat, 0)
  END Match;

END oocStrings2.
