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
  $Id: RelatedEven.om,v 1.8 2005/04/28 08:30:09 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: RelatedEven.om,v $
  Revision 1.8  2005/04/28 08:30:09  borchert
  added assertion to Forward that takes care that from # to
  (otherwise we get a nasty infinite loop)

  Revision 1.7  2004/09/09 21:04:24  borchert
  undoing change of Revision 1.5:
    fields dependants and dependson must not be subject of
    Save/Restore as this makes it impossible to undo the
    dependencies within the TerminationHandler
  we no longer remove the discipline in case of terminated
  objects as this causes a list of error events to be lost

  Revision 1.6  2004/02/18 17:01:59  borchert
  Raise asserts now that event.type # NIL

  Revision 1.5  2004/02/18 16:53:48  borchert
  fields dependants and dependson moved from discipline to state
  object to support them for Save/Restore

  Revision 1.4  1998/01/12  14:39:18  borchert
  some bug fixes around RelatedEvents.null

  Revision 1.3  1995/03/20  17:05:13  borchert
  - Save & Restore added
  - support for Forwarders & Resources added

  Revision 1.2  1994/08/27  14:49:44  borchert
  null object added

  Revision 1.1  1994/02/22  20:09:53  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 11/91
  ----------------------------------------------------------------------------
*)

