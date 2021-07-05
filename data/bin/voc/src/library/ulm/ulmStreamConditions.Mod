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
   $Id: StreamCondi.om,v 1.1 1994/02/22 20:10:24 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: StreamCondi.om,v $
   Revision 1.1  1994/02/22  20:10:24  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 1/92
   ----------------------------------------------------------------------------
*)

MODULE ulmStreamConditions;

   IMPORT Conditions := ulmConditions, Events := ulmEvents, Priorities := ulmPriorities, RelatedEvents := ulmRelatedEvents, Streams := ulmStreams;

   CONST
      msgFailed* = 0; (* message was not processed by the implementation *)
      invalidOp* = 1; (* operation was not read or write *)
      errorcodes* = 2;
   TYPE
      ErrorEvent* = POINTER TO ErrorEventRec;
      ErrorEventRec* =
	 RECORD
	    (Events.EventRec)
	    errorcode*: SHORTINT;
	 END;
   VAR
      errormsg*: ARRAY errorcodes OF Events.Message;
      error*: Events.EventType;

   CONST
      read* = 0; write* = 1; (* operations *)
   TYPE
      Operation* = SHORTINT; (* read or write *)
   TYPE
      CreateConditionMessage* =
	 RECORD
	    (Streams.Message)
	    (* in-parameters *)
	    operation*: Operation; (* read or write *)
	    (* out-parameters *)
	    condition*: Conditions.Condition; (* return value *)
	    stream*: Streams.Stream; (* message processed for this stream *)
	    msgProcessed*: BOOLEAN; (* initially FALSE; has to be set to TRUE *)
	 END;
      TestConditionMessage* =
	 RECORD
	    (Streams.Message)
	    (* in-parameters *)
	    operation*: Operation; (* read or write *)
	    errors*: RelatedEvents.Object; (* relate errors to this object *)
	    (* out-parameters *)
	    wouldblock*: BOOLEAN;
	    msgProcessed*: BOOLEAN;
	 END;

   TYPE
      Condition = POINTER TO ConditionRec;
      ConditionRec =
	 RECORD
	    (Conditions.ConditionRec)
	    stream: Streams.Stream;
	    operation: Operation;
	 END;
   VAR
      domain: Conditions.Domain;

   PROCEDURE InitErrorHandling;
   BEGIN
      Events.Define(error);
      Events.SetPriority(error, Priorities.liberrors);
      errormsg[msgFailed] :=
	 "operation not processed by underlying stream implementation";
      errormsg[invalidOp] := "invalid operation (read or write expected)";
   END InitErrorHandling;

   PROCEDURE Error(object: RelatedEvents.Object; errorcode: SHORTINT);
      VAR
	 event: ErrorEvent;
   BEGIN
      NEW(event); event.type := error; event.message := errormsg[errorcode];
      event.errorcode := errorcode;
      RelatedEvents.Raise(object, event);
   END Error;

   PROCEDURE Test(domain: Conditions.Domain; condition: Conditions.Condition;
		  errors: RelatedEvents.Object) : BOOLEAN;
      VAR
	 msg: TestConditionMessage;
   BEGIN
      WITH condition: Condition DO
	 CASE condition.operation OF
	 | read:  IF Streams.InputInBuffer(condition.stream) THEN
		     RETURN TRUE
		  END;
	 | write: IF Streams.OutputWillBeBuffered(condition.stream) THEN
		     RETURN TRUE
		  END;
    ELSE
	 END;
	 msg.operation := condition.operation;
	 msg.errors := errors;
	 msg.wouldblock := TRUE;
	 msg.msgProcessed := FALSE;
	 Streams.Send(condition.stream, msg);
	 IF ~msg.msgProcessed THEN
	    Error(errors, msgFailed); RETURN FALSE
	 END;
	 RETURN ~msg.wouldblock
      END;
   END Test;

   PROCEDURE InitDomain;
      VAR
	 if: Conditions.Interface;
	 desc: Conditions.Description;
   BEGIN
      NEW(if); if.test := Test;
      NEW(desc); desc.caps := {}; desc.internal := TRUE;
      NEW(domain); Conditions.InitDomain(domain, if, desc);
   END InitDomain;

   PROCEDURE Create*(VAR condition: Conditions.Condition;
		    s: Streams.Stream; operation: Operation);
      (* condition = NIL in error case, eg if the associated
	 stream implementation does not interpret such messages
      *)
      VAR
	 msg: CreateConditionMessage;
	 newcond: Condition;
   BEGIN
      IF (operation # read) & (operation # write) THEN
	 condition := NIL; Error(s, invalidOp); RETURN
      END;
      msg.operation := operation; msg.condition := NIL;
      msg.stream := s; msg.msgProcessed := FALSE;
      Streams.Send(s, msg);
      IF ~msg.msgProcessed THEN
	 Error(s, msgFailed); condition := NIL; RETURN
      END;
      IF (msg.condition # NIL) & (msg.stream = s) THEN
	 (* underlying implementation has its own domain and
	    defines it own conditions
	 *)
	 condition := msg.condition; RETURN
      END;
      NEW(newcond); newcond.stream := s; newcond.operation := operation;
      Conditions.Init(newcond, domain);
      condition := newcond;
   END Create;

BEGIN
   InitErrorHandling;
   InitDomain;
END ulmStreamConditions.
