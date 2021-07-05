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
   $Id: Priorities.om,v 1.1 1994/02/22 20:09:33 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Priorities.om,v $
   Revision 1.1  1994/02/22  20:09:33  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 9/89
   ----------------------------------------------------------------------------
*)

MODULE ulmPriorities;

   (* defines priority system per initialized variables;
      all priorities needed by the Oberon-library (base, sys, and std) are
      defined in this module;

      the original module of this definition can be copied
      and modified to match the needs of a specific application;

      the default priority should range in [null..error);
      setting the default priority to null allows to take advantage
      of default error handling routines in small applications;

      the priority system must be open for extensions:
      - each priority below defines a base value of a priority region;
	the region size is defined by `region';
	e.g. legal library error priorities range from
	liberrors to liberrors+region-1
      - gap defines the minimum distance between two priority regions
	defined in this module
   *)
   IMPORT Types := ulmTypes;
   CONST
      region* = 10;
      gap* = 10;

      null* = 0;			(* lowest priority possible;
				   this is not a legal priority for events
				*)

   TYPE
      Priority* = Types.Int32;

   VAR
      (* current priority at begin of execution (after init of Events);
	 this is the lowest priority possible during execution (>= null);
	 every event with priority less than `base' is ignored
	 automatically
      *)
      base*: Priority;

      (* default priority of events (if not changed by Events.SetPriority)*)
      default*: Priority;

      (* priority of messages which do not indicate an error *)
      message*: Priority;

      (* priority of system call errors *)
      syserrors*: Priority;

      (* priority of library errors;
         e.g. usage errors or failed system calls;
	 library errors should have higher priority than syserrors
      *)
      liberrors*: Priority;

      (* priority of assertions of library modules *)
      assertions*: Priority;

      (* priority of (application) error messages or warnings *)
      error*: Priority;

      (* priority of asynchronous interrupts like
	 break key, alarm clock, etc.
      *)
      interrupts*: Priority;

      (* priority of ``out of space'' events (SysStorage) *)
      storage*: Priority;

      (* priority of run time errors *)
      rtserrors*: Priority;

      (* priority of fatal errors (error message & exit) *)
      fatal*: Priority;

      (* priority of fatal signals;
	 e.g. segmentation violation, alignment faults, illegal instructions;
	 these signals must not be ignored, and
	 event handlers must not return on such events
	 (this would cause an infinite loop)
      *)
      fatalsignals*: Priority;

      (* priority of bugs and (failed) assertions;
	 bugs are error messages followed by exit (with core dump if possible)
      *)
      bug*: Priority;

      (* priority of task switches are at very high priority to
	 allow the necessary bookkeeping
      *)
      taskswitch*: Priority;

      (* priority of exit and abort;
	 actions on this priority level should be minimized
	 and (if possible) error-free
      *)
      exit*: Priority;

      next: Priority; (* next legal priority value *)

   PROCEDURE Set(VAR base: Priority);
   BEGIN
      base := next; INC(next, region+gap);
   END Set;

BEGIN
   next := null;
   Set(base);
   Set(default);
   Set(message);
   Set(syserrors);
   Set(liberrors);
   Set(assertions);
   Set(error);
   Set(interrupts);
   Set(storage);
   Set(rtserrors);
   Set(fatal);
   Set(fatalsignals);
   Set(bug);
   Set(taskswitch);
   Set(exit);
END ulmPriorities.
