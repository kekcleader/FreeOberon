/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#ifndef Files__h
#define Files__h

#include "SYSTEM.h"

typedef
	struct Files_FileDesc *Files_File;

typedef
	struct Files_FileDesc {
		INT32 _prvt0;
		char _prvt1[568];
	} Files_FileDesc;

typedef
	struct Files_Rider {
		INT32 res;
		BOOLEAN eof;
		char _prvt0[15];
	} Files_Rider;


import INT16 Files_MaxPathLength, Files_MaxNameLength;

import ADDRESS *Files_FileDesc__typ;
import ADDRESS *Files_Rider__typ;

import Files_File Files_Base (Files_Rider *r, ADDRESS *r__typ);
import void Files_ChangeDirectory (CHAR *path, ADDRESS path__len, INT16 *res);
import void Files_Close (Files_File f);
import void Files_Delete (CHAR *name, ADDRESS name__len, INT16 *res);
import void Files_GetDate (Files_File f, INT32 *t, INT32 *d);
import void Files_GetName (Files_File f, CHAR *name, ADDRESS name__len);
import INT32 Files_Length (Files_File f);
import Files_File Files_New (CHAR *name, ADDRESS name__len);
import Files_File Files_Old (CHAR *name, ADDRESS name__len);
import INT32 Files_Pos (Files_Rider *r, ADDRESS *r__typ);
import void Files_Purge (Files_File f);
import void Files_Read (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x);
import void Files_ReadBool (Files_Rider *R, ADDRESS *R__typ, BOOLEAN *x);
import void Files_ReadBytes (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x, ADDRESS x__len, INT32 n);
import void Files_ReadInt (Files_Rider *R, ADDRESS *R__typ, INT16 *x);
import void Files_ReadLInt (Files_Rider *R, ADDRESS *R__typ, INT32 *x);
import void Files_ReadLReal (Files_Rider *R, ADDRESS *R__typ, LONGREAL *x);
import void Files_ReadLine (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len);
import void Files_ReadNum (Files_Rider *R, ADDRESS *R__typ, SYSTEM_BYTE *x, ADDRESS x__len);
import void Files_ReadReal (Files_Rider *R, ADDRESS *R__typ, REAL *x);
import void Files_ReadSet (Files_Rider *R, ADDRESS *R__typ, UINT32 *x);
import void Files_ReadString (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len);
import void Files_Register (Files_File f);
import void Files_Rename (CHAR *old, ADDRESS old__len, CHAR *new, ADDRESS new__len, INT16 *res);
import void Files_Set (Files_Rider *r, ADDRESS *r__typ, Files_File f, INT32 pos);
import void Files_SetSearchPath (CHAR *path, ADDRESS path__len);
import void Files_Write (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE x);
import void Files_WriteBool (Files_Rider *R, ADDRESS *R__typ, BOOLEAN x);
import void Files_WriteBytes (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x, ADDRESS x__len, INT32 n);
import void Files_WriteInt (Files_Rider *R, ADDRESS *R__typ, INT16 x);
import void Files_WriteLInt (Files_Rider *R, ADDRESS *R__typ, INT32 x);
import void Files_WriteLReal (Files_Rider *R, ADDRESS *R__typ, LONGREAL x);
import void Files_WriteNum (Files_Rider *R, ADDRESS *R__typ, INT64 x);
import void Files_WriteReal (Files_Rider *R, ADDRESS *R__typ, REAL x);
import void Files_WriteSet (Files_Rider *R, ADDRESS *R__typ, UINT32 x);
import void Files_WriteString (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len);
import void *Files__init(void);


#endif // Files
