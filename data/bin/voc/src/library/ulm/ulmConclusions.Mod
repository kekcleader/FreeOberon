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
   $Id: Conclusions.om,v 1.2 1994/07/05 12:50:01 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Conclusions.om,v $
   Revision 1.2  1994/07/05 12:50:01  borchert
   formatting of error messages depends now on the indentation width
   of StreamDisciplines

   Revision 1.1  1994/02/23  07:46:17  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 11/91
   ----------------------------------------------------------------------------
*)

MODULE ulmConclusions;

   (* convert errors and events into conclusions,
      i.e. a final message and reaction
   *)

   IMPORT Errors := ulmErrors, Events := ulmEvents, Process := ulmProcess, RelatedEvents := ulmRelatedEvents, StreamDisciplines := ulmStreamDisciplines,
      Streams := ulmStreams, Strings := ulmStrings, Write := ulmWrite, Types := ulmTypes;

   VAR
      handlerSet*: Errors.HandlerSet;
      errors*: Types.Int32; (* number of errors *)
      fatalcode*: Types.Int32; (* exit code on fatal events *)

      (* private variables *)
      cmdName: Process.Name; (* should be sufficient for a base name *)
      cmdNameLen: Types.Int32; (* Strings.Len(cmdName) *)

   (* private procedures *)

   PROCEDURE GeneralHandler(event: Events.Event; kind: Errors.Kind);
      VAR
	 width: Types.Int32;
   BEGIN
      IF event # NIL THEN
	 Write.IndentS(Streams.stderr);
	 Write.StringS(Streams.stderr, cmdName);
	 Write.StringS(Streams.stderr, ": ");
	 width := SHORT(Strings.Len(cmdName) + 2);
	 StreamDisciplines.IncrIndentationWidth(Streams.stderr, width);
	 IF kind # Errors.message THEN
	    Write.StringS(Streams.stderr, Errors.kindText[kind]);
	    Write.StringS(Streams.stderr, ": ");
	 END;
	 Errors.Write(Streams.stderr, event); Write.LnS(Streams.stderr);
	 StreamDisciplines.IncrIndentationWidth(Streams.stderr, -width);
      END;
      CASE kind OF
      | Errors.error:   INC(errors);
      | Errors.fatal:   Process.Exit(fatalcode);
      | Errors.bug:     Process.Abort;
      ELSE
	 (* no further actions *)
      END;
   END GeneralHandler;

   PROCEDURE AbortHandler(event: Events.Event);
   BEGIN
      GeneralHandler(event, Errors.bug);
   END AbortHandler;

   PROCEDURE Init;
      VAR
	 messageKind: Errors.Kind;
   BEGIN
      fatalcode := 1;
      errors := 0;

      cmdName := Process.name;
      cmdNameLen := SHORT(Strings.Len(cmdName));

      messageKind := 0;
      Errors.CreateHandlerSet(handlerSet);
      WHILE messageKind < Errors.nkinds DO
	 Errors.InstallHandler(handlerSet, messageKind, GeneralHandler);
	 INC(messageKind);
      END;
      Events.AbortHandler(AbortHandler);
   END Init;

   (* public procedures *)

   PROCEDURE CatchEvent*(type: Events.EventType; kind: Errors.Kind);
   BEGIN
      Errors.CatchEvent(handlerSet, kind, type);
   END CatchEvent;

   PROCEDURE ConcludeS*(s: Streams.Stream;
		       object: RelatedEvents.Object; kind: Errors.Kind;
		       text: ARRAY OF CHAR);
      VAR
	 queue: RelatedEvents.Queue;
	 width: Types.Int32;

      PROCEDURE ReverseQueue(VAR queue: RelatedEvents.Queue);
	 VAR
	    ptr, prev, next: RelatedEvents.Queue;
      BEGIN
	 ptr := queue; prev := NIL;
	 WHILE ptr # NIL DO
	    next := ptr.next;
	    ptr.next := prev;
	    prev := ptr;
	    ptr := next;
	 END;
	 queue := prev;
      END ReverseQueue;

   BEGIN
      RelatedEvents.GetQueue(object, queue);
      Write.IndentS(s);
      Write.StringS(s, cmdName); Write.StringS(s, ": ");
      IF kind # Errors.message THEN
	 Write.StringS(s, Errors.kindText[kind]); Write.StringS(s, ": ");
      END;
      IF text # "" THEN
	 Write.StringS(s, text); Write.StringS(s, ": ");
      END;
      IF queue = NIL THEN
	 Write.StringS(s, "*no error messages found*"); Write.LnS(s);
      ELSE
	 width := cmdNameLen + (* ": " *) 2;
	 StreamDisciplines.IncrIndentationWidth(s, width);
	 (* convert FIFO into LIFO *)
	 ReverseQueue(queue);
	 LOOP
	    Errors.Write(s, queue.event); Write.LnS(s);
	    queue := queue.next;
	    (**)IF queue = NIL THEN EXIT END;
	    Write.IndentS(s);
	 END;
	 StreamDisciplines.IncrIndentationWidth(s, -width);
      END;
      GeneralHandler(NIL, kind);
   END ConcludeS;

   PROCEDURE Conclude*(object: RelatedEvents.Object; kind: Errors.Kind;
		      text: ARRAY OF CHAR);
   BEGIN
      ConcludeS(Streams.stderr, object, kind, text);
   END Conclude;

BEGIN
   Init;
END ulmConclusions.
