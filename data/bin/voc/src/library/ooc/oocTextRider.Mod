(*	$Id: TextRider.Mod,v 1.29 2001/07/15 15:51:16 ooc-devel Exp $	*)
MODULE oocTextRider;

(*
    TextRider -  Text-based input/output of Oberon variables.       
    Copyright (C) 1998, 1999  Michael van Acken
    Copyright (C) 1997  Michael Griebling
 
    This module is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.
 
    This module is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General Public
    License along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*)

IMPORT
  Ascii := oocAscii, Channel := oocChannel, CharClass := oocCharClass, Strings := oocStrings, LRealStr := oocLRealStr, RealStr := oocRealStr, IntStr := oocIntStr, LRealConv := oocLRealConv, ConvTypes := oocConvTypes, Msg := oocMsg;

CONST
  done* = Channel.done;
  invalidFormat* = Channel.invalidFormat;
  valueOutOfRange* = 1;

  (* Scanner types *)
  undefined*=-1;
  char*=0; string*=1; int*=2; real*=3; bool*=4; set*=5;
  tab*=6; line*=7; ident*=8; error*=9; invalid*=10;
  
  (* Writer options *)
  noBuffering*=0;        (* when set output is not buffered.  This allows
                            interactive output prompts to appear as soon as
                            they are written *)

  (* Reader/Scanner options *)
  returnCtrlChars*=0;    (* when set returns EOL & TAB characters; otherwise
                            they are treated like whitespace *)
                           
  (* additional Scanner options *)
  interpretBools*=1;     (* when set returns truth values of the strings "TRUE"
                            and "FALSE"; otherwise returns the strings *)
  interpretSets*=2;      (* when set returns a set value of the string set
                            representation; otherwise returns the brace and
                            comma characters, and the numbers individually *)
  interpretStrings*=3;   (* when set returns a complete string contained
                            within open and closing quotes; otherwise returns
                            the quote characters and string contents as
                            separate tokens. *)
  useSignedNumbers*=4;   (* when set returns a complete signed number;
                            otherwise returns the sign characters and the
                            number tokens separately. *)
                            
  defReaderOptions*  = {};
  defWriterOptions*  = {};
  defScannerOptions* = defReaderOptions + {interpretBools..useSignedNumbers};

CONST
  maxLengthEol* = 2; (* system dependent, >= 2 *)
  maxLookahead = 2;  (* must be >= maxLengthEol and >=2 *)
  
