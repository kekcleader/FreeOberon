MODULE ulmSYSTEM;
IMPORT SYSTEM, Platform, Sys := ulmSys;

TYPE pchar = POINTER TO ARRAY 1 OF CHAR;
     pstring = POINTER TO ARRAY 1024 OF CHAR;
     (* pstatus = POINTER TO Platform.Status; *)

      TYPE bytearray* = ARRAY SIZE(LONGINT) OF SYSTEM.BYTE; (* need this because voc does not convert implicitly LONGINT to ARRAY OF BYTE; -- noch *)
          pbytearray* = POINTER TO bytearray;
      TYPE longrealarray* = ARRAY SIZE(LONGREAL) OF SYSTEM.BYTE; (* need this because voc does not convert implicitly LONGINT to ARRAY OF BYTE; -- noch *)
          plongrealarray* = POINTER TO longrealarray;

   PROCEDURE LongToByteArr* ( l : LONGINT; VAR bar : bytearray); (* noch *)
   VAR b : SYSTEM.BYTE;
       adr : SYSTEM.ADDRESS;
       i : LONGINT;
   BEGIN
      adr := SYSTEM.ADR(l);
      i := 0;
	  REPEAT
        SYSTEM.GET(adr + i, b);
		bar[i] := b;
		INC(i)
	  UNTIL i = SIZE(LONGINT)
   END LongToByteArr;

   PROCEDURE LRealToByteArr* ( l : LONGREAL; VAR lar : longrealarray); (* noch *)
   VAR b : SYSTEM.BYTE;
       adr: SYSTEM.ADDRESS;
       i : LONGINT;
   BEGIN
	  adr := SYSTEM.ADR(l);
	  i := 0;
	  REPEAT
        SYSTEM.GET(adr + i, b);
        lar[i] := b;
	    INC(i)
	  UNTIL i = SIZE(LONGREAL);
   END LRealToByteArr;


  PROCEDURE TAS*(VAR flag:BOOLEAN): BOOLEAN; (* added for compatibility with ulmSYSTEM module; noch *)
  VAR oldflag : BOOLEAN;
  BEGIN
     oldflag := flag;
     flag := TRUE;
     RETURN oldflag;
  END TAS;

(*
  PROCEDURE UNIXCALL*(syscall: LONGINT; VAR d0, d1: LONGINT; (* in ulm version both LONGINT and INTEGER are 4 byte size *)
                     arg1, arg2, arg3: LONGINT) : BOOLEAN;
  VAR
      n:    LONGINT;
      ch:   CHAR;
      pch:  pchar;
      pstr: pstring;
      h:    Platform.FileHandle;
      (* pst : pstatus; *)
  BEGIN

  IF syscall = Sys.read THEN
    d0 := Platform.Read(arg1, arg2, arg3, n);
    IF d0 >= 0 THEN d0 := n END;
    RETURN d0 >= 0;
    (*NEW(pch);
    pch := SYSTEM.VAL(pchar, arg2);
    ch := pch^[0];
    n := read(ch);
    IF n # 1 THEN
       ch := 0X;
       RETURN FALSE
    ELSE
       pch^[0] := ch;
       RETURN TRUE
    END;
    *)
  ELSIF syscall = Sys.write THEN
    RETURN Platform.Write(arg1, arg2, arg3) = 0;
    (*NEW(pch);
    pch := SYSTEM.VAL(pchar, arg2);
    n := Write(SYSTEM.VAL(LONGINT, pch), 1);
    IF n # 1 THEN RETURN FALSE ELSE RETURN TRUE END
    *)
  ELSIF syscall = Sys.open THEN
    pstr := SYSTEM.VAL(pstring, arg1);
    IF SYSTEM.VAL(SET, arg3) * {0,1} # {} THEN
      RETURN Platform.OldRW(pstr^, d0) = 0
    ELSE
      RETURN Platform.OldRO(pstr^, d0) = 0
    END
  ELSIF syscall = Sys.close THEN
    RETURN Platform.Close(arg1) = 0
  ELSIF syscall = Sys.lseek THEN
    RETURN Platform.Seek(arg1, arg2, SYSTEM.VAL(INTEGER, arg3)) = 0
  (*
  ELSIF syscall = Sys.ioctl THEN
     d0 := Platform.Ioctl(arg1, arg2, arg3);
     RETURN d0 >= 0;
  ELSIF syscall = Sys.fcntl THEN
     d0 := Platform.Fcntl (arg1, arg2, arg3);
     RETURN d0 >= 0;
  ELSIF syscall = Sys.dup THEN
     d0 := Platform.Dup(arg1);
     RETURN d0 > 0;
  ELSIF syscall = Sys.pipe THEN
     d0 := Platform.Pipe(arg1);
     RETURN d0 >= 0;
  ELSIF syscall = Sys.newstat THEN
     pst := SYSTEM.VAL(pstatus, arg2);
     pstr := SYSTEM.VAL(pstring, arg1);
     d0 := Platform.Stat(pstr^, pst^);
     RETURN d0 >= 0
  ELSIF syscall = Sys.newfstat THEN
     pst := SYSTEM.VAL(pstatus, arg2);
     d0 := Platform.Fstat(arg1, pst^);
     RETURN d0 >= 0;
  *)
  ELSE
    HALT(99);
  END

  END UNIXCALL;
*)

  PROCEDURE UNIXFORK(VAR pid: LONGINT) : BOOLEAN;
  BEGIN

  END UNIXFORK;

  PROCEDURE UNIXSIGNAL(signo: INTEGER; p: PROCEDURE;
                       VAR old: PROCEDURE; VAR error: INTEGER) : BOOLEAN;
  BEGIN

  END UNIXSIGNAL;

  PROCEDURE WMOVE*(from, to, n : SYSTEM.ADDRESS);
  BEGIN
     SYSTEM.MOVE(from, to, n);
  END WMOVE;

END ulmSYSTEM.
