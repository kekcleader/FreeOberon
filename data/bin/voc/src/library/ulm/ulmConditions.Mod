(* Ulm's Oberon Library
   Copyright (C) 1989-2005 by University of Ulm, SAI, D-89069 Ulm, Germany
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
   $Id: Conditions.om,v 1.7 2005/02/09 09:53:25 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Conditions.om,v $
   Revision 1.7  2005/02/09 09:53:25  borchert
   bug fix: we have to enter a busy loop even in case of interrupting
            events as there is a window between setup and Process.Pause

   Revision 1.6  2005/02/06 22:26:59  borchert
   bug fix: assure that the priority of asynchronous events exceeds
            those of interrupting events

   Revision 1.5  2004/09/03 08:59:34  borchert
   hash tab size for ConditionSet changed from 128 to 64

   Revision 1.4  2004/09/01 13:32:18  borchert
   performance improvement: condition sets are now based on hashes

   Revision 1.3  2001/05/18 21:59:01  borchert
   SetupAsyncEvents checks now all conditions to add as much conditions
   as possible to setOfTrueConditions

   Revision 1.2  1996/01/04 16:59:56  borchert
   - conditions are now extensions of Disciplines.Object
   - some renamings: timecond -> timelimit, hint -> timecond
   - errors events have been replaced by assertions
   - WaitForAndSelect has been renamed to WaitFor (the old version
     of WaitFor vanished)
   - conditions are now tagged to allow some optimizations of the
     condition set operations
   - optimized support of async capability
   - redesign of blocking algorithm

   Revision 1.1  1994/02/22  20:06:25  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 12/91
   ----------------------------------------------------------------------------
*)

