/* voc 2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8. xtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Configuration.h"
#include "OPM.h"
#include "OPT.h"


static INT16 OPC_indentLevel;
static INT8 OPC_hashtab[105];
static CHAR OPC_keytab[50][9];
static BOOLEAN OPC_GlbPtrs;
static CHAR OPC_BodyNameExt[13];


export void OPC_Andent (OPT_Struct typ);
static void OPC_AnsiParamList (OPT_Object obj, BOOLEAN showParamNames);
export OPT_Object OPC_BaseTProc (OPT_Object obj);
export void OPC_BegBlk (void);
export void OPC_BegStat (void);
static void OPC_CProcDefs (OPT_Object obj, INT16 vis);
export void OPC_Case (INT64 caseVal, INT16 form);
static void OPC_CharacterLiteral (INT64 c);
export void OPC_Cmp (INT16 rel);
export void OPC_CompleteIdent (OPT_Object obj);
export void OPC_Constant (OPT_Const con, INT16 form);
static void OPC_DeclareBase (OPT_Object dcl);
static void OPC_DeclareObj (OPT_Object dcl, BOOLEAN scopeDef);
static void OPC_DeclareParams (OPT_Object par, BOOLEAN macro);
static void OPC_DeclareTProcs (OPT_Object obj, BOOLEAN *empty);
static void OPC_DefAnonRecs (OPT_Node n);
export void OPC_DefineInter (OPT_Object proc);
static void OPC_DefineTProcMacros (OPT_Object obj, BOOLEAN *empty);
static void OPC_DefineTProcTypes (OPT_Object obj);
static void OPC_DefineType (OPT_Struct str);
export void OPC_EndBlk (void);
export void OPC_EndBlk0 (void);
export void OPC_EndStat (void);
export void OPC_EnterBody (void);
export void OPC_EnterProc (OPT_Object proc);
export void OPC_ExitBody (void);
export void OPC_ExitProc (OPT_Object proc, BOOLEAN eoBlock, BOOLEAN implicitRet);
static void OPC_FieldList (OPT_Struct typ, BOOLEAN last, INT32 *off, INT32 *n, INT32 *curAlign);
static void OPC_FillGap (INT32 gap, INT32 off, INT32 align, INT32 *n, INT32 *curAlign);
export void OPC_GenBdy (OPT_Node n);
static void OPC_GenDynTypes (OPT_Node n, INT16 vis);
export void OPC_GenEnumPtrs (OPT_Object var);
export void OPC_GenHdr (OPT_Node n);
export void OPC_GenHdrIncludes (void);
static void OPC_GenHeaderMsg (void);
export void OPC_Halt (INT32 n);
export void OPC_Ident (OPT_Object obj);
static void OPC_IdentList (OPT_Object obj, INT16 vis);
static void OPC_Include (CHAR *name, ADDRESS name__len);
static void OPC_IncludeImports (OPT_Object obj, INT16 vis);
export void OPC_Increment (BOOLEAN decrement);
export void OPC_Indent (INT16 count);
export void OPC_Init (void);
static void OPC_InitImports (OPT_Object obj);
static void OPC_InitKeywords (void);
export void OPC_InitTDesc (OPT_Struct typ);
static void OPC_InitTProcs (OPT_Object typ, OPT_Object obj);
export void OPC_IntLiteral (INT64 n, INT32 size);
export void OPC_Len (OPT_Object obj, OPT_Struct array, INT64 dim);
static void OPC_LenList (OPT_Object par, BOOLEAN ansiDefine, BOOLEAN showParamName);
static INT16 OPC_Length (CHAR *s, ADDRESS s__len);
export BOOLEAN OPC_NeedsRetval (OPT_Object proc);
export INT32 OPC_NofPtrs (OPT_Struct typ);
static INT16 OPC_PerfectHash (CHAR *s, ADDRESS s__len);
static BOOLEAN OPC_Prefixed (OPT_ConstExt x, CHAR *y, ADDRESS y__len);
static void OPC_ProcHeader (OPT_Object proc, BOOLEAN define);
static void OPC_ProcPredefs (OPT_Object obj, INT8 vis);
static void OPC_PutBase (OPT_Struct typ);
static void OPC_PutPtrOffsets (OPT_Struct typ, INT32 adr, INT32 *cnt);
static void OPC_RegCmds (OPT_Object obj);
export void OPC_SetInclude (BOOLEAN exclude);
static void OPC_Stars (OPT_Struct typ, BOOLEAN *openClause);
static void OPC_Str1 (CHAR *s, ADDRESS s__len, INT32 x);
static void OPC_StringLiteral (CHAR *s, ADDRESS s__len, INT32 l);
export void OPC_TDescDecl (OPT_Struct typ);
export void OPC_TypeDefs (OPT_Object obj, INT16 vis);
export void OPC_TypeOf (OPT_Object ap);
static BOOLEAN OPC_Undefined (OPT_Object obj);


void OPC_Init (void)
{
	OPC_indentLevel = 0;
	__MOVE("__init(void)", OPC_BodyNameExt, 13);
}

void OPC_Indent (INT16 count)
{
	OPC_indentLevel += count;
}

void OPC_BegStat (void)
{
	INT16 i;
	i = OPC_indentLevel;
	while (i > 0) {
		OPM_Write(0x09);
		i -= 1;
	}
}

void OPC_EndStat (void)
{
	OPM_Write(';');
	OPM_WriteLn();
}

void OPC_BegBlk (void)
{
	OPM_Write('{');
	OPM_WriteLn();
	OPC_indentLevel += 1;
}

void OPC_EndBlk (void)
{
	OPC_indentLevel -= 1;
	OPC_BegStat();
	OPM_Write('}');
	OPM_WriteLn();
}

void OPC_EndBlk0 (void)
{
	OPC_indentLevel -= 1;
	OPC_BegStat();
	OPM_Write('}');
}

static void OPC_Str1 (CHAR *s, ADDRESS s__len, INT32 x)
{
	CHAR ch;
	INT16 i;
	__DUP(s, s__len, CHAR);
	ch = s[0];
	i = 0;
	while (ch != 0x00) {
		if (ch == '#') {
			OPM_WriteInt(x);
		} else {
			OPM_Write(ch);
		}
		i += 1;
		ch = s[__X(i, s__len)];
	}
	__DEL(s);
}

static INT16 OPC_Length (CHAR *s, ADDRESS s__len)
{
	INT16 i;
	i = 0;
	while (s[__X(i, s__len)] != 0x00) {
		i += 1;
	}
	return i;
}

static INT16 OPC_PerfectHash (CHAR *s, ADDRESS s__len)
{
	INT16 i, h;
	i = 0;
	h = 0;
	while ((s[__X(i, s__len)] != 0x00 && i < 5)) {
		h = 3 * h + (INT16)s[__X(i, s__len)];
		i += 1;
	}
	return (int)__MOD(h, 105);
}

void OPC_Ident (OPT_Object obj)
{
	INT16 mode, level, h;
	mode = obj->mode;
	level = obj->mnolev;
	if ((__IN(mode, 0x62, 32) && level > 0) || __IN(mode, 0x14, 32)) {
		OPM_WriteStringVar((void*)obj->name, 256);
		h = OPC_PerfectHash((void*)obj->name, 256);
		if (OPC_hashtab[__X(h, 105)] >= 0) {
			if (__STRCMP(OPC_keytab[__X(OPC_hashtab[__X(h, 105)], 50)], obj->name) == 0) {
				OPM_Write('_');
			}
		}
	} else if ((mode == 5 && __IN(obj->typ->form, 0x90, 32))) {
		if (obj->typ == OPT_adrtyp) {
			OPM_WriteString((CHAR*)"ADDRESS", 8);
		} else {
			if (obj->typ->form == 4) {
				OPM_WriteString((CHAR*)"INT", 4);
			} else {
				OPM_WriteString((CHAR*)"UINT", 5);
			}
			OPM_WriteInt(__ASHL(obj->typ->size, 3));
		}
	} else {
		if (mode != 5 || obj->linkadr != 2) {
			if (mode == 13) {
				OPC_Ident(obj->link->typ->strobj);
			} else if (level < 0) {
				OPM_WriteStringVar((void*)OPT_GlbMod[__X(-level, 64)]->name, 256);
				if (OPM_currFile == 0) {
					OPT_GlbMod[__X(-level, 64)]->vis = 1;
				}
			} else {
				OPM_WriteStringVar((void*)OPM_modName, 32);
			}
			OPM_Write('_');
		} else if (obj == OPT_sysptrtyp->strobj || obj == OPT_bytetyp->strobj) {
			OPM_WriteString((CHAR*)"SYSTEM_", 8);
		}
		OPM_WriteStringVar((void*)obj->name, 256);
	}
}

static void OPC_Stars (OPT_Struct typ, BOOLEAN *openClause)
{
	INT16 pointers;
	*openClause = 0;
	if (((typ->strobj == NIL || typ->strobj->name[0] == 0x00) && typ->comp != 4)) {
		if (__IN(typ->comp, 0x0c, 32)) {
			OPC_Stars(typ->BaseTyp, &*openClause);
			*openClause = typ->comp == 2;
		} else if (typ->form == 12) {
			OPM_Write('(');
			OPM_Write('*');
		} else {
			pointers = 0;
			while (((typ->strobj == NIL || typ->strobj->name[0] == 0x00) && typ->form == 11)) {
				pointers += 1;
				typ = typ->BaseTyp;
			}
			if (pointers > 0) {
				if (typ->comp != 3) {
					OPC_Stars(typ, &*openClause);
				}
				if (*openClause) {
					OPM_Write('(');
					*openClause = 0;
				}
				while (pointers > 0) {
					OPM_Write('*');
					pointers -= 1;
				}
			}
		}
	}
}

static void OPC_DeclareObj (OPT_Object dcl, BOOLEAN scopeDef)
{
	OPT_Struct typ = NIL;
	BOOLEAN varPar, openClause;
	INT16 form, comp;
	typ = dcl->typ;
	varPar = ((dcl->mode == 2 && typ->comp != 2) || typ->comp == 3) || scopeDef;
	OPC_Stars(typ, &openClause);
	if (varPar) {
		if (openClause) {
			OPM_Write('(');
		}
		OPM_Write('*');
	}
	if (dcl->name[0] != 0x00) {
		OPC_Ident(dcl);
	}
	if ((varPar && openClause)) {
		OPM_Write(')');
	}
	openClause = 0;
	for (;;) {
		form = typ->form;
		comp = typ->comp;
		if (((typ->strobj != NIL && typ->strobj->name[0] != 0x00) || form == 10) || comp == 4) {
			break;
		} else if ((form == 11 && typ->BaseTyp->comp != 3)) {
			openClause = 1;
		} else if (form == 12 || __IN(comp, 0x0c, 32)) {
			if (openClause) {
				OPM_Write(')');
				openClause = 0;
			}
			if (form == 12) {
				OPM_Write(')');
				OPC_AnsiParamList(typ->link, 0);
				break;
			} else if (comp == 2) {
				OPM_Write('[');
				OPM_WriteInt(typ->n);
				OPM_Write(']');
			}
		} else {
			break;
		}
		typ = typ->BaseTyp;
	}
}

void OPC_Andent (OPT_Struct typ)
{
	if (typ->strobj == NIL || typ->align >= 65536) {
		OPM_WriteStringVar((void*)OPM_modName, 32);
		OPC_Str1((CHAR*)"__#", 4, __ASHR(typ->align, 16));
	} else {
		OPC_Ident(typ->strobj);
	}
}

static BOOLEAN OPC_Undefined (OPT_Object obj)
{
	return obj->name[0] == 0x00 || (((obj->mnolev >= 0 && obj->linkadr != (3 + OPM_currFile))) && obj->linkadr != 2);
}

static void OPC_DeclareBase (OPT_Object dcl)
{
	OPT_Struct typ = NIL, prev = NIL;
	OPT_Object obj = NIL;
	INT16 nofdims;
	INT32 off, n, dummy;
	typ = dcl->typ;
	prev = typ;
	while ((((((((typ->strobj == NIL || typ->comp == 3) || OPC_Undefined(typ->strobj)) && typ->comp != 4)) && typ->form != 10)) && !((typ->form == 11 && typ->BaseTyp->comp == 3)))) {
		prev = typ;
		typ = typ->BaseTyp;
	}
	obj = typ->strobj;
	if (typ->form == 10) {
		OPM_WriteString((CHAR*)"void", 5);
	} else if ((obj != NIL && !OPC_Undefined(obj))) {
		OPC_Ident(obj);
	} else if (typ->comp == 4) {
		OPM_WriteString((CHAR*)"struct ", 8);
		OPC_Andent(typ);
		if ((prev->form != 11 && (obj != NIL || dcl->name[0] == 0x00))) {
			if ((typ->BaseTyp != NIL && typ->BaseTyp->strobj->vis != 0)) {
				OPM_WriteString((CHAR*)" { /* ", 7);
				OPC_Ident(typ->BaseTyp->strobj);
				OPM_WriteString((CHAR*)" */", 4);
				OPM_WriteLn();
				OPC_Indent(1);
			} else {
				OPM_Write(' ');
				OPC_BegBlk();
			}
			OPC_FieldList(typ, 1, &off, &n, &dummy);
			OPC_EndBlk0();
		}
	} else if ((typ->form == 11 && typ->BaseTyp->comp == 3)) {
		typ = typ->BaseTyp->BaseTyp;
		nofdims = 1;
		while (typ->comp == 3) {
			nofdims += 1;
			typ = typ->BaseTyp;
		}
		OPM_WriteString((CHAR*)"struct ", 8);
		OPC_BegBlk();
		OPC_BegStat();
		OPC_Str1((CHAR*)"ADDRESS len[#]", 15, nofdims);
		OPC_EndStat();
		OPC_BegStat();
		__NEW(obj, OPT_ObjDesc);
		__NEW(obj->typ, OPT_StrDesc);
		obj->typ->form = 13;
		obj->typ->comp = 2;
		obj->typ->n = 1;
		obj->typ->BaseTyp = typ;
		obj->mode = 4;
		__MOVE("data", obj->name, 5);
		obj->linkadr = 0;
		OPC_DeclareBase(obj);
		OPM_Write(' ');
		OPC_DeclareObj(obj, 0);
		OPC_EndStat();
		OPC_EndBlk0();
	}
}

