MODULE VT100;

IMPORT Out, Strings;
 (* reference http://en.wikipedia.org/wiki/ANSI_escape_code
  & http://misc.flogisoft.com/bash/tip_colors_and_formatting
 *)
CONST

   Escape* = 1BX;
   SynchronousIdle* = 16X;
   LeftCrotchet* = '[';

   (* formatting *)
   Bold*        = "1m";
   Dim*         = "2m";
   Underlined*  = "4m";
   Blink*       = "5m"; (* does not work with most emulators, works in tty and xterm *)
   Reverse*     = "7m"; (* invert the foreground and background colors *)
   Hidden*      = "8m"; (* useful for passwords *)

   (* reset *)
   ResetAll*        = "0m";
   ResetBold*       = "21m";
   ResetDim*        = "22m";
   ResetUnderlined* = "24m";
   ResetBlink*      = "25m";
   ResetReverse*    = "27m";
   ResetHidden*     = "28m";

   (* foreground colors *)
   Black*        = "30m";
   Red*          = "31m";
   Green*        = "32m";
   Yellow*       = "33m";
   Blue*         = "34m";
   Magenta*      = "35m";
   Cyan*         = "36m";
   LightGray*    = "37m";
   Default*      = "39m";
   DarkGray*     = "90m";
   LightRed*     = "91m";
   LightGreen*   = "92m";
   LightYellow*  = "93m";
   LightBlue*    = "94m";
   LightMagenta* = "95m";
   LightCyan*    = "96m";
   White*        = "97m";

   (* background colors *)
   BBlack*       = "40m";
   BRed*         = "41m";
   BGreen*       = "42m";
   BYellow*      = "43m";
   BBlue*        = "44m";
   BMagenta*     = "45m";
   BCyan*        = "46m";
   BLightGray*   = "47m";
   BDefault*     = "49m";
   BDarkGray*    = "100m";
   BLightRed*    = "101m";
   BLightGreen*  = "102m";
   BLightYellow* = "103m";
   BLightBlue*   = "104m";
   BLightMagenta*= "105m";
   BLightCyan*   = "106m";
   BWhite*       = "107m";

   VAR
      CSI* : ARRAY 5 OF CHAR;
      tmpstr : ARRAY 32 OF CHAR;

   (* IntToStr routine taken from
   https://github.com/romiras/Oberon-F-components/blob/master/Ott/Mod/IntStr.cp
   and modified to work on 64bit system,
   in order to avoid using oocIntStr, which has many dependencies *)
   PROCEDURE Reverse0 (VAR str : ARRAY OF CHAR; start, end : INTEGER);
   (* Reverses order of characters in the interval [start..end]. *)
   VAR
     h : CHAR;
   BEGIN
     WHILE start < end DO
       h := str[start]; str[start] := str[end]; str[end] := h;
       INC(start); DEC(end)
     END
   END Reverse0;

   PROCEDURE IntToStr*(int: LONGINT; VAR str: ARRAY OF CHAR);
   (* Converts the value of `int' to string form and copies the possibly truncated
   result to `str'. *)
   VAR
     b : ARRAY 21 OF CHAR;
     s, e: INTEGER;
     maxLength : SHORTINT; (* maximum number of digits representing a LONGINT value *)
   BEGIN
     IF SIZE(LONGINT) = 4 THEN maxLength := 11 END;
     IF SIZE(LONGINT) = 8 THEN maxLength := 20 END;
     (* build representation in string 'b' *)
     IF int = MIN(LONGINT) THEN (* smallest LONGINT, -int is an overflow *)
       IF SIZE(LONGINT) = 4 THEN
          b := "-2147483648";
          e := 11
       ELSE (* SIZE(LONGINT) = 8 *)
          b := "-9223372036854775808";
          e := 20
       END
     ELSE
       IF int < 0 THEN (* negative sign *)
         b[0] := "-"; int := -int; s := 1
       ELSE (* no sign *)
         s := 0
       END;
       e := s; (* 's' holds starting position of string *)
       REPEAT
         b[e] := CHR(int MOD 10+ORD("0"));
         int := int DIV 10;
         INC(e)
       UNTIL int = 0;
       b[e] := 0X;
       Reverse0(b, s, e-1);
     END;
       COPY(b, str) (* truncate output if necessary *)
   END IntToStr;

   PROCEDURE EscSeq0 (letter : ARRAY OF CHAR);
      VAR
       cmd : ARRAY 9 OF CHAR;
   BEGIN
      COPY(CSI, cmd);
      Strings.Append (letter, cmd);
      Out.String (cmd);
   END EscSeq0;

   PROCEDURE EscSeq (n : INTEGER; letter : ARRAY OF CHAR);
      VAR nstr : ARRAY 2 OF CHAR;
       cmd : ARRAY 7 OF CHAR;
   BEGIN
      IntToStr (n, nstr);
      COPY(CSI, cmd);
      Strings.Append (nstr, cmd);
      Strings.Append (letter, cmd);
      Out.String (cmd);
   END EscSeq;

  PROCEDURE EscSeqSwapped (n : INTEGER; letter : ARRAY OF CHAR);
      VAR nstr : ARRAY 2 OF CHAR;
       cmd : ARRAY 7 OF CHAR;
   BEGIN
      IntToStr (n, nstr);
      COPY(CSI, cmd);
      Strings.Append (letter, cmd);
      Strings.Append (nstr, cmd);
      Out.String (cmd);
   END EscSeqSwapped;

   PROCEDURE EscSeq2(n, m : INTEGER; letter : ARRAY OF CHAR);
      VAR nstr, mstr : ARRAY 5 OF CHAR;
          cmd : ARRAY 12 OF CHAR;
   BEGIN
      IntToStr(n, nstr);
      IntToStr(m, mstr);

      COPY (CSI, cmd);
      Strings.Append (nstr, cmd);
      Strings.Append (';', cmd);
      Strings.Append (mstr, cmd);
      Strings.Append (letter, cmd);
      Out.String (cmd);

   END EscSeq2;



(* Cursor up
   moves cursor n cells in the given direction. if the cursor is already at the edge of the screen, this has no effect *)

   PROCEDURE CUU*(n : INTEGER);
   BEGIN
      EscSeq (n, 'A');
   END CUU;

(* Cursor down
   moves cursor n cells in the given direction. if the cursor is already at the edge of the screen, this has no effect *)

   PROCEDURE CUD*(n : INTEGER);
   BEGIN
      EscSeq (n, 'B');
   END CUD;


(* Cursor forward
   moves cursor n cells in the given direction. if the cursor is already at the edge of the screen, this has no effect *)

   PROCEDURE CUF*(n : INTEGER);
   BEGIN
      EscSeq (n, 'C');
   END CUF;

(* Cursor back
   moves cursor n cells in the given direction. if the cursor is already at the edge of the screen, this has no effect *)

   PROCEDURE CUB*(n : INTEGER);
   BEGIN
      EscSeq (n, 'D');
   END CUB;

(* Curnser Next Line
   moves cursor to beginning of the line n lines down *)

   PROCEDURE CNL*( n: INTEGER);
   BEGIN
      EscSeq (n, 'E');
   END CNL;


(* Cursor Previous Line
   Moves cursor to beginning of the line n lines down *)

   PROCEDURE CPL*( n : INTEGER);
   BEGIN
      EscSeq (n, 'F');
   END CPL;

(* Cursor Horizontal Absolute
   Moves the cursor to column n *)

   PROCEDURE CHA*( n : INTEGER);
   BEGIN
      EscSeq (n, 'G');
   END CHA;

 (* Cursor position, moves cursor to row n, column m *)
   PROCEDURE CUP*(n, m : INTEGER);
   BEGIN
      EscSeq2 (n, m, 'H');
   END CUP;

   (* Erase Display
   if n = 0 then clears from cursor to end of the screen
   if n = 1 then clears from cursor to beginning of the screen
   if n = 2 then clears entire screen *)

   PROCEDURE ED* (n : INTEGER);
   BEGIN
      EscSeq(n, 'J');
   END ED;

   (* Erase in Line
      Erases part of the line. If n is zero, clear from cursor to the end of the line. If n is one, clear from cursor to beginning of the line. If n is two, clear entire line. Cursor position does not change *)
   PROCEDURE EL*( n : INTEGER);
   BEGIN
      EscSeq(n, 'K');
   END EL;

(* Scroll Up
   Scroll whole page up by n lines. New lines are added at the bottom *)
   PROCEDURE SU*( n : INTEGER);
   BEGIN
      EscSeq(n, 'S')
   END SU;

(* Scroll Down
   Scroll whole page down by n (default 1) lines. New lines are added at the top *)
   PROCEDURE SD*( n : INTEGER);
   BEGIN
      EscSeq(n, 'T');
   END SD;

(* Horizontal and Vertical Position,
   Moves the cursor to row n, column m. Both default to 1 if omitted. Same as CUP *)
   PROCEDURE HVP*(n, m : INTEGER);
   BEGIN
      EscSeq2 (n, m, 'f');
   END HVP;

(* Select Graphic Rendition
   Sets SGR parameters, including text color. After CSI can be zero or more parameters separated with ;. With no parameters, CSI m is treated as CSI 0 m (reset / normal), which is typical of most of the ANSI escape sequences *)

   PROCEDURE SGR*( n : INTEGER);
   BEGIN
         EscSeq(n, 'm');
   END SGR;

   PROCEDURE SGR2*( n, m : INTEGER);
   BEGIN
         EscSeq2(n, m, 'm');
   END SGR2;

(* Device Status Report
   Reports the cursor position (CPR) to the application as (as though typed at the keyboard) ESC[n;mR, where n is the row and m is the column.)  *)

   PROCEDURE DSR*(n : INTEGER);
   BEGIN
         EscSeq(6, 'n');
   END DSR;

(* Save Cursor Position *)

   PROCEDURE SCP*;
   BEGIN
      EscSeq0('s');
   END SCP;

(* Restore Cursor Position *)

   PROCEDURE RCP*;
   BEGIN
      EscSeq0('u');
   END RCP;

(* Hide the cursor *)
   PROCEDURE DECTCEMl*;
   BEGIN
      EscSeq0("?25l")
   END DECTCEMl;

(* shows the cursor *)
   PROCEDURE DECTCEMh*;
   BEGIN
      EscSeq0("?25h")
   END DECTCEMh;

   PROCEDURE SetAttr*(attr : ARRAY OF CHAR);
   VAR tmpstr : ARRAY 16 OF CHAR;
   BEGIN
      COPY(CSI, tmpstr);
      Strings.Append(attr, tmpstr);
      Out.String(tmpstr);
   END SetAttr;

   BEGIN
   (* init CSI sequence *)
      COPY(Escape, CSI);
      Strings.Append(LeftCrotchet, CSI);
(*
      EraseDisplay;
      GotoXY (0, 0);
      COPY(CSI, tmpstr);
      Strings.Append(Green, tmpstr);
      Strings.Append("hello", tmpstr);
      Out.String(tmpstr); Out.Ln;
*)
   END VT100.
