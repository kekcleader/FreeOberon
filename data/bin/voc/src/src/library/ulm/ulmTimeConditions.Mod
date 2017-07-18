(* Ulm's Oberon Library
  Copyright (C) 1989-2004 by University of Ulm, SAI, D-89069 Ulm, Germany
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
  $Id: TimeConditi.om,v 1.5 2004/04/05 16:23:37 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: TimeConditi.om,v $
  Revision 1.5  2004/04/05 16:23:37  borchert
  bug fix: Test must not call anything which causes directly or
        indirectly WaitFor to be called; hence we schedule
        a timer event in all cases where this is possible;
        the only exception remains Clocks.system where we
        take it for granted that the clock operations are
        that simple that they do not lead to WaitFor
        (was necessary to get RemoteClocks working again)

  Revision 1.4  2004/02/19 15:23:10  borchert
  - Init added to support extensions of TimeConditions.Condition
  - using Clocks.Passed instead of Clocks.GetTime in some instances
    to reduce the number of system calls needed
  - Timers event is only generated now if strictly needed,
    i.e. if SendEvent has been called

  Revision 1.3  2001/04/30 15:25:12  borchert
  several improvements / bug fixes in context of domain-oriented
  condition handling

  Revision 1.2  1995/04/06  14:36:16  borchert
  fixes due to changed if & semantics of Conditions

  Revision 1.1  1994/02/22  20:11:18  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 1/92
  ----------------------------------------------------------------------------
*)