INT32 OPC_NofPtrs (OPT_Struct typ)
{
	OPT_Object fld = NIL;
	OPT_Struct btyp = NIL;
	INT32 n;
	if ((typ->form == 11 && typ->sysflag == 0)) {
		return 1;
	} else if ((typ->comp == 4 && __MASK(typ->sysflag, -256) == 0)) {
		btyp = typ->BaseTyp;
		if (btyp != NIL) {
			n = OPC_NofPtrs(btyp);
		} else {
			n = 0;
		}
		fld = typ->link;
		while ((fld != NIL && fld->mode == 4)) {
			if (__STRCMP(fld->name, "@ptr") != 0) {
				n = n + OPC_NofPtrs(fld->typ);
			} else {
				n += 1;
			}
			fld = fld->link;
		}
		return n;
	} else if (typ->comp == 2) {
		btyp = typ->BaseTyp;
		n = typ->n;
		while (btyp->comp == 2) {
			n = btyp->n * n;
			btyp = btyp->BaseTyp;
		}
		return OPC_NofPtrs(btyp) * n;
	} else {
		return 0;
	}
	__RETCHK;
}

static void OPC_PutPtrOffsets (OPT_Struct typ, INT32 adr, INT32 *cnt)
{
	OPT_Object fld = NIL;
	OPT_Struct btyp = NIL;
	INT32 n, i;
	if ((typ->form == 11 && typ->sysflag == 0)) {
		OPM_WriteInt(adr);
		OPM_WriteString((CHAR*)", ", 3);
		*cnt += 1;
		if (__MASK(*cnt, -16) == 0) {
			OPM_WriteLn();
			OPM_Write(0x09);
		}
	} else if ((typ->comp == 4 && __MASK(typ->sysflag, -256) == 0)) {
		btyp = typ->BaseTyp;
		if (btyp != NIL) {
			OPC_PutPtrOffsets(btyp, adr, &*cnt);
		}
		fld = typ->link;
		while ((fld != NIL && fld->mode == 4)) {
			if (__STRCMP(fld->name, "@ptr") != 0) {
				OPC_PutPtrOffsets(fld->typ, adr + fld->adr, &*cnt);
			} else {
				OPM_WriteInt(adr + fld->adr);
				OPM_WriteString((CHAR*)", ", 3);
				*cnt += 1;
				if (__MASK(*cnt, -16) == 0) {
					OPM_WriteLn();
					OPM_Write(0x09);
				}
			}
			fld = fld->link;
		}
	} else if (typ->comp == 2) {
		btyp = typ->BaseTyp;
		n = typ->n;
		while (btyp->comp == 2) {
			n = btyp->n * n;
			btyp = btyp->BaseTyp;
		}
		if (OPC_NofPtrs(btyp) > 0) {
			i = 0;
			while (i < n) {
				OPC_PutPtrOffsets(btyp, adr + i * btyp->size, &*cnt);
				i += 1;
			}
		}
	}
}

static void OPC_InitTProcs (OPT_Object typ, OPT_Object obj)
{
	if (obj != NIL) {
		OPC_InitTProcs(typ, obj->left);
		if (obj->mode == 13) {
			OPC_BegStat();
			OPM_WriteString((CHAR*)"__INITBP(", 10);
			OPC_Ident(typ);
			OPM_WriteString((CHAR*)", ", 3);
			OPC_Ident(obj);
			OPC_Str1((CHAR*)", #)", 5, __ASHR(obj->adr, 16));
			OPC_EndStat();
		}
		OPC_InitTProcs(typ, obj->right);
	}
}

