(* 	$Id: OakStrings.Mod,v 1.3 1999/10/03 11:44:53 ooc-devel Exp $	 *)
MODULE oocOakStrings;
(*  Oakwood compliant string manipulation facilities.
    Copyright (C) 1998, 1999  Michael van Acken

    This module is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public License
    as published by the Free Software Foundation; either version 2 of
    the License, or (at your option) any later version.

    This module is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with OOC. If not, write to the Free Software Foundation,
    59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*)
(* see also [Oakwood Guidelines, revision 1A]
Module Strings provides a set of operations on strings (i.e., on string 
constants and character arrays, both of wich contain the character 0X as a
terminator).  All positions in strings start at 0.

Remarks
String assignments and string comparisons are already supported by the language
Oberon-2.
*)

PROCEDURE Length* (s: ARRAY OF CHAR): INTEGER;
(* Returns the number of characters in s up to and excluding the first 0X. *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (s[i] # 0X) DO
      INC (i)
    END;
    RETURN i
  END Length;

PROCEDURE Insert* (src: ARRAY OF CHAR; pos: INTEGER; VAR dst: ARRAY OF CHAR);
(* Inserts the string src into the string dst at position pos (0<=pos<= 
   Length(dst)).  If pos=Length(dst), src is appended to dst.  If the size of
   dst is not large enough to hold the result of the operation, the result is
   truncated so that dst is always terminated with a 0X. *)
  VAR
    lenSrc, lenDst, maxDst, i: INTEGER;
  BEGIN
    lenDst := Length (dst);
    lenSrc := Length (src);
    maxDst := SHORT (LEN (dst))-1;
    IF (pos+lenSrc < maxDst) THEN
      IF (lenDst+lenSrc > maxDst) THEN
        (* 'dst' too long, truncate it *)
        lenDst := maxDst-lenSrc;
        dst[lenDst] := 0X
      END;
      (* 'src' is inserted inside of 'dst', move tail section *)
      FOR i := lenDst TO pos BY -1 DO
        dst[i+lenSrc] := dst[i]
      END
    ELSE
      dst[maxDst] := 0X;
      lenSrc := maxDst-pos
    END;
    (* copy characters from 'src' to 'dst' *)
    FOR i := 0 TO lenSrc-1 DO
      dst[pos+i] := src[i]
    END
  END Insert;

PROCEDURE Append* (s: ARRAY OF CHAR; VAR dst: ARRAY OF CHAR);
(* Has the same effect as Insert(s, Length(dst), dst). *)
  VAR
    sp, dp, m: INTEGER;
  BEGIN
    m := SHORT (LEN(dst))-1;             (* max length of dst *)
    dp := Length (dst);                  (* append s at position dp *)
    sp := 0;    
    WHILE (dp < m) & (s[sp] # 0X) DO     (* copy chars from s to dst *)
      dst[dp] := s[sp];
      INC (dp);
      INC (sp)
    END;
    dst[dp] := 0X                        (* terminate dst *)
  END Append;

PROCEDURE Delete* (VAR s: ARRAY OF CHAR; pos, n: INTEGER);
(* Deletes n characters from s starting at position pos (0<=pos<=Length(s)).
   If n>Length(s)-pos, the new length of s is pos. *)
  VAR
    lenStr, i: INTEGER;
  BEGIN
    lenStr := Length (s);
    IF (pos+n < lenStr) THEN
      FOR i := pos TO lenStr-n DO
        s[i] := s[i+n]
      END
    ELSE
      s[pos] := 0X
    END
  END Delete;

PROCEDURE Replace* (src: ARRAY OF CHAR; pos: INTEGER; VAR dst: ARRAY OF CHAR);
(* Has the same effect as Delete(dst, pos, Length(src)) followed by an
   Insert(src, pos, dst). *)
  VAR
    sp, maxDst: INTEGER;
    addNull: BOOLEAN;
  BEGIN
    maxDst := SHORT (LEN (dst))-1;       (* max length of dst *)
    addNull := FALSE;
    sp := 0;
    WHILE (src[sp] # 0X) & (pos < maxDst) DO (* copy chars from src to dst *)
      (* set addNull=TRUE if we write over the end of dst *)
      addNull := addNull OR (dst[pos] = 0X);
      dst[pos] := src[sp];
      INC (pos);
      INC (sp)
    END;
    IF addNull THEN
      dst[pos] := 0X                     (* terminate dst *)
    END
  END Replace;

PROCEDURE Extract* (src: ARRAY OF CHAR; pos, n: INTEGER; VAR dst: ARRAY OF CHAR);
(* Extracts a substring dst with n characters from position pos (0<=pos<=
   Length(src)) in src.  If n>Length(src)-pos, dst is only the part of src from
   pos to the end of src, i.e. Length(src)-1.  If the size of dst is not large
   enough to hold the result of the operation, the result is truncated so that
   dst is always terminated with a 0X. *)
  VAR
    i: INTEGER;
  BEGIN
    (* set n to Max(n, LEN(dst)-1) *)
    IF (n > LEN(dst)) THEN
      n := SHORT (LEN(dst))-1
    END;
    (* copy upto n characters into dst *)
    i := 0;
    WHILE (i < n) & (src[pos+i] # 0X) DO
      dst[i] := src[pos+i];
      INC (i)
    END;
    dst[i] := 0X
  END Extract;

PROCEDURE Pos* (pat, s: ARRAY OF CHAR; pos: INTEGER): INTEGER;
(* Returns the position of the first occurrence of pat in s.  Searching starts
   at position pos.  If pat is not found, -1 is returned. *)
  VAR
    posPat: INTEGER;
  BEGIN
    posPat := 0;
    LOOP
      IF (pat[posPat] = 0X) THEN         (* reached end of pattern *)
        RETURN pos-posPat
      ELSIF (s[pos] = 0X) THEN           (* end of string (but not of pattern) *)
        RETURN -1
      ELSIF (s[pos] = pat[posPat]) THEN  (* characters identic, compare next one *)
        INC (pos); INC (posPat)
      ELSE                               (* difference found: reset indices and restart *)
        pos := pos-posPat+1; posPat := 0
      END
    END
  END Pos;

PROCEDURE Cap* (VAR s: ARRAY OF CHAR);
(* Replaces each lower case letter with s by its upper case equivalent. *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (s[i] # 0X) DO
      s[i] := CAP (s[i]);
      INC (i)
    END
  END Cap;

END oocOakStrings.