MODULE ulmTimeConditions;

  IMPORT
    Clocks  := ulmClocks,  Conditions    := ulmConditions,    Disciplines := ulmDisciplines,
    Events  := ulmEvents,  Op            := ulmOperations,    Priorities  := ulmPriorities,
    Process := ulmProcess, RelatedEvents := ulmRelatedEvents, Scales      := ulmScales,
    Timers  := ulmTimers,  Times         := ulmTimes;

  TYPE
    Domain = POINTER TO DomainRec;
    DomainRec =
      RECORD
        (Conditions.DomainRec)
        clock: Clocks.Clock;
        alarm: Events.EventType;
        event: Events.Event; (* event of SendEvent *)
      END;
    Condition = POINTER TO ConditionRec;
    ConditionRec* =
      RECORD
        (Conditions.ConditionRec)
        time: Times.Time;
        passed: BOOLEAN; (* becomes TRUE if the time has passed *)
        scheduled: BOOLEAN; (* Timer event scheduled? *)
        domain: Domain;
      END;

  TYPE
    (* this discpline will be attached to clocks *)
    Discipline = POINTER TO DisciplineRec;
    DisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        domain: Domain;
      END;
  VAR
    disciplineId: Disciplines.Identifier;

  TYPE
    WakeupEvent = POINTER TO WakeupEventRec;
    WakeupEventRec =
      RECORD
        (Events.EventRec)
        condition: Condition;
        awaked: BOOLEAN; (* set to true by Wakeup event handler *)
      END;

  VAR
    if: Conditions.Interface;

  PROCEDURE FixTime(VAR time: Times.Time;
                    currentTime: Times.Time;
                    clock: Clocks.Clock);
    (* convert relative time measures into absolute time specs *)
    VAR op: Op.Operand;
  BEGIN
    IF Scales.IsRelative(time) THEN
      Clocks.GetTime(clock, currentTime);
      op := time; Op.Add3(op, currentTime, time); time := op(Times.Time)
    END;
  END FixTime;

  PROCEDURE Wakeup(event: Events.Event);
    (* note that we strictly rely on the capability of the
      underlying clock to raise this event at the appropriate
      time; we are unable to verify it because that could
      deadlock us in case of remote clocks
    *)
    VAR
      condevent: Events.Event; (* event requested by SendEvent *)
  BEGIN
    WITH event: WakeupEvent DO
      event.awaked := TRUE;
      IF event.condition # NIL THEN
        event.condition.passed := TRUE;
        event.condition.scheduled := FALSE;
        condevent := event.condition.domain.event;
        IF condevent # NIL THEN
          event.condition.domain.event := NIL;
          Events.Raise(condevent);
        END;
      END;
    END;
  END Wakeup;

  PROCEDURE ScheduleEvent(condition: Condition);
    VAR
      wakeup: WakeupEvent;
      domain: Domain;
  BEGIN
    IF ~condition.scheduled THEN
      domain := condition.domain;
      ASSERT(domain.alarm # NIL);
      NEW(wakeup); wakeup.type := domain.alarm;
      wakeup.awaked := FALSE; wakeup.condition := condition;
      condition.scheduled := TRUE;
      Timers.Schedule(domain.clock, condition.time, wakeup);
    END;
  END ScheduleEvent;

  PROCEDURE Init*(condition: Condition; clock: Clocks.Clock; time: Times.Time);
    (* like Create but without NEW *)
    VAR
      clockDisc: Discipline;
      disc: Disciplines.Discipline;
      domain: Domain;
      desc: Conditions.Description;
      priorityOfClock: Priorities.Priority;
      currentTime: Times.Time;
  BEGIN
    IF Disciplines.Seek(clock, disciplineId, disc) THEN
      domain := disc(Discipline).domain;
    ELSE
      (* create new domain *)
      NEW(desc); desc.caps := {}; desc.internal := TRUE;
      IF clock = Clocks.system THEN
        desc.caps := desc.caps +
                  {Conditions.timelimit, Conditions.timecond};
      END;
      IF Clocks.timer IN Clocks.Capabilities(clock) THEN
        Clocks.GetPriority(clock, priorityOfClock);
        IF priorityOfClock > Priorities.base THEN
          desc.caps := desc.caps + {Conditions.select, Conditions.async};
          desc.internal := priorityOfClock < Priorities.interrupts;
        END;
      END;
      NEW(domain); Conditions.InitDomain(domain, if, desc);
      domain.clock := clock;
      IF Clocks.timer IN Clocks.Capabilities(clock) THEN
        Events.Define(domain.alarm);
        Events.SetPriority(domain.alarm, priorityOfClock + 1);
        Events.Handler(domain.alarm, Wakeup);
      ELSE
        domain.alarm := NIL;
      END;
      NEW(clockDisc); clockDisc.id := disciplineId;
      clockDisc.domain := domain;
      Disciplines.Add(clock, clockDisc);
      domain.event := NIL;
    END;
    Conditions.Init(condition, domain);
    FixTime(time, currentTime, clock); condition.time := time;
    condition.domain := domain;
    condition.passed := Clocks.Passed(clock, time);
    condition.scheduled := FALSE;
    IF ~condition.passed &
        (domain.alarm # NIL) & (clock # Clocks.system) THEN
      ScheduleEvent(condition);
    END;
  END Init;

  PROCEDURE Create*(VAR condition: Conditions.Condition;
              clock: Clocks.Clock; time: Times.Time);
    (* create and initialize a time condition:
      is the current time of the clock greater than or
      equal to `time';
      if time is relative then it is taken relative to the current time
    *)
    VAR
      timeCond: Condition;
  BEGIN
    NEW(timeCond);
    Init(timeCond, clock, time);
    condition := timeCond;
  END Create;

  (* ======== interface procedures ================================ *)

  PROCEDURE GetTime(clock: Clocks.Clock;
              VAR currentTime: Times.Time;
              errors: RelatedEvents.Object) : BOOLEAN;
    (* get the current time of clock and check for errors *)
    VAR
      oldEvents, newEvents: RelatedEvents.Queue;
  BEGIN
    RelatedEvents.GetQueue(clock, oldEvents);
    Clocks.GetTime(clock, currentTime);
    RelatedEvents.GetQueue(clock, newEvents);
    IF newEvents # NIL THEN
      RelatedEvents.AppendQueue(errors, newEvents);
    END;
    IF oldEvents # NIL THEN
      RelatedEvents.AppendQueue(clock, oldEvents);
    END;
    IF newEvents # NIL THEN
      RelatedEvents.AppendQueue(clock, newEvents);
    END;
    RETURN newEvents = NIL
  END GetTime;

  PROCEDURE Passed(clock: Clocks.Clock;
              time: Times.Time;
              VAR passed: BOOLEAN;
              errors: RelatedEvents.Object) : BOOLEAN;
    VAR
      oldEvents, newEvents: RelatedEvents.Queue;
  BEGIN
    RelatedEvents.GetQueue(clock, oldEvents);
    passed := Clocks.Passed(clock, time);
    RelatedEvents.GetQueue(clock, newEvents);
    IF newEvents # NIL THEN
      RelatedEvents.AppendQueue(errors, newEvents);
    END;
    IF oldEvents # NIL THEN
      RelatedEvents.AppendQueue(clock, oldEvents);
    END;
    IF newEvents # NIL THEN
      RelatedEvents.AppendQueue(clock, newEvents);
    END;
    RETURN newEvents = NIL
  END Passed;

  PROCEDURE Test(domain: Conditions.Domain; condition: Conditions.Condition;
            errors: RelatedEvents.Object) : BOOLEAN;
    VAR
      currentTime: Times.Time;
  BEGIN
    WITH domain: Domain DO WITH condition: Condition DO
      IF condition.passed THEN RETURN TRUE END;
      IF condition.domain.event # NIL THEN RETURN FALSE END;
      IF condition.scheduled THEN RETURN FALSE END;
      IF ~Passed(domain.clock, condition.time,
          condition.passed, errors) THEN
        condition.passed := TRUE;
        RETURN TRUE
      END;
      RETURN condition.passed
    END; END;
  END Test;

  PROCEDURE GetMinTime(conditionSet: Conditions.ConditionSet;
                VAR minTime: Times.Time;
                VAR minCond: Condition);
    VAR
      condition: Conditions.Condition; (* Condition *)
      op: Op.Operand;
  BEGIN
    minTime := NIL;
    Conditions.ExamineConditions(conditionSet);
    WHILE Conditions.GetNextCondition(conditionSet, condition) DO
      IF (minTime = NIL) OR (Op.Compare(condition(Condition).time, minTime) < 0) THEN
        minTime := condition(Condition).time; minCond := condition(Condition)
      END;
    END;
    op := minTime; Op.Assign(op, minTime); minTime := op(Times.Time) (* take a copy *)
  END GetMinTime;

  PROCEDURE Select(domain: Conditions.Domain;
              conditionSet: Conditions.ConditionSet;
              time: Times.Time;
              VAR setOfTrueConditions: Conditions.ConditionSet;
              errors: RelatedEvents.Object;
              retry: BOOLEAN;
              VAR interrupted: BOOLEAN) : BOOLEAN;
    VAR
      minTime: Times.Time;
      minCond: Condition;
      currentTime: Times.Time; (* of Clocks.system *)
      condition: Conditions.Condition; (* Condition *)
      wakeup: WakeupEvent;
      anythingTrue: BOOLEAN;

    PROCEDURE Failure;
      (* we are unable to retrieve the time;
        so we have to mark all conditions as passed
        and to return the whole set
      *)
      VAR
        condition: Conditions.Condition; (* Condition *)
    BEGIN
      Conditions.CreateSet(setOfTrueConditions);
      Conditions.ExamineConditions(conditionSet);
      WHILE Conditions.GetNextCondition(conditionSet, condition) DO
        condition(Condition).passed := TRUE;
        Conditions.Incl(setOfTrueConditions, condition(Condition));
      END;
    END Failure;

  BEGIN (* Select *)
    WITH domain: Domain DO
      GetMinTime(conditionSet, minTime, minCond);

      (* block current process, if necessary *)
      interrupted := FALSE;
      IF time # NIL THEN
        Clocks.GetTime(Clocks.system, currentTime);
        FixTime(time, currentTime, Clocks.system);
        NEW(wakeup); wakeup.type := domain.alarm;
        wakeup.condition := NIL; wakeup.awaked := FALSE;
        Timers.Schedule(Clocks.system, time, wakeup);
      END;
      IF ~GetTime(domain.clock, currentTime, errors) THEN
        Failure; RETURN TRUE
      END;

      IF ~minCond.passed THEN
        LOOP (* goes only into loop if retry = TRUE & we get interrupted *)
          Process.Pause;
          IF wakeup.awaked THEN EXIT END;
          interrupted := ~minCond.passed;
          IF ~interrupted THEN EXIT END;
          IF ~retry THEN RETURN FALSE END;
        END;
      END;

      anythingTrue := FALSE;
      Conditions.CreateSet(setOfTrueConditions);
      Conditions.ExamineConditions(conditionSet);
      WHILE Conditions.GetNextCondition(conditionSet, condition) DO
        IF condition(Condition).passed THEN
          Conditions.Incl(setOfTrueConditions, condition(Condition));
          anythingTrue := TRUE;
        END;
      END;
      RETURN anythingTrue
    END;
  END Select;

  PROCEDURE SendEvent(domain: Conditions.Domain;
                condition: Conditions.Condition;
                event: Events.Event;
                errors: RelatedEvents.Object) : BOOLEAN;
  BEGIN
    WITH domain: Domain DO WITH condition: Condition DO
      IF condition.passed THEN
        RETURN FALSE
      ELSE
        domain.event := event;
        ScheduleEvent(condition);
        RETURN TRUE
      END;
    END; END;
  END SendEvent;

  PROCEDURE GetNextTime(domain: Conditions.Domain;
                 conditionSet: Conditions.ConditionSet;
                 VAR nextTime: Times.Time;
                 VAR nextCond: Conditions.Condition;
                 errors: RelatedEvents.Object);
    VAR
      condition: Condition;
  BEGIN
    GetMinTime(conditionSet, nextTime, condition);
    nextCond := condition;
  END GetNextTime;

  PROCEDURE InitInterface;
  BEGIN
    NEW(if);
    if.test := Test;
    if.select := Select;
    if.sendevent := SendEvent;
    if.gettime := GetNextTime;
  END InitInterface;

BEGIN
  disciplineId := Disciplines.Unique();
  InitInterface;
END ulmTimeConditions.