static void OPC_PutBase (OPT_Struct typ)
{
	if (typ != NIL) {
		OPC_PutBase(typ->BaseTyp);
		OPC_Ident(typ->strobj);
		OPM_WriteString((CHAR*)"__typ", 6);
		OPM_WriteString((CHAR*)", ", 3);
	}
}

static void OPC_LenList (OPT_Object par, BOOLEAN ansiDefine, BOOLEAN showParamName)
{
	OPT_Struct typ = NIL;
	INT16 dim;
	if (showParamName) {
		OPC_Ident(par);
		OPM_WriteString((CHAR*)"__len", 6);
	}
	dim = 1;
	typ = par->typ->BaseTyp;
	while (typ->comp == 3) {
		if (ansiDefine) {
			OPM_WriteString((CHAR*)", ADDRESS ", 11);
		} else {
			OPM_WriteString((CHAR*)", ", 3);
		}
		if (showParamName) {
			OPC_Ident(par);
			OPM_WriteString((CHAR*)"__len", 6);
			OPM_WriteInt(dim);
		}
		typ = typ->BaseTyp;
		dim += 1;
	}
}

static void OPC_DeclareParams (OPT_Object par, BOOLEAN macro)
{
	OPM_Write('(');
	while (par != NIL) {
		if (macro) {
			OPM_WriteStringVar((void*)par->name, 256);
		} else {
			if ((par->mode == 1 && par->typ->form == 5)) {
				OPM_Write('_');
			}
			OPC_Ident(par);
		}
		if (par->typ->comp == 3) {
			OPM_WriteString((CHAR*)", ", 3);
			OPC_LenList(par, 0, 1);
		} else if ((par->mode == 2 && par->typ->comp == 4)) {
			OPM_WriteString((CHAR*)", ", 3);
			OPM_WriteStringVar((void*)par->name, 256);
			OPM_WriteString((CHAR*)"__typ", 6);
		}
		par = par->link;
		if (par != NIL) {
			OPM_WriteString((CHAR*)", ", 3);
		}
	}
	OPM_Write(')');
}

static void OPC_DefineTProcTypes (OPT_Object obj)
{
	OPT_Object par = NIL;
	if (obj->typ != OPT_notyp) {
		OPC_DefineType(obj->typ);
	}
	par = obj->link;
	while (par != NIL) {
		OPC_DefineType(par->typ);
		par = par->link;
	}
}

static void OPC_DeclareTProcs (OPT_Object obj, BOOLEAN *empty)
{
	if (obj != NIL) {
		OPC_DeclareTProcs(obj->left, &*empty);
		if (obj->mode == 13) {
			if (obj->typ != OPT_notyp) {
				OPC_DefineType(obj->typ);
			}
			if (OPM_currFile == 0) {
				if (obj->vis == 1) {
					OPC_DefineTProcTypes(obj);
					OPM_WriteString((CHAR*)"import ", 8);
					*empty = 0;
					OPC_ProcHeader(obj, 0);
				}
			} else {
				*empty = 0;
				OPC_DefineTProcTypes(obj);
				if (obj->vis == 0) {
					OPM_WriteString((CHAR*)"static ", 8);
				} else {
					OPM_WriteString((CHAR*)"export ", 8);
				}
				OPC_ProcHeader(obj, 0);
			}
		}
		OPC_DeclareTProcs(obj->right, &*empty);
	}
}

OPT_Object OPC_BaseTProc (OPT_Object obj)
{
	OPT_Struct typ = NIL, base = NIL;
	INT32 mno;
	typ = obj->link->typ;
	if (typ->form == 11) {
		typ = typ->BaseTyp;
	}
	base = typ->BaseTyp;
	mno = __ASHR(obj->adr, 16);
	while ((base != NIL && mno < base->n)) {
		typ = base;
		base = typ->BaseTyp;
	}
	OPT_FindField(obj->name, typ, &obj);
	return obj;
}

static void OPC_DefineTProcMacros (OPT_Object obj, BOOLEAN *empty)
{
	if (obj != NIL) {
		OPC_DefineTProcMacros(obj->left, &*empty);
		if ((((obj->mode == 13 && obj == OPC_BaseTProc(obj))) && (OPM_currFile != 0 || obj->vis == 1))) {
			OPM_WriteString((CHAR*)"#define __", 11);
			OPC_Ident(obj);
			OPC_DeclareParams(obj->link, 1);
			OPM_WriteString((CHAR*)" __SEND(", 9);
			if (obj->link->typ->form == 11) {
				OPM_WriteString((CHAR*)"__TYPEOF(", 10);
				OPC_Ident(obj->link);
				OPM_Write(')');
			} else {
				OPC_Ident(obj->link);
				OPM_WriteString((CHAR*)"__typ", 6);
			}
			OPC_Str1((CHAR*)", #, ", 6, __ASHR(obj->adr, 16));
			if (obj->typ == OPT_notyp) {
				OPM_WriteString((CHAR*)"void", 5);
			} else {
				OPC_Ident(obj->typ->strobj);
			}
			OPM_WriteString((CHAR*)"(*)", 4);
			OPC_AnsiParamList(obj->link, 0);
			OPM_WriteString((CHAR*)", ", 3);
			OPC_DeclareParams(obj->link, 1);
			OPM_Write(')');
			OPM_WriteLn();
		}
		OPC_DefineTProcMacros(obj->right, &*empty);
	}
}

static void OPC_DefineType (OPT_Struct str)
{
	OPT_Object obj = NIL, field = NIL, par = NIL;
	BOOLEAN empty;
	if (OPM_currFile == 1 || str->ref < 255) {
		obj = str->strobj;
		if (obj == NIL || OPC_Undefined(obj)) {
			if (obj != NIL) {
				if (obj->linkadr == 1) {
					if (str->form != 11) {
						OPM_Mark(244, str->txtpos);
						obj->linkadr = 2;
					}
				} else {
					obj->linkadr = 1;
				}
			}
			if (str->comp == 4) {
				if (str->BaseTyp != NIL) {
					OPC_DefineType(str->BaseTyp);
				}
				field = str->link;
				while ((field != NIL && field->mode == 4)) {
					if (field->vis != 0 || OPM_currFile == 1) {
						OPC_DefineType(field->typ);
					}
					field = field->link;
				}
			} else if (str->form == 11) {
				if (str->BaseTyp->comp != 4) {
					OPC_DefineType(str->BaseTyp);
				}
			} else if (__IN(str->comp, 0x0c, 32)) {
				OPC_DefineType(str->BaseTyp);
			} else if (str->form == 12) {
				if (str->BaseTyp != OPT_notyp) {
					OPC_DefineType(str->BaseTyp);
				}
				field = str->link;
				while (field != NIL) {
					OPC_DefineType(field->typ);
					field = field->link;
				}
			}
		}
		if ((obj != NIL && OPC_Undefined(obj))) {
			OPM_WriteString((CHAR*)"typedef", 8);
			OPM_WriteLn();
			OPM_Write(0x09);
			OPC_Indent(1);
			obj->linkadr = 1;
			OPC_DeclareBase(obj);
			OPM_Write(' ');
			obj->typ->strobj = NIL;
			OPC_DeclareObj(obj, 0);
			obj->typ->strobj = obj;
			obj->linkadr = 3 + OPM_currFile;
			OPC_EndStat();
			OPC_Indent(-1);
			OPM_WriteLn();
			if (obj->typ->comp == 4) {
				empty = 1;
				OPC_DeclareTProcs(str->link, &empty);
				OPC_DefineTProcMacros(str->link, &empty);
				if (!empty) {
					OPM_WriteLn();
				}
			}
		}
	}
}

static BOOLEAN OPC_Prefixed (OPT_ConstExt x, CHAR *y, ADDRESS y__len)
{
	INT16 i;
	__DUP(y, y__len, CHAR);
	i = 0;
	while ((*x)[__X(i + 1, 256)] == y[__X(i, y__len)]) {
		i += 1;
	}
	__DEL(y);
	return y[__X(i, y__len)] == 0x00;
}

static void OPC_CProcDefs (OPT_Object obj, INT16 vis)
{
	INT16 i;
	OPT_ConstExt ext = NIL;
	INT16 _for__7;
	if (obj != NIL) {
		OPC_CProcDefs(obj->left, vis);
		if ((((obj->mode == 9 && (INT16)obj->vis >= vis)) && obj->adr == 1)) {
			ext = obj->conval->ext;
			i = 1;
			if (((*ext)[1] != '#' && !(OPC_Prefixed(ext, (CHAR*)"extern ", 8) || OPC_Prefixed(ext, (CHAR*)"import ", 8)))) {
				OPM_WriteString((CHAR*)"#define ", 9);
				OPC_Ident(obj);
				OPC_DeclareParams(obj->link, 1);
				OPM_Write(0x09);
			}
			_for__7 = (INT16)(*obj->conval->ext)[0];
			i = i;
			while (i <= _for__7) {
				OPM_Write((*obj->conval->ext)[__X(i, 256)]);
				i += 1;
			}
			OPM_WriteLn();
		}
		OPC_CProcDefs(obj->right, vis);
	}
}

