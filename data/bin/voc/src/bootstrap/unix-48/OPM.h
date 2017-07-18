/* voc 2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8. xtspaSF */

#ifndef OPM__h
#define OPM__h

#include "SYSTEM.h"


import CHAR OPM_Model[10];
import INT16 OPM_AddressSize, OPM_Alignment;
import UINT32 OPM_GlobalOptions, OPM_Options;
import INT16 OPM_ShortintSize, OPM_IntegerSize, OPM_LongintSize;
import INT64 OPM_MaxIndex;
import LONGREAL OPM_MinReal, OPM_MaxReal, OPM_MinLReal, OPM_MaxLReal;
import BOOLEAN OPM_noerr;
import INT32 OPM_curpos, OPM_errpos, OPM_breakpc;
import INT16 OPM_currFile, OPM_level, OPM_pc, OPM_entno;
import CHAR OPM_modName[32];
import CHAR OPM_objname[64];
import CHAR OPM_InstallDir[1024];
import CHAR OPM_ResourceDir[1024];


import void OPM_CloseFiles (void);
import void OPM_CloseOldSym (void);
import void OPM_DeleteObj (CHAR *modulename, ADDRESS modulename__len);
import void OPM_DeleteSym (CHAR *modulename, ADDRESS modulename__len);
import void OPM_FPrint (INT32 *fp, INT64 val);
import void OPM_FPrintLReal (INT32 *fp, LONGREAL val);
import void OPM_FPrintReal (INT32 *fp, REAL val);
import void OPM_FPrintSet (INT32 *fp, UINT64 val);
import void OPM_Get (CHAR *ch);
import void OPM_Init (BOOLEAN *done);
import void OPM_InitOptions (void);
import INT16 OPM_Integer (INT64 n);
import void OPM_LogCompiling (CHAR *modname, ADDRESS modname__len);
import void OPM_LogVT100 (CHAR *vt100code, ADDRESS vt100code__len);
import void OPM_LogW (CHAR ch);
import void OPM_LogWLn (void);
import void OPM_LogWNum (INT64 i, INT64 len);
import void OPM_LogWStr (CHAR *s, ADDRESS s__len);
import INT32 OPM_Longint (INT64 n);
import void OPM_Mark (INT16 n, INT32 pos);
import void OPM_NewSym (CHAR *modName, ADDRESS modName__len);
import void OPM_OldSym (CHAR *modName, ADDRESS modName__len, BOOLEAN *done);
import void OPM_OpenFiles (CHAR *moduleName, ADDRESS moduleName__len);
import BOOLEAN OPM_OpenPar (void);
import void OPM_RegisterNewSym (void);
import INT64 OPM_SignedMaximum (INT32 bytecount);
import INT64 OPM_SignedMinimum (INT32 bytecount);
import void OPM_SymRCh (CHAR *ch);
import INT32 OPM_SymRInt (void);
import INT64 OPM_SymRInt64 (void);
import void OPM_SymRLReal (LONGREAL *lr);
import void OPM_SymRReal (REAL *r);
import void OPM_SymRSet (UINT64 *s);
import void OPM_SymWCh (CHAR ch);
import void OPM_SymWInt (INT64 i);
import void OPM_SymWLReal (LONGREAL lr);
import void OPM_SymWReal (REAL r);
import void OPM_SymWSet (UINT64 s);
import void OPM_Write (CHAR ch);
import void OPM_WriteHex (INT64 i);
import void OPM_WriteInt (INT64 i);
import void OPM_WriteLn (void);
import void OPM_WriteReal (LONGREAL r, CHAR suffx);
import void OPM_WriteString (CHAR *s, ADDRESS s__len);
import void OPM_WriteStringVar (CHAR *s, ADDRESS s__len);
import BOOLEAN OPM_eofSF (void);
import void OPM_err (INT16 n);
import void *OPM__init(void);


#endif // OPM
