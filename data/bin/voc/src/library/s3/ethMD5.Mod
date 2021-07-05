(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethMD5;  (** portable *) (* ejz  *)
  IMPORT SYSTEM;

(* todo. Use fixed size integers and sets. *)

(** The MD5 Message-Digest Algorithm (RFC1321)

The algorithm takes as input a message of arbitrary length and produces
as output a 128-bit "fingerprint" or "message digest" of the input. It is
conjectured that it is computationally infeasible to produce two messages
having the same message digest, or to produce any message having a
given prespecified target message digest. The MD5 algorithm is intended
for digital signature applications, where a large file must be "compressed"
in a secure manner before being encrypted with a private (secret) key
under a public-key cryptosystem such as RSA. *)

  TYPE
    Context*  = POINTER TO ContextDesc;
    ContextDesc = RECORD
      buf: ARRAY 4 OF LONGINT;
      bits: LONGINT;
      in: ARRAY 64 OF CHAR
    END;
    Digest* = ARRAY 16 OF CHAR;

(** Begin an MD5 operation, with a new context. *)
  PROCEDURE New*(): Context;
    VAR cont: Context;
  BEGIN
    NEW(cont);
    cont.buf[0] := 00000000067452301H;
    cont.buf[1] := 0FFFFFFFFEFCDAB89H;
    cont.buf[2] := 0FFFFFFFF98BADCFEH;
    cont.buf[3] := 00000000010325476H;
    cont.bits := 0;
    RETURN cont
  END New;

  PROCEDURE ByteReverse(VAR in: ARRAY OF SYSTEM.BYTE; VAR out: ARRAY OF LONGINT; longs: LONGINT);
    VAR
      adr:   SYSTEM.ADDRESS;
      t, i:  LONGINT;
      bytes: ARRAY 4 OF CHAR;
  BEGIN
    adr := SYSTEM.ADR(in[0]); i := 0;
    WHILE i < longs DO
      SYSTEM.MOVE(adr, SYSTEM.ADR(bytes[0]), 4);
      t := ORD(bytes[3]);
      t := 256*t + ORD(bytes[2]);
      t := 256*t + ORD(bytes[1]);
      t := 256*t + ORD(bytes[0]);
      out[i] := t;
      INC(adr, 4); INC(i)
    END
  END ByteReverse;

  PROCEDURE F1(x, y, z: LONGINT): LONGINT;
  BEGIN
    RETURN SYSTEM.VAL(LONGINT, (SYSTEM.VAL(SET, x)*SYSTEM.VAL(SET, y)) + ((-SYSTEM.VAL(SET, x))*SYSTEM.VAL(SET, z)))
  END F1;

  PROCEDURE F2(x, y, z: LONGINT): LONGINT;
  BEGIN
    RETURN SYSTEM.VAL(LONGINT, (SYSTEM.VAL(SET, x)*SYSTEM.VAL(SET, z)) + (SYSTEM.VAL(SET, y)*(-SYSTEM.VAL(SET, z))))
  END F2;

  PROCEDURE F3(x, y, z: LONGINT): LONGINT;
  BEGIN
    RETURN SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, x) / SYSTEM.VAL(SET, y) / SYSTEM.VAL(SET, z))
  END F3;

  PROCEDURE F4(x, y, z: LONGINT): LONGINT;
  BEGIN
    RETURN SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, y) / (SYSTEM.VAL(SET, x)+(-SYSTEM.VAL(SET, z))))
  END F4;

  PROCEDURE STEP1(VAR w: LONGINT; x, y, z, data, s: LONGINT);
  BEGIN
    w := w+F1(x, y, z)+data;
    w := SYSTEM.ROT(w, s);
    INC(w, x)
  END STEP1;

  PROCEDURE STEP2(VAR w: LONGINT; x, y, z, data, s: LONGINT);
  BEGIN
    w := w+F2(x, y, z)+data;
    w := SYSTEM.ROT(w, s);
    INC(w, x)
  END STEP2;

  PROCEDURE STEP3(VAR w: LONGINT; x, y, z, data, s: LONGINT);
  BEGIN
    w := w+F3(x, y, z)+data;
    w := SYSTEM.ROT(w, s);
    INC(w, x)
  END STEP3;

  PROCEDURE STEP4(VAR w: LONGINT; x, y, z, data, s: LONGINT);
  BEGIN
    w := w+F4(x, y, z)+data;
    w := SYSTEM.ROT(w, s);
    INC(w, x)
  END STEP4;

  PROCEDURE Transform(VAR buf, in: ARRAY OF LONGINT);
    VAR a, b, c, d: LONGINT;
  BEGIN
    a := buf[0]; b := buf[1]; c := buf[2]; d := buf[3];

    STEP1(a, b, c, d, in[0]  + 0FFFFFFFFD76AA478H, 7);
    STEP1(d, a, b, c, in[1]  + 0FFFFFFFFE8C7B756H, 12);
    STEP1(c, d, a, b, in[2]  + 000000000242070DBH, 17);
    STEP1(b, c, d, a, in[3]  + 0FFFFFFFFC1BDCEEEH, 22);
    STEP1(a, b, c, d, in[4]  + 0FFFFFFFFF57C0FAFH, 7);
    STEP1(d, a, b, c, in[5]  + 0000000004787C62AH, 12);
    STEP1(c, d, a, b, in[6]  + 0FFFFFFFFA8304613H, 17);
    STEP1(b, c, d, a, in[7]  + 0FFFFFFFFFD469501H, 22);
    STEP1(a, b, c, d, in[8]  + 000000000698098D8H, 7);
    STEP1(d, a, b, c, in[9]  + 0FFFFFFFF8B44F7AFH, 12);
    STEP1(c, d, a, b, in[10] + 0FFFFFFFFFFFF5BB1H, 17);
    STEP1(b, c, d, a, in[11] + 0FFFFFFFF895CD7BEH, 22);
    STEP1(a, b, c, d, in[12] + 0000000006B901122H, 7);
    STEP1(d, a, b, c, in[13] + 0FFFFFFFFFD987193H, 12);
    STEP1(c, d, a, b, in[14] + 0FFFFFFFFA679438EH, 17);
    STEP1(b, c, d, a, in[15] + 00000000049B40821H, 22);

    STEP2(a, b, c, d, in[1]  + 0FFFFFFFFF61E2562H, 5);
    STEP2(d, a, b, c, in[6]  + 0FFFFFFFFC040B340H, 9);
    STEP2(c, d, a, b, in[11] + 000000000265E5A51H, 14);
    STEP2(b, c, d, a, in[0]  + 0FFFFFFFFE9B6C7AAH, 20);
    STEP2(a, b, c, d, in[5]  + 0FFFFFFFFD62F105DH, 5);
    STEP2(d, a, b, c, in[10] + 00000000002441453H, 9);
    STEP2(c, d, a, b, in[15] + 0FFFFFFFFD8A1E681H, 14);
    STEP2(b, c, d, a, in[4]  + 0FFFFFFFFE7D3FBC8H, 20);
    STEP2(a, b, c, d, in[9]  + 00000000021E1CDE6H, 5);
    STEP2(d, a, b, c, in[14] + 0FFFFFFFFC33707D6H, 9);
    STEP2(c, d, a, b, in[3]  + 0FFFFFFFFF4D50D87H, 14);
    STEP2(b, c, d, a, in[8]  + 000000000455A14EDH, 20);
    STEP2(a, b, c, d, in[13] + 0FFFFFFFFA9E3E905H, 5);
    STEP2(d, a, b, c, in[2]  + 0FFFFFFFFFCEFA3F8H, 9);
    STEP2(c, d, a, b, in[7]  + 000000000676F02D9H, 14);
    STEP2(b, c, d, a, in[12] + 0FFFFFFFF8D2A4C8AH, 20);

    STEP3(a, b, c, d, in[5]  + 0FFFFFFFFFFFA3942H, 4);
    STEP3(d, a, b, c, in[8]  + 0FFFFFFFF8771F681H, 11);
    STEP3(c, d, a, b, in[11] + 0000000006D9D6122H, 16);
    STEP3(b, c, d, a, in[14] + 0FFFFFFFFFDE5380CH, 23);
    STEP3(a, b, c, d, in[1]  + 0FFFFFFFFA4BEEA44H, 4);
    STEP3(d, a, b, c, in[4]  + 0000000004BDECFA9H, 11);
    STEP3(c, d, a, b, in[7]  + 0FFFFFFFFF6BB4B60H, 16);
    STEP3(b, c, d, a, in[10] + 0FFFFFFFFBEBFBC70H, 23);
    STEP3(a, b, c, d, in[13] + 000000000289B7EC6H, 4);
    STEP3(d, a, b, c, in[0]  + 0FFFFFFFFEAA127FAH, 11);
    STEP3(c, d, a, b, in[3]  + 0FFFFFFFFD4EF3085H, 16);
    STEP3(b, c, d, a, in[6]  + 00000000004881D05H, 23);
    STEP3(a, b, c, d, in[9]  + 0FFFFFFFFD9D4D039H, 4);
    STEP3(d, a, b, c, in[12] + 0FFFFFFFFE6DB99E5H, 11);
    STEP3(c, d, a, b, in[15] + 0000000001FA27CF8H, 16);
    STEP3(b, c, d, a, in[2]  + 0FFFFFFFFC4AC5665H, 23);

    STEP4(a, b, c, d, in[0]  + 0FFFFFFFFF4292244H, 6);
    STEP4(d, a, b, c, in[7]  + 000000000432AFF97H, 10);
    STEP4(c, d, a, b, in[14] + 0FFFFFFFFAB9423A7H, 15);
    STEP4(b, c, d, a, in[5]  + 0FFFFFFFFFC93A039H, 21);
    STEP4(a, b, c, d, in[12] + 000000000655B59C3H, 6);
    STEP4(d, a, b, c, in[3]  + 0FFFFFFFF8F0CCC92H, 10);
    STEP4(c, d, a, b, in[10] + 0FFFFFFFFFFEFF47DH, 15);
    STEP4(b, c, d, a, in[1]  + 0FFFFFFFF85845DD1H, 21);
    STEP4(a, b, c, d, in[8]  + 0000000006FA87E4FH, 6);
    STEP4(d, a, b, c, in[15] + 0FFFFFFFFFE2CE6E0H, 10);
    STEP4(c, d, a, b, in[6]  + 0FFFFFFFFA3014314H, 15);
    STEP4(b, c, d, a, in[13] + 0000000004E0811A1H, 21);
    STEP4(a, b, c, d, in[4]  + 0FFFFFFFFF7537E82H, 6);
    STEP4(d, a, b, c, in[11] + 0FFFFFFFFBD3AF235H, 10);
    STEP4(c, d, a, b, in[2]  + 0000000002AD7D2BBH, 15);
    STEP4(b, c, d, a, in[9]  + 0FFFFFFFFEB86D391H, 21);

    INC(buf[0], a); INC(buf[1], b);
    INC(buf[2], c); INC(buf[3], d)
  END Transform;