void OPC_TypeDefs (OPT_Object obj, INT16 vis)
{
	if (obj != NIL) {
		OPC_TypeDefs(obj->left, vis);
		if ((obj->mode == 5 && obj->typ->txtpos > 0)) {
			OPC_DefineType(obj->typ);
		}
		OPC_TypeDefs(obj->right, vis);
	}
}

static void OPC_DefAnonRecs (OPT_Node n)
{
	OPT_Object o = NIL;
	OPT_Struct typ = NIL;
	while ((n != NIL && n->class == 14)) {
		typ = n->typ;
		if ((typ->strobj == NIL && (OPM_currFile == 1 || typ->ref < 255))) {
			OPC_DefineType(typ);
			__NEW(o, OPT_ObjDesc);
			o->typ = typ;
			o->name[0] = 0x00;
			OPC_DeclareBase(o);
			OPC_EndStat();
			OPM_WriteLn();
		}
		n = n->link;
	}
}

void OPC_TDescDecl (OPT_Struct typ)
{
	INT32 nofptrs;
	OPT_Object o = NIL;
	OPC_BegStat();
	OPM_WriteString((CHAR*)"__TDESC(", 9);
	OPC_Andent(typ);
	OPC_Str1((CHAR*)", #", 4, typ->n + 1);
	OPC_Str1((CHAR*)", #) = {__TDFLDS(", 18, OPC_NofPtrs(typ));
	OPM_Write('"');
	if (typ->strobj != NIL) {
		OPM_WriteStringVar((void*)typ->strobj->name, 256);
	}
	OPM_Write('"');
	OPC_Str1((CHAR*)", #), {", 8, typ->size);
	nofptrs = 0;
	OPC_PutPtrOffsets(typ, 0, &nofptrs);
	OPC_Str1((CHAR*)"#}}", 4, -((nofptrs + 1) * OPM_AddressSize));
	OPC_EndStat();
}

void OPC_InitTDesc (OPT_Struct typ)
{
	OPC_BegStat();
	OPM_WriteString((CHAR*)"__INITYP(", 10);
	OPC_Andent(typ);
	OPM_WriteString((CHAR*)", ", 3);
	if (typ->BaseTyp != NIL) {
		OPC_Andent(typ->BaseTyp);
	} else {
		OPC_Andent(typ);
	}
	OPC_Str1((CHAR*)", #)", 5, typ->extlev);
	OPC_EndStat();
	if (typ->strobj != NIL) {
		OPC_InitTProcs(typ->strobj, typ->link);
	}
}

static void OPC_FillGap (INT32 gap, INT32 off, INT32 align, INT32 *n, INT32 *curAlign)
{
	INT32 adr;
	adr = off;
	OPT_Align(&adr, align);
	if ((*curAlign < align && gap - (adr - off) >= align)) {
		gap -= (adr - off) + align;
		OPC_BegStat();
		switch (align) {
			case 2: 
				OPM_WriteString((CHAR*)"INT16", 6);
				break;
			case 4: 
				OPM_WriteString((CHAR*)"INT32", 6);
				break;
			case 8: 
				OPM_WriteString((CHAR*)"INT64", 6);
				break;
			default: 
				OPM_LogWLn();
				OPM_LogWStr((CHAR*)"Unexpected enclosing alignment in FillGap.", 43);
				break;
		}
		OPC_Str1((CHAR*)" _prvt#", 8, *n);
		*n += 1;
		OPC_EndStat();
		*curAlign = align;
	}
	if (gap > 0) {
		OPC_BegStat();
		OPC_Str1((CHAR*)"char _prvt#", 12, *n);
		*n += 1;
		OPC_Str1((CHAR*)"[#]", 4, gap);
		OPC_EndStat();
	}
}

static void OPC_FieldList (OPT_Struct typ, BOOLEAN last, INT32 *off, INT32 *n, INT32 *curAlign)
{
	OPT_Object fld = NIL;
	OPT_Struct base = NIL;
	INT32 gap, adr, align, fldAlign;
	fld = typ->link;
	align = __MASK(typ->align, -65536);
	if (typ->BaseTyp != NIL) {
		OPC_FieldList(typ->BaseTyp, 0, &*off, &*n, &*curAlign);
	} else {
		*off = 0;
		*n = 0;
		*curAlign = 1;
	}
	while ((fld != NIL && fld->mode == 4)) {
		if ((OPM_currFile == 0 && fld->vis == 0) || (((OPM_currFile == 1 && fld->vis == 0)) && typ->mno != 0)) {
			fld = fld->link;
			while ((((fld != NIL && fld->mode == 4)) && fld->vis == 0)) {
				fld = fld->link;
			}
		} else {
			adr = *off;
			fldAlign = OPT_BaseAlignment(fld->typ);
			OPT_Align(&adr, fldAlign);
			gap = fld->adr - adr;
			if (fldAlign > *curAlign) {
				*curAlign = fldAlign;
			}
			if (gap > 0) {
				OPC_FillGap(gap, *off, align, &*n, &*curAlign);
			}
			OPC_BegStat();
			OPC_DeclareBase(fld);
			OPM_Write(' ');
			OPC_DeclareObj(fld, 0);
			*off = fld->adr + fld->typ->size;
			base = fld->typ;
			fld = fld->link;
			while ((((((((fld != NIL && fld->mode == 4)) && fld->typ == base)) && fld->adr == *off)) && ((OPM_currFile == 1 || fld->vis != 0) || fld->typ->strobj == NIL))) {
				OPM_WriteString((CHAR*)", ", 3);
				OPC_DeclareObj(fld, 0);
				*off = fld->adr + fld->typ->size;
				fld = fld->link;
			}
			OPC_EndStat();
		}
	}
	if (last) {
		adr = typ->size - __ASHR(typ->sysflag, 8);
		if (adr == 0) {
			gap = 1;
		} else {
			gap = adr - *off;
		}
		if (gap > 0) {
			OPC_FillGap(gap, *off, align, &*n, &*curAlign);
		}
	}
}

static void OPC_IdentList (OPT_Object obj, INT16 vis)
{
	OPT_Struct base = NIL;
	BOOLEAN first;
	INT16 lastvis;
	base = NIL;
	first = 1;
	while ((obj != NIL && obj->mode != 13)) {
		if ((__IN(vis, 0x05, 32) || (vis == 1 && obj->vis != 0)) || (vis == 3 && !obj->leaf)) {
			if (obj->typ != base || (INT16)obj->vis != lastvis) {
				if (!first) {
					OPC_EndStat();
				}
				first = 0;
				base = obj->typ;
				lastvis = obj->vis;
				OPC_BegStat();
				if ((vis == 1 && obj->vis != 0)) {
					OPM_WriteString((CHAR*)"import ", 8);
				} else if ((obj->mnolev == 0 && vis == 0)) {
					if (obj->vis == 0) {
						OPM_WriteString((CHAR*)"static ", 8);
					} else {
						OPM_WriteString((CHAR*)"export ", 8);
					}
				}
				if ((((vis == 2 && obj->mode == 1)) && base->form == 5)) {
					OPM_WriteString((CHAR*)"double", 7);
				} else {
					OPC_DeclareBase(obj);
				}
			} else {
				OPM_Write(',');
			}
			OPM_Write(' ');
			if ((((vis == 2 && obj->mode == 1)) && base->form == 5)) {
				OPM_Write('_');
			}
			OPC_DeclareObj(obj, vis == 3);
			if (obj->typ->comp == 3) {
				OPC_EndStat();
				OPC_BegStat();
				base = OPT_adrtyp;
				OPM_WriteString((CHAR*)"ADDRESS ", 9);
				OPC_LenList(obj, 0, 1);
			} else if ((obj->mode == 2 && obj->typ->comp == 4)) {
				OPC_EndStat();
				OPC_BegStat();
				OPM_WriteString((CHAR*)"ADDRESS *", 10);
				OPC_Ident(obj);
				OPM_WriteString((CHAR*)"__typ", 6);
				base = NIL;
			} else if ((((((__IN(5, OPM_Options, 32) && vis == 0)) && obj->mnolev > 0)) && obj->typ->form == 11)) {
				OPM_WriteString((CHAR*)" = NIL", 7);
			}
		}
		obj = obj->link;
	}
	if (!first) {
		OPC_EndStat();
	}
}

