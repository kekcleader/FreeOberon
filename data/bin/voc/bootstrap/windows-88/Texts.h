/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#ifndef Texts__h
#define Texts__h

#include "SYSTEM.h"
#include "Files.h"

typedef
	struct Texts_BufDesc {
		INT32 len;
		INT64 _prvt0;
	} Texts_BufDesc;

typedef
	Texts_BufDesc *Texts_Buffer;

typedef
	struct Texts_ElemMsg {
		char _prvt0[1];
	} Texts_ElemMsg;

typedef
	struct Texts_ElemDesc *Texts_Elem;

typedef
	struct Texts_CopyMsg { /* Texts_ElemMsg */
		Texts_Elem e;
	} Texts_CopyMsg;

typedef
	struct Texts_RunDesc {
		INT64 _prvt0;
		char _prvt1[27];
	} Texts_RunDesc;

typedef
	void (*Texts_Handler)(Texts_Elem, Texts_ElemMsg*, ADDRESS *);

typedef
	struct Texts_ElemDesc {
		INT64 _prvt0;
		char _prvt1[28];
		INT32 W, H;
		Texts_Handler handle;
		char _prvt2[8];
	} Texts_ElemDesc;

typedef
	struct Texts_FileMsg { /* Texts_ElemMsg */
		INT16 id;
		INT32 pos;
		Files_Rider r;
	} Texts_FileMsg;

typedef
	struct Texts_FontDesc {
		char _prvt0[32];
	} Texts_FontDesc;

typedef
	Texts_FontDesc *Texts_FontsFont;

typedef
	struct Texts_IdentifyMsg { /* Texts_ElemMsg */
		CHAR mod[32], proc[32];
	} Texts_IdentifyMsg;

typedef
	struct Texts_TextDesc *Texts_Text;

typedef
	void (*Texts_Notifier)(Texts_Text, INT16, INT32, INT32);

typedef
	struct Texts_Reader {
		BOOLEAN eot;
		Texts_FontsFont fnt;
		INT8 col, voff;
		Texts_Elem elem;
		char _prvt0[40];
	} Texts_Reader;

typedef
	struct Texts_Scanner { /* Texts_Reader */
		BOOLEAN eot;
		Texts_FontsFont fnt;
		INT8 col, voff;
		Texts_Elem elem;
		char _prvt0[40];
		CHAR nextCh;
		INT16 line, class;
		INT32 i;
		REAL x;
		LONGREAL y;
		CHAR c;
		INT8 len;
		CHAR s[64];
	} Texts_Scanner;

typedef
	struct Texts_TextDesc {
		INT32 len;
		Texts_Notifier notify;
		char _prvt0[20];
	} Texts_TextDesc;

typedef
	struct Texts_Writer {
		Texts_Buffer buf;
		Texts_FontsFont fnt;
		INT8 col, voff;
		char _prvt0[38];
	} Texts_Writer;


import Texts_Elem Texts_new;

import ADDRESS *Texts_FontDesc__typ;
import ADDRESS *Texts_RunDesc__typ;
import ADDRESS *Texts_ElemMsg__typ;
import ADDRESS *Texts_ElemDesc__typ;
import ADDRESS *Texts_FileMsg__typ;
import ADDRESS *Texts_CopyMsg__typ;
import ADDRESS *Texts_IdentifyMsg__typ;
import ADDRESS *Texts_BufDesc__typ;
import ADDRESS *Texts_TextDesc__typ;
import ADDRESS *Texts_Reader__typ;
import ADDRESS *Texts_Scanner__typ;
import ADDRESS *Texts_Writer__typ;

import void Texts_Append (Texts_Text T, Texts_Buffer B);
import void Texts_ChangeLooks (Texts_Text T, INT32 beg, INT32 end, UINT32 sel, Texts_FontsFont fnt, INT8 col, INT8 voff);
import void Texts_Close (Texts_Text T, CHAR *name, ADDRESS name__len);
import void Texts_Copy (Texts_Buffer SB, Texts_Buffer DB);
import void Texts_CopyElem (Texts_Elem SE, Texts_Elem DE);
import void Texts_Delete (Texts_Text T, INT32 beg, INT32 end);
import Texts_Text Texts_ElemBase (Texts_Elem E);
import INT32 Texts_ElemPos (Texts_Elem E);
import void Texts_Insert (Texts_Text T, INT32 pos, Texts_Buffer B);
import void Texts_Load (Files_Rider *r, ADDRESS *r__typ, Texts_Text T);
import void Texts_Open (Texts_Text T, CHAR *name, ADDRESS name__len);
import void Texts_OpenBuf (Texts_Buffer B);
import void Texts_OpenReader (Texts_Reader *R, ADDRESS *R__typ, Texts_Text T, INT32 pos);
import void Texts_OpenScanner (Texts_Scanner *S, ADDRESS *S__typ, Texts_Text T, INT32 pos);
import void Texts_OpenWriter (Texts_Writer *W, ADDRESS *W__typ);
import INT32 Texts_Pos (Texts_Reader *R, ADDRESS *R__typ);
import void Texts_Read (Texts_Reader *R, ADDRESS *R__typ, CHAR *ch);
import void Texts_ReadElem (Texts_Reader *R, ADDRESS *R__typ);
import void Texts_ReadPrevElem (Texts_Reader *R, ADDRESS *R__typ);
import void Texts_Recall (Texts_Buffer *B);
import void Texts_Save (Texts_Text T, INT32 beg, INT32 end, Texts_Buffer B);
import void Texts_Scan (Texts_Scanner *S, ADDRESS *S__typ);
import void Texts_SetColor (Texts_Writer *W, ADDRESS *W__typ, INT8 col);
import void Texts_SetFont (Texts_Writer *W, ADDRESS *W__typ, Texts_FontsFont fnt);
import void Texts_SetOffset (Texts_Writer *W, ADDRESS *W__typ, INT8 voff);
import void Texts_Store (Files_Rider *r, ADDRESS *r__typ, Texts_Text T);
import void Texts_Write (Texts_Writer *W, ADDRESS *W__typ, CHAR ch);
import void Texts_WriteDate (Texts_Writer *W, ADDRESS *W__typ, INT32 t, INT32 d);
import void Texts_WriteElem (Texts_Writer *W, ADDRESS *W__typ, Texts_Elem e);
import void Texts_WriteHex (Texts_Writer *W, ADDRESS *W__typ, INT32 x);
import void Texts_WriteInt (Texts_Writer *W, ADDRESS *W__typ, INT64 x, INT64 n);
import void Texts_WriteLn (Texts_Writer *W, ADDRESS *W__typ);
import void Texts_WriteLongReal (Texts_Writer *W, ADDRESS *W__typ, LONGREAL x, INT16 n);
import void Texts_WriteLongRealHex (Texts_Writer *W, ADDRESS *W__typ, LONGREAL x);
import void Texts_WriteReal (Texts_Writer *W, ADDRESS *W__typ, REAL x, INT16 n);
import void Texts_WriteRealFix (Texts_Writer *W, ADDRESS *W__typ, REAL x, INT16 n, INT16 k);
import void Texts_WriteRealHex (Texts_Writer *W, ADDRESS *W__typ, REAL x);
import void Texts_WriteString (Texts_Writer *W, ADDRESS *W__typ, CHAR *s, ADDRESS s__len);
import void *Texts__init(void);


#endif // Texts
