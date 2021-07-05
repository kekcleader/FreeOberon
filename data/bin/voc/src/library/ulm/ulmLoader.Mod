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
   $Id: Loader.om,v 1.3 2004/09/03 09:46:50 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Loader.om,v $
   Revision 1.3  2004/09/03 09:46:50  borchert
   error events are also raised as global events
   (this allows to log all failed loading operations)

   Revision 1.2  1996/01/04  16:48:33  borchert
   support for dynamic loading of service providers added

   Revision 1.1  1994/02/22  20:08:13  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 6/93
   ----------------------------------------------------------------------------
*)

MODULE ulmLoader;

   (* load and initialize modules *)

   IMPORT ASCII := ulmASCII , Events := ulmEvents, Priorities := ulmPriorities, RelatedEvents := ulmRelatedEvents, Services := ulmServices;

   CONST
      loadService* = 0;
   TYPE
      CapabilitySet* = SET; (* loadService..loadService *)
      LoadProc* = PROCEDURE (module: ARRAY OF CHAR;
			    errors: RelatedEvents.Object) : BOOLEAN;
      LoadServiceProc* = PROCEDURE (service, for: ARRAY OF CHAR;
				   errors: RelatedEvents.Object) : BOOLEAN;
      Interface* = POINTER TO InterfaceRec;
      InterfaceRec* =
	 RECORD
	    load*: LoadProc;
	    loadService*: LoadServiceProc;
	 END;

   CONST
      noInterface* = 0; (* SetInterface has not been called yet *)
      moduleNotLoaded* = 1; (* interface procedure returned FALSE *)
      servicesNotSupported* = 2; (* no dynamic loading of service providers *)
      serviceNotLoaded* = 3; (* interface procedure returned FALSE *)
      errorcodes* = 4;
   TYPE
      ErrorEvent* = POINTER TO ErrorEventRec;
      ErrorEventRec* =
	 RECORD
	    (Events.EventRec)
	    errorcode*: SHORTINT;
	    module*: Events.Message; (* module or service name *)
	    for*: Events.Message; (* type name for serviceNotLoaded *)
	 END;
   VAR
      errormsg*: ARRAY errorcodes OF Events.Message;
      error*: Events.EventType;

   VAR
      loadif: Interface; loadcaps: CapabilitySet;

   (* commented out because Loader must not import Streams, Errors
      and Strings to avoid reference cycles

   PROCEDURE WriteErrorEvent(s: Streams.Stream; event: Events.Event);

      PROCEDURE WriteString(string: ARRAY OF CHAR);
      BEGIN
	 IF ~Streams.WritePart(s, string, 0, Strings.Len(string)) THEN END;
      END WriteString;

      PROCEDURE WriteChar(ch: CHAR);
      BEGIN
	 IF ~Streams.WriteByte(s, ch) THEN END;
      END WriteChar;

   BEGIN
      WITH event: ErrorEvent DO
	 WriteChar(ASCII.quote);
	 WriteString(event.module);
	 WriteChar(ASCII.quote);
	 IF event.for # "" THEN
	    WriteString(" for ");
	    WriteChar(ASCII.quote);
	    WriteString(event.for);
	    WriteChar(ASCII.quote);
	 END;
	 WriteString(": ");
	 WriteString(event.message);
      END;
   END WriteErrorEvent;

   *)

   PROCEDURE InitErrorHandling;
   BEGIN
      Events.Define(error);
      Events.SetPriority(error, Priorities.liberrors);
      Events.Ignore(error);
      (* Errors.AssignWriteProcedure(error, WriteErrorEvent); *)
      errormsg[noInterface] := "Loader.SetInterface has not been called yet";
      errormsg[moduleNotLoaded] := "module cannot be loaded";
      errormsg[servicesNotSupported] :=
	 "dynamic loading of service providers is not supported";
      errormsg[serviceNotLoaded] :=
	 "serving module cannot be loaded";
   END InitErrorHandling;

   PROCEDURE SetInterface*(if: Interface; caps: CapabilitySet);
   BEGIN
      loadif := if; loadcaps := caps;
   END SetInterface;

   PROCEDURE Load*(module: ARRAY OF CHAR;
		  errors: RelatedEvents.Object) : BOOLEAN;

      PROCEDURE Error(errorcode: SHORTINT);
	 VAR
	    event: ErrorEvent;
      BEGIN
	 NEW(event);
	 event.type := error;
	 event.message := errormsg[errorcode];
	 event.errorcode := errorcode;
	 COPY(module, event.module);
	 event.for[0] := 0X;
	 RelatedEvents.Raise(errors, event);
	 Events.Raise(event);
      END Error;

   BEGIN
      IF loadif = NIL THEN
	 Error(noInterface); RETURN FALSE
      ELSE
	 IF ~loadif.load(module, errors) THEN
	    Error(moduleNotLoaded); RETURN FALSE
	 END;
	 RETURN TRUE
      END;
   END Load;

   PROCEDURE LoadService*(service, for: ARRAY OF CHAR;
			 errors: RelatedEvents.Object) : BOOLEAN;

      PROCEDURE Error(errorcode: SHORTINT);
	 VAR
	    event: ErrorEvent;
      BEGIN
	 NEW(event);
	 event.type := error;
	 event.message := errormsg[errorcode];
	 event.errorcode := errorcode;
	 COPY(service, event.module);
	 COPY(for, event.for);
	 RelatedEvents.Raise(errors, event);
	 Events.Raise(event);
      END Error;

   BEGIN
      IF loadif = NIL THEN
	 Error(noInterface); RETURN FALSE
      ELSIF ~(loadService IN loadcaps) THEN
	 Error(servicesNotSupported); RETURN FALSE
      ELSIF ~loadif.loadService(service, for, errors) THEN
	 Error(serviceNotLoaded); RETURN FALSE
      ELSE
	 RETURN TRUE
      END;
   END LoadService;

   (* === support of Services =========================================== *)

   PROCEDURE LService(service, for: ARRAY OF CHAR) : BOOLEAN;
   BEGIN
      RETURN LoadService(service, for, RelatedEvents.null)
   END LService;

   PROCEDURE LModule(module: ARRAY OF CHAR) : BOOLEAN;
   BEGIN
      RETURN Load(module, RelatedEvents.null)
   END LModule;

   PROCEDURE InitServices;
      VAR
	 if: Services.LoaderInterface;
   BEGIN
      NEW(if);
      if.loadService := LService;
      if.loadModule := LModule;
      Services.InitLoader(if);
   END InitServices;

BEGIN
   loadif := NIL; loadcaps := {};
   InitErrorHandling;
   InitServices;
END ulmLoader.
