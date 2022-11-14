MODULE Files;
(** Standard data type input-output

    Little Endian,
    SInt: 2 bytes, Int: 4 bytes, LInt: 8 bytes
    ORD({0}) = 1,
    FALSE = 0, TRUE = 1
    IEEE Real Format,
    Null-terminated strings,
    compact numbers according to M. Odersky *)

IMPORT SYSTEM, Platform, Heap, Strings, Out, Utf8;

CONST
  PathDelimiter = Platform.PathDelimiter;
  PathSeparator = Platform.PathSeparator;

  NumBufs = 4;
  BufSize = 4096;

  (* No file states, used when FileDesc.fd = Platform.InvalidHandleValue() *)
  open   = 0; (* OS File has been opened *)
  create = 1; (* OS file needs to be created *)
  close  = 2; (* Flag used by Files.Register to tell Create to create the file
                 using it's registerName directly, rather than to create a
                 temporary file: i.e. since we're closing and all data is still
                 in buffers bypass writing to temp file and then renaming and
                 just write directly to final register name *)

TYPE
  SBYTE* = BYTE;
  BYTE* = UBYTE;
  INT64 = LONGINT;
  LONGINT = INTEGER; (* For larger version of Files, i.e. Files64 *)

  FileName = ARRAY 256 OF CHAR;
  File* = POINTER TO FileDesc;
  Buffer = POINTER TO BufDesc;

  FileDesc = RECORD
    workName, registerName: FileName;
    tempFile: BOOLEAN;
    identity: Platform.FileIdentity;
    fd-: Platform.FileHandle;
    len, pos: LONGINT;
    bufs: ARRAY NumBufs OF Buffer;
    swapper, state: SHORTINT;
    next: POINTER [notag] TO FileDesc
  END;

  BufDesc = RECORD
    f: File;
    chg: BOOLEAN;
    org: LONGINT;
    size: INTEGER;
    data: ARRAY BufSize OF SBYTE
  END;

  Rider* = RECORD
    res*: INTEGER; (* Residue (byte count not read) at eof of ReadBytes *)
    eof*: BOOLEAN;
    justSet: BOOLEAN; (* TRUE after Set(r, F, n>0) for UTF-8 error handling *)
    buf: Buffer;
    org: LONGINT; (* File offset of block containing current position *)
    offset: INTEGER (* Current position offset within block at org. *)
  END;

VAR
  (* Array of files backed by an OS file: open, registered or temporary. *)
  files: POINTER [notag] TO FileDesc;

  tempno: INTEGER;
  home: ARRAY 1024 OF CHAR;
  SearchPath: ARRAY 4096 OF CHAR;

PROCEDURE -IdxTrap(pos: INTEGER) '__HALT(-1, "Files.Mod", pos)';

PROCEDURE^ Finalize(o: SYSTEM.PTR);

PROCEDURE Err(IN s: ARRAY OF CHAR; f: File; errcode: Platform.ErrorCode);
BEGIN
  Out.Ln; Out.String('-- '); Out.String(s); Out.String(': ');
  IF f # NIL THEN
    IF f.registerName # '' THEN Out.String(f.registerName)
    ELSE Out.String(f.workName)
    END;
    IF f.fd # 0 THEN Out.String(' f.fd = '); Out.Int(f.fd, 1) END
  END;
  IF errcode # 0 THEN Out.String(' errcode = '); Out.Int(errcode, 1) END;
  Out.Ln;
  HALT(99)
END Err;

PROCEDURE MakeFileName(IN dir, name: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR);
VAR i, j: INTEGER;
BEGIN i := 0; j := 0;
  WHILE dir[i] # 0X DO dest[i] := dir[i]; INC(i) END;
  IF dest[i-1] # PathDelimiter THEN dest[i] := PathDelimiter; INC(i) END;
  WHILE name[j] # 0X DO dest[i] := name[j]; INC(i); INC(j) END;
  dest[i] := 0X
END MakeFileName;

PROCEDURE GetTempName(IN finalName: ARRAY OF CHAR; VAR name: ARRAY OF CHAR);
VAR n, i: INTEGER;
  q: ARRAY 256 OF SHORTCHAR;
BEGIN INC(tempno); Platform.GetTempPath(q); Utf8.Decode(q, name);
  i := 0; WHILE name[i] # 0X DO INC(i) END;

  name[i] := 'o'; INC(i); name[i] := 'b'; INC(i); name[i] := 'e'; INC(i);
  name[i] := 'r'; INC(i); name[i] := 'o'; INC(i); name[i] := 'n'; INC(i);
  name[i] := '.'; INC(i); n := tempno;
  REPEAT name[i] := CHR(n MOD 10 + 30H); n := n DIV 10; INC(i) UNTIL n = 0;

  name[i] := '.'; INC(i); n := Platform.PID;
  REPEAT name[i] := CHR(n MOD 10 + 30H); n := n DIV 10; INC(i) UNTIL n = 0;
  name[i] := 0X