(** Continues an MD5 message-digest operation, processing another
  message block, and updating the context. *)
  PROCEDURE Write*(context: Context; ch: CHAR);
    VAR
      in: ARRAY 16 OF LONGINT;
      t, len: LONGINT;
  BEGIN
    t := context.bits; len := 1;
    context.bits := t + 8;
    t := (t DIV 8) MOD 64;
    IF t > 0 THEN
      t := 64-t;
      IF 1 < t THEN
        context.in[64-t] := ch;
        RETURN
      END;
      ASSERT(len = 1);
      context.in[64-t] := ch;
      ByteReverse(context.in, in, 16);
      Transform(context.buf, in);
      DEC(len, t)
    END;
    IF len > 0 THEN
      context.in[0] := ch
    END
  END Write;

(** Continues an MD5 message-digest operation, processing another
  message block, and updating the context. *)
  PROCEDURE WriteBytes*(context: Context; VAR buf: ARRAY OF CHAR; len: LONGINT);
    VAR
      in: ARRAY 16 OF LONGINT;
      beg, t: LONGINT;
  BEGIN
    beg := 0; t := context.bits;
    context.bits := t + len*8;
    t := (t DIV 8) MOD 64;
    IF t > 0 THEN
      t := 64-t;
      IF len < t THEN
        SYSTEM.MOVE(SYSTEM.ADR(buf[beg]), SYSTEM.ADR(context.in[64-t]), len);
        RETURN
      END;
      SYSTEM.MOVE(SYSTEM.ADR(buf[beg]), SYSTEM.ADR(context.in[64-t]), t);
      ByteReverse(context.in, in, 16);
      Transform(context.buf, in);
      INC(beg, t); DEC(len, t)
    END;
    WHILE len >= 64 DO
      SYSTEM.MOVE(SYSTEM.ADR(buf[beg]), SYSTEM.ADR(context.in[0]), 64);
      ByteReverse(context.in, in, 16);
      Transform(context.buf, in);
      INC(beg, 64); DEC(len, 64)
    END;
    IF len > 0 THEN
      SYSTEM.MOVE(SYSTEM.ADR(buf[beg]), SYSTEM.ADR(context.in[0]), len)
    END
  END WriteBytes;

