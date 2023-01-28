MODULE Files;
(** Input-output of standard data types from/to a storage media.

      The order of bytes used is Little Endian,
      SInt: 2 bytes, Int: 4 bytes, LInt: 8 bytes
      ORD({0}) = 1,
      FALSE = 0, TRUE = 1
      IEEE Real Format,
      Null-terminated strings,
      compact numbers according to M. Odersky

%RU Ввод-вывод стандартных типов данных с/на носитель информации

      Используется порядок байтов от младшего к старшему,
      SInt: 2 байта, Int: 4 байта, LInt: 8 байтов.
      ORD({0}) = 1,
      FALSE = 0, TRUE = 1
      Вещественный формат IEEE,
      Нуль-терминированные строки,
      компактные числа по М. Одерскому *)

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
  SBYTE* = BYTE; (** Signed 8-bit integer, -128..127
%RU                  Знаковое 8-битное целое, -128..127 *)
  BYTE* = UBYTE; (** Unsigned 8-bit integer, 0..255
%RU                  Беззнаковое 8-битное целое, 0..255 *)
  INT64 = LONGINT; (** Signed 64-bit integer
%RU                    Знаковое 64-битное целое *)
  LONGINT = INTEGER; (* For larger version of Files, i.e. Files64
%RU                     Для более крупной версии Files, т.е. Files64 *)

  FileName = ARRAY 256 OF CHAR;
  File* = POINTER TO FileDesc; (** A file object
%RU                                Объект, представляющий файл *)
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

  (** Rider on a file. Used to read or write data from/to a file.
      Can be set in a arbitrary place in a file. Automatically moves forward
      in a file every time it is used for reading or writing
%RU   Бегунок по файлу. Используется для чтения или записи данных из/в файл.
      Может быть установлен в произвольном месте файла. Автоматически
      перемещается вперёд в файле всякий раз, когда используется для
      чтения или записи. *)
  Rider* = RECORD
    res*: INTEGER; (** Residue (byte count not read) at eof of ReadBytes
%RU                     *)
    eof*: BOOLEAN; (** TRUE when end of file is reached. Should be checked
                       after calling Read procedures.
%RU                    TRUE, когда достигнут конец файла. Должен проверяться
                       после вызова Read-процедур. *)
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

(** Flushes the contents of the file to storage media.
    The file can still be used after a call to Close.
%RU Сбрасывает содержимое файла на носитель.
    Файл может быть использован и после вызова Close. *)