END GetTempName;

(* When registering a file, it may turn out that the name we want to use
   is aready in use by another File. E.g. the compiler opens and reads
   an existing symbol file if present before creating an updated one.
   When this happens on Windows, creation of the new file will be blocked
   by the presence of the old one because it is in a open state. Further,
   on both Unix and Windows systems we want behaviour to match that of
   a real Oberon system, where registering the new file has the effect of
   unregistering the old file. To simulate this we need to change the old
   Files.File back to a temp file. *)
PROCEDURE Deregister(IN name: ARRAY OF CHAR);
VAR identity: Platform.FileIdentity;
  osfile: File;
  error: Platform.ErrorCode;
  q, s: ARRAY 2048 OF SHORTCHAR;
BEGIN
  Utf8.Encode(name, q);
  IF Platform.IdentifyByName(q, identity) = 0 THEN
    (* The name we are registering is an already existing file. *)
    osfile := files;
    WHILE (osfile # NIL) & ~Platform.SameFile(osfile.identity, identity) DO
      osfile := osfile.next
    END;
    IF osfile # NIL THEN
      (* osfile is the FileDesc corresponding to the file name we are hoping
         to register. Turn it into a temporary file. *)
      ASSERT(~osfile.tempFile); ASSERT(osfile.fd >= 0);
      osfile.registerName := osfile.workName;
      GetTempName(osfile.registerName, osfile.workName);
      osfile.tempFile := TRUE;
      error := Platform.CloseFile(osfile.fd);
      osfile.state := close;
      Utf8.Encode(osfile.registerName, q);
      Utf8.Encode(osfile.workName, s);
      error := Platform.RenameFile(q, s);
      IF error # 0 THEN
        Err('Could not rename previous version of file being registered',
          osfile, error)
      END
    END
  END
END Deregister;

(** Makes sure there is an OS file backing this Oberon file.
    Used when more data has been written to an unregistered new file than
    buffers can hold, or when registering a new file whose data is all in
    buffers. *)
PROCEDURE Create(f: File);
VAR done: BOOLEAN;
  error: Platform.ErrorCode;
  err: ARRAY 32 OF CHAR;
  q: ARRAY 2048 OF SHORTCHAR;
BEGIN
  IF f.fd = Platform.InvalidHandleValue() THEN
    IF f.state = create THEN
      (* New file with enough data written to exceed buffers, so we need to
         create a temporary file to back it. *) 
      GetTempName(f.registerName, f.workName); f.tempFile := TRUE
    ELSE
      ASSERT(f.state = close);
      (* New file with all data in buffers being registered. No need for a
         temp file, will just write the buffers to the registerName. *)
      Deregister(f.registerName);
      f.workName := f.registerName; f.registerName := ''; f.tempFile := FALSE
    END;
    (* Unlink first to avoid stale NFS handles and to avoid reuse of inodes *)
    Utf8.Encode(f.workName, q);
    error := Platform.DeleteFile(q);

    error := Platform.NewFile(q, f.fd);
    done := error = 0;
    IF done THEN
      (* Link this file into the list of OS backed files. *)
      f.next := files; files := f;
      INC(Heap.FileCount);
      Heap.RegisterFinalizer(f, Finalize);
      f.state := open;
      f.pos   := 0;
      error   := Platform.Identify(f.fd, f.identity);
    ELSE
      IF Platform.NoSuchDirectory(error) THEN err := 'no such directory'
      ELSIF Platform.TooManyFiles(error) THEN err := 'too many files open'
      ELSE err := 'file not created'
      END;
      Err(err, f, error)
    END
  END
END Create;

PROCEDURE Flush(buf: Buffer);
VAR error: Platform.ErrorCode;
  f: File;
BEGIN
  IF buf.chg THEN f := buf.f; Create(f);
    IF buf.org # f.pos THEN
      error := Platform.Seek(f.fd, buf.org, Platform.SeekSet)
    END;
    error := Platform.Write(f.fd, SYSTEM.ADR(buf.data), buf.size);
    IF error # 0 THEN Err('error writing file', f, error) END;
    f.pos := buf.org + buf.size; buf.chg := FALSE;
    (* Update identity with new modification time. *)
    error := Platform.Identify(f.fd, f.identity);
    IF error # 0 THEN Err('error identifying file', f, error) END
  END
END Flush;

PROCEDURE CloseOSFile(f: File);
(* Close the OS file handle and remove f from 'files' *)
VAR prev: File; error: Platform.ErrorCode;
BEGIN
  IF files = f THEN files := f.next
  ELSE
    prev := files;
    WHILE (prev # NIL) & (prev.next # f) DO prev := prev.next END;
    IF prev.next # NIL THEN prev.next := f.next END
  END;
  error := Platform.CloseFile(f.fd);
  f.fd := Platform.InvalidHandleValue(); f.state := create; DEC(Heap.FileCount)
END CloseOSFile;

PROCEDURE Close*(f: File);
VAR i: INTEGER;
BEGIN
  IF (f.state # create) OR (f.registerName # '') THEN
    Create(f); i := 0;
    WHILE (i < NumBufs) & (f.bufs[i] # NIL) DO Flush(f.bufs[i]); INC(i) END
  END
END Close;

PROCEDURE Length*(f: File): LONGINT;
BEGIN RETURN f.len END Length;

PROCEDURE New*(IN name: ARRAY OF CHAR): File;
VAR f: File;
BEGIN
  NEW(f); f.workName := ''; f.registerName := name$;
  f.fd := Platform.InvalidHandleValue(); f.state := create;
  f.len := 0; f.pos := 0; f.swapper := -1 ;
RETURN f END New;

PROCEDURE ScanPath(VAR pos: INTEGER; VAR dir: ARRAY OF CHAR);
(* Extract next individual directory from searchpath starting at pos,
   updating pos and returning dir.
   Supports ~, ~user and blanks inside path *)
VAR i: INTEGER; ch: CHAR;
BEGIN
  i := 0;
  IF SearchPath = '' THEN (* Default search path is the current directory *)
    IF pos = 0 THEN dir[0] := '.'; i := 1; INC(pos) END
  ELSE
    ch := SearchPath[pos];
    WHILE (ch = ' ') OR (ch = PathSeparator) DO
      INC(pos); ch := SearchPath[pos]
    END;
    IF ch = '~' THEN
      INC(pos); ch := SearchPath[pos];
      WHILE home[i] # 0X DO dir[i] := home[i]; INC(i) END;
      IF (ch # PathDelimiter) & (ch # 0X) & (ch # PathSeparator) & (ch # ' ')
      THEN WHILE (i > 0) & (dir[i - 1] # PathDelimiter) DO DEC(i) END
      END
    END;
    WHILE (ch # 0X) & (ch # PathSeparator) DO
      dir[i] := ch; INC(i); INC(pos); ch := SearchPath[pos]
    END;
    WHILE (i > 0) & (dir[i - 1] = ' ') DO DEC(i) END
  END;
  dir[i] := 0X
END ScanPath;

PROCEDURE HasDir(IN name: ARRAY OF CHAR): BOOLEAN;
VAR i: INTEGER; ch: CHAR;
BEGIN i := 0; ch := name[0];
  WHILE (ch # 0X) & (ch # PathDelimiter) DO INC(i); ch := name[i] END ;
RETURN ch = PathDelimiter END HasDir;

PROCEDURE CacheEntry(identity: Platform.FileIdentity): File;
VAR f: File; i: INTEGER; error: Platform.ErrorCode; n: INT64;
BEGIN f := files;
  WHILE f # NIL DO
    IF Platform.SameFile(identity, f.identity) THEN
      IF ~Platform.SameFileTime(identity, f.identity) THEN i := 0;
        WHILE i < NumBufs DO
          IF f.bufs[i] # NIL THEN f.bufs[i].org := -1; f.bufs[i] := NIL END;
          INC(i)
        END;
        f.swapper := -1; f.identity := identity;
        error := Platform.FileSize(f.fd, n); f.len := SHORT(n)
      END;
      RETURN f
    END;
    f := f.next
  END;
  RETURN NIL
END CacheEntry;

PROCEDURE Old*(IN name: ARRAY OF CHAR): File;
VAR f: File;
  fd: Platform.FileHandle;
  pos: INTEGER;
  done: BOOLEAN;
  dir, path: ARRAY 256 OF CHAR;
  error: Platform.ErrorCode;
  identity: Platform.FileIdentity;
  q: ARRAY 4096 OF SHORTCHAR;
  n: INT64;
BEGIN
  IF name # '' THEN
    IF HasDir(name) THEN dir := ''; path := name$
    ELSE pos := 0; ScanPath(pos, dir);
      MakeFileName(dir, name, path); ScanPath(pos, dir)
    END;
    LOOP Utf8.Encode(path, q);
      error := Platform.OldRW(q, fd); done := error = 0;
      IF ~done & Platform.TooManyFiles(error) THEN
        Err('too many files open', f, error)
      END;
      IF ~done & Platform.Inaccessible(error) THEN
        error := Platform.OldRO(q, fd); done := error = 0
      END;
      IF ~done & ~Platform.Absent(error) THEN
        Out.String('Warning: Files.Old '); Out.String(name);
        Out.String(' error = '); Out.Int(error, 0); Out.Ln
      END;
      IF done THEN
        error := Platform.Identify(fd, identity);
        f := CacheEntry(identity);
        IF f # NIL THEN
          error := Platform.CloseFile(fd); (* fd not needed, f.fd is used *)
          RETURN f
        ELSE NEW(f); Heap.RegisterFinalizer(f, Finalize);
          f.fd := fd; f.state := open; f.pos := 0; f.swapper := -1;
          error := Platform.FileSize(fd, n); f.len := SHORT(n);
          f.workName := name$; f.registerName := ''; f.tempFile := FALSE;
          f.identity := identity;
          f.next := files; files := f; INC(Heap.FileCount);
          RETURN f
        END
      ELSIF dir = '' THEN RETURN NIL
      ELSE MakeFileName(dir, name, path); ScanPath(pos, dir)
      END
    END
  ELSE RETURN NIL
  END
END Old;

PROCEDURE Purge*(f: File);
VAR i: INTEGER;
  identity: Platform.FileIdentity;
  error: Platform.ErrorCode;
BEGIN i := 0;
  WHILE i < NumBufs DO
    IF f.bufs[i] # NIL THEN f.bufs[i].org := -1; f.bufs[i] := NIL END;
    INC(i)
  END;
  IF f.fd # Platform.InvalidHandleValue() THEN
    error := Platform.TruncateFile(f.fd, 0);
    error := Platform.Seek(f.fd, 0, Platform.SeekSet)
  END;
  f.pos := 0; f.len := 0; f.swapper := -1;
  error := Platform.Identify(f.fd, identity);
  Platform.SetMTime(f.identity, identity)
END Purge;

PROCEDURE GetDate*(f: File; VAR t, d: INTEGER);
VAR identity: Platform.FileIdentity;
  error: Platform.ErrorCode;
BEGIN Create(f); error := Platform.Identify(f.fd, identity);
  Platform.MTimeAsClock(identity, t, d)
END GetDate;

PROCEDURE Pos*(VAR r: Rider): INTEGER;
BEGIN RETURN r.org + r.offset
END Pos;

PROCEDURE Set*(VAR r: Rider; f: File; pos: LONGINT);
VAR org: LONGINT;
  offset, i, n: INTEGER;
  buf: Buffer;
  error: Platform.ErrorCode;
BEGIN
  IF f # NIL THEN
    IF pos > f.len THEN pos := f.len ELSIF pos < 0 THEN pos := 0 END;
    offset := SHORT(pos MOD BufSize); org := pos - offset; i := 0;
    WHILE (i < NumBufs) & (f.bufs[i] # NIL) & (org # f.bufs[i].org) DO
      INC(i)
    END;
    IF i < NumBufs THEN
      IF f.bufs[i] = NIL THEN
        NEW(buf); buf.chg := FALSE; buf.org := -1; buf.f := f; f.bufs[i] := buf
      ELSE buf := f.bufs[i]
      END
    ELSE f.swapper := SHORT((f.swapper + 1) MOD NumBufs);
      buf := f.bufs[f.swapper];
      Flush(buf)
    END;
    IF buf.org # org THEN
      IF org = f.len THEN buf.size := 0
      ELSE Create(f);
        IF f.pos # org THEN
          error := Platform.Seek(f.fd, org, Platform.SeekSet)
        END;
        error := Platform.ReadBuf(f.fd, buf.data, n);
        IF error # 0 THEN Err('read from file not done', f, error) END;
        f.pos := org + n;
        buf.size := n
      END;
      buf.org := org; buf.chg := FALSE
    END
  ELSE buf := NIL; org := 0; offset := 0
  END;
  r.buf := buf; r.org := org; r.offset := offset; r.eof := FALSE; r.res := 0;
  r.justSet := pos > 0
END Set;

PROCEDURE Read*(VAR r: Rider; VAR x: BYTE);
VAR offset: INTEGER; buf: Buffer;
BEGIN
  buf := r.buf; offset := r.offset;
  IF r.org # buf.org THEN
    Set(r, buf.f, r.org + offset); buf := r.buf; offset := r.offset
  END;
  IF (offset < buf.size) THEN
    x := SYSTEM.VAL(BYTE, buf.data[offset]); r.offset := offset + 1
  ELSIF r.org + offset < buf.f.len THEN
    Set(r, r.buf.f, r.org + offset);
    x := SYSTEM.VAL(BYTE, r.buf.data[0]); r.offset := 1
  ELSE x := 0; r.eof := TRUE
  END
END Read;

PROCEDURE ReadBytes*(VAR r: Rider; VAR x: ARRAY OF BYTE; n: INTEGER);
VAR xpos, min, restInBuf, offset: INTEGER; buf: Buffer;
BEGIN
  IF n > LEN(x) THEN IdxTrap(433) END;
  xpos := 0; buf := r.buf; offset := r.offset; (* Offset within buffer r.buf *)
  WHILE n > 0 DO
    IF (r.org # buf.org) OR (offset >= BufSize) THEN
      Set(r, buf.f, r.org + offset);
      buf := r.buf; offset := r.offset
    END;
    restInBuf := buf.size - offset;
    IF restInBuf = 0 THEN r.res := n; r.eof := TRUE; RETURN
    ELSIF n > restInBuf THEN min := restInBuf ELSE min := n END;
    SYSTEM.MOVE(SYSTEM.ADR(buf.data) + offset, SYSTEM.ADR(x) + xpos, min);
    INC(offset, min); r.offset := offset; INC(xpos, min); DEC(n, min)
  END;
  r.res := 0; r.eof := FALSE
END ReadBytes;

PROCEDURE ReadShortChar*(VAR r: Rider; VAR x: SHORTCHAR);
BEGIN Read(r, SYSTEM.VAL(BYTE, x))
END ReadShortChar;

PROCEDURE ReadChar*(VAR r: Rider; VAR x: CHAR);
VAR b: BYTE; y: INTEGER;
BEGIN Read(r, b); y := b;
  IF y > 80H THEN Read(r, b); b := SYSTEM.VAL(BYTE, b MOD 64); (* Not 1 byte *)
    IF y DIV 32 = 6 THEN (* 2 bytes *)
      y := y MOD 32 * 64 + b
    ELSIF y DIV 16 = 14 THEN (* 3 bytes *)
      y := (y MOD 16 * 64 + b) * 64;
      Read(r, b); INC(y, b MOD 64)
    ELSIF y DIV 8 = 30 THEN (* 4 bytes *)
      y := (y MOD 8 * 64 + b) * 64;
      Read(r, b); y := (y + b MOD 64) * 64;
      Read(r, b); INC(y, b MOD 64) (*!FIXME UTF-16 surrogate pairs *)
    ELSE y := 0
    END
    (*!TODO: IF (UTF-8 error occurred) & ~r.justSet THEN yield error char
             ELSE skip to next char (but only one skip is allowed) END*)
  END;
  x := CHR(y); r.justSet := FALSE
END ReadChar;

PROCEDURE Base*(VAR r: Rider): File;
BEGIN RETURN r.buf.f
END Base;

PROCEDURE Write*(VAR r: Rider; x: BYTE);
VAR buf: Buffer; offset: INTEGER;
BEGIN
  buf := r.buf; offset := r.offset;
  IF (r.org # buf.org) OR (offset >= BufSize) THEN
    Set(r, buf.f, r.org + offset);
    buf := r.buf; offset := r.offset
  END;
  buf.data[offset] := x;
  buf.chg := TRUE;
  IF offset = buf.size THEN
    INC(buf.size); INC(buf.f.len)
  END;
  r.offset := offset + 1; r.res := 0
END Write;

PROCEDURE WriteBytes*(VAR r: Rider; IN x: ARRAY OF BYTE; n: INTEGER);
VAR xpos, min, restInBuf, offset: INTEGER; buf: Buffer;
BEGIN
  IF n > LEN(x) THEN IdxTrap(477) END;
  xpos := 0; buf := r.buf; offset := r.offset;
  WHILE n > 0 DO
    IF (r.org # buf.org) OR (offset >= BufSize) THEN
      Set(r, buf.f, r.org + offset);
      buf := r.buf; offset := r.offset
    END;
    restInBuf := BufSize - offset;
    IF n > restInBuf THEN min := restInBuf ELSE min := n END;
    SYSTEM.MOVE(SYSTEM.ADR(x) + xpos, SYSTEM.ADR(buf.data) + offset, min);
    INC(offset, min); r.offset := offset;
    IF offset > buf.size THEN buf.f.len := buf.f.len + (offset - buf.size);
    buf.size := offset END; INC(xpos, min); DEC(n, min); buf.chg := TRUE
  END;
  r.res := 0
END WriteBytes;

PROCEDURE Truncate*(F: File; pos: INTEGER);
BEGIN F.len := pos (*!FIXME*)
END Truncate;

PROCEDURE Delete*(IN name: ARRAY OF CHAR; VAR res: INTEGER);
VAR pos: INTEGER;
  dir, path: ARRAY 2048 OF CHAR;
  q: ARRAY 2048 OF SHORTCHAR;
BEGIN
  IF name # '' THEN
    IF HasDir(name) THEN dir := ''; path := name$
    ELSE pos := 0; ScanPath(pos, dir);
      MakeFileName(dir, name, path); ScanPath(pos, dir)
    END;
    LOOP
      Deregister(path);
      Utf8.Encode(path, q);
      res := Platform.DeleteFile(q);
      IF (res = 0) OR (dir = '') THEN RETURN
      ELSE MakeFileName(dir, name, path); ScanPath(pos, dir)
      END
    END
  ELSE res := 1
  END
END Delete;

PROCEDURE Rename*(IN old, new: ARRAY OF CHAR; VAR res: INTEGER);
VAR n: INTEGER;
  fdold, fdnew: Platform.FileHandle;
  error, ignore: Platform.ErrorCode;
  oldidentity, newidentity: Platform.FileIdentity;
  buf, old2, new2: ARRAY 4096 OF SHORTCHAR;
BEGIN
  Utf8.Encode(old, old2); Utf8.Encode(new, new2);
  error := Platform.IdentifyByName(old2, oldidentity);
  IF error = 0 THEN
    error := Platform.IdentifyByName(new2, newidentity);
    IF (error # 0) & ~Platform.SameFile(oldidentity, newidentity) THEN
      Delete(new, error) (* work around stale nfs handles *)
    END;
    error := Platform.RenameFile(old2, new2);
    (* TODO, if we already have a FileDesc for old, it ought to be updated
       with the new workname. *)
    IF ~Platform.DifferentFilesystems(error) THEN
      res := error;
      RETURN
    ELSE
      (* cross device link, move the file *)
      error := Platform.OldRO(old2, fdold);
      IF error # 0 THEN
        res := 2;
        RETURN
      END;
      error := Platform.NewFile(new2, fdnew);
      IF error # 0 THEN
        error := Platform.CloseFile(fdold); res := 3;
        RETURN
      END;
      error := Platform.Read(fdold, SYSTEM.ADR(buf), BufSize, n);
      WHILE n > 0 DO
        error := Platform.Write(fdnew, SYSTEM.ADR(buf), n);
        IF error # 0 THEN
          ignore := Platform.CloseFile(fdold);
          ignore := Platform.CloseFile(fdnew);
          Err('cannot move file', NIL, error)
        END;
        error := Platform.Read(fdold, SYSTEM.ADR(buf), BufSize, n);
      END;
      ignore := Platform.CloseFile(fdold);
      ignore := Platform.CloseFile(fdnew);
      IF n = 0 THEN error := Platform.DeleteFile(old2); res := 0
      ELSE Err('cannot move file', NIL, error)
      END
    END
  ELSE res := 2 (* old file not found *)
  END
END Rename;

PROCEDURE Register*(f: File);
VAR errcode: INTEGER;
  q: ARRAY 2048 OF SHORTCHAR;
BEGIN
  IF (f.state = create) & (f.registerName # '') THEN f.state := close END;
  Close(f);
  IF f.registerName # '' THEN
    Deregister(f.registerName);
    errcode := Platform.CloseFile(f.fd);
    IF errcode = 0 THEN (* Platform.RenameFile requires a closed file *)
      Rename(f.workName, f.registerName, errcode);
      IF errcode = 0 THEN Utf8.Encode(f.registerName, q);
        errcode := Platform.OldRW(q, f.fd);
        IF errcode = 0 THEN f.workName := f.registerName;
          f.registerName := ''; f.tempFile := FALSE;
          RETURN
        END
      END
    END;
    Err('Could not rename temp name as register name', f, errcode)
  END
END Register;

PROCEDURE ChangeDirectory*(IN path: ARRAY OF CHAR; VAR res: INTEGER);
VAR q: ARRAY 2048 OF SHORTCHAR;
BEGIN Utf8.Encode(path, q); res := Platform.ChDir(q)
END ChangeDirectory;

PROCEDURE FlipBytes(VAR src, dest: ARRAY OF BYTE);
VAR i, j: INTEGER;
BEGIN
  IF ~Platform.LittleEndian THEN i := LEN(src); j := 0;
    WHILE i > 0 DO DEC(i); dest[j] := src[i]; INC(j) END
  ELSE SYSTEM.MOVE(SYSTEM.ADR(src), SYSTEM.ADR(dest), LEN(src))
  END
END FlipBytes;

PROCEDURE ReadBool*(VAR R: Rider; VAR x: BOOLEAN);
BEGIN Read(R, SYSTEM.VAL(BYTE, x))
END ReadBool;

PROCEDURE ReadSInt*(VAR R: Rider; VAR x: SHORTINT);
VAR b: ARRAY 2 OF SHORTCHAR;
BEGIN ReadBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 2), 2);
  x := SHORT(ORD(b[0]) + ORD(b[1])*256)
END ReadSInt;

PROCEDURE ReadInt*(VAR R: Rider; VAR x: INTEGER);
VAR b: ARRAY 4 OF SHORTCHAR;
BEGIN ReadBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 4), 4);
  x := ORD(b[0]) + ORD(b[1]) * 100H + ORD(b[2]) * 10000H +
    ORD(b[3]) * 1000000H
END ReadInt;

PROCEDURE ReadLInt*(VAR R: Rider; VAR x: INT64);
VAR b: ARRAY 8 OF SHORTCHAR; n: INTEGER; s: INT64;
BEGIN ReadBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 8), 8);
  x := ORD(b[0]); s := 100H;
  FOR n := 1 TO 7 DO INC(x, ORD(b[n]) * s); s := s * 100H END
END ReadLInt;

PROCEDURE ReadSet*(VAR R: Rider; VAR x: SET);
VAR b: ARRAY 4 OF SHORTCHAR;
BEGIN ReadBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 4), 4);
  x := SYSTEM.VAL(SET, ORD(b[0]) + ORD(b[1]) * 100H +
    ORD(b[2]) * 10000H + ORD(b[3]) * 1000000H)
END ReadSet;

PROCEDURE ReadReal*(VAR R: Rider; VAR x: SHORTREAL);
VAR b: ARRAY 4 OF BYTE;
BEGIN ReadBytes(R, b, 4);
  FlipBytes(b, SYSTEM.THISARR(SYSTEM.ADR(x), 4))
END ReadReal;

PROCEDURE ReadLReal*(VAR R: Rider; VAR x: REAL);
VAR b: ARRAY 8 OF BYTE;
BEGIN ReadBytes(R, b, 8);
  FlipBytes(b, SYSTEM.THISARR(SYSTEM.ADR(x), 8))
END ReadLReal;

PROCEDURE ReadShortString*(VAR R: Rider; VAR x: ARRAY OF SHORTCHAR);
VAR i: INTEGER; ch: SHORTCHAR;
BEGIN i := 0; (*!FIXME code from scratch*)
  REPEAT ReadShortChar(R, ch); x[i] := ch; INC(i) UNTIL ch = 0X
END ReadShortString;

PROCEDURE ReadString*(VAR R: Rider; VAR x: ARRAY OF CHAR);
VAR i: INTEGER; ch: CHAR;
BEGIN i := 0; (*!FIXME code from scratch*)
  REPEAT ReadChar(R, ch); x[i] := ch; INC(i) UNTIL ch = 0X
END ReadString;

PROCEDURE ReadLine*(VAR R: Rider; VAR x: ARRAY OF SHORTCHAR);
VAR i: INTEGER; ch: SHORTCHAR; b: BOOLEAN;
BEGIN i := 0; b := FALSE;
  REPEAT
    ReadShortChar(R, ch);
    IF ((ch = 0X) OR (ch = 0AX) OR (ch = 0DX)) THEN b := TRUE
    ELSE x[i] := ch; INC(i)
    END
  UNTIL b
END ReadLine;

PROCEDURE ReadNum*(VAR R: Rider; VAR x: INTEGER);
VAR n: INTEGER; b: BYTE;
BEGIN n := 0; x := 0; Read(R, b);
  WHILE b >= 128 DO
    INC(x, ASH(LONG(b) - 128, n)); INC(n, 7); Read(R, b)
  END;
  INC(x, ASH(LONG(b) MOD 64 - LONG(b) DIV 64 * 64, n))
END ReadNum;

PROCEDURE WriteBool*(VAR R: Rider; x: BOOLEAN);
BEGIN Write(R, SYSTEM.VAL(BYTE, x))
END WriteBool;

PROCEDURE WriteShortChar*(VAR R: Rider; x: SHORTCHAR);
BEGIN Write(R, SYSTEM.VAL(BYTE, x))
END WriteShortChar;

PROCEDURE WriteChar*(VAR R: Rider; c: CHAR);
VAR i, L: INTEGER;
  q: ARRAY 5 OF SHORTCHAR;
BEGIN
  Utf8.EncodeChar(c, q, L); i := 0;
  WHILE i # L DO Write(R, SYSTEM.VAL(BYTE, q[i])); INC(i) END
END WriteChar;

PROCEDURE WriteSInt*(VAR R: Rider; x: SHORTINT);
VAR b: ARRAY 2 OF SHORTCHAR;
BEGIN b[0] := SHORT(CHR(x)); b[1] := SHORT(CHR(x DIV 256));
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 2), 2)
END WriteSInt;

PROCEDURE WriteInt*(VAR R: Rider; x: INTEGER);
VAR b: ARRAY 4 OF SHORTCHAR;
BEGIN b[0] := SHORT(CHR(x)); b[1] := SHORT(CHR(x DIV 100H));
  b[2] := SHORT(CHR(x DIV 10000H)); b[3] := SHORT(CHR(x DIV 1000000H));
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 4), 4)
END WriteInt;

PROCEDURE WriteLInt*(VAR R: Rider; x: INT64);
VAR b: ARRAY 8 OF SHORTCHAR; n: INTEGER; s: INT64;
BEGIN b[0] := SHORT(CHR(x)); s := 100H;
  FOR n := 0 TO 7 DO b[n] := SHORT(CHR(x DIV s)); s := s*100H END;
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 8), 8)
END WriteLInt;

