(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  08-20-1997 rel. 32/1.0 LEI                                                *)
(*  19-11-1998 rel. 32/1.1 LEI bug in RemoveTrailingSpaces fixed              *)
(**---------------------------------------------------------------------------  
  This module provides functions for string processing. This includes combining 
  strings, copying parts of a string, the conversion of a string to a number or 
  vice-versa etc.

  All functions of this module start to count the character positions with one 
  i.e. the first character of a string is at position one.

  All procedures applying to characters instead of strings have a
  trailing "Char" in their names.  
  
  All procedures should be save. If character arrays are being used which are 
  to short for a result, the result will be truncated accordingly. 
  All functions tolerate errors in character position. However, strings 
  must always be terminated by a character with the code zero in order 
  to be processed correctly, otherwise runtime errors may occur.
  ----------------------------------------------------------------------------*)

MODULE powStrings;

CONST
  ISSHORTINT*=1;
  ISINTEGER*=2;
  ISLONGINT*=3;
  ISOUTOFRANGE*=4;
  STRINGEMPTY*=5;
  STRINGILLEGAL*=6;

TYPE
  StringT*=ARRAY OF CHAR;
  String*=POINTER TO StringT;

PROCEDURE Length*(VAR t:StringT):LONGINT;
(** Returns the length of a zero terminated string in characters. *)
VAR
  i,maxlen:LONGINT;
