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
  $Id: Services.om,v 1.2 2004/09/03 09:34:24 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Services.om,v $
  Revision 1.2  2004/09/03 09:34:24  borchert
  cache results of LoadService to avoid further attempts

  Revision 1.1  1995/03/03  09:32:15  borchert
  Initial revision

  ----------------------------------------------------------------------------
*)

MODULE ulmServices;

  IMPORT Disciplines := ulmDisciplines, Objects := ulmObjects, Types := ulmTypes;

  TYPE
    Type* = POINTER TO TypeRec;
    ServiceList = POINTER TO ServiceListRec;
    Service* = POINTER TO ServiceRec;
    Object* = POINTER TO ObjectRec;
    ObjectRec* =
      RECORD
        (Disciplines.ObjectRec)
        type: Type;
        installed: ServiceList;  (* set of installed services *)
      END;

    InstallProc = PROCEDURE (object: Object; service: Service);

    ServiceRec* =
      RECORD
        (Disciplines.ObjectRec)
        name: ARRAY 64 OF CHAR;
        next: Service;
      END;

    ServiceListRec =
      RECORD
        service: Service;
        type: Type;
        install: InstallProc;
        next: ServiceList;
      END;

  VAR
    services: Service;
      (* list of services -- needed to support Seek *)

  TYPE
    LoadModuleProc* = PROCEDURE (module: ARRAY OF CHAR) : BOOLEAN;
    LoadServiceProc* = PROCEDURE (service, for: ARRAY OF CHAR) : BOOLEAN;
    LoaderInterface* = POINTER TO LoaderInterfaceRec;
    LoaderInterfaceRec* =
      RECORD
        loadModule*: LoadModuleProc;
        loadService*: LoadServiceProc;
      END;
  VAR
    loaderIF: LoaderInterface;

  (* ==== name tables ================================================== *)

  CONST
    bufsize = 512; (* length of a name buffer in bytes *)
    tabsize = 1171;
  TYPE
    BufferPosition = Types.Int32;
    Length = Types.Int32;
    HashValue = Types.Int32;
    Buffer = ARRAY bufsize OF CHAR;
    NameList = POINTER TO NameListRec;
    NameListRec =
      RECORD
        buffer: Buffer;
        next: NameList;
      END;
  VAR
    currentBuf: NameList; currentPos: BufferPosition;
  TYPE
    TypeRec* =
      RECORD
        (Disciplines.ObjectRec)
        baseType: Type;
        services: ServiceList;
        cachedservices: ServiceList; (* of base types *)
        (* table management *)
        hashval: HashValue;
        length: Length;
        begin: NameList;
        pos: BufferPosition;
        next: Type; (* next type with same hash value *)
      END;
    BucketTable = ARRAY tabsize OF Type;
  VAR
    bucket: BucketTable;

  (* ==== name table management ======================================== *)

  PROCEDURE Hash(name: ARRAY OF CHAR; length: Types.Int32) : HashValue;
    CONST
      shift = 4;
    VAR
      index: Types.Int32;
      val: Types.Int32;
      ch: CHAR;
      ordval: Types.Int32;
  BEGIN
    index := 0; val := length;
    WHILE index < length DO
      ch := name[index];
      IF ch >= " " THEN
        ordval := ORD(ch) - ORD(" ");
      ELSE
        ordval := ORD(MAX(CHAR)) - ORD(" ") + ORD(ch);
      END;
      val := ASH(val, shift) + ordval;
      INC(index);
    END;
    val := val MOD tabsize;
    RETURN SHORT(val)
  END Hash;

  PROCEDURE CreateBuf(VAR buf: NameList);
  BEGIN
    NEW(buf); buf.next := NIL;
    IF currentBuf # NIL THEN
      currentBuf.next := buf;
    END;
    currentBuf := buf;
    currentPos := 0;
  END CreateBuf;

  PROCEDURE StringLength(string: ARRAY OF CHAR) : Types.Int32;
    VAR
      index: Types.Int32;
  BEGIN
    index := 0;
    WHILE (index < LEN(string)) & (string[index] # 0X) DO
      INC(index);
    END;
    RETURN index
  END StringLength;

  PROCEDURE InitName(name: Type; string: ARRAY OF CHAR);
    VAR
      index, length: Types.Int32;
      firstbuf, buf: NameList;
      startpos: BufferPosition;
  BEGIN
    IF currentBuf = NIL THEN
      CreateBuf(buf);
    ELSE
      buf := currentBuf;
    END;

    firstbuf := buf; startpos := currentPos;
    index := 0;
    WHILE (index < LEN(string)) & (string[index] # 0X) DO
      IF currentPos = bufsize THEN
        CreateBuf(buf);
      END;
      buf.buffer[currentPos] := string[index]; INC(currentPos);
      INC(index);
    END;
    length := index;

    name.hashval := Hash(string, length);
    name.length := length;
    name.begin := firstbuf;
    name.pos := startpos;
    name.next := bucket[name.hashval];
    bucket[name.hashval] := name;
  END InitName;

  PROCEDURE EqualName(name: Type; string: ARRAY OF CHAR) : BOOLEAN;
    (* precondition: both have the same length *)
    VAR
      index: Types.Int32;
      buf: NameList;
      pos: Types.Int32;
  BEGIN
    buf := name.begin; pos := name.pos;
    index := 0;
    WHILE index < name.length DO
      IF pos = bufsize THEN
        buf := buf.next; pos := 0;
      END;
      IF string[index] # buf.buffer[pos] THEN
        RETURN FALSE
      END;
      INC(pos);
      INC(index);
    END;
    RETURN TRUE
  END EqualName;

  PROCEDURE SeekName(string: ARRAY OF CHAR; VAR name: Type) : BOOLEAN;
    VAR
      length: Types.Int32;
      hashval: HashValue;
      p: Type;
  BEGIN
    length := StringLength(string);
    hashval := Hash(string, length);
    p := bucket[hashval];
    WHILE (p # NIL) & ((length # p.length) OR ~EqualName(p, string)) DO
      p := p.next;
    END;
    name := p;
    RETURN p # NIL
  END SeekName;

  PROCEDURE ExtractName(name: Type; VAR string: ARRAY OF CHAR);
    VAR
      index: Types.Int32;
      buf: NameList;
      pos: Types.Int32;
  BEGIN
    buf := name.begin; pos := name.pos;
    index := 0;
    WHILE (index + 1 < LEN(string)) & (index < name.length) DO
      IF pos = bufsize THEN
        buf := buf.next; pos := 0;
      END;
      string[index] := buf.buffer[pos];
      INC(pos);
      INC(index);
    END;
    string[index] := 0X;
  END ExtractName;

  PROCEDURE LoadModule(module: ARRAY OF CHAR) : BOOLEAN;
  BEGIN
    IF (loaderIF # NIL) & (loaderIF.loadModule # NIL) THEN
      RETURN loaderIF.loadModule(module)
    ELSE
      RETURN FALSE
    END;
  END LoadModule;

  PROCEDURE LoadService(service, for: ARRAY OF CHAR) : BOOLEAN;
  BEGIN
    IF (loaderIF # NIL) & (loaderIF.loadService # NIL) THEN
      RETURN loaderIF.loadService(service, for)
    ELSE
      RETURN FALSE
    END;
  END LoadService;

  PROCEDURE MemberOf(list: ServiceList; service: Service;
               VAR member: ServiceList) : BOOLEAN;
    VAR
      p: ServiceList;
  BEGIN
    p := list;
    WHILE (p # NIL) & (p.service # service) DO
      p := p.next;
    END;
    member := p;
    RETURN p # NIL
  END MemberOf;

  PROCEDURE SeekService(type: Type; service: Service;
                 VAR member: ServiceList;
                 VAR baseType: Type) : BOOLEAN;

    VAR
      btype: Type;
      cachedservice: ServiceList;

    PROCEDURE Seek(type: Type; service: Service;
              VAR member: ServiceList) : BOOLEAN;
      VAR
        typeName: ARRAY 512 OF CHAR;
    BEGIN
      IF MemberOf(type.services, service, member) OR
          MemberOf(type.cachedservices, service, member) THEN
        RETURN TRUE
      END;
      ExtractName(type, typeName);
      RETURN LoadService(service.name, typeName) &
           MemberOf(type.services, service, member)
    END Seek;

  BEGIN (* SeekService *)
    btype := type;
    WHILE (btype # NIL) & ~Seek(btype, service, member) DO
      btype := btype.baseType;
    END;
    IF (member # NIL) & (btype # type) THEN
      (* cache result to avoid further tries to load
        a more fitting variant dynamically
      *)
      NEW(cachedservice);
      cachedservice.service := service;
      cachedservice.type := member.type;
      cachedservice.install := member.install;
      cachedservice.next := type.cachedservices;
      type.cachedservices := cachedservice;
      baseType := member.type;
      RETURN TRUE
    END;
    IF member = NIL THEN
      RETURN FALSE
    ELSE
      baseType := member.type;
      RETURN TRUE
    END;
  END SeekService;

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

  (* ==== exported procedures ========================================== *)

  PROCEDURE InitLoader*(if: LoaderInterface);
  BEGIN
    ASSERT((loaderIF = NIL) & (if # NIL));
    loaderIF := if;
  END InitLoader;

  PROCEDURE InitType*(type: Type; name, baseName: ARRAY OF CHAR);
    VAR
      baseType: Type;
      otherType: Type;
      ok: BOOLEAN;
  BEGIN
    IF baseName = "" THEN
      baseType := NIL;
    ELSE
      ok := SeekName(baseName, baseType); ASSERT(ok);
    END;
    ASSERT(~SeekName(name, otherType));
    InitName(type, name);
    type.baseType := baseType;
    type.services := NIL;
    type.cachedservices := NIL;
  END InitType;

  PROCEDURE CreateType*(VAR type: Type; name, baseName: ARRAY OF CHAR);
  BEGIN
    NEW(type); InitType(type, name, baseName);
  END CreateType;

  PROCEDURE Init*(object: Object; type: Type);
  BEGIN
    ASSERT(type # NIL);
    ASSERT(object.type = NIL);
    object.type := type;
    object.installed := NIL;
  END Init;

  PROCEDURE GetType*(object: Object; VAR type: Type);
  BEGIN
    type := object.type;
  END GetType;

  PROCEDURE GetTypeName*(type: Type; VAR name: ARRAY OF CHAR);
  BEGIN
    ExtractName(type, name);
  END GetTypeName;

  PROCEDURE GetBaseType*(type: Type; VAR baseType: Type);
  BEGIN
    baseType := type.baseType;
  END GetBaseType;

  PROCEDURE IsExtensionOf*(type, baseType: Type) : BOOLEAN;
  BEGIN
    ASSERT(baseType # NIL);
    WHILE (type # NIL) & (type # baseType) DO
      type := type.baseType;
    END;
    RETURN type = baseType
  END IsExtensionOf;

  PROCEDURE SeekType*(name: ARRAY OF CHAR; VAR type: Type);
    VAR
      module: ARRAY 64 OF CHAR;
  BEGIN
    IF ~SeekName(name, type) THEN
      (* try to load the associated module *)
      GetModule(name, module);
      IF ~LoadModule(module) OR ~SeekName(name, type) THEN
        type := NIL;
      END;
    END;
  END SeekType;

  PROCEDURE Seek*(name: ARRAY OF CHAR; VAR service: Service);
  BEGIN
    service := services;
    WHILE (service # NIL) & (service.name # name) DO
      service := service.next;
    END;

    (* try to load a module named after `name', if not successful *)
    IF (service = NIL) & LoadModule(name) THEN
      service := services;
      WHILE (service # NIL) & (service.name # name) DO
        service := service.next;
      END;
    END;
  END Seek;

  PROCEDURE Create*(VAR service: Service; name: ARRAY OF CHAR);

    PROCEDURE Created(name: ARRAY OF CHAR) : BOOLEAN;
      VAR
        service: Service;
    BEGIN
      service := services;
      WHILE (service # NIL) & (service.name # name) DO
        service := service.next;
      END;
      RETURN service # NIL
    END Created;

  BEGIN
    ASSERT(~Created(name));
    NEW(service);
    COPY(name, service.name);
    service.next := services; services := service;
  END Create;

  PROCEDURE Define*(type: Type; service: Service; install: InstallProc);
    VAR
      member: ServiceList;
  BEGIN
    ASSERT(service # NIL);
    (* protect against multiple definitions: *)
    ASSERT(~MemberOf(type.services, service, member));

    NEW(member); member.service := service;
    member.install := install; member.type := type;
    member.next := type.services; type.services := member;
  END Define;

  PROCEDURE Install*(object: Object; service: Service) : BOOLEAN;
    VAR
      member, installed: ServiceList;
      baseType: Type;
  BEGIN
    IF object.type = NIL THEN RETURN FALSE END;
    IF ~SeekService(object.type, service, member, baseType) THEN
      (* service not supported for this object type *)
      RETURN FALSE
    END;
    IF ~MemberOf(object.installed, service, installed) THEN
      (* install services only once *)
      IF member.install # NIL THEN
        member.install(object, service);
      END;
      NEW(installed);
      installed.service := service;
      installed.next := object.installed;
      object.installed := installed;
    END;
    RETURN TRUE
  END Install;

  PROCEDURE Supported*(object: Object; service: Service) : BOOLEAN;
    VAR
      member: ServiceList;
      baseType: Type;
  BEGIN
    RETURN (object.type # NIL) &
         SeekService(object.type, service, member, baseType)
  END Supported;

  PROCEDURE Installed*(object: Object; service: Service) : BOOLEAN;
    VAR
      member: ServiceList;
  BEGIN
    RETURN MemberOf(object.installed, service, member)
  END Installed;

  PROCEDURE GetSupportedBaseType*(object: Object; service: Service;
                       VAR baseType: Type);
    VAR
      member: ServiceList;
  BEGIN
    IF ~SeekService(object.type, service, member, baseType) THEN
      baseType := NIL;
    END;
  END GetSupportedBaseType;

BEGIN
  currentBuf := NIL; currentPos := 0; loaderIF := NIL;
END ulmServices.
