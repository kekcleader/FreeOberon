(* Ulm's Oberon Library
  Copyright (C) 1989-1994 by University of Ulm, SAI, D-89069 Ulm, Germany
  ----------------------------------------------------------------------------
  Ulm's Oberon Library is free software; you can redistribute it
  and/or modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either version
  2 of the License, or (at your option) any later version.

  Ulm's Oberon Library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty
  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  ----------------------------------------------------------------------------
  E-mail contact: oberon@mathematik.uni-ulm.de
  ----------------------------------------------------------------------------
  $Id: PersistentO.om,v 1.8 2004/03/30 13:14:16 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: PersistentO.om,v $
  Revision 1.8  2004/03/30 13:14:16  borchert
  introduced more elaborate error events for cannotReadData

  Revision 1.7  1998/04/09 16:55:48  borchert
  bug fix: ReadTypeInfo failed on hierarchical mode if none of the
        types were known by returning TRUE with type set to NIL

  Revision 1.6  1998/03/24  22:42:28  borchert
  improvements:
  - it is now acceptable that read and write if procedures are given
    but neither create nor createAndRead -- this is fine for
    abstractions that maintain some components
  - Read operates now immediately on the given object to support
    LinearizedStructures -- otherwise it would be nearly impossible
    to reconstruct self-referential data structures;
    note that this is *not supported* by GuardedRead

  Revision 1.5  1995/04/04  12:36:39  borchert
  major redesign of PersistentObjects:
  - new type encoding schemes
  - size if proc removed
  - support for NIL and guards added

  Revision 1.4  1994/07/18  14:19:13  borchert
  bug fix: SizeOf used uninitialized variable (name) and added the
        length of all type names of the hierarchy to the sum

  Revision 1.3  1994/07/05  08:47:26  borchert
  bug fix: modifications due to last bug fix didn't work correctly in
        in all cases
  code cleaned up at several locations

  Revision 1.2  1994/03/25  15:54:09  borchert
  bug fix: the complete type hierarchy together with all abstract types
        was written -- this caused a NIL-procedure to be called in
        case of projections. Now, we write shorter type hierarchies and
        GetCreate checks the create-procedure against NIL

  Revision 1.1  1994/02/22  20:09:21  borchert
  Initial revision

  ----------------------------------------------------------------------------
  DB 7/93
  ----------------------------------------------------------------------------
*)