BEGIN
  maxlen:=LEN(t);
  i:=0;
  WHILE (i<maxlen) & (t[i]#0X) DO INC(i) END;
  RETURN i;
END Length;

PROCEDURE PosChar*(x:CHAR; 
                   VAR t:StringT; 
                   start:LONGINT (** Indicates the position starting from which 
                                     the search is to be carried out. If start is less 
                                     than one it is set to one. If start denotes a 
                                     position beyond the end of t the function returns zero. *)
                  ):LONGINT;
(** This function returns the position of the character <x> in the string <t>.
    If <x> does not occur in <t> zero is returned. If <x> occurs several times the 
    position of the first occurrence is returned. *)
VAR
  maxl:LONGINT;
BEGIN
  IF start<1 THEN start:=0 ELSE DEC(start) END;
  maxl:=Length(t);
  WHILE (start<maxl) & (t[start]#x) DO INC(start); END;
  IF (start<maxl) & (t[start]=x) THEN RETURN start+1 ELSE RETURN 0; END;
END PosChar;

PROCEDURE Pos*(VAR pattern:StringT; 
               VAR t:StringT; 
               start:LONGINT (** Indicates the position starting from which the search shall be 
                                 carried out. If start is less than one it is set to one. If start 
                                 denotes a position beyond the end of t the function returns zero. *)
              ):LONGINT;
(** This function returns the position of the string pattern in the string <t>.
    If pattern does not occur in <t> zero is returned. If the pattern occurs several 
    times the position of the first occurrence is returned. *)
VAR
  i,j,maxl,patLen:LONGINT;
BEGIN
  IF start<1 THEN start:=0 ELSE DEC(start) END;
  maxl:=Length(t);
  patLen:=Length(pattern);
  i:=start;
  j:=0;
  WHILE (j<patLen) & (i+j<maxl) DO
    IF t[i+j]=pattern[j] THEN INC(j) ELSE j:=0; INC(i) END;
  END;
  IF j=patLen THEN RETURN i+1 ELSE RETURN 0 END;
END Pos;

PROCEDURE Copy*(VAR source,dest:StringT; 
                pos,        (** character position of the source fragment *)
                n:LONGINT   (** length of the source fragment *)
               );
(** A section of the string <source> is copied to the string <dest>. The former contents 
    of <dest> are overwritten and therefore lost.
    
    The copied section in <source> starts at the position <pos> and is <n> characters long.
    
    If <dest> is not large enough to hold the copied string then only the 
    part that fits into <dest> is copied. *)
VAR
  i,j,l1,l2:LONGINT;
BEGIN
  IF pos<1 THEN
    dest[0]:=0X;
    RETURN;
  END;
  l1:=Length(source)-pos+1; 
  IF l1<1 THEN 
    dest[0]:=0X;
    RETURN;
  END;
  l2:=LEN(dest)-1;
  IF l2<l1 THEN l1:=l2 END;
  IF n<l1 THEN l1:=n END;
  i:=0;
  j:=pos-1;
  WHILE i<l1 DO 
    dest[i]:=source[j]; 
    INC(i); 
    INC(j);
  END;
  dest[i]:=0X;
END Copy;

PROCEDURE Append*(VAR dest:StringT; VAR src:StringT);
(** The string <src> is appended to the string <dest>. *)
VAR
  i,j,lSrc,lDest:LONGINT;
BEGIN
  i:=Length(dest);
  j:=0;
  lDest:=LEN(dest)-1;
  lSrc:=LEN(src);
  WHILE (i<lDest) & (j<lSrc) & (src[j]#0X) DO  
    dest[i]:=src[j];
    INC(i);
    INC(j);
  END;
  dest[i]:=0X;
END Append;

PROCEDURE AppendChar*(VAR dest:StringT; ch:CHAR);
(** The character <ch> is appended to the string <dest>. *)
VAR
  l:LONGINT;
BEGIN
  l:=Length(dest);
  IF LEN(dest)>=l+2 THEN 
    dest[l]:=ch; 
    dest[l+1]:=0X; 
  END;
END AppendChar;

PROCEDURE UpCaseChar*(x:CHAR):CHAR;
(** For all lower case letters the corresponding capital letter is returned. This also 
    applies to international characters such as ä, á, à, â... All other characters are 
    returned unchanged. The difference between this function and the Oberon-2 function 
    CAP(x:CHAR): CHAR is that the return value for characters other than lower case 
    letters of the latter function depends on the individual compiler implementation. *)
BEGIN
  CASE x OF
    "a".."z":x:=CHR(ORD(x)+ORD("A")-ORD("a"));
  | "ö": x:="Ö";
  | "ä": x:="Ä";
  | "ü": x:="Ü";
  | "á": x:="Á";
  | "é": x:="É";
  | "í": x:="Í";
  | "ó": x:="Ó";
  | "ú": x:="Ú";
  | "à": x:="À";
  | "è": x:="È";
  | "ì": x:="Ì";
  | "ò": x:="Ò";
  | "ù": x:="Ù";
  | "â": x:="Â";
  | "ê": x:="Ê";
  | "î": x:="Î";
  | "ô": x:="Ô";
  | "û": x:="Û";
  ELSE        
  END;
  RETURN x;
END UpCaseChar;

PROCEDURE UpCase*(VAR t:StringT);
(** All lower case letters in <t> are converted to upper case. This also 
    applies to international characters such as ä, á, à, â... All other characters are 
    returned unchanged. *)
VAR
  i,l:LONGINT;
BEGIN
  i:=0;
  l:=LEN(t);
  WHILE (i<l) & (t[i]#0X) DO 
    t[i]:=UpCaseChar(t[i]);
    INC(i);
  END;
END UpCase;

PROCEDURE Delete*(VAR t:StringT; pos,n:LONGINT);
(** Starting at the position <pos> <n> characters of the string <t> are deleted. *)
VAR
  i,l:LONGINT;
BEGIN
  l:=Length(t);
  IF (n<1) OR (pos<1) OR (pos>l) THEN RETURN END;
  IF n>l-pos+1 THEN n:=l-pos+1 END;
  FOR i:=pos-1 TO l-n DO t[i]:=t[i+n]; END;
END Delete;

PROCEDURE ReverseStringT(VAR t:StringT; n:LONGINT);
VAR
  a,b:LONGINT;
  x:CHAR;
BEGIN
  a:=0;
  b:=n-1;
  WHILE (a<b) DO
    x:=t[a];
    t[a]:=t[b];
    t[b]:=x;
    INC(a);
    DEC(b);
  END;
END ReverseStringT;

PROCEDURE RemoveTrailingSpaces*(VAR t:StringT);
(** All blanks at the end of <t> are removed. *)
VAR
  i:LONGINT;
BEGIN
  i:=Length(t)-1;
  WHILE (i>=0) & (t[i]=" ") DO DEC(i) END;
  t[i+1]:=0X;
END RemoveTrailingSpaces;

PROCEDURE RemoveLeadingSpaces*(VAR t:StringT);
(** All blanks at the beginning of <t> are removed. *)
VAR
  i,ml:LONGINT;
BEGIN
  i:=0;
  ml:=LEN(t)-1;
  WHILE (i<ml) & (t[i]=" ") DO INC(i); END;
  IF i>0 THEN Delete(t,1,i) END;
END RemoveLeadingSpaces;

PROCEDURE Val*(t:StringT):LONGINT;
(** The string <t> is converted to a number and returned as result of the function.

    If the character sequence in <t> does not represent a number and thus the 
    conversion to a number fails the smallest negative number (MIN(LONGINT)) is returned.
    Blanks at the beginning and the end of <t> are ignored. 
    The number must not contain blanks. *)
CONST
  threshDec=MAX(LONGINT) DIV 10;
  threshHex=MAX(LONGINT) DIV 16;
VAR                       
  inx,l,v,res:LONGINT;
  hex,exit,neg:BOOLEAN;
  ch:CHAR;
BEGIN
  RemoveTrailingSpaces(t);
  RemoveLeadingSpaces(t); 
  l:=Length(t);
  IF l<1 THEN RETURN MIN(LONGINT) END;
  hex:=CAP(t[l-1])="H";
  IF hex THEN
    DEC(l);
    t[l]:=0X;
    IF l<1 THEN RETURN MIN(LONGINT) END;
  END;  
  inx:=0;
  neg:=FALSE;
  res:=0;
  IF t[0]="+" THEN INC(inx) 
  ELSIF t[0]="-" THEN INC(inx); neg:=TRUE; END;
  IF t[l-1]="+" THEN DEC(l) 
  ELSIF t[l-1]="-" THEN DEC(l); neg:=TRUE; END;
  exit:=FALSE;
  IF hex THEN
    IF neg THEN 
      WHILE (inx<l) & ~exit DO
        ch:=CAP(t[inx]);
        IF (ch>="0") & (ch<="9") THEN
          v:=ORD(ch)-48;
        ELSIF (ch>="A") & (ch<="F") THEN
          v:=ORD(ch)-65+10;
        ELSE
          v:=-1;
        END;
        IF (v<0) OR (v>15) OR (res<-threshHex) THEN 
          exit:=TRUE
        ELSE
          res:=res*16-v;
          INC(inx);
        END;
      END;
    ELSE
      WHILE (inx<l) & ~exit DO
        ch:=CAP(t[inx]);
        IF (ch>="0") & (ch<="9") THEN
          v:=ORD(ch)-48;
        ELSIF (ch>="A") & (ch<="F") THEN
          v:=ORD(ch)-65+10;
        ELSE
          v:=-1;
        END;
        IF (v<0) OR (v>15) OR (res>threshHex) THEN 
          exit:=TRUE
        ELSE
          res:=res*16+v;
          INC(inx);
        END;
      END;
    END;
  ELSE
    IF neg THEN 
      WHILE (inx<l) & ~exit DO
        v:=ORD(t[inx])-48;
        IF (v<0) OR (v>9) OR (res<-threshDec) OR ((res=-threshDec) & (v>8)) THEN 
          exit:=TRUE
        ELSE
          res:=res*10-v;
          INC(inx);
        END;
      END;
    ELSE
      WHILE (inx<l) & ~exit DO
        v:=ORD(t[inx])-48;
        IF (v<0) OR (v>9) OR (res>threshDec) OR ((res=threshDec) & (v>7)) THEN 
          exit:=TRUE
        ELSE
          res:=res*10+v;
          INC(inx);
        END;
      END;
    END;
  END;
  IF exit THEN 
    RETURN MIN(LONGINT)
  ELSE
    RETURN res;
  END;
END Val;

PROCEDURE ValResult*(t:StringT):INTEGER;
(** This function can be used to discover whether the string <t> can be converted 
    to a number, and which kind of integer is at least necessary for storing it.
    
    The IS??? constants defined for the return value have a numerical order defined 
    relative to each other:
    
    ISSHORTINT < ISINTEGER < ISLONGINT < ISOUTOFRANGE < (STRINGEMPTY, STRINGILLEGAL)
    
    This definition makes it easier to find out if e.g. a number is small enough to 
    be stored in a INTEGER variable.
    
    IF Strings.ValResult(txt)<=Strings.ISINTEGER THEN ...
    END;
    
    instead of
    
    IF (Strings.ValResult(txt)=Strings.ISSHORTINT) OR 
       (Strings.ValResult(txt)=Strings.ISINTEGER) THEN ... *)
CONST
  threshDec=MAX(LONGINT) DIV 10;
  threshHex=MAX(LONGINT) DIV 16;
  mThreshHex=MIN(LONGINT) DIV 16;
VAR                       
  inx,l,v,res:LONGINT;
  h:INTEGER;
  hex,exit,neg:BOOLEAN;
  ch:CHAR;
BEGIN
  RemoveTrailingSpaces(t);
  RemoveLeadingSpaces(t); 
  l:=Length(t);
  IF l<1 THEN RETURN STRINGEMPTY END;
  hex:=CAP(t[l-1])="H";
  IF hex THEN
    DEC(l);
    t[l]:=0X;
    IF l<1 THEN RETURN STRINGEMPTY END;
  END;  
  inx:=0;
  neg:=FALSE;
  res:=0;
  IF t[0]="+" THEN INC(inx) 
  ELSIF t[0]="-" THEN INC(inx); neg:=TRUE; END;
  IF t[l-1]="+" THEN DEC(l) 
  ELSIF t[l-1]="-" THEN DEC(l); neg:=TRUE; END;
  exit:=FALSE;
  IF hex THEN
    IF neg THEN 
      WHILE (inx<l) & ~exit DO
        ch:=CAP(t[inx]);
        IF (ch>="0") & (ch<="9") THEN
          v:=ORD(ch)-48;
        ELSIF (ch>="A") & (ch<="F") THEN
          v:=ORD(ch)-65+10;
        ELSE
          v:=-1;
        END;
        IF (v<0) OR (v>15) OR (res<mThreshHex) OR ((res=mThreshHex) & (v>0)) THEN 
          exit:=TRUE
        ELSE
          res:=res*16-v;
          INC(inx);
        END;
      END;
    ELSE
      WHILE (inx<l) & ~exit DO
        ch:=CAP(t[inx]);
        IF (ch>="0") & (ch<="9") THEN
          v:=ORD(ch)-48;
        ELSIF (ch>="A") & (ch<="F") THEN
          v:=ORD(ch)-65+10;
        ELSE
          v:=-1;
        END;
        IF (v<0) OR (v>15) OR (res>threshHex) THEN 
          exit:=TRUE
        ELSE
          res:=res*16+v;
          INC(inx);
        END;
      END;
    END;
  ELSE
    IF neg THEN 
      WHILE (inx<l) & ~exit DO
        v:=ORD(t[inx])-48;
        IF (v<0) OR (v>9) OR (res<-threshDec) OR ((res=-threshDec) & (v>8)) THEN 
          exit:=TRUE
        ELSE
          res:=res*10-v;
          INC(inx);
        END;
      END;
    ELSE
      WHILE (inx<l) & ~exit DO
        v:=ORD(t[inx])-48;
        IF (v<0) OR (v>9) OR (res>threshDec) OR ((res=threshDec) & (v>7)) THEN 
          exit:=TRUE
        ELSE
          res:=res*10+v;
          INC(inx);
        END;
      END;
    END;
  END;
  IF exit THEN 
    IF (v<0) OR (hex & (v>15)) OR (~hex & (v>9)) THEN RETURN STRINGILLEGAL ELSE RETURN ISOUTOFRANGE END;
  ELSE
    h:=ISLONGINT;
    IF (res>=MIN(INTEGER)) & (res<=MAX(INTEGER)) THEN DEC(h) END;
    IF (res>=MIN(SHORTINT)) & (res<=MAX(SHORTINT)) THEN DEC(h) END;
    RETURN h;
  END;
END ValResult;

PROCEDURE Str*(x:LONGINT; VAR t:StringT);
(** The number <x> is converted to a string and the result is stored in <t>.
    If <t> is not large enough to hold all characters of the number, 
    <t> is filled with "$" characters. *)
VAR
  i:LONGINT;
  maxlen:LONGINT;
  neg:BOOLEAN;
BEGIN
  maxlen:=LEN(t)-1;
  IF maxlen<1 THEN
    t[0]:=0X;
    RETURN;
  END;
  IF x=0 THEN
    t[0]:="0";
    t[1]:=0X;
  ELSE
    i:=0;
    neg:=x<0;
    IF neg THEN 
      IF x=MIN(LONGINT) THEN
        COPY("-2147483648",t);
        IF Length(t)#11 THEN
          FOR i:=0 TO maxlen-1 DO t[i]:="$" END;
          t[maxlen]:=0X;
        END;
        RETURN;
      ELSE
        x:=-x; 
      END;
    END;
    WHILE (x#0) & (i<maxlen) DO
      t[i]:=CHR(48+x MOD 10);
      x:=x DIV 10;
      INC(i);
    END;
    IF (x#0) OR (neg & (i>=maxlen)) THEN 
      FOR i:=0 TO maxlen-1 DO t[i]:="$" END;
      t[maxlen]:=0X;
    ELSE  
      IF neg THEN
        t[i]:="-";
        INC(i);
      END;
      t[i]:=0X;
      ReverseStringT(t,i);
    END;
  END;
END Str;   

PROCEDURE HexStr*(x:LONGINT; VAR t:StringT);
(** The number <x> is converted to a string of hexadecimal format and the result is stored 
    in <t>. At the end of the string an "h" is appended to indicate the hexadecimal 
    representation of the number.
    
    If <t> is not large enough to hold all characters of the number, <t> is filled with "$" 
    characters. Example: 0 becomes "0h", 15 becomes "Fh", 16 becomes "10h". *)
VAR
  i:LONGINT;
  digit:LONGINT;
  maxlen:LONGINT;
  neg:BOOLEAN;
BEGIN
  maxlen:=LEN(t)-1;
  IF maxlen<2 THEN
    IF maxlen=1 THEN t[0]:="$"; t[1]:=0X ELSE t[0]:=0X END;
    RETURN;
  END;
  IF x=0 THEN
    t[0]:="0";
    t[1]:="h";
    t[2]:=0X;
  ELSE
    t[0]:="h";
    i:=1;
    neg:=x<0;
    IF neg THEN 
      IF x=MIN(LONGINT) THEN
        COPY("-80000000h",t);
        IF Length(t)#10 THEN
          FOR i:=0 TO maxlen-1 DO t[i]:="$" END;
          t[maxlen]:=0X;
        END;
        RETURN;
      ELSE
        x:=-x; 
      END;
    END;
    WHILE (x#0) & (i<maxlen) DO
      digit:=x MOD 16;
      IF digit<10 THEN t[i]:=CHR(48+digit) ELSE t[i]:=CHR(55+digit) END;
      x:=x DIV 16;
      INC(i);
    END;
    IF (x#0) OR (neg & (i>=maxlen)) THEN 
      FOR i:=0 TO maxlen-1 DO t[i]:="$" END;
      t[maxlen]:=0X;
    ELSE  
      IF neg THEN
        t[i]:="-";
        INC(i);
      END;
      t[i]:=0X;
      ReverseStringT(t,i);
    END;
  END;
END HexStr;   

PROCEDURE InsertChar*(x:CHAR; VAR t:StringT; pos:LONGINT);
(** The character <x> is inserted into the string <t> at the position <pos> if 
    <t> provides space for it. *)
VAR
  i,l:LONGINT;
BEGIN
  l:=Length(t);
  IF l+1<LEN(t) THEN
    IF pos<1 THEN pos:=1 ELSIF pos>l+1 THEN pos:=l+1 END;
    FOR i:=l TO pos-1 BY -1 DO t[i+1]:=t[i]; END;
    t[pos-1]:=x;
  END;
END InsertChar;

PROCEDURE Insert*(VAR source:StringT; VAR dest:StringT; pos:LONGINT);
(** The string <source> is inserted into the string <dest> at the position <pos>. 
    If the maximum length of <dest> is insufficient to store the result only 
    the part of <source> fitting in <dest> is inserted. *)
VAR
  i,l,dif:LONGINT;         
BEGIN
  dif:=Length(source);
  l:=Length(dest);
  IF l+dif+1>LEN(dest) THEN dif:=LEN(dest)-l-1 END;
  IF pos<1 THEN pos:=1 ELSIF pos>l+1 THEN pos:=l+1 END;
  FOR i:=l TO pos-1 BY -1 DO dest[i+dif]:=dest[i]; END;
  FOR i:=pos-1 TO pos-2+dif DO dest[i]:=source[i+1-pos] END;
END Insert;

PROCEDURE LeftAlign*(VAR t:StringT; n:LONGINT);
(** The length of <t> is increased to <n> characters by appending blanks. If <t> has 
    already the appropriate length or is longer <t> remains unchanged. *)
VAR
  l,i:LONGINT;
  maxlen:LONGINT;
BEGIN
  maxlen:=LEN(t);
  IF n+1>maxlen THEN n:=maxlen-1; END;
  l:=Length(t);
  IF l<=n-1 THEN
    FOR i:=l TO n-1 DO t[i]:=" " END;
    t[n]:=0X;
  END;
END LeftAlign;

PROCEDURE RightAlign*(VAR t:StringT; n:LONGINT);
(** The length of <t> is increased to <n> characters by inserting blanks at the 
    beginning. If <t> has already the appropriate length or is longer <t> remains unchanged. *)
VAR
  l,i:LONGINT;
  maxlen:LONGINT;
BEGIN
  maxlen:=LEN(t);
  IF n+1>maxlen THEN n:=maxlen-1; END;
  l:=Length(t);
  IF l<n THEN
    t[n]:=0X;
    n:=n-l;
    FOR i:=l-1 TO 0 BY -1 DO t[i+n]:=t[i] END;
    FOR i:=0 TO n-1 DO t[i]:=" " END;
  END;
END RightAlign;

END powStrings.
