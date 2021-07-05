MODULE Oberon;

(* this version should not have dependency on graphics -- noch *)

  IMPORT Platform, Modules, Texts, Out;

  TYPE
    ParList* = POINTER TO ParRec;
    ParRec* = RECORD
      (*
      vwr*: Viewers.Viewer;
      frame*: Display.Frame;
      *)
      text*: Texts.Text;
      pos*: LONGINT
    END;

  VAR
    Log*:        Texts.Text;
    Par*:        ParList;      (*actual parameters*)
    OptionChar*: CHAR;

    R: Texts.Reader;
    W: Texts.Writer;

  (*clocks*)

PROCEDURE GetClock* (VAR t, d: LONGINT);
BEGIN Platform.GetClock(t, d)
END GetClock;

PROCEDURE Time* (): LONGINT;
BEGIN RETURN Platform.Time()
END Time;

PROCEDURE PopulateParams;
  VAR W: Texts.Writer; i: INTEGER; str: ARRAY 256 OF CHAR;
BEGIN
  Texts.OpenWriter(W);
  i := 1; (* skip program name *)
  WHILE i < Modules.ArgCount DO
    Modules.GetArg(i, str); Texts.WriteString(W, str); Texts.Write(W, " ");
    INC(i)
  END;
  Texts.Append(Par^.text, W.buf);
END PopulateParams;

PROCEDURE GetSelection*(VAR text: Texts.Text; VAR beg, end, time: LONGINT);
BEGIN text := NIL; beg := 0; end := 0; time := 0
END GetSelection;

(* --- Notifier for echoing to the comsole all text appended to the log. --- *)
PROCEDURE LogNotifier(Log: Texts.Text; op: INTEGER; beg, end: LONGINT);
  VAR ch: CHAR;
BEGIN
  Texts.OpenReader(R, Log, beg);
  WHILE ~R.eot & (beg < end) DO
    Texts.Read(R, ch);
    IF ch = 0DX THEN Out.Ln ELSE Out.Char(ch) END;
    INC(beg)
  END
END LogNotifier;

BEGIN
   NEW(Par);
   NEW(Par.text);
   Par.pos := 0;
   OptionChar := '-';
   Texts.Open(Par.text, "");
   PopulateParams;
   NEW(Log);
   Texts.Open(Log, "");
   Log.notify := LogNotifier;
END Oberon.