static void OPC_AnsiParamList (OPT_Object obj, BOOLEAN showParamNames)
{
	CHAR name[32];
	OPM_Write('(');
	if (obj == NIL || obj->mode == 13) {
		OPM_WriteString((CHAR*)"void", 5);
	} else {
		for (;;) {
			OPC_DeclareBase(obj);
			if (showParamNames) {
				OPM_Write(' ');
				OPC_DeclareObj(obj, 0);
			} else {
				__COPY(obj->name, name, 32);
				obj->name[0] = 0x00;
				OPC_DeclareObj(obj, 0);
				__COPY(name, obj->name, 256);
			}
			if (obj->typ->comp == 3) {
				OPM_WriteString((CHAR*)", ADDRESS ", 11);
				OPC_LenList(obj, 1, showParamNames);
			} else if ((obj->mode == 2 && obj->typ->comp == 4)) {
				OPM_WriteString((CHAR*)", ADDRESS *", 12);
				if (showParamNames) {
					OPC_Ident(obj);
					OPM_WriteString((CHAR*)"__typ", 6);
				}
			}
			if (obj->link == NIL || obj->link->mode == 13) {
				break;
			}
			OPM_WriteString((CHAR*)", ", 3);
			obj = obj->link;
		}
	}
	OPM_Write(')');
}

static void OPC_ProcHeader (OPT_Object proc, BOOLEAN define)
{
	if (proc->typ == OPT_notyp) {
		OPM_WriteString((CHAR*)"void", 5);
	} else {
		OPC_Ident(proc->typ->strobj);
	}
	OPM_Write(' ');
	OPC_Ident(proc);
	OPM_Write(' ');
	OPC_AnsiParamList(proc->link, 1);
	if (!define) {
		OPM_Write(';');
	}
	OPM_WriteLn();
}

static void OPC_ProcPredefs (OPT_Object obj, INT8 vis)
{
	if (obj != NIL) {
		OPC_ProcPredefs(obj->left, vis);
		if ((((__IN(obj->mode, 0xc0, 32) && obj->vis >= vis)) && (obj->history != 4 || obj->mode == 6))) {
			if (vis == 1) {
				OPM_WriteString((CHAR*)"import ", 8);
			} else if (obj->vis == 0) {
				OPM_WriteString((CHAR*)"static ", 8);
			} else {
				OPM_WriteString((CHAR*)"export ", 8);
			}
			OPC_ProcHeader(obj, 0);
		}
		OPC_ProcPredefs(obj->right, vis);
	}
}

static void OPC_Include (CHAR *name, ADDRESS name__len)
{
	__DUP(name, name__len, CHAR);
	OPM_WriteString((CHAR*)"#include ", 10);
	OPM_Write('"');
	OPM_WriteStringVar((void*)name, name__len);
	OPM_WriteString((CHAR*)".h", 3);
	OPM_Write('"');
	OPM_WriteLn();
	__DEL(name);
}

static void OPC_IncludeImports (OPT_Object obj, INT16 vis)
{
	if (obj != NIL) {
		OPC_IncludeImports(obj->left, vis);
		if ((((obj->mode == 11 && obj->mnolev != 0)) && (INT16)OPT_GlbMod[__X(-obj->mnolev, 64)]->vis >= vis)) {
			OPC_Include(OPT_GlbMod[__X(-obj->mnolev, 64)]->name, 256);
		}
		OPC_IncludeImports(obj->right, vis);
	}
}

static void OPC_GenDynTypes (OPT_Node n, INT16 vis)
{
	OPT_Struct typ = NIL;
	while ((n != NIL && n->class == 14)) {
		typ = n->typ;
		if (vis == 0 || typ->ref < 255) {
			OPC_BegStat();
			if (vis == 1) {
				OPM_WriteString((CHAR*)"import ", 8);
			} else if ((typ->strobj != NIL && typ->strobj->mnolev > 0)) {
				OPM_WriteString((CHAR*)"static ", 8);
			} else {
				OPM_WriteString((CHAR*)"export ", 8);
			}
			OPM_WriteString((CHAR*)"ADDRESS *", 10);
			OPC_Andent(typ);
			OPM_WriteString((CHAR*)"__typ", 6);
			OPC_EndStat();
		}
		n = n->link;
	}
}

void OPC_GenHdr (OPT_Node n)
{
	OPM_currFile = 0;
	OPC_DefAnonRecs(n);
	OPC_TypeDefs(OPT_topScope->right, 1);
	OPM_WriteLn();
	OPC_IdentList(OPT_topScope->scope, 1);
	OPM_WriteLn();
	OPC_GenDynTypes(n, 1);
	OPM_WriteLn();
	OPC_ProcPredefs(OPT_topScope->right, 1);
	OPM_WriteString((CHAR*)"import ", 8);
	OPM_WriteString((CHAR*)"void *", 7);
	OPM_WriteStringVar((void*)OPM_modName, 32);
	OPM_WriteString(OPC_BodyNameExt, 13);
	OPC_EndStat();
	OPM_WriteLn();
	OPC_CProcDefs(OPT_topScope->right, 1);
	OPM_WriteLn();
	OPM_WriteString((CHAR*)"#endif // ", 11);
	OPM_WriteStringVar((void*)OPM_modName, 32);
	OPM_WriteLn();
}

static void OPC_GenHeaderMsg (void)
{
	INT16 i;
	OPM_WriteString((CHAR*)"/* ", 4);
	OPM_WriteString((CHAR*)"voc", 4);
	OPM_Write(' ');
	OPM_WriteString(Configuration_versionLong, 76);
	OPM_Write(' ');
	i = 0;
	while (i <= 31) {
		if (__IN(i, OPM_Options, 32)) {
			switch (i) {
				case 0: 
					OPM_Write('x');
					break;
				case 2: 
					OPM_Write('r');
					break;
				case 3: 
					OPM_Write('t');
					break;
				case 4: 
					OPM_Write('s');
					break;
				case 5: 
					OPM_Write('p');
					break;
				case 7: 
					OPM_Write('a');
					break;
				case 9: 
					OPM_Write('e');
					break;
				case 10: 
					OPM_Write('m');
					break;
				case 13: 
					OPM_Write('S');
					break;
				case 14: 
					OPM_Write('c');
					break;
				case 15: 
					OPM_Write('M');
					break;
				case 16: 
					OPM_Write('f');
					break;
				case 17: 
					OPM_Write('F');
					break;
				case 18: 
					OPM_Write('v');
					break;
				default: 
					OPM_LogWStr((CHAR*)"( more options defined in OPM than checked in OPC.GenHeaderMsg, if you are a compiler developer, add them to OPC.GenHeaderMsg", 126);
					OPM_LogWLn();
					break;
			}
		}
		i += 1;
	}
	OPM_WriteString((CHAR*)" */", 4);
	OPM_WriteLn();
}

void OPC_GenHdrIncludes (void)
{
	OPM_currFile = 2;
	OPC_GenHeaderMsg();
	OPM_WriteLn();
	OPM_WriteString((CHAR*)"#ifndef ", 9);
	OPM_WriteStringVar((void*)OPM_modName, 32);
	OPM_WriteString((CHAR*)"__h", 4);
	OPM_WriteLn();
	OPM_WriteString((CHAR*)"#define ", 9);
	OPM_WriteStringVar((void*)OPM_modName, 32);
	OPM_WriteString((CHAR*)"__h", 4);
	OPM_WriteLn();
	OPM_WriteLn();
	OPC_Include((CHAR*)"SYSTEM", 7);
	OPC_IncludeImports(OPT_topScope->right, 1);
	OPM_WriteLn();
}

void OPC_GenBdy (OPT_Node n)
{
	OPM_currFile = 1;
	OPC_GenHeaderMsg();
	OPM_WriteLn();
	OPM_WriteString((CHAR*)"#define SHORTINT INT", 21);
	OPM_WriteInt(__ASHL(OPT_sinttyp->size, 3));
	OPM_WriteLn();
	OPM_WriteString((CHAR*)"#define INTEGER  INT", 21);
	OPM_WriteInt(__ASHL(OPT_inttyp->size, 3));
	OPM_WriteLn();
	OPM_WriteString((CHAR*)"#define LONGINT  INT", 21);
	OPM_WriteInt(__ASHL(OPT_linttyp->size, 3));
	OPM_WriteLn();
	OPM_WriteString((CHAR*)"#define SET      UINT", 22);
	OPM_WriteInt(__ASHL(OPT_settyp->size, 3));
	OPM_WriteLn();
	OPM_WriteLn();
	OPC_Include((CHAR*)"SYSTEM", 7);
	OPC_IncludeImports(OPT_topScope->right, 0);
	OPM_WriteLn();
	OPC_DefAnonRecs(n);
	OPC_TypeDefs(OPT_topScope->right, 0);
	OPM_WriteLn();
	OPC_IdentList(OPT_topScope->scope, 0);
	OPM_WriteLn();
	OPC_GenDynTypes(n, 0);
	OPM_WriteLn();
	OPC_ProcPredefs(OPT_topScope->right, 0);
	OPM_WriteLn();
	OPC_CProcDefs(OPT_topScope->right, 0);
	OPM_WriteLn();
}

