/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#ifndef OPT__h
#define OPT__h

#include "SYSTEM.h"
#include "OPS.h"

typedef
	struct OPT_ConstDesc *OPT_Const;

typedef
	OPS_String *OPT_ConstExt;

typedef
	struct OPT_ConstDesc {
		OPT_ConstExt ext;
		INT64 intval;
		INT32 intval2;
		UINT64 setval;
		LONGREAL realval;
	} OPT_ConstDesc;

typedef
	struct OPT_LinkDesc *OPT_Link;

typedef
	struct OPT_LinkDesc {
		OPS_Name name;
		OPT_Link next;
	} OPT_LinkDesc;

typedef
	struct OPT_NodeDesc *OPT_Node;

typedef
	struct OPT_StrDesc *OPT_Struct;

typedef
	struct OPT_ObjDesc *OPT_Object;

typedef
	struct OPT_NodeDesc {
		OPT_Node left, right, link;
		INT8 class, subcl;
		BOOLEAN readonly;
		OPT_Struct typ;
		OPT_Object obj;
		OPT_Const conval;
	} OPT_NodeDesc;

typedef
	struct OPT_ObjDesc {
		OPT_Object left, right, link, scope;
		OPS_Name name;
		BOOLEAN leaf;
		INT8 mode, mnolev, vis, history;
		BOOLEAN used, fpdone;
		INT32 fprint;
		OPT_Struct typ;
		OPT_Const conval;
		INT32 adr, linkadr;
		INT16 x;
	} OPT_ObjDesc;

typedef
	struct OPT_StrDesc {
		INT8 form, comp, mno, extlev;
		INT16 ref, sysflag;
		INT32 n, size, align, txtpos;
		BOOLEAN allocated, pbused, pvused;
		char _prvt0[4];
		INT32 idfp;
		char _prvt1[8];
		OPT_Struct BaseTyp;
		OPT_Object link, strobj;
	} OPT_StrDesc;


import OPT_Object OPT_topScope;
import OPT_Struct OPT_undftyp, OPT_niltyp, OPT_notyp, OPT_bytetyp, OPT_cpbytetyp, OPT_booltyp, OPT_chartyp, OPT_sinttyp, OPT_inttyp, OPT_linttyp, OPT_hinttyp, OPT_int8typ, OPT_int16typ, OPT_int32typ, OPT_int64typ, OPT_settyp, OPT_set32typ, OPT_set64typ, OPT_realtyp, OPT_lrltyp, OPT_stringtyp, OPT_adrtyp, OPT_sysptrtyp;
import OPT_Object OPT_sintobj, OPT_intobj, OPT_lintobj, OPT_setobj;
import INT8 OPT_nofGmod;
import OPT_Object OPT_GlbMod[64];
import OPS_Name OPT_SelfName;
import BOOLEAN OPT_SYSimported;
import OPT_Link OPT_Links;

import ADDRESS *OPT_ConstDesc__typ;
import ADDRESS *OPT_ObjDesc__typ;
import ADDRESS *OPT_StrDesc__typ;
import ADDRESS *OPT_NodeDesc__typ;
import ADDRESS *OPT_LinkDesc__typ;

import void OPT_Align (INT32 *adr, INT32 base);
import INT32 OPT_BaseAlignment (OPT_Struct typ);
import void OPT_Close (void);
import void OPT_CloseScope (void);
import void OPT_Export (BOOLEAN *ext, BOOLEAN *new);
import void OPT_FPrintErr (OPT_Object obj, INT16 errcode);
import void OPT_FPrintObj (OPT_Object obj);
import void OPT_FPrintStr (OPT_Struct typ);
import void OPT_Find (OPT_Object *res);
import void OPT_FindField (OPS_Name name, OPT_Struct typ, OPT_Object *res);
import void OPT_FindImport (OPT_Object mod, OPT_Object *res);
import void OPT_IdFPrint (OPT_Struct typ);
import void OPT_Import (OPS_Name aliasName, OPS_Name name, BOOLEAN *done);
import void OPT_Init (OPS_Name name, UINT32 opt);
import void OPT_InitRecno (void);
import void OPT_Insert (OPS_Name name, OPT_Object *obj);
import void OPT_InsertImport (OPT_Object obj, OPT_Object *root, OPT_Object *old);
import INT16 OPT_IntSize (INT64 n);
import OPT_Struct OPT_IntType (INT32 size);
import OPT_Const OPT_NewConst (void);
import OPT_ConstExt OPT_NewExt (void);
import OPT_Node OPT_NewNode (INT8 class);
import OPT_Object OPT_NewObj (void);
import OPT_Struct OPT_NewStr (INT8 form, INT8 comp);
import void OPT_OpenScope (INT8 level, OPT_Object owner);
import OPT_Struct OPT_SetType (INT32 size);
import OPT_Struct OPT_ShorterOrLongerType (OPT_Struct x, INT16 dir);
import INT32 OPT_SizeAlignment (INT32 size);
import void OPT_TypSize (OPT_Struct typ);
import void *OPT__init(void);


#endif // OPT
