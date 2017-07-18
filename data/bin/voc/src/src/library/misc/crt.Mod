MODULE crt;

IMPORT VT100, Platform, Out, Strings;

CONST

(* Foreground and background color constants *)
  Black*         = 0;
  Blue*          = 1;
  Green*         = 2;
  Cyan*          = 3;
  Red*           = 4;
  Magenta*       = 5;
  Brown*         = 6;
  LightGray*     = 7;

(* Foreground color constants *)
  DarkGray*      = 8;
  LightBlue*     = 9;
  LightGreen*    = 10;
  LightCyan*     = 11;
  LightRed*      = 12;
  LightMagenta*  = 13;
  Yellow*        = 14;
  White*         = 15;

(* Add-in for blinking *)
   Blink*         = 128;

   PROCEDURE EraseDisplay*;
   BEGIN
      VT100.ED(2);
   END EraseDisplay;

   PROCEDURE ClrScr*;
   BEGIN
      VT100.ED(2);
   END ClrScr;

   PROCEDURE ClrEol*;
   BEGIN
      VT100.EL(0);
   END ClrEol;

   PROCEDURE cursoroff*;
   BEGIN
      VT100.DECTCEMl;
   END cursoroff;

   PROCEDURE cursoron*;
   BEGIN
      VT100.DECTCEMh;
   END cursoron;

   PROCEDURE Delay*(ms: INTEGER);
   BEGIN Platform.Delay(ms) END Delay;

   PROCEDURE GotoXY* (x, y: INTEGER);
   BEGIN
      VT100.CUP (y, x);
   END GotoXY;

   PROCEDURE HighVideo*;
   VAR tmpstr: ARRAY 5 OF CHAR;
   BEGIN
      COPY (VT100.CSI, tmpstr);
      Strings.Append(VT100.Bold, tmpstr);
      Out.String(tmpstr);
   END HighVideo;

   PROCEDURE DelLine*;
   BEGIN
      VT100.EL(2);
   END DelLine;

   PROCEDURE InsLine*;
   BEGIN
      VT100.SCP;
      Out.Ln;
      VT100.RCP;
   END InsLine;

   PROCEDURE LowVideo*;
   VAR tmpstr : ARRAY 7 OF CHAR;
   BEGIN
      COPY (VT100.CSI, tmpstr);
      Strings.Append(VT100.ResetBold, tmpstr);
      Out.String(tmpstr);
   END LowVideo;

   PROCEDURE NormVideo*;
   VAR tmpstr : ARRAY 7 OF CHAR;
   BEGIN
      COPY(VT100.CSI, tmpstr);
      Strings.Append(VT100.ResetAll, tmpstr);
      Out.String(tmpstr);
   END NormVideo;

   PROCEDURE TextBackground*(color : SHORTINT);
   BEGIN
      IF    color = Black THEN
         VT100.SetAttr(VT100.BBlack)
      ELSIF color = Blue  THEN
         VT100.SetAttr(VT100.BBlue)
      ELSIF color = Green THEN
         VT100.SetAttr(VT100.BGreen)
      ELSIF color = Cyan  THEN
         VT100.SetAttr(VT100.BCyan)
      ELSIF color = Red   THEN
         VT100.SetAttr(VT100.BRed)
      ELSIF color = Magenta THEN
         VT100.SetAttr(VT100.BMagenta)
      ELSIF color = Brown   THEN
         VT100.SetAttr(VT100.BYellow)
      ELSIF color = LightGray  THEN
         VT100.SetAttr(VT100.BLightGray)
      ELSIF color = DarkGray   THEN
         VT100.SetAttr(VT100.BDarkGray)
      ELSIF color = LightBlue  THEN
         VT100.SetAttr(VT100.BLightBlue)
      ELSIF color = LightGreen THEN
         VT100.SetAttr(VT100.BLightBlue)
      ELSIF color = LightCyan  THEN
         VT100.SetAttr(VT100.BLightCyan)
      ELSIF color = LightRed THEN
         VT100.SetAttr(VT100.BLightRed)
      ELSIF color = LightMagenta THEN
         VT100.SetAttr(VT100.BLightMagenta)
      ELSIF color = Yellow THEN
         VT100.SetAttr(VT100.BLightYellow)
      ELSIF color = White THEN
         VT100.SetAttr(VT100.BWhite)
      END;
   END TextBackground;

   PROCEDURE TextColor*(color : SHORTINT);
   BEGIN
      IF    color = Black THEN
         VT100.SetAttr(VT100.Black)
      ELSIF color = Blue  THEN
         VT100.SetAttr(VT100.Blue)
      ELSIF color = Green THEN
         VT100.SetAttr(VT100.Green)
      ELSIF color = Cyan  THEN
         VT100.SetAttr(VT100.Cyan)
      ELSIF color = Red   THEN
         VT100.SetAttr(VT100.Red)
      ELSIF color = Magenta THEN
         VT100.SetAttr(VT100.Magenta)
      ELSIF color = Brown   THEN
         VT100.SetAttr(VT100.Yellow)
      ELSIF color = LightGray  THEN
         VT100.SetAttr(VT100.LightGray)
      ELSIF color = DarkGray   THEN
         VT100.SetAttr(VT100.DarkGray)
      ELSIF color = LightBlue  THEN
         VT100.SetAttr(VT100.LightBlue)
      ELSIF color = LightGreen THEN
         VT100.SetAttr(VT100.LightBlue)
      ELSIF color = LightCyan  THEN
         VT100.SetAttr(VT100.LightCyan)
      ELSIF color = LightRed THEN
         VT100.SetAttr(VT100.LightRed)
      ELSIF color = LightMagenta THEN
         VT100.SetAttr(VT100.LightMagenta)
      ELSIF color = Yellow THEN
         VT100.SetAttr(VT100.LightYellow)
      ELSIF color = White THEN
         VT100.SetAttr(VT100.White)
      END;
   END TextColor;

END crt.