static void OPC_RegCmds (OPT_Object obj)
{
	if (obj != NIL) {
		OPC_RegCmds(obj->left);
		if ((obj->mode == 7 && obj->history != 4)) {
			if ((((obj->vis != 0 && obj->link == NIL)) && obj->typ == OPT_notyp)) {
				OPC_BegStat();
				OPM_WriteString((CHAR*)"__REGCMD(\"", 11);
				OPM_WriteStringVar((void*)obj->name, 256);
				OPM_WriteString((CHAR*)"\", ", 4);
				OPC_Ident(obj);
				OPM_Write(')');
				OPC_EndStat();
			}
		}
		OPC_RegCmds(obj->right);
	}
}

static void OPC_InitImports (OPT_Object obj)
{
	if (obj != NIL) {
		OPC_InitImports(obj->left);
		if ((obj->mode == 11 && obj->mnolev != 0)) {
			OPC_BegStat();
			OPM_WriteString((CHAR*)"__MODULE_IMPORT(", 17);
			OPM_WriteStringVar((void*)OPT_GlbMod[__X(-obj->mnolev, 64)]->name, 256);
			OPM_Write(')');
			OPC_EndStat();
		}
		OPC_InitImports(obj->right);
	}
}

void OPC_GenEnumPtrs (OPT_Object var)
{
	OPT_Struct typ = NIL;
	INT32 n;
	OPC_GlbPtrs = 0;
	while (var != NIL) {
		typ = var->typ;
		if (OPC_NofPtrs(typ) > 0) {
			if (!OPC_GlbPtrs) {
				OPC_GlbPtrs = 1;
				OPM_WriteString((CHAR*)"static void EnumPtrs(void (*P)(void*))", 39);
				OPM_WriteLn();
				OPC_BegBlk();
			}
			OPC_BegStat();
			if (typ->form == 11) {
				OPM_WriteString((CHAR*)"P(", 3);
				OPC_Ident(var);
				OPM_Write(')');
			} else if (typ->comp == 4) {
				OPM_WriteString((CHAR*)"__ENUMR(&", 10);
				OPC_Ident(var);
				OPM_WriteString((CHAR*)", ", 3);
				OPC_Andent(typ);
				OPM_WriteString((CHAR*)"__typ", 6);
				OPC_Str1((CHAR*)", #", 4, typ->size);
				OPM_WriteString((CHAR*)", 1, P)", 8);
			} else if (typ->comp == 2) {
				n = typ->n;
				typ = typ->BaseTyp;
				while (typ->comp == 2) {
					n = n * typ->n;
					typ = typ->BaseTyp;
				}
				if (typ->form == 11) {
					OPM_WriteString((CHAR*)"__ENUMP(", 9);
					OPC_Ident(var);
					OPC_Str1((CHAR*)", #, P)", 8, n);
				} else if (typ->comp == 4) {
					OPM_WriteString((CHAR*)"__ENUMR(", 9);
					OPC_Ident(var);
					OPM_WriteString((CHAR*)", ", 3);
					OPC_Andent(typ);
					OPM_WriteString((CHAR*)"__typ", 6);
					OPC_Str1((CHAR*)", #", 4, typ->size);
					OPC_Str1((CHAR*)", #, P)", 8, n);
				}
			}
			OPC_EndStat();
		}
		var = var->link;
	}
	if (OPC_GlbPtrs) {
		OPC_EndBlk();
		OPM_WriteLn();
	}
}

void OPC_EnterBody (void)
{
	OPM_WriteLn();
	OPM_WriteString((CHAR*)"export ", 8);
	if (__IN(10, OPM_Options, 32)) {
		OPM_WriteString((CHAR*)"int main(int argc, char **argv)", 32);
		OPM_WriteLn();
	} else {
		OPM_WriteString((CHAR*)"void *", 7);
		OPM_WriteString(OPM_modName, 32);
		OPM_WriteString(OPC_BodyNameExt, 13);
		OPM_WriteLn();
	}
	OPC_BegBlk();
	OPC_BegStat();
	if (__IN(10, OPM_Options, 32)) {
		OPM_WriteString((CHAR*)"__INIT(argc, argv)", 19);
	} else {
		OPM_WriteString((CHAR*)"__DEFMOD", 9);
	}
	OPC_EndStat();
	if ((__IN(10, OPM_Options, 32) && 0)) {
		OPC_BegStat();
		OPM_WriteString((CHAR*)"/*don`t do it!*/ printf(\"DEMO VERSION: DO NOT USE THIS PROGRAM FOR ANY COMMERCIAL PURPOSE\\n\")", 94);
		OPC_EndStat();
	}
	OPC_InitImports(OPT_topScope->right);
	OPC_BegStat();
	if (__IN(10, OPM_Options, 32)) {
		OPM_WriteString((CHAR*)"__REGMAIN(\"", 12);
	} else {
		OPM_WriteString((CHAR*)"__REGMOD(\"", 11);
	}
	OPM_WriteString(OPM_modName, 32);
	if (OPC_GlbPtrs) {
		OPM_WriteString((CHAR*)"\", EnumPtrs)", 13);
	} else {
		OPM_WriteString((CHAR*)"\", 0)", 6);
	}
	OPC_EndStat();
	if (__STRCMP(OPM_modName, "SYSTEM") != 0) {
		OPC_RegCmds(OPT_topScope);
	}
}

void OPC_ExitBody (void)
{
	OPC_BegStat();
	if (__IN(10, OPM_Options, 32)) {
		OPM_WriteString((CHAR*)"__FINI;", 8);
	} else {
		OPM_WriteString((CHAR*)"__ENDMOD;", 10);
	}
	OPM_WriteLn();
	OPC_EndBlk();
}

void OPC_DefineInter (OPT_Object proc)
{
	OPT_Object scope = NIL;
	scope = proc->scope;
	OPM_WriteString((CHAR*)"static ", 8);
	OPM_WriteString((CHAR*)"struct ", 8);
	OPM_WriteStringVar((void*)scope->name, 256);
	OPM_Write(' ');
	OPC_BegBlk();
	OPC_IdentList(proc->link, 3);
	OPC_IdentList(scope->scope, 3);
	OPC_BegStat();
	OPM_WriteString((CHAR*)"struct ", 8);
	OPM_WriteStringVar((void*)scope->name, 256);
	OPM_Write(' ');
	OPM_Write('*');
	OPM_WriteString((CHAR*)"lnk", 4);
	OPC_EndStat();
	OPC_EndBlk0();
	OPM_Write(' ');
	OPM_Write('*');
	OPM_WriteStringVar((void*)scope->name, 256);
	OPM_WriteString((CHAR*)"_s", 3);
	OPC_EndStat();
	OPM_WriteLn();
	OPC_ProcPredefs(scope->right, 0);
	OPM_WriteLn();
}

BOOLEAN OPC_NeedsRetval (OPT_Object proc)
{
	return (proc->typ != OPT_notyp && !proc->scope->leaf);
}

