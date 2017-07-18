MODULE Platform;
IMPORT SYSTEM;

CONST
  StdIn-  = 0;
  StdOut- = 1;
  StdErr- = 2;

TYPE
  SignalHandler = PROCEDURE(signal: SYSTEM.INT32);

  ErrorCode*  = INTEGER;
  FileHandle* = LONGINT;

  FileIdentity* = RECORD
    volume: LONGINT;  (* dev on Unix filesystems, volume serial number on NTFS *)
    index:  LONGINT;  (* inode on Unix filesystems, file id on NTFS *)
    mtime:  LONGINT;  (* File modification time, value is system dependent *)
  END;

VAR
  LittleEndian-:   BOOLEAN;
  PID-:            INTEGER;    (* Note: Must be updated by Fork implementation *)
  CWD-:            ARRAY 256 OF CHAR;
  TimeStart:       LONGINT;

  SeekSet-:        INTEGER;
  SeekCur-:        INTEGER;
  SeekEnd-:        INTEGER;

  NL-:             ARRAY 3 OF CHAR;  (* Platform specific newline representation *)



(* Unix headers to be included *)

PROCEDURE -Aincludesystime  '#include <sys/time.h>';  (* for gettimeofday *)
PROCEDURE -Aincludetime     '#include <time.h>';      (* for localtime *)
PROCEDURE -Aincludesystypes '#include <sys/types.h>';
PROCEDURE -Aincludeunistd   '#include <unistd.h>';
PROCEDURE -Aincludesysstat  '#include <sys/stat.h>';
PROCEDURE -Aincludefcntl    '#include <fcntl.h>';
PROCEDURE -Aincludeerrno    '#include <errno.h>';
PROCEDURE -Astdlib          '#include <stdlib.h>';
PROCEDURE -Astdio           '#include <stdio.h>';
PROCEDURE -Aerrno           '#include <errno.h>';




(* Error code tests *)

PROCEDURE -EMFILE():       ErrorCode 'EMFILE';
PROCEDURE -ENFILE():       ErrorCode 'ENFILE';
PROCEDURE -ENOENT():       ErrorCode 'ENOENT';
PROCEDURE -EXDEV():        ErrorCode 'EXDEV';
PROCEDURE -EACCES():       ErrorCode 'EACCES';
PROCEDURE -EROFS():        ErrorCode 'EROFS';
PROCEDURE -EAGAIN():       ErrorCode 'EAGAIN';
PROCEDURE -ETIMEDOUT():    ErrorCode 'ETIMEDOUT';
PROCEDURE -ECONNREFUSED(): ErrorCode 'ECONNREFUSED';
PROCEDURE -ECONNABORTED(): ErrorCode 'ECONNABORTED';
PROCEDURE -ENETUNREACH():  ErrorCode 'ENETUNREACH';
PROCEDURE -EHOSTUNREACH(): ErrorCode 'EHOSTUNREACH';
PROCEDURE -EINTR():        ErrorCode 'EINTR';




PROCEDURE TooManyFiles*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = EMFILE()) OR (e = ENFILE()) END TooManyFiles;

PROCEDURE NoSuchDirectory*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = ENOENT() END NoSuchDirectory;

PROCEDURE DifferentFilesystems*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = EXDEV() END DifferentFilesystems;

PROCEDURE Inaccessible*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = EACCES()) OR (e = EROFS()) OR (e = EAGAIN()) END Inaccessible;

PROCEDURE Absent*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = ENOENT() END Absent;

PROCEDURE TimedOut*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = ETIMEDOUT() END TimedOut;

PROCEDURE ConnectionFailed*(e: ErrorCode): BOOLEAN;
BEGIN RETURN (e = ECONNREFUSED()) OR (e = ECONNABORTED())
          OR (e = ENETUNREACH())  OR (e = EHOSTUNREACH()) END ConnectionFailed;

PROCEDURE Interrupted*(e: ErrorCode): BOOLEAN;
BEGIN RETURN e = EINTR() END Interrupted;




(* OS memory allocaton *)

PROCEDURE -allocate  (size: SYSTEM.ADDRESS): SYSTEM.ADDRESS "(ADDRESS)((void*)malloc((size_t)size))";
PROCEDURE OSAllocate*(size: SYSTEM.ADDRESS): SYSTEM.ADDRESS; BEGIN RETURN allocate(size) END OSAllocate;

