MODULE OPM;  (* RC 6.3.89 / 28.6.89, J.Templ 10.7.89 / 22.7.96  *)
(* constants needed for C code generation

  31.1.2007 jt synchronized with BlackBox version, in particular PromoteIntConstToLInt added
*)

  IMPORT SYSTEM, Texts, Files, Platform, Modules, Out, Configuration, VT100, Strings;

  CONST
    OptionChar* = "-";

    (* compiler option flag bits; don't change the encoding *)
    inxchk*         = 0;  (* index check on *)
    ranchk*         = 2;  (* range check on *)
    typchk*         = 3;  (* type check on *)
    newsf*          = 4;  (* generation of new symbol file allowed *)
    ptrinit*        = 5;  (* pointer initialization *)
    assert*         = 7;  (* assert evaluation *)
    extsf*          = 9;  (* extension of old symbol file allowed *)
    mainprog*       = 10; (* translate module body into C main function *)
    dontasm*        = 13; (* don't call external assembler/C compiler *)
    dontlink*       = 14; (* don't link *)
    mainlinkstat*   = 15; (* generate code for main module and then link object file statically *)
    notcoloroutput* = 16; (* turn off color output *)
    forcenewsym*    = 17; (* force new symbol file *)
    verbose*        = 18; (* verbose *)

    nilval*         = 0;

    MaxRExp*        = 38;
    MaxLExp*        = 308;

    MinHaltNr*      = 0;
    MaxHaltNr*      = 255;
    MaxSysFlag*     = 1;

    MaxCC*          = -1;  (* SYSTEM.CC, GETREG, PUTREG; not implementable in C backend *)
    MinRegNr*       = 0;
    MaxRegNr*       = -1;

    LANotAlloc*     = -1;  (* XProc link adr initialization *)
    ConstNotAlloc*  = -1;  (* for allocation of string and real constants *)
    TDAdrUndef*     = -1;  (* no type desc allocated *)

    MaxCases*       = 128;
    MaxCaseRange*   = 512;

    MaxStruct*      = 255;

    (* maximal number of hidden fields in an exported record: *)
    MaxHdFld*       = 2048;

    HdPtrName*      = "@ptr";
    HdProcName*     = "@proc";
    HdTProcName*    = "@tproc";

    ExpHdPtrFld*    = TRUE;
    ExpHdProcFld*   = FALSE;
    ExpHdTProc*     = FALSE;

    NEWusingAdr*    = FALSE;

    Eot*            = 0X;

    HeaderFile*     = 0;
    BodyFile*       = 1;
    HeaderInclude*  = 2;

    (* C default expression integral size details. Const for now, should be var for avr_gcc/sdcc support *)
    CIntSize*       = 4;
    CIntMax*        = 7FFFFFFFH;
    CIntMin*        = -CIntMax - 1;


    SFext = ".sym"; (* symbol file extension *)
    BFext = ".c";   (* body file extension *)
    HFext = ".h";   (* header file extension *)
    SFtag = 0F7X;   (* symbol file tag *)
    SFver = 083X;   (* symbol file version. Increment if symbol file format is changed. *)




  TYPE
    FileName = ARRAY 32 OF CHAR;

  VAR
    SourceFileName : ARRAY 256 OF CHAR;

    GlobalModel,       Model*:       ARRAY 10 OF CHAR;  (* 2: S8/I16/L32, C: S16/I32/L64, V:S8/I32/L64 *)
    GlobalAddressSize, AddressSize*: INTEGER;
    GlobalAlignment,   Alignment*:   INTEGER;
    GlobalOptions*,    Options*:     SET;

    ShortintSize*, IntegerSize*, LongintSize*, SetSize*: INTEGER;

    MaxIndex*: SYSTEM.INT64;

    MinReal*, MaxReal*, MinLReal*, MaxLReal*: LONGREAL;

    noerr*:           BOOLEAN;
    curpos*, errpos*: LONGINT;  (* character and error position in source file *)
    breakpc*:         LONGINT;  (* set by OPV.Init *)
    currFile*:        INTEGER;  (* current output file *)
    level*:           INTEGER;  (* procedure nesting level *)
    pc*, entno*:      INTEGER;  (* entry number *)
    modName*:         ARRAY 32 OF CHAR;
    objname*:         ARRAY 64 OF CHAR;

    ErrorLineStartPos, ErrorLineLimitPos, ErrorLineNumber: LONGINT;  (* Limit = start of next line *)

    lasterrpos:   LONGINT;
    inR:          Texts.Reader;
    Log, Errors:  Texts.Text;
    oldSF, newSF: Files.Rider;
    R:            ARRAY 3 OF Files.Rider;

    oldSFile, newSFile, HFile, BFile, HIFile: Files.File;

    S: INTEGER;

    InstallDir*:  ARRAY 1024 OF CHAR;
    ResourceDir*: ARRAY 1024 OF CHAR;


  (* ------------------------- Log Output ------------------------- *)

  PROCEDURE LogW*(ch: CHAR);                BEGIN Out.Char(ch)    END LogW;
  PROCEDURE LogWStr*(s: ARRAY OF CHAR);     BEGIN Out.String(s)   END LogWStr;
  PROCEDURE LogWNum*(i, len: SYSTEM.INT64); BEGIN Out.Int(i, len) END LogWNum;
  PROCEDURE LogWLn*;                        BEGIN Out.Ln          END LogWLn;

  PROCEDURE LogVT100*(vt100code: ARRAY OF CHAR);
  BEGIN
    IF Out.IsConsole & ~(notcoloroutput IN Options) THEN
      VT100.SetAttr(vt100code)
    END
  END LogVT100;

  PROCEDURE LogCompiling*(modname: ARRAY OF CHAR);
  BEGIN
    LogWStr("Compiling "); LogWStr(modname);
    IF verbose IN Options THEN
      LogWStr(", s:");    LogWNum(ShortintSize*8,1);
      LogWStr( " i:");    LogWNum(IntegerSize*8,1);
      LogWStr( " l:");    LogWNum(LongintSize*8,1);
      LogWStr( " adr:");  LogWNum(AddressSize*8,1);
      LogWStr( " algn:"); LogWNum(Alignment*8,1)
    END;
    LogW(".");
  END LogCompiling;


  (* Integer size support *)

  PROCEDURE SignedMaximum*(bytecount: LONGINT): SYSTEM.INT64;
  VAR result: SYSTEM.INT64;
  BEGIN
    result := 1;
    result := SYSTEM.LSH(result, bytecount*8-1);
    RETURN result - 1;
  END SignedMaximum;

  PROCEDURE SignedMinimum*(bytecount: LONGINT): SYSTEM.INT64;
  BEGIN RETURN -SignedMaximum(bytecount) - 1
  END SignedMinimum;


  (* Unchecked conversion of any size integer to INTEGER or LONGINT *)

  PROCEDURE Longint* (n: SYSTEM.INT64): LONGINT; BEGIN RETURN SYSTEM.VAL(LONGINT, n) END Longint;
  PROCEDURE Integer* (n: SYSTEM.INT64): INTEGER; BEGIN RETURN SYSTEM.VAL(INTEGER, n) END Integer;




  (* --------------- Initialisation and parameter handling ---------------*)

  PROCEDURE ScanOptions(s: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN
  i := 1; (* skip - *)
    WHILE s[i] # 0X DO
      CASE s[i] OF

      (* Run time safety *)
      | "p": Options := Options / {ptrinit}          (* Initialise pointers to NIL. *)
      | "a": Options := Options / {assert}           (* Halt on assertion failures. *)
      | "r": Options := Options / {ranchk}           (* Halt on range check failures. *)
      | "t": Options := Options / {typchk}           (* Halt on type guad failure. *)
      | "x": Options := Options / {inxchk}           (* Halt on index out of range. *)

      (* Symbol file management *)
      | "e": Options := Options / {extsf}            (* Allow extension of old symbol file. *)
      | "s": Options := Options / {newsf}            (* Allow generation of new symbol file. *)
      | "F": Options := Options / {forcenewsym}      (* Force generation of new symbol file. *)

      (* C compiler and linker control *)
      | "m": Options := Options / {mainprog}         (* This module is main. Link dynamically. *)
      | "M": Options := Options / {mainlinkstat}     (* This module is main. Link statically. *)
      | "S": Options := Options / {dontasm}          (* Don't call C compiler *)
      | "c": Options := Options / {dontlink}         (* Don't link. *)

      (* Miscellaneous *)
      | "f": Options := Options / {notcoloroutput}   (* Disable VT100 control characters in status output. *)
      | "V": Options := Options / {verbose}

      (* Elementary type size model *)
      | "O": IF i+1 >= Strings.Length(s) THEN LogWStr("-O option requires following size model character."); LogWLn ELSE
               Model[0] := s[i+1]; Model[1] := 0X;
               IF (Model[0] # '2') & (Model[0] # 'C') & (Model[0] # 'V') THEN
                 LogWStr("Unrecognised size model character following -O."); LogWLn
               END;
               INC(i)
             END

      (* Target machine address size and alignment *)
      | "A": IF i+2 >= Strings.Length(s) THEN LogWStr("-M option requires two following digits."); LogWLn ELSE
               AddressSize := ORD(s[i+1]) - ORD('0'); Alignment := ORD(s[i+2]) - ORD('0');
               INC(i, 2)
             END
      ELSE
        LogWStr("  warning: option ");
        LogW(OptionChar);
        LogW(s[i]);
        LogWStr(" ignored");
        LogWLn
      END;
      INC(i)
    END;
  END ScanOptions;


  PROCEDURE -GetAlignment(VAR a: INTEGER) "struct {char c; long long l;} _s; *a = (char*)&_s.l - (char*)&_s";

  PROCEDURE OpenPar*(): BOOLEAN;  (* prepare for a sequence of translations *)
    VAR s: ARRAY 256 OF CHAR;
  BEGIN
    IF Modules.ArgCount = 1 THEN
      LogWLn;
      LogWStr("Oberon-2 compiler v"); LogWStr(Configuration.versionLong); LogW(".");                               LogWLn;
      LogWStr("Based on Ofront by J. Templ and Software Templ OEG.");                                              LogWLn;
      LogWStr("Further development by Norayr Chilingarian, David Brown and others.");                              LogWLn;
      LogWStr("Loaded from "); LogWStr(Modules.BinaryDir);                                                         LogWLn;
      LogWLn;
      LogWStr("Usage:");                                                                                           LogWLn;
      LogWLn;
      LogWStr("  "); LogWStr(Configuration.name); LogWStr(" options {files {options}}.");                          LogWLn;
      LogWLn;
      LogWStr('Options:');                                                                                         LogWLn;
      LogWLn;
      LogWStr("  Run time safety");                                                                                LogWLn;
      LogWStr("    -p   Initialise pointers to NIL. On by default.");                                              LogWLn;
      LogWStr("    -a   Halt on assertion failures. On by default.");                                              LogWLn;
      LogWStr("    -r   Halt on range check failures.");                                                           LogWLn;
      LogWStr("    -t   Halt on type guard failure. On by default.");                                              LogWLn;
      LogWStr("    -x   Halt on index out of range. On by default.");                                              LogWLn;
      LogWLn;
      LogWStr("  Symbol file management");                                                                         LogWLn;
      LogWStr("    -e   Allow extension of old symbol file.");                                                     LogWLn;
      LogWStr("    -s   Allow generation of new symbol file.");                                                    LogWLn;
      LogWStr("    -F   Force generation of new symbol file.");                                                    LogWLn;
      LogWLn;
      LogWStr("  C compiler and linker control");                                                                  LogWLn;
      LogWStr("    -m   This module is main. Link dynamically.");                                                  LogWLn;
      LogWStr("    -M   This module is main. Link statically.");                                                   LogWLn;
      LogWStr("    -S   Don't call C compiler");                                                                   LogWLn;
      LogWStr("    -c   Don't link.");                                                                             LogWLn;
      LogWLn;
      LogWStr("  Miscellaneous");                                                                                  LogWLn;
      LogWStr("    -f   Disable VT100 control characters in status output.");                                      LogWLn;
      LogWStr("    -V   Display compiler debugging messages.");                                                    LogWLn;
      LogWLn;
      LogWStr("  Size model for elementary types (default O2)");                                                   LogWLn;
      LogWStr("    -O2   Original Oberon / Oberon-2:  8 bit SHORTINT, 16 bit INTEGER, 32 bit LONGINT and SET.");   LogWLn;
      LogWStr("    -OC   Component Pascal:           16 bit SHORTINT, 32 bit INTEGER and SET, 64 bit LONGINT.");   LogWLn;
      LogWStr("    -OV   Alternate large model:       8 bit SHORTINT, 32 bit INTEGER, 64 bit LONGINT and SET.");   LogWLn;
      LogWLn;
      LogWStr("  Target machine address size and alignment (default is that of the running compiler binary)");     LogWLn;
      LogWStr("    -A44   32 bit addresses, 32 bit alignment (e.g. Unix/linux 32 bit on x86).");                   LogWLn;
      LogWStr("    -A48   32 bit addresses, 64 bit alignment (e.g. Windows 32 bit on x86, linux 32 bit on arm)."); LogWLn;
      LogWStr("    -A88   64 bit addresses, 64 bit alignment (e.g. 64 bit platforms).");                           LogWLn;
      LogWLn;
      LogWStr("All options are off by default, except where noted above.");                                        LogWLn;
      LogWStr("Initial options specify defaults for all files.");                                                  LogWLn;
      LogWStr("Options following a filename are specific to that file.");                                          LogWLn;
      LogWStr("Repeating an option toggles its value.");                                                           LogWLn;
      RETURN FALSE
    ELSE
      (* Set options to initial defaults *)
      AddressSize := SIZE(SYSTEM.ADDRESS); (* This compilers address size *)
      GetAlignment(Alignment);             (* This compilers alignment *)
      Model := "2";                        (* Size model of common Oberon-2 implementations: S8/I16/L32  *)
      Options := {inxchk, typchk, ptrinit, assert};  (* Default options *)

      (* Pick up global option changes from start of command line *)
      S:=1; s:=""; Modules.GetArg(S, s);
      WHILE s[0] = OptionChar DO
        ScanOptions(s);
        INC(S); s:=""; Modules.GetArg(S, s)
      END;

      (* Record global option settings for this command line *)
      GlobalAddressSize := AddressSize;
      GlobalAlignment   := Alignment;
      GlobalModel       := Model;
      GlobalOptions     := Options;

      RETURN TRUE
    END;
  END OpenPar;


  PROCEDURE InitOptions*;  (* get the options for one translation *)
    VAR s: ARRAY 256 OF CHAR; searchpath, modules: ARRAY 1024 OF CHAR;
    MODULES: ARRAY 1024 OF CHAR;

  BEGIN
    Options := GlobalOptions; Model:=GlobalModel; Alignment := GlobalAlignment; AddressSize := GlobalAddressSize;

    s:=""; Modules.GetArg(S, s);
    WHILE s[0] = OptionChar DO
      ScanOptions(s);
      INC(S); s:=""; Modules.GetArg(S, s)
    END;

    IF mainlinkstat IN Options THEN INCL(Options, mainprog) END;

    MaxIndex := SignedMaximum(AddressSize);
    CASE Model[0] OF
    |'2':  ShortintSize := 1;  IntegerSize := 2;  LongintSize := 4;  SetSize := 4;
    |'C':  ShortintSize := 2;  IntegerSize := 4;  LongintSize := 8;  SetSize := 4;
    |'V':  ShortintSize := 1;  IntegerSize := 4;  LongintSize := 8;  SetSize := 8;
    ELSE   ShortintSize := 1;  IntegerSize := 2;  LongintSize := 4;  SetSize := 4;
    END;

    (*IF verbose IN Options THEN VerboseListSizes END;*)

    ResourceDir := InstallDir;
    IF ResourceDir[0] # 0X THEN
      Strings.Append("/",   ResourceDir);
      Strings.Append(Model, ResourceDir);
    END;

    modules    := "";  Platform.GetEnv("MODULES", modules);
    searchpath := "."; Platform.GetEnv("OBERON",  searchpath);
    Strings.Append(";.;",                         searchpath);
    Strings.Append(modules,                       searchpath);
    Strings.Append(";",                           searchpath);
    Strings.Append(ResourceDir,                   searchpath);
    Strings.Append("/sym;",                       searchpath);
    Files.SetSearchPath(searchpath);
  END InitOptions;


  PROCEDURE Init*(VAR done: BOOLEAN);  (* get the source for one translation *)
  VAR
    T: Texts.Text;
    beg, end, time: LONGINT;
    s: ARRAY 256 OF CHAR;
  BEGIN
    done := FALSE;
    curpos := 0;
    IF S >= Modules.ArgCount THEN RETURN END ;

    s:=""; Modules.GetArg(S, s);

    NEW(T); Texts.Open(T, s);
    LogWStr(s); LogWStr("  ");
    COPY(s, SourceFileName); (* to keep it also in this module -- noch *)

    IF T.len = 0 THEN
      LogWStr(s); LogWStr(" not found."); LogWLn
    ELSE
      Texts.OpenReader(inR, T, 0);
      done := TRUE
    END;

    INC(S);
    level := 0; noerr := TRUE; errpos := curpos; lasterrpos := curpos -10;
    ErrorLineStartPos := 0; ErrorLineLimitPos := 0; ErrorLineNumber := 0;
  END Init;



  (* ------------------------- read source text -------------------------*)

  PROCEDURE Get*(VAR ch: CHAR);  (* read next character from source text, 0X if eof *)
  BEGIN
    curpos := Texts.Pos(inR);
    Texts.Read(inR, ch);

    (* TODO, remove curpos var, and provide fn returning Texts.Pos(inR) - 1. *)
    (* Or, better still, record symbol position in OPS. *)

    IF (ch < 09X) & ~inR.eot THEN ch := " " END
  END Get;


  PROCEDURE MakeFileName(VAR name, FName: ARRAY OF CHAR; ext: ARRAY OF CHAR);
    VAR i, j: INTEGER; ch: CHAR;
  BEGIN i := 0;
    LOOP ch := name[i];
      IF ch = 0X THEN EXIT END ;
      FName[i] := ch; INC(i)
    END ;
    j := 0;
    REPEAT ch := ext[j]; FName[i] := ch; INC(i); INC(j)
    UNTIL ch = 0X
  END MakeFileName;


  PROCEDURE LogErrMsg(n: INTEGER);
  VAR l: INTEGER; S: Texts.Scanner; c: CHAR;
  BEGIN
    IF n >= 0 THEN
      LogVT100(VT100.Red); LogWStr("  err "); LogVT100(VT100.ResetAll)
    ELSE
      LogVT100(VT100.Magenta); LogWStr("  warning "); n := -n; LogVT100(VT100.ResetAll)
    END;
    LogWNum(n, 1);
    LogWStr("  ");

    IF Errors = NIL THEN NEW(Errors); Texts.Open(Errors, "Errors.Txt") END;

    Texts.OpenScanner(S, Errors, 0);
    REPEAT l := S.line; Texts.Scan(S)
    UNTIL (l # S.line) & (S.class = Texts.Int) & (S.i = n)  OR  S.eot;
    IF ~S.eot THEN
      Texts.Read(S, c);
      WHILE ~S.eot & (c >= ' ') DO Out.Char(c); Texts.Read(S, c) END
    END
  END LogErrMsg;


  PROCEDURE FindLine(f: Files.File; VAR r: Files.Rider; pos: SYSTEM.INT64);
  (* Updates ErrorLineStartPos, ErrorLineLimitPos, ErrorLineNumber to
     describe the line containing pos.
     Exits with the rider set to the start of the line conaining pos. *)
  VAR
    ch, cheol: CHAR;
  BEGIN
    IF pos < ErrorLineStartPos THEN  (* Desired position is before saved position, start again at the begnning of file *)
      ErrorLineStartPos := 0; ErrorLineLimitPos := 0; ErrorLineNumber := 0
    END;
    IF pos < ErrorLineLimitPos THEN (* Current saved line positions contain pos *)
      Files.Set(r, f, ErrorLineStartPos);
      RETURN
    END;

    Files.Set(r, f, ErrorLineLimitPos);
    Files.Read(r, ch);
    WHILE (ErrorLineLimitPos < pos) & ~r.eof DO
      ErrorLineStartPos := ErrorLineLimitPos;
      INC(ErrorLineNumber);
      WHILE (ch # 0X) & (ch # 0DX) & (ch # 0AX) DO
        Files.Read(r, ch); INC(ErrorLineLimitPos)
      END;
      cheol := ch; Files.Read(r, ch); INC(ErrorLineLimitPos);
      IF (cheol = 0DX) & (ch = 0AX) THEN
        INC(ErrorLineLimitPos); Files.Read(r, ch)
      END
    END;
    Files.Set(r, f, ErrorLineStartPos);
  END FindLine;


  PROCEDURE ShowLine(pos: SYSTEM.INT64);
  VAR
    f:    Files.File;
    r:    Files.Rider;
    line: ARRAY 1023 OF CHAR;
    i:    INTEGER;
    ch:   CHAR;
  BEGIN
    f := Files.Old(SourceFileName);
    FindLine(f, r, pos);

    i := 0; Files.Read(r, ch);
    WHILE (ch # 0X) & (ch # 0DX) & (ch # 0AX) & (i < LEN(line)-1) DO
      line[i] := ch; INC(i); Files.Read(r, ch)
    END;
    line[i] := 0X;

    LogWLn; LogWLn;
    LogWNum(ErrorLineNumber, 4); LogWStr(": "); LogWStr(line); LogWLn;
    LogWStr("      ");

    IF pos >= ErrorLineLimitPos THEN pos := ErrorLineLimitPos-1 END;
    i := SHORT(Longint(pos - ErrorLineStartPos));
    WHILE i > 0 DO LogW(" "); DEC(i) END;

    LogVT100(VT100.Green); LogW("^"); LogVT100(VT100.ResetAll);
  END ShowLine;


  PROCEDURE Mark*(n: INTEGER; pos: LONGINT);
  BEGIN
    IF pos = -1 THEN pos := 0 END;
    IF n >= 0 THEN
      noerr := FALSE;
      IF (pos < lasterrpos) OR (lasterrpos + 9 < pos) THEN lasterrpos := pos; ShowLine(pos); LogWLn; LogWStr("  ");
        IF n < 249 THEN LogWStr("  pos"); LogWNum(pos, 6); LogErrMsg(n)
        ELSIF n = 255 THEN LogWStr("pos"); LogWNum(pos, 6); LogWStr("  pc "); LogWNum(breakpc, 1)
        ELSIF n = 254 THEN LogWStr("pc not found")
        ELSE LogWStr(objname);
          IF    n = 253 THEN LogWStr(" is new, compile with option e")
          ELSIF n = 252 THEN LogWStr(" is redefined, compile with option s")
          ELSIF n = 251 THEN LogWStr(" is redefined (private part only), compile with option s")
          ELSIF n = 250 THEN LogWStr(" is no longer visible, compile with option s")
          ELSIF n = 249 THEN LogWStr(" is not consistently imported, recompile imports")
          END
        END
      END
    ELSE
      IF pos >= 0 THEN ShowLine(pos); LogWLn; LogWStr("  pos"); LogWNum(pos, 6) END ;
      LogErrMsg(n);
      IF pos < 0 THEN LogWLn END
    END
  END Mark;


  PROCEDURE err*(n: INTEGER);
  BEGIN Mark(n, errpos)
  END err;


  (* ------------------------ Fingerprint hashing ----------------------- *)

  PROCEDURE FingerprintBytes(VAR fp: LONGINT; VAR bytes: ARRAY OF SYSTEM.BYTE);
  VAR i: INTEGER; l: LONGINT;
  BEGIN
    ASSERT(LEN(bytes) MOD SIZE(LONGINT) = 0);
    i := 0; WHILE i < LEN(bytes) DO
      SYSTEM.GET(SYSTEM.ADR(bytes[i]), l);
      fp := SYSTEM.ROT(SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, fp) / SYSTEM.VAL(SET, l)), 1);
      INC(i, SIZE(LONGINT))
    END
  END FingerprintBytes;

  PROCEDURE FPrint*     (VAR fp: LONGINT; val: HUGEINT);      BEGIN FingerprintBytes(fp, val) END FPrint;
  PROCEDURE FPrintSet*  (VAR fp: LONGINT; val: SYSTEM.SET64); BEGIN FingerprintBytes(fp, val) END FPrintSet;
  PROCEDURE FPrintReal* (VAR fp: LONGINT; val: REAL);         BEGIN FingerprintBytes(fp, val) END FPrintReal;
  PROCEDURE FPrintLReal*(VAR fp: LONGINT; val: LONGREAL);     BEGIN FingerprintBytes(fp, val) END FPrintLReal;




  (* ------------------------- Read Symbol File ------------------------- *)

  PROCEDURE SymRCh*(VAR ch: CHAR);
  BEGIN Files.Read(oldSF, ch)
  END SymRCh;

  (* todo - combine RInt64 and RInt *)
  PROCEDURE SymRInt*(): LONGINT;
    VAR k: LONGINT;
  BEGIN Files.ReadNum(oldSF, k); RETURN k
  END SymRInt;

  PROCEDURE SymRInt64*(): SYSTEM.INT64;
    VAR k: SYSTEM.INT64;
  BEGIN Files.ReadNum(oldSF, k); RETURN k
  END SymRInt64;

  PROCEDURE SymRSet*(VAR s: SYSTEM.SET64);
  BEGIN Files.ReadNum(oldSF, s)
  END SymRSet;

  PROCEDURE SymRReal*(VAR r: REAL);
  BEGIN Files.ReadReal(oldSF, r)
  END SymRReal;

  PROCEDURE SymRLReal*(VAR lr: LONGREAL);
  BEGIN Files.ReadLReal(oldSF, lr)
  END SymRLReal;

  PROCEDURE CloseOldSym*;
  BEGIN Files.Close(Files.Base(oldSF))
  END CloseOldSym;

  PROCEDURE OldSym*(VAR modName: ARRAY OF CHAR; VAR done: BOOLEAN);
    VAR tag, ver: CHAR; fileName: FileName; res: INTEGER;
  BEGIN
    oldSFile := NIL; done := FALSE;
    MakeFileName(modName, fileName, SFext);
    oldSFile := Files.Old(fileName); done := oldSFile # NIL;
    IF done THEN
      Files.Set(oldSF, oldSFile, 0); Files.Read(oldSF, tag); Files.Read(oldSF, ver);
      IF (tag # SFtag) OR (ver # SFver) THEN
        (* Possibly a symbol file from another Oberon implementation, e.g. HP-Oberon,
           or from a symbol incompatible version of this Oberon. *)
        IF ~(newsf IN Options) THEN err(-306) END;
        CloseOldSym; done := FALSE
      END
    END
  END OldSym;

  PROCEDURE eofSF*(): BOOLEAN;
  BEGIN RETURN oldSF.eof
  END eofSF;




  (* ------------------------- Write Symbol File ------------------------- *)

  PROCEDURE SymWCh*(ch: CHAR);
  BEGIN Files.Write(newSF, ch)
  END SymWCh;

  PROCEDURE SymWInt*(i: SYSTEM.INT64);
  BEGIN Files.WriteNum(newSF, i)
  END SymWInt;

  PROCEDURE SymWSet*(s: SYSTEM.SET64);
  BEGIN Files.WriteNum(newSF, SYSTEM.VAL(SYSTEM.INT64, s))
  END SymWSet;

  PROCEDURE SymWReal*(r: REAL);
  BEGIN Files.WriteReal(newSF, r)
  END SymWReal;

  PROCEDURE SymWLReal*(lr: LONGREAL);
  BEGIN Files.WriteLReal(newSF, lr)
  END SymWLReal;

  PROCEDURE RegisterNewSym*;
  BEGIN
    IF (modName # "SYSTEM") OR (mainprog IN Options) THEN Files.Register(newSFile) END
  END RegisterNewSym;

  PROCEDURE DeleteSym*(VAR modulename: ARRAY OF CHAR);
  VAR fn: FileName; res: INTEGER;
  BEGIN MakeFileName(modulename, fn, SFext); Files.Delete(fn, res)
  END DeleteSym;

  PROCEDURE DeleteObj*(VAR modulename: ARRAY OF CHAR);
  VAR fn: FileName; res: INTEGER;
  BEGIN MakeFileName(modulename, fn, Configuration.objext); Files.Delete(fn, res)
  END DeleteObj;

  PROCEDURE NewSym*(VAR modName: ARRAY OF CHAR);
    VAR fileName: FileName;
  BEGIN MakeFileName(modName, fileName, SFext);
    newSFile := Files.New(fileName);
    IF newSFile # NIL THEN Files.Set(newSF, newSFile, 0);
      Files.Write(newSF, SFtag); Files.Write(newSF, SFver)
    ELSE err(153)
    END
  END NewSym;




  (* ------------------------- Write Header & Body Files ------------------------- *)

  PROCEDURE Write*(ch: CHAR);
  BEGIN Files.Write(R[currFile], ch)
  END Write;

  PROCEDURE WriteString*(s: ARRAY [1] OF CHAR);
    VAR i: INTEGER;
  BEGIN i := 0;
    WHILE s[i] # 0X DO INC(i) END ;
    Files.WriteBytes(R[currFile], s, i)
  END WriteString;

  PROCEDURE WriteStringVar*(VAR s: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN i := 0;
    WHILE s[i] # 0X DO INC(i) END ;
    Files.WriteBytes(R[currFile], s, i)
  END WriteStringVar;

  PROCEDURE WriteHex* (i: SYSTEM.INT64);
    VAR s: ARRAY 3 OF CHAR;
      digit : SYSTEM.INT32;
  BEGIN
    digit := SHORT(i) DIV 16;
    IF digit < 10 THEN s[0] := CHR (ORD ("0") + digit); ELSE s[0] := CHR (ORD ("a") - 10 + digit ); END;
    digit := SHORT(i) MOD 16;
    IF digit < 10 THEN s[1] := CHR (ORD ("0") + digit); ELSE s[1] := CHR (ORD ("a") - 10 + digit ); END;
    s[2] := 0X;
    WriteString(s)
  END WriteHex;

  PROCEDURE WriteInt* (i: SYSTEM.INT64);
    VAR s: ARRAY 26 OF CHAR; i1, k: SYSTEM.INT64;
  BEGIN
    IF (i = SignedMinimum(2)) OR (i = SignedMinimum(4)) OR (i = SignedMinimum(8)) THEN
      (* abs(minint) is one more than maxint, causing problems representing the value as a minus sign
         followed by absoute value. Therefore represent as -maxint - 1. For INTEGER this avoids a
         compiler warning 'this decimal constant is unsigned only in ISO C90', for LONGINT it is the
         only way to represent MinLInt. *)
      Write("("); WriteInt(i+1); WriteString("-1)")
    ELSE i1 := ABS(i);
      IF i1 <= MAX(SYSTEM.INT32) THEN k := 0 ELSE s := "LL"; k := 2 END;
      s[k] := CHR(i1 MOD 10 + ORD("0")); i1 := i1 DIV 10; INC(k);
      WHILE i1 > 0 DO s[k] := CHR(i1 MOD 10 + ORD("0")); i1 := i1 DIV 10; INC(k) END ;
      IF i < 0 THEN s[k] := "-"; INC(k) END ;
      WHILE k > 0 DO  DEC(k); Write(s[k]) END;
    END;
  END WriteInt;

  PROCEDURE WriteReal* (r: LONGREAL; suffx: CHAR);
    VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; s: ARRAY 32 OF CHAR; ch: CHAR; i: INTEGER;
  BEGIN
(*should be improved *)
    IF (r < SignedMaximum(LongintSize)) & (r > SignedMinimum(LongintSize)) & (r = ENTIER(r)) THEN
      IF suffx = "f" THEN WriteString("(REAL)") ELSE WriteString("(LONGREAL)") END ;
      WriteInt(ENTIER(r))
    ELSE
      Texts.OpenWriter(W);
      IF suffx = "f" THEN Texts.WriteLongReal(W, r, 16) ELSE Texts.WriteLongReal(W, r, 23) END ;
      NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
      Texts.OpenReader(R, T, 0); i := 0; Texts.Read(R, ch);
      WHILE ch # 0X DO s[i] := ch; INC(i); Texts.Read(R, ch) END ;
  (* s[i] := suffx; s[i+1] := 0X;
  suffix does not work in K&R *)
      s[i] := 0X;
      i := 0; ch := s[0];
      WHILE (ch # "D") & (ch # 0X) DO INC(i); ch := s[i] END ;
      IF ch = "D" THEN s[i] := "e" END ;
      WriteString(s)
    END
  END WriteReal;

  PROCEDURE WriteLn* ();
  BEGIN Files.Write(R[currFile], 0AX)
  END WriteLn;

  PROCEDURE Append(VAR R: Files.Rider; F: Files.File);
    VAR R1: Files.Rider; buffer: ARRAY 4096 OF CHAR;
  BEGIN
    IF F # NIL THEN
      Files.Set(R1, F, 0); Files.ReadBytes(R1, buffer, LEN(buffer));
      WHILE LEN(buffer) - R1.res > 0 DO
        Files.WriteBytes(R, buffer, LEN(buffer) - R1.res);
        Files.ReadBytes(R1, buffer, LEN(buffer))
      END
    END
  END Append;

  PROCEDURE OpenFiles*(VAR moduleName: ARRAY OF CHAR);
    VAR FName: FileName;
  BEGIN
    COPY(moduleName, modName);
    HFile := Files.New("");
    IF HFile # NIL THEN Files.Set(R[HeaderFile], HFile, 0) ELSE err(153) END ;
    MakeFileName(moduleName, FName, BFext);
    BFile := Files.New(FName);
    IF BFile # NIL THEN Files.Set(R[BodyFile], BFile, 0) ELSE err(153) END ;
    MakeFileName(moduleName, FName, HFext);
    HIFile := Files.New(FName);
    IF HIFile # NIL THEN Files.Set(R[HeaderInclude], HIFile, 0) ELSE err(153) END ;
  END OpenFiles;

  PROCEDURE CloseFiles*;
    VAR FName: FileName; res: INTEGER;
  BEGIN
    IF noerr THEN LogWStr("  "); LogWNum(Files.Pos(R[BodyFile]), 0); LogWStr(" chars.") END;
    IF noerr THEN
      IF modName = "SYSTEM" THEN
        IF ~(mainprog IN Options) THEN Files.Register(BFile) END
      ELSIF ~(mainprog IN Options) THEN
        Append(R[HeaderInclude], HFile);
        Files.Register(HIFile); Files.Register(BFile)
      ELSE
        MakeFileName(modName, FName, HFext); Files.Delete(FName, res);
        MakeFileName(modName, FName, SFext); Files.Delete(FName, res);
        Files.Register(BFile)
      END
    END ;
    HFile := NIL; BFile := NIL; HIFile := NIL; newSFile := NIL; oldSFile := NIL;
    Files.Set(R[0], NIL, 0); Files.Set(R[1], NIL, 0); Files.Set(R[2], NIL, 0); Files.Set(newSF, NIL, 0); Files.Set(oldSF, NIL, 0)
  END CloseFiles;


(* === Installation directory discovery === *)

  PROCEDURE IsProbablyInstallDir(s: ARRAY OF CHAR): BOOLEAN;
  VAR testpath: ARRAY 4096 OF CHAR; identity: Platform.FileIdentity;
  BEGIN
    COPY(InstallDir, testpath);
    Strings.Append("/lib/lib", testpath);
    Strings.Append(Configuration.name, testpath);
    Strings.Append("-O2.a", testpath);
    IF Platform.IdentifyByName(testpath, identity) # 0 THEN RETURN FALSE END;

    COPY(InstallDir, testpath);
    Strings.Append("/2/include/Oberon.h", testpath);
    IF Platform.IdentifyByName(testpath, identity) # 0 THEN RETURN FALSE END;

    COPY(InstallDir, testpath);
    Strings.Append("/2/sym/Files.sym", testpath);
    IF Platform.IdentifyByName(testpath, identity) # 0 THEN RETURN FALSE END;

    RETURN TRUE;
  END IsProbablyInstallDir;

  PROCEDURE FindInstallDir;
  VAR i: INTEGER;
  BEGIN
    (* First try location of binary (with <name>.d appended) *)
    COPY(Modules.BinaryDir, InstallDir);
    Strings.Append("/", InstallDir);
    Strings.Append(Configuration.name, InstallDir);
    Strings.Append(".d", InstallDir);
    IF IsProbablyInstallDir(InstallDir) THEN RETURN END;

    (* Now test whether binary is in bin directory under install dir. *)
    COPY(Modules.BinaryDir, InstallDir);
    i := Strings.Length(InstallDir);
    WHILE (i > 0) & (InstallDir[i-1] # '/') DO DEC(i) END;
    IF (i > 0) & (InstallDir[i-1] = '/') THEN
      InstallDir[i-1] := 0X;
      IF IsProbablyInstallDir(InstallDir) THEN RETURN END
    END;

    (* Give up! Use install directory from configuration. *)
    COPY(Configuration.installdir, InstallDir)
  END FindInstallDir;



BEGIN
  MaxReal := 3.40282346D38;                      (* REAL is 4 bytes *)
  MaxLReal := 1.7976931348623157D307 * 9.999999; (* LONGREAL is 8 bytes, should be 1.7976931348623157D308 *)
  MinReal  := -MaxReal;
  MinLReal := -MaxLReal;
  FindInstallDir;
END OPM.
