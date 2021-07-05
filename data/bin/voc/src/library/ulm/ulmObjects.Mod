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
   $Id: Objects.om,v 1.1 1994/02/22 20:08:53 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Objects.om,v $
   Revision 1.1  1994/02/22  20:08:53  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 6/89
   ----------------------------------------------------------------------------
*)

MODULE ulmObjects;

   (* common base of all record definitions of the library *)

   TYPE
      Object* = POINTER TO ObjectRec;
      ObjectRec* = RECORD END;

END ulmObjects.
