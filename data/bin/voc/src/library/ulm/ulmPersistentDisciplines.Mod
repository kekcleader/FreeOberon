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
  $Id: PersistentD.om,v 1.4 1998/02/22 10:25:22 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: PersistentD.om,v $
  Revision 1.4  1998/02/22  10:25:22  borchert
  bug fix in GetObject: Disciplines.Add was missing if the main object
  is just an extension of Disciplines.Object and not of
  PersistentDisciplines.Object

  Revision 1.3  1996/07/24  07:41:28  borchert
  bug fix: count component was not initialized (with the
        exception of CreateObject) -- detected by Martin Hasch

  Revision 1.2  1995/03/17  16:13:33  borchert
  - persistent disciplines may now be attached to non-persistent objects
  - some fixes due to changes of PersistentObjects

  Revision 1.1  1994/02/22  20:09:12  borchert
  Initial revision

  ----------------------------------------------------------------------------
*)

MODULE ulmPersistentDisciplines;

  IMPORT Disciplines := ulmDisciplines, Forwarders := ulmForwarders, NetIO := ulmNetIO, Objects := ulmObjects, PersistentObjects := ulmPersistentObjects,
    Services := ulmServices, Streams := ulmStreams;

  CONST
    objectName = "PersistentDisciplines.Object";
    disciplineName = "PersistentDisciplines.Discipline";

  TYPE
    Identifier* = LONGINT;

    Discipline* = POINTER TO DisciplineRec;
    DisciplineRec* =
      RECORD
        (PersistentObjects.ObjectRec)
        id*: Identifier; (* should be unique for all types of disciplines *)
      END;

    DisciplineList = POINTER TO DisciplineListRec;
    DisciplineListRec =
      RECORD
        discipline: Discipline;
        id: Identifier; (* copied from discipline.id *)
        next: DisciplineList;
      END;

    Interface = POINTER TO InterfaceRec;
    Object = POINTER TO ObjectRec;
    ObjectRec* =
      RECORD
        (PersistentObjects.ObjectRec)
        (* private part *)
        count: LONGINT; (* number of attached disciplines *)
        list: DisciplineList; (* set of disciplines *)
        if: Interface; (* overrides builtins if # NIL *)
        forwardTo: Object;
        usedBy: Object; (* used as target of UseInterfaceOf *)
          (* very restrictive way of avoiding reference cycles:
            forwardTo references must be built from inner to
            outer objects and not vice versa
          *)
      END;

  TYPE
    VolatileDiscipline = POINTER TO VolatileDisciplineRec;
    VolatileDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        object: Object;
      END;
  VAR
    volDiscID: Disciplines.Identifier;

  TYPE
    AddProc* = PROCEDURE (object: Disciplines.Object; discipline: Discipline);
    RemoveProc* = PROCEDURE (object: Disciplines.Object; id: Identifier);
    SeekProc* = PROCEDURE (object: Disciplines.Object; id: Identifier;
                   VAR discipline: Discipline) : BOOLEAN;
    InterfaceRec* =
      RECORD
        (Objects.ObjectRec)
        add*: AddProc;
        remove*: RemoveProc;
        seek*: SeekProc;
      END;

  VAR
    unique: Identifier;
    objIf: PersistentObjects.Interface;
    objDatatype, discDatatype: Services.Type;

  CONST
    hashtabsize = 32;
  TYPE
    Sample = POINTER TO SampleRec;
    SampleRec =
      RECORD
        id: Identifier;
        sample: Discipline;
        next: Sample;
      END;
    BucketTable = ARRAY hashtabsize OF Sample;
  VAR
    samples: BucketTable;

  PROCEDURE CreateObject*(VAR object: Object);
    (* creates a new object; this procedures should be called instead of
      NEW for objects of type `Object'
    *)
  BEGIN
    NEW(object);
    object.count := 0; (* up to now, there are no attached disciplines *)
    object.list := NIL;
    object.if := NIL;
    PersistentObjects.Init(object, objDatatype);
  END CreateObject;

  PROCEDURE GetObject(obj: Disciplines.Object; VAR object: Object);
    VAR
      disc:  Disciplines.Discipline;
      vdisc: VolatileDiscipline;
  BEGIN
    IF obj IS Object THEN
      object := obj(Object);
      (* initialize private components now if not done already;
        we assume here that pointers which have not been
        initialized yet are defined to be NIL
        (because of the garbage collection);
        a similar assumption does not necessarily hold for
        other types (e.g. integers)
      *)
      IF object.list = NIL THEN
        object.count := 0;
      END;
    ELSIF Disciplines.Seek(obj, volDiscID, disc) THEN
      object := disc(VolatileDiscipline).object;
    ELSE
      CreateObject(object);
      NEW(vdisc); vdisc.id := volDiscID; vdisc.object := object;
      Disciplines.Add(obj, vdisc);
    END;
  END GetObject;

  (* === normal stuff for disciplines ===================================== *)

  PROCEDURE Unique*(sample: Discipline) : Identifier;
    (* returns a unique identifier;
      this procedure should be called during initialization by
      all modules defining a discipline type;
      a sample of the associated discipline has to be provided
    *)
    VAR
      hashval: Identifier;
      entry: Sample;
  BEGIN
    INC(unique);
    NEW(entry); entry.id := unique; entry.sample := sample;
    hashval := unique MOD hashtabsize;
    entry.next := samples[hashval]; samples[hashval] := entry;
    RETURN unique
  END Unique;

  PROCEDURE GetSample*(id: Identifier) : Discipline;
    (* return sample for the given identifier;
      NIL will be returned if id has not yet been returned by Unique
    *)
    VAR
      hashval: Identifier;
      ptr: Sample;
  BEGIN
    hashval := id MOD hashtabsize;
    ptr := samples[hashval];
    WHILE (ptr # NIL) & (ptr.id # id) DO
      ptr := ptr.next;
    END;
    IF ptr # NIL THEN
      RETURN ptr.sample
    ELSE
      RETURN NIL
    END;
  END GetSample;

  PROCEDURE AttachInterface*(object: Disciplines.Object; if: Interface);
    (* override the builtin implementations of Add, Remove and
      Seek for `object' with the implementations given by `if'
    *)
    VAR
      po: Object;
  BEGIN
    GetObject(object, po);
    IF (po.list = NIL) & (po.forwardTo = NIL) THEN
      po.if := if;
    END;
  END AttachInterface;

  PROCEDURE UseInterfaceOf*(object, host: Disciplines.Object);
    (* forward Add, Remove and Seek operations from object to host *)
    VAR
      po, phost: Object;
  BEGIN
    GetObject(object, po); GetObject(host, phost);
    IF (po.list = NIL) & (po.forwardTo = NIL) &
        (po.usedBy = NIL) THEN
      po.forwardTo := phost;
      phost.usedBy := po; (* avoid reference cycles *)
    END;
  END UseInterfaceOf;

  PROCEDURE Forward(from, to: Forwarders.Object);
  BEGIN
    UseInterfaceOf(from, to);
  END Forward;

  PROCEDURE Remove*(object: Disciplines.Object; id: Identifier);
    (* remove the discipline with the given id from object, if it exists *)
    VAR
      po: Object;
      prev, dl: DisciplineList;
  BEGIN
    GetObject(object, po);
    WHILE po.forwardTo # NIL DO
      po := po.forwardTo;
    END;
    IF po.if = NIL THEN
      prev := NIL;
      dl := po.list;
      WHILE (dl # NIL) & (dl.id # id) DO
        prev := dl; dl := dl.next;
      END;
      IF dl # NIL THEN
        IF prev = NIL THEN
          po.list := dl.next;
        ELSE
          prev.next := dl.next;
        END;
        DEC(po.count); (* discipline removed *)
      END;
    ELSE
      po.if.remove(po, id);
    END;
  END Remove;

  PROCEDURE Add*(object: Disciplines.Object; discipline: Discipline);
    (* adds a new discipline to the given object;
      if already a discipline with the same identifier exist
      it is deleted first
    *)
    VAR
      po: Object;
      dl: DisciplineList;
  BEGIN
    GetObject(object, po);
    WHILE po.forwardTo # NIL DO
      po := po.forwardTo;
    END;
    IF po.if = NIL THEN
      dl := po.list;
      WHILE (dl # NIL) & (dl.id # discipline.id) DO
        dl := dl.next;
      END;
      IF dl = NIL THEN
        NEW(dl);
        dl.id := discipline.id;
        dl.next := po.list;
        po.list := dl;
        INC(po.count); (* discipline added *)
      END;
      dl.discipline := discipline;
    ELSE
      po.if.add(po, discipline);
    END;
  END Add;

  PROCEDURE Seek*(object: Disciplines.Object; id: Identifier;
            VAR discipline: Discipline) : BOOLEAN;
    (* returns TRUE if a discipline with the given id is found *)
    VAR
      po: Object;
      dl: DisciplineList;
  BEGIN
    GetObject(object, po);
    WHILE po.forwardTo # NIL DO
      po := po.forwardTo;
    END;
    IF po.if = NIL THEN
      dl := po.list;
      WHILE (dl # NIL) & (dl.id # id) DO
        dl := dl.next;
      END;
      IF dl # NIL THEN
        discipline := dl.discipline;
      ELSE
        discipline := NIL;
      END;
      RETURN discipline # NIL
    ELSE
      RETURN po.if.seek(po, id, discipline)
    END;
  END Seek;

  (* === interface procedures for PersistentObjects for Object === *)

  PROCEDURE ReadObjectData(stream: Streams.Stream;
                   object: PersistentObjects.Object) : BOOLEAN;
    (* read data and attached disciplines of given object from stream *)
    VAR
      discipline: PersistentObjects.Object; (* Discipline *)
      count: LONGINT;
  BEGIN
    (* get number of attached disciplines *)
    IF ~NetIO.ReadLongInt(stream, count) THEN
      RETURN FALSE;
    END;
    (* read all disciplines from `stream' and attach them to `object' *)
    WHILE count > 0 DO
      IF ~PersistentObjects.Read(stream, discipline) THEN
        RETURN FALSE;
      END;
      Add(object(Object), discipline(Discipline));
      DEC(count);
    END;
    RETURN TRUE;
  END ReadObjectData;

  PROCEDURE WriteObjectData(stream: Streams.Stream;
                    object: PersistentObjects.Object) : BOOLEAN;
    (* write data and attached disciplines of given object to stream *)
    VAR
      dl: DisciplineList;
  BEGIN
    WITH object: Object DO
      (* write number of attached disciplines to `stream' *)
      IF ~NetIO.WriteLongInt(stream, object.count) THEN
        RETURN FALSE;
      END;
      (* write all attached disciplines to the stream *)
      dl := object.list;
      WHILE dl # NIL DO
        IF ~PersistentObjects.Write(stream, dl.discipline) THEN
          RETURN FALSE;
        END;
        dl := dl.next;
      END;
    END;
    RETURN TRUE;
  END WriteObjectData;

  PROCEDURE InternalCreate(VAR obj: PersistentObjects.Object);
    VAR
      myObject: Object;
  BEGIN
    CreateObject(myObject);
    obj := myObject;
  END InternalCreate;

BEGIN
  unique := 0;

  NEW(objIf);
  objIf.read := ReadObjectData;
  objIf.write := WriteObjectData;
  objIf.create := InternalCreate;
  objIf.createAndRead := NIL;
  PersistentObjects.RegisterType(objDatatype, objectName, "", objIf);
  PersistentObjects.RegisterType(discDatatype, disciplineName, "", NIL);

  volDiscID := Disciplines.Unique();

  Forwarders.Register("", Forward);
END ulmPersistentDisciplines.
