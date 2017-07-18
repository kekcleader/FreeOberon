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
   $Id: IndirectDis.om,v 1.2 1995/03/17 13:56:51 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: IndirectDis.om,v $
   Revision 1.2  1995/03/17  13:56:51  borchert
   support of Forwarders added

   Revision 1.1  1994/06/27  09:50:43  borchert
   Initial revision

   ----------------------------------------------------------------------------
*)

MODULE ulmIndirectDisciplines;

   IMPORT Disciplines := ulmDisciplines, Forwarders := ulmForwarders, SYSTEM;

   TYPE
      Object* = Disciplines.Object;
      ObjectRec* = Disciplines.ObjectRec;
      Discipline* = Disciplines.Discipline;
      DisciplineRec* = Disciplines.DisciplineRec;
      Identifier* = Disciplines.Identifier;

   TYPE
      IndDiscipline = POINTER TO IndDisciplineRec;
      IndDisciplineRec =
	      RECORD
	         (DisciplineRec)
	         forwardTo: Object;
	      END;

   VAR
      discID: Identifier;

   PROCEDURE Forward*(from, to: Object);
      VAR
	      disc: IndDiscipline;
   BEGIN
      IF to = NIL THEN
	      Disciplines.Remove(from, discID);
      ELSE
	      NEW(disc); disc.id := discID;
	      disc.forwardTo := to;
	      Disciplines.Add(from, disc);
      END;
   END Forward;

   PROCEDURE InternalForward(from, to: Forwarders.Object);
   BEGIN
      Forward(from, to);
   END InternalForward;

   PROCEDURE Add*(object: Object; discipline: Discipline);
      VAR
	      disc: Discipline;
   BEGIN
      WHILE Disciplines.Seek(object, discID, disc) DO
	      object := disc(IndDiscipline).forwardTo;
      END;
      Disciplines.Add(object, discipline);
   END Add;

   PROCEDURE Remove*(object: Object; id: Identifier);
      VAR
	      dummy, disc: Discipline;
   BEGIN
      LOOP
	      IF Disciplines.Seek(object, id, dummy) THEN
	         Disciplines.Remove(object, id);
	         EXIT
	      END;
	      IF ~Disciplines.Seek(object, discID, disc) THEN
	         EXIT
	      END;
	      object := disc(IndDiscipline).forwardTo;
      END;
   END Remove;

   PROCEDURE Seek*(object: Object; id: Identifier;
		             VAR discipline: Discipline) : BOOLEAN;
      VAR
	      disc: Discipline;
   BEGIN
      LOOP
	      IF Disciplines.Seek(object, id, discipline) THEN
	         RETURN TRUE
	      END;
	      IF ~Disciplines.Seek(object, discID, disc) THEN
	         RETURN FALSE
	      END;
	      object := disc(IndDiscipline).forwardTo;
      END;
   END Seek;

   PROCEDURE Unique*() : Identifier;
   BEGIN
      RETURN Disciplines.Unique()
   END Unique;

BEGIN
   discID := Disciplines.Unique();
   Forwarders.Register("", InternalForward);
END ulmIndirectDisciplines.
