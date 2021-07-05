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
   $Id: BlockCipher.om,v 1.1 1997/04/02 11:52:59 borchert Exp borchert $
   ----------------------------------------------------------------------------
   $Log: BlockCipher.om,v $
   Revision 1.1  1997/04/02  11:52:59  borchert
   Initial revision

   ----------------------------------------------------------------------------
*)

MODULE ulmBlockCiphers; (* Michael Szczuka *)

   (* abstraction for the use of block ciphers *)

   IMPORT Ciphers := ulmCiphers, NetIO := ulmNetIO, PersistentObjects := ulmPersistentObjects, Services := ulmServices, Streams := ulmStreams, Types := ulmTypes;

   TYPE 
      Cipher* = POINTER TO CipherRec;

      CipherRec* = RECORD
	 (Ciphers.CipherRec)
	 (* private *)
	 inLength: Types.Int32;
	 outLength: Types.Int32;
      END;

   VAR
      blockCipherType : Services.Type;
      if : PersistentObjects.Interface;

   PROCEDURE Init* (key: Cipher; if: Ciphers.Interface; 
		   inLength, outLength: Types.Int32);
      (* init a block cipher with its special interface *)
   BEGIN
      Ciphers.Init(key, if);
      ASSERT(inLength > 0);
      ASSERT(outLength > 0);
      key.inLength := inLength;
      key.outLength := outLength;
   END Init;

   PROCEDURE GetInLength* (key: Cipher) : Types.Int32;
      (* returns the input block length of a block cipher *)
   BEGIN
      RETURN key.inLength;
   END GetInLength;

   PROCEDURE GetOutLength* (key: Cipher) : Types.Int32;
      (* returns the output block length of a block cipher *)
   BEGIN
      RETURN key.outLength;
   END GetOutLength;

   PROCEDURE EncryptBlock* (in: Streams.Stream; key: Cipher; 
			   out: Streams.Stream) : BOOLEAN;
      VAR
	 length : Types.Int32;
   BEGIN
      length := GetInLength(key);
      RETURN Ciphers.EncryptPart(in, key, length, out);
   END EncryptBlock;

   PROCEDURE DecryptBlock* (in: Streams.Stream; key: Cipher; 
			   out: Streams.Stream) : BOOLEAN;
      VAR
	 length : Types.Int32;
   BEGIN
      length := GetOutLength(key);
      RETURN Ciphers.DecryptPart(in, key, length, out);
   END DecryptBlock;

   PROCEDURE Create(VAR obj: PersistentObjects.Object);
      VAR
	 key : Cipher;
   BEGIN
      NEW(key);   
      PersistentObjects.Init(key, blockCipherType);
      obj := key;
   END Create;

   PROCEDURE Write(s: Streams.Stream; obj: PersistentObjects.Object) : BOOLEAN;
   BEGIN
      WITH obj:Cipher DO 
	 RETURN NetIO.WriteInteger(s, obj.inLength) & 
		NetIO.WriteInteger(s, obj.outLength); 
      END;
   END Write;

   PROCEDURE Read(s: Streams.Stream; obj: PersistentObjects.Object) : BOOLEAN;
   BEGIN
      WITH obj:Cipher DO 
	 RETURN NetIO.ReadInteger(s, obj.inLength) & 
		NetIO.ReadInteger(s, obj.outLength); 
      END;
   END Read;

BEGIN
   NEW(if);
   if.create := Create; 
   if.write := Write;
   if.read := Read;
   if.createAndRead := NIL;
   PersistentObjects.RegisterType(blockCipherType, "BlockCiphers.Cipher",
	"Ciphers.Cipher", if);
END ulmBlockCiphers.
