(* 	$Id: Strings.Mod,v 1.2 2002/03/11 21:33:22 mva Exp $	 *)
MODULE ooc2Strings;
(*  Facilities for manipulating strings in character arrays.
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
 
 
(**

Unlike Modula-2, the behaviour of a procedure is undefined, if one of its input
parameters is an unterminated character array.  All of the following procedures
expect to get 0X terminated strings, and will return likewise terminated 
strings.

All input parameters that represent an array index or a length are
expected to be non-negative.  In the descriptions below these
restrictions are stated as pre-conditions of the procedures, but they
aren't checked explicitly.  If this module is compiled with run-time
index enabled, checks some illegal input values may be caught.  By
default it is installed @emph{without} index checks.

*)


TYPE
  CompareResults* = SHORTINT;
  (**Result type of @oproc{Compare}.  *)
  
CONST
  less* = -1;
  (**Result of @oproc{Compare} if the first argument is lexically less
     than the second one.  *)
  equal* = 0;
  (**Result of @oproc{Compare} if the first argument is equal to the second
     one.  *)
  greater* = 1;
  (**Result of @oproc{Compare} if the first argument is lexically greater
     than the second one.  *)
 

PROCEDURE Length* (stringVal: ARRAY OF CHAR): INTEGER;
(**Returns the length of @oparam{stringVal}.  This is equal to the number of 
   characters in @oparam{stringVal} up to and excluding the first @code{0X}. *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (stringVal[i] # 0X) DO
      INC (i)
    END;
    RETURN i
  END Length;

 
 
PROCEDURE Assign* (source: ARRAY OF CHAR; VAR destination: ARRAY OF CHAR);
(**Copies @oparam{source} to @oparam{destination}.  Equivalent to the
   predefined procedure @code{COPY}.  Unlike @code{COPY}, this procedure can be
   assigned to a procedure variable.  *)
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
(**Copies at most @oparam{numberToExtract} characters from @oparam{source} to
   @oparam{destination}, starting at position @oparam{startPos} in
   @oparam{source}.  An empty string value will be extracted if
   @oparam{startPos} is greater than or equal to @samp{Length(source)}.

   @precond
   @oparam{startPos} and @oparam{numberToExtract} are not negative.
   @end precond  *)
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
(**Deletes at most @oparam{numberToDelete} characters from @oparam{stringVar},
   starting at position @oparam{startPos}.  The string value in
   @oparam{stringVar} is not altered if @oparam{startPos} is greater than or
   equal to @samp{Length(stringVar)}.

   @precond
   @oparam{startPos} and @oparam{numberToDelete} are not negative.
   @end precond  *)
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
(**Inserts @oparam{source} into @oparam{destination} at position
   @oparam{startPos}.  After the call @oparam{destination} contains the string
   that is contructed by first splitting @oparam{destination} at the position
   @oparam{startPos} and then concatenating the first half, @oparam{source},
   and the second half.  The string value in @oparam{destination} is not
   altered if @oparam{startPos} is greater than @samp{Length(source)}.  If
   @samp{startPos = Length(source)}, then @oparam{source} is appended to
   @oparam{destination}.

   @precond
   @oparam{startPos} is not negative.
   @end precond  *)
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
(**Copies @oparam{source} into @oparam{destination}, starting at position
   @oparam{startPos}. Copying stops when all of @oparam{source} has been
   copied, or when the last character of the string value in
   @oparam{destination} has been replaced.  The string value in
   @oparam{destination} is not altered if @oparam{startPos} is greater than or
   equal to @samp{Length(source)}.

   @precond
   @oparam{startPos} is not negative.
   @end precond  *)
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
(**Appends @oparam{source} to @oparam{destination}. *)
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
(**Concatenates @oparam{source2} onto @oparam{source1} and copies the result
   into @oparam{destination}.  *)
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



PROCEDURE CanAssignAll* (sourceLength: INTEGER; VAR destination: ARRAY OF CHAR): BOOLEAN;
(**Returns @code{TRUE} if a number of characters, indicated by
   @oparam{sourceLength}, will fit into @oparam{destination}; otherwise returns
   @code{FALSE}.

   @precond
   @oparam{sourceLength} is not negative.
   @end precond  *)
  BEGIN
    RETURN (sourceLength < LEN (destination))
  END CanAssignAll;
 
PROCEDURE CanExtractAll* (sourceLength, startPos, numberToExtract: INTEGER;
                          VAR destination: ARRAY OF CHAR): BOOLEAN;
(**Returns @code{TRUE} if there are @oparam{numberToExtract} characters
   starting at @oparam{startPos} and within the @oparam{sourceLength} of some
   string, and if the capacity of @oparam{destination} is sufficient to hold
   @oparam{numberToExtract} characters; otherwise returns @code{FALSE}.

   @precond
   @oparam{sourceLength}, @oparam{startPos}, and @oparam{numberToExtract} are
   not negative.
   @end precond  *)
  BEGIN
    RETURN (startPos+numberToExtract <= sourceLength) &
           (numberToExtract < LEN (destination))
  END CanExtractAll;
  
PROCEDURE CanDeleteAll* (stringLength, startPos, 
                        numberToDelete: INTEGER): BOOLEAN;
(**Returns @code{TRUE} if there are @oparam{numberToDelete} characters starting
   at @oparam{startPos} and within the @oparam{stringLength} of some string;
   otherwise returns @code{FALSE}.

   @precond
   @oparam{stringLength}, @oparam{startPos} and @oparam{numberToDelete} are not
   negative.
   @end precond  *)
  BEGIN
    RETURN (startPos+numberToDelete <= stringLength)
  END CanDeleteAll;
  
PROCEDURE CanInsertAll* (sourceLength, startPos: INTEGER;
                         VAR destination: ARRAY OF CHAR): BOOLEAN;
(**Returns @code{TRUE} if there is room for the insertion of
   @oparam{sourceLength} characters from some string into @oparam{destination}
   starting at @oparam{startPos}; otherwise returns @code{FALSE}.

   @precond
   @oparam{sourceLength} and @oparam{startPos} are not negative.
   @end precond  *)
  VAR
    lenDestination: INTEGER;
  BEGIN
    lenDestination := Length (destination);
    RETURN (startPos <= lenDestination) &
           (sourceLength+lenDestination < LEN (destination))
  END CanInsertAll;
 
PROCEDURE CanReplaceAll* (sourceLength, startPos: INTEGER;
                          VAR destination: ARRAY OF CHAR): BOOLEAN;
(**Returns @code{TRUE} if there is room for the replacement of
   @oparam{sourceLength} characters in @oparam{destination} starting at
   @oparam{startPos}; otherwise returns @code{FALSE}.

   @precond
   @oparam{sourceLength} and @oparam{startPos} are not negative.
   @end precond  *)
  BEGIN
    RETURN (sourceLength+startPos <= Length(destination))
  END CanReplaceAll;
 
PROCEDURE CanAppendAll* (sourceLength: INTEGER; 
                         VAR destination: ARRAY OF CHAR): BOOLEAN;
(**Returns @code{TRUE} if there is sufficient room in @oparam{destination} to
   append a string of length @oparam{sourceLength} to the string in
   @oparam{destination}; otherwise returns @code{FALSE}.

   @precond
   @oparam{sourceLength} is not negative.
   @end precond  *)
  BEGIN
    RETURN (Length (destination)+sourceLength < LEN (destination))
  END CanAppendAll;
 
PROCEDURE CanConcatAll* (source1Length, source2Length: INTEGER;
                         VAR destination: ARRAY OF CHAR): BOOLEAN;
(**Returns @code{TRUE} if there is sufficient room in @oparam{destination} for
   a two strings of lengths @oparam{source1Length} and @oparam{source2Length};
   otherwise returns @code{FALSE}.

   @precond
   @oparam{source1Length} and @oparam{source2Length} are not negative.
   @end precond  *)
  BEGIN
    RETURN (source1Length+source2Length < LEN (destination))
  END CanConcatAll;
  


PROCEDURE Compare* (stringVal1, stringVal2: ARRAY OF CHAR): CompareResults;
(**Returns @oconst{less}, @oconst{equal}, or @oconst{greater}, according as
   @oparam{stringVal1} is lexically less than, equal to, or greater than
   @oparam{stringVal2}.  Note that Oberon-2 already contains predefined
   comparison operators on strings.  *)
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
(**Returns @samp{stringVal1 = stringVal2}.  Unlike the predefined operator
   @samp{=}, this procedure can be assigned to a procedure variable.  *)
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
(**Looks forward for next occurrence of @oparam{pattern} in
   @oparam{stringToSearch}, starting the search at position @oparam{startPos}.
   If @samp{startPos < Length(stringToSearch)} and @oparam{pattern} is found,
   @oparam{patternFound} is returned as @code{TRUE}, and @oparam{posOfPattern}
   contains the start position in @oparam{stringToSearch} of @oparam{pattern}.
   The position is a value in the range [startPos..Length(stringToSearch)-1].
   Otherwise @oparam{patternFound} is returned as @code{FALSE}, and
   @oparam{posOfPattern} is unchanged.  If @samp{startPos >
   Length(stringToSearch)-Length(Pattern)} then @oparam{patternFound} is
   returned as @code{FALSE}.

   @precond
   @oparam{startPos} is not negative.
   @end precond  *)
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
(**Looks backward for the previous occurrence of @oparam{pattern} in
   @oparam{stringToSearch} and returns the position of the first character of
   the @oparam{pattern} if found.  The search for the pattern begins at
   @oparam{startPos}.  If @oparam{pattern} is found, @oparam{patternFound} is
   returned as @code{TRUE}, and @oparam{posOfPattern} contains the start
   position in @oparam{stringToSearch} of pattern in the range [0..startPos].
   Otherwise @oparam{patternFound} is returned as @code{FALSE}, and
   @oparam{posOfPattern} is unchanged.  The pattern might be found at the given
   value of @oparam{startPos}.  The search will fail if @oparam{startPos} is
   negative.  If @samp{startPos > Length(stringToSearch)-Length(pattern)} the
   whole string value is searched.  *)
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
(**Compares the string values in @oparam{stringVal1} and @oparam{stringVal2}
   for differences.  If they are equal, @oparam{differenceFound} is returned as
   @code{FALSE}, and @code{TRUE} otherwise.  If @oparam{differenceFound} is
   @code{TRUE}, @oparam{posOfDifference} is set to the position of the first
   difference; otherwise @oparam{posOfDifference} is unchanged.  *)
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
(**Applies the function @code{CAP} to each character of the string value in
   @oparam{stringVar}.  *)
  VAR
    i: INTEGER;
  BEGIN
    i := 0;
    WHILE (stringVar[i] # 0X) DO
      stringVar[i] := CAP (stringVar[i]);
      INC (i)
    END
  END Capitalize;
 
END ooc2Strings.
