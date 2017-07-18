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
   $Id: Process.om,v 1.3 2004/09/10 16:42:31 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Process.om,v $
   Revision 1.3  2004/09/10 16:42:31  borchert
   id and host added

   Revision 1.2  2004/04/02 17:58:26  borchert
   softTermination and TerminateSoftly added

   Revision 1.1  1994/02/22  20:09:43  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 3/92
   ----------------------------------------------------------------------------
*)

MODULE ulmProcess;

   IMPORT Events := ulmEvents, Priorities := ulmPriorities, Types := ulmTypes;

   (* user readable name of our process *)
   TYPE
      Name* = ARRAY 128 OF CHAR;
   VAR
      name*: Name;
      id*: Name; (* something that identifies our process on our host *)
      host*: Name; (* something that identifies our host, may be "" *)

   (* exit codes *)
   TYPE
      ExitCode* = Types.Int32;
   VAR
      indicateSuccess*: ExitCode;
      indicateFailure*: ExitCode;

   (* process events *)
   TYPE
      ExitEvent* = POINTER TO ExitEventRec;
      ExitEventRec* =
	 RECORD
	    (Events.EventRec)
	    exitcode*: ExitCode;
	 END;
   VAR
      softTermination*: Events.EventType;
      termination*: Events.EventType;
      abort*: Events.EventType;
      startOfGarbageCollection*, endOfGarbageCollection: Events.EventType;
	 (* these events indicate beginning and end of a garbage collection *)

   TYPE
      ExitProc* = PROCEDURE (code: ExitCode);
      AbortProc* = PROCEDURE;
      PauseProc* = PROCEDURE;
      Interface* = POINTER TO InterfaceRec;
      InterfaceRec* =
	 RECORD
	    exit*: ExitProc;
	    abort*: AbortProc;
	    pause*: PauseProc;
	 END;

   (* private declarations *)
   VAR
      handlers: Interface;
      nestlevel: Types.Int32;

   PROCEDURE SetHandlers*(if: Interface);
   BEGIN
      handlers := if;
   END SetHandlers;

   PROCEDURE Exit*(code: ExitCode);
      VAR
	 event: ExitEvent;
   BEGIN
      INC(nestlevel);
      IF nestlevel = 1 THEN
	 NEW(event);
	 event.type := termination;
	 event.message := "exit";
	 event.exitcode := code;
	 Events.Raise(event);
      END;

      handlers.exit(code);
      handlers.pause;
      LOOP END;
   END Exit;

   PROCEDURE TerminateSoftly*;
      VAR
	 event: Events.Event;
   BEGIN
      NEW(event);
      event.type := softTermination;
      event.message := "terminate, please!";
      Events.Raise(event);
   END TerminateSoftly;

   PROCEDURE Terminate*;
   BEGIN
      Exit(indicateSuccess);
   END Terminate;

   PROCEDURE Abort*;
      VAR
	 event: Events.Event;
   BEGIN
      INC(nestlevel);
      IF nestlevel = 1 THEN
	 NEW(event);
	 event.type := abort;
	 event.message := "abort";
	 Events.Raise(event);
      END;

      handlers.abort;
      handlers.exit(indicateFailure);
      handlers.pause;
      LOOP END;
   END Abort;

   PROCEDURE Pause*;
   BEGIN
      handlers.pause;
   END Pause;

   (* =============================================================== *)

   PROCEDURE AbortHandler(event: Events.Event);
   BEGIN
      Abort;
   END AbortHandler;

   (* =============================================================== *)

   PROCEDURE DummyExit(code: ExitCode);
   BEGIN
      LOOP END;
   END DummyExit;

   PROCEDURE DummyAbort;
   BEGIN
      LOOP END;
   END DummyAbort;

   PROCEDURE DummyPause;
   BEGIN
      LOOP END;
   END DummyPause;

BEGIN
   nestlevel := 0;

   name := "Process.name";
   indicateSuccess := 0; indicateFailure := 1;
   NEW(handlers);
   handlers.exit := DummyExit;
   handlers.abort := DummyAbort;
   handlers.pause := DummyPause;

   Events.Define(termination);
   Events.SetPriority(termination, Priorities.exit);
   Events.Handler(termination, Events.NilHandler);

   Events.Define(abort);
   Events.SetPriority(abort, Priorities.exit);
   Events.Handler(abort, Events.NilHandler);

   Events.Define(softTermination);
   Events.SetPriority(softTermination, Priorities.message);
   Events.Handler(softTermination, Events.NilHandler);

   Events.AbortHandler(AbortHandler);

   Events.Define(startOfGarbageCollection);
   Events.SetPriority(startOfGarbageCollection, Priorities.message);
   Events.Ignore(startOfGarbageCollection);
   Events.Define(endOfGarbageCollection);
   Events.SetPriority(endOfGarbageCollection, Priorities.message);
   Events.Ignore(endOfGarbageCollection);
END ulmProcess.
