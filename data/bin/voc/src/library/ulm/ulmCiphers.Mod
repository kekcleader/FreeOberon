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
   $Id: Ciphers.om,v 1.1 1997/04/02 11:51:15 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Ciphers.om,v $
   Revision 1.1  1997/04/02  11:51:15  borchert
   Initial revision

   ----------------------------------------------------------------------------
*)

(* abstraction for the use of ciphers and cryptographic methods *)
MODULE ulmCiphers;

IMPORT Objects := ulmObjects, PersistentObjects := ulmPersistentObjects, PersistentDisciplines := ulmPersistentDisciplines, Services := ulmServices,
       Streams := ulmStreams, Write := ulmWrite, Types := ulmTypes;

TYPE
   Cipher* = POINTER TO CipherRec;

TYPE
   CryptProc* = PROCEDURE (in: Streams.Stream; key: Cipher;
                          length: Types.Int32; out: Streams.Stream) : BOOLEAN;

TYPE
   Interface* = POINTER TO InterfaceRec;
   InterfaceRec* = RECORD
      (Objects.ObjectRec)
      (* public *)
      encrypt*, decrypt* : CryptProc;
   END;

TYPE
   CipherRec* = RECORD
      (PersistentDisciplines.ObjectRec)
      (* private *)
      if : Interface
   END;

VAR
   cipherType, interfaceType : Services.Type;

PROCEDURE Init*(key: Cipher; if: Interface);
BEGIN
   ASSERT(if # NIL);
   ASSERT(if.encrypt # NIL);
   key.if := if;
END Init;

PROCEDURE Encrypt*(in: Streams.Stream; key: Cipher;
                  out: Streams.Stream) : BOOLEAN;
BEGIN
   RETURN key.if.encrypt(in, key, -1, out);
END Encrypt;

PROCEDURE Decrypt*(in: Streams.Stream; key: Cipher;
                  out: Streams.Stream) : BOOLEAN;
BEGIN
   RETURN key.if.decrypt(in, key, -1, out);
END Decrypt;

PROCEDURE EncryptPart*(in: Streams.Stream; key: Cipher;
                      length: Types.Int32; out: Streams.Stream) : BOOLEAN;
BEGIN
   RETURN key.if.encrypt(in, key, length, out);
END EncryptPart;

PROCEDURE DecryptPart*(in: Streams.Stream; key: Cipher;
                      length: Types.Int32; out: Streams.Stream) : BOOLEAN;
BEGIN
   RETURN key.if.decrypt(in, key, length, out);
END DecryptPart;

BEGIN
   PersistentObjects.RegisterType(cipherType, "Ciphers.Cipher",
      "PersistentDisciplines.Object", NIL);
END ulmCiphers.
