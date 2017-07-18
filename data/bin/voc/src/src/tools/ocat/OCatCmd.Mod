MODULE OCatCmd;  (* J. Templ, 13-Jan-96 *)

(* looks at the OBERON search path and writes one or more Oberon or ascii texts to standard out *)

  IMPORT Args, Console, Files, Texts;

  PROCEDURE Cat*;
    VAR path: ARRAY 128 OF CHAR; i: INTEGER; T: Texts.Text; R: Texts.Reader; ch: CHAR; tab: BOOLEAN;
      buf: ARRAY 1024  OF CHAR; bufpos: INTEGER;

    PROCEDURE ConsoleChar(ch: CHAR);  (* buffered write *)
    BEGIN buf[bufpos] := ch; INC(bufpos);
      IF bufpos = LEN(buf) - 1 THEN buf[bufpos] := 0X; Console.String(buf); bufpos := 0 END
    END ConsoleChar;

  BEGIN
    path := ""; NEW(T);
    Args.Get(1, path);
    IF path = "-t" THEN tab := TRUE; i := 2; Args.Get(2, path)
    ELSE tab := FALSE; i := 1
    END ;
    WHILE path # "" DO
      IF Files.Old(path) # NIL THEN 
        Texts.Open(T, path);
        Texts.OpenReader(R, T, 0); Texts.Read(R, ch); bufpos := 0;
        WHILE ~R.eot DO
          IF ch >= " " THEN ConsoleChar(ch)
          ELSIF ch = 09X THEN
            IF tab THEN ConsoleChar(ch) ELSE ConsoleChar(" "); ConsoleChar(" ") END
          ELSIF ch = 0DX THEN ConsoleChar(0AX)
          END ;
          Texts.Read(R, ch)
        END ;
        buf[bufpos] := 0X; Console.String(buf)  (* flush *)
      ELSE
        Console.String("ocat: cannot open "); Console.String(path); Console.Ln
      END ;
      INC(i); path  := "";
      Args.Get(i, path)
    END
  END Cat;

BEGIN Cat
END OCatCmd.



ocat [-t] files...

-t   no tab conversion