MODULE ulmPersistentObjects;

  (* handling of persistent objects *)

  IMPORT ASCII := ulmASCII, ConstStrings := ulmConstStrings, Disciplines := ulmDisciplines, Errors := ulmErrors, Events := ulmEvents, Forwarders := ulmForwarders,
    IndirectDisciplines := ulmIndirectDisciplines, Loader := ulmLoader, NetIO := ulmNetIO, Objects := ulmObjects, Priorities := ulmPriorities,
    RelatedEvents := ulmRelatedEvents, Services := ulmServices, StreamDisciplines := ulmStreamDisciplines, Streams := ulmStreams, Strings := ulmStrings, Texts := ulmTexts, SYS := SYSTEM, Types := ulmTypes;

  CONST
    maxNameLen = 128; (* max length of data type names *)
  TYPE
    TypeName = ARRAY maxNameLen OF CHAR; (* for temporary use only *)
    ShortTypeName = ARRAY 32 OF CHAR; (* for error messages only *)

  CONST
    cannotReadData* = 0;
    cannotWriteData* = 1;
    cannotReadType* = 2;
    cannotWriteType* = 3;
    invalidType* = 4;
    unknownType* = 5;
    otherTypeHier* = 6;
    eofReached* = 7;
    cannotSkip* = 8;
    typeGuardFailure* = 9;   (* GuardedRead failed to type guard failure *)
    errorcodes* = 10;        (* number of error codes                      *)

    (* how are types specified:   fullTypeName, typeCode, incrTypeCode
      with or without size info: withSize, withoutSize
      with or without type hier: withHier, withoutHier

      combinations are given as additions,
        e.g.   typeCode + withSize + withHier
    *)
    fullTypeName* = 1; typeCode* = 2; incrTypeCode* = 3;
    withSize* = 4; withoutSize* = 0;
    withHier* = 8; withoutHier* = 0;

    defaultMode = fullTypeName + withSize + withHier;
      (* provide all informations on default *)

    (* forms:
        type spec: codeF | incrF | nameF | incrhierF | hierF
        size spec: sizeF | noSizeF
      add specs, eg. codeF + sizeF
    *)
    codeF = 1; (* just a type code *)
    incrF = 2; (* type name + code given *)
    nameF = 3; (* type name given *)
    incrhierF = 4; (* type hierarchy with codes *)
    hierF = 5; (* type hierarchy without codes *)
    sizeF = 8; (* size information given *)
    noSizeF = 0; (* no size information given *)
    maskF = 8;
    maxF = 13; (* maximal valid form code *)

  TYPE
    Mode* = Types.Int8;
    Form = Types.Int8;

    Object* = POINTER TO ObjectRec;
    Type = POINTER TO TypeRec;

    ReadProc* = PROCEDURE (s: Streams.Stream; o: Object) : BOOLEAN;
    WriteProc* = PROCEDURE (s: Streams.Stream; o: Object) : BOOLEAN;
    CreateProc* = PROCEDURE (VAR o: Object);
    CreateAndReadProc* = PROCEDURE (s: Streams.Stream;
                         create: BOOLEAN;
                         VAR o: Object) : BOOLEAN;

    Interface* = POINTER TO InterfaceRec;
    InterfaceRec* =
      RECORD
        (Objects.ObjectRec)
        create*: CreateProc;         (* create object *)
        read*: ReadProc;            (* read data from stream *)
        write*: WriteProc;          (* write data to stream  *)
        createAndRead*: CreateAndReadProc; (* replaces create & read *)
      END;

    ObjectRec* =
      RECORD
        (Services.ObjectRec)
        (* private data *)
        type: Type;
        projected: BOOLEAN; (* set after Read *)
      END;

  CONST
    ttlen = 16;
  TYPE
    TypeEntry = POINTER TO TypeEntryRec;
    TypeEntryRec =
      RECORD
        code: Types.Int32;
        type: Type;
        next: TypeEntry;
      END;
    TypeTable = ARRAY ttlen OF TypeEntry;
    StreamDiscipline = POINTER TO StreamDisciplineRec;
    StreamDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        mode: Mode; (* type encoding mode for the stream *)
        rtypes, wtypes: TypeTable;
      END;

    InterfaceList = POINTER TO InterfaceListRec;
    InterfaceListRec =
      RECORD
        if: Interface;
        next: InterfaceList; (* points to next extension *)
      END;
    TypeRec =
      RECORD
        (Services.TypeRec)
        baseType: Type;      (* the next non-abstract base type *)
        if: Interface;       (* may be = NIL for abstract types *)
        ifs: InterfaceList;  (* list of interfaces in reverse order *)
        code: Types.Int32;       (* unique number *)
      END;

    (* this list is used for storing the base type list of an object during
      reading this object
    *)
    BaseTypeList = POINTER TO BaseTypeRec;
    BaseTypeRec =
      RECORD
        name: ConstStrings.String; (* name of the base type *)
        next: BaseTypeList;
      END;

    (* each error causes an event; the error number is stored in
      event.errorcode; the associated text can be taken from event.message
    *)
    ErrorCode = Types.Int8;
    Event = POINTER TO EventRec;
    EventRec* =
      RECORD
        (Events.EventRec)
        stream*: Streams.Stream;
        errorcode*: ErrorCode;
      END;
    UnknownTypeEvent = POINTER TO UnknownTypeEventRec;
    UnknownTypeEventRec =
      RECORD
        (EventRec)
        typeName: ARRAY 80 OF CHAR;
      END;
    DecodeFailureEvent = POINTER TO DecodeFailureEventRec;
    DecodeFailureEventRec =
      RECORD
        (EventRec)
        objectType: Services.Type;
      END;
    TypeGuardFailureEvent = POINTER TO TypeGuardFailureEventRec;
    TypeGuardFailureEventRec =
      RECORD
        (EventRec)
        found, expected: Services.Type;
      END;

  VAR
    id: Disciplines.Identifier;
    nextTypeCode: Types.Int32; (* for the generation of unique numbers *)
    potype: Services.Type;

    errormsg*: ARRAY errorcodes OF Events.Message;
      (* readable text for error codes *)
    error*: Events.EventType;
      (* raised on failed stream operations; ignored by default *)

  (* ===== for internal use only ========================================== *)

  PROCEDURE Error(stream: Streams.Stream; code: ErrorCode);
    (* raise an error event with the error code `code' *)
    VAR
      event: Event;
  BEGIN
    stream.count := 0;
    NEW(event);
    event.type := error;
    event.message := errormsg[code];
    event.stream := stream;
    event.errorcode := code;
    RelatedEvents.Raise(stream, event);
  END Error;

  PROCEDURE UnknownType(stream: Streams.Stream; typeName: ARRAY OF CHAR);
    VAR
      event: UnknownTypeEvent;
  BEGIN
    stream.count := 0;
    NEW(event);
    event.type := error;
    event.message := errormsg[unknownType];
    event.stream := stream;
    event.errorcode := unknownType;
    COPY(typeName, event.typeName);
    RelatedEvents.Raise(stream, event);
  END UnknownType;

  PROCEDURE TypeGuardFailure(stream: Streams.Stream;
                    found, expected: Services.Type);
    VAR
      event: TypeGuardFailureEvent;
  BEGIN
    stream.count := 0;
    NEW(event);
    event.type := error;
    event.message := errormsg[typeGuardFailure];
    event.stream := stream;
    event.errorcode := typeGuardFailure;
    event.found := found;
    event.expected := expected;
    RelatedEvents.Raise(stream, event);
  END TypeGuardFailure;

  PROCEDURE WriteEvent(s: Streams.Stream; event: Events.Event);

    VAR
      typename: ARRAY 128 OF CHAR;

    PROCEDURE WriteString(s: Streams.Stream;
                   string: ARRAY OF CHAR) : BOOLEAN;
    BEGIN
      RETURN Streams.WritePart(s, string, 0, Strings.Len(string))
    END WriteString;

    PROCEDURE WriteLn(s: Streams.Stream) : BOOLEAN;
      VAR
        lineterm: StreamDisciplines.LineTerminator;
        width: Types.Int32;
    BEGIN
      StreamDisciplines.GetLineTerm(s, lineterm);
      IF ~WriteString(s, lineterm) THEN RETURN FALSE END;
      StreamDisciplines.GetIndentationWidth(s, width);
      WHILE width > 0 DO
        IF ~Streams.WriteByte(s, " ") THEN RETURN FALSE END;
        DEC(width);
      END;
      RETURN TRUE
    END WriteLn;

    PROCEDURE WriteType(s: Streams.Stream;
                  type: Services.Type) : BOOLEAN;
      VAR
        name: TypeName;
    BEGIN
      Services.GetTypeName(type, name);
      RETURN Streams.WriteByte(s, ASCII.quote) &
           WriteString(s, name) &
           Streams.WriteByte(s, ASCII.quote)
    END WriteType;

  BEGIN
    IF event IS UnknownTypeEvent THEN
      WITH event: UnknownTypeEvent DO
        IF WriteString(s, event.message) &
            WriteString(s, ": ") &
            Streams.WriteByte(s, ASCII.quote) &
            WriteString(s, event.typeName) &
            Streams.WriteByte(s, ASCII.quote) THEN
        END;
      END;
    ELSIF event IS TypeGuardFailureEvent THEN
      WITH event: TypeGuardFailureEvent DO
        IF WriteString(s, event.message) &
            WriteString(s, ":") &
            WriteLn(s) &
            WriteString(s, "expected extension of ") &
            WriteType(s, event.expected) &
            WriteString(s, " but got ") &
            WriteType(s, event.found) THEN
        END;
      END;
    ELSIF event IS DecodeFailureEvent THEN
      WITH event: DecodeFailureEvent DO
        Services.GetTypeName(event.objectType, typename);
        IF WriteString(s, event.message) &
            WriteString(s, ":") &
            WriteLn(s) &
            WriteString(s, "unable to parse object of type ") &
            Streams.WriteByte(s, ASCII.quote) &
            WriteString(s, typename) &
            Streams.WriteByte(s, ASCII.quote) THEN
        END;
      END;
    ELSE
      IF WriteString(s, event.message) THEN END;
    END;
  END WriteEvent;

  PROCEDURE InitErrorHandling;
  BEGIN
    errormsg[cannotReadData] := "cannot read data part of persistent object";
    errormsg[cannotWriteData] := "cannot write data part of persistent object";
    errormsg[cannotReadType] := "cannot read type of persistent object";
    errormsg[cannotWriteType] := "cannot write type of persistent object";
    errormsg[invalidType] := "invalid type form read";
    errormsg[unknownType] := "unknown type information found";
    errormsg[otherTypeHier] := "different & nonconforming type hierarchy found";
    errormsg[eofReached] := "unexpected EOF encountered during reading";
    errormsg[cannotSkip] := "unable to skip unknown data parts";
    errormsg[typeGuardFailure] := "read object is of unexpected type";

    Events.Define(error);
    Events.SetPriority(error, Priorities.liberrors);
    Events.Ignore(error);
    Errors.AssignWriteProcedure(error, WriteEvent);
  END InitErrorHandling;

  (* ==== marshalling procedures ======================================== *)

  (* encoding scheme:

    Object = Form Type Size ObjectInfo .
    Form = Types.Int8;
    Type = Code (* codeF *) |
         Code TypeName (* incrF *) |
         TypeName (* nameF *) |
         Code TypeName { Code TypeName } 0 (* incrhierF *) |
         TypeName { TypeName } 0X (* hierF *) .
    Size = (* noSizeF *) |
         Size (* sizeF *) . (* size of object info in bytes *)
    ObjectInfo = { Byte } .
  *)

  PROCEDURE DecodeForm(form: Form;
                VAR nameGiven, codeGiven, hier, size: BOOLEAN);
    VAR
      typeform: Types.Int8;
      sizeform: Types.Int8;
  BEGIN
    typeform := form MOD maskF; sizeform := form DIV maskF;
    nameGiven := typeform IN {incrF, nameF, hierF, incrhierF};
    codeGiven := typeform IN {codeF, incrF, incrhierF};
    hier := (typeform = incrhierF) OR (typeform = hierF);
    size := (sizeform = sizeF);
  END DecodeForm;

  PROCEDURE GetModule(name: ARRAY OF CHAR; VAR module: ARRAY OF CHAR);
    (* get the name of the module where 'name' was defined *)
    VAR
      index: Types.Int32;
  BEGIN
    index := 0;
    WHILE (name[index] # ".") & (name[index] # 0X) &
        (index < LEN(module)-1) DO
      module[index] := name[index]; INC(index);
    END;
    module[index] := 0X;
  END GetModule;

  PROCEDURE Failure(s: Streams.Stream; code: ErrorCode);
  BEGIN
    IF s.eof THEN
      Error(s, eofReached);
    ELSE
      Error(s, code);
    END;
  END Failure;

  PROCEDURE DecodeFailure(s: Streams.Stream; type: Services.Type);
    VAR
      event: DecodeFailureEvent;
  BEGIN
    IF s.eof THEN
      Error(s, eofReached);
    ELSE
      NEW(event);
      event.type := error;
      event.message := errormsg[cannotReadData];
      event.stream := s;
      event.errorcode := cannotReadData;
      event.objectType := type;
      RelatedEvents.Raise(s, event);
    END;
  END DecodeFailure;

  PROCEDURE GetStreamDisc(s: Streams.Stream; VAR disc: StreamDiscipline);
    VAR d: IndirectDisciplines.Discipline;
  BEGIN
    IF IndirectDisciplines.Seek(s, id, d) THEN
      disc := d(StreamDiscipline)
    ELSE
      NEW(disc); disc.id := id; disc.mode := defaultMode;
      IndirectDisciplines.Add(s, disc);
    END;
  END GetStreamDisc;

  PROCEDURE ReadTypeInfo(s: Streams.Stream; VAR type: Type;
                  VAR projection: BOOLEAN;
                  VAR size: Streams.Count) : BOOLEAN;
    VAR
      form: Form;
      btype: Type;
      nameGiven, codeGiven, hier, sizeGiven: BOOLEAN;
      disc: StreamDiscipline;
      sentinelFound, unknownTypeFound: BOOLEAN;
      lastType: Type;

    PROCEDURE ReadType(s: Streams.Stream; VAR type: Type;
                 VAR sentinelFound, unknownTypeFound: BOOLEAN) : BOOLEAN;
      VAR
        code: Types.Int32;
        entry: TypeEntry;
        typeName: TypeName;
        btype: Type;

      PROCEDURE SeekType(typeName: ARRAY OF CHAR;
                   VAR type: Type) : BOOLEAN;
        VAR
          t: Services.Type;
          module: TypeName;
      BEGIN
        Services.SeekType(typeName, t);
        IF t = NIL THEN
          GetModule(typeName, module);
          IF Loader.Load(module, s) THEN
            (* maybe the type is now registered *)
            Services.SeekType(typeName, t);
          END;
        END;
        IF (t # NIL) & (t IS Type) THEN
          type := t(Type); RETURN TRUE
        END;
        RETURN FALSE
      END SeekType;

    BEGIN (* ReadType *)
      sentinelFound := FALSE; unknownTypeFound := FALSE;
      type := NIL;
      IF codeGiven THEN
        IF ~NetIO.ReadLongInt(s, code) THEN
          Failure(s, cannotReadType); RETURN FALSE
        END;
        IF code = 0 THEN sentinelFound := TRUE; RETURN FALSE END;
        entry := disc.rtypes[code MOD ttlen];
        WHILE (entry # NIL) & (entry.code # code) DO
          entry := entry.next;
        END;
        IF entry # NIL THEN
          type := entry.type;
        END;
        IF (entry = NIL) & ~nameGiven THEN
          Failure(s, unknownType); unknownTypeFound := TRUE; RETURN FALSE
        END;
      END;
      IF nameGiven THEN
        IF ~NetIO.ReadString(s, typeName) THEN
          Failure(s, cannotReadType); RETURN FALSE
        END;
        IF typeName[0] = 0X THEN sentinelFound := TRUE; RETURN FALSE END;
        IF (type = NIL) & ~SeekType(typeName, type) THEN
          UnknownType(s, typeName); unknownTypeFound := TRUE; RETURN FALSE
        END;
      END;
      IF codeGiven & (entry = NIL) THEN
        NEW(entry);
        entry.code := code;
        entry.type := type;
        entry.next := disc.rtypes[code MOD ttlen];
        disc.rtypes[code MOD ttlen] := entry;
      END;
      RETURN TRUE
    END ReadType;

  BEGIN (* ReadTypeInfo *)
    (* read & check form of type info *)
    IF ~NetIO.ReadShortInt(s, form) THEN
      Failure(s, cannotReadType); RETURN FALSE
    END;
    IF (form <= 0) OR (form > maxF) THEN
      Failure(s, invalidType); RETURN FALSE
    END;
    DecodeForm(form, nameGiven, codeGiven, hier, sizeGiven);
    IF codeGiven THEN
      GetStreamDisc(s, disc);
    END;

    (* read first type information *)
    IF ~ReadType(s, type, sentinelFound, unknownTypeFound) & ~hier THEN
      RETURN FALSE
    END;

    (* read type hierarchy, if any *)
    projection := FALSE;
    IF hier THEN
      IF sentinelFound THEN
        Failure(s, invalidType); RETURN FALSE
      END;
      lastType := type;
      LOOP (* until type hierarchy is read *)
        IF ReadType(s, btype, sentinelFound, unknownTypeFound) THEN
          IF (lastType # NIL) & (lastType.baseType # btype) THEN
            Failure(s, otherTypeHier); RETURN FALSE
          END;
          IF type = NIL THEN
            projection := TRUE;
            type := btype;
          END;
          lastType := btype;
        ELSIF sentinelFound THEN
          EXIT
        ELSIF unknownTypeFound THEN
          IF lastType # NIL THEN
            Failure(s, otherTypeHier); RETURN FALSE
          END;
        ELSE
          RETURN FALSE
        END;
      END;
      IF type = NIL THEN
        (* error events already generated by ReadType *)
        RETURN FALSE
      END;
    END;

    (* read size information, if any *)
    IF sizeGiven THEN
      IF ~NetIO.ReadLongInt(s, size) THEN
        Failure(s, cannotReadType); RETURN FALSE
      END;
      IF size < 0 THEN
        Failure(s, invalidType); RETURN FALSE
      END;
    ELSE
      size := -1;
    END;
    RETURN TRUE
  END ReadTypeInfo;

  PROCEDURE ReadData(s: Streams.Stream; VAR object: Object) : BOOLEAN;
    (* use the interface list to read all data in the right order *)
    VAR
      ifList: InterfaceList;
  BEGIN
    ifList := object.type.ifs;
    WHILE ifList # NIL DO
      IF ~ifList.if.read(s, object) THEN
        (* error handling is done by the calling procedure *)
        RETURN FALSE
      END;
      ifList := ifList.next;
    END;
    RETURN (object.type.if.read = NIL) OR object.type.if.read(s, object)
  END ReadData;

  PROCEDURE EncodeForm(s: Streams.Stream; type: Type; VAR form: Form);
    VAR
      mode: Mode;
      disc: IndirectDisciplines.Discipline;
      hier: BOOLEAN;

    PROCEDURE KnownType() : BOOLEAN;
      VAR
        p: TypeEntry;
    BEGIN
      p := disc(StreamDiscipline).wtypes[type.code MOD ttlen];
      WHILE (p # NIL) & (p.type # type) DO
        p := p.next;
      END;
      RETURN p # NIL
    END KnownType;

  BEGIN
    IF ~IndirectDisciplines.Seek(s, id, disc) THEN
      mode := defaultMode; disc := NIL;
    ELSE
      mode := disc(StreamDiscipline).mode;
    END;
    form := 0;
    hier := mode DIV 8 MOD 2 > 0;
    CASE mode MOD 4 OF
    | fullTypeName:   IF hier THEN form := hierF ELSE form := nameF END;
    | typeCode:       form := codeF; ASSERT(~hier);
    | incrTypeCode:   IF KnownType() THEN
                  form := codeF;
                ELSIF hier THEN
                  form := incrhierF;
                ELSE
                  form := incrF;
                END;
    ELSE
    END;
    IF mode DIV 4 MOD 2 > 0 THEN
      INC(form, sizeF);
    ELSE
      INC(form, noSizeF);
    END;
  END EncodeForm;

  PROCEDURE WriteTypeInfo(s: Streams.Stream; type: Type;
                  VAR giveSize: BOOLEAN) : BOOLEAN;
    (* write type information without size *)
    VAR
      form: Form;
      giveName, giveCode, hier: BOOLEAN;
      mode: Mode; incr: BOOLEAN;
      disc: IndirectDisciplines.Discipline;
      btype: Type;

    PROCEDURE WriteType(s: Streams.Stream; type: Type) : BOOLEAN;
      VAR
        typeName: TypeName;
        entry: TypeEntry;
    BEGIN
      IF giveCode THEN
        IF ~NetIO.WriteLongInt(s, type.code) THEN
          Error(s, cannotWriteType); RETURN FALSE
        END;
      END;
      IF giveName THEN
        Services.GetTypeName(type, typeName);
        IF ~NetIO.WriteString(s, typeName) THEN
          Error(s, cannotWriteType); RETURN FALSE
        END;
      END;
      IF incr THEN
        NEW(entry); entry.type := type; entry.code := type.code;
        entry.next := disc(StreamDiscipline).wtypes[type.code MOD ttlen];
        disc(StreamDiscipline).wtypes[type.code MOD ttlen] := entry;
      END;
      RETURN TRUE
    END WriteType;

  BEGIN (* WriteTypeInfo *)
    EncodeForm(s, type, form);
    IF ~NetIO.WriteShortInt(s, form) THEN
      Error(s, cannotWriteType);
    END;
    DecodeForm(form, giveName, giveCode, hier, giveSize);
    IF ~IndirectDisciplines.Seek(s, id, disc) THEN
      mode := defaultMode;
    END;
    incr := giveName & giveCode;

    IF ~WriteType(s, type) THEN RETURN FALSE END;

    IF hier THEN
      btype := type.baseType;
      WHILE btype # NIL DO
        IF ~WriteType(s, btype) THEN RETURN FALSE END;
        btype := btype.baseType;
      END;
      (* write sentinel *)
      IF giveCode THEN
        IF ~NetIO.WriteLongInt(s, 0) THEN
          Error(s, cannotWriteType);
          RETURN FALSE
        END;
      ELSE
        IF ~NetIO.WriteString(s, "") THEN
          Error(s, cannotWriteType);
          RETURN FALSE
        END;
      END;
    END;

    RETURN TRUE
  END WriteTypeInfo;

  PROCEDURE WriteData(s: Streams.Stream; object: Object) : BOOLEAN;
    (* use the interface list to write all data in the right order *)
    VAR
      ifList: InterfaceList;
  BEGIN
    ifList := object.type.ifs;
    WHILE ifList # NIL DO
      IF ~ifList.if.write(s, object) THEN
        (* error handling is done by the calling procedure *)
        RETURN FALSE
      END;
      ifList := ifList.next;
    END;
    RETURN (object.type.if.write = NIL) OR object.type.if.write(s, object)
  END WriteData;

  (* ===== exported procedures ============================================ *)

  PROCEDURE RegisterType*(VAR type: Services.Type;
                  name, baseName: ARRAY OF CHAR;
                  if: Interface);
    VAR
      newtype: Type;
      baseType: Services.Type;
      member: InterfaceList;
      bt: Type;
      ifval: Types.Int32;
  BEGIN
    (* check the parameters *)
    ASSERT(name[0] # 0X);
    IF if # NIL THEN
      ifval := 0;
      IF if.create # NIL THEN INC(ifval, 1) END;
      IF if.read # NIL THEN INC(ifval, 2) END;
      IF if.write # NIL THEN INC(ifval, 4) END;
      IF if.createAndRead # NIL THEN INC(ifval, 8) END;
      (* legal variants:

        if = NIL                                    abstract data type

        create   read   write   createAndRead
         #NIL     NIL     NIL       NIL         1   empty data type
          NIL    #NIL    #NIL       NIL         6   abstract data type
         #NIL    #NIL    #NIL       NIL         7   normal case
          NIL     NIL    #NIL      #NIL        12   special case

        note that the special case must not be given as base type!
      *)
      ASSERT(ifval IN {1, 6, 7, 12});
    END;

    (* create type and determine next non-abstract base type *)
    NEW(newtype);
    newtype.code := nextTypeCode; INC(nextTypeCode);
    newtype.if := if;
    IF baseName = "" THEN
      Services.InitType(newtype, name, "PersistentObjects.Object");
    ELSE
      Services.InitType(newtype, name, baseName);
    END;
    IF baseName = "" THEN
      newtype.baseType := NIL;
    ELSE
      Services.GetBaseType(newtype, baseType);
      ASSERT((baseType # NIL) & (baseType IS Type));
      WHILE (baseType # NIL) & (baseType IS Type) &
          (baseType(Type).if = NIL) DO
        Services.GetBaseType(baseType, baseType);
      END;
      IF (baseType = NIL) OR ~(baseType IS Type) THEN
        newtype.baseType := NIL;
      ELSE
        newtype.baseType := baseType(Type);
        ASSERT(newtype.baseType.if.createAndRead = NIL);
      END;
    END;

    (* build up list of interfaces *)
    newtype.ifs := NIL; bt := newtype.baseType;
    WHILE bt # NIL DO
      NEW(member); member.if := bt.if;
      member.next := newtype.ifs; newtype.ifs := member;
      bt := bt.baseType;
    END;

    type := newtype;
  END RegisterType;

  PROCEDURE Init*(object: Object; type: Services.Type);
  BEGIN
    ASSERT(type IS Type);
    WITH type: Type DO
      ASSERT((type.if.create # NIL) OR (type.if.createAndRead # NIL));
      object.type := type;
      object.projected := FALSE;
      Services.Init(object, type);
    END;
  END Init;

  PROCEDURE SetMode*(s: Streams.Stream; mode: Mode);
    VAR
      disc: StreamDiscipline;
      d:    Disciplines.Discipline;
  BEGIN
    IF Disciplines.Seek(s, id, d) THEN
      disc := d(StreamDiscipline)
    ELSE
      NEW(disc); disc.id := id;
    END;
    disc.mode := mode;
    Disciplines.Add(s, disc);
  END SetMode;

  PROCEDURE GetMode*(s: Streams.Stream; VAR mode: Mode);
    (* return the current mode for the given stream *)
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF Disciplines.Seek(s, id, disc) THEN
      mode := disc(StreamDiscipline).mode;
    ELSE
      mode := defaultMode;
    END;
  END GetMode;

  PROCEDURE IsProjected*(object: Object) : BOOLEAN;
    (* show whether the object was a victim of projection or not *)
  BEGIN
    RETURN object.projected
  END IsProjected;

  PROCEDURE InternalRead(s: Streams.Stream; create: BOOLEAN;
                         VAR object: Object) : BOOLEAN;
    (* read `object' from `s';
      note that we have to operate on `object' directly because
      LinearizedStructures relies on this in case of cyclic
      references
    *)
    VAR
      streamCaps: Streams.CapabilitySet;
      type: Type;
      objectType: Services.Type;
      projection: BOOLEAN; (* necessary due to unknown types? *)
      size: Streams.Count; (* size information, if unknown it equals -1 *)
      skipUnknownParts: BOOLEAN; (* are we able to skip data if necessary? *)

      (* these vars are used for skipping unknown data areas *)
      oldPos, newPos: Streams.Count;
      textbuf: Texts.Text;

  BEGIN (* InternalRead *)
    IF ~ReadTypeInfo(s, type, projection, size) THEN RETURN FALSE END;
    IF ~create & (type.if.createAndRead = NIL) THEN
      (* projection necessary due to target object? *)
      Services.GetType(object, objectType);
      IF ~Services.IsExtensionOf(type, objectType) THEN
        TypeGuardFailure(s, type, objectType); RETURN FALSE
      END;
      projection := projection OR (type # objectType);
    END;
    skipUnknownParts := projection & (size > 0);
    streamCaps := Streams.Capabilities(s);
    IF skipUnknownParts THEN
      IF Streams.tell IN streamCaps THEN
        Streams.GetPos(s, oldPos);
      ELSE
        Texts.Open(SYS.VAL(Streams.Stream, textbuf));
        IF ~Streams.Copy(s, textbuf, size) THEN
          Failure(s, cannotReadData); RETURN FALSE
        END;
        Forwarders.Forward(textbuf, s);
        RelatedEvents.Forward(textbuf, s);
        s := textbuf;
        skipUnknownParts := FALSE;
      END;
    END;

    IF type.if.createAndRead # NIL THEN
      IF ~type.if.createAndRead(s, create, object) THEN
        DecodeFailure(s, type); object := NIL; RETURN FALSE
      END;
    ELSE
      IF create THEN
        type.if.create(object);
      END;
      IF ~ReadData(s, object) THEN
        DecodeFailure(s, type);
        object := NIL;
        RETURN FALSE
      END;
    END;

    (* store information about projection into object *)
    object.projected := projection;

    IF skipUnknownParts THEN
      IF Streams.seek IN streamCaps THEN
        Streams.SetPos(s, oldPos + size);
      ELSE
        Streams.GetPos(s, newPos);
        IF ~Streams.Copy(s, Streams.null, size - newPos + oldPos) THEN
          Failure(s, cannotSkip); RETURN FALSE
        END;
      END;
    ELSIF projection & (size < 0) THEN
      Error(s, cannotSkip); RETURN FALSE
    END;

    s.count := 1; (* show success *)
    RETURN TRUE
  END InternalRead;

  PROCEDURE Read*(s: Streams.Stream; VAR object: Object) : BOOLEAN;
    (* read `object' from `s'; object # NIL on success *)
  BEGIN
    RETURN InternalRead(s, (* create = *) TRUE, object)
  END Read;

  PROCEDURE ReadInto*(s: Streams.Stream; object: Object) : BOOLEAN;
    (* read an object from `s' and assign it to `object';
      this fails if `object' doesn't has the IDENTICAL type
      (thus projections are not supported here)
    *)
  BEGIN
    RETURN InternalRead(s, (* create = *) FALSE, object)
  END ReadInto;

  PROCEDURE GuardedRead*(s: Streams.Stream; guard: Services.Type;
                 VAR object: Object) : BOOLEAN;
    (* read an object from `s' and return it, provided
      the type of the read object is an extension of `guard'
    *)
    VAR
      testObject: Object;
      type: Services.Type;
  BEGIN
    IF ~Read(s, testObject) THEN RETURN FALSE END;
    Services.GetType(testObject, type);
    IF Services.IsExtensionOf(type, guard) THEN
      object := testObject; RETURN TRUE
    ELSE
      TypeGuardFailure(s, type, guard);
      RETURN FALSE
    END;
  END GuardedRead;

  PROCEDURE Write*(s: Streams.Stream; object: Object) : BOOLEAN;
    (* write `obj' to `s' *)
    VAR
      giveSize: BOOLEAN;
      streamCaps: Streams.CapabilitySet;
      patchSize: BOOLEAN;
      sizePos, beginPos, endPos: Streams.Count;
      textbuf, origStream: Streams.Stream;
      mode: Mode;
  BEGIN
    IF ~WriteTypeInfo(s, object.type, giveSize) THEN RETURN FALSE END;
    IF giveSize THEN
      streamCaps := Streams.Capabilities(s);
      patchSize := ({Streams.tell, Streams.seek} - streamCaps = {}) &
               Streams.Tell(s, sizePos);
      IF patchSize THEN
        IF ~NetIO.WriteLongInt(s, 0) THEN
          Error(s, cannotWriteData); RETURN FALSE
        END;
        Streams.GetPos(s, beginPos);
      ELSE
        Texts.Open(textbuf);
        Forwarders.Forward(textbuf, s);
        RelatedEvents.Forward(textbuf, s);
        GetMode(s, mode); SetMode(textbuf, mode);
        origStream := s; s := textbuf;
      END;
    END;

    IF object.type.if.createAndRead # NIL THEN
      IF ~object.type.if.write(s, object) THEN
        Error(s, cannotWriteData); RETURN FALSE
      END;
    ELSE
      IF ~WriteData(s, object) THEN
        Error(s, cannotWriteData); RETURN FALSE
      END;
    END;

    IF giveSize THEN
      IF patchSize THEN
        Streams.GetPos(s, endPos);
        Streams.SetPos(s, sizePos);
        IF ~NetIO.WriteLongInt(s, endPos - beginPos) THEN
          Streams.SetPos(s, endPos);
          Error(s, cannotWriteData);
          RETURN FALSE
        END;
        Streams.SetPos(s, endPos);
      ELSE
        Streams.GetPos(textbuf, endPos);
        Streams.SetPos(textbuf, 0);
        s := origStream;
        IF ~NetIO.WriteLongInt(s, endPos) OR
            ~Streams.Copy(textbuf, s, endPos) THEN
          Error(s, cannotWriteData);
        END;
      END;
    END;
    s.count := 1;
    RETURN TRUE
  END Write;

  PROCEDURE ReadObjectOrNIL*(s: Streams.Stream; VAR object: Object) : BOOLEAN;
    VAR
      nil: BOOLEAN;
  BEGIN
    object := NIL;
    RETURN NetIO.ReadBoolean(s, nil) & (nil OR Read(s, object))
  END ReadObjectOrNIL;

  PROCEDURE GuardedReadObjectOrNIL*(s: Streams.Stream; guard: Services.Type;
                        VAR object: Object) : BOOLEAN;
    (* may be used instead of ReadObjectOrNIL *)
    VAR
      testObject: Object;
      type: Services.Type;
      nil: BOOLEAN;
  BEGIN
    IF ~NetIO.ReadBoolean(s, nil) THEN RETURN FALSE END;
    IF nil THEN
      object := NIL;
      RETURN TRUE
    END;
    IF ~Read(s, testObject) THEN RETURN FALSE END;
    IF testObject = NIL THEN RETURN TRUE END;
    Services.GetType(testObject, type);
    IF Services.IsExtensionOf(type, guard) THEN
      object := testObject; RETURN TRUE
    ELSE
      TypeGuardFailure(s, type, guard);
      RETURN FALSE
    END;
  END GuardedReadObjectOrNIL;

  PROCEDURE WriteObjectOrNIL*(s: Streams.Stream; object: Object) : BOOLEAN;
    VAR
      nil: BOOLEAN;
  BEGIN
    nil := object = NIL;
    RETURN NetIO.WriteBoolean(s, nil) & (nil OR Write(s, object))
  END WriteObjectOrNIL;

BEGIN
  id := Disciplines.Unique();
  nextTypeCode := 1;
  InitErrorHandling;
  Services.CreateType(potype, "PersistentObjects.Object", "");
END ulmPersistentObjects.
