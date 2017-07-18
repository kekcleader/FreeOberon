/* voc 2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8. xtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "OPC.h"
#include "OPM.h"
#include "OPS.h"
#include "OPT.h"

typedef
	struct OPV_ExitInfo {
		INT16 level, label;
	} OPV_ExitInfo;


static INT16 OPV_stamp;
static OPV_ExitInfo OPV_exit;
static INT16 OPV_nofExitLabels;

export ADDRESS *OPV_ExitInfo__typ;

static void OPV_ActualPar (OPT_Node n, OPT_Object fp);
export void OPV_AdrAndSize (OPT_Object topScope);
static void OPV_CaseStat (OPT_Node n, OPT_Object outerProc);
static void OPV_Convert (OPT_Node n, OPT_Struct newtype, INT16 prec);
static void OPV_DefineTDescs (OPT_Node n);
static void OPV_Entier (OPT_Node n, INT16 prec);
static void OPV_GetTProcNum (OPT_Object obj);
static void OPV_IfStat (OPT_Node n, BOOLEAN withtrap, OPT_Object outerProc);
static BOOLEAN OPV_ImplicitReturn (OPT_Node n);
static void OPV_Index (OPT_Node n, OPT_Node d, INT16 prec, INT16 dim);
export void OPV_Init (void);
static void OPV_InitTDescs (OPT_Node n);
static void OPV_Len (OPT_Node n, INT64 dim);
export void OPV_Module (OPT_Node prog);
static void OPV_NewArr (OPT_Node d, OPT_Node x);
static void OPV_ParIntLiteral (INT64 n, INT32 size);
static INT16 OPV_Precedence (INT16 class, INT16 subclass, INT16 form, INT16 comp);
static BOOLEAN OPV_SideEffects (OPT_Node n);
static void OPV_SizeCast (OPT_Node n, INT32 to);
static void OPV_Stamp (OPS_Name s);
static OPT_Object OPV_SuperProc (OPT_Node n);
static void OPV_Traverse (OPT_Object obj, OPT_Object outerScope, BOOLEAN exported);
static void OPV_TraverseRecord (OPT_Struct typ);
static void OPV_TypeOf (OPT_Node n);
static void OPV_design (OPT_Node n, INT16 prec);
static void OPV_expr (OPT_Node n, INT16 prec);
static void OPV_stat (OPT_Node n, OPT_Object outerProc);


void OPV_Init (void)
{
	OPV_stamp = 0;
	OPV_nofExitLabels = 0;
}

static void OPV_GetTProcNum (OPT_Object obj)
{
	INT32 oldPos;
	OPT_Struct typ = NIL;
	OPT_Object redef = NIL;
	oldPos = OPM_errpos;
	OPM_errpos = obj->scope->adr;
	typ = obj->link->typ;
	if (typ->form == 11) {
		typ = typ->BaseTyp;
	}
	OPT_FindField(obj->name, typ->BaseTyp, &redef);
	if (redef != NIL) {
		obj->adr = __ASHL(__ASHR(redef->adr, 16), 16);
		if (!__IN(2, obj->conval->setval, 64)) {
			OPM_err(119);
		}
	} else {
		obj->adr += __ASHL(typ->n, 16);
		typ->n += 1;
	}
	OPM_errpos = oldPos;
}

static void OPV_TraverseRecord (OPT_Struct typ)
{
	if (!typ->allocated) {
		if (typ->BaseTyp != NIL) {
			OPV_TraverseRecord(typ->BaseTyp);
			typ->n = typ->BaseTyp->n;
		}
		typ->allocated = 1;
		OPV_Traverse(typ->link, typ->strobj, 0);
	}
}

static void OPV_Stamp (OPS_Name s)
{
	INT16 i, j, k;
	CHAR n[10];
	OPV_stamp += 1;
	i = 0;
	j = OPV_stamp;
	while (s[__X(i, 256)] != 0x00) {
		i += 1;
	}
	if (i > 25) {
		i = 25;
	}
	s[__X(i, 256)] = '_';
	s[__X(i + 1, 256)] = '_';
	i += 2;
	k = 0;
	do {
		n[__X(k, 10)] = (CHAR)((int)__MOD(j, 10) + 48);
		j = __DIV(j, 10);
		k += 1;
	} while (!(j == 0));
	do {
		k -= 1;
		s[__X(i, 256)] = n[__X(k, 10)];
		i += 1;
	} while (!(k == 0));
	s[__X(i, 256)] = 0x00;
}

static void OPV_Traverse (OPT_Object obj, OPT_Object outerScope, BOOLEAN exported)
{
	INT16 mode;
	OPT_Object scope = NIL;
	OPT_Struct typ = NIL;
	if (obj != NIL) {
		OPV_Traverse(obj->left, outerScope, exported);
		if (obj->name[0] == '@') {
			obj->name[0] = '_';
			OPV_Stamp(obj->name);
		}
		obj->linkadr = 0;
		mode = obj->mode;
		if ((mode == 5 && (obj->vis != 0) == exported)) {
			typ = obj->typ;
			OPT_TypSize(obj->typ);
			if (typ->form == 11) {
				typ = typ->BaseTyp;
			}
			if (typ->comp == 4) {
				OPV_TraverseRecord(typ);
			}
		} else if (mode == 13) {
			OPV_GetTProcNum(obj);
		} else if (mode == 1) {
			OPT_TypSize(obj->typ);
		}
		if (!exported) {
			if ((__IN(mode, 0x60, 32) && obj->mnolev > 0)) {
				OPV_Stamp(obj->name);
			}
			if (__IN(mode, 0x26, 32)) {
				obj->scope = outerScope;
			} else if (__IN(mode, 0x26c0, 32)) {
				if (obj->conval->setval == 0x0) {
					OPM_err(129);
				}
				scope = obj->scope;
				scope->leaf = 1;
				__MOVE(obj->name, scope->name, 256);
				OPV_Stamp(scope->name);
				if (mode == 9) {
					obj->adr = 1;
				}
				if (scope->mnolev > 1) {
					outerScope->leaf = 0;
				}
				OPV_Traverse(obj->scope->right, obj->scope, 0);
			}
		}
		OPV_Traverse(obj->right, outerScope, exported);
	}
}

void OPV_AdrAndSize (OPT_Object topScope)
{
	__ASSERT(OPT_sinttyp != NIL, 0);
	__ASSERT(OPT_inttyp != NIL, 0);
	__ASSERT(OPT_linttyp != NIL, 0);
	OPM_errpos = topScope->adr;
	topScope->leaf = 1;
	OPV_Traverse(topScope->right, topScope, 1);
	OPV_Traverse(topScope->right, topScope, 0);
	OPT_chartyp->strobj->linkadr = 2;
	OPT_cpbytetyp->strobj->linkadr = 2;
	OPT_settyp->strobj->linkadr = 2;
	OPT_realtyp->strobj->linkadr = 2;
	OPT_adrtyp->strobj->linkadr = 2;
	OPT_int8typ->strobj->linkadr = 2;
	OPT_int16typ->strobj->linkadr = 2;
	OPT_int32typ->strobj->linkadr = 2;
	OPT_int64typ->strobj->linkadr = 2;
	OPT_set32typ->strobj->linkadr = 2;
	OPT_set64typ->strobj->linkadr = 2;
	OPT_hinttyp->strobj->linkadr = 2;
	OPT_lrltyp->strobj->linkadr = 2;
	OPT_booltyp->strobj->linkadr = 2;
	OPT_bytetyp->strobj->linkadr = 2;
	OPT_sysptrtyp->strobj->linkadr = 2;
}

static INT16 OPV_Precedence (INT16 class, INT16 subclass, INT16 form, INT16 comp)
{
	switch (class) {
		case 7: case 0: case 2: case 4: case 9: 
		case 13: 
			return 10;
			break;
		case 5: 
			if (__IN(3, OPM_Options, 32)) {
				return 10;
			} else {
				return 9;
			}
			break;
		case 1: 
			if (__IN(comp, 0x0c, 32)) {
				return 10;
			} else {
				return 9;
			}
			break;
		case 3: 
			return 9;
			break;
		case 11: 
			switch (subclass) {
				case 33: case 7: case 24: case 29: case 20: 
					return 9;
					break;
				case 16: case 21: case 22: case 23: case 25: 
					return 10;
					break;
				default: 
					OPM_LogWStr((CHAR*)"unhandled case in OPV.Precedence OPT.Nmop, subclass = ", 55);
					OPM_LogWNum(subclass, 0);
					OPM_LogWLn();
					break;
			}
			break;
		case 12: 
			switch (subclass) {
				case 1: 
					if (form == 7) {
						return 4;
					} else {
						return 8;
					}
					break;
				case 2: 
					if (form == 7) {
						return 3;
					} else {
						return 8;
					}
					break;
				case 3: case 4: 
					return 10;
					break;
				case 6: 
					if (form == 7) {
						return 2;
					} else {
						return 7;
					}
					break;
				case 7: 
					if (form == 7) {
						return 4;
					} else {
						return 7;
					}
					break;
				case 11: case 12: case 13: case 14: 
					return 6;
					break;
				case 9: case 10: 
					return 5;
					break;
				case 5: 
					return 1;
					break;
				case 8: 
					return 0;
					break;
				case 19: case 15: case 17: case 18: case 26: 
				case 27: case 28: 
					return 10;
					break;
				default: 
					OPM_LogWStr((CHAR*)"unhandled case in OPV.Precedence OPT.Ndop, subclass = ", 55);
					OPM_LogWNum(subclass, 0);
					OPM_LogWLn();
					break;
			}
			break;
		case 10: 
			return 10;
			break;
		case 8: case 6: 
			return 12;
			break;
		default: 
			OPM_LogWStr((CHAR*)"unhandled case in OPV.Precedence, class = ", 43);
			OPM_LogWNum(class, 0);
			OPM_LogWLn();
			break;
	}
	__RETCHK;
}

static void OPV_Len (OPT_Node n, INT64 dim)
{
	while ((n->class == 4 && n->typ->comp == 3)) {
		dim += 1;
		n = n->left;
	}
	if ((n->class == 3 && n->typ->comp == 3)) {
		OPV_design(n->left, 10);
		OPM_WriteString((CHAR*)"->len[", 7);
		OPM_WriteInt(dim);
		OPM_Write(']');
	} else {
		OPC_Len(n->obj, n->typ, dim);
	}
}

static BOOLEAN OPV_SideEffects (OPT_Node n)
{
	if (n != NIL) {
		return (n->class == 13 || OPV_SideEffects(n->left)) || OPV_SideEffects(n->right);
	} else {
		return 0;
	}
	__RETCHK;
}

static void OPV_Entier (OPT_Node n, INT16 prec)
{
	if (__IN(n->typ->form, 0x60, 32)) {
		OPM_WriteString((CHAR*)"__ENTIER(", 10);
		OPV_expr(n, -1);
		OPM_Write(')');
	} else {
		OPV_expr(n, prec);
	}
}

static void OPV_SizeCast (OPT_Node n, INT32 to)
{
	if ((to < n->typ->size && __IN(2, OPM_Options, 32))) {
		OPM_WriteString((CHAR*)"__SHORT", 8);
		if (OPV_SideEffects(n)) {
			OPM_Write('F');
		}
		OPM_Write('(');
		OPV_Entier(n, -1);
		OPM_WriteString((CHAR*)", ", 3);
		OPM_WriteInt(OPM_SignedMaximum(to) + 1);
		OPM_Write(')');
	} else {
		if ((n->typ->size != to && (n->typ->size > 4 || to != 4))) {
			OPM_WriteString((CHAR*)"(INT", 5);
			OPM_WriteInt(__ASHL(to, 3));
			OPM_WriteString((CHAR*)")", 2);
		}
	}
}

static void OPV_Convert (OPT_Node n, OPT_Struct newtype, INT16 prec)
{
	INT16 from, to;
	from = n->typ->form;
	to = newtype->form;
	if (to == 7) {
		if (from == 7) {
			OPV_SizeCast(n, newtype->size);
			OPV_Entier(n, 9);
		} else {
			OPM_WriteString((CHAR*)"__SETOF(", 9);
			OPV_Entier(n, -1);
			OPM_WriteString((CHAR*)",", 2);
			OPM_WriteInt(__ASHL(newtype->size, 3));
			OPM_Write(')');
		}
	} else if (to == 4) {
		OPV_SizeCast(n, newtype->size);
		OPV_Entier(n, 9);
	} else if (to == 3) {
		if (__IN(2, OPM_Options, 32)) {
			OPM_WriteString((CHAR*)"__CHR", 6);
			if (OPV_SideEffects(n)) {
				OPM_Write('F');
			}
			OPM_Write('(');
			OPV_Entier(n, -1);
			OPM_Write(')');
		} else {
			OPM_WriteString((CHAR*)"(CHAR)", 7);
			OPV_Entier(n, 9);
		}
	} else {
		OPV_expr(n, prec);
	}
}

static void OPV_TypeOf (OPT_Node n)
{
	if (n->typ->form == 11) {
		OPM_WriteString((CHAR*)"__TYPEOF(", 10);
		OPV_expr(n, -1);
		OPM_Write(')');
	} else if (__IN(n->class, 0x15, 32)) {
		OPC_Andent(n->typ);
		OPM_WriteString((CHAR*)"__typ", 6);
	} else if (n->class == 3) {
		OPM_WriteString((CHAR*)"__TYPEOF(", 10);
		OPV_expr(n->left, -1);
		OPM_Write(')');
	} else if (n->class == 5) {
		OPV_TypeOf(n->left);
	} else if ((n->class == 11 && n->subcl == 29)) {
		OPC_TypeOf(n->left->obj);
	} else {
		OPC_TypeOf(n->obj);
	}
}

static void OPV_Index (OPT_Node n, OPT_Node d, INT16 prec, INT16 dim)
{
	if (!__IN(0, OPM_Options, 32) || (n->right->class == 7 && (n->right->conval->intval == 0 || n->left->typ->comp != 3))) {
		OPV_expr(n->right, prec);
	} else {
		if (OPV_SideEffects(n->right)) {
			OPM_WriteString((CHAR*)"__XF(", 6);
		} else {
			OPM_WriteString((CHAR*)"__X(", 5);
		}
		OPV_expr(n->right, -1);
		OPM_WriteString((CHAR*)", ", 3);
		OPV_Len(d, dim);
		OPM_Write(')');
	}
}

static void OPV_design (OPT_Node n, INT16 prec)
{
	OPT_Object obj = NIL;
	OPT_Struct typ = NIL;
	INT16 class, designPrec, comp;
	OPT_Node d = NIL, x = NIL;
	INT16 dims, i, _for__26;
	comp = n->typ->comp;
	obj = n->obj;
	class = n->class;
	designPrec = OPV_Precedence(class, n->subcl, n->typ->form, comp);
	if ((((((class == 0 && obj->mnolev > 0)) && (INT16)obj->mnolev != OPM_level)) && prec == 10)) {
		designPrec = 9;
	}
	if (prec > designPrec) {
		OPM_Write('(');
	}
	if (prec == 11) {
		OPM_Write('*');
	}
	switch (class) {
		case 9: 
			OPC_Ident(n->obj);
			break;
		case 0: 
			OPC_CompleteIdent(n->obj);
			break;
		case 1: 
			if (!__IN(comp, 0x0c, 32)) {
				OPM_Write('*');
			}
			OPC_CompleteIdent(n->obj);
			break;
		case 2: 
			if (n->left->class == 3) {
				OPV_design(n->left->left, designPrec);
				OPM_WriteString((CHAR*)"->", 3);
			} else {
				OPV_design(n->left, designPrec);
				OPM_Write('.');
			}
			OPC_Ident(n->obj);
			break;
		case 3: 
			if (n->typ->comp == 3) {
				OPV_design(n->left, 10);
				OPM_WriteString((CHAR*)"->data", 7);
			} else {
				OPM_Write('*');
				OPV_design(n->left, designPrec);
			}
			break;
		case 4: 
			d = n->left;
			if (d->typ->comp == 3) {
				dims = 0;
				while (d->class == 4) {
					d = d->left;
					dims += 1;
				}
				if (n->typ->comp == 3) {
					OPM_Write('&');
				}
				OPV_design(d, designPrec);
				OPM_Write('[');
				if (n->typ->comp == 3) {
					OPM_Write('(');
				}
				i = dims;
				x = n;
				while (x != d) {
					if (x->left != d) {
						OPV_Index(x, d, 7, i);
						OPM_WriteString((CHAR*)" + ", 4);
						OPV_Len(d, i);
						OPM_WriteString((CHAR*)" * (", 5);
						i -= 1;
					} else {
						OPV_Index(x, d, -1, i);
					}
					x = x->left;
				}
				_for__26 = dims;
				i = 1;
				while (i <= _for__26) {
					OPM_Write(')');
					i += 1;
				}
				if (n->typ->comp == 3) {
					OPM_Write(')');
					while (i < __ASHR(d->typ->size - 4, 2)) {
						OPM_WriteString((CHAR*)" * ", 4);
						OPV_Len(d, i);
						i += 1;
					}
				}
				OPM_Write(']');
			} else {
				OPV_design(n->left, designPrec);
				OPM_Write('[');
				OPV_Index(n, n->left, -1, 0);
				OPM_Write(']');
			}
			break;
		case 5: 
			typ = n->typ;
			obj = n->left->obj;
			if (__IN(3, OPM_Options, 32)) {
				if (typ->comp == 4) {
					OPM_WriteString((CHAR*)"__GUARDR(", 10);
					if ((INT16)obj->mnolev != OPM_level) {
						OPM_WriteStringVar((void*)obj->scope->name, 256);
						OPM_WriteString((CHAR*)"__curr->", 9);
						OPC_Ident(obj);
					} else {
						OPC_Ident(obj);
					}
				} else {
					if (typ->BaseTyp->strobj == NIL) {
						OPM_WriteString((CHAR*)"__GUARDA(", 10);
					} else {
						OPM_WriteString((CHAR*)"__GUARDP(", 10);
					}
					OPV_expr(n->left, -1);
					typ = typ->BaseTyp;
				}
				OPM_WriteString((CHAR*)", ", 3);
				OPC_Andent(typ);
				OPM_WriteString((CHAR*)", ", 3);
				OPM_WriteInt(typ->extlev);
				OPM_Write(')');
			} else {
				if (typ->comp == 4) {
					OPM_WriteString((CHAR*)"*(", 3);
					OPC_Ident(typ->strobj);
					OPM_WriteString((CHAR*)"*)", 3);
					OPC_CompleteIdent(obj);
				} else {
					OPM_Write('(');
					OPC_Ident(typ->strobj);
					OPM_Write(')');
					OPV_expr(n->left, designPrec);
				}
			}
			break;
		case 6: 
			if (__IN(3, OPM_Options, 32)) {
				if (n->left->class == 1) {
					OPM_WriteString((CHAR*)"__GUARDEQR(", 12);
					OPC_CompleteIdent(n->left->obj);
					OPM_WriteString((CHAR*)", ", 3);
					OPV_TypeOf(n->left);
				} else {
					OPM_WriteString((CHAR*)"__GUARDEQP(", 12);
					OPV_expr(n->left->left, -1);
				}
				OPM_WriteString((CHAR*)", ", 3);
				OPC_Ident(n->left->typ->strobj);
				OPM_Write(')');
			} else {
				OPV_expr(n->left, -1);
			}
			break;
		case 11: 
			if (n->subcl == 29) {
				OPV_design(n->left, prec);
			}
			break;
		default: 
			OPM_LogWStr((CHAR*)"unhandled case in OPV.design, class = ", 39);
			OPM_LogWNum(class, 0);
			OPM_LogWLn();
			break;
	}
	if (prec > designPrec) {
		OPM_Write(')');
	}
}

static void OPV_ParIntLiteral (INT64 n, INT32 size)
{
	OPM_WriteInt(n);
}

static void OPV_ActualPar (OPT_Node n, OPT_Object fp)
{
	OPT_Struct typ = NIL, aptyp = NIL;
	INT16 comp, form, mode, prec, dim;
	OPM_Write('(');
	while (n != NIL) {
		typ = fp->typ;
		comp = typ->comp;
		form = typ->form;
		mode = fp->mode;
		prec = -1;
		if ((((mode == 2 && n->class == 11)) && n->subcl == 29)) {
			OPM_Write('(');
			OPC_Ident(n->typ->strobj);
			OPM_WriteString((CHAR*)"*)", 3);
			prec = 10;
		}
		if (!__IN(n->typ->comp, 0x0c, 32)) {
			if (mode == 2) {
				if (typ != n->typ) {
					OPM_WriteString((CHAR*)"(void*)", 8);
				}
				OPM_Write('&');
				prec = 9;
			} else {
				if ((__IN(comp, 0x0c, 32) && n->class == 7)) {
					OPM_WriteString((CHAR*)"(CHAR*)", 8);
				} else if ((((form == 11 && typ != n->typ)) && n->typ != OPT_niltyp)) {
					OPM_WriteString((CHAR*)"(void*)", 8);
				}
			}
		} else {
			if ((((mode == 2 && typ != n->typ)) && prec == -1)) {
				OPM_WriteString((CHAR*)"(void*)", 8);
			}
		}
		if ((((mode == 2 && n->class == 11)) && n->subcl == 29)) {
			OPV_expr(n->left, prec);
		} else if ((form == 4 && n->class == 7)) {
			OPV_ParIntLiteral(n->conval->intval, n->typ->size);
		} else {
			OPV_expr(n, prec);
		}
		if ((comp == 4 && mode == 2)) {
			OPM_WriteString((CHAR*)", ", 3);
			OPV_TypeOf(n);
		} else if (comp == 3) {
			if (n->class == 7) {
				OPM_WriteString((CHAR*)", ", 3);
				OPV_ParIntLiteral(n->conval->intval2, OPM_AddressSize);
			} else {
				aptyp = n->typ;
				dim = 0;
				while ((typ->comp == 3 && typ->BaseTyp->form != 1)) {
					OPM_WriteString((CHAR*)", ", 3);
					OPV_Len(n, dim);
					typ = typ->BaseTyp;
					aptyp = aptyp->BaseTyp;
					dim += 1;
				}
				if ((typ->comp == 3 && typ->BaseTyp->form == 1)) {
					OPM_WriteString((CHAR*)", ", 3);
					while (aptyp->comp == 3) {
						OPV_Len(n, dim);
						OPM_WriteString((CHAR*)" * ", 4);
						dim += 1;
						aptyp = aptyp->BaseTyp;
					}
					OPV_ParIntLiteral(aptyp->size, OPM_AddressSize);
				}
			}
		}
		n = n->link;
		fp = fp->link;
		if (n != NIL) {
			OPM_WriteString((CHAR*)", ", 3);
		}
	}
	OPM_Write(')');
}

static OPT_Object OPV_SuperProc (OPT_Node n)
{
	OPT_Object obj = NIL;
	OPT_Struct typ = NIL;
	typ = n->right->typ;
	if (typ->form == 11) {
		typ = typ->BaseTyp;
	}
	OPT_FindField(n->left->obj->name, typ->BaseTyp, &obj);
	return obj;
}

static void OPV_expr (OPT_Node n, INT16 prec)
{
	INT16 class, subclass, form, exprPrec;
	OPT_Struct typ = NIL;
	OPT_Node l = NIL, r = NIL;
	OPT_Object proc = NIL;
	class = n->class;
	subclass = n->subcl;
	form = n->typ->form;
	l = n->left;
	r = n->right;
	exprPrec = OPV_Precedence(class, subclass, form, n->typ->comp);
	if ((exprPrec <= prec && __IN(class, 0x3ce0, 32))) {
		OPM_Write('(');
	}
	switch (class) {
		case 7: 
			OPC_Constant(n->conval, form);
			break;
		case 10: 
			OPM_WriteString((CHAR*)"__SETRNG(", 10);
			OPV_expr(l, -1);
			OPM_WriteString((CHAR*)", ", 3);
			OPV_expr(r, -1);
			OPM_WriteString((CHAR*)", ", 3);
			OPM_WriteInt(__ASHL(n->typ->size, 3));
			OPM_Write(')');
			break;
		case 11: 
			switch (subclass) {
				case 33: 
					OPM_Write('!');
					OPV_expr(l, exprPrec);
					break;
				case 7: 
					if (form == 7) {
						OPM_Write('~');
					} else {
						OPM_Write('-');
					}
					OPV_expr(l, exprPrec);
					break;
				case 16: 
					typ = n->obj->typ;
					if (l->typ->comp == 4) {
						OPM_WriteString((CHAR*)"__IS(", 6);
						OPC_TypeOf(l->obj);
					} else {
						OPM_WriteString((CHAR*)"__ISP(", 7);
						OPV_expr(l, -1);
						typ = typ->BaseTyp;
					}
					OPM_WriteString((CHAR*)", ", 3);
					OPC_Andent(typ);
					OPM_WriteString((CHAR*)", ", 3);
					OPM_WriteInt(typ->extlev);
					OPM_Write(')');
					break;
				case 20: 
					OPV_Convert(l, n->typ, exprPrec);
					break;
				case 21: 
					if (OPV_SideEffects(l)) {
						if (l->typ->form < 5) {
							if (l->typ->size <= 4) {
								OPM_WriteString((CHAR*)"(int)", 6);
							}
							OPM_WriteString((CHAR*)"__ABSF(", 8);
						} else {
							OPM_WriteString((CHAR*)"__ABSFD(", 9);
						}
					} else {
						OPM_WriteString((CHAR*)"__ABS(", 7);
					}
					OPV_expr(l, -1);
					OPM_Write(')');
					break;
				case 22: 
					OPM_WriteString((CHAR*)"__CAP(", 7);
					OPV_expr(l, -1);
					OPM_Write(')');
					break;
				case 23: 
					OPM_WriteString((CHAR*)"__ODD(", 7);
					OPV_expr(l, -1);
					OPM_Write(')');
					break;
				case 24: 
					OPM_WriteString((CHAR*)"(ADDRESS)", 10);
					if (l->class == 1) {
						OPC_CompleteIdent(l->obj);
					} else {
						if ((l->typ->form != 8 && !__IN(l->typ->comp, 0x0c, 32))) {
							OPM_Write('&');
						}
						OPV_expr(l, exprPrec);
					}
					break;
				case 29: 
					if (!__IN(l->class, 0x17, 32) || (((__IN(n->typ->form, 0x1890, 32) && __IN(l->typ->form, 0x1890, 32))) && n->typ->size == l->typ->size)) {
						OPM_Write('(');
						OPC_Ident(n->typ->strobj);
						OPM_Write(')');
						if (__IN(n->typ->form, 0x1800, 32) || __IN(l->typ->form, 0x1800, 32)) {
							OPM_WriteString((CHAR*)"(ADDRESS)", 10);
						}
						OPV_expr(l, exprPrec);
					} else {
						OPM_WriteString((CHAR*)"__VAL(", 7);
						OPC_Ident(n->typ->strobj);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_expr(l, -1);
						OPM_Write(')');
					}
					break;
				default: 
					OPM_err(200);
					break;
			}
			break;
		case 12: 
			switch (subclass) {
				case 19: 
					OPV_Len(l, r->conval->intval);
					break;
				case 15: case 17: case 18: case 26: case 27: 
				case 28: case 3: case 4: 
					switch (subclass) {
						case 15: 
							OPM_WriteString((CHAR*)"__IN(", 6);
							break;
						case 17: 
							if (r->class == 7) {
								if (r->conval->intval >= 0) {
									OPM_WriteString((CHAR*)"__ASHL(", 8);
								} else {
									OPM_WriteString((CHAR*)"__ASHR(", 8);
								}
							} else if (OPV_SideEffects(r)) {
								OPM_WriteString((CHAR*)"__ASHF(", 8);
							} else {
								OPM_WriteString((CHAR*)"__ASH(", 7);
							}
							break;
						case 18: 
							OPM_WriteString((CHAR*)"__MASK(", 8);
							break;
						case 26: 
							OPM_WriteString((CHAR*)"__BIT(", 7);
							break;
						case 27: 
							if (r->class == 7) {
								if (r->conval->intval >= 0) {
									OPM_WriteString((CHAR*)"__LSHL(", 8);
								} else {
									OPM_WriteString((CHAR*)"__LSHR(", 8);
								}
							} else {
								OPM_WriteString((CHAR*)"__LSH(", 7);
							}
							break;
						case 28: 
							if (r->class == 7) {
								if (r->conval->intval >= 0) {
									OPM_WriteString((CHAR*)"__ROTL(", 8);
								} else {
									OPM_WriteString((CHAR*)"__ROTR(", 8);
								}
							} else {
								OPM_WriteString((CHAR*)"__ROT(", 7);
							}
							break;
						case 3: 
							if (OPV_SideEffects(n)) {
								if (n->typ->size <= 4) {
									OPM_WriteString((CHAR*)"(int)", 6);
								}
								OPM_WriteString((CHAR*)"__DIVF(", 8);
							} else {
								OPM_WriteString((CHAR*)"__DIV(", 7);
							}
							break;
						case 4: 
							if (n->typ->size <= 4) {
								OPM_WriteString((CHAR*)"(int)", 6);
							}
							if (OPV_SideEffects(n)) {
								OPM_WriteString((CHAR*)"__MODF(", 8);
							} else {
								OPM_WriteString((CHAR*)"__MOD(", 7);
							}
							break;
						default: 
							OPM_LogWStr((CHAR*)"unhandled case in OPV.expr, subclass = ", 40);
							OPM_LogWNum(subclass, 0);
							OPM_LogWLn();
							break;
					}
					OPV_expr(l, -1);
					OPM_WriteString((CHAR*)", ", 3);
					if ((((__IN(subclass, 0x18020000, 32) && r->class == 7)) && r->conval->intval < 0)) {
						OPM_WriteInt(-r->conval->intval);
					} else {
						OPV_expr(r, -1);
					}
					if (__IN(subclass, 0x18008000, 32)) {
						OPM_WriteString((CHAR*)", ", 3);
						if (subclass == 15) {
							OPM_WriteInt(__ASHL(r->typ->size, 3));
						} else {
							OPM_WriteInt(__ASHL(l->typ->size, 3));
						}
					}
					OPM_Write(')');
					break;
				case 9: case 10: case 11: case 12: case 13: 
				case 14: 
					if (__IN(l->typ->form, 0x2100, 32)) {
						OPM_WriteString((CHAR*)"__STRCMP(", 10);
						OPV_expr(l, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_expr(r, -1);
						OPM_Write(')');
						OPC_Cmp(subclass);
						OPM_Write('0');
					} else {
						OPV_expr(l, exprPrec);
						OPC_Cmp(subclass);
						typ = l->typ;
						if ((((((typ->form == 11 && r->typ->form != 9)) && r->typ != typ)) && r->typ != OPT_sysptrtyp)) {
							OPM_WriteString((CHAR*)"(void *) ", 10);
						}
						OPV_expr(r, exprPrec);
					}
					break;
				default: 
					if (subclass == 5 || (form == 7 && (subclass == 1 || subclass == 7))) {
						OPM_Write('(');
					}
					OPV_expr(l, exprPrec);
					switch (subclass) {
						case 1: 
							if (form == 7) {
								OPM_WriteString((CHAR*)" & ", 4);
							} else {
								OPM_WriteString((CHAR*)" * ", 4);
							}
							break;
						case 2: 
							if (form == 7) {
								OPM_WriteString((CHAR*)" ^ ", 4);
							} else {
								OPM_WriteString((CHAR*)" / ", 4);
								if (r->obj == NIL || r->obj->typ->form == 4) {
									OPM_Write('(');
									OPC_Ident(n->typ->strobj);
									OPM_Write(')');
								}
							}
							break;
						case 5: 
							OPM_WriteString((CHAR*)" && ", 5);
							break;
						case 6: 
							if (form == 7) {
								OPM_WriteString((CHAR*)" | ", 4);
							} else {
								OPM_WriteString((CHAR*)" + ", 4);
							}
							break;
						case 7: 
							if (form == 7) {
								OPM_WriteString((CHAR*)" & ~", 5);
							} else {
								OPM_WriteString((CHAR*)" - ", 4);
							}
							break;
						case 8: 
							OPM_WriteString((CHAR*)" || ", 5);
							break;
						default: 
							OPM_LogWStr((CHAR*)"unhandled case in OPV.expr, subclass = ", 40);
							OPM_LogWNum(subclass, 0);
							OPM_LogWLn();
							break;
					}
					OPV_expr(r, exprPrec);
					if (subclass == 5 || (form == 7 && (subclass == 1 || subclass == 7))) {
						OPM_Write(')');
					}
					break;
			}
			break;
		case 13: 
			if ((l->obj != NIL && l->obj->mode == 13)) {
				if (l->subcl == 1) {
					proc = OPV_SuperProc(n);
				} else {
					OPM_WriteString((CHAR*)"__", 3);
					proc = OPC_BaseTProc(l->obj);
				}
				OPC_Ident(proc);
				n->obj = proc->link;
			} else if (l->class == 9) {
				OPV_design(l, 10);
			} else {
				OPV_design(l, 11);
			}
			OPV_ActualPar(r, n->obj);
			break;
		default: 
			OPV_design(n, prec);
			break;
	}
	if ((exprPrec <= prec && __IN(class, 0x3ca0, 32))) {
		OPM_Write(')');
	}
}

static void OPV_IfStat (OPT_Node n, BOOLEAN withtrap, OPT_Object outerProc)
{
	OPT_Node if_ = NIL;
	OPT_Object obj = NIL;
	OPT_Struct typ = NIL;
	INT32 adr;
	if_ = n->left;
	while (if_ != NIL) {
		OPM_WriteString((CHAR*)"if ", 4);
		OPV_expr(if_->left, 12);
		OPM_Write(' ');
		OPC_BegBlk();
		if ((n->class == 27 && if_->left->left != NIL)) {
			obj = if_->left->left->obj;
			typ = obj->typ;
			adr = obj->adr;
			if (typ->comp == 4) {
				OPC_BegStat();
				OPC_Ident(if_->left->obj);
				OPM_WriteString((CHAR*)" *", 3);
				OPM_WriteString(obj->name, 256);
				OPM_WriteString((CHAR*)"__ = (void*)", 13);
				obj->adr = 0;
				OPC_CompleteIdent(obj);
				OPC_EndStat();
			}
			obj->adr = 1;
			obj->typ = if_->left->obj->typ;
			OPV_stat(if_->right, outerProc);
			obj->typ = typ;
			obj->adr = adr;
		} else {
			OPV_stat(if_->right, outerProc);
		}
		if_ = if_->link;
		if ((if_ != NIL || n->right != NIL) || withtrap) {
			OPC_EndBlk0();
			OPM_WriteString((CHAR*)" else ", 7);
		} else {
			OPC_EndBlk();
		}
	}
	if (withtrap) {
		OPM_WriteString((CHAR*)"__WITHCHK", 10);
		OPC_EndStat();
	} else if (n->right != NIL) {
		OPC_BegBlk();
		OPV_stat(n->right, outerProc);
		OPC_EndBlk();
	}
}

static void OPV_CaseStat (OPT_Node n, OPT_Object outerProc)
{
	OPT_Node switchCase = NIL, label = NIL;
	INT64 low, high;
	INT16 form, i;
	OPM_WriteString((CHAR*)"switch ", 8);
	OPV_expr(n->left, 12);
	OPM_Write(' ');
	OPC_BegBlk();
	form = n->left->typ->form;
	switchCase = n->right->left;
	while (switchCase != NIL) {
		label = switchCase->left;
		i = 0;
		while (label != NIL) {
			low = label->conval->intval;
			high = label->conval->intval2;
			while (low <= high) {
				if (i == 0) {
					OPC_BegStat();
				}
				OPC_Case(low, form);
				low += 1;
				i += 1;
				if (i == 5) {
					OPM_WriteLn();
					i = 0;
				}
			}
			label = label->link;
		}
		if (i > 0) {
			OPM_WriteLn();
		}
		OPC_Indent(1);
		OPV_stat(switchCase->right, outerProc);
		OPC_BegStat();
		OPM_WriteString((CHAR*)"break", 6);
		OPC_EndStat();
		OPC_Indent(-1);
		switchCase = switchCase->link;
	}
	OPC_BegStat();
	OPM_WriteString((CHAR*)"default: ", 10);
	if (n->right->conval->setval != 0x0) {
		OPC_Indent(1);
		OPM_WriteLn();
		OPV_stat(n->right->right, outerProc);
		OPC_BegStat();
		OPM_WriteString((CHAR*)"break", 6);
		OPC_Indent(-1);
	} else {
		OPM_WriteString((CHAR*)"__CASECHK", 10);
	}
	OPC_EndStat();
	OPC_EndBlk();
}

static BOOLEAN OPV_ImplicitReturn (OPT_Node n)
{
	while ((n != NIL && n->class != 26)) {
		n = n->link;
	}
	return n == NIL;
}

static void OPV_NewArr (OPT_Node d, OPT_Node x)
{
	OPT_Struct typ = NIL, base = NIL;
	INT16 nofdim, nofdyn;
	typ = d->typ->BaseTyp;
	base = typ;
	nofdim = 0;
	nofdyn = 0;
	while (base->comp == 3) {
		nofdim += 1;
		nofdyn += 1;
		base = base->BaseTyp;
	}
	OPV_design(d, -1);
	OPM_WriteString((CHAR*)" = __NEWARR(", 13);
	while (base->comp == 2) {
		nofdim += 1;
		base = base->BaseTyp;
	}
	if ((base->comp == 4 && OPC_NofPtrs(base) != 0)) {
		OPC_Ident(base->strobj);
		OPM_WriteString((CHAR*)"__typ", 6);
	} else if (base->form == 11) {
		OPM_WriteString((CHAR*)"POINTER__typ", 13);
	} else {
		OPM_WriteString((CHAR*)"NIL", 4);
	}
	OPM_WriteString((CHAR*)", ", 3);
	OPM_WriteInt(base->size);
	OPM_WriteString((CHAR*)", ", 3);
	OPM_WriteInt(OPT_BaseAlignment(base));
	OPM_WriteString((CHAR*)", ", 3);
	OPM_WriteInt(nofdim);
	OPM_WriteString((CHAR*)", ", 3);
	OPM_WriteInt(nofdyn);
	while (typ != base) {
		OPM_WriteString((CHAR*)", ", 3);
		if (typ->comp == 3) {
			if (x->class == 7) {
				OPC_IntLiteral(x->conval->intval, OPM_AddressSize);
			} else {
				OPM_WriteString((CHAR*)"((ADDRESS)(", 12);
				OPV_expr(x, 10);
				OPM_WriteString((CHAR*)"))", 3);
			}
			x = x->link;
		} else {
			OPC_IntLiteral(typ->n, OPM_AddressSize);
		}
		typ = typ->BaseTyp;
	}
	OPM_Write(')');
}

static void OPV_DefineTDescs (OPT_Node n)
{
	while ((n != NIL && n->class == 14)) {
		OPC_TDescDecl(n->typ);
		n = n->link;
	}
}

static void OPV_InitTDescs (OPT_Node n)
{
	while ((n != NIL && n->class == 14)) {
		OPC_InitTDesc(n->typ);
		n = n->link;
	}
}

static void OPV_stat (OPT_Node n, OPT_Object outerProc)
{
	OPT_Object proc = NIL;
	OPV_ExitInfo saved;
	OPT_Node l = NIL, r = NIL;
	while ((n != NIL && OPM_noerr)) {
		OPM_errpos = OPM_Longint(n->conval->intval);
		if (n->class != 14) {
			OPC_BegStat();
		}
		switch (n->class) {
			case 18: 
				if (n->obj == NIL) {
					OPM_level += 1;
					OPV_stat(n->left, outerProc);
					OPM_level -= 1;
					OPC_GenEnumPtrs(OPT_topScope->scope);
					OPV_DefineTDescs(n->right);
					OPC_EnterBody();
					OPV_InitTDescs(n->right);
					OPM_WriteString((CHAR*)"/* BEGIN */", 12);
					OPM_WriteLn();
					OPV_stat(n->right, outerProc);
					OPC_ExitBody();
				} else {
					proc = n->obj;
					OPC_TypeDefs(proc->scope->right, 0);
					if (!proc->scope->leaf) {
						OPC_DefineInter(proc);
					}
					OPM_level += 1;
					OPV_stat(n->left, proc);
					OPM_level -= 1;
					OPC_EnterProc(proc);
					OPV_stat(n->right, proc);
					OPC_ExitProc(proc, 1, OPV_ImplicitReturn(n->right));
				}
				break;
			case 14: 
				break;
			case 19: 
				switch (n->subcl) {
					case 0: 
						l = n->left;
						r = n->right;
						if (l->typ->comp == 2) {
							OPM_WriteString((CHAR*)"__MOVE(", 8);
							OPV_expr(r, -1);
							OPM_WriteString((CHAR*)", ", 3);
							OPV_expr(l, -1);
							OPM_WriteString((CHAR*)", ", 3);
							if (r->typ == OPT_stringtyp) {
								OPM_WriteInt(r->conval->intval2);
							} else if (r->typ->comp == 3) {
								OPM_WriteString((CHAR*)"__X(", 5);
								OPC_Len(r->obj, r->typ, 0);
								OPM_WriteString((CHAR*)" * ", 4);
								OPM_WriteInt(r->typ->BaseTyp->size);
								OPM_WriteString((CHAR*)", ", 3);
								OPM_WriteInt(l->typ->size + 1);
								OPM_Write(')');
							} else {
								__ASSERT(r->typ->comp == 2, 0);
								__ASSERT(r->typ->size <= l->typ->size, 0);
								OPM_WriteInt(r->typ->size);
							}
							OPM_Write(')');
						} else {
							if ((((((l->typ->form == 11 && l->obj != NIL)) && l->obj->adr == 1)) && l->obj->mode == 1)) {
								l->obj->adr = 0;
								OPV_design(l, -1);
								l->obj->adr = 1;
								if (r->typ->form != 9) {
									OPM_WriteString((CHAR*)" = (void*)", 11);
								} else {
									OPM_WriteString((CHAR*)" = ", 4);
								}
							} else {
								OPV_design(l, -1);
								OPM_WriteString((CHAR*)" = ", 4);
							}
							if (l->typ == r->typ) {
								OPV_expr(r, -1);
							} else if ((((l->typ->form == 11 && r->typ->form != 9)) && l->typ->strobj != NIL)) {
								OPM_Write('(');
								OPC_Ident(l->typ->strobj);
								OPM_Write(')');
								OPV_expr(r, -1);
							} else if (l->typ->comp == 4) {
								OPM_WriteString((CHAR*)"*(", 3);
								OPC_Andent(l->typ);
								OPM_WriteString((CHAR*)"*)&", 4);
								OPV_expr(r, 9);
							} else {
								OPV_expr(r, -1);
							}
						}
						break;
					case 1: 
						if (n->left->typ->BaseTyp->comp == 4) {
							OPM_WriteString((CHAR*)"__NEW(", 7);
							OPV_design(n->left, -1);
							OPM_WriteString((CHAR*)", ", 3);
							OPC_Andent(n->left->typ->BaseTyp);
							OPM_WriteString((CHAR*)")", 2);
						} else if (__IN(n->left->typ->BaseTyp->comp, 0x0c, 32)) {
							OPV_NewArr(n->left, n->right);
						}
						break;
					case 13: case 14: 
						OPV_expr(n->left, -1);
						OPC_Increment(n->subcl == 14);
						OPV_expr(n->right, -1);
						break;
					case 15: case 16: 
						OPV_expr(n->left, -1);
						OPC_SetInclude(n->subcl == 16);
						OPM_WriteString((CHAR*)"__SETOF(", 9);
						OPV_expr(n->right, -1);
						OPM_WriteString((CHAR*)",", 2);
						OPM_WriteInt(__ASHL(n->left->typ->size, 3));
						OPM_Write(')');
						break;
					case 18: 
						OPM_WriteString((CHAR*)"__COPY(", 8);
						OPV_expr(n->right, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_expr(n->left, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_Len(n->left, 0);
						OPM_Write(')');
						break;
					case 31: 
						OPM_WriteString((CHAR*)"__MOVE(", 8);
						OPV_expr(n->right, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_expr(n->left, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_expr(n->right->link, -1);
						OPM_Write(')');
						break;
					case 24: 
						OPM_WriteString((CHAR*)"__GET(", 7);
						OPV_expr(n->right, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_expr(n->left, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPC_Ident(n->left->typ->strobj);
						OPM_Write(')');
						break;
					case 25: 
						OPM_WriteString((CHAR*)"__PUT(", 7);
						OPV_expr(n->left, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_expr(n->right, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPC_Ident(n->right->typ->strobj);
						OPM_Write(')');
						break;
					case 26: case 27: 
						OPM_err(200);
						break;
					case 30: 
						OPM_WriteString((CHAR*)"__SYSNEW(", 10);
						OPV_design(n->left, -1);
						OPM_WriteString((CHAR*)", ", 3);
						OPV_expr(n->right, -1);
						OPM_Write(')');
						break;
					default: 
						OPM_LogWStr((CHAR*)"unhandled case in OPV.expr, n^.subcl = ", 40);
						OPM_LogWNum(n->subcl, 0);
						OPM_LogWLn();
						break;
				}
				break;
			case 13: 
				if ((n->left->obj != NIL && n->left->obj->mode == 13)) {
					if (n->left->subcl == 1) {
						proc = OPV_SuperProc(n);
					} else {
						OPM_WriteString((CHAR*)"__", 3);
						proc = OPC_BaseTProc(n->left->obj);
					}
					OPC_Ident(proc);
					n->obj = proc->link;
				} else if (n->left->class == 9) {
					OPV_design(n->left, 10);
				} else {
					OPV_design(n->left, 11);
				}
				OPV_ActualPar(n->right, n->obj);
				break;
			case 20: 
				if (n->subcl != 32) {
					OPV_IfStat(n, 0, outerProc);
				} else if (__IN(7, OPM_Options, 32)) {
					OPM_WriteString((CHAR*)"__ASSERT(", 10);
					OPV_expr(n->left->left->left, -1);
					OPM_WriteString((CHAR*)", ", 3);
					OPM_WriteInt(n->left->right->right->conval->intval);
					OPM_Write(')');
					OPC_EndStat();
				}
				break;
			case 21: 
				OPV_exit.level += 1;
				OPV_CaseStat(n, outerProc);
				OPV_exit.level -= 1;
				break;
			case 22: 
				OPV_exit.level += 1;
				OPM_WriteString((CHAR*)"while ", 7);
				OPV_expr(n->left, 12);
				OPM_Write(' ');
				OPC_BegBlk();
				OPV_stat(n->right, outerProc);
				OPC_EndBlk();
				OPV_exit.level -= 1;
				break;
			case 23: 
				OPV_exit.level += 1;
				OPM_WriteString((CHAR*)"do ", 4);
				OPC_BegBlk();
				OPV_stat(n->left, outerProc);
				OPC_EndBlk0();
				OPM_WriteString((CHAR*)" while (!", 10);
				OPV_expr(n->right, 9);
				OPM_Write(')');
				OPV_exit.level -= 1;
				break;
			case 24: 
				saved = OPV_exit;
				OPV_exit.level = 0;
				OPV_exit.label = -1;
				OPM_WriteString((CHAR*)"for (;;) ", 10);
				OPC_BegBlk();
				OPV_stat(n->left, outerProc);
				OPC_EndBlk();
				if (OPV_exit.label != -1) {
					OPC_BegStat();
					OPM_WriteString((CHAR*)"exit__", 7);
					OPM_WriteInt(OPV_exit.label);
					OPM_Write(':');
					OPC_EndStat();
				}
				OPV_exit = saved;
				break;
			case 25: 
				if (OPV_exit.level == 0) {
					OPM_WriteString((CHAR*)"break", 6);
				} else {
					if (OPV_exit.label == -1) {
						OPV_exit.label = OPV_nofExitLabels;
						OPV_nofExitLabels += 1;
					}
					OPM_WriteString((CHAR*)"goto exit__", 12);
					OPM_WriteInt(OPV_exit.label);
				}
				break;
			case 26: 
				if (OPM_level == 0) {
					if (__IN(10, OPM_Options, 32)) {
						OPM_WriteString((CHAR*)"__FINI", 7);
					} else {
						OPM_WriteString((CHAR*)"__ENDMOD", 9);
					}
				} else if (OPC_NeedsRetval(outerProc)) {
					OPM_WriteString((CHAR*)"__retval = ", 12);
					if ((n->left->typ->form == 11 && n->obj->typ != n->left->typ)) {
						OPM_WriteString((CHAR*)"(void*)", 8);
						OPV_expr(n->left, 10);
					} else {
						OPV_expr(n->left, -1);
					}
					OPC_EndStat();
					OPC_BegStat();
					OPC_ExitProc(outerProc, 0, 0);
					OPC_EndStat();
					OPC_BegStat();
					OPM_WriteString((CHAR*)"return __retval", 16);
				} else {
					OPC_ExitProc(outerProc, 0, 0);
					OPM_WriteString((CHAR*)"return", 7);
					if (n->left != NIL) {
						OPM_Write(' ');
						if ((n->left->typ->form == 11 && n->obj->typ != n->left->typ)) {
							OPM_WriteString((CHAR*)"(void*)", 8);
							OPV_expr(n->left, 10);
						} else {
							OPV_expr(n->left, -1);
						}
					}
				}
				break;
			case 27: 
				OPV_IfStat(n, n->subcl == 0, outerProc);
				break;
			case 28: 
				OPC_Halt(OPM_Longint(n->right->conval->intval));
				break;
			default: 
				OPM_LogWStr((CHAR*)"unhandled case in OPV.expr, n^.class = ", 40);
				OPM_LogWNum(n->class, 0);
				OPM_LogWLn();
				break;
		}
		if (!__IN(n->class, 0x09744000, 32)) {
			OPC_EndStat();
		}
		n = n->link;
	}
}

void OPV_Module (OPT_Node prog)
{
	if (!__IN(10, OPM_Options, 32)) {
		OPC_GenHdr(prog->right);
		OPC_GenHdrIncludes();
	}
	OPC_GenBdy(prog->right);
	OPV_stat(prog, NIL);
}

__TDESC(OPV_ExitInfo, 1, 0) = {__TDFLDS("ExitInfo", 4), {-8}};

export void *OPV__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(OPC);
	__MODULE_IMPORT(OPM);
	__MODULE_IMPORT(OPS);
	__MODULE_IMPORT(OPT);
	__REGMOD("OPV", 0);
	__REGCMD("Init", OPV_Init);
	__INITYP(OPV_ExitInfo, OPV_ExitInfo, 0);
/* BEGIN */
	__ENDMOD;
}