TYPE
  Reader* = POINTER TO ReaderDesc;
  ReaderDesc* = RECORD
    res*: Msg.Msg;       (* READ-ONLY *)
    opt-: SET;                  (* current reader options (see above) *)
    byteReader-: Channel.Reader;(* only to be used by extensions of Reader *)
    base-: Channel.Channel;
    
    (* the end of line marker may contain the character 0X, which means its
       length must be stored in a separate field; the eol marker cannot be 
       empty, and it is required to contain control characters with an 
       ASCII code in 00X..1FX  *)
    eol-: ARRAY maxLengthEol OF CHAR;
      (* character sequence of end of line marker; all chars < 20X *)
    eolLen-: INTEGER;
      (* number of characters in `eol'; -1 means auto detect (the default) *)
    deferredEol: BOOLEAN;        (* TRUE iff eol detection is progress *)
    
    (* la: small buffer of characters, used to "peek" to the following
         characters in the input stream; managed as a FIFO 
       laRes: result `res' of read operation for corresponding character of
         `lookahead'
       laLen: number of characters in the lookahead FIFO
         invariant: 0 <= laLen < maxLookahead  *)
    la: ARRAY maxLookahead OF CHAR;
    laRes: ARRAY maxLookahead OF Msg.Msg;
    laLen: INTEGER;
  END;

  Writer* = POINTER TO WriterDesc;
  WriterDesc* = RECORD 
    res*: Msg.Msg;       (* READ-ONLY *)
    opt-: SET;                  (* current writer options (see above) *)
    byteWriter-: Channel.Writer;(* only to be used by extensions of Writer *)
    base-: Channel.Channel;
    
    eol: ARRAY maxLengthEol OF CHAR;
      (* character sequence of end of line marker *)
    eolLen: INTEGER;            (* number of characters in `eol' *)
  END;

  String* = ARRAY 256 OF CHAR;
  Scanner* = POINTER TO ScannerDesc;
  ScannerDesc* = RECORD
    res*: Msg.Msg;       (* READ-ONLY *)
    r-: Reader;      (* attached reader; exported only for extensions of Scanner *)
    base-: Channel.Channel;
    opt-: SET;       (* current scanner options (see above) *)
    type-: INTEGER;  (* scanned token type (see above) *)
    pos-: LONGINT;   (* position of current token in the channel *) 
    lines-: LONGINT; (* total of scanner eol markers; starts at 0 *)
    int-: LONGINT;   (* integer from channel *)
    real-: LONGREAL; (* real from channel *)
    char-: CHAR;     (* char from channel *)
    string-: String; (* string from channel *)
    set-: SET;       (* set from channel *)
    bool-: BOOLEAN;  (* boolean from channel *)
  END;



(*
> > Btw: I did _not_ fix the potential string buffer overruns in ReadLReal
> > and Scanner.ReadNum.
> 
> What should we do about this?  Make it POINTER TO ARRAY OF CHAR?  Or ADT
> Lib's dynamic String type?

IMO, the correct way to do this is to have the procedures accept
strings of arbitrary length, and return the nearest LONGREAL value in
any case.  The trick is to discard stuff like leading zeroes, cutoff
digits beyond the maximum number of significant digits, and to detect
overflows just by counting digits.  With these techniques and
MAX(LONGREAL) < 2E308, one could store any valid read number in a
buffer of 330 characters, and detect overflows and underflows for
longer real strings "by hand".  I implemented something similar for
integers, but it is a little bit more complex for reals.  Right now I
only signal "valueOutOfRange" if the real string is longer than 1023
characters, although I do scan to the end of the number before
reporting this.
*)



TYPE
  ErrorContext = POINTER TO ErrorContextDesc;
  ErrorContextDesc* = RECORD
     (* this record is exported, so that extensions of Channel can access the
        error descriptions by extending `ErrorContextDesc' *)
    (Msg.ContextDesc)
  END;


VAR
  errorContext: ErrorContext;

PROCEDURE GetError (code: Msg.Code): Msg.Msg;
  BEGIN
    RETURN Msg.New (errorContext, code)
  END GetError;

PROCEDURE (context: ErrorContext) GetTemplate* (msg: Msg.Msg; VAR templ: Msg.LString);
  VAR
    str: ARRAY 128 OF CHAR;
  BEGIN
    CASE msg. code OF
    | valueOutOfRange: str := "Number exceeded limits or string was too long"
    ELSE
      str := "";
      context. GetTemplate^ (msg, templ)
    END;
    IF (str # "") THEN
      COPY (str, templ)
    END
  END GetTemplate;



(* Reader methods 
   ------------------------------------------------------------------------ *)

PROCEDURE EolDetect (r: Reader; ch: CHAR);
(* pre: (r. eolLen < 0) & 
        (r. deferredEol OR (ch = Ascii.lf) OR (ch = Ascii.cr)) *)
  BEGIN
    IF (r. res = done) THEN
      IF r. deferredEol THEN  (* previous character was Ascii.cr *)
        IF (ch = Ascii.lf) THEN  (* eol sequence is cr+lf *)
          r. eol[1] := ch;
          r. eolLen := 2
        ELSE  (* eol is just cr *)
          r. eolLen := 1
        END;
        r. deferredEol := FALSE
      ELSE
        r. eol[0] := ch;
        IF (ch = Ascii.lf) THEN  (* eol is just lf *)
          r. eolLen := 1
        ELSE  (* (ch = Ascii.cr) *)
          r. deferredEol := TRUE
        END
      END
    END
  END EolDetect;

PROCEDURE Lookahead (r: Reader; len: INTEGER): BOOLEAN;
(* Tries to read `len' characters past the current position from the input
   stream.  Characters present in the lookahead FIFO are taken into account.
   After successful completion, `len' characters or more are available in
   the lookahead FIFO and result is TRUE.  Less than `len' characters
   may be available if the operation is aborted due to a read error.  In this
   case result is FALSE.  
   pre: (len >= 1) & (r.res = done) & (len <= maxLookahead) 
   post: (r.res = done)  *)
  VAR
    ch: CHAR;
  BEGIN
    ASSERT (r. res = done);
    IF (r. laLen = 0) OR (r. laRes[r. laLen-1] = done) THEN
      WHILE (r. laLen < len) & (r. byteReader. res = done) DO
        r. byteReader. ReadByte (ch);

        IF (r. eolLen < 0) & 
           (r. deferredEol OR (ch = Ascii.lf) OR (ch = Ascii.cr)) THEN
          EolDetect (r,  ch)
        END;

        r. la[r. laLen] := ch;
        r. laRes[r. laLen] := r. byteReader. res;
        INC (r. laLen)
      END
    END;
    RETURN (len <= r. laLen) & (r. laRes[len-1] = done)
  END Lookahead;

PROCEDURE Consume (r: Reader): CHAR;
(* note: it is safe to call this procedure with `r.res#done'
   post: r.res holds the result code for the returned character *)
  VAR
    ch: CHAR;
    i: INTEGER;
  BEGIN
    IF (r. res = done) THEN
      IF (r. laLen > 0) THEN
        ch := r. la[0];
        r. res := r. laRes[0];
        FOR i := 1 TO r. laLen-1 DO
          r. la[i-1] := r. la[i];
          r. laRes[i-1] := r. laRes[i]
        END;
        DEC (r. laLen)
      ELSE
        r. byteReader. ReadByte (ch);

        IF (r. byteReader. res # done) THEN
          r. res := r. byteReader. res;
          ch := 0X
        ELSIF (r. eolLen < 0) & 
              (r. deferredEol OR (ch = Ascii.lf) OR (ch = Ascii.cr)) THEN
          EolDetect (r, ch)
        END
      END
    ELSE
      ch := 0X
    END;
    RETURN ch
  END Consume;



(* The following methods read a value of the given type from the current
   position in the TextReader. Iff the value is invalid for its type, 
   'r.Res' returns 'invalidFormat'.
  *)
  
PROCEDURE (r: Reader) Pos* () : LONGINT;
  BEGIN
    RETURN r.byteReader.Pos()-r. laLen
  END Pos;

PROCEDURE (r: Reader) ClearError*;
  BEGIN
    r. byteReader. ClearError;
    r. res := done;
    r. deferredEol := FALSE
  END ClearError;

PROCEDURE (r: Reader) Available* () : LONGINT;
  VAR
    avail, laChars: LONGINT;
  BEGIN
    avail := r. byteReader. Available();
    laChars := 0;
    WHILE (laChars # r. laLen) & (r. laRes[laChars] = done) DO
      INC (laChars)
    END;
    IF (avail < 0) & (laChars > 0) THEN
      RETURN laChars
    ELSE
      RETURN avail+laChars
    END
  END Available;

PROCEDURE (r: Reader) SetPos* (newPos: LONGINT);
  BEGIN
    IF (r. res = done) THEN
      r. byteReader. SetPos(newPos);
      r. laLen := 0;                     (* lookahead characters not valid *)
      r. deferredEol := FALSE;           (* interrupt any eol detection *)
      r. res := r. byteReader. res
    END
  END SetPos;

PROCEDURE (r: Reader) SetOpts* (opts: SET);
(* Set the reader options `r.opt' which are defined above. *)
  BEGIN
    r.opt:=opts
  END SetOpts;

PROCEDURE (r: Reader) SetEol* (marker: ARRAY OF CHAR; markerLen: INTEGER);
(* Sets new end of line marker.  If the passed string marker does not fit into
   the field `eol', or it does contain a character >= " ", then 
   `r.Res()' is set to `invalidFormat'. 
   
   A marker length `markerLen=-1' enables auto detection of the end-of-line
   convention used by the channel.  The channel is required to use one of the
   following eol markers:
     LF      used by Unix
     CR      used by MacOS
     CR/LF   used by MS-DOS and Windows
     
   Enabling auto detection introduces a (small) inconsistency: if the first 
   line of the channel ends with a <CR>, then skipping over the complete eol 
   marker of this line is not done at once iff the next character is a <LF>. 
   All reading procedures except for `ReadChar' will automatically skip the
   spurious <LF>.
   
   Example: 
     Input is "line1<CR><LF>line2".
     The first ReadLine leaves the reading position between <CR> and <LF>,
     and a second ReadLine skips automagically the <LF> and returns "line2".
     But if the second operation is a ReadChar, it will return <LF>, not
     "l".
     
   The reason for this is that ReadChar is the only operation that can look
   at parts of an multi-byte end-of-line marker, while such a marker is an 
   atomic entity for all other read operations if the channel is read 
   sequentially.
   
   pre: (r.Res() = done) & 
        ((markerLen = -1) OR (1 <= markerLen < LEN (marker))) &
        (markerLen <= maxLengthEol) & (for all i: marker[i] < 20X) *)
  VAR
    i: INTEGER;
  BEGIN
    IF (r. res = done) THEN
      IF (markerLen < 1) & (markerLen # -1) OR (markerLen > maxLengthEol) THEN
        r. res := GetError (invalidFormat)
      ELSE
        FOR i := 0 TO markerLen-1 DO
          IF (marker[i] >= 20X) THEN
            r. res := GetError (invalidFormat)
          END;
          r. eol[i] := marker[i]
        END;
        r. eolLen := markerLen
      END
    END
  END SetEol;

PROCEDURE (r: Reader) ReadChar* (VAR ch: CHAR);
(* Read a character.  NOTE: no new characters will be read
   if an error has occurred. *)
  BEGIN
    ch := Consume (r)
  END ReadChar;
  
PROCEDURE (r: Reader) Eol*(): BOOLEAN;
(* Return TRUE if the character at the current position is the system-dependent
   end-of-line character sequence or the last character has been read.  
   If `r.res # done', then result is TRUE.  *)
  VAR
    i: INTEGER;
  BEGIN
    IF (r. res = done) THEN
      IF (r. eolLen > 0) THEN
        FOR i := 0 TO r. eolLen-1 DO
          IF Lookahead (r, i+1) THEN
            IF (r. la[i] # r. eol[i]) THEN
              RETURN FALSE
            END
          ELSE
            RETURN (r. laLen = 1)
          END
        END;
        RETURN TRUE
      ELSIF Lookahead (r, 1) THEN
        IF (r. eolLen > 0) THEN
          RETURN r. Eol()  (* the extra lookahead solved our problem *)
        ELSE  (* here holds: `r.la[0] # Ascii.lf' *)
          RETURN (r. la[0] = Ascii.cr)
        END
      ELSE
        RETURN TRUE  (* low-level error for next character *)
      END
    ELSE
      RETURN TRUE
    END
  END Eol;
 
PROCEDURE SkipBlanks (r: Reader);
  VAR
    ch: CHAR;
  BEGIN
    (* note: Ascii.lf must be a whitespace character, or with eol auto 
       detection a ReadFoo procedure may find a spurious Ascii.lf in its 
       input that it should never have seen *)
    IF (r. res = done) THEN
      IF (returnCtrlChars IN r.opt) THEN
        WHILE ~r.  Eol() & Lookahead (r, 1) & 
              (r. la[0] <= " ") &
              (r. la[0] # Ascii.ht) DO
          ch := Consume (r)
        END
      ELSE
        WHILE Lookahead (r, 1) & (r. la[0] <= " ") DO
          ch := Consume (r)
        END
      END
    END
  END SkipBlanks;

PROCEDURE SkipEol (r: Reader);
  VAR
    i: INTEGER;
    ch: CHAR;
  BEGIN
    IF r. Eol() THEN
      FOR i := 1 TO ABS (r. eolLen) DO
        (* note: if r.eolLen<-1 and we are looking at a CR+LF, only the CR 
           will be skipped at this time *)
        ch := Consume (r)
      END
    END
  END SkipEol;

PROCEDURE (r: Reader) ReadLn*;
  VAR 
    ch: CHAR;
  BEGIN
    WHILE ~r. Eol() DO
      ch := Consume (r)
    END;
    SkipEol (r)
  END ReadLn;

PROCEDURE (r: Reader) ReadString* (VAR s: ARRAY OF CHAR);
(* Pre: input = [whitespace] '"' {char} '"' | [whitespace] "'" {char} "'"
   Illegal chars terminate with invalidFormat.
 *)
  VAR
    cnt: INTEGER;
    quote: CHAR;
  BEGIN
    SkipBlanks (r);
    cnt := 0;
    
    IF (r. res = done) & Lookahead (r, 1) THEN
      IF (r. la[0] # '"') & (r. la[0] # "'") THEN
        r. res := GetError (invalidFormat)
      ELSE
        quote := Consume (r);
        LOOP
          IF ~Lookahead (r, 1) THEN
            quote := Consume (r);  (* low-level error *)
            EXIT
          ELSIF (r. la[0] < " ") THEN
            r. res := GetError (invalidFormat);
            EXIT
          ELSIF (r. la[0] = quote) THEN
            quote := Consume (r);  (* end quote *)
            EXIT
          ELSIF (cnt = LEN (s)-1) THEN
            r. res := GetError (valueOutOfRange);
            EXIT
          ELSE
            s[cnt] := Consume (r);
            INC (cnt)
          END
        END
      END
    ELSE
      quote := Consume (r)  (* low-level error *)
    END;
    
    s[cnt] := 0X
  END ReadString;

PROCEDURE (r: Reader) ReadLine* (VAR s: ARRAY OF CHAR);
(* Reads characters until an end of line character is encountered, or the 
   array `s' is full.  CAUTION: If reading multiple lines of input and an
   integer, real, etc. has just been read, the channel may be positioned
   at a eol character and this method will return an empty string. *)
  VAR
    cnt: INTEGER;
    dummy: CHAR;
  BEGIN
    (* check if eol auto detection left us a spurious lf in the input *)
    IF r. deferredEol & Lookahead (r, 1) & (r. la[0] = Ascii.lf) THEN
      dummy := Consume (r)
    END;
    
    (* read in the characters *)
    cnt := 0;
    WHILE ~r. Eol() & Lookahead (r, 1) & (cnt # LEN (s)-1) DO
      s[cnt] := Consume (r);
      INC (cnt)
    END;
    
    IF r. Eol() THEN
      SkipEol (r)
    ELSIF (cnt = LEN (s)-1)  THEN
      r. res := GetError (valueOutOfRange)
    END;
    s[cnt]:=0X (* terminate string *)
  END ReadLine;

PROCEDURE (r: Reader) ReadIdentifier* (VAR s: ARRAY OF CHAR);
(* Pre: input = [whitespace] letter {letter | digit}
 *)
  VAR
    cnt: INTEGER;
    ch: CHAR;
  BEGIN
    SkipBlanks (r);
    cnt := 0;
    
    IF (r. res = done) & Lookahead (r, 1) THEN
      IF ~CharClass.IsLetter(r. la[0]) THEN
        r. res := GetError (invalidFormat)
      ELSE
        s[0] := Consume (r);
        cnt := 1;
        LOOP
          IF ~(Lookahead (r, 1) &
               (CharClass.IsLetter(r. la[0]) OR
                CharClass.IsNumeric(r. la[0]))) THEN
            EXIT
          ELSIF (cnt = LEN (s)-1) THEN
            r. res := GetError (valueOutOfRange);
            EXIT
          ELSE
            s[cnt] := Consume (r);
            INC (cnt)
          END
        END
      END
    ELSE
      ch := Consume (r)  (* low-level error *)
    END;
    
    s[cnt]:=0X (* terminate string *)
  END ReadIdentifier;
 
PROCEDURE (r: Reader) ReadBool* (VAR bool: BOOLEAN);
(* Pre: input=[whitespace] ["TRUE"|"FALSE"]; Post: bool=TRUE iff input="TRUE"
   and bool=FALSE iff input="FALSE"; undefined otherwise *)
  VAR
    ident: ARRAY 8 OF CHAR;
  BEGIN
    r. ReadIdentifier (ident);
    IF (r. res = done) THEN
      IF (ident = "TRUE") THEN
        bool := TRUE
      ELSIF (ident = "FALSE") THEN
        bool := FALSE
      ELSE
        r. res := GetError (invalidFormat)
      END
    END
  END ReadBool;

PROCEDURE HexDigit (ch: CHAR) : BOOLEAN;
  BEGIN
    RETURN ((ch>="0") & (ch<="9")) OR ((ch>="A") & (ch<="F"))
  END HexDigit;

PROCEDURE HexToInt (str: ARRAY OF CHAR; VAR lint: LONGINT): BOOLEAN;
(* Returns the long integer constant `lint' in the string `str' according 
   to the format:
     IntConst = digit {hexdigit}

   Note: 80000000H-FFFFFFFFH are valid inputs which map to the negative
   integers. *)
  CONST
    BASE   = 16;
    MAXPAT = 8000000H;
  VAR
    d, pos: INTEGER;
  BEGIN    
    (* accept the hexadecimal input number *)
    lint:=0; pos:=0;
    LOOP
      (* read a digit *)
      d:=ORD(str[pos]);
      IF d=0 THEN RETURN TRUE
      ELSIF CharClass.IsNumeric(CHR(d)) THEN DEC(d, ORD("0"))
      ELSE (* A-F *) DEC(d, ORD("A")-10)
      END;
      
      (* check for overflow and adjustment *)
      IF (lint>=MAXPAT*2) OR (lint<0) THEN 
        RETURN FALSE (* overflow *)
      ELSIF (lint>=MAXPAT) & (d>=8) THEN 
        DEC(lint, MAXPAT*2)                          (* adjustment *)
      END;

      (* build up the number *)
      lint:=BASE*lint+d; 
      INC(pos)
    END
  END HexToInt;

PROCEDURE (r: Reader) ReadLInt* (VAR lint: LONGINT);
(* Returns the long integer constant n at the current position according to the
   format:
           IntConst = [whitespace] ["+"|"-"] digit {digit}        
*)
  CONST
    (* 2^31 has 11 digits, plus sign, plus 0, plus 0X = 14 *)
    buffer = 14;
  VAR
    str: ARRAY buffer OF CHAR;
    ch: CHAR;
    pos: INTEGER;
    res: SHORTINT;
    ignoreZeros: BOOLEAN;
  BEGIN 
    SkipBlanks (r);
    pos := 0;

    IF (r. res = done) & Lookahead (r, 1) THEN
      IF (r. la[0] = "+") OR (r. la[0] = "-") THEN
        str[0] := Consume (r);
        INC (pos);
        IF ~Lookahead (r, 1) THEN
          ch := Consume (r);         (* low-level error *)
          RETURN
        END
      END;
      
      IF CharClass.IsNumeric(r. la[0]) THEN
        str[pos] := "0";
        INC (pos);
        ignoreZeros := TRUE;
        LOOP
          IF ~(Lookahead (r, 1) & CharClass.IsNumeric(r. la[0])) THEN
            EXIT
          ELSE
            (* accumulate the digits; avoid overflow because of excessive 
               leading zeros *)
            ch := Consume (r);
            IF ~ignoreZeros OR (ch # "0") THEN
              IF (pos # buffer) THEN
                str[pos] := ch;
                INC (pos)
              END;
              ignoreZeros := FALSE
            END
          END
        END;
        
        (* convert to an integer *)
        IF (pos = buffer) THEN
          res := IntStr.strOutOfRange
        ELSE
          str[pos] := 0X; 
          IntStr.StrToInt (str, lint, res)
        END;

        (* set errors -- if needed *)
        IF (res = IntStr.strOutOfRange) THEN
          r. res := GetError (valueOutOfRange)
        ELSIF (res # IntStr.strAllRight) THEN
          r. res := GetError (invalidFormat)
        END
      ELSE
        r. res := GetError (invalidFormat)
      END
    ELSE
      ch := Consume (r)  (* low-level error *)
    END
  END ReadLInt;
  
PROCEDURE (r: Reader) ReadHex* (VAR lint: LONGINT);
(* Returns the long integer constant n at the current position according to the
   format:
     IntConst = [whitespace] digit {hexdigit}
                where hexDigit = "0".."9" | "A".."F" 
   Note: Numbers in the range 80000000H-FFFFFFFFH are read in as negative
   numbers.  If numbers like 80H-FFH are to be interpreted as negatives for
   SHORTINTs then neg = lint-100H or 8000H-FFFFH are to be interpreted as 
   negatives for INTEGERs then neg = lint-10000H.
*)
  CONST
    (* 2^32 has 8 digits, plus two digits, plus 0X = 11 *)
    buffer = 11;
  VAR
    str: ARRAY buffer OF CHAR;
    ch: CHAR;
    pos: INTEGER;
    ignoreZeros: BOOLEAN;
  BEGIN 
    SkipBlanks (r);
    pos := 0;

    IF (r. res = done) & Lookahead (r, 1) THEN
      IF CharClass.IsNumeric(r. la[0]) THEN
        str[pos] := "0";
        INC (pos);
        ignoreZeros := TRUE;
        LOOP
          IF ~(Lookahead (r, 1) & HexDigit (r. la[0])) THEN
            EXIT
          ELSE
            (* accumulate the digits; avoid overflow because of excessive 
               leading zeros *)
            ch := Consume (r);
            IF ~ignoreZeros OR (ch # "0") THEN
              IF (pos # buffer) THEN
                str[pos] := ch;
                INC (pos)
              END;
              ignoreZeros := FALSE
            END
          END
        END;
        
        (* convert to integer *)
        IF (pos = buffer) THEN
          r. res := GetError (valueOutOfRange)
        ELSE
          str[pos] := 0X;
          IF ~HexToInt(str, lint) THEN
            r. res := GetError (valueOutOfRange)
          END
        END
      ELSE
        r. res := GetError (invalidFormat)
      END
    ELSE
      ch := Consume (r)  (* low-level error *)
    END
  END ReadHex;

PROCEDURE (r: Reader) ReadInt * (VAR int: INTEGER);
(* as ReadLInt *)
  VAR
    lint: LONGINT;
  BEGIN
    r.ReadLInt(lint);
    IF (lint>MAX(INTEGER)) OR (lint<MIN(INTEGER)) THEN
      r. res := GetError (valueOutOfRange)
    ELSE
      int := SHORT(lint)
    END
  END ReadInt;

PROCEDURE (r: Reader) ReadSInt * (VAR sint: SHORTINT);
(* as ReadLInt *)
  VAR
    lint: LONGINT;
  BEGIN
    r.ReadLInt(lint);
    IF (lint>MAX(SHORTINT)) OR (lint<MIN(SHORTINT)) THEN
      r. res := GetError (valueOutOfRange)
    ELSE
      sint := SHORT(SHORT(lint))
    END
  END ReadSInt;

PROCEDURE (r: Reader) ReadLReal* (VAR lreal: LONGREAL);
(* Returns the long real constant `lreal' at the current position according to the 
   format:
     LongRealConst = [whitespace] ["+" | "-"] digit {digit} ["." {digit} [exponent]]
   where exponent = ("E" | "D") ("+" | "-") digit {digit}
   
   Note: Because of implementation restrictions, a real representation with 
   more than 1023 characters causes an `invalidFormat' error.
*)
  CONST
    buffer = 1024;
  VAR
    str: ARRAY buffer OF CHAR;
    res: SHORTINT;
    class: ConvTypes.ScanClass;
    state: ConvTypes.ScanState;
    pos: INTEGER;
    ch: CHAR;
  BEGIN    
    (* use state machine to ensure valid input *)
    SkipBlanks(r);
    pos := 0;
    
    IF (r. res = done) & Lookahead (r, 1) THEN
      LRealConv.ScanReal(r. la[0], class, state);
      
      IF (class = ConvTypes.valid) THEN
        str[0] := Consume (r);
        INC (pos);
        LOOP
          IF ~Lookahead (r, 1) THEN
            EXIT
          ELSE
            state.p (r. la[0], class, state);
            IF (class = ConvTypes.valid) THEN
              IF (pos < buffer) THEN
                str[pos] := Consume (r)
              END;
              INC (pos)
            ELSE
              EXIT
            END
          END
        END;
        
        IF (pos < buffer) THEN
          (* convert the real string *)
          str[pos] := 0X;
          LRealStr.StrToReal(str, lreal, res);

          (* set errors -- if needed *)
          IF (res = LRealStr.strOutOfRange) THEN
            r. res := GetError (valueOutOfRange)
          ELSIF (res # LRealStr.strAllRight) THEN
            r. res := GetError (invalidFormat)
          END
        ELSE
          r. res := GetError (invalidFormat)
        END
        
      ELSE
        r. res := GetError (invalidFormat)
      END
    ELSE
      ch := Consume (r)  (* low-level error *)
    END
  END ReadLReal;

PROCEDURE (r: Reader) ReadReal* (VAR real: REAL);
(* as ReadLReal *) 
  VAR
    n: LONGREAL;
    
  PROCEDURE ValidReal (value: LONGREAL): BOOLEAN;
  (* Returns TRUE iff `value' is mapped onto the range MIN(REAL)..MAX(REAL) if
     it would be converted to a REAL value.  Rounding to nearest/evan is 
     assumed.  Note that this depends on REAL being IEEE single precision.  
     The same code is used in the OOC frontend (module StdTypes.ValidReal).  *)
    CONST
      eps = 1.0141204801825835D+31;
      (* equals 2^103, half of the difference between two consecutive IEEE 
         single precision floating point numbers with maximum exponent *)
    BEGIN
      RETURN (MIN (REAL)-eps < value) & (value < MAX (REAL)+eps)
    END ValidReal;

  BEGIN
    r.ReadLReal(n);
    IF ValidReal (n) THEN
      real := SHORT(n)
    ELSE
      r. res := GetError (valueOutOfRange)
    END
  END ReadReal;

PROCEDURE (r: Reader) ReadSet* (VAR s: SET);
(* Read a set described in mathematical set notation into 's'.
   Pre: "{Element, ..., Element}"; Post: s={Element, ..., Element}
   where Element = number [".." number] and 0 <= number <= 31 *)
  VAR
    ch: CHAR;

  PROCEDURE ReadRange (): SET;
    VAR
      low, high: SHORTINT;
    BEGIN
      r. ReadSInt (low);
      high := low;
      
      IF (r. res = done) THEN
        IF ((low < 0) OR (low > MAX (SET))) THEN
          r. res := GetError (valueOutOfRange);
          RETURN {}
        ELSIF Lookahead (r, 2) & (r. la[0] = ".") & (r. la[1] = ".") THEN
          ch := Consume (r);
          ch := Consume (r);
          SkipBlanks (r);
          r. ReadSInt (high);
          IF (r. res = done) & 
             ((high < 0) OR (high > MAX (SET)) OR (high < low)) THEN
            r. res := GetError (valueOutOfRange);
            RETURN {}
          END
        END
      END;
      SkipBlanks (r);
      RETURN {low..high}
    END ReadRange;

  BEGIN
    (* ensure a valid start *)
    SkipBlanks (r);
    
    IF (r. res = done) & Lookahead (r, 1) THEN
      IF (r. la[0] = "{") THEN
        s := {};
        ch := Consume (r);
        SkipBlanks (r);
        IF (r. res = done) & Lookahead (r, 1) THEN
          IF (r. la[0] # "}") THEN
            s := s + ReadRange();
            WHILE (r. res = done) & Lookahead (r, 1) & (r. la[0] = ",") DO
              ch := Consume (r);
              SkipBlanks (r);
              s := s + ReadRange()
            END
          END;
          IF (r. res = done) & (r. la[0] = "}") THEN
            ch := Consume (r)
          ELSE
            r. res := GetError (invalidFormat)
          END
        ELSE
          ch := Consume (r)  (* low-level error *)
        END
      ELSE
        r. res := GetError (invalidFormat)
      END
    ELSE
      ch := Consume (r)  (* low-level error *)
    END
  END ReadSet;
 

(* Scanner methods 
   ------------------------------------------------------------------------ *)
   
PROCEDURE SkipSpaces (s: Scanner);
(* Skip white space as defined by the scanner options.  *)
  VAR
    ch: CHAR;
  BEGIN  (* pre: (s. res = done) *)
    (* note: Ascii.lf must be a whitespace character, or with eol auto 
       detection a ReadFoo procedure may find a spurious Ascii.lf in its 
       input that it should never have seen *)
    ASSERT (s. res = done);
    IF (returnCtrlChars IN s. opt) THEN
      WHILE ~s. r.  Eol() & Lookahead (s. r, 1) & 
            (s. r. la[0] <= " ") &
            (s. r. la[0] # Ascii.ht) DO
        ch := Consume (s. r)
      END
    ELSE
      WHILE Lookahead (s. r, 1) & (s. r. la[0] <= " ") DO
        IF s. r. Eol() THEN
          INC (s. lines);
          SkipEol (s. r)
        ELSE
          ch := Consume (s. r)
        END
      END
    END;
    s. res := s. r. res
  END SkipSpaces;

PROCEDURE (s: Scanner) Pos* () : LONGINT;
(* Position of the look-ahead character *)
  BEGIN
    RETURN s.r.Pos()
  END Pos;
  
PROCEDURE (s: Scanner) ClearError*;
  BEGIN
    s. r. ClearError;
    s. res := done;
    s. type := undefined
  END ClearError;

PROCEDURE (s: Scanner) Available* () : LONGINT;
(* Position of the look-ahead character *)
  BEGIN
    RETURN s.r.Available()
  END Available;

PROCEDURE (s: Scanner) SetPos* (pos: LONGINT);
  BEGIN
    IF (s. res = done) THEN
      s. r. SetPos(pos);
      s. res := s. r. res
    END
  END SetPos;

(* Scan for the next token *)
PROCEDURE (s: Scanner) Scan*;
(* Note: Because of implementation restrictions, a real representation with 
   more than 1023 characters causes an `invalidFormat' error.  *)
  CONST
    buffer = 1024;
  VAR
    ch: CHAR; str: ARRAY buffer OF CHAR; pos: INTEGER; res: SHORTINT;
    
  PROCEDURE ReadNum;
  (* pre: current lookahead character is digit or sign *)
    PROCEDURE Get;
      VAR
        dummy: BOOLEAN;
      BEGIN
        IF (pos < buffer) THEN
          str[pos] := Consume (s. r)
        END; 
        INC (pos);
        IF (s. r. res = done) THEN
          dummy := Lookahead (s. r, 1)
        ELSE
          s. r. la[0] := 0X
        END
      END Get;
    
    PROCEDURE LA (): CHAR;
      BEGIN
        RETURN s. r. la[0]
      END LA;
    
    BEGIN
      IF (s. r. res = done) & Lookahead (s. r, 1) THEN
        pos:=0;
        
        IF (LA() = "-") OR (LA() = "+") THEN
          Get
        END;

        (* read leading digits *)
        IF ~CharClass.IsNumeric (LA()) THEN
          s. res := GetError (invalidFormat);
          RETURN
        ELSE
          WHILE HexDigit (LA()) DO Get END
        END;

        (* check for reals or hexadecimals *)
        IF (LA() = ".") THEN  (* real number *)
          s.type:=real;
          Get;
          (* read trailing digits *)
          WHILE CharClass.IsNumeric (LA()) DO Get END;
          (* read the exponent *)
          IF (LA() = "E") OR (LA() = "e") THEN
            Get;
            IF (pos-1 < buffer) THEN str[pos-1] := "E" END;
            IF (LA() = "-") OR (LA() = "+") THEN Get END;
            (* read leading digits *)
            IF ~CharClass.IsNumeric (LA()) THEN
              s. res := GetError (invalidFormat);
              RETURN
            ELSE
              WHILE CharClass.IsNumeric (LA()) DO Get END
            END
          END;

          (* convert to real *)
          IF (pos < buffer) THEN
            str[pos]:=0X;
            LRealStr.StrToReal(str, s.real, res);

            (* set errors -- if needed *)
            IF (res # LRealStr.strAllRight) THEN
              s. res := GetError (invalidFormat)
            END
          ELSE
            s. res := GetError (invalidFormat)
          END
          
        ELSIF (LA() = "H") THEN (* hexadecimal integer *)
          s.type:=int; str[pos]:=0X; 
          IF ~HexToInt (str, s. int) THEN
            s. res := GetError (invalidFormat)
          END;
          Get  (* get rid of "H" *)

        ELSE (* just an integer *)
          s.type:=int;
          str[pos]:=0X;
          IntStr.StrToInt(str, s.int, res);
          IF res#IntStr.strAllRight THEN 
            s. res := GetError (invalidFormat)
          END             
        END
      END
    END ReadNum;
    
  PROCEDURE SetType (type: SHORTINT);
    BEGIN
      s. type := type
    END SetType;
  
  BEGIN
    IF (s. type < error) THEN  (* `error' and `invalid' are sticky *)
      (* if `s.type' does not signal an error, then `s.res=done' *)
      SkipSpaces (s); 

      IF (s. res = done) & Lookahead (s. r, 1) THEN
        s.pos:=s.Pos();

        IF s. r. Eol() THEN
          s. type := line;
          SkipEol (s. r);
          INC (s. lines)
        ELSE
          CASE s. r. la[0] OF
          | '"', "'":
            IF (interpretStrings IN s. opt) THEN
              s. r. ReadString (s. string); 
              SetType (string)
            ELSE
              s. r. ReadChar (s.char);
              SetType (char)
            END
          | "a".."z", "A".."Z": 
            s. r. ReadIdentifier (s. string);
            IF (s. r. res = done) & (interpretBools IN s.opt) &
               ((s. string = "TRUE") OR (s. string="FALSE")) THEN
              s. bool := (s. string = "TRUE");
              SetType (bool)
            ELSE
              SetType (ident)
            END
          | "+", "-":
            IF (useSignedNumbers IN s.opt) THEN
              ReadNum
            ELSE
              s. r. ReadChar (s.char);
              SetType (char)
            END
          | "0".."9": (* integer or real *)
            ReadNum
          | "{":
            IF (interpretSets IN s. opt) THEN
              s. r. ReadSet (s. set); 
              SetType (set)
            ELSE
              s. r. ReadChar (s.char);
              SetType (char)
            END
          ELSE
            s. r. ReadChar (s.char);
            IF (s. char = Ascii.ht) THEN
              SetType (tab)
            ELSE
              SetType (char)
            END
          END
        END
      ELSE
        ch := Consume (s. r)  (* low-level error *)
      END;

      IF (s. r. res # done) & (s. res = done) THEN
          s. res := s. r. res
      END;
      IF (s. res # done) & (s. res. context = errorContext) THEN
        IF ((s. res. code = invalidFormat) OR
            (s. res. code = valueOutOfRange)) THEN
          s. type := invalid
        ELSE
          s. type := error
        END
      END
    END
  END Scan;

(* Set the scanner options `s.opt' which are defined above. *)
PROCEDURE (s: Scanner) SetOpts* (opts: SET);
  BEGIN
    s.opt:=opts;
    s.r.opt:=opts*{returnCtrlChars}  (* adjust the reader options as well *)
  END SetOpts;

PROCEDURE (s: Scanner) SetEol* (marker: ARRAY OF CHAR; markerLen: INTEGER);
(* As Reader.SetEol.  *)
  BEGIN
    s. r. SetEol (marker, markerLen)
  END SetEol;


(* Writer methods 
   ------------------------------------------------------------------------ *)

(* The following write methods write the value as a string to the 
   underlying Channel.
 *)
 
PROCEDURE (w: Writer) Pos* () : LONGINT;
  BEGIN
    RETURN w.byteWriter.Pos()
  END Pos;

PROCEDURE (w: Writer) SetPos* (newPos: LONGINT);
  BEGIN
    IF (w. res = done) THEN
      w.byteWriter.SetPos(newPos);
      w. res := w. byteWriter. res
    END
  END SetPos;

PROCEDURE (w: Writer) ClearError*;
  BEGIN
    w.byteWriter.ClearError;
    w.res := done
  END ClearError;

PROCEDURE (w: Writer) SetOpts* (opts: SET);
(* Set the writer options `w.opt' which are defined above. *)
  BEGIN
    w.opt:=opts
  END SetOpts;

PROCEDURE (w: Writer) SetEol* (marker: ARRAY OF CHAR; markerLen: INTEGER);
(* Sets new end of line marker.  If the passed string marker does not fit into
   the field `eol', then `w.res' is set to `invalidFormat'.  The empty
   marker is permitted.  The default value for newly created writer is 
   `CharClass.systemEol'.
   pre: (w.res = done) & (0 <= markerLen < LEN (marker)) &
        (markerLen <= maxLengthEol)  *)
  VAR
    i: INTEGER;
  BEGIN
    IF (w. res = done) THEN
      IF (markerLen < 0) OR (markerLen > maxLengthEol) THEN
        w. res := GetError (invalidFormat)
      ELSE
        FOR i := 0 TO markerLen-1 DO
          w. eol[i] := marker[i]
        END;
        w. eolLen := markerLen
      END
    END
  END SetEol;

(* The terminating 0X is not written *)
PROCEDURE (w: Writer) WriteString*(s(*[NO_COPY]*): ARRAY OF CHAR); (* this will slow it down a little, but I cannot imagine a better and simpler solution; -- noch *)
  BEGIN
    IF (w. res = done) THEN
      w. byteWriter. WriteBytes (s, 0, Strings.Length (s));
      w. res := w. byteWriter. res;
      IF (noBuffering IN w.opt) & (w. res = done) THEN
        w. base. Flush;
        w. res := w. base. res
      END
    END
  END WriteString;

PROCEDURE (w: Writer) WriteBool*(bool: BOOLEAN);
  BEGIN
    IF bool THEN w. WriteString ("TRUE")
    ELSE w. WriteString ("FALSE")
    END
  END WriteBool;
  
PROCEDURE (w: Writer) WriteChar*(ch: CHAR);
  BEGIN
    IF (w. res = done) THEN
      w.byteWriter.WriteByte(ch);
      IF (noBuffering IN w.opt) & (w. res = done) THEN
        w. base. Flush;
        w. res := w. base. res
      END
    END
  END WriteChar;
  
PROCEDURE WritePad (w: Writer; n: LONGINT);
  BEGIN
    (* output padding *)
    WHILE n>0 DO w.WriteChar(" "); DEC(n) END  
  END WritePad;
  
(* Convert 'sint' to a string of at least 'n' chars and write it to the
   underlying channel. If 'n' is too small it will be extended. If 'n'
   is greater then nessesary spaces will be added after the number, i.e.
   it is left justified. *)
PROCEDURE (w: Writer) WriteLInt*(lint: LONGINT; n: LONGINT);
  VAR
    val: ARRAY 16 OF CHAR;
  BEGIN
    (* convert to a string *)
    IntStr.IntToStr(lint, val);
    
    (* output any required padding *)
    WritePad(w, n-Strings.Length(val));
    
    (* output the string *)
    w.WriteString(val)
  END WriteLInt;
  
PROCEDURE (w: Writer) WriteSInt* (sint: SHORTINT; n: LONGINT);
  BEGIN
    w.WriteLInt(sint, n)
  END WriteSInt;

PROCEDURE (w: Writer) WriteInt* (int: INTEGER; n: LONGINT);
  BEGIN
    w.WriteLInt(int, n)
  END WriteInt;
 
(* Write `lint' as a heximal number using `d' digits. 
   If `d' <= 0 then `lint' is written using 8 digits. *)
PROCEDURE (w: Writer) WriteHex* (lint: LONGINT; d: LONGINT);
  PROCEDURE WriteHexDigits(w: Writer; VAR n: LONGINT; digits: LONGINT);
    CONST
      BASE=16;
    VAR
      dig: LONGINT;
    BEGIN
      (* output padding digits *)
      WHILE digits>8 DO 
        IF n<0 THEN w.WriteChar("F") ELSE w.WriteChar("0") END;
        DEC(digits)
      END;

      (* output the actual number *)
      WHILE digits>0 DO
        DEC(digits);
        dig := ASH(n, -4*digits) MOD BASE;
        IF dig<=9 THEN w.WriteChar(CHR(ORD("0") + dig)) 
        ELSE w.WriteChar(CHR(ORD("A") - 10 + dig)) 
        END
      END
    END WriteHexDigits;

  BEGIN
    IF d<=0 THEN d:=8 END;
    WriteHexDigits(w, lint, d)
  END WriteHex;

PROCEDURE (w: Writer) WriteLReal*(lreal: LONGREAL; n, k: LONGINT);
 (* The call to WriteLongReal(lreal, n, k) shall write to the underlying
    channel a formatted string corresponding to the value of `lreal' in
    floating-point form.  A sign shall be included only for negative
    values.  One significant digit shall be included in the whole number
    part.  The signed exponent part shall be included only if the exponent
    value is not 0.  If the value of `k' is greater than 0, that
    number of significant digits shall be included, otherwise an
    implementation-defined number of significant digits shall be
    included.  The decimal point shall not be included if there are no
    significant digits in the fractional part.  The complete formatted
    number will be right-justified in a field of width `n'.  If 'n' is 
    too small it will be extended.
    
    For example: (n=9)
    
    value:     3923009     39.23009     0.0003923009
      k
      1             4E+6        4E+1         4E-4 
      2           3.9E+6      3.9E+1       3.9E-4
      5        3.9230E+6   3.9230E+1    3.9230E-4
 *)
  VAR
    val: ARRAY 128 OF CHAR;
  BEGIN
    (* convert to a string *)
    LRealStr.RealToFloat(lreal, SHORT(k), val);
    
    (* output any required padding *)
    WritePad(w, n-Strings.Length(val));

    (* output the string *)
    w.WriteString(val);
  END WriteLReal;

PROCEDURE (w: Writer) WriteReal*(real: REAL; n, k: LONGINT);
(* As WriteLReal *)
  VAR
    val: ARRAY 128 OF CHAR;
  BEGIN
    (* convert to a string *)
    RealStr.RealToFloat(real, SHORT(k), val);
    
    (* output any required padding *)
    WritePad(w, n-Strings.Length(val));

    (* output the string *)
    w.WriteString(val)
  END WriteReal;

PROCEDURE (w: Writer) WriteLRealFix*(VAR lreal: LONGREAL; n, k: LONGINT);
 (* 
    The call WriteLRealFix(lreal, n, k) shall output to the underlying
    channel the formatted string corresponding to the value of `lreal' in
    fixed-point form.  A sign shall be included only for negative values.
    At least one digit shall be included in the whole number part.  The
    value shall be rounded to the given value of `k' relative to the
    decimal point.  The decimal point shall be suppressed if `k' is
    less than 0. The complete formatted number will be right-justified 
    in a field of width `n'.  If 'n' is too small it will be extended.
    
    For example: (n=12)
    
    value:        3923009         3.923009   0.0003923009
      k
     -5             3920000             0          0 
     -2             3923010             0          0
     -1             3923009             4          0 
      0            3923009.            4.         0. 
      1           3923009.0           3.9        0.0
      4        3923009.0000        3.9230     0.0004       
 *)
  VAR
    val: ARRAY 128 OF CHAR;
  BEGIN
    (* convert to a string *)
    LRealStr.RealToFixed(lreal, SHORT(k), val);
    
    (* output any required padding *)
    WritePad(w, n-Strings.Length(val));
    
    (* output the string *)
    w.WriteString(val)
  END WriteLRealFix;

PROCEDURE (w: Writer) WriteRealFix*(real: REAL; n, k: LONGINT);
(* As WriteLongRealFix *)
  VAR
    val: ARRAY 128 OF CHAR;
  BEGIN
    (* convert to a string *)
    RealStr.RealToFixed(real, SHORT(k), val);
    
    (* output any required padding *)
    WritePad(w, n-Strings.Length(val));
    
    (* output the string *)
    w.WriteString(val)
  END WriteRealFix;

PROCEDURE (w: Writer) WriteLRealEng*(VAR lreal: LONGREAL; n, k: LONGINT);
 (* 
    Converts the value of real to floating-point string form, with 
    `k' significant figures, and writes the resultant value,
    right-justified in a field of width `n' to the underlying channel.
    If 'n' is too small it will be extended. The number is scaled with 
    one to three digits in the whole number part and with an exponent 
    that is a multiple of three.
     
    For example: n=9
    
    value:     3923009     39.23009   0.0003923009
      k
      1             4E+6        40         400E-6 
      2           3.9E+6        39         390E-6
      5        3.9230E+6    39.230      392.30E-6     
  *)
  VAR
    val: ARRAY 128 OF CHAR;
  BEGIN
    (* convert to a string *)
    LRealStr.RealToEng(lreal, SHORT(k), val);
    
    (* output any required padding *)
    WritePad(w, n-Strings.Length(val));
    
    (* output the string *)
    w.WriteString(val)
  END WriteLRealEng;

PROCEDURE (w: Writer) WriteRealEng*(real: REAL; n, k: LONGINT);
(* As WriteLRealEng *)
  VAR
    val: ARRAY 128 OF CHAR;
  BEGIN
    (* convert to a string *)
    RealStr.RealToEng(real, SHORT(k), val);
    
    (* output any required padding *)
    WritePad(w, n-Strings.Length(val));
    
    (* output the string *)
    w.WriteString(val)
  END WriteRealEng;
  
PROCEDURE (w: Writer) WriteSet*(s: SET);
(* Write 's' in mathematical set notation.
   Pre: x = {Element, ..., Element}; Post: write "{Element, ..., Element}" 
   where Element = number [".." number] and 0 <= number <= 31 *)
  VAR
    bit, lo: SHORTINT; addComma: BOOLEAN;
  BEGIN
    w.WriteChar("{"); bit:=0; addComma:=FALSE;
    WHILE bit<=MAX(SET) DO      
      IF bit IN s THEN
        lo:=bit;
        WHILE (bit<MAX(SET)) & (bit+1 IN s) DO INC(bit) END; (* check for runs *)
        
        (* output the set element(s) *)
        IF addComma THEN w.WriteString(", ") ELSE addComma:=TRUE END;
        w.WriteInt(lo, 0);
        IF lo<bit THEN
          w.WriteString(".."); w.WriteInt(bit, 0)
        END
      END;
      INC(bit)
    END;
    w.WriteChar("}");
  END WriteSet;
 
PROCEDURE (w: Writer) WriteLn*;
(* Write a newline *)
  VAR
    i: INTEGER;
  BEGIN
    FOR i := 0 TO w. eolLen-1 DO
      w. WriteChar (w.eol[i])
    END
  END WriteLn;


(* Reader Procedures
   ------------------------------------------------------------------------ *)

PROCEDURE InitReader* (r: Reader; ch: Channel.Channel);
  BEGIN
    r. res := done;
    r. opt := defReaderOptions;
    r. byteReader := ch.NewReader();
    r. base := ch;
    r. eolLen := -1;
    r. deferredEol := FALSE;
    r. laLen := 0
  END InitReader;

PROCEDURE ConnectReader*(ch: Channel.Channel): Reader;
  VAR
    r: Reader;
  BEGIN
    NEW(r);
    InitReader (r, ch);
    IF (r. byteReader = NIL) THEN
      RETURN NIL
    ELSE
      RETURN r
    END
  END ConnectReader;
  
(* Writer Procedures
   ------------------------------------------------------------------------ *)

PROCEDURE InitWriter* (w: Writer; ch: Channel.Channel);
  VAR
    i: INTEGER;
  BEGIN
    w. res := done;
    w. opt := defWriterOptions;
    w. byteWriter := ch.NewWriter();
    w. base := ch;
    w. eolLen := Strings.Length (CharClass.systemEol);
    FOR i := 0 TO w. eolLen-1 DO
      w. eol[i] := CharClass.systemEol[i]
    END
  END InitWriter;

PROCEDURE ConnectWriter*(ch: Channel.Channel): Writer;
  VAR
    w: Writer;
  BEGIN
    NEW(w);
    InitWriter (w, ch);
    IF (w. byteWriter = NIL) THEN
      RETURN NIL
    ELSE
      RETURN w
    END
  END ConnectWriter;

(* Scanner Procedures
   ------------------------------------------------------------------------ *)

PROCEDURE InitScanner* (s: Scanner; ch: Channel.Channel);
  BEGIN
    s. res := done;
    s.r:=ConnectReader(ch);
    s.opt:=defScannerOptions;
    s.type:=undefined;
    s.lines:=0;
    s. base := ch;
  END InitScanner;

PROCEDURE ConnectScanner*(ch: Channel.Channel): Scanner;
  VAR
    s: Scanner;
  BEGIN
    NEW(s);
    InitScanner (s, ch);
    IF (s. r = NIL) THEN
      RETURN NIL
    ELSE
      RETURN s
    END
  END ConnectScanner;

BEGIN
  NEW (errorContext);
  Msg.InitContext (errorContext, "OOC:Core:TextRider")
END oocTextRider.
