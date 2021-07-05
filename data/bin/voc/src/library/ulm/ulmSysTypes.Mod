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
   $Id: SysTypes.om,v 1.1 1994/02/23 08:01:38 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: SysTypes.om,v $
   Revision 1.1  1994/02/23  08:01:38  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 9/89
   ----------------------------------------------------------------------------
*)

MODULE ulmSysTypes;

   IMPORT Types := ulmTypes, Platform;

   TYPE
      Address* = Types.Address;
      UntracedAddress* = Types.UntracedAddress;
      Count* = Types.Count;
      Size* = Types.Size;
      Byte* = Types.Byte;

      File*   = Platform.FileHandle;
      Offset* = Types.Int32;
      Device* = Types.Int32;
      Inode*  = Types.Int32;
      Time*   = Types.Int32;

      Word*   = Types.Int32; (* must have the size of C's int-type *)

   (* Note: linux supports wait4 but not waitid, i.e. these
    * constants aren't needed. *)
   (*
   CONST
      (* possible values of the idtype parameter (4 bytes),
	 see <sys/procset.h>
      *)
      idPid = 0; (* a process identifier *)
      idPpid = 1; (* a parent process identifier *)
      idPgid = 2; (* a process group (job control group) identifier *)
      idSid = 3; (* a session identifier *)
      idCid = 4; (* a scheduling class identifier *)
      idUid = 5; (* a user identifier *)
      idGid = 6; (* a group identifier *)
      idAll = 7; (* all processes *)
      idLwpid = 8; (* an LWP identifier *)
   TYPE
      IdType = Types.Int32; (* idPid .. idLwpid *)
   *)

END ulmSysTypes.
