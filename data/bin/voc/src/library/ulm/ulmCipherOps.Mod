(* Ulm's Oberon Library
  Copyright (C) 1989-1997 by University of Ulm, SAI, D-89069 Ulm, Germany
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
  $Id: CipherOps.om,v 1.1 1997/04/02 11:53:20 borchert Exp borchert $
  ----------------------------------------------------------------------------
  $Log: CipherOps.om,v $
  Revision 1.1  1997/04/02  11:53:20  borchert
  Initial revision

  ----------------------------------------------------------------------------
*)

MODULE ulmCipherOps; (* Michael Szczuka *)

  (* useful functions for stream ciphers *)

  IMPORT Streams := ulmStreams, SYS := SYSTEM, Write := ulmWrite, Types := ulmTypes;

  PROCEDURE XorByte* (b1, b2: SYS.BYTE) : SYS.BYTE;
    (* adds two bytes bitwise modulo 2 *)
  BEGIN
  (*RETURN SYS.VAL(SYS.BYTE, SYS.VAL(Types.Set, LONG(b1)) / SYS.VAL(Types.Set, LONG(b2)))*)
    RETURN SYS.VAL(SYS.BYTE, SYS.VAL(Types.Set, LONG(LONG(SYS.VAL(Types.Int8, b1))))
                           / SYS.VAL(Types.Set, LONG(LONG(SYS.VAL(Types.Int8, b2)))))
  END XorByte;

  PROCEDURE XorStream* (in1, in2, out: Streams.Stream;
                length: Types.Int32) : BOOLEAN;
    (* adds two streams bitwise modulo 2; restricted to length bytes *)
    VAR
      b1, b2, res : SYS.BYTE;
      wholeStream : BOOLEAN;
  BEGIN
    IF length < 0 THEN
      wholeStream := TRUE;
    ELSE
      wholeStream := FALSE;
    END;
    WHILE wholeStream OR (length > 0) DO
      IF Streams.ReadByte(in1, b1) & Streams.ReadByte(in2, b2) THEN
        res := XorByte(b1, b2);
        IF ~Streams.WriteByte(out, res) THEN
          RETURN FALSE
        END;
      ELSE
        RETURN wholeStream
      END;
      DEC(length);
    END;
    RETURN TRUE
  END XorStream;

END ulmCipherOps.