void OPC_EnterProc (OPT_Object proc)
{
	OPT_Object var = NIL, scope = NIL;
	OPT_Struct typ = NIL;
	INT16 dim;
	if (proc->vis != 1) {
		OPM_WriteString((CHAR*)"static ", 8);
	}
	OPC_ProcHeader(proc, 1);
	OPC_BegBlk();
	scope = proc->scope;
	OPC_IdentList(scope->scope, 0);
	if (!scope->leaf) {
		OPC_BegStat();
		OPM_WriteString((CHAR*)"struct ", 8);
		OPM_WriteStringVar((void*)scope->name, 256);
		OPM_Write(' ');
		OPM_WriteString((CHAR*)"_s", 3);
		OPC_EndStat();
	}
	if (OPC_NeedsRetval(proc)) {
		OPC_BegStat();
		OPC_Ident(proc->typ->strobj);
		OPM_WriteString((CHAR*)" __retval", 10);
		OPC_EndStat();
	}
	var = proc->link;
	while (var != NIL) {
		if ((var->typ->comp == 2 && var->mode == 1)) {
			OPC_BegStat();
			if (var->typ->strobj == NIL) {
				OPM_Mark(200, var->typ->txtpos);
			} else {
				OPC_Ident(var->typ->strobj);
			}
			OPM_Write(' ');
			OPC_Ident(var);
			OPM_WriteString((CHAR*)"__copy", 7);
			OPC_EndStat();
		}
		var = var->link;
	}
	var = proc->link;
	while (var != NIL) {
		if ((((__IN(var->typ->comp, 0x0c, 32) && var->mode == 1)) && var->typ->sysflag == 0)) {
			OPC_BegStat();
			if (var->typ->comp == 2) {
				OPM_WriteString((CHAR*)"__DUPARR(", 10);
				OPC_Ident(var);
				OPM_WriteString((CHAR*)", ", 3);
				if (var->typ->strobj == NIL) {
					OPM_Mark(200, var->typ->txtpos);
				} else {
					OPC_Ident(var->typ->strobj);
				}
			} else {
				OPM_WriteString((CHAR*)"__DUP(", 7);
				OPC_Ident(var);
				OPM_WriteString((CHAR*)", ", 3);
				OPC_Ident(var);
				OPM_WriteString((CHAR*)"__len", 6);
				typ = var->typ->BaseTyp;
				dim = 1;
				while (typ->comp == 3) {
					OPM_WriteString((CHAR*)" * ", 4);
					OPC_Ident(var);
					OPM_WriteString((CHAR*)"__len", 6);
					OPM_WriteInt(dim);
					typ = typ->BaseTyp;
					dim += 1;
				}
				OPM_WriteString((CHAR*)", ", 3);
				if (typ->strobj == NIL) {
					OPM_Mark(200, typ->txtpos);
				} else {
					OPC_Ident(typ->strobj);
				}
			}
			OPM_Write(')');
			OPC_EndStat();
		}
		var = var->link;
	}
	if (!scope->leaf) {
		var = proc->link;
		while (var != NIL) {
			if (!var->leaf) {
				OPC_BegStat();
				OPM_WriteString((CHAR*)"_s", 3);
				OPM_Write('.');
				OPC_Ident(var);
				OPM_WriteString((CHAR*)" = ", 4);
				if (__IN(var->typ->comp, 0x0c, 32)) {
					OPM_WriteString((CHAR*)"(void*)", 8);
				} else if (var->mode != 2) {
					OPM_Write('&');
				}
				OPC_Ident(var);
				if (var->typ->comp == 3) {
					typ = var->typ;
					dim = 0;
					do {
						OPM_WriteString((CHAR*)"; ", 3);
						OPM_WriteString((CHAR*)"_s", 3);
						OPM_Write('.');
						OPC_Ident(var);
						OPM_WriteString((CHAR*)"__len", 6);
						if (dim != 0) {
							OPM_WriteInt(dim);
						}
						OPM_WriteString((CHAR*)" = ", 4);
						OPC_Ident(var);
						OPM_WriteString((CHAR*)"__len", 6);
						if (dim != 0) {
							OPM_WriteInt(dim);
						}
						typ = typ->BaseTyp;
					} while (!(typ->comp != 3));
				} else if ((var->mode == 2 && var->typ->comp == 4)) {
					OPM_WriteString((CHAR*)"; ", 3);
					OPM_WriteString((CHAR*)"_s", 3);
					OPM_Write('.');
					OPC_Ident(var);
					OPM_WriteString((CHAR*)"__typ", 6);
					OPM_WriteString((CHAR*)" = ", 4);
					OPC_Ident(var);
					OPM_WriteString((CHAR*)"__typ", 6);
				}
				OPC_EndStat();
			}
			var = var->link;
		}
		var = scope->scope;
		while (var != NIL) {
			if (!var->leaf) {
				OPC_BegStat();
				OPM_WriteString((CHAR*)"_s", 3);
				OPM_Write('.');
				OPC_Ident(var);
				OPM_WriteString((CHAR*)" = ", 4);
				if (var->typ->comp != 2) {
					OPM_Write('&');
				} else {
					OPM_WriteString((CHAR*)"(void*)", 8);
				}
				OPC_Ident(var);
				OPC_EndStat();
			}
			var = var->link;
		}
		OPC_BegStat();
		OPM_WriteString((CHAR*)"_s", 3);
		OPM_Write('.');
		OPM_WriteString((CHAR*)"lnk", 4);
		OPM_WriteString((CHAR*)" = ", 4);
		OPM_WriteStringVar((void*)scope->name, 256);
		OPM_WriteString((CHAR*)"_s", 3);
		OPC_EndStat();
		OPC_BegStat();
		OPM_WriteStringVar((void*)scope->name, 256);
		OPM_WriteString((CHAR*)"_s", 3);
		OPM_WriteString((CHAR*)" = ", 4);
		OPM_Write('&');
		OPM_WriteString((CHAR*)"_s", 3);
		OPC_EndStat();
	}
}

void OPC_ExitProc (OPT_Object proc, BOOLEAN eoBlock, BOOLEAN implicitRet)
{
	OPT_Object var = NIL;
	BOOLEAN indent;
	indent = eoBlock;
	if ((implicitRet && proc->typ != OPT_notyp)) {
		OPM_Write(0x09);
		OPM_WriteString((CHAR*)"__RETCHK;", 10);
		OPM_WriteLn();
	} else if (!eoBlock || implicitRet) {
		if (!proc->scope->leaf) {
			if (indent) {
				OPC_BegStat();
			} else {
				indent = 1;
			}
			OPM_WriteStringVar((void*)proc->scope->name, 256);
			OPM_WriteString((CHAR*)"_s", 3);
			OPM_WriteString((CHAR*)" = ", 4);
			OPM_WriteString((CHAR*)"_s", 3);
			OPM_Write('.');
			OPM_WriteString((CHAR*)"lnk", 4);
			OPC_EndStat();
		}
		var = proc->link;
		while (var != NIL) {
			if ((((var->typ->comp == 3 && var->mode == 1)) && var->typ->sysflag == 0)) {
				if (indent) {
					OPC_BegStat();
				} else {
					indent = 1;
				}
				OPM_WriteString((CHAR*)"__DEL(", 7);
				OPC_Ident(var);
				OPM_Write(')');
				OPC_EndStat();
			}
			var = var->link;
		}
	}
	if (eoBlock) {
		OPC_EndBlk();
		OPM_WriteLn();
	} else if (indent) {
		OPC_BegStat();
	}
}

void OPC_CompleteIdent (OPT_Object obj)
{
	INT16 comp, level;
	level = obj->mnolev;
	if (obj->adr == 1) {
		if (obj->typ->comp == 4) {
			OPC_Ident(obj);
			OPM_WriteString((CHAR*)"__", 3);
		} else {
			OPM_WriteString((CHAR*)"(*(", 4);
			OPC_Ident(obj->typ->strobj);
			OPM_WriteString((CHAR*)"*)&", 4);
			OPC_Ident(obj);
			OPM_Write(')');
		}
	} else if ((level != OPM_level && level > 0)) {
		comp = obj->typ->comp;
		if ((obj->mode != 2 && comp != 3)) {
			OPM_Write('*');
		}
		OPM_WriteStringVar((void*)obj->scope->name, 256);
		OPM_WriteString((CHAR*)"_s", 3);
		OPM_WriteString((CHAR*)"->", 3);
		OPC_Ident(obj);
	} else {
		OPC_Ident(obj);
	}
}

void OPC_TypeOf (OPT_Object ap)
{
	INT16 i;
	__ASSERT(ap->typ->comp == 4, 0);
	if (ap->mode == 2) {
		if ((INT16)ap->mnolev != OPM_level) {
			OPM_WriteStringVar((void*)ap->scope->name, 256);
			OPM_WriteString((CHAR*)"_s->", 5);
			OPC_Ident(ap);
		} else {
			OPC_Ident(ap);
		}
		OPM_WriteString((CHAR*)"__typ", 6);
	} else if (ap->typ->strobj != NIL) {
		OPC_Ident(ap->typ->strobj);
		OPM_WriteString((CHAR*)"__typ", 6);
	} else {
		OPC_Andent(ap->typ);
	}
}

void OPC_Cmp (INT16 rel)
{
	switch (rel) {
		case 9: 
			OPM_WriteString((CHAR*)" == ", 5);
			break;
		case 10: 
			OPM_WriteString((CHAR*)" != ", 5);
			break;
		case 11: 
			OPM_WriteString((CHAR*)" < ", 4);
			break;
		case 12: 
			OPM_WriteString((CHAR*)" <= ", 5);
			break;
		case 13: 
			OPM_WriteString((CHAR*)" > ", 4);
			break;
		case 14: 
			OPM_WriteString((CHAR*)" >= ", 5);
			break;
		default: 
			OPM_LogWStr((CHAR*)"unhandled case in OPC.Cmp, rel = ", 34);
			OPM_LogWNum(rel, 0);
			OPM_LogWLn();
			break;
	}
}

static void OPC_CharacterLiteral (INT64 c)
{
	if (c < 32 || c > 126) {
		OPM_WriteString((CHAR*)"0x", 3);
		OPM_WriteHex(c);
	} else {
		OPM_Write('\'');
		if ((c == 92 || c == 39) || c == 63) {
			OPM_Write('\\');
		}
		OPM_Write((CHAR)c);
		OPM_Write('\'');
	}
}