PROCEDURE WriteSet*(VAR R: Rider; x: SET);
VAR b: ARRAY 4 OF SHORTCHAR; i: INTEGER;
BEGIN i := SYSTEM.VAL(INTEGER, x);
  b[0] := SHORT(CHR(i)); b[1] := SHORT(CHR(i DIV 100H));
  b[2] := SHORT(CHR(i DIV 10000H)); b[3] := SHORT(CHR(i DIV 1000000H));
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 4), 4)
END WriteSet;

PROCEDURE WriteReal*(VAR R: Rider; x: SHORTREAL);
VAR b: ARRAY 4 OF BYTE;
BEGIN FlipBytes(SYSTEM.THISARR(SYSTEM.ADR(x), 4), b);
  WriteBytes(R, b, 4)
END WriteReal;

PROCEDURE WriteLReal*(VAR R: Rider; x: REAL);
VAR b: ARRAY 8 OF BYTE;
BEGIN FlipBytes(SYSTEM.THISARR(SYSTEM.ADR(x), 8), b);
  WriteBytes(R, b, 8)
END WriteLReal;

PROCEDURE WriteShortString*(VAR R: Rider; IN s: ARRAY OF SHORTCHAR);
VAR i: INTEGER;
BEGIN i := 0; WHILE s[i] # 0X DO INC(i) END;
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(s), LEN(s)), i + 1)
END WriteShortString;