MODULE ulmConditions;

   IMPORT Clocks := ulmClocks, Disciplines := ulmDisciplines, Events := ulmEvents, Objects := ulmObjects, Op := ulmOperations,
      Priorities := ulmPriorities, Process := ulmProcess, RelatedEvents := ulmRelatedEvents, Scales := ulmScales, Timers := ulmTimers, Times := ulmTimes, SYSTEM, Types := ulmTypes;

   CONST
      tags = 64;
   TYPE
      Tag = Types.Int32; (* 0..tags-1 *)
	 (* tags are used for the hashs *)
   VAR
      nextTag: Tag; (* 0..tags-1, 0..tags-1, ... *)

   TYPE
      Domain* = POINTER TO DomainRec;
      Condition* = POINTER TO ConditionRec;
      ConditionRec* =
	 RECORD
	    (Disciplines.ObjectRec)
	    domain: Domain;
	    tag: Tag;
	    waitingForEvent: BOOLEAN;
	    gotEvent: BOOLEAN;
	 END;

      (* disjunctive list of conditions *)
      ConditionList = POINTER TO ConditionListRec;
      ConditionListRec =
	 RECORD
	    cond: Condition;
	    next: ConditionList;
	 END;

      BucketTable = ARRAY tags OF ConditionList;
      ConditionSet* = POINTER TO ConditionSetRec;
      ConditionSetRec* =
	 RECORD
	    (Objects.ObjectRec)
	    cardinality: Types.Int32;
	    bucket: BucketTable;
	    (* for the iterator *)
	    next: ConditionList; i: Types.Int32;
	 END;

   CONST
      select* = 0; timelimit* = 1; async* = 2; timecond* = 3; preconditions* = 4;
   TYPE
      CapabilitySet* = Types.Set; (* OF [select..preconditions] *)
   TYPE
      SelectProc* = PROCEDURE (domain: Domain; conditionSet: ConditionSet;
			      time: Times.Time;
			      VAR setOfTrueConditions: ConditionSet;
			      errors: RelatedEvents.Object;
			      retry: BOOLEAN;
			      VAR interrupted: BOOLEAN) : BOOLEAN;
	 (* needs only to be provided if select is in caps;
	    if timelimit isn't in caps then time is guaranteed to
	    be equal to NIL
	 *)
      TestProc* = PROCEDURE (domain: Domain; condition: Condition;
			    errors: RelatedEvents.Object) : BOOLEAN;
      SendEventProc* = PROCEDURE (domain: Domain; condition: Condition;
				 event: Events.Event;
				 errors: RelatedEvents.Object) : BOOLEAN;
	 (* sendevent needs only to be provided if async is in caps *)
      GetTimeProc* = PROCEDURE (domain: Domain; conditionSet: ConditionSet;
			       VAR nextTime: Times.Time;
			       VAR nextCond: Condition;
			       errors: RelatedEvents.Object);
	 (* needs only to be provided if timecond is in caps *)
      PreConditionsProc* = PROCEDURE (domain: Domain; condition: Condition;
				     VAR preconds: ConditionSet;
				     errors: RelatedEvents.Object) : BOOLEAN;
	 (* needs only to be provided if preconditions is in caps *)
      
      Interface* = POINTER TO InterfaceRec;
      InterfaceRec* =
	 RECORD
	    (Objects.ObjectRec)
	    test*: TestProc;
	    select*: SelectProc;
	    sendevent*: SendEventProc;
	    gettime*: GetTimeProc;
	    preconditions*: PreConditionsProc;
	 END;
      Description* = POINTER TO DescriptionRec;
      DescriptionRec* =
	 RECORD
	    (Objects.ObjectRec)
	    caps*: CapabilitySet;
	    internal*: BOOLEAN; (* value does not change during Process.Pause? *)
	 END;

   TYPE
      DomainRec* =
	 RECORD
	    (Disciplines.ObjectRec)
	    if: Interface;
	    desc: Description;
	 END;

   TYPE
      GetTimeOfNextTryProc* = PROCEDURE (iteration: Types.Int32;
					VAR time: Times.Time);
	 (* return a relative time measure *)
   VAR
      getTimeOfNextTry: GetTimeOfNextTryProc;

   TYPE
      WakeupEvent = POINTER TO WakeupEventRec;
      WakeupEventRec =
	 RECORD
	    (Events.EventRec)
	    condition: Condition;
	 END;
   VAR
      nodelay: Times.Time;
      wakeupEventType: Events.EventType; (* used for busy loops only *)

   PROCEDURE WakeupHandler(event: Events.Event);
   BEGIN
      WITH event: WakeupEvent DO
	 event.condition.gotEvent := TRUE;
      END;
   END WakeupHandler;

   PROCEDURE SetGetTimeOfNextTryProc*(p: GetTimeOfNextTryProc);
   BEGIN
      getTimeOfNextTry := p;
   END SetGetTimeOfNextTryProc;

   PROCEDURE GetTimeOfNextTry(iteration: Types.Int32; VAR time: Times.Time);
   BEGIN
      Times.CreateAndSet(time, Times.relative, 0, 1, 0);
      iteration := iteration DIV 5;
      IF iteration > 8 THEN
	 iteration := 8;
      END;
      WHILE iteration > 0 DO
	 Op.Add2(SYSTEM.VAL(Op.Operand, time), time);
	 DEC(iteration);
      END;
   END GetTimeOfNextTry;

   PROCEDURE CreateSet*(VAR conditionSet: ConditionSet);
      VAR
	 i: Types.Int32;
	 cset: ConditionSet;
   BEGIN
      NEW(cset);
      cset.cardinality := 0;
      (*
	 commented out for reasons of efficiency
	 as NEW delivers 0-initialized areas anyway

	 i := 0;
	 WHILE i < tags DO
	    conditionSet.bucket[i] := NIL;
	    INC(i);
	 END;
      *)
      cset.next := NIL; cset.i := 0;
      conditionSet := cset;
   END CreateSet;

   PROCEDURE Incl*(conditionSet: ConditionSet; condition: Condition);
      VAR
	 listp: ConditionList;
	 new: ConditionList;
	 i: Types.Int32;
   BEGIN
      (* check if condition is already present in conditionSet *)
      i := condition.tag;
      listp := conditionSet.bucket[i];
      WHILE (listp # NIL) & (listp.cond # condition) DO
	 listp := listp.next;
      END;
      IF listp # NIL THEN (* already in set *) RETURN END;

      NEW(new); new.cond := condition;
      new.next := conditionSet.bucket[i];
      conditionSet.bucket[i] := new;
      INC(conditionSet.cardinality);
   END Incl;

   PROCEDURE Excl*(conditionSet: ConditionSet; condition: Condition);
      VAR
	 prev, listp: ConditionList;
	 i: Types.Int32;
   BEGIN
      i := condition.tag;
      listp := conditionSet.bucket[i]; prev := NIL;
      WHILE (listp # NIL) & (listp.cond # condition) DO
	 prev := listp; listp := listp.next;
      END;
      IF listp = NIL THEN (* condition not in set *) RETURN END;

      IF prev = NIL THEN
	 conditionSet.bucket[i] := listp.next;
      ELSE
	 prev.next := listp.next;
      END;
      DEC(conditionSet.cardinality);

      (* make the iterator more robust *)
      IF conditionSet.next = listp THEN
	 conditionSet.next := listp.next;
      END;
   END Excl;

   PROCEDURE In*(conditionSet: ConditionSet; condition: Condition) : BOOLEAN;
      VAR
	 listp: ConditionList;
   BEGIN
      listp := conditionSet.bucket[condition.tag];
      WHILE (listp # NIL) & (listp.cond # condition) DO
	 listp := listp.next;
      END;
      RETURN listp # NIL
   END In;

   PROCEDURE Union*(result: ConditionSet; set: ConditionSet);
      VAR
	 listp: ConditionList;
	 newelem, newelems: ConditionList;
	 count: Types.Int32; (* # of added elements in newelems *)
	 i: Types.Int32;
   BEGIN
      count := 0;
      i := 0;
      WHILE i < tags DO
	 listp := set.bucket[i];
	 newelems := result.bucket[i];
	 IF newelems = NIL THEN
	    WHILE listp # NIL DO
	       NEW(newelem); newelem.cond := listp.cond;
	       newelem.next := newelems;
	       newelems := newelem;
	       INC(count);
	       listp := listp.next;
	    END;
	 ELSE
	    WHILE listp # NIL DO
	       IF ~In(result, listp.cond) THEN
		  NEW(newelem); newelem.cond := listp.cond;
		  newelem.next := newelems;
		  newelems := newelem;
		  INC(count);
	       END;
	       listp := listp.next;
	    END;
	 END;
	 result.bucket[i] := newelems;
	 INC(i);
      END;
      INC(result.cardinality, count);
   END Union;

   PROCEDURE Union3*(VAR result: ConditionSet; set1, set2: ConditionSet);
   BEGIN
      CreateSet(result); Union(result, set1); Union(result, set2);
   END Union3;

   PROCEDURE Card*(conditionSet: ConditionSet) : Types.Int32;
   BEGIN
      RETURN conditionSet.cardinality
   END Card;

   PROCEDURE ExamineConditions*(conditionSet: ConditionSet);
   BEGIN
      conditionSet.next := NIL;
      conditionSet.i := 0;
   END ExamineConditions;

   PROCEDURE GetNextCondition*(conditionSet: ConditionSet;
			      VAR condition: Condition) : BOOLEAN;
      VAR
	 i: Types.Int32;
   BEGIN
      IF conditionSet.next = NIL THEN
	 i := conditionSet.i;
	 WHILE (i < tags) & (conditionSet.bucket[i] = NIL) DO
	    INC(i);
	 END;
	 conditionSet.i := i + 1;
	 IF i >= tags THEN
	    RETURN FALSE
	 END;
	 conditionSet.next := conditionSet.bucket[i];
      END;
      condition := conditionSet.next.cond;
      conditionSet.next := conditionSet.next.next;
      RETURN TRUE
   END GetNextCondition;

   PROCEDURE InitDomain*(domain: Domain; if: Interface; desc: Description);
   BEGIN
      domain.if := if;
      domain.desc := desc;
   END InitDomain;

   PROCEDURE Init*(condition: Condition; domain: Domain);
   BEGIN
      condition.domain := domain;
      condition.tag := nextTag;
      nextTag := (nextTag + 1) MOD tags;
      condition.waitingForEvent := FALSE;
      condition.gotEvent := FALSE;
   END Init;

   PROCEDURE Test*(condition: Condition; errors: RelatedEvents.Object) : BOOLEAN;
   BEGIN
      IF condition.waitingForEvent & ~condition.gotEvent THEN
	 RETURN FALSE
      ELSE
	 RETURN condition.domain.if.test(condition.domain, condition, errors)
      END;
   END Test;

   PROCEDURE CommonDomain(cset: ConditionSet;
			  VAR domain: Domain) : BOOLEAN;
      VAR
	 dom: Domain;
	 i: Types.Int32;
	 listp: ConditionList;
   BEGIN
      dom := NIL;
      i := 0;
      WHILE i < tags DO
	 listp := cset.bucket[i];
	 WHILE listp # NIL DO
	    IF dom = NIL THEN
	       dom := listp.cond.domain;
	    ELSIF dom # listp.cond.domain THEN
	       RETURN FALSE
	    END;
	    listp := listp.next;
	 END;
	 INC(i);
      END;
      domain := dom;
      RETURN dom # NIL
   END CommonDomain;

   PROCEDURE SimpleWaitForAndSelect(
		  conditionSet: ConditionSet;
		  VAR setOfTrueConditions: ConditionSet;
		  errors: RelatedEvents.Object);
      (* simple means that we don't need to take care of preconditions *)
      TYPE
	 List = POINTER TO ListRec;
	 Element = POINTER TO ElementRec;
	 ListRec =
	    RECORD
	       head: Element;
	    END;
	 Ring = POINTER TO RingRec;
	 RingRec =
	    RECORD
	       (ListRec)
	       tail: Element;
	    END;
	 ElementRec =
	    RECORD
	       next: Element;
	       domain: Domain;
	       cset: ConditionSet;
	    END;
      VAR
	 domain: Domain;
	 interrupted: BOOLEAN;
	 ok: BOOLEAN;

      PROCEDURE SortConditions(VAR asyncList, timeList, others: List;
			       VAR ring: Ring;
			       VAR otherAreInternal: BOOLEAN);
	 (* sort conditions into several lists:

	    ayncList:   list of conditions for which we can setup an event;
			after this setup we needn't to take care of them
	    timeList:   list of time conditions (based on system clock)
	    ring:       conditions which support select & timelimit

	    otherAreInternal:
			is set to TRUE if all other conditions which
			are not put into one of the lists above remain
			unaffected while pausing
	 *)

	 VAR
	    listp: ConditionList;
	    i: Types.Int32;

	 PROCEDURE CreateList(VAR list: List);
	 BEGIN
	    NEW(list); list.head := NIL;
	 END CreateList;

	 PROCEDURE CreateRing(VAR ring: Ring);
	 BEGIN
	    NEW(ring); ring.head := NIL; ring.tail := NIL;
	 END CreateRing;

	 PROCEDURE Add(condition: Condition);
	    VAR
	       domain: Domain;

	    PROCEDURE AddTo(list: List);
	       VAR
		  elp: Element;
	    BEGIN
	       elp := list.head;
	       WHILE (elp # NIL) & (elp.domain # domain) DO
		  elp := elp.next;
	       END;
	       IF elp = NIL THEN
		  NEW(elp);
		  elp.next := list.head;
		  elp.domain := condition.domain;
		  CreateSet(elp.cset);
		  list.head := elp;
		  IF list IS Ring THEN
		     WITH list: Ring DO
			IF list.tail = NIL THEN
			   list.tail := elp;
			END;
			list.tail.next := list.head;
		     END;
		  END;
	       END;
	       Incl(elp.cset, condition);
	    END AddTo;

	 BEGIN (* Add *)
	    domain := condition.domain;
	    IF timecond IN domain.desc.caps THEN
	       IF timeList = NIL THEN
		  CreateList(timeList);
	       END;
	       AddTo(timeList);
	    ELSIF async IN domain.desc.caps THEN
	       IF asyncList = NIL THEN
		  CreateList(asyncList);
	       END;
	       AddTo(asyncList);
	    ELSIF (select IN domain.desc.caps) &
		  (timelimit IN domain.desc.caps) THEN
	       IF ring = NIL THEN
		  CreateRing(ring);
	       END;
	       AddTo(ring);
	    ELSE
	       IF others = NIL THEN
		  CreateList(others);
	       END;
	       AddTo(others);
	       IF ~domain.desc.internal THEN
		  otherAreInternal := FALSE;
	       END;
	    END;
	 END Add;

      BEGIN (* SortConditions *)
	 asyncList := NIL; timeList := NIL; ring := NIL;
	 otherAreInternal := TRUE;
	 i := 0;
	 WHILE i < tags DO
	    listp := conditionSet.bucket[i];
	    WHILE listp # NIL DO
	       Add(listp.cond);
	       listp := listp.next;
	    END;
	    INC(i);
	 END;
      END SortConditions;

      PROCEDURE SetupEventHandling(condition: Condition;
                                   VAR wakeupEvent: WakeupEvent);
	 VAR
	    wakeup: Events.EventType;
	    priority: Priorities.Priority;
      BEGIN
	 Events.Define(wakeup);
	 priority := Events.GetPriority() + 1;
	 IF priority < Priorities.interrupts + 1 THEN
	    priority := Priorities.interrupts + 1;
	 END;
	 Events.SetPriority(wakeup, priority);
	 Events.Handler(wakeup, WakeupHandler);
	 NEW(wakeupEvent); wakeupEvent.type := wakeup;
	 wakeupEvent.condition := condition;
	 condition.waitingForEvent := TRUE;
	 condition.gotEvent := FALSE;
      END SetupEventHandling;

      PROCEDURE SetupAsyncEvents(list: List) : BOOLEAN;
	 VAR
	    elp: Element;
	    listp: ConditionList; i: Types.Int32;
	    wakeupEvent: WakeupEvent;
	    sendevent: SendEventProc;
	    anythingTrue: BOOLEAN;
      BEGIN
	 anythingTrue := FALSE;
	 elp := list.head;
	 WHILE elp # NIL DO
	    sendevent := elp.domain.if.sendevent;
	    i := 0;
	    WHILE i < tags DO
	       listp := elp.cset.bucket[i];
	       WHILE listp # NIL DO
		  IF ~listp.cond.waitingForEvent OR listp.cond.gotEvent THEN
		     SetupEventHandling(listp.cond, wakeupEvent);
		     IF ~sendevent(elp.domain, listp.cond,
			   wakeupEvent, errors) THEN
			IF ~anythingTrue THEN
			   CreateSet(setOfTrueConditions);
			END;
			Incl(setOfTrueConditions, listp.cond);
			listp.cond.waitingForEvent := FALSE;
			anythingTrue := TRUE;
		     END;
		  END;
		  listp := listp.next;
	       END;
	       INC(i);
	    END;
	    elp := elp.next;
	 END;
	 RETURN ~anythingTrue
      END SetupAsyncEvents;

      PROCEDURE Block;
	 (* block until one of the conditions becomes TRUE *)
	 VAR
	    asyncList: List; (* list of domains which supports async events *)
	    timeList: List; (* list of domains which supports timecond *)
	    ring: Ring; (* ring of domains which support select+timelimit *)
	    largeRing: BOOLEAN; (* >=2 ring members *)
	    ringMember: Element; (* current ring member *)
	    others: List; (* those which are not member of the other lists *)
	    otherAreInternal: BOOLEAN;
	    waitErrors: RelatedEvents.Object;
	    queue: RelatedEvents.Queue; (* queue of waitErrors *)
	    busyLoop: BOOLEAN; (* TRUE if we have to resort to a busy loop *)
	    wakeupEvent: Events.Event; (* iteration event for busy loops *)
	    loopCnt: Types.Int32; (* number of iterations *)
	    nextTime: Times.Time;
	    minTime: Times.Time;
	    minTimeCond: Condition;
	    interrupted: BOOLEAN; (* interrupted select? *)
	    highPriority: BOOLEAN; (* priority >= Priorities.interrupt? *)

	 PROCEDURE FixToRelTime(VAR time: Times.Time);
	    VAR
	       currentTime: Times.Time;
	       relTime: Times.Time;
	 BEGIN
	    Clocks.GetTime(Clocks.system, currentTime);
	    Op.Sub3(SYSTEM.VAL(Op.Operand, relTime), time, currentTime);
	    time := relTime;
	 END FixToRelTime;

	 PROCEDURE GetMinTime(VAR nextTime: Times.Time;
			      VAR minCond: Condition);
	    VAR
	       elp: Element;
	       time: Times.Time;
	       condition: Condition;

	 BEGIN (* GetMinTime *)
	    nextTime := NIL; minCond := NIL;
	    IF timeList # NIL THEN
	       elp := timeList.head;
	       WHILE elp # NIL DO
		  elp.domain.if.gettime(domain, elp.cset,
					time, condition, waitErrors);
		  IF Scales.IsAbsolute(time) THEN
		     FixToRelTime(time);
		  END;
		  IF (nextTime = NIL) OR (Op.Compare(time, nextTime) < 0) THEN
		     nextTime := time; minCond := condition;
		  END;
		  elp := elp.next;
	       END;
	    END;
	 END GetMinTime;

	 PROCEDURE UpdateMinTime(VAR nextTime: Times.Time;
				 VAR minCond: Condition);
	    VAR
	       set: ConditionSet;
	       time: Times.Time;
	       cond: Condition;
	 BEGIN
	    IF minCond = NIL THEN
	       nextTime := NIL;
	    ELSE
	       CreateSet(set);
	       Incl(set, minCond);
	       minCond.domain.if.gettime(minCond.domain, set,
					 time, cond, waitErrors);
	       IF Scales.IsAbsolute(time) THEN
		  FixToRelTime(time);
	       END;
	       nextTime := time;
	    END;
	 END UpdateMinTime;

	 PROCEDURE TestNonRingMembers() : BOOLEAN;

	    PROCEDURE TestList(list: List) : BOOLEAN;
	       VAR
		  domain: Domain;
		  element: Element;
		  selected: ConditionSet;
		  interrupted: BOOLEAN;

	       PROCEDURE TestAndSelect(conditionSet: ConditionSet;
				       VAR setOfTrueConditions: ConditionSet;
				       errors: RelatedEvents.Object) : BOOLEAN;
		  VAR
		     listp: ConditionList; i: Types.Int32;
		     condition: Condition;
		     anythingTrue: BOOLEAN;
	       BEGIN (* TestAndSelect *)
		  anythingTrue := FALSE;
		  CreateSet(setOfTrueConditions);
		  i := 0;
		  WHILE i < tags DO
		     listp := conditionSet.bucket[i];
		     WHILE listp # NIL DO
			condition := listp.cond;
			IF domain.if.test(domain, condition, errors) THEN
			   Incl(setOfTrueConditions, condition);
			   anythingTrue := TRUE;
			END;
			listp := listp.next;
		     END;
		     INC(i);
		  END;
		  RETURN anythingTrue
	       END TestAndSelect;

	    BEGIN (* TestList *)
	       IF list = NIL THEN RETURN FALSE END;
	       element := list.head;
	       WHILE element # NIL DO
		  domain := element.domain;
		  IF (select IN domain.desc.caps) &
			(timelimit IN domain.desc.caps) THEN
		     IF domain.if.select(domain, element.cset, nodelay,
			   selected, waitErrors, FALSE, interrupted) THEN
			ASSERT(Card(selected) > 0);
			Union(setOfTrueConditions, selected);
			RETURN TRUE
		     END;
		  ELSE
		     IF TestAndSelect(element.cset, selected, waitErrors) THEN
			Union(setOfTrueConditions, selected);
			RETURN TRUE
		     END;
		  END;
		  element := element.next;
	       END;
	       RETURN FALSE
	    END TestList;

	    PROCEDURE TestAsyncList(list: List) : BOOLEAN;
	       VAR
		  element: Element;
		  listp: ConditionList; i: Types.Int32;
		  condition: Condition;
		  anythingFound: BOOLEAN;
	    BEGIN
	       IF list = NIL THEN RETURN FALSE END;
	       anythingFound := FALSE;
	       element := list.head;
	       WHILE element # NIL DO
		  i := 0;
		  WHILE i < tags DO
		     listp := element.cset.bucket[i];
		     WHILE listp # NIL DO
			condition := listp.cond;
			IF condition.gotEvent THEN
			   Incl(setOfTrueConditions, condition);
			   anythingFound := TRUE;
			END;
			listp := listp.next;
		     END;
		     INC(i);
		  END;
		  element := element.next;
	       END;
	       RETURN anythingFound
	    END TestAsyncList;

	 BEGIN (* TestNonRingMembers *)
	    CreateSet(setOfTrueConditions);
	    RETURN TestAsyncList(asyncList) OR TestList(others)
	 END TestNonRingMembers;

      BEGIN (* Block *)
	 NEW(waitErrors); RelatedEvents.QueueEvents(waitErrors);
	 SortConditions(asyncList, timeList, others, ring, otherAreInternal);
	 IF asyncList # NIL THEN
	    (* set up asynchronous events for these conditions --
	       this should be done before the first call of
	       TestNonRingMembers() to avoid redundant test calls
	    *)
	    IF ~SetupAsyncEvents(asyncList) THEN
	       (* one of them happened to be TRUE now *)
	       RETURN
	    END;
	 END;
	 IF TestNonRingMembers() THEN
	    RETURN
	 END;
	 (* check for deadlock *)
	 ASSERT((asyncList # NIL) OR (timeList # NIL) OR (ring # NIL) OR
		~otherAreInternal);
	 highPriority := Events.GetPriority() >= Priorities.interrupts;
	 IF ring # NIL THEN
	    ringMember := ring.head;
	    largeRing := ring.head # ring.head.next;
	 ELSE
	    ringMember := NIL; largeRing := FALSE;
	 END;
	 GetMinTime(minTime, minTimeCond);
	 busyLoop := largeRing OR ~otherAreInternal OR (asyncList # NIL);

	 loopCnt := 0;
	 LOOP (* until one of the conditions becomes TRUE *)
	    (* determine timelimit parameter for select *)
	    IF busyLoop THEN
	       getTimeOfNextTry(loopCnt + 1, nextTime);
	       ASSERT(Op.Compare(nextTime, nodelay) > 0);
	       IF timeList # NIL THEN
		  IF Op.Compare(minTime, nextTime) < 0 THEN
		     nextTime := minTime;
		  END;
	       END;
	    ELSIF timeList # NIL THEN
	       nextTime := minTime;
	    ELSE
	       nextTime := NIL; minTime := NIL; minTimeCond := NIL;
	    END;

	    IF (minTime # NIL) & (Op.Compare(minTime, nodelay) <= 0) THEN
	       CreateSet(setOfTrueConditions);
	       Incl(setOfTrueConditions, minTimeCond);
	       EXIT
	    END;

	    IF ringMember = NIL THEN
	       ASSERT(~highPriority);
	       IF nextTime # NIL THEN
		  NEW(wakeupEvent); 
		  wakeupEvent.type := wakeupEventType;
		  Events.SetPriority(wakeupEventType, Events.GetPriority() + 1);
		  Timers.Schedule(Clocks.system, nextTime, wakeupEvent);
	       END;
	       Process.Pause;
	    ELSE
	       IF ringMember.domain.if.select
		     (ringMember.domain, ringMember.cset, nextTime,
		      setOfTrueConditions, waitErrors,
		      (* retry = *) FALSE, interrupted) THEN
		  ASSERT(Card(setOfTrueConditions) > 0);
		  EXIT
	       END;
	       (* timelimit exceeded or interrupted *)
	       ASSERT(interrupted OR (nextTime # NIL));
	       IF interrupted THEN
		  (* remove error event *)
		  RelatedEvents.GetQueue(waitErrors, queue);
	       ELSIF (minTimeCond # NIL) & ~busyLoop THEN
		  (* timelimit exceeded: minTimeCond is now TRUE *)
		  CreateSet(setOfTrueConditions);
		  Incl(setOfTrueConditions, minTimeCond);
		  EXIT
	       END;
	    END;
	    IF TestNonRingMembers() THEN
	       EXIT
	    END;
	    IF timeList # NIL THEN
	       UpdateMinTime(minTime, minTimeCond);
	    END;
	    INC(loopCnt);
	 END;
	 (* forward error events to error parameter of SimpleWaitForAndSelect *)
	 RelatedEvents.GetQueue(waitErrors, queue);
	 RelatedEvents.AppendQueue(errors, queue);
      END Block;

   BEGIN (* SimpleWaitForAndSelect *)
      IF CommonDomain(conditionSet, domain) &
	    (select IN domain.desc.caps) THEN
	 ok := domain.if.select
		  (domain, conditionSet, NIL, setOfTrueConditions,
		   errors, (* retry = *) TRUE, interrupted);
	 (* a return value of FALSE is only to be expected
	    if a time limit is given or if retry = FALSE
	 *)
	 ASSERT(ok);
      ELSE
	 Block;
      END;
   END SimpleWaitForAndSelect;

   PROCEDURE WaitFor*(conditionSet: ConditionSet;
		     VAR setOfTrueConditions: ConditionSet;
		     errors: RelatedEvents.Object);
      VAR
	 listp: ConditionList; i: Types.Int32;
	 testSet: ConditionSet;
	 preconds: ConditionSet;
	 domain: Domain;
	 selected: ConditionSet;
	 anyPreconditions: BOOLEAN;

      PROCEDURE PretestClosure(testSet, preconds: ConditionSet);
	 VAR
	    listp: ConditionList; i: Types.Int32;
	    domain: Domain;
	    morePreconditions: ConditionSet;
	    evenMorePreconditions: ConditionSet;
      BEGIN
	 REPEAT
	    CreateSet(morePreconditions);
	    i := 0;
	    WHILE i < tags DO
	       listp := preconds.bucket[i];
	       WHILE listp # NIL DO
		  domain := listp.cond.domain;
		  IF (preconditions IN domain.desc.caps) &
			domain.if.preconditions(domain, listp.cond,
						evenMorePreconditions, errors) &
			(evenMorePreconditions # NIL) &
			(Card(evenMorePreconditions) > 0) THEN
		     Union(morePreconditions, evenMorePreconditions);
		  ELSE
		     Incl(testSet, listp.cond);
		  END;
		  listp := listp.next;
	       END;
	       INC(i);
	    END;
	    preconds := morePreconditions;
	 UNTIL Card(preconds) = 0
      END PretestClosure;

   BEGIN (* WaitFor *)
      ASSERT(conditionSet.cardinality > 0);
      LOOP
	 CreateSet(testSet);
	 anyPreconditions := FALSE;
	 i := 0;
	 WHILE i < tags DO
	    listp := conditionSet.bucket[i];
	    WHILE listp # NIL DO
	       domain := listp.cond.domain;
	       IF (preconditions IN domain.desc.caps) &
		     domain.if.preconditions(domain,
					     listp.cond, preconds, errors) &
		     (preconds # NIL) & (Card(preconds) > 0) THEN
		  PretestClosure(testSet, preconds);
		  anyPreconditions := TRUE;
	       ELSE
		  Incl(testSet, listp.cond);
	       END;
	       listp := listp.next;
	    END;
	    INC(i);
	 END;

	 SimpleWaitForAndSelect(testSet, selected, errors);
	 IF ~anyPreconditions THEN
	    setOfTrueConditions := selected;
	    EXIT
	 END;
	 i := 0;
	 WHILE i < tags DO
	    listp := selected.bucket[i];
	    WHILE listp # NIL DO
	       IF ~In(conditionSet, listp.cond) THEN
		  Excl(selected, listp.cond);
	       END;
	       listp := listp.next;
	    END;
	    INC(i);
	 END;
	 IF Card(selected) > 0 THEN
	    setOfTrueConditions := selected;
	    EXIT
	 END;
      END;
      ASSERT(Card(setOfTrueConditions) > 0);
   END WaitFor;

BEGIN
   SetGetTimeOfNextTryProc(GetTimeOfNextTry);
   Times.CreateAndSet(nodelay, Times.relative, 0, 0, 0);
   nextTag := 0;
   Events.Define(wakeupEventType);
   Events.Handler(wakeupEventType, Events.NilHandler);
END ulmConditions.