MODULE ulmRelatedEvents;

  (* relate events to objects *)

  IMPORT Disciplines := ulmDisciplines, Events := ulmEvents, Forwarders := ulmForwarders, Objects := ulmObjects, Priorities := ulmPriorities, Resources := ulmResources, SYSTEM;

  CONST
    (* possible directions of propagated events *)
    forward = 0;   (* forward along the forwardTo chain, if given *)
    backward = 1;  (* forward event to all dependants, if present *)
    both = 2;      (* forward event to both directions *)
  TYPE
    Direction = SHORTINT; (* forward, backward, both *)

  TYPE
    Object* = Disciplines.Object;
    Event* = POINTER TO EventRec;
    EventRec* =
      RECORD
        (Events.EventRec)
        object*: Object;
        event*: Events.Event;
      END;
    Queue* = POINTER TO QueueRec;
    QueueRec* =
      RECORD
        (Objects.ObjectRec)
        event*: Events.Event;
        next*: Queue;
      END;
    ObjectList = POINTER TO ObjectListRec;
    ObjectListRec =
      RECORD
        object: Object;
        next: ObjectList;
      END;

  TYPE
    State = POINTER TO StateRec;
    StateRec =
      RECORD
        default: BOOLEAN; (* default reaction? *)
        eventType: Events.EventType; (* may be NIL *)
        queue: BOOLEAN; (* are events to be queued? *)
        forwardto: Object;
        head, tail: Queue;
        saved: State;
      END;
    Discipline = POINTER TO DisciplineRec;
    DisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        state: State;
        dependants: ObjectList;
        dependsOn: Object;
      END;
  VAR
    id: Disciplines.Identifier;
  VAR
    null*: Object; (* object which ignores all related events *)
    nullevent: Events.EventType;

  PROCEDURE RemoveDependant(VAR list: ObjectList; dependant: Object);
    VAR
      prev, p: ObjectList;
  BEGIN
    prev := NIL; p := list;
    WHILE (p # NIL) & (p.object # dependant) DO
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

  PROCEDURE Seek(object: Object;  id: Disciplines.Identifier;
                 VAR discipline: Discipline): BOOLEAN;
  VAR
    disc:   Disciplines.Discipline;
    result: BOOLEAN;
  BEGIN
    result := Disciplines.Seek(object, id, disc);
    IF result THEN discipline := disc(Discipline) ELSE discipline := NIL END;
    RETURN result
  END Seek;

  PROCEDURE TerminationHandler(event: Events.Event);
    VAR
      disc: Discipline;
  BEGIN
    WITH event: Resources.Event DO
      IF (event.change = Resources.terminated) & Seek(event.resource, id, disc) THEN
        IF (disc.dependsOn # NIL) & Seek(disc.dependsOn, id, disc) THEN
          RemoveDependant(disc.dependants, event.resource);
          disc.dependsOn := NIL;
        END;
        (*
          afb 9/2004:
          do not remove this discipline for dead objects
          as this makes it impossible to retrieve the final
          list of error events
          Disciplines.Remove(event.resource, id);
        *)
      END;
    END;
  END TerminationHandler;

  PROCEDURE CreateState(VAR state: State);
  BEGIN
    NEW(state);
    state.eventType := NIL;
    state.queue := FALSE; state.head := NIL; state.tail := NIL;
    state.forwardto := NIL;
    state.default := TRUE;
    state.saved := NIL;
  END CreateState;

  PROCEDURE CreateDiscipline(VAR disc: Discipline);
  BEGIN
    NEW(disc); disc.id := id; CreateState(disc.state);
  END CreateDiscipline;

  PROCEDURE GetEventType*(object: Object; VAR eventType: Events.EventType);
    (* returns an event type for the given object;
      all events related to the object are also handled by this event type
    *)
    VAR
      disc: Discipline;
      state: State;
  BEGIN
    IF object = null THEN
      eventType := nullevent;
    ELSE
      IF ~Seek(object, id, disc) THEN
        CreateDiscipline(disc);
        Disciplines.Add(object, disc);
      END;
      state := disc.state;
      state.default := FALSE;
      IF state.eventType = NIL THEN
        Events.Define(state.eventType);
        Events.SetPriority(state.eventType, Priorities.liberrors + 1);
        Events.Ignore(state.eventType);
      END;
      eventType := state.eventType;
    END;
  END GetEventType;

  PROCEDURE Forward*(from, to: Object);
    (* causes all events related to `from' to be forwarded to `to' *)
    VAR
      disc: Discipline;
  BEGIN
    IF (from # NIL) & (from # null) THEN
      ASSERT(from # to);
      IF ~Seek(from, id, disc) THEN
        CreateDiscipline(disc);
        Disciplines.Add(from, disc);
      END;
      IF to = null THEN
        to := NIL;
      END;
      disc.state.forwardto := to;
      disc.state.default := FALSE;
    END;
  END Forward;

  PROCEDURE ForwardToDependants(from, to: Forwarders.Object);
    (* is called by Forwarders.Forward:
      build a backward chain from `to' to `from'
    *)
    VAR
      fromDisc, toDisc: Discipline;
      member: ObjectList;
      eventType: Events.EventType;
  BEGIN
    IF (from = null) OR (to = null) THEN RETURN END;
    IF ~Seek(from, id, fromDisc) THEN
      CreateDiscipline(fromDisc); Disciplines.Add(from, fromDisc);
    END;
    IF fromDisc.dependsOn # NIL THEN RETURN END;
    fromDisc.dependsOn := to;
    Resources.TakeInterest(from, eventType);
    Events.Handler(eventType, TerminationHandler);

    IF ~Seek(to, id, toDisc) THEN
      CreateDiscipline(toDisc); Disciplines.Add(to, toDisc);
    END;
    NEW(member); member.object := from;
    member.next := toDisc.dependants; toDisc.dependants := member;
  END ForwardToDependants;

  PROCEDURE QueueEvents*(object: Object);
    (* put all incoming events into a queue *)
    VAR
      disc: Discipline;
      state: State;
  BEGIN
    IF (object # NIL) & (object # null) THEN
      IF ~Seek(object, id, disc) THEN
        CreateDiscipline(disc);
        Disciplines.Add(object, disc);
      END;
      state := disc.state;
      state.default := FALSE;
      IF ~state.queue THEN
        state.queue := TRUE; state.head := NIL; state.tail := NIL;
      END;
    END;
  END QueueEvents;

  PROCEDURE GetQueue*(object: Object; VAR queue: Queue);
    (* return queue of related events which is removed
      from the object;
      object must have been prepared by QueueEvents
    *)
    VAR
      disc: Discipline;
      state: State;
  BEGIN
    IF (object # NIL) & (object # null) & Seek(object, id, disc) & disc.state.queue THEN
      state := disc.state;
      queue := state.head; state.head := NIL; state.tail := NIL;
    ELSE
      queue := NIL;
    END;
  END GetQueue;

  PROCEDURE EventsPending*(object: Object) : BOOLEAN;
    (* return TRUE if GetQueue will return a queue # NIL *)
    VAR
      disc: Discipline;
  BEGIN
    IF (object # NIL) & (object # null) & Seek(object, id, disc) & disc.state.queue THEN
      RETURN disc.state.head # NIL
    ELSE
      RETURN FALSE
    END;
  END EventsPending;

  PROCEDURE Reset*(object: Object);
    (* return to default behaviour *)
    VAR
      disc: Discipline;
      state: State;
  BEGIN
    IF object # null THEN
      IF Seek(object, id, disc) THEN
        IF (disc.state.saved = NIL) &
            (disc.dependsOn = NIL) &
            (disc.dependants = NIL) THEN
          Disciplines.Remove(object, id);
        ELSE
          state := disc.state;
          state.queue := FALSE; state.head := NIL; state.tail := NIL;
          state.eventType := NIL; state.forwardto := NIL;
          state.default := TRUE;
        END;
      END;
    END;
  END Reset;

  PROCEDURE Save*(object: Object);
    (* save current status of the given object and reset to
      default behaviour;
      the status includes the reaction types and event queues;
      Save operations may be nested
    *)
    VAR
      disc: Discipline;
      state: State;
  BEGIN
    IF object # null THEN
      IF ~Seek(object, id, disc) THEN
        CreateDiscipline(disc);
        Disciplines.Add(object, disc);
      END;
      CreateState(state);
      state.saved := disc.state; disc.state := state;
    END;
  END Save;

  PROCEDURE Restore*(object: Object);
    (* restore status saved earlier by Save *)
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(object, id, disc) & (disc.state.saved # NIL) THEN
      disc.state := disc.state.saved;
    END;
  END Restore;

  PROCEDURE InternalRaise(object: Object; dir: Direction; event: Events.Event);
    VAR
      disc: Discipline;
      state: State;
      relEvent: Event;
      element: Queue;        (* new element of queue *)
      dependant: ObjectList;
  BEGIN
    IF (object = null) OR ~Seek(object, id, disc) THEN RETURN END;

    (* backward chaining *)
    IF (disc.dependants # NIL) & (dir IN {backward, both}) THEN
      dependant := disc.dependants;
      WHILE dependant # NIL DO
        InternalRaise(dependant.object, backward, event);
        dependant := dependant.next;
      END;
    END;

    (* local handling & forward chaining *)
    IF ~disc.state.default THEN
      state := disc.state;
      IF state.queue THEN
        NEW(element); element.next := NIL; element.event := event;
        IF state.tail # NIL THEN
          state.tail.next := element;
        ELSE
          state.head := element;
        END;
        state.tail := element;
      END;
      IF state.eventType # NIL THEN
        NEW(relEvent);
        relEvent.message := event.message;
        relEvent.type := state.eventType;
        relEvent.object := object;
        relEvent.event := event;
        Events.Raise(relEvent);
      END;
      IF (state.forwardto # NIL) & (dir IN {both, forward}) THEN
        InternalRaise(state.forwardto, forward, event);
      END;
    END;
  END InternalRaise;

  PROCEDURE Raise*(object: Object; event: Events.Event);
    VAR
      disc: Discipline;
  BEGIN
    ASSERT(event.type # NIL);
    IF object # null THEN
      IF (object = NIL) OR ~Seek(object, id, disc) THEN
        Events.Raise(event);
      ELSE
        InternalRaise(object, both, event);
      END;
    END;
  END Raise;

  PROCEDURE AppendQueue*(object: Object; queue: Queue);
    (* Raise(object, event) for all events of the queue *)
  BEGIN
    WHILE queue # NIL DO
      Raise(object, queue.event);
      queue := queue.next;
    END;
  END AppendQueue;

BEGIN
  id := Disciplines.Unique();
  NEW(null);
  Events.Define(nullevent);
  Forwarders.Register("", ForwardToDependants);
END ulmRelatedEvents.
