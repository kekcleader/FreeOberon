(* Test that interrupt and quit are handled correctly. *)
MODULE SignalTest;
IMPORT Console, Platform, Modules, Files, SYSTEM;

VAR result: Files.File; rider: Files.Rider;

PROCEDURE ws(s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) DO Files.Write(rider, s[i]); INC(i) END
END ws;

PROCEDURE wl;
BEGIN Files.Write(rider, 0AX) END wl;

PROCEDURE wi(i: LONGINT);
VAR s: ARRAY 30 OF CHAR; j: INTEGER;
BEGIN
  j := 0;
  IF i<0 THEN s[0] := '-'; INC(j) END;
  s[j] := CHR(i MOD 10 + 48); INC(j); i := i DIV 10;
  WHILE i > 0 DO s[j] := CHR(i MOD 10 + 48); INC(j); i := i DIV 10 END;
  WHILE j > 0 DO DEC(j); Files.Write(rider, s[j]) END
END wi;


PROCEDURE handle(signal: SYSTEM.INT32);
BEGIN
  Console.Ln; Console.String("Signal: "); Console.Int(signal,1); Console.Ln;
  ws("Signal "); wi(signal); wl;
  (*Platform.Delay(1000)*)
END handle;

PROCEDURE Take5(i: INTEGER);
BEGIN
  WHILE i > 0 DO
    Console.Int(i,2); Console.Flush(); Platform.Delay(1000); DEC(i)
  END;
  Console.Ln;
END Take5;

BEGIN
  result := Files.New("result");
  Files.Set(rider, result, 0);
  IF Modules.ArgCount > 1 THEN
    Platform.SetInterruptHandler(handle);
    Platform.SetQuitHandler(handle)
  END;
  Take5(4);
  Files.Register(result);
END SignalTest.