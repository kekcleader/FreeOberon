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
  $Id: Timers.om,v 1.3 2001/04/30 14:58:18 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Timers.om,v $
  Revision 1.3  2001/04/30 14:58:18  borchert
  bug fix: recursion via Clocks.TimerOn was not possible

  Revision 1.2  1994/07/18  14:21:51  borchert
  bug fix: CreateQueue took uninitialized priority variable instead of
        queue.priority

  Revision 1.1  1994/02/22  20:11:37  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 1/92
  ----------------------------------------------------------------------------
*)

MODULE ulmTimers;

  IMPORT Clocks := ulmClocks, Disciplines := ulmDisciplines, Events := ulmEvents, Objects := ulmObjects, Op := ulmOperations, Priorities := ulmPriorities,
    SYS := ulmSYSTEM, RelatedEvents := ulmRelatedEvents, Scales := ulmScales, Times := ulmTimes, Types := ulmTypes;

  TYPE
    Queue = POINTER TO QueueRec;
    Timer* = POINTER TO TimerRec;
    TimerRec* =
      RECORD
        (Objects.ObjectRec)
        valid: BOOLEAN;       (* a valid timer entry? *)
        queue: Queue;         (* timer belongs to this queue *)
        prev, next: Timer;    (* double-linked and sorted list *)
        time: Times.Time;     (* key *)
        event: Events.Event;  (* raise this event at the given time *)
      END;
    QueueRec =
      RECORD
        (Disciplines.ObjectRec)
        clock: Clocks.Clock;           (* queue of this clock *)
        priority: Priorities.Priority; (* priority of the clock *)
        checkQueue: Events.EventType;  (* check queue on this event *)
        head, tail: Timer;             (* sorted list of timers *)
        lock: BOOLEAN;
      END;
  TYPE
    CheckQueueEvent = POINTER TO CheckQueueEventRec;
    CheckQueueEventRec =
      RECORD
        (Events.EventRec)
        queue: Queue;
      END;
  TYPE
    ClockDiscipline = POINTER TO ClockDisciplineRec;
    ClockDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        queue: Queue;
      END;
  VAR
    clockDisciplineId: Disciplines.Identifier;

  CONST
    invalidTimer* = 0; (* timer is no longer valid *)
    queueLocked* = 1; (* the queue is currently locked *)
    badClock* = 2; (* clock is unable to maintain a timer *)
    errorcodes* = 3;
  TYPE
    ErrorEvent* = POINTER TO ErrorEventRec;
    ErrorEventRec* =
      RECORD
        (Events.EventRec)
        errorcode*: Types.Int8;
      END;
  VAR
    errormsg*: ARRAY errorcodes OF Events.Message;
    error*: Events.EventType;

  PROCEDURE InitErrorHandling;
  BEGIN
    errormsg[invalidTimer] := "invalid timer given to Timers.Remove";
    errormsg[queueLocked] := "the queue is currently locked";
    errormsg[badClock] := "clock is unable to maintain a timer";
    Events.Define(error); Events.SetPriority(error, Priorities.liberrors);
  END InitErrorHandling;

  PROCEDURE Error(errors: RelatedEvents.Object; code: Types.Int8);
    VAR
      event: ErrorEvent;
  BEGIN
    NEW(event);
    event.type := error;
    event.message := errormsg[code];
    event.errorcode := code;
    RelatedEvents.Raise(errors, event);
  END Error;

  PROCEDURE CheckQueue(queue: Queue);
    VAR
      currentTime: Times.Time;
      oldTimers: Timer;
      p, prev: Timer;
      checkQueueEvent: CheckQueueEvent;
      nextTimer: Timer;
  BEGIN
    IF queue.head = NIL THEN queue.lock := FALSE; RETURN END;

    Clocks.GetTime(queue.clock, currentTime);

    (* remove old timers from queue *)
    oldTimers := queue.head;
    p := queue.head; prev := NIL;
    WHILE (p # NIL) & (Op.Compare(currentTime, p.time) >= 0) DO
      prev := p; p := p.next;
    END;
    IF p = NIL THEN
      queue.head := NIL; queue.tail := NIL;
    ELSE
      queue.head := p;
      p.prev := NIL;
    END;
    IF prev = NIL THEN
      oldTimers := NIL;
    ELSE
      prev.next := NIL;
    END;

    (* set up next check-queue-event, if necessary *)
    nextTimer := queue.head;
    queue.lock := FALSE;
      (* unlock queue now to allow recursion via Clocks.TimerOn *)
    IF nextTimer # NIL THEN
      NEW(checkQueueEvent);
      checkQueueEvent.type := queue.checkQueue;
      checkQueueEvent.message := "check queue of timer";
      checkQueueEvent.queue := queue;
      Clocks.TimerOn(queue.clock, nextTimer.time, checkQueueEvent);
    ELSE
      Clocks.TimerOff(queue.clock);
    END;

    (* process old timers *)
    p := oldTimers;
    WHILE p # NIL DO
      p.valid := FALSE;
      Events.Raise(p.event);
      p := p.next;
    END;
  END CheckQueue;

  PROCEDURE CatchCheckQueueEvents(event: Events.Event);
  BEGIN
    WITH event: CheckQueueEvent DO
      IF ~SYS.TAS(event.queue.lock) THEN
        CheckQueue(event.queue);
        (* event.queue.lock := FALSE; (* done by CheckQueue *) *)
      END;
    END;
  END CatchCheckQueueEvents;

  PROCEDURE CreateQueue(errors: RelatedEvents.Object;
                 VAR queue: Queue; clock: Clocks.Clock) : BOOLEAN;
    VAR
      clockDiscipline: ClockDiscipline;
  BEGIN
    IF ~(Clocks.timer IN Clocks.Capabilities(clock)) THEN
      Error(errors, badClock); RETURN FALSE
    END;

    NEW(queue);
    queue.clock := clock;
    queue.head := NIL; queue.tail := NIL;
    queue.lock := FALSE;
    Events.Define(queue.checkQueue);
    Events.Handler(queue.checkQueue, CatchCheckQueueEvents);
    Clocks.GetPriority(clock, queue.priority);
    IF queue.priority > Priorities.base THEN
      Events.SetPriority(queue.checkQueue, queue.priority + 1);
    ELSE
      queue.priority := Priorities.default;
    END;

    NEW(clockDiscipline); clockDiscipline.id := clockDisciplineId;
    clockDiscipline.queue := queue;
    Disciplines.Add(clock, clockDiscipline);
    RETURN TRUE
  END CreateQueue;

  PROCEDURE Add*(clock: Clocks.Clock; time: Times.Time; event: Events.Event;
            VAR timer: Timer);
    VAR
      queue: Queue;
      clockDiscipline: Disciplines.Discipline; (* ClockDiscipline *)
      p: Timer;
      absTime: Times.Time;
      op: Op.Operand;
  BEGIN
    IF Disciplines.Seek(clock, clockDisciplineId, clockDiscipline) THEN
      queue := clockDiscipline(ClockDiscipline).queue;
    ELSIF ~CreateQueue(clock, queue, clock) THEN
      RETURN
    END;

    IF SYS.TAS(queue.lock) THEN
      Error(clock, queueLocked); RETURN
    END;
    Events.AssertPriority(queue.priority);

    IF Scales.IsRelative(time) THEN
      (* take relative time to be relative to the current time *)
      Clocks.GetTime(clock, absTime);
      (* Op.Add2(SYSTEM.VAL(Op.Operand, absTime), time); *)
      op := absTime; Op.Add2(op, time); absTime := op(Times.Time);
    ELSE
      (* create a copy of time *)
      op := NIL; Op.Assign(op, time); absTime := op(Times.Time);
    END;
    time := absTime;
    NEW(timer); timer.time := time; timer.event := event;
    timer.queue := queue; timer.valid := TRUE;

    (* look for the insertion point *)
    p := queue.head;
    WHILE (p # NIL) & (Op.Compare(time, p.time) > 0) DO
      p := p.next;
    END;

    (* insert timer in front of p *)
    timer.next := p;
    IF p = NIL THEN
      (* append timer at the end of the queue *)
      timer.prev := queue.tail;
      IF queue.tail = NIL THEN
        queue.head := timer;
      ELSE
        queue.tail.next := timer;
      END;
      queue.tail := timer;
    ELSE
      timer.prev := p.prev;
      timer.next := p;
      IF p = queue.head THEN
        queue.head := timer;
      ELSE
        p.prev.next := timer;
      END;
      p.prev := timer;
    END;

    CheckQueue(queue);
    (* queue.lock := FALSE; (* done by CheckQueue *) *)
    Events.ExitPriority;
  END Add;

  PROCEDURE Remove*(timer: Timer);
    VAR
      queue: Queue;
  BEGIN
    IF timer.valid THEN
      queue := timer.queue;
      IF SYS.TAS(queue.lock) THEN
        Error(queue.clock, queueLocked); RETURN
      END;
      Events.AssertPriority(queue.priority);
      timer.valid := FALSE;
      IF timer.prev = NIL THEN
        queue.head := timer.next;
      ELSE
        timer.prev.next := timer.next;
      END;
      IF timer.next = NIL THEN
        queue.tail := timer.prev;
      ELSE
        timer.next.prev := timer.prev;
      END;
      CheckQueue(queue);
      (* queue.lock := FALSE; (* done by CheckQueue *) *)
      Events.ExitPriority;
    ELSE
      Error(timer.queue.clock, invalidTimer);
    END;
  END Remove;

  PROCEDURE Schedule*(clock: Clocks.Clock;
               time: Times.Time; event: Events.Event);
    VAR
      timer: Timer;
  BEGIN
    Add(clock, time, event, timer);
  END Schedule;

  PROCEDURE NextEvent*(clock: Clocks.Clock; VAR time: Times.Time) : BOOLEAN;
    VAR
      rval: BOOLEAN;
      queue: Queue;
      clockDiscipline: Disciplines.Discipline; (* ClockDiscipline *)
  BEGIN
    IF ~Disciplines.Seek(clock, clockDisciplineId, clockDiscipline) THEN
      RETURN FALSE
    END;
    queue := clockDiscipline(ClockDiscipline).queue;

    IF SYS.TAS(queue.lock) THEN
      Error(clock, queueLocked); RETURN FALSE
    END;
    CheckQueue(queue);
    IF queue.head # NIL THEN
      time := queue.head.time;
      rval := TRUE;
    ELSE
      rval := FALSE
    END;
    (* queue.lock := FALSE; (* done by CheckQueue *) *)
    RETURN rval
  END NextEvent;

BEGIN
  InitErrorHandling;
  clockDisciplineId := Disciplines.Unique();
END ulmTimers.
