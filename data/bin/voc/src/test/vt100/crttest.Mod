MODULE crttest;

IMPORT crt, vt100, Console, Strings;


VAR tmpstr : ARRAY 32 OF CHAR;
BEGIN
(* test *)
      crt.EraseDisplay;
      crt.GotoXY (0, 0);

      COPY(vt100.CSI, tmpstr);
      Strings.Append(vt100.Yellow, tmpstr);
      (*Strings.Append(vt100.CSI, tmpstr);
      Strings.Append(vt100.BBlue, tmpstr);*)
      Strings.Append(vt100.CSI, tmpstr);
      Strings.Append(vt100.Blink, tmpstr);
      Strings.Append("hello", tmpstr);
      Strings.Append(vt100.CSI, tmpstr);
      Strings.Append(vt100.ResetAll, tmpstr);
      Console.String(tmpstr); Console.Ln;
      Console.Ln;

      COPY(vt100.CSI, tmpstr);
      Strings.Append (vt100.BRed, tmpstr);
      Strings.Append ("            ", tmpstr);
      Console.String (tmpstr); Console.Ln;
 
      COPY(vt100.CSI, tmpstr);
      Strings.Append (vt100.BBlue, tmpstr);
      Strings.Append ("            ", tmpstr);
      Console.String (tmpstr); Console.Ln;
 
      COPY(vt100.CSI, tmpstr);
      Strings.Append (vt100.BYellow, tmpstr);
      Strings.Append ("            ", tmpstr);
      Console.String (tmpstr); Console.Ln;

      COPY(vt100.CSI, tmpstr);
      Strings.Append(vt100.ResetAll, tmpstr);
      Console.String(tmpstr); Console.Ln;

      crt.HighVideo;
      Console.String("high video"); Console.Ln;
      Console.Ln;
      crt.LowVideo;
      Console.String("low video"); Console.Ln;

      crt.TextColor(crt.Red); Console.String("red"); Console.Ln;
      crt.TextColor(crt.Green); Console.String("green"); Console.Ln;
      crt.TextBackground(crt.Yellow); crt.TextColor(crt.Blue); Console.String("blue on yellow"); Console.Ln;

      Console.Ln; Console.Ln;
      crt.Delay (2000);


END crttest.
