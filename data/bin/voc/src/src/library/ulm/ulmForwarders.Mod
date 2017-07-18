(* Ulm's Oberon Library
  Copyright (C) 1989-1995 by University of Ulm, SAI, D-89069 Ulm, Germany
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
  $Id: Forwarders.om,v 1.1 1996/01/04 16:40:57 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Forwarders.om,v $
  Revision 1.1  1996/01/04  16:40:57  borchert
  Initial revision

  ----------------------------------------------------------------------------
*)

MODULE ulmForwarders; (* AFB 3/95 *)

  IMPORT Disciplines := ulmDisciplines, Events := ulmEvents, Resources := ulmResources, Services := ulmServices;

  TYPE
    Object* = Services.Object;
    ForwardProc* = PROCEDURE (from, to: Object);

  TYPE
    ListOfForwarders = POINTER TO ListOfForwardersRec;
    ListOfForwardersRec =
      RECORD
        forward: ForwardProc;
        next: ListOfForwarders;
      END;
    ListOfDependants = POINTER TO ListOfDependantsRec;
    ListOfDependantsRec =
      RECORD
        dependant: Object;
        next: ListOfDependants;
      END;
    TypeDiscipline = POINTER TO TypeDisciplineRec;
    TypeDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        list: ListOfForwarders;
      END;
    ObjectDiscipline = POINTER TO ObjectDisciplineRec;
    ObjectDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        dependants: ListOfDependants;
        forwarders: ListOfForwarders;
        dependsOn: Object;
      END;
  VAR
    genlist: ListOfForwarders; (* list which applies to all types *)
    typeDiscID: Disciplines.Identifier;
    objectDiscID: Disciplines.Identifier;

  (* === private procedures ============================================ *)

  PROCEDURE RemoveDependant(VAR list: ListOfDependants; dependant: Object);
    VAR
      prev, p: ListOfDependants;
  BEGIN
    prev := NIL; p := list;
    WHILE (p # NIL) & (p.dependant # dependant) DO
      prev := p; p := p.next;
    END;
    IF p # NIL THEN
      IF prev = NIL THEN
        list := p.next;
      ELSE
        prev.next := p.next;
      END;
    END;
  END RemoveDependant;

  PROCEDURE TerminationHandler(event: Events.Event);
    (* remove list of dependants in case of termination and
      remove event.resource from the list of dependants of that
      object it depends on
    *)
    VAR
      odisc:     Disciplines.Discipline;
      dependsOn: Object;
  BEGIN
    WITH event: Resources.Event DO
      IF event.change = Resources.terminated THEN
        IF Disciplines.Seek(event.resource, objectDiscID, odisc) THEN
          Disciplines.Remove(event.resource, objectDiscID);
          dependsOn := odisc(ObjectDiscipline).dependsOn;
          IF (dependsOn # NIL) & ~Resources.Terminated(dependsOn) &
              Disciplines.Seek(dependsOn, objectDiscID, odisc) THEN
            RemoveDependant(odisc(ObjectDiscipline).dependants, event.resource(Object));
          END;
        END;
      END;
    END;
  END TerminationHandler;

  PROCEDURE Insert(VAR list: ListOfForwarders; forward: ForwardProc);
    VAR
      member: ListOfForwarders;
  BEGIN
    NEW(member); member.forward := forward;
    member.next := list; list := member;
  END Insert;

  PROCEDURE GetObjectDiscipline(object: Object; VAR odisc: ObjectDiscipline);
    VAR
      disc: Disciplines.Discipline;
      resourceNotification: Events.EventType;
  BEGIN
    IF Disciplines.Seek(object, objectDiscID, disc) THEN
      odisc := disc(ObjectDiscipline)
    ELSE
      NEW(odisc); odisc.id := objectDiscID; odisc.dependants := NIL;
      odisc.forwarders := NIL; odisc.dependsOn := NIL;
      (* let's state our interest in termination of `object' if
        we see this object the first time
      *)
      Resources.TakeInterest(object, resourceNotification);
      Events.Handler(resourceNotification, TerminationHandler);
      Disciplines.Add(object, odisc);
    END;
  END GetObjectDiscipline;

  (* === exported procedures =========================================== *)

  PROCEDURE Register*(for: ARRAY OF CHAR; forward: ForwardProc);
    (* register a forwarder which is to be called for all
      forward operations which affects extensions of `for';
      "" may be given for Services.Object
    *)

    VAR
      type:  Services.Type;
      tdisc: TypeDiscipline;
      disc:  Disciplines.Discipline;

  BEGIN (* Register *)
    IF for = "" THEN
      Insert(genlist, forward);
    ELSE
      Services.SeekType(for, type);
      ASSERT(type # NIL);
      IF Disciplines.Seek(type, typeDiscID, disc) THEN
        tdisc := disc(TypeDiscipline)
      ELSE
        NEW(tdisc); tdisc.id := typeDiscID; tdisc.list := NIL;
      END;
      Insert(tdisc.list, forward);
      Disciplines.Add(type, tdisc);
    END;
  END Register;

  PROCEDURE RegisterObject*(object: Object; forward: ForwardProc);
    (* to be called instead of Register if specific objects
      are supported only and not all extensions of a type
    *)
    VAR
      odisc: ObjectDiscipline;
  BEGIN
    GetObjectDiscipline(object, odisc);
    Insert(odisc.forwarders, forward);
  END RegisterObject;

  PROCEDURE Update*(object: Object; forward: ForwardProc);
    (* is to be called by one of the registered forwarders if
      an interface for object has been newly installed or changed
      in a way which needs forward to be called for each of
      the filter objects which delegate to `object'
    *)
    VAR
      odisc:  ObjectDiscipline;
      disc:   Disciplines.Discipline;
      client: ListOfDependants;
  BEGIN
    IF Disciplines.Seek(object, objectDiscID, disc) THEN
      odisc := disc(ObjectDiscipline);
      client := odisc.dependants;
      WHILE client # NIL DO
        forward(client.dependant, object);
        client := client.next;
      END;
    END;
  END Update;

  PROCEDURE Forward*(from, to: Object);
    (* forward (as far as supported) all operations from `from' to `to' *)
    VAR
      type, otherType, baseType: Services.Type;
      disc:      Disciplines.Discipline;
      tdisc:     TypeDiscipline;
      odisc:     ObjectDiscipline;
      client:    ListOfDependants;
      forwarder: ListOfForwarders;

    PROCEDURE CallForwarders(list: ListOfForwarders);
    BEGIN
      WHILE list # NIL DO
        list.forward(from, to);
        list := list.next;
      END;
    END CallForwarders;

  BEGIN (* Forward *)
    Services.GetType(from, type);
    Services.GetType(to, otherType);
    ASSERT((type # NIL) & (otherType # NIL));

    IF Resources.Terminated(to) OR Resources.Terminated(from) THEN
      (* forwarding operations is no longer useful *)
      RETURN
    END;
    Resources.DependsOn(from, to);

    (* update the list of dependants for `to' *)
    GetObjectDiscipline(to, odisc);
    NEW(client); client.dependant := from;
    client.next := odisc.dependants; odisc.dependants := client;

    (* call object-specific forwarders *)
    CallForwarders(odisc.forwarders);

    LOOP (* go through the list of base types in descending order *)
      IF Disciplines.Seek(type, typeDiscID, disc) & Services.IsExtensionOf(otherType, type) THEN
        tdisc := disc(TypeDiscipline);
        CallForwarders(tdisc.list);
      END;
      Services.GetBaseType(type, baseType);
      IF baseType = NIL THEN EXIT END;
      type := baseType;
    END;
    CallForwarders(genlist);
  END Forward;

BEGIN
  genlist := NIL;
  typeDiscID := Disciplines.Unique();
  objectDiscID := Disciplines.Unique();
END ulmForwarders.
