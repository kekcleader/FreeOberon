(* 	$Id: Strings.Mod,v 1.4 1999/10/03 11:45:07 ooc-devel Exp $	 *)
MODULE oocStrings;
(*  Facilities for manipulating strings.
    Copyright (C) 1996, 1997  Michael van Acken

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
 
 
(*
Notes:

Unlike Modula-2, the behaviour of a procedure is undefined, if one of its input
parameters is an unterminated character array.  All of the following procedures
expect to get 0X terminated strings, and will return likewise terminated 
strings.

All input parameters that represent an array index or a length are expected to
be non-negative.  In the descriptions below these restrictions are stated as
pre-conditions of the procedures, but they aren't checked explicitly.  If this
module is compiled with enable run-time index checks some illegal input values
may be caught.  By default it is installed _without_ index checks.

Differences from the Strings module of the Oakwood Guidelines:
- `Delete' is defined for `startPos' greater than `Length(stringVar)' 
- `Insert' is defined for `startPos' greater than `Length(destination)' 
- `Replace' is defined for `startPos' greater than `Length(destination)'
- `Replace' will never return a string in `destination' that is longer
  than the initial value of `destination' before the call.
- `Capitalize' replaces `Cap'
- `FindNext' replaces `Pos' with slightly changed call pattern
- the `CanSomethingAll' predicates are new  
- also new: `Compare', `Equal', `FindPrev', and `FindDiff'
*)


TYPE
  CompareResults* = SHORTINT;
  
CONST
  (* values returned by `Compare' *)
  less* = -1;
  equal* = 0;
  greater* = 1;
 

PROCEDURE Length* (stringVal: ARRAY OF CHAR): INTEGER;
(* Returns the length of `stringVal'.  This is equal to the number of 
   characters in `stringVal' up to and excluding the first 0X.  *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (stringVal[i] # 0X) DO
      INC (i)
    END;
    RETURN i
  END Length;

 
 
(* 
The following seven procedures construct a string value, and attempt to assign
it to a variable parameter.  They all have the property that if the length of 
the constructed string value exceeds the capacity of the variable parameter, a
truncated value is assigned.  The constructed string always ends with the
string terminator 0X.
*)

PROCEDURE Assign* (source: ARRAY OF CHAR; VAR destination: ARRAY OF CHAR);
(* Copies `source' to `destination'.  Equivalent to the predefined procedure 
   COPY.  Unlike COPY, this procedure can be assigned to a procedure 
   variable.  *)
  VAR
    i: INTEGER;
  BEGIN
    i := -1;
    REPEAT
      INC (i);
      destination[i] := source[i]
    UNTIL (destination[i] = 0X) OR (i = LEN (destination)-1);
    destination[i] := 0X
  END Assign;
  
PROCEDURE Extract* (source: ARRAY OF CHAR; startPos, numberToExtract: INTEGER;
                    VAR destination: ARRAY OF CHAR);
(* Copies at most `numberToExtract' characters from `source' to `destination',
   starting at position `startPos' in `source'.  An empty string value will be
   extracted if `startPos' is greater than or equal to `Length(source)'.  
   pre: `startPos' and `numberToExtract' are not negative.  *)
  VAR
    sourceLength, i: INTEGER;
  BEGIN
    (* make sure that we get an empty string if `startPos' refers to an array
       index beyond `Length (source)'  *)
    sourceLength := Length (source);
    IF (startPos > sourceLength) THEN
      startPos := sourceLength
    END;
    
    (* make sure that `numberToExtract' doesn't exceed the capacity 
       of `destination' *)
    IF (numberToExtract >= LEN (destination)) THEN
      numberToExtract := SHORT (LEN (destination))-1
    END;
    
    (* copy up to `numberToExtract' characters to `destination' *)
    i := 0;
    WHILE (i < numberToExtract) & (source[startPos+i] # 0X) DO
      destination[i] := source[startPos+i];
      INC (i)
    END;
    destination[i] := 0X
  END Extract;
  
PROCEDURE Delete* (VAR stringVar: ARRAY OF CHAR; 
                  startPos, numberToDelete: INTEGER);
(* Deletes at most `numberToDelete' characters from `stringVar', starting at 
   position `startPos'.  The string value in `stringVar' is not altered if
   `startPos' is greater than or equal to `Length(stringVar)'.
   pre: `startPos' and `numberToDelete' are not negative.  *)
  VAR
    stringLength, i: INTEGER;
  BEGIN
    stringLength := Length (stringVar);
    IF (startPos+numberToDelete < stringLength) THEN
      (* `stringVar' has remaining characters beyond the deleted section;
         these have to be moved forward by `numberToDelete' characters *)
      FOR i := startPos TO stringLength-numberToDelete DO
        stringVar[i] := stringVar[i+numberToDelete]
      END
    ELSIF (startPos < stringLength) THEN
      stringVar[startPos] := 0X
    END
  END Delete;
 
PROCEDURE Insert* (source: ARRAY OF CHAR; startPos: INTEGER;
                   VAR destination: ARRAY OF CHAR);
(* Inserts `source' into `destination' at position `startPos'.  After the call
   `destination' contains the string that is contructed by first splitting 
   `destination' at the position `startPos' and then concatenating the first 
   half, `source', and the second half.  The string value in `destination' is 
   not altered if `startPos' is greater than `Length(source)'.  If `startPos =
   Length(source)', then `source' is appended to `destination'.
   pre: `startPos' is not negative.  *)
  VAR
    sourceLength, destLength, destMax, i: INTEGER;
  BEGIN
    destLength := Length (destination);
    sourceLength := Length (source);
    destMax := SHORT (LEN (destination))-1;
    IF (startPos+sourceLength < destMax) THEN
      (* `source' is inserted inside of `destination' *)
      IF (destLength+sourceLength > destMax) THEN
        (* `destination' too long, truncate it *)
        destLength := destMax-sourceLength;
        destination[destLength] := 0X
      END;
      
      (* move tail section of `destination' *)
      FOR i := destLength TO startPos BY -1 DO
        destination[i+sourceLength] := destination[i]
      END
    ELSIF (startPos <= destLength) THEN
      (* `source' replaces `destination' from `startPos' on *)
      destination[destMax] := 0X;        (* set string terminator *)
      sourceLength := destMax-startPos   (* truncate `source' *)
    ELSE  (* startPos > destLength: no change in `destination' *)
      sourceLength := 0
    END;
    (* copy characters from `source' to `destination' *)
    FOR i := 0 TO sourceLength-1 DO
      destination[startPos+i] := source[i]
    END
  END Insert;
  
PROCEDURE Replace* (source: ARRAY OF CHAR; startPos: INTEGER;
                    VAR destination: ARRAY OF CHAR);
(* Copies `source' into `destination', starting at position `startPos'. Copying
   stops when all of `source' has been copied, or when the last character of 
   the string value in `destination' has been replaced.   The string value in 
   `destination' is not altered if `startPos' is greater than or equal to 
   `Length(source)'. 
   pre: `startPos' is not negative.  *)
  VAR
    destLength, i: INTEGER;
  BEGIN
    destLength := Length (destination);
    IF (startPos < destLength) THEN
      (* if `startPos' is inside `destination', then replace characters until
         the end of `source' or `destination' is reached *)
      i := 0;
      WHILE (startPos # destLength) & (source[i] # 0X) DO
        destination[startPos] := source[i];
        INC (startPos);
        INC (i)
      END
    END
  END Replace;
 
PROCEDURE Append* (source: ARRAY OF CHAR; VAR destination: ARRAY OF CHAR);
(* Appends source to destination. *)
  VAR
    destLength, i: INTEGER;
  BEGIN
    destLength := Length (destination);
    i := 0;
    WHILE (destLength < LEN (destination)-1) & (source[i] # 0X) DO
      destination[destLength] := source[i];
      INC (destLength);
      INC (i)
    END;
    destination[destLength] := 0X
  END Append;
  
PROCEDURE Concat* (source1, source2: ARRAY OF CHAR; 
                   VAR destination: ARRAY OF CHAR);
(* Concatenates `source2' onto `source1' and copies the result into 
   `destination'. *)
  VAR
    i, j: INTEGER;
  BEGIN
    (* copy `source1' into `destination' *)
    i := 0;
    WHILE (source1[i] # 0X) & (i < LEN(destination)-1) DO
      destination[i] := source1[i];
      INC (i)
    END;
    
    (* append `source2' to `destination' *)
    j := 0;
    WHILE (source2[j] # 0X) & (i < LEN (destination)-1) DO
      destination[i] := source2[j];
      INC (j); INC (i)
    END;
    destination[i] := 0X
  END Concat;



(*
The following predicates provide for pre-testing of the operation-completion
conditions for the procedures above.
*)
 
PROCEDURE CanAssignAll* (sourceLength: INTEGER; VAR destination: ARRAY OF CHAR): BOOLEAN;
(* Returns TRUE if a number of characters, indicated by `sourceLength', will 
   fit into `destination'; otherwise returns FALSE.  
   pre: `sourceLength' is not negative.  *)
  BEGIN
    RETURN (sourceLength < LEN (destination))
  END CanAssignAll;
 
PROCEDURE CanExtractAll* (sourceLength, startPos, numberToExtract: INTEGER;
                          VAR destination: ARRAY OF CHAR): BOOLEAN;
(* Returns TRUE if there are `numberToExtract' characters starting at 
  `startPos' and within the `sourceLength' of some string, and if the capacity
   of `destination' is sufficient to hold `numberToExtract' characters;
   otherwise returns FALSE. 
   pre: `sourceLength', `startPos', and `numberToExtract' are not negative.  *)
  BEGIN
    RETURN (startPos+numberToExtract <= sourceLength) &
           (numberToExtract < LEN (destination))
  END CanExtractAll;
  
PROCEDURE CanDeleteAll* (stringLength, startPos, 
                        numberToDelete: INTEGER): BOOLEAN;
(* Returns TRUE if there are `numberToDelete' characters starting at `startPos'
   and within the `stringLength' of some string; otherwise returns FALSE.
   pre: `stringLength', `startPos' and `numberToDelete' are not negative.  *)
  BEGIN
    RETURN (startPos+numberToDelete <= stringLength)
  END CanDeleteAll;
  
PROCEDURE CanInsertAll* (sourceLength, startPos: INTEGER;
                         VAR destination: ARRAY OF CHAR): BOOLEAN;
(* Returns TRUE if there is room for the insertion of `sourceLength'
   characters from some string into `destination' starting at `startPos'; 
   otherwise returns FALSE.
   pre: `sourceLength' and `startPos' are not negative.  *)
  VAR
    lenDestination: INTEGER;
  BEGIN
    lenDestination := Length (destination);
    RETURN (startPos <= lenDestination) &
           (sourceLength+lenDestination < LEN (destination))
  END CanInsertAll;
 
PROCEDURE CanReplaceAll* (sourceLength, startPos: INTEGER;
                          VAR destination: ARRAY OF CHAR): BOOLEAN;
(* Returns TRUE if there is room for the replacement of `sourceLength'
   characters in `destination' starting at `startPos'; otherwise returns FALSE.
   pre: `sourceLength' and `startPos' are not negative.  *)
  BEGIN
    RETURN (sourceLength+startPos <= Length(destination))
  END CanReplaceAll;
 
PROCEDURE CanAppendAll* (sourceLength: INTEGER; 
                         VAR destination: ARRAY OF CHAR): BOOLEAN;
(* Returns TRUE if there is sufficient room in `destination' to append a string
   of length `sourceLength' to the string in `destination'; otherwise returns 
   FALSE.
   pre: `sourceLength' is not negative.  *)
  BEGIN
    RETURN (Length (destination)+sourceLength < LEN (destination))
  END CanAppendAll;
 
PROCEDURE CanConcatAll* (source1Length, source2Length: INTEGER;
                         VAR destination: ARRAY OF CHAR): BOOLEAN;
(* Returns TRUE if there is sufficient room in `destination' for a two strings
   of lengths `source1Length' and `source2Length'; otherwise returns FALSE.
   pre: `source1Length' and `source2Length' are not negative.  *)
  BEGIN
    RETURN (source1Length+source2Length < LEN (destination))
  END CanConcatAll;
  


(* 
The following type and procedures provide for the comparison of string values,
and for the location of substrings within strings.  
*)
 
PROCEDURE Compare* (stringVal1, stringVal2: ARRAY OF CHAR): CompareResults;
(* Returns `less', `equal', or `greater', according as `stringVal1' is 
   lexically less than, equal to, or greater than `stringVal2'.
   Note that Oberon-2 already contains predefined comparison operators on 
   strings.  *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (stringVal1[i] # 0X) & (stringVal1[i] = stringVal2[i]) DO
      INC (i)
    END;
    IF (stringVal1[i] < stringVal2[i]) THEN
      RETURN less 
    ELSIF (stringVal1[i] > stringVal2[i]) THEN
      RETURN greater
    ELSE
      RETURN equal
    END
  END Compare;
 
PROCEDURE Equal* (stringVal1, stringVal2: ARRAY OF CHAR): BOOLEAN;
(* Returns `stringVal1 = stringVal2'.  Unlike the predefined operator `=', this
   procedure can be assigned to a procedure variable. *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (stringVal1[i] # 0X) & (stringVal1[i] = stringVal2[i]) DO
      INC (i)
    END;
    RETURN (stringVal1[i] = 0X) & (stringVal2[i] = 0X)
  END Equal;
 
PROCEDURE FindNext* (pattern, stringToSearch: ARRAY OF CHAR; startPos: INTEGER;
                     VAR patternFound: BOOLEAN; VAR posOfPattern: INTEGER);
(* Looks forward for next occurrence of `pattern' in `stringToSearch', starting
   the search at position `startPos'.  If `startPos < Length(stringToSearch)' 
   and `pattern' is found, `patternFound' is returned as TRUE, and 
   `posOfPattern' contains the start position in `stringToSearch' of `pattern',
   a value in the range [startPos..Length(stringToSearch)-1].  Otherwise 
   `patternFound' is returned as FALSE, and `posOfPattern' is unchanged.  
   If `startPos > Length(stringToSearch)-Length(Pattern)' then `patternFound'
   is returned as FALSE.
   pre: `startPos' is not negative.  *)
  VAR
    patternPos: INTEGER;
  BEGIN
    IF (startPos < Length (stringToSearch)) THEN
      patternPos := 0;
      LOOP
        IF (pattern[patternPos] = 0X) THEN     
          (* reached end of pattern *)
          patternFound := TRUE;
          posOfPattern := startPos-patternPos;
          EXIT
        ELSIF (stringToSearch[startPos] = 0X) THEN 
          (* end of string (but not of pattern) *)
          patternFound := FALSE;
          EXIT
        ELSIF (stringToSearch[startPos] = pattern[patternPos]) THEN  
          (* characters identic, compare next one *)
          INC (startPos); 
          INC (patternPos)
        ELSE                               
          (* difference found: reset indices and restart *)
          startPos := startPos-patternPos+1; 
          patternPos := 0
        END
      END
    ELSE
      patternFound := FALSE
    END
  END FindNext;
  
PROCEDURE FindPrev* (pattern, stringToSearch: ARRAY OF CHAR; startPos: INTEGER;
                     VAR patternFound: BOOLEAN; VAR posOfPattern: INTEGER);
(* Looks backward for the previous occurrence of `pattern' in `stringToSearch'
   and returns the position of the first character of the `pattern' if found. 
   The search for the pattern begins at `startPos'. If `pattern' is found, 
   `patternFound' is returned as TRUE, and `posOfPattern' contains the start 
   position in `stringToSearch' of pattern in the range [0..startPos]. 
   Otherwise `patternFound' is returned as FALSE, and `posOfPattern' is 
   unchanged.  
   The pattern might be found at the given value of `startPos'.  The search 
   will fail if `startPos' is negative.
   If `startPos > Length(stringToSearch)-Length(pattern)' the whole string 
   value is searched.  *)
  VAR
    patternPos, stringLength, patternLength: INTEGER;
  BEGIN
    (* correct `startPos' if it is larger than the possible searching range *)
    stringLength := Length (stringToSearch);
    patternLength := Length (pattern);
    IF (startPos > stringLength-patternLength) THEN
      startPos := stringLength-patternLength
    END;
    
    IF (startPos >= 0) THEN
      patternPos := 0;
      LOOP
        IF (pattern[patternPos] = 0X) THEN     
          (* reached end of pattern *)
          patternFound := TRUE;
          posOfPattern := startPos-patternPos;
          EXIT
        ELSIF (stringToSearch[startPos] # pattern[patternPos]) THEN
          (* characters differ: reset indices and restart *)
          IF (startPos > patternPos) THEN
            startPos := startPos-patternPos-1;
            patternPos := 0
          ELSE
            (* reached beginning of `stringToSearch' without finding a match *)
            patternFound := FALSE;
            EXIT
          END
        ELSE  (* characters identic, compare next one *)
          INC (startPos); 
          INC (patternPos)
        END
      END
    ELSE
      patternFound := FALSE
    END
  END FindPrev;
 
PROCEDURE FindDiff* (stringVal1, stringVal2: ARRAY OF CHAR;
                     VAR differenceFound: BOOLEAN; 
                     VAR posOfDifference: INTEGER);
(* Compares the string values in `stringVal1' and `stringVal2' for differences.
   If they are equal, `differenceFound' is returned as FALSE, and TRUE 
   otherwise. If `differenceFound' is TRUE, `posOfDifference' is set to the 
   position of the first difference; otherwise `posOfDifference' is unchanged.
*)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (stringVal1[i] # 0X) & (stringVal1[i] = stringVal2[i]) DO
      INC (i)
    END;
    differenceFound := (stringVal1[i] # 0X) OR (stringVal2[i] # 0X);
    IF differenceFound THEN
      posOfDifference := i
    END
  END FindDiff;

  
PROCEDURE Capitalize* (VAR stringVar: ARRAY OF CHAR);
(* Applies the function CAP to each character of the string value in 
   `stringVar'.  *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (stringVar[i] # 0X) DO
      stringVar[i] := CAP (stringVar[i]);
      INC (i)
    END
  END Capitalize;
 
END oocStrings.