PROCEDURE Close*(f: File);
VAR i: INTEGER;
BEGIN
  IF (f.state # create) OR (f.registerName # '') THEN
    Create(f); i := 0;
    WHILE (i < NumBufs) & (f.bufs[i] # NIL) DO Flush(f.bufs[i]); INC(i) END
  END
END Close;

(** Returns the length of the given file in bytes
%RU Возвращает длину данного файла в байтах *)
PROCEDURE Length*(f: File): LONGINT;
BEGIN RETURN f.len END Length;

(** Creates and returns a file object with the given file name.
     This procedure is used to create new files or rewrite old files, but
    New does not delete or rewrite the file if it existed -- this is done
    by Register or Close.
%RU Создает и возвращает объект файла с заданным именем файла.
     Эта процедура используется для создания новых или перезаписи старых
    файлов, но New не удаляет и не перезаписывает файл, если он уже
    существовал -- это делает Register или Close. *)
PROCEDURE New*(IN name: ARRAY OF CHAR): File;
VAR f: File;
BEGIN
  NEW(f); f.workName := ''; f.registerName := name$;
  f.fd := Platform.InvalidHandleValue(); f.state := create;
  f.len := 0; f.pos := 0; f.swapper := -1 ;
RETURN f END New;

PROCEDURE ScanPath(VAR pos: INTEGER; VAR dir: ARRAY OF CHAR);
(** Extract next individual directory from searchpath starting at pos,
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
RETURN ch # 0X END HasDir;

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

(** Opens a file with the given file name if it exists. Returns the object
    representing the file. If the file does not exist, returns NIL.
     If you write to a file opened with Old, the changes will be stored
    in the storage medium only after a call to Register or Close.
%RU Открывает файл с заданным именем файла, если он существует. Возвращает
    объект, представляющий этот файл. Если файл не существует, возвращает NIL.
     Если вы пишете в файл, открытый с помощью Old, изменения будут сохранены
     на носителе информации только после вызова Register или Close. *)
PROCEDURE Old*(name: ARRAY OF CHAR): File;
VAR f: File;
  fd: Platform.FileHandle;
  i, pos: INTEGER;
  done: BOOLEAN;
  dir, path: ARRAY 256 OF CHAR;
  error: Platform.ErrorCode;
  identity: Platform.FileIdentity;
  q: ARRAY 4096 OF SHORTCHAR;
  n: INT64;
BEGIN
  IF name # '' THEN
    (* Replace all / with \ if required *)
    IF PathDelimiter = '\' THEN i := 0;
      WHILE (i # LEN(name)) & (name[i] # 0X) DO
        IF name[i] = '/' THEN name[i] := '\' END;
        INC(i)
      END
    END;

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

(** Frees the sectors of storage device used by the file
%RU Освобождает сектора носителя данных, используемые файлом *)
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

(** Puts in `t` and `d` the time and date of the file in a special bit format:
      d = YYYYYYYMMMMDDDDD  Y-year  M-month   D-day
      t = HHHHmmmmmmSSSSSS  H-hour  m-minute  S-second
    The year bits hold the two last digits of the year
%RU Помещает в `t` и `d` время и дату файла в особом битовом формате:
      d = YYYYYYYMMMMDDDDD  Y-год  M-месяц   D-день
      t = HHHHmmmmmmSSSSSS  H-час  m-минута  S-секунда
    Биты года содержат две последние цифры года.*)
PROCEDURE GetDate*(f: File; VAR t, d: INTEGER);
VAR identity: Platform.FileIdentity;
  error: Platform.ErrorCode;
BEGIN Create(f); error := Platform.Identify(f.fd, identity);
  Platform.MTimeAsClock(identity, t, d)
END GetDate;

(** Returns position of rider `r` in the file.
     Note that the position is measured in bytes (and not characters, each
    of which is coded in UTF-8 as 1, 2, 3 or 4 bytes).
     Position 0 means the position exactly before the very first byte of the
    file. Position Length() points at exactly after the last byte.
%RU Возвращает позицию бегунка `r` в файле.
     Обратите внимание, что позиция измеряется в байтах (а не в литерах,
    каждая из которых закодирована в UTF-8 как 1, 2, 3 или 4 байта).
     Позиция 0 означает позицию точно перед самым первым байтом файла.
    Позиция Length() указывает на позицию сразу после последнего байта. *)
PROCEDURE Pos*(VAR r: Rider): INTEGER;
BEGIN RETURN r.org + r.offset
END Pos;

(** Sets rider `r` at position `pos` of the file `f`.
     Use this procedure after successfully opening a file with Old or New.
     Note that the position is measured in bytes (and not characters, each
    of which is coded in UTF-8 as 1, 2, 3 or 4 bytes).
    Position 0 means the position exactly before the very first byte of the
    file. Position Length() points at exactly after the last byte.
%RU Устанавливает райдер `r` в позиции `pos` файла `f`.
     Эту процедуру вызывают после успешного открытия файла с помощью Old
    или New.
     Обратите внимание, что позиция измеряется в байтах (а не в литерах,
    каждая из которых закодирована в UTF-8 как 1, 2, 3 или 4 байта).
     Позиция 0 означает позицию точно перед самым первым байтом файла.
    Позиция Length() указывает на позицию сразу после последнего байта. *)
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

(** Reads one byte from a file and puts it in `x`.
     The rider `r` must have been set to a file using Set.
%RU Считывает один байт из файла и помещает его в `x`.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
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

(** Reads several bytes from a file and puts it in `x`. Puts the number of
    bytes read in `n`.
     The rider `r` must have been set to a file using Set.
%RU Считывает несколько байтов из файла и помещает их в `x`, количество
    считанных байтов помещается в `n`.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
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

(** Reads one byte from a file and puts it in `x` as a short (ASCII) character.
     The rider `r` must have been set to a file using Set.
%RU Считывает один байт из файла и помещает его в `x` в виде короткого
    (ASCII) символа.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadShortChar*(VAR r: Rider; VAR x: SHORTCHAR);
BEGIN Read(r, SYSTEM.VAL(BYTE, x))
END ReadShortChar;

(** Reads up to four bytes (but at least one byte) from a file, interprets
    them as a UTF-8-encoded character and puts the decoded character in `x`
    (as 2 bytes in UCS-2 format).
     The rider `r` must have been set to a file using Set.
%RU Считывает до четырех байт (но не менее одного байта) из файла,
    расценивает их как литеру, закодированную в UTF-8, и помещает
    декодированную литеру в `x` (как 2 байта в формате UCS-2).
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
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

(** Returns a file object that was connected to rider `r` with Set.
%RU Возвращает файловый объект, связанный с бегунком `r` с помощью Set. *)
PROCEDURE Base*(VAR r: Rider): File;
BEGIN RETURN r.buf.f
END Base;

(** Writes a single byte `x` to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл один байт `x`.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
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

(** Writes `n` bytes from array `x` to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
    Записывает в файл `n` байт из массива `x`.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
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

(** Truncates a file at position `pos`.
    The file length will be equal to `pos`.
%RU Усекает файл в позиции `pos`.
    Длина файла будет равна `pos`. *)
PROCEDURE Truncate*(F: File; pos: INTEGER);
BEGIN F.len := pos (*!FIXME*)
END Truncate;

(** Deletes (deregisters) a file with the given name from the storage media.
     Sets `res` to 0 on success, 1 on error.
     IMPORTANT! It uses SearchPath to find the specified file.
%RU Удаляет (дерегистрирует) файл с заданным именем с носителя.
     Устанавливает `res` в 0 при успехе, в 1 при ошибке.
     ВАЖНО! Для поиска указанного файла используется SearchPath. *)
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

(** Renames a file with the name `old` to `new`.
     Sets `res` to 0 on success, non-0 on error.
     `res = 2` means file not found.
     IMPORTANT! It uses SearchPath to find the specified file.
%RU Переименовывает файл с именем `old` в `new`.
     Устанавливает `res` в 0 при успехе, не-0 при ошибке.
     `res = 2` означает, что файл не найден.
     ВАЖНО! Для поиска указанного файла используется SearchPath. *)
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

(** Registers and saves a file on the storage media.
     Call Register when you are finished writing a file.
    Register can be called several times and anywhere in between.
%RU Регистрирует и сохраняет файл на носителе.
     Вызовите Register, когда закончите запись файла.
    Register можно вызывать несколько раз и в любой точке создания файла. *)
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

(** Sets current working directory to `path`.
     Sets `res` to 0 on success, non-0 on failure.
%RU Устанавливает текущий рабочий каталог в `path`.
     Устанавливает `res` в 0 при успехе, в не-0 при неудаче. *)
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

(** Reads one byte from a file and puts it in `x` as a BOOLEAN value,
    where byte value of 0 means FALSE, other values mean TRUE.
     The rider `r` must have been set to a file using Set.
%RU Считывает один байт из файла и помещает его в `x` как значение типа
    BOOLEAN. Значение 0 означает FALSE, а другие значения означают TRUE.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadBool*(VAR R: Rider; VAR x: BOOLEAN);
BEGIN Read(R, SYSTEM.VAL(BYTE, x))
END ReadBool;

(** Reads two bytes from a file and puts them in `x` as a SHORTINT.
     The rider `r` must have been set to a file using Set.
%RU Считывает два байта из файла и помещает их в `x` в виде SHORTINT.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadSInt*(VAR R: Rider; VAR x: SHORTINT);
VAR b: ARRAY 2 OF SHORTCHAR;
BEGIN ReadBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 2), 2);
  x := SHORT(ORD(b[0]) + ORD(b[1])*256)
END ReadSInt;

(** Reads four bytes from a file and puts them in `x` as an INTEGER.
     The rider `r` must have been set to a file using Set.
%RU Считывает четыре байта из файла и помещает их в `x` в виде INTEGER.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadInt*(VAR R: Rider; VAR x: INTEGER);
VAR b: ARRAY 4 OF SHORTCHAR;
BEGIN ReadBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 4), 4);
  x := ORD(b[0]) + ORD(b[1]) * 100H + ORD(b[2]) * 10000H +
    ORD(b[3]) * 1000000H
END ReadInt;

(** Reads eight bytes from a file and puts them in `x` as a LONGINT.
     The rider `r` must have been set to a file using Set.
%RU Считывает восемь байтов из файла и помещает их в `x` в виде LONGINT.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadLInt*(VAR R: Rider; VAR x: INT64);
VAR b: ARRAY 8 OF SHORTCHAR; n: INTEGER; s: INT64;
BEGIN ReadBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 8), 8);
  x := ORD(b[0]); s := 100H;
  FOR n := 1 TO 7 DO INC(x, ORD(b[n]) * s); s := s * 100H END
END ReadLInt;

(** Reads four bytes from a file and puts it in `x` as a SET.
     The rider `r` must have been set to a file using Set.
%RU Считывает четыре байта из файла и помещает их в `x` в виде SET.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadSet*(VAR R: Rider; VAR x: SET);
VAR b: ARRAY 4 OF SHORTCHAR;
BEGIN ReadBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 4), 4);
  x := SYSTEM.VAL(SET, ORD(b[0]) + ORD(b[1]) * 100H +
    ORD(b[2]) * 10000H + ORD(b[3]) * 1000000H)
END ReadSet;

(** Reads four bytes from a file and puts it in `x` as REAL.
     The rider `r` must have been set to a file using Set.
%RU Считывает четыре байта из файла и помещает их в `x` как REAL.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadReal*(VAR R: Rider; VAR x: SHORTREAL);
VAR b: ARRAY 4 OF BYTE;
BEGIN ReadBytes(R, b, 4);
  FlipBytes(b, SYSTEM.THISARR(SYSTEM.ADR(x), 4))
END ReadReal;

(** Reads eight bytes from a file and puts it in `x` as LONGREAL.
     The rider `r` must have been set to a file using Set.
%RU Считывает восемь байтов из файла и помещает их в `x` как LONGREAL.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadLReal*(VAR R: Rider; VAR x: REAL);
VAR b: ARRAY 8 OF BYTE;
BEGIN ReadBytes(R, b, 8);
  FlipBytes(b, SYSTEM.THISARR(SYSTEM.ADR(x), 8))
END ReadLReal;

(** Reads bytes from a file until the first zero byte, puts all in `x`.
     The rider `r` must have been set to a file using Set.
%RU Считывает байты из файла до первого нулевого байта, помещает всё в `x`.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadShortString*(VAR R: Rider; VAR x: ARRAY OF SHORTCHAR);
VAR i: INTEGER; ch: SHORTCHAR;
BEGIN i := 0; (*!FIXME code from scratch*)
  REPEAT ReadShortChar(R, ch); x[i] := ch; INC(i) UNTIL ch = 0X
END ReadShortString;

(** Reads a file character by character until the first 0X, puts all in `x`.
     The rider `r` must have been set to a file using Set.
%RU Считывает файл по одной литере до первой литеры 0X, помещает всё в `x`.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadString*(VAR R: Rider; VAR x: ARRAY OF CHAR);
VAR i: INTEGER; ch: CHAR;
BEGIN i := 0; (*!FIXME code from scratch*)
  REPEAT ReadChar(R, ch); x[i] := ch; INC(i) UNTIL ch = 0X
END ReadString;

(** Reads bytes from a file until the first 0X, 0AX or 0DX byte,
    puts all in `x` (except the last byte).
     The rider `r` must have been set to a file using Set.
%RU Считывает байты из файла до первого байта 0X, 0AX или 0DX,
    помещает всё в `x` (кроме последнего байта).
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
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

(** Reads one or more bytes from a file to decode a compact number
    (according to M. Odersky), puts the number read in `x`.
     The rider `r` must have been set to a file using Set.
%RU Считывает один или несколько байт из файла и декодирует их как
    компактное число (по М. Одерскому), помещает считанное число в `x`.
     Бегунок `r` должен быть установлен на файл с помощью Set. *)
PROCEDURE ReadNum*(VAR R: Rider; VAR x: INTEGER);
VAR n: INTEGER; b: BYTE;
BEGIN n := 0; x := 0; Read(R, b);
  WHILE b >= 128 DO
    INC(x, ASH(LONG(b) - 128, n)); INC(n, 7); Read(R, b)
  END;
  INC(x, ASH(LONG(b) MOD 64 - LONG(b) DIV 64 * 64, n))
END ReadNum;

(** Writes BOOLEAN `x` as one byte to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл BOOLEAN `x` в виде одного байта.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteBool*(VAR R: Rider; x: BOOLEAN);
BEGIN Write(R, SYSTEM.VAL(BYTE, x))
END WriteBool;

(** Writes short (1-byte) character `x` to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл короткую (однобайтную) литеру `x`.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteShortChar*(VAR R: Rider; x: SHORTCHAR);
BEGIN Write(R, SYSTEM.VAL(BYTE, x))
END WriteShortChar;

(** Writes character `x` as UTF-8 to a file (1 to 4 bytes).
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл литеру `x` в формате UTF-8 (от 1 до 4 байт).
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteChar*(VAR R: Rider; c: CHAR);
VAR i, L: INTEGER;
  q: ARRAY 5 OF SHORTCHAR;
BEGIN
  Utf8.EncodeChar(c, q, L); i := 0;
  WHILE i # L DO Write(R, SYSTEM.VAL(BYTE, q[i])); INC(i) END
END WriteChar;

(** Writes SHORTINT `x` as two bytes to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл SHORTINT `x` как два байта.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteSInt*(VAR R: Rider; x: SHORTINT);
VAR b: ARRAY 2 OF SHORTCHAR;
BEGIN b[0] := SHORT(CHR(x)); b[1] := SHORT(CHR(x DIV 256));
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 2), 2)
END WriteSInt;

(** Writes INTEGER `x` as four bytes to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл INTEGER `x` как четыре байта.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteInt*(VAR R: Rider; x: INTEGER);
VAR b: ARRAY 4 OF SHORTCHAR;
BEGIN b[0] := SHORT(CHR(x)); b[1] := SHORT(CHR(x DIV 100H));
  b[2] := SHORT(CHR(x DIV 10000H)); b[3] := SHORT(CHR(x DIV 1000000H));
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 4), 4)
END WriteInt;

(** Writes LONGINT `x` as eight bytes to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл LONGINT `x` как восемь байтов.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteLInt*(VAR R: Rider; x: INT64);
VAR b: ARRAY 8 OF SHORTCHAR; n: INTEGER; s: INT64;
BEGIN b[0] := SHORT(CHR(x)); s := 100H;
  FOR n := 0 TO 7 DO b[n] := SHORT(CHR(x DIV s)); s := s*100H END;
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 8), 8)
END WriteLInt;

(** Writes SET `x` as four bytes to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл SET `x` как четыре байта.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteSet*(VAR R: Rider; x: SET);
VAR b: ARRAY 4 OF SHORTCHAR; i: INTEGER;
BEGIN i := SYSTEM.VAL(INTEGER, x);
  b[0] := SHORT(CHR(i)); b[1] := SHORT(CHR(i DIV 100H));
  b[2] := SHORT(CHR(i DIV 10000H)); b[3] := SHORT(CHR(i DIV 1000000H));
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(b), 4), 4)
END WriteSet;

(** Writes REAL `x` as four bytes to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл REAL `x` как четыре байта.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteReal*(VAR R: Rider; x: SHORTREAL);
VAR b: ARRAY 4 OF BYTE;
BEGIN FlipBytes(SYSTEM.THISARR(SYSTEM.ADR(x), 4), b);
  WriteBytes(R, b, 4)
END WriteReal;

(** Writes LONGREAL `x` as eight bytes to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл LONGREAL `x` как восемь байтов.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteLReal*(VAR R: Rider; x: REAL);
VAR b: ARRAY 8 OF BYTE;
BEGIN FlipBytes(SYSTEM.THISARR(SYSTEM.ADR(x), 8), b);
  WriteBytes(R, b, 8)
END WriteLReal;

(** Writes string `x` consising of a 1-byte characters to a file.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл строку `x`, состоящую из 1-байтовых литер.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteShortString*(VAR R: Rider; IN x: ARRAY OF SHORTCHAR);
VAR i: INTEGER;
BEGIN i := 0; WHILE x[i] # 0X DO INC(i) END;
  WriteBytes(R, SYSTEM.THISARR(SYSTEM.ADR(x), LEN(x)), i + 1)
END WriteShortString;

(** Writes string `x` to a file in UTF-8 format.
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл строку `x` в формате UTF-8.
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteString*(VAR R: Rider; IN x: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := -1;
  REPEAT INC(i); WriteChar(R, x[i]) UNTIL (i = LEN(x)) OR (x[i] = 0X)
END WriteString;

(** Writes INTEGER `x` as one or more bytes to a file in a compact number
    format (according to M. Odersky).
     The rider `r` must have been set to a file using Set.
     The file is not immediately written on a storage media.
%RU Записывает в файл INTEGER `x` в виде одного или нескольких байтов
    в формате компактного числа формате (по М. Одерскому).
     Бегунок `r` должен быть установлен на файл с помощью Set.
     Файл не записывается на носитель сразу. *)
PROCEDURE WriteNum*(VAR R: Rider; x: INTEGER);
BEGIN
  WHILE (x < - 64) OR (x > 63) DO
    Write(R, SYSTEM.VAL(BYTE, x MOD 128 + 128)); x := x DIV 128
  END;
  Write(R, SYSTEM.VAL(BYTE, x MOD 128))
END WriteNum;

(** Puts in `name` the naem of the file `f`.
%RU Помещает в `name` имя файла `f`. *)
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

(** Sets a search path for Old, New, Delete, Rename etc.
%RU Устанавливает путь поиска для Old, New, Delete, Rename и т. д. *)
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
