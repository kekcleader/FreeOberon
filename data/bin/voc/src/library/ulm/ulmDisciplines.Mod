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
  $Id: Disciplines.om,v 1.1 1994/02/22 20:07:03 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Disciplines.om,v $
  Revision 1.1  1994/02/22  20:07:03  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 5/91
  ----------------------------------------------------------------------------
*)

MODULE ulmDisciplines;

  (* Disciplines allows to attach additional data structures to
    abstract datatypes like Streams;
    these added data structures permit to parametrize operations
    which are provided by other modules (e.g. Read or Write for Streams)
  *)

  IMPORT Objects := ulmObjects;

  TYPE
    Identifier* = LONGINT;

    Discipline* = POINTER TO DisciplineRec;
    DisciplineRec* =
      RECORD
        (Objects.ObjectRec)
        id*: Identifier; (* should be unique for all types of disciplines *)
      END;

    DisciplineList = POINTER TO DisciplineListRec;
    DisciplineListRec =
      RECORD
        discipline: Discipline;
        id: Identifier; (* copied from discipline.id *)
        next: DisciplineList;
      END;

    Object* = POINTER TO ObjectRec;
    ObjectRec* =
      RECORD
        (Objects.ObjectRec)
        (* private part *)
        list: DisciplineList; (* set of disciplines *)
      END;

  VAR
    unique: Identifier;

  PROCEDURE Unique*() : Identifier;
    (* returns a unique identifier;
      this procedure should be called during initialization by
      all modules defining a discipline type
    *)
  BEGIN
    INC(unique);
    RETURN unique
  END Unique;

  PROCEDURE Remove*(object: Object; id: Identifier);
    (* remove the discipline with the given id from object, if it exists *)
    VAR
      prev, dl: DisciplineList;
  BEGIN
    prev := NIL;
    dl := object.list;
    WHILE (dl # NIL) & (dl.id # id) DO
      prev := dl; dl := dl.next;
    END;
    IF dl # NIL THEN
      IF prev = NIL THEN
        object.list := dl.next;
      ELSE
        prev.next := dl.next;
      END;
    END;
  END Remove;

  PROCEDURE Add*(object: Object; discipline: Discipline);
    (* adds a new discipline to the given object;
      if already a discipline with the same identifier exist
      it is deleted first
    *)
    VAR
      dl: DisciplineList;
  BEGIN
    dl := object.list;
    WHILE (dl # NIL) & (dl.id # discipline.id) DO
      dl := dl.next;
    END;
    IF dl = NIL THEN
      NEW(dl);
      dl.id := discipline.id;
      dl.next := object.list;
      object.list := dl;
    END;
    dl.discipline := discipline;
  END Add;

  PROCEDURE Seek*(object: Object; id: Identifier;
            VAR discipline: Discipline) : BOOLEAN;
    (* returns TRUE if a discipline with the given id is found *)
    VAR
      dl: DisciplineList;
  BEGIN
    dl := object.list;
    WHILE (dl # NIL) & (dl.id # id) DO
      dl := dl.next;
    END;
    IF dl # NIL THEN
      discipline := dl.discipline;
    ELSE
      discipline := NIL;
    END;
    RETURN discipline # NIL
  END Seek;

BEGIN
  unique := 0;
END ulmDisciplines.
