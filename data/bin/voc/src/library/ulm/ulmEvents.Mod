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
   $Id: Events.om,v 1.4 2004/03/30 17:48:14 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Events.om,v $
   Revision 1.4  2004/03/30 17:48:14  borchert
   support of external queue handling added

   Revision 1.3  1996/01/04 17:07:20  borchert
   event types are now an extension of Services.Object

   Revision 1.2  1994/07/18  14:17:17  borchert
   unused variables of Raise (oldevent + newevent) removed

   Revision 1.1  1994/02/22  20:07:41  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 8/89
   ----------------------------------------------------------------------------
*)

MODULE ulmEvents;

   IMPORT Objects := ulmObjects, Priorities := ulmPriorities, Services := ulmServices, SYS := ulmSYSTEM, Types := ulmTypes;

   TYPE
      EventType* = POINTER TO EventTypeRec;

   CONST
      (* possibilities on receipt of an event: *)
      default* = 0;             (* causes abortion *)
      ignore* = 1;              (* ignore event *)
      funcs* = 2;               (* call associated event handlers *)

   TYPE
      Reaction* = Types.Int32;      (* one of default, ignore, or funcs *)
      Message* = ARRAY 80 OF CHAR;
      Event* = POINTER TO EventRec;
      EventRec* =
         RECORD
            (Objects.ObjectRec)
            type*: EventType;
            message*: Message;
            (* private part *)
            next: Event;                (* queue *)
         END;
      EventHandler = PROCEDURE (event: Event);

      (* event managers are needed if there is any action necessary
         on changing the kind of reaction
      *)
      EventManager = PROCEDURE (type: EventType; reaction: Reaction);

      Priority = Types.Int32; (* must be non-negative *)

      (* every event with reaction `funcs' has a handler list;
         the list is in calling order which is reverse to
         the order of `Handler'-calls
      *)
      HandlerList = POINTER TO HandlerRec;
      HandlerRec* =
         RECORD
            (Objects.ObjectRec)
            handler*: EventHandler;
            next*: HandlerList;
         END;
      SaveList = POINTER TO SaveRec;
      SaveRec =
         RECORD
            reaction: Reaction;
            handlers: HandlerList;
            next: SaveList;
         END;

      EventTypeRec* =
         RECORD
            (Services.ObjectRec)
            (* private components *)
            handlers: HandlerList;
            priority: Priority;
            reaction: Reaction;
            manager:  EventManager;
            savelist: SaveList;
         END;

      Queue = POINTER TO QueueRec;
      QueueRec =
         RECORD
            priority: Types.Int32;          (* queue for this priority *)
            head, tail: Event;
            next: Queue;                (* queue with lower priority *)
         END;

   VAR
      eventTypeType: Services.Type;

   CONST
      priotabsize = 256;        (* size of a priority table *)
      maxnestlevel = 1024;      (* of Raise-calls (avoids endless recursion) *)

   TYPE
      (* in some cases coroutines uses local priority systems *)
      PrioritySystem* = POINTER TO PrioritySystemRec;
      PrioritySystemRec* =
         RECORD
            (Objects.ObjectRec)
            (* private part *)
            currentPriority: Priority;
            priotab: ARRAY priotabsize OF Priority;
            priotop: Types.Int32;
            overflow: Types.Int32;  (* of priority table *)
         END;

   CONST
      priorityViolation* = 0; (* priority violation (EnterPriority *)
      unbalancedExitPriority* = 1; (* unbalanced call of ExitPriority *)
      unbalancedRestoreReaction* = 2; (* unbalanced call of RestoreReaction *)
      negPriority* = 3; (* negative priority given to SetPriority *)
      errorcodes* = 4;

   TYPE
      ErrorEvent* = POINTER TO ErrorEventRec;
      ErrorEventRec* =
         RECORD
            (EventRec)
            errorcode*: Types.Int8;
         END;

   VAR
      errormsg*: ARRAY errorcodes OF Message;
      error*: EventType;

   VAR
      (* private part *)
      abort, log, queueHandler: EventHandler;
      nestlevel: Types.Int32;       (* of Raise calls *)
      queue: Queue;
      lock: BOOLEAN;            (* lock critical operations *)
      psys: PrioritySystem;     (* current priority system *)

   PROCEDURE ^ Define*(VAR type: EventType);
   PROCEDURE ^ SetPriority*(type: EventType; priority: Priority);
   PROCEDURE ^ Raise*(event: Event);

   PROCEDURE InitErrorHandling;
   BEGIN
      Define(error); SetPriority(error, Priorities.liberrors);
      errormsg[priorityViolation] :=
         "priority violation (Events.EnterPriority)";
      errormsg[unbalancedExitPriority] :=
         "unbalanced call of Events.ExitPriority";
      errormsg[unbalancedRestoreReaction] :=
         "unbalanced call of Events.RestoreReaction";
      errormsg[negPriority] :=
         "negative priority given to Events.SetPriority";
   END InitErrorHandling;

   PROCEDURE Error(code: Types.Int8);
      VAR event: ErrorEvent;
   BEGIN
      NEW(event); event.type := error;
      event.message := errormsg[code];
      event.errorcode := code;
      Raise(event);
   END Error;

   PROCEDURE NilEventManager(type: EventType; reaction: Reaction);
   END NilEventManager;

   PROCEDURE Init*(type: EventType);
      VAR
         stype: Services.Type;
   BEGIN
      Services.GetType(type, stype); ASSERT(stype # NIL);
      type.handlers := NIL;
      type.priority := Priorities.default;
      type.reaction := default;
      type.manager := NilEventManager;
      type.savelist := NIL;
   END Init;

   PROCEDURE Define*(VAR type: EventType);
      (* definition of a new event;
         an unique event number is returned;
         the reaction on receipt of `type' is defined to be `default'
      *)
   BEGIN
      NEW(type);
      Services.Init(type, eventTypeType);
      Init(type);
   END Define;

   PROCEDURE GetReaction*(type: EventType) : Reaction;
      (* returns either `default', `ignore', or `funcs' *)
   BEGIN
      RETURN type.reaction
   END GetReaction;

   PROCEDURE SetPriority*(type: EventType; priority: Priority);
      (* (re-)defines the priority of an event *)
   BEGIN
      IF priority <= 0 THEN
         Error(negPriority);
      ELSE
         type.priority := priority;
      END;
   END SetPriority;

   PROCEDURE GetEventPriority*(type: EventType) : Priority;
      (* return the priority of the given event *)
   BEGIN
      RETURN type.priority
   END GetEventPriority;

   PROCEDURE Manager*(type: EventType; manager: EventManager);
   BEGIN
      type.manager := manager;
   END Manager;

   PROCEDURE Handler*(type: EventType; handler: EventHandler);
      (* add `handler' to the list of handlers for event `type' *)
      VAR
         newhandler: HandlerList;
   BEGIN
      NEW(newhandler);
      newhandler.handler := handler; newhandler.next := type.handlers;
      type.handlers := newhandler;
      IF type.reaction # funcs THEN
         type.reaction := funcs; type.manager(type, funcs);
      END;
   END Handler;

   PROCEDURE RemoveHandlers*(type: EventType);
      (* remove list of handlers for event `type';
         implies default reaction (abortion) on
         receipt of `type'
      *)
   BEGIN
      type.handlers := NIL;
      IF type.reaction # default THEN
         type.reaction := default; type.manager(type, default);
      END;
   END RemoveHandlers;

   PROCEDURE Ignore*(type: EventType);
      (* implies RemoveHandlers(type) and causes receipt
         of `type' to be ignored
      *)
   BEGIN
      type.handlers := NIL;
      IF type.reaction # ignore THEN
         type.reaction := ignore; type.manager(type, ignore);
      END;
   END Ignore;

   PROCEDURE GetHandlers*(type: EventType; handlers: HandlerList);
      (* returns the list of handlers in `handlers';
         the reaction of `type' must be `funcs'
      *)
   BEGIN
      handlers := type.handlers;
   END GetHandlers;

   PROCEDURE Log*(loghandler: EventHandler);
      (* call `loghandler' for every event;
         subsequent calls of `Log' replace the loghandler;
         the loghandler is not called on default and ignore
      *)
   BEGIN
      log := loghandler;
   END Log;

   PROCEDURE GetLog*(VAR loghandler: EventHandler);
      (* returns the loghandler set by `Log' *)
   BEGIN
      loghandler := log;
   END GetLog;

   PROCEDURE NilHandler*(event: Event);
      (* an empty event handler *)
   END NilHandler;

(* now QueueHandler will translate partly like
        BOOLEAN b;
        handler_EventHandler tmphandler;
        Types.Int32 i, j;
        i = (Types.Int32)handler;
        tmphandler = handler_NilHandler;
        j = (Types.Int32)tmphandler;
        b = i != j;
*)
(* changed because voc cannot compara handler and NilHandler -- noch *)

   PROCEDURE QueueHandler*(handler: EventHandler);
      (* setup an alternative handler of events
         that cannot be processed now because
         of their unsufficient priority
      *)
      VAR b : BOOLEAN; (* noch *)
      tmphandler : EventHandler;
      (*i,j : Types.Int32;*)
   BEGIN
      (*i := SYSTEM.VAL(Types.Int32, handler);*)
      tmphandler := NilHandler;
      (*b := tmphandler = handler;*)
      (*j := SYSTEM.VAL(Types.Int32, tmphandler);
      b := i # j;*)
      b := handler # tmphandler;
      (*ASSERT (handler # NilHandler);*)
      ASSERT(b);
      queueHandler := handler;
   END QueueHandler;

   PROCEDURE AbortHandler*(handler: EventHandler);
      (* defines the handler to be called on abortion *)
   BEGIN
      abort := handler;
   END AbortHandler;

   PROCEDURE GetAbortHandler*(VAR handler: EventHandler);
      (* returns the handler set by `AbortHandler' *)
   BEGIN
      handler := abort;
   END GetAbortHandler;

   PROCEDURE ^ CallHandlers(event: Event);

   PROCEDURE WorkupQueue;
      VAR
         ptr: Event;
   BEGIN
      WHILE (queue # NIL) & (queue.priority > psys.currentPriority) DO
         IF SYS.TAS(lock) THEN RETURN END;
         ptr := queue.head; queue := queue.next;
         lock := FALSE;
         WHILE ptr # NIL DO
            CallHandlers(ptr);
            ptr := ptr.next;
         END;
      END;
   END WorkupQueue;

   PROCEDURE CallHandlers(event: Event);
      VAR
         ptr: HandlerList;
         oldPriority: Priority;
   BEGIN
      CASE event.type.reaction OF
      | default:  abort(event);
      | ignore:
      | funcs:    oldPriority := psys.currentPriority;
                  psys.currentPriority := event.type.priority;
                  log(event);
                  ptr := event.type.handlers;
                  WHILE ptr # NIL DO
                     ptr.handler(event);
                     ptr := ptr.next;
                  END;
                  psys.currentPriority := oldPriority;
      ELSE (* Explicitly ignore unhandled even type reactions *)
      END;
   END CallHandlers;

   PROCEDURE Raise*(event: Event);
      (* call all event handlers (in reverse order)
            associated with event.type;
         abort if there are none;
         some system events may abort in another way
            (i.e. they do not cause the abortion handler to be called)
      *)
      VAR
         priority: Priority;

      PROCEDURE AddToQueue(event: Event);
         VAR
            prev, ptr: Queue;
      BEGIN
         event.next := NIL;
         ptr := queue; prev := NIL;
         WHILE (ptr # NIL) & (ptr.priority > priority) DO
            prev := ptr;
            ptr := ptr.next;
         END;
         IF (ptr # NIL) & (ptr.priority = priority) THEN
            ptr.tail.next := event;
            ptr.tail := event;
         ELSE
            NEW(ptr);
            ptr.priority := priority;
            ptr.head := event; ptr.tail := event;
            IF prev = NIL THEN
               ptr.next := queue;
               queue := ptr;
            ELSE
               ptr.next := prev.next;
               prev.next := ptr;
            END;
         END;
      END AddToQueue;

   BEGIN (* Raise *)
      INC(nestlevel);
      IF nestlevel >= maxnestlevel THEN
         abort(event);
      ELSE
         IF event.type.reaction # ignore THEN
            priority := event.type.priority;
            IF psys.currentPriority < priority THEN
               CallHandlers(event); WorkupQueue;
            ELSIF queueHandler # NIL THEN
               queueHandler(event);
            ELSIF ~SYS.TAS(lock) THEN
               AddToQueue(event);
               lock := FALSE;
            END;
         END;
      END;
      DEC(nestlevel);
   END Raise;

   PROCEDURE CreatePrioritySystem*(VAR prioritySystem: PrioritySystem);
      (* create and initialize a new priority system *)
   BEGIN
      NEW(prioritySystem);
      prioritySystem.currentPriority := Priorities.base;
      prioritySystem.priotop := 0;
   END CreatePrioritySystem;

   PROCEDURE CurrentPrioritySystem*() : PrioritySystem;
      (* return the priority system currently active *)
   BEGIN
      RETURN psys
   END CurrentPrioritySystem;

   PROCEDURE SwitchPrioritySystem*(prioritySystem: PrioritySystem);
      (* switch to another priority system; this is typically
         done in case of task switches
      *)
   BEGIN
      psys := prioritySystem;
   END SwitchPrioritySystem;

   PROCEDURE EnterPriority*(priority: Priority);
      (* sets the current priority to `priority';
         it is an error to give a priority less than
         the current priority (event `badpriority')
      *)
   BEGIN
      IF psys.currentPriority <= priority THEN
         IF (psys.overflow = 0) & (psys.priotop < priotabsize) THEN
            psys.priotab[psys.priotop] := psys.currentPriority;
            INC(psys.priotop);
            psys.currentPriority := priority;
         ELSE
            INC(psys.overflow);
         END;
      ELSE
         Error(priorityViolation);
         INC(psys.overflow);
      END;
   END EnterPriority;

   PROCEDURE AssertPriority*(priority: Priority);
      (* current priority
             <  priority:  set the current priority to `priority'
             >= priority:  the current priority remains unchanged
      *)
   BEGIN
      IF (psys.overflow = 0) & (psys.priotop < priotabsize) THEN
         psys.priotab[psys.priotop] := psys.currentPriority; INC(psys.priotop);
         IF psys.currentPriority < priority THEN
            psys.currentPriority := priority;
         END;
      ELSE
         INC(psys.overflow);
      END;
   END AssertPriority;

   PROCEDURE ExitPriority*;
      (* causes the priority before the last effective call
         of SetPriority or AssertPriority to be restored
      *)
   BEGIN
      IF psys.overflow > 0 THEN
         DEC(psys.overflow);
      ELSIF psys.priotop = 0 THEN
         Error(unbalancedExitPriority);
      ELSE
         DEC(psys.priotop); psys.currentPriority := psys.priotab[psys.priotop];
         WorkupQueue;
      END;
   END ExitPriority;

   PROCEDURE GetPriority*() : Priority;
      (* returns the current priority *)
   BEGIN
      RETURN psys.currentPriority
   END GetPriority;

   PROCEDURE SaveReaction*(type: EventType);
      (* saves current reaction until call of RestoreReaction;
         the new reaction of `type' is defined to be `ignore'
         but can be changed by Events.Handler or Events.RemoveHandlers
      *)
      VAR
         savelist: SaveList;
   BEGIN
      NEW(savelist);
      savelist.reaction := type.reaction;
      savelist.handlers := type.handlers;
      savelist.next := type.savelist;
      type.savelist := savelist;
      type.handlers := NIL;
      IF type.reaction # ignore THEN
         type.reaction := ignore; type.manager(type, ignore);
      END;
   END SaveReaction;

   PROCEDURE RestoreReaction*(type: EventType);
      (* restores old reaction;
         must be properly nested
      *)
      VAR
         savelist: SaveList;
   BEGIN
      IF type.savelist = NIL THEN
         Error(unbalancedRestoreReaction);
      ELSE
         savelist := type.savelist;
         type.savelist := savelist.next;
         type.handlers := savelist.handlers;
         IF type.reaction # savelist.reaction THEN
            type.reaction := savelist.reaction;
            type.manager(type, savelist.reaction);
         END;
      END;
   END RestoreReaction;

BEGIN
   CreatePrioritySystem(psys);

   Services.CreateType(eventTypeType, "Events.EventType", "");

   abort := NilHandler; log := NilHandler; queueHandler := NIL;
   nestlevel := 0;
   queue := NIL;
   lock := FALSE;

   InitErrorHandling;
END ulmEvents.