(** Ends an MD5 message-digest operation, writing the message digest. *)
  PROCEDURE Close*(context: Context; VAR digest: Digest);
    VAR
      in: ARRAY 16 OF LONGINT;
      beg, i, count: LONGINT;
  BEGIN
    count := (context.bits DIV 8) MOD 64;
    beg := count;
    context.in[beg] := CHR(128); INC(beg);
    count := 64-1-count;
    IF count < 8 THEN
      i := 0;
      WHILE i < count DO
        context.in[beg+i] := 0X; INC(i)
      END;
      ByteReverse(context.in, in, 16);
      Transform(context.buf, in);
      i := 0;
      WHILE i < 56 DO
        context.in[i] := 0X; INC(i)
      END
    ELSE
      i := 0;
      WHILE i < (count-8) DO
        context.in[beg+i] := 0X; INC(i)
      END
    END;
    ByteReverse(context.in, in, 14);
    in[14] := context.bits; in[15] := 0;
    Transform(context.buf, in);
    ByteReverse(context.buf, in, 4);
    SYSTEM.MOVE(SYSTEM.ADR(in[0]), SYSTEM.ADR(digest[0]), 16)
  END Close;

  PROCEDURE HexDigit(i: LONGINT): CHAR;
  BEGIN
    IF i < 10 THEN
      RETURN CHR(ORD("0")+i)
    ELSE
      RETURN CHR(ORD("a")+i-10)
    END
  END HexDigit;

(** Convert the digest into an hexadecimal string. *)
  PROCEDURE ToString*(digest: Digest; VAR str: ARRAY OF CHAR);
    VAR i: LONGINT;
  BEGIN
    FOR i := 0 TO 15 DO
      str[2*i] := HexDigit(ORD(digest[i]) DIV 16);
      str[2*i+1] := HexDigit(ORD(digest[i]) MOD 16)
    END;
    str[32] := 0X
  END ToString;

END ethMD5.