static void OPC_StringLiteral (CHAR *s, ADDRESS s__len, INT32 l)
{
	INT32 i;
	INT16 c;
	__DUP(s, s__len, CHAR);
	OPM_Write('"');
	i = 0;
	while (i < l) {
		c = (INT16)s[__X(i, s__len)];
		if (c < 32 || c > 126) {
			OPM_Write('\\');
			OPM_Write((CHAR)(48 + __ASHR(c, 6)));
			c = __MASK(c, -64);
			OPM_Write((CHAR)(48 + __ASHR(c, 3)));
			c = __MASK(c, -8);
			OPM_Write((CHAR)(48 + c));
		} else {
			if ((c == 92 || c == 34) || c == 63) {
				OPM_Write('\\');
			}
			OPM_Write((CHAR)c);
		}
		i += 1;
	}
	OPM_Write('"');
	__DEL(s);
}

void OPC_Case (INT64 caseVal, INT16 form)
{
	CHAR ch;
	OPM_WriteString((CHAR*)"case ", 6);
	switch (form) {
		case 3: 
			OPC_CharacterLiteral(caseVal);
			break;
		case 4: 
			OPM_WriteInt(caseVal);
			break;
		default: 
			OPM_LogWStr((CHAR*)"unhandled case in OPC.Case, form = ", 36);
			OPM_LogWNum(form, 0);
			OPM_LogWLn();
			break;
	}
	OPM_WriteString((CHAR*)": ", 3);
}

void OPC_SetInclude (BOOLEAN exclude)
{
	if (exclude) {
		OPM_WriteString((CHAR*)" &= ~", 6);
	} else {
		OPM_WriteString((CHAR*)" |= ", 5);
	}
}

void OPC_Increment (BOOLEAN decrement)
{
	if (decrement) {
		OPM_WriteString((CHAR*)" -= ", 5);
	} else {
		OPM_WriteString((CHAR*)" += ", 5);
	}
}

void OPC_Halt (INT32 n)
{
	OPC_Str1((CHAR*)"__HALT(#)", 10, n);
}

void OPC_IntLiteral (INT64 n, INT32 size)
{
	if ((((size > 4 && n <= 2147483647)) && n > (-2147483647-1))) {
		OPM_WriteString((CHAR*)"((INT", 6);
		OPM_WriteInt(__ASHL(size, 3));
		OPM_WriteString((CHAR*)")(", 3);
		OPM_WriteInt(n);
		OPM_WriteString((CHAR*)"))", 3);
	} else {
		OPM_WriteInt(n);
	}
}

void OPC_Len (OPT_Object obj, OPT_Struct array, INT64 dim)
{
	if (array->comp == 3) {
		OPC_CompleteIdent(obj);
		OPM_WriteString((CHAR*)"__len", 6);
		if (dim != 0) {
			OPM_WriteInt(dim);
		}
	} else {
		while (dim > 0) {
			array = array->BaseTyp;
			dim -= 1;
		}
		OPM_WriteInt(array->n);
	}
}

void OPC_Constant (OPT_Const con, INT16 form)
{
	INT16 i;
	UINT64 s;
	INT64 hex;
	BOOLEAN skipLeading;
	switch (form) {
		case 1: 
			OPM_WriteInt(con->intval);
			break;
		case 2: 
			OPM_WriteInt(con->intval);
			break;
		case 3: 
			OPC_CharacterLiteral(con->intval);
			break;
		case 4: 
			OPM_WriteInt(con->intval);
			break;
		case 5: 
			OPM_WriteReal(con->realval, 'f');
			break;
		case 6: 
			OPM_WriteReal(con->realval, 0x00);
			break;
		case 7: 
			OPM_WriteString((CHAR*)"0x", 3);
			skipLeading = 1;
			s = con->setval;
			i = 64;
			do {
				hex = 0;
				do {
					i -= 1;
					hex = __ASHL(hex, 1);
					if (__IN(i, s, 64)) {
						hex += 1;
					}
				} while (!(__MASK(i, -8) == 0));
				if (hex != 0 || !skipLeading) {
					OPM_WriteHex(hex);
					skipLeading = 0;
				}
			} while (!(i == 0));
			if (skipLeading) {
				OPM_Write('0');
			}
			break;
		case 8: 
			OPC_StringLiteral(*con->ext, 256, con->intval2 - 1);
			break;
		case 9: 
			OPM_WriteString((CHAR*)"NIL", 4);
			break;
		default: 
			OPM_LogWStr((CHAR*)"unhandled case in OPC.Constant, form = ", 40);
			OPM_LogWNum(form, 0);
			OPM_LogWLn();
			break;
	}
}

static struct InitKeywords__46 {
	INT8 *n;
	struct InitKeywords__46 *lnk;
} *InitKeywords__46_s;

static void Enter__47 (CHAR *s, ADDRESS s__len);

static void Enter__47 (CHAR *s, ADDRESS s__len)
{
	INT16 h;
	__DUP(s, s__len, CHAR);
	h = OPC_PerfectHash((void*)s, s__len);
	OPC_hashtab[__X(h, 105)] = *InitKeywords__46_s->n;
	__COPY(s, OPC_keytab[__X(*InitKeywords__46_s->n, 50)], 9);
	*InitKeywords__46_s->n += 1;
	__DEL(s);
}

static void OPC_InitKeywords (void)
{
	INT8 n, i;
	struct InitKeywords__46 _s;
	_s.n = &n;
	_s.lnk = InitKeywords__46_s;
	InitKeywords__46_s = &_s;
	n = 0;
	i = 0;
	while (i <= 104) {
		OPC_hashtab[__X(i, 105)] = -1;
		i += 1;
	}
	Enter__47((CHAR*)"ADDRESS", 8);
	Enter__47((CHAR*)"INT16", 6);
	Enter__47((CHAR*)"INT32", 6);
	Enter__47((CHAR*)"INT64", 6);
	Enter__47((CHAR*)"INT8", 5);
	Enter__47((CHAR*)"UINT16", 7);
	Enter__47((CHAR*)"UINT32", 7);
	Enter__47((CHAR*)"UINT64", 7);
	Enter__47((CHAR*)"UINT8", 6);
	Enter__47((CHAR*)"asm", 4);
	Enter__47((CHAR*)"auto", 5);
	Enter__47((CHAR*)"break", 6);
	Enter__47((CHAR*)"case", 5);
	Enter__47((CHAR*)"char", 5);
	Enter__47((CHAR*)"const", 6);
	Enter__47((CHAR*)"continue", 9);
	Enter__47((CHAR*)"default", 8);
	Enter__47((CHAR*)"do", 3);
	Enter__47((CHAR*)"double", 7);
	Enter__47((CHAR*)"else", 5);
	Enter__47((CHAR*)"enum", 5);
	Enter__47((CHAR*)"extern", 7);
	Enter__47((CHAR*)"export", 7);
	Enter__47((CHAR*)"float", 6);
	Enter__47((CHAR*)"for", 4);
	Enter__47((CHAR*)"fortran", 8);
	Enter__47((CHAR*)"goto", 5);
	Enter__47((CHAR*)"if", 3);
	Enter__47((CHAR*)"import", 7);
	Enter__47((CHAR*)"int", 4);
	Enter__47((CHAR*)"long", 5);
	Enter__47((CHAR*)"register", 9);
	Enter__47((CHAR*)"return", 7);
	Enter__47((CHAR*)"short", 6);
	Enter__47((CHAR*)"signed", 7);
	Enter__47((CHAR*)"sizeof", 7);
	Enter__47((CHAR*)"size_t", 7);
	Enter__47((CHAR*)"static", 7);
	Enter__47((CHAR*)"struct", 7);
	Enter__47((CHAR*)"switch", 7);
	Enter__47((CHAR*)"typedef", 8);
	Enter__47((CHAR*)"union", 6);
	Enter__47((CHAR*)"unsigned", 9);
	Enter__47((CHAR*)"void", 5);
	Enter__47((CHAR*)"volatile", 9);
	Enter__47((CHAR*)"while", 6);
	InitKeywords__46_s = _s.lnk;
}


export void *OPC__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Configuration);
	__MODULE_IMPORT(OPM);
	__MODULE_IMPORT(OPT);
	__REGMOD("OPC", 0);
	__REGCMD("BegBlk", OPC_BegBlk);
	__REGCMD("BegStat", OPC_BegStat);
	__REGCMD("EndBlk", OPC_EndBlk);
	__REGCMD("EndBlk0", OPC_EndBlk0);
	__REGCMD("EndStat", OPC_EndStat);
	__REGCMD("EnterBody", OPC_EnterBody);
	__REGCMD("ExitBody", OPC_ExitBody);
	__REGCMD("GenHdrIncludes", OPC_GenHdrIncludes);
	__REGCMD("Init", OPC_Init);
/* BEGIN */
	OPC_InitKeywords();
	__ENDMOD;
}
