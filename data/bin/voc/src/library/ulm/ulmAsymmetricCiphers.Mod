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
   $Id: AsymmetricC.om,v 1.1 1997/04/02 11:52:05 borchert Exp borchert $
   ----------------------------------------------------------------------------
   $Log: AsymmetricC.om,v $
   Revision 1.1  1997/04/02  11:52:05  borchert
   Initial revision

   ----------------------------------------------------------------------------
*)

MODULE ulmAsymmetricCiphers; (* Michael Szczuka *)

   (* abstraction for the use of public key ciphers *)

   IMPORT BlockCiphers := ulmBlockCiphers, Ciphers := ulmCiphers, NetIO := ulmNetIO, PersistentObjects := ulmPersistentObjects, Services := ulmServices, Streams := ulmStreams, Types := ulmTypes;

   CONST
      composed* = 0; isPrivateKey* = 1;

   TYPE 
      CapabilitySet* = Types.Set;

   TYPE
      Cipher* = POINTER TO CipherRec;
      SplitProc* = PROCEDURE (VAR public: Cipher; key: Cipher);
      RandomStreamProc* = PROCEDURE (s: Streams.Stream);

      Interface* = POINTER TO InterfaceRec;
      InterfaceRec* = RECORD
	 (Ciphers.InterfaceRec)
	 (* public *)
	 compencrypt* : Ciphers.CryptProc;
	 split* : SplitProc;
	 randomStream* : RandomStreamProc;
      END;

      CipherRec* = RECORD
	 (BlockCiphers.CipherRec)
	 (* private *)
	 cap : CapabilitySet;
	 asymIf : Interface;
      END;

   VAR
      asymmetricCipherType : Services.Type;
      if : PersistentObjects.Interface;

   (* need to have this in case anyone wants to decrypt something with
      a public cipher ... *)
   PROCEDURE Identity(in: Streams.Stream; key: Ciphers.Cipher;
		      length: Types.Int32; out: Streams.Stream) : BOOLEAN;
   BEGIN
      RETURN Streams.Copy(in, out, length);
   END Identity;

   PROCEDURE Init* (key: Cipher; if: Interface; 
		   cap: CapabilitySet; inLength, outLength: Types.Int32);
   BEGIN
      IF if.decrypt = NIL THEN
	 (* decrypt is not defined, so we have only the public part of a cipher;
	    we can use the identity instead of a decrypting function
	    in this case
	 *)
	 if.decrypt := Identity;
      END;
      BlockCiphers.Init(key, if, inLength, outLength);
      key.cap := cap;
      key.asymIf := if;
      IF (key.asymIf.compencrypt = NIL) OR ~(composed IN cap) THEN
      (* so the cipher's composed function is not defined; therefor it must be
	 the identical function *)
	 key.asymIf.compencrypt := Identity;
      END;
   END Init;

   PROCEDURE Capabilities* (key: Cipher) : CapabilitySet;
   BEGIN
      RETURN key.cap;
   END Capabilities;

   PROCEDURE IsPublicKey* (key: Cipher) : BOOLEAN;
   BEGIN
      RETURN ~(isPrivateKey IN key.cap);
   END IsPublicKey;

   PROCEDURE Split* (VAR public: Cipher; key: Cipher);
   BEGIN
      IF IsPublicKey(key) THEN
      (* trying to extract a public part from a key that already IS a public 
	 cipher? well, if you really want to ... *)
	 public := key;
	 RETURN;
      END;
      key.asymIf.split(public, key);
      (* define the extracted part as public *)
      public.cap := public.cap - {isPrivateKey};
   END Split;

   (* encrypts a given stream msg with the composed map of the key *)
   PROCEDURE ComposedEncrypt* (in: Streams.Stream; key: Cipher; 
			      out: Streams.Stream) : BOOLEAN;
   BEGIN
      RETURN key.asymIf.compencrypt(in, key, -1, out);
   END ComposedEncrypt;

   PROCEDURE ComposedEncryptPart* (in: Streams.Stream; key: Cipher; 
				  length: Types.Int32;
				  out: Streams.Stream) : BOOLEAN;
   BEGIN
      RETURN key.asymIf.compencrypt(in, key, length, out);
   END ComposedEncryptPart;

   PROCEDURE ComposedEncryptBlock* (in: Streams.Stream; key: Cipher; 
				   out: Streams.Stream) : BOOLEAN;
   VAR
      length : Types.Int32;
   BEGIN
      length := BlockCiphers.GetInLength(key);
      RETURN key.asymIf.compencrypt(in, key, length, out);
   END ComposedEncryptBlock;

   PROCEDURE RandomStream*(s: Streams.Stream; key: Cipher);
   BEGIN
      key.asymIf.randomStream(s);
   END RandomStream;

   PROCEDURE Create (VAR obj: PersistentObjects.Object);
   VAR
      cipher : Cipher;
   BEGIN
      NEW(cipher);   
      PersistentObjects.Init(cipher, asymmetricCipherType);
      obj := cipher;
   END Create;

   PROCEDURE Write (s: Streams.Stream; obj: PersistentObjects.Object) : BOOLEAN;
   BEGIN
      WITH obj:Cipher DO
	 RETURN NetIO.WriteSet(s, obj.cap);
      END;
   END Write;

   PROCEDURE Read (s: Streams.Stream; obj: PersistentObjects.Object) : BOOLEAN;
   BEGIN
      WITH obj:Cipher DO
	 RETURN NetIO.ReadSet(s, obj.cap);
      END;
   END Read;

BEGIN
   NEW(if);
   if.create := Create; if.write := Write; if.read := Read;
   if.createAndRead := NIL;
   PersistentObjects.RegisterType(asymmetricCipherType,
	"AsymmetricCiphers.Cipher", "BlockCiphers.Cipher", if);
END ulmAsymmetricCiphers.
