MODULE newttest;

IMPORT newt, oocIntStr, Platform;

CONST delayTime = 1000;

VAR 
  i, j, k : newt.Int32;
  str : ARRAY 32 OF CHAR;
  ch : CHAR;
  fo, co : newt.Component;
BEGIN
  i := newt.Init();
  newt.Cls();
  str := "hello world!";
  newt.DrawRootText(5, 7, str);
  newt.GetScreenSize(i, j);
  oocIntStr.IntToStr(i, str);
  newt.DrawRootText(5, 9, str);
  str := "x";
  newt.DrawRootText(7, 9, "x");
  oocIntStr.IntToStr(j, str);
  newt.DrawRootText(9, 9, str);

  newt.PushHelpLine("");
  newt.Refresh();
  Platform.Delay(delayTime);

  newt.PushHelpLine("A help line");
  newt.Refresh();
  Platform.Delay(delayTime);

  newt.PopHelpLine();
  newt.Refresh();
  Platform.Delay(delayTime);

  REPEAT
    ch := newt.GetKey();
    str[0] := ch;
    str[1] := 0X;
    newt.DrawRootText(5, 5, str);
    newt.PushHelpLine(str);
    newt.Refresh;
  UNTIL ch = ' ';

  (*
  newt.WaitForKey();
  newt.Delay(30);*)
  i := newt.Finished();
END newttest.
