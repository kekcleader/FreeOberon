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
   $Id: Clocks.om,v 1.3 2004/02/19 15:21:17 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Clocks.om,v $
   Revision 1.3  2004/02/19 15:21:17  borchert
   Passed added including passed capability

   Revision 1.2  1996/01/04 16:50:25  borchert
   clocks are now an extension of Services.Object

   Revision 1.1  1994/02/22  20:06:13  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 1/92
   ----------------------------------------------------------------------------
*)

MODULE ulmClocks;

   IMPORT Disciplines := ulmDisciplines, Events := ulmEvents, Objects := ulmObjects, Op := ulmOperations, Priorities := ulmPriorities,
      RelatedEvents := ulmRelatedEvents, Services := ulmServices, Times := ulmTimes, Types := ulmTypes;

   TYPE
      Clock* = POINTER TO ClockRec;

   CONST
      settime* = 0; timer* = 1; passed* = 2;
   TYPE
      CapabilitySet* = Types.Set; (* OF [settime..passed] *)
   TYPE
      GetTimeProc* = PROCEDURE (clock: Clock; VAR time: Times.Time);
      SetTimeProc* = PROCEDURE (clock: Clock; time: Times.Time);
      PassedProc* = PROCEDURE (clock: Clock; time: Times.Time) : BOOLEAN;
      TimerOnProc* = PROCEDURE (clock: Clock; time: Times.Time;
			       event: Events.Event);
      TimerOffProc* = PROCEDURE (clock: Clock);
      GetPriorityProc* = PROCEDURE (clock: Clock;
				   VAR priority: Priorities.Priority);
      Interface* = POINTER TO InterfaceRec;
      InterfaceRec* =
	 RECORD
	    (Objects.ObjectRec)
	    gettime*: GetTimeProc;
	    settime*: SetTimeProc;
	    passed*: PassedProc;
	    timeron*: TimerOnProc;
	    timeroff*: TimerOffProc;
	    getpriority*: GetPriorityProc;
	 END;

   TYPE
      ClockRec* =
	 RECORD
	    (Services.ObjectRec)
	    if: Interface;
	    caps: CapabilitySet;
	 END;
   VAR
      clockType: Services.Type;

   TYPE
      StaticClock = POINTER TO StaticClockRec;
      StaticClockRec =
	 RECORD
	    (ClockRec)
	    time: Times.Time;
	    timerOn: BOOLEAN;
	    timer: Times.Time;
	    event: Events.Event;
	 END;
   VAR
      staticClockType: Services.Type;

   VAR
      system*: Clock; (* the clock of the operating system *)

   CONST
      cannotSetTime* = 0; (* SetTime not implemented *)
      cannotSetTimer* = 1; (* timer not implemented *)
      errorcodes* = 2;
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

   PROCEDURE Error(clock: Clock; code: Types.Int8);
      VAR
	 event: ErrorEvent;
   BEGIN
      NEW(event);
      event.type := error;
      event.message := errormsg[code];
      event.errorcode := code;
      RelatedEvents.Raise(clock, event);
   END Error;

   PROCEDURE InitErrorHandling;
   BEGIN
      errormsg[cannotSetTime] := "SetTime not implemented for this clock";
      errormsg[cannotSetTimer] := "timer not implemented for this clock";
      Events.Define(error);
      Events.SetPriority(error, Priorities.liberrors);
   END InitErrorHandling;

   PROCEDURE Init*(clock: Clock; if: Interface; caps: CapabilitySet);
      VAR
	 type: Services.Type;
   BEGIN
      Services.GetType(clock, type);
      ASSERT(type # NIL);
      ASSERT(if.gettime # NIL);
      ASSERT(~(passed IN caps) OR (if.passed # NIL));
      ASSERT(~(settime IN caps) OR (if.settime # NIL));
      IF timer IN caps THEN
	 ASSERT((if.timeron # NIL) & (if.timeroff # NIL) &
	    (if.getpriority # NIL));
      END;
      clock.if := if;
      clock.caps := caps;
      RelatedEvents.QueueEvents(clock);
   END Init;

   PROCEDURE Capabilities*(clock: Clock) : CapabilitySet;
   BEGIN
      RETURN clock.caps
   END Capabilities;

   PROCEDURE GetTime*(clock: Clock; VAR time: Times.Time);
   BEGIN
      clock.if.gettime(clock, time);
   END GetTime;

   PROCEDURE SetTime*(clock: Clock; time: Times.Time);
   BEGIN
      IF settime IN clock.caps THEN
	 clock.if.settime(clock, time);
      ELSE
	 Error(clock, cannotSetTime);
      END;
   END SetTime;

   PROCEDURE Passed*(clock: Clock; time: Times.Time) : BOOLEAN;
      VAR
	 currentTime: Times.Time;
   BEGIN
      IF passed IN clock.caps THEN
	 RETURN clock.if.passed(clock, time)
      ELSE
	 GetTime(clock, currentTime);
	 RETURN Op.Compare(currentTime, time) >= 0
      END;
   END Passed;

   PROCEDURE TimerOn*(clock: Clock; time: Times.Time; event: Events.Event);
   BEGIN
      IF timer IN clock.caps THEN
	 clock.if.timeron(clock, time, event);
      ELSE
	 Error(clock, cannotSetTimer);
      END;
   END TimerOn;

   PROCEDURE TimerOff*(clock: Clock);
   BEGIN
      IF timer IN clock.caps THEN
	 clock.if.timeroff(clock);
      ELSE
	 Error(clock, cannotSetTimer);
      END;
   END TimerOff;

   PROCEDURE GetPriority*(clock: Clock; VAR priority: Priorities.Priority);
      (* return Priorities.base in case of static clocks *)
   BEGIN
      IF timer IN clock.caps THEN
	 clock.if.getpriority(clock, priority);
      ELSE
	 Error(clock, cannotSetTimer);
      END;
   END GetPriority;

   (* ========= implementation of static clocks ========== *)

   PROCEDURE StaticGetTime(clock: Clock; VAR time: Times.Time);
   BEGIN
      time := clock(StaticClock).time;
   END StaticGetTime;

   PROCEDURE StaticSetTime(clock: Clock; time: Times.Time);
   BEGIN
      WITH clock: StaticClock DO
	 clock.time := time;
	 IF clock.timerOn & (Op.Compare(clock.time, clock.timer) >= 0) THEN
	    clock.timerOn := FALSE;
	    Events.Raise(clock.event);
	 END;
      END;
   END StaticSetTime;

   PROCEDURE StaticTimerOn(clock: Clock; time: Times.Time; event: Events.Event);
   BEGIN
      WITH clock: StaticClock DO
	 IF Op.Compare(time, clock.time) < 0 THEN
	    Events.Raise(event);
	 ELSE
	    clock.timerOn := TRUE;
	    clock.timer := time;
	    clock.event := event;
	 END;
      END;
   END StaticTimerOn;

   PROCEDURE StaticTimerOff(clock: Clock);
   BEGIN
      WITH clock: StaticClock DO
	 clock.timerOn := FALSE;
      END;
   END StaticTimerOff;

   PROCEDURE StaticGetPriority(clock: Clock; VAR priority: Priorities.Priority);
   BEGIN
      priority := Priorities.base;
   END StaticGetPriority;

   PROCEDURE CreateStaticClock*(VAR clock: Clock);
      VAR
	 if: Interface;
	 staticClock: StaticClock;
   BEGIN
      NEW(staticClock);
      Services.Init(staticClock, staticClockType);
      Times.Create(staticClock.time, Times.absolute);
      staticClock.timerOn := FALSE;
      NEW(if);
      if.gettime := StaticGetTime;
      if.settime := StaticSetTime;
      if.timeron := StaticTimerOn;
      if.timeroff := StaticTimerOff;
      if.getpriority := StaticGetPriority;
      Init(staticClock, if, {settime, timer});
      clock := staticClock;
   END CreateStaticClock;

BEGIN
   InitErrorHandling;
   Services.CreateType(clockType, "Clocks.Clock", "");
   Services.CreateType(staticClockType, "Clocks.StaticClock", "Clocks.Clock");
   (* system is hopefully re-initialized by another module which interfaces
      the real system clock
   *)
   CreateStaticClock(system);
END ulmClocks.