PROCEDURE -free(address: SYSTEM.ADDRESS) "free((void*)address)";
PROCEDURE OSFree*(address: SYSTEM.ADDRESS); BEGIN free(address) END OSFree;




(* Program arguments and environment access *)

PROCEDURE -getenv(var: ARRAY OF CHAR): SYSTEM.ADDRESS "getenv((char*)var)";

PROCEDURE getEnv*(var: ARRAY OF CHAR; VAR val: ARRAY OF CHAR): BOOLEAN;
TYPE EnvPtr = POINTER TO ARRAY 1024 OF CHAR;
VAR  p: EnvPtr;
BEGIN
  p := SYSTEM.VAL(EnvPtr, getenv(var));
  IF p # NIL THEN COPY(p^, val) END;
  RETURN p # NIL;
END getEnv;

PROCEDURE GetEnv*(var: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
BEGIN
  IF ~getEnv(var, val) THEN val[0] := 0X END;
END GetEnv;






(* Signals and traps *)

PROCEDURE -sethandler(s: INTEGER; h: SignalHandler) "SystemSetHandler(s, (ADDRESS)h)";

PROCEDURE SetInterruptHandler*(handler: SignalHandler);
BEGIN sethandler(2, handler); END SetInterruptHandler;

PROCEDURE SetQuitHandler*(handler: SignalHandler);
BEGIN sethandler(3, handler); END SetQuitHandler;

PROCEDURE SetBadInstructionHandler*(handler: SignalHandler);
BEGIN sethandler(4, handler); END SetBadInstructionHandler;




(* Time of day *)

PROCEDURE -gettimeval          "struct timeval tv; gettimeofday(&tv,0)";
PROCEDURE -tvsec():  LONGINT   "tv.tv_sec";
PROCEDURE -tvusec(): LONGINT   "tv.tv_usec";
PROCEDURE -sectotm(s: LONGINT) "struct tm *time = localtime((time_t*)&s)";
PROCEDURE -tmsec():  LONGINT   "(LONGINT)time->tm_sec";
PROCEDURE -tmmin():  LONGINT   "(LONGINT)time->tm_min";
PROCEDURE -tmhour(): LONGINT   "(LONGINT)time->tm_hour";
PROCEDURE -tmmday(): LONGINT   "(LONGINT)time->tm_mday";
PROCEDURE -tmmon():  LONGINT   "(LONGINT)time->tm_mon";
PROCEDURE -tmyear(): LONGINT   "(LONGINT)time->tm_year";

PROCEDURE YMDHMStoClock(ye,mo,da,ho,mi,se: LONGINT; VAR t, d: LONGINT);
BEGIN
  d := ASH(ye MOD 100, 9) + ASH(mo+1, 5) + da;
  t := ASH(ho, 12)        + ASH(mi, 6)   + se;
END YMDHMStoClock;

PROCEDURE GetClock*(VAR t, d: LONGINT);
BEGIN
  gettimeval; sectotm(tvsec());
  YMDHMStoClock(tmyear(), tmmon(), tmmday(), tmhour(), tmmin(), tmsec(), t, d);
END GetClock;

PROCEDURE GetTimeOfDay*(VAR sec, usec: LONGINT);
BEGIN
  gettimeval; sec := tvsec(); usec := tvusec();
END GetTimeOfDay;

PROCEDURE Time*(): LONGINT;
VAR ms: LONGINT;
BEGIN
  gettimeval;
  ms := (tvusec() DIV 1000) + (tvsec() * 1000);
  RETURN (ms - TimeStart) MOD 7FFFFFFFH;
END Time;


PROCEDURE -nanosleep(s: LONGINT; ns: LONGINT) "struct timespec req, rem; req.tv_sec = s; req.tv_nsec = ns; nanosleep(&req, &rem)";

PROCEDURE Delay*(ms: LONGINT);
VAR s, ns: LONGINT;
BEGIN
  s  :=  ms DIV 1000;
  ns := (ms MOD 1000) * 1000000;
  nanosleep(s, ns);
END Delay;




(* System call *)

PROCEDURE -system(str: ARRAY OF CHAR): INTEGER "system((char*)str)";
PROCEDURE -err(): INTEGER "errno";


PROCEDURE System*(cmd : ARRAY OF CHAR): INTEGER;
BEGIN RETURN system(cmd); END System;

PROCEDURE Error*(): ErrorCode; BEGIN RETURN err() END Error;




(* File system *)

(* Note: Consider also using flags O_SYNC and O_DIRECT as we do buffering *)
PROCEDURE -openrw (n: ARRAY OF CHAR): INTEGER "open((char*)n, O_RDWR)";
PROCEDURE -openro (n: ARRAY OF CHAR): INTEGER "open((char*)n, O_RDONLY)";
PROCEDURE -opennew(n: ARRAY OF CHAR): INTEGER "open((char*)n, O_CREAT | O_TRUNC | O_RDWR, 0664)";

(* File APIs *)

PROCEDURE OldRO*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: INTEGER;
BEGIN
  fd := openro(n);
  IF (fd < 0) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END OldRO;

PROCEDURE OldRW*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: INTEGER;
BEGIN
  fd := openrw(n);
  IF (fd < 0) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END OldRW;

PROCEDURE New*(VAR n: ARRAY OF CHAR; VAR h: FileHandle): ErrorCode;
VAR fd: INTEGER;
BEGIN
  fd := opennew(n);
  IF (fd < 0) THEN RETURN err() ELSE h := fd; RETURN 0 END;
END New;



PROCEDURE -closefile(fd: LONGINT): INTEGER "close(fd)";

PROCEDURE Close*(h: FileHandle): ErrorCode;
BEGIN
  IF closefile(h) < 0 THEN RETURN err() ELSE RETURN 0 END
END Close;


PROCEDURE -isatty(fd: LONGINT): INTEGER "isatty(fd)";

PROCEDURE IsConsole*(h: FileHandle): BOOLEAN;
BEGIN RETURN isatty(h) # 0 END IsConsole;



PROCEDURE -fstat(fd: LONGINT):     INTEGER "fstat(fd, &s)";
PROCEDURE -stat(n: ARRAY OF CHAR): INTEGER "stat((char*)n, &s)";
PROCEDURE -structstats                     "struct stat s";
PROCEDURE -statdev():              LONGINT "(LONGINT)s.st_dev";
PROCEDURE -statino():              LONGINT "(LONGINT)s.st_ino";
PROCEDURE -statmtime():            LONGINT "(LONGINT)s.st_mtime";
PROCEDURE -statsize():             LONGINT "(ADDRESS)s.st_size";

PROCEDURE Identify*(h: FileHandle; VAR identity: FileIdentity): ErrorCode;
BEGIN
  structstats;
  IF fstat(h) < 0 THEN RETURN err() END;
  identity.volume := statdev();
  identity.index  := statino();
  identity.mtime  := statmtime();
  RETURN 0
END Identify;

PROCEDURE IdentifyByName*(n: ARRAY OF CHAR; VAR identity: FileIdentity): ErrorCode;
BEGIN
  structstats;
  IF stat(n) < 0 THEN RETURN err() END;
  identity.volume := statdev();
  identity.index  := statino();
  identity.mtime  := statmtime();
  RETURN 0
END IdentifyByName;


PROCEDURE SameFile*(i1, i2: FileIdentity): BOOLEAN;
BEGIN RETURN (i1.index = i2.index) & (i1.volume = i2.volume)
END SameFile;

PROCEDURE SameFileTime*(i1, i2: FileIdentity): BOOLEAN;
BEGIN RETURN i1.mtime = i2.mtime
END SameFileTime;

PROCEDURE SetMTime*(VAR target: FileIdentity; source: FileIdentity);
BEGIN target.mtime := source.mtime;
END SetMTime;

PROCEDURE MTimeAsClock*(i: FileIdentity; VAR t, d: LONGINT);
BEGIN
  sectotm(i.mtime);
  YMDHMStoClock(tmyear(), tmmon(), tmmday(), tmhour(), tmmin(), tmsec(), t, d);
END MTimeAsClock;


PROCEDURE Size*(h: FileHandle; VAR l: LONGINT): ErrorCode;
BEGIN
  structstats;
  IF fstat(h) < 0 THEN RETURN err() END;
  l := statsize();
  RETURN 0;
END Size;



PROCEDURE -readfile (fd: LONGINT; p: SYSTEM.ADDRESS; l: LONGINT): LONGINT
"(LONGINT)read(fd, (void*)(ADDRESS)(p), l)";

PROCEDURE Read*(h: FileHandle; p: SYSTEM.ADDRESS; l: LONGINT; VAR n: LONGINT): ErrorCode;
BEGIN
  n := readfile(h, p, l);
  IF n < 0 THEN n := 0; RETURN err() ELSE RETURN 0 END
END Read;

PROCEDURE ReadBuf*(h: FileHandle; VAR b: ARRAY OF SYSTEM.BYTE; VAR n: LONGINT): ErrorCode;
BEGIN
  n := readfile(h, SYSTEM.ADR(b), LEN(b));
  IF n < 0 THEN n := 0; RETURN err() ELSE RETURN 0 END
END ReadBuf;



PROCEDURE -writefile(fd: LONGINT; p: SYSTEM.ADDRESS; l: LONGINT): SYSTEM.ADDRESS
"write(fd, (void*)(ADDRESS)(p), l)";

PROCEDURE Write*(h: FileHandle; p: SYSTEM.ADDRESS; l: LONGINT): ErrorCode;
  VAR written: SYSTEM.ADDRESS;
BEGIN
  written := writefile(h, p, l);
  IF written < 0 THEN RETURN err() ELSE RETURN 0 END
END Write;



PROCEDURE -fsync(fd: LONGINT): INTEGER "fsync(fd)";

PROCEDURE Sync*(h: FileHandle): ErrorCode;
BEGIN
  IF fsync(h) < 0 THEN RETURN err() ELSE RETURN 0 END
END Sync;



PROCEDURE -lseek(fd: LONGINT; o: LONGINT; w: INTEGER): INTEGER "lseek(fd, o, w)";
PROCEDURE -seekset(): INTEGER "SEEK_SET";
PROCEDURE -seekcur(): INTEGER "SEEK_CUR";
PROCEDURE -seekend(): INTEGER "SEEK_END";

PROCEDURE Seek*(h: FileHandle; offset: LONGINT; whence: INTEGER): ErrorCode;
BEGIN
  IF lseek(h, offset, whence) < 0 THEN RETURN err() ELSE RETURN 0 END
END Seek;



PROCEDURE -ftruncate(fd: LONGINT; l: LONGINT): INTEGER "ftruncate(fd, l)";

PROCEDURE Truncate*(h: FileHandle; l: LONGINT): ErrorCode;
BEGIN
  IF (ftruncate(h, l) < 0) THEN RETURN err() ELSE RETURN 0 END;
END Truncate;



PROCEDURE -unlink(n: ARRAY OF CHAR): INTEGER "unlink((char*)n)";

PROCEDURE Unlink*(VAR n: ARRAY OF CHAR): ErrorCode;
BEGIN
  IF unlink(n) < 0 THEN RETURN err() ELSE RETURN 0 END
END Unlink;



PROCEDURE -chdir(n: ARRAY OF CHAR): INTEGER "chdir((char*)n)";
PROCEDURE -getcwd(VAR cwd: ARRAY OF CHAR): SYSTEM.PTR "getcwd((char*)cwd, cwd__len)";

PROCEDURE Chdir*(VAR n: ARRAY OF CHAR): ErrorCode;
  VAR r: INTEGER;
BEGIN
  IF (chdir(n) >= 0) & (getcwd(CWD) # NIL) THEN RETURN 0
  ELSE RETURN err() END
END Chdir;



PROCEDURE -rename(o,n: ARRAY OF CHAR): INTEGER "rename((char*)o, (char*)n)";

PROCEDURE Rename*(VAR o,n: ARRAY OF CHAR): ErrorCode;
BEGIN
  IF rename(o,n) < 0 THEN RETURN err() ELSE RETURN 0 END
END Rename;




(* Process termination *)

PROCEDURE -exit(code: LONGINT) "exit((int)code)";
PROCEDURE Exit*(code: LONGINT); BEGIN exit(code) END Exit;



PROCEDURE TestLittleEndian;
  VAR i: INTEGER;
 BEGIN i := 1; SYSTEM.GET(SYSTEM.ADR(i), LittleEndian); END TestLittleEndian;


PROCEDURE -getpid(): INTEGER   "(INTEGER)getpid()";

BEGIN
  TestLittleEndian;

  TimeStart   := 0;   TimeStart := Time();
  PID         := getpid();
  IF getcwd(CWD) = NIL THEN CWD := "" END;

  SeekSet := seekset();
  SeekCur := seekcur();
  SeekEnd := seekend();

  NL[0] := 0AX; (* LF *)
  NL[1] := 0X;
END Platform.
