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
   $Id: Assertions.om,v 1.2 1996/01/04 16:50:59 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Assertions.om,v $
   Revision 1.2  1996/01/04  16:50:59  borchert
   some fixes because event types are now an extension of Services.Object

   Revision 1.1  1994/02/22  20:06:01  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 11/91
   ----------------------------------------------------------------------------
*)

MODULE ulmAssertions;

   (* general error handling of library routines *)

   IMPORT Disciplines := ulmDisciplines, Events := ulmEvents, IO := ulmIO, Priorities := ulmPriorities, RelatedEvents := ulmRelatedEvents, Services := ulmServices, Types := ulmTypes;

   TYPE
      Object = Disciplines.Object;
      Identifier* = ARRAY 32 OF CHAR; (* should be sufficient *)
      Event* = POINTER TO EventRec;
      EventRec* =
	 RECORD
	    (Events.EventRec)
	    object*: Object;      (* may be NIL *)
	    module*: Identifier;
	    proc*: Identifier;
	 END;
      EventType = POINTER TO EventTypeRec;
      EventTypeRec* =
	 RECORD
	    (Events.EventTypeRec)
	    (* private components *)
	    module: Identifier;
	 END;

   VAR
      failedAssertion*: Events.EventType;
      eventTypeType: Services.Type;

   PROCEDURE Define*(VAR type: Events.EventType; module: ARRAY OF CHAR);
      (* create a new event type which will be of type Assertions.EventType *)
      VAR
	 newtype: EventType;
   BEGIN
      NEW(newtype);
      Services.Init(newtype, eventTypeType);
      Events.Init(newtype);
      Events.SetPriority(newtype, Priorities.assertions);
      COPY(module, newtype.module);
      type := newtype;
   END Define;

   PROCEDURE Raise*(object: RelatedEvents.Object;
		   type: Events.EventType;
		   proc: ARRAY OF CHAR;
		   text: ARRAY OF CHAR);
      (* raise Assertions.failedAssertion;
	 create a event of the given type and pass it
	 to RelatedEvents.Raise (if object # NIL)
	 or Events.Raise (if object = NIL);
      *)
      VAR
	 event: Event;

      PROCEDURE CreateEvent(VAR event: Event; etype: Events.EventType);
      BEGIN
	 NEW(event);
	 event.type := etype;
	 COPY(text, event.message);
	 event.object := object;
	 IF type IS EventType THEN
	    COPY(type(EventType).module, event.module);
	 ELSE
	    event.module[0] := 0X;
	 END;
	 COPY(proc, event.proc);
      END CreateEvent;

   BEGIN
      IO.WriteString("assertion failed: ");
      IO.WriteString(text); IO.WriteString(" in procedure ");
      IO.WriteString(proc); IO.WriteLn;
      CreateEvent(event, failedAssertion); Events.Raise(event);
      CreateEvent(event, type);
      IF object = NIL THEN
	 Events.Raise(event);
      ELSE
	 RelatedEvents.Raise(object, event);
      END;
   END Raise;

BEGIN
   Events.Define(failedAssertion);
   Events.SetPriority(failedAssertion, Priorities.assertions);
   Events.Ignore(failedAssertion);
   Services.CreateType(eventTypeType,
      "Assertions.EventType", "Events.EventType");
END ulmAssertions.