PROCEDURE WriteString*(VAR R: Rider; IN s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := -1;
  REPEAT INC(i); WriteChar(R, s[i]) UNTIL (i = LEN(s)) OR (s[i] = 0X)
END WriteString;

PROCEDURE WriteNum*(VAR R: Rider; x: INTEGER);
BEGIN
  WHILE (x < - 64) OR (x > 63) DO
    Write(R, SYSTEM.VAL(BYTE, x MOD 128 + 128)); x := x DIV 128
  END;
  Write(R, SYSTEM.VAL(BYTE, x MOD 128))
END WriteNum;

PROCEDURE GetName*(f: File; VAR name: ARRAY OF CHAR);
BEGIN name := f.workName$
END GetName;

PROCEDURE Finalize(o: SYSTEM.PTR);
VAR f: File; res: INTEGER;
  q: ARRAY 2048 OF SHORTCHAR;
BEGIN f := SYSTEM.VAL(File, o);
  IF f.fd # Platform.InvalidHandleValue() THEN
    CloseOSFile(f);
    IF f.tempFile THEN
      Utf8.Encode(f.workName, q);
      res := Platform.DeleteFile(q)
    END
  END
END Finalize;

PROCEDURE SetSearchPath*(IN path: ARRAY OF CHAR);
BEGIN SearchPath := path$
END SetSearchPath;

PROCEDURE Init;
VAR q: ARRAY 2048 OF SHORTCHAR;
BEGIN tempno := -1; Heap.FileCount := 0; SearchPath := '';
  Platform.GetEnv('HOME', q); Utf8.Decode(q, home);
END Init;

BEGIN
  Init
END Files.
