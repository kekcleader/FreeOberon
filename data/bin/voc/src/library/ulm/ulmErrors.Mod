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
  $Id: Errors.om,v 1.2 1994/07/18 14:16:33 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Errors.om,v $
  Revision 1.2  1994/07/18  14:16:33  borchert
  unused variables of Write (ch & index) removed

  Revision 1.1  1994/02/22  20:07:15  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 11/91
  ----------------------------------------------------------------------------
*)

MODULE ulmErrors;

  (* translate events to errors *)

  IMPORT Disciplines := ulmDisciplines, Events := ulmEvents, Objects := ulmObjects, RelatedEvents := ulmRelatedEvents, Streams := ulmStreams, Strings := ulmStrings,
  SYS := SYSTEM;

  CONST
    (* Kind = (debug, message, warning, error, fatal, bug) *)
    debug* = 0;
    message* = 1;
    warning* = 2;
    error* = 3;
    fatal* = 4;
    bug* = 5;
    nkinds* = 6;
  TYPE
    Kind* = SHORTINT; (* debug..bug *)
  VAR
    kindText*: ARRAY nkinds OF ARRAY 12 OF CHAR;

  TYPE
    Handler* = PROCEDURE (event: Events.Event; kind: Kind);
    HandlerSet* = POINTER TO HandlerSetRec;
    HandlerSetRec* =
      RECORD
        (Disciplines.ObjectRec)
        (* private components *)
        handlerSet: SET; (* set of installed handlers *)
        handler: ARRAY nkinds OF Handler;
      END;

  (* ========== write discipline ========================================= *)
  TYPE
    WriteProcedure* = PROCEDURE (s: Streams.Stream; event: Events.Event);
    WriteDiscipline = POINTER TO WriteDisciplineRec;
    WriteDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        write: WriteProcedure;
      END;
  VAR
    writeDiscId: Disciplines.Identifier;

  (* ========== handler discipline ======================================= *)
  TYPE
    HandlerDiscipline = POINTER TO HandlerDisciplineRec;
    HandlerDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        hs: HandlerSet;
        kind: Kind;
      END;
  VAR
    handlerDiscId: Disciplines.Identifier;

  VAR
    null*: HandlerSet; (* empty handler set *)

  PROCEDURE CreateHandlerSet*(VAR hs: HandlerSet);
  BEGIN
    NEW(hs); hs.handlerSet := {};
  END CreateHandlerSet;

  PROCEDURE InstallHandler*(hs: HandlerSet; kind: Kind; handler: Handler);
  BEGIN
    hs.handler[kind] := handler;
    INCL(hs.handlerSet, kind);
  END InstallHandler;

  PROCEDURE AssignWriteProcedure*(eventType: Events.EventType;
                       write: WriteProcedure);
    VAR
      writeDiscipline: WriteDiscipline;
  BEGIN
    NEW(writeDiscipline);
    writeDiscipline.id := writeDiscId;
    writeDiscipline.write := write;
    Disciplines.Add(eventType, writeDiscipline);
  END AssignWriteProcedure;

  PROCEDURE Write*(s: Streams.Stream; event: Events.Event);
    VAR
      writeDiscipline: Disciplines.Discipline;
  BEGIN
    IF Disciplines.Seek(event.type, writeDiscId, writeDiscipline) THEN
      writeDiscipline(WriteDiscipline).write(s, event);
    ELSE
      IF ~Streams.WritePart(s, event.message, 0,
                            Strings.Len(event.message)) THEN
      END;
    END;
  END Write;

  PROCEDURE GeneralEventHandler(event: Events.Event);
    VAR
      disc:  Disciplines.Discipline;
      hdisc: HandlerDiscipline;
  BEGIN
    IF Disciplines.Seek(event.type, handlerDiscId, disc) THEN
      hdisc := disc(HandlerDiscipline);
      IF hdisc.kind IN hdisc.hs.handlerSet THEN
        hdisc.hs.handler[hdisc.kind](event, hdisc.kind)
      END
    END;
  END GeneralEventHandler;

  PROCEDURE CatchEvent*(hs: HandlerSet; kind: Kind; type: Events.EventType);
    VAR
      handlerDiscipline: HandlerDiscipline;
  BEGIN
    NEW(handlerDiscipline); handlerDiscipline.id := handlerDiscId;
    handlerDiscipline.hs := hs; handlerDiscipline.kind := kind;
    Disciplines.Add(type, handlerDiscipline);
    Events.Handler(type, GeneralEventHandler);
  END CatchEvent;

BEGIN
  writeDiscId := Disciplines.Unique();
  handlerDiscId := Disciplines.Unique();
  CreateHandlerSet(null);
  kindText[debug] := "debug";
  kindText[message] := "message";
  kindText[warning] := "warning";
  kindText[error] := "error";
  kindText[fatal] := "fatal";
  kindText[bug] := "bug";
END ulmErrors.
