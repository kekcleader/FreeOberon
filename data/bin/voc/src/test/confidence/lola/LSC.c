/* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpa */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "LSB.h"
#include "LSS.h"
#include "Oberon.h"
#include "Texts.h"


static INT16 LSC_sym;
static BOOLEAN LSC_err;
static LSB_Object LSC_top, LSC_bot, LSC_undef;
static void (*LSC_factor)(LSB_Item*);
static void (*LSC_expression)(LSB_Item*);
static void (*LSC_Unit)(LSB_Object*);
static Texts_Writer LSC_W;


static void LSC_CheckAssign (LSB_Item x, LSB_Item y);
static void LSC_CheckTypes (LSB_Item x, LSB_Item y, LSB_Item z);
export void LSC_Compile (void);
static void LSC_ConstDeclaration (void);
static void LSC_Err (INT16 n);
static INT32 LSC_Log (INT32 m);
static void LSC_Module (Texts_Text T, INT32 pos);
static LSB_Item LSC_New (INT16 tag, LSB_Item a, LSB_Item b);
static LSB_Object LSC_NewObj (INT16 class);
static void LSC_Param (LSB_Object fpar, LSB_Item *apar);
static void LSC_ParamList (void);
static void LSC_SimpleExpression (LSB_Item *x);
static void LSC_StatSequence (void);
static void LSC_Statement (void);
static LSB_Object LSC_ThisObj (LSS_Ident id);
static void LSC_Traverse (LSB_Item x);
static void LSC_Type0 (LSB_Type *type);
static void LSC_TypeDeclaration (void);
static void LSC_UncondExpression (LSB_Item *x);
static void LSC_Unit0 (LSB_Object *locals);
static void LSC_VarList (INT16 kind, LSB_Item clk);
static void LSC_constructor (LSB_Item *x);
static void LSC_elem (LSB_Item *x, INT32 *len);
static void LSC_expression0 (LSB_Item *x);
static void LSC_factor0 (LSB_Item *x);
static void LSC_selector (LSB_Item *x);
static void LSC_term (LSB_Item *x);


static void LSC_Err (INT16 n)
{
	LSS_Mark((CHAR*)"type error", 11);
	Texts_WriteInt(&LSC_W, Texts_Writer__typ, n, 4);
	Texts_WriteLn(&LSC_W, Texts_Writer__typ);
	Texts_Append(Oberon_Log, LSC_W.buf);
}

static INT32 LSC_Log (INT32 m)
{
	INT32 n;
	n = 1;
	while (m > 1) {
		m = __ASHR(m, 1);
		n += 1;
	}
	return n;
}

static LSB_Item LSC_New (INT16 tag, LSB_Item a, LSB_Item b)
{
	LSB_Item z = NIL;
	__NEW(z, LSB_ItemDesc);
	z->tag = tag;
	z->a = a;
	z->b = b;
	z->val = b->val;
	return z;
}

static LSB_Object LSC_NewObj (INT16 class)
{
	LSB_Object new = NIL, x = NIL;
	x = LSC_top;
	while ((x->next != LSC_bot && __STRCMP(x->next->name, LSS_id) != 0)) {
		x = x->next;
	}
	if (x->next == LSC_bot) {
		__NEW(new, LSB_ObjDesc);
		__MOVE(LSS_id, new->name, 32);
		new->tag = class;
		new->next = LSC_bot;
		x->next = new;
	} else {
		LSS_Mark((CHAR*)"mult def", 9);
		new = x;
	}
	return new;
}

static LSB_Object LSC_ThisObj (LSS_Ident id)
{
	LSB_Object x = NIL;
	LSS_Ident id__copy;
	__DUPARR(id, LSS_Ident);
	x = LSC_top->next;
	while ((x != NIL && __STRCMP(x->name, id) != 0)) {
		x = x->next;
	}
	if (x == NIL) {
		LSS_Mark((CHAR*)"undef", 6);
		x = LSC_undef;
	}
	return x;
}

static void LSC_CheckTypes (LSB_Item x, LSB_Item y, LSB_Item z)
{
	LSB_Type xtyp = NIL, ytyp = NIL;
	xtyp = x->type;
	ytyp = y->type;
	z->type = xtyp;
	z->size = x->size;
	z->val = x->val;
	if (xtyp == LSB_bitType) {
		z->type = xtyp;
		if (ytyp == LSB_integer) {
			if (y->val >= 2) {
				LSC_Err(20);
				LSS_Mark((CHAR*)"only 0 or 1", 12);
			}
		} else if (ytyp == LSB_string) {
			LSC_Err(21);
		} else if (ytyp != LSB_bitType) {
			LSC_Err(22);
		}
	} else if (__ISP(xtyp, LSB_ArrayTypeDesc, 1)) {
		if (__GUARDP(xtyp, LSB_ArrayTypeDesc, 1)->eltyp == LSB_bitType) {
			if ((__ISP(ytyp, LSB_ArrayTypeDesc, 1) && __GUARDP(xtyp, LSB_ArrayTypeDesc, 1)->eltyp == LSB_bitType)) {
				if (xtyp->size != ytyp->size) {
					LSC_Err(33);
				}
			} else if (ytyp == LSB_integer) {
				if (xtyp->size < LSC_Log(y->val)) {
					LSC_Err(30);
				}
			} else if (ytyp == LSB_string) {
				if (xtyp->size != y->size) {
					LSC_Err(31);
				}
			} else if (ytyp != LSB_bitType) {
				LSC_Err(34);
			}
		} else if ((__ISP(ytyp, LSB_ArrayTypeDesc, 1) && __GUARDP(xtyp, LSB_ArrayTypeDesc, 1)->eltyp == __GUARDP(ytyp, LSB_ArrayTypeDesc, 1)->eltyp)) {
			if (xtyp->size != ytyp->size) {
				LSC_Err(40);
			}
		} else {
			LSC_Err(41);
		}
	} else if (xtyp == LSB_string) {
		if (ytyp == LSB_bitType) {
			LSC_Err(12);
		} else if ((__ISP(ytyp, LSB_ArrayTypeDesc, 1) && __GUARDP(ytyp, LSB_ArrayTypeDesc, 1)->eltyp == LSB_bitType)) {
			if (x->size != ytyp->size) {
				LSC_Err(13);
			}
		} else if (ytyp == LSB_integer) {
			if (x->size < LSC_Log(y->val)) {
				LSC_Err(10);
			}
		} else if (ytyp == LSB_string) {
			if (x->size != y->size) {
				LSC_Err(11);
			}
		} else {
			LSC_Err(14);
		}
	} else if (xtyp == LSB_integer) {
		if ((__ISP(ytyp, LSB_ArrayTypeDesc, 1) && __GUARDP(ytyp, LSB_ArrayTypeDesc, 1)->eltyp == LSB_bitType)) {
			if (LSC_Log(x->val) > ytyp->size) {
				LSC_Err(3);
				LSS_Mark((CHAR*)"const too large", 16);
			}
		} else if (ytyp == LSB_bitType) {
			if (x->val >= 2) {
				LSC_Err(2);
			}
		} else if (ytyp == LSB_integer) {
		} else if (ytyp == LSB_string) {
			if (LSC_Log(x->val) > y->size) {
				LSC_Err(12);
			}
		} else {
			LSC_Err(4);
		}
	}
}

static void LSC_selector (LSB_Item *x)
{
	LSB_Item y = NIL, z = NIL;
	LSB_Object obj = NIL;
	LSB_Type eltyp = NIL;
	INT32 len, kind;
	while (LSC_sym == 27 || LSC_sym == 18) {
		if (LSC_sym == 27) {
			eltyp = __GUARDP((*x)->type, LSB_ArrayTypeDesc, 1)->eltyp;
			LSS_Get(&LSC_sym);
			(*LSC_expression)(&y);
			if (LSC_sym == 20) {
				LSS_Get(&LSC_sym);
				(*LSC_expression)(&z);
				if ((y->tag == 4 && z->tag == 4)) {
					len = (y->val - z->val) + 1;
					y = LSC_New(8, y, z);
					*x = LSC_New(7, *x, y);
					(*x)->type = LSB_string;
					(*x)->size = len;
				}
			} else {
				kind = (*x)->val;
				*x = LSC_New(7, *x, y);
				(*x)->type = eltyp;
				(*x)->val = kind;
			}
			if (LSC_sym == 22) {
				LSS_Get(&LSC_sym);
			} else {
				LSS_Mark((CHAR*)"rbrak \?", 8);
			}
		} else {
			LSS_Get(&LSC_sym);
			(*LSC_factor)(&y);
			if ((y->tag == 4 && y->val >= (*x)->type->len)) {
				LSS_Mark((CHAR*)"too large", 10);
			}
			eltyp = __GUARDP((*x)->type, LSB_ArrayTypeDesc, 1)->eltyp;
			kind = (*x)->val;
			*x = LSC_New(7, *x, y);
			(*x)->type = eltyp;
			(*x)->val = kind;
		}
	}
}

static void LSC_elem (LSB_Item *x, INT32 *len)
{
	LSB_Item y = NIL, z = NIL;
	INT32 m, n;
	(*LSC_expression)(&*x);
	if ((*x)->type == LSB_integer || (*x)->type == LSB_string) {
		m = (*x)->size;
	} else {
		m = (*x)->type->size;
	}
	if (LSC_sym == 29) {
		LSS_Get(&LSC_sym);
		if (LSC_sym == 32) {
			__NEW(y, LSB_ItemDesc);
			y->tag = 4;
			n = LSS_val;
			y->val = n;
			y->type = LSB_integer;
			LSS_Get(&LSC_sym);
			*x = LSC_New(10, *x, y);
		}
	} else {
		n = 1;
	}
	*len = m * n;
}

static void LSC_constructor (LSB_Item *x)
{
	LSB_Item y = NIL;
	INT32 n, len;
	LSC_elem(&*x, &len);
	while (LSC_sym == 19) {
		LSS_Get(&LSC_sym);
		LSC_elem(&y, &n);
		len += n;
		*x = LSC_New(9, *x, y);
		(*x)->val = len;
	}
	(*x)->size = len;
	(*x)->type = LSB_string;
	if (LSC_sym == 23) {
		LSS_Get(&LSC_sym);
	} else {
		LSS_Mark((CHAR*)"rbrace \?", 9);
	}
}

static void LSC_factor0 (LSB_Item *x)
{
	LSB_Object obj = NIL;
	LSB_Item y = NIL, z = NIL;
	INT32 n, len;
	LSB_ArrayType t = NIL;
	if (LSC_sym == 31) {
		*x = (LSB_Item)LSC_ThisObj(LSS_id);
		LSS_Get(&LSC_sym);
		if ((*x)->tag == 3) {
			LSC_selector(&*x);
		} else if ((*x)->tag == 1) {
			n = (*x)->b->val;
			__NEW(*x, LSB_ItemDesc);
			(*x)->tag = 4;
			(*x)->val = n;
			(*x)->type = LSB_integer;
		} else {
			LSS_Mark((CHAR*)"bad factor", 11);
		}
	} else if (LSC_sym == 26) {
		LSS_Get(&LSC_sym);
		(*LSC_expression)(&*x);
		if (LSC_sym == 21) {
			LSS_Get(&LSC_sym);
		} else {
			LSS_Mark((CHAR*)"rparen \?", 9);
		}
	} else if (LSC_sym == 32) {
		__NEW(*x, LSB_ItemDesc);
		(*x)->tag = 4;
		(*x)->val = LSS_val;
		(*x)->type = LSB_integer;
		LSS_Get(&LSC_sym);
		if (LSC_sym == 17) {
			LSS_Get(&LSC_sym);
			if (LSC_sym == 32) {
				len = LSS_val;
				LSS_Get(&LSC_sym);
				if (len < LSC_Log((*x)->val)) {
					LSS_Mark((CHAR*)"value too large", 16);
				}
			} else {
				LSS_Mark((CHAR*)"integer \?", 10);
				len = 0;
			}
			(*x)->size = len;
		} else {
			len = 0;
		}
		(*x)->size = len;
	} else if (LSC_sym == 9) {
		LSS_Get(&LSC_sym);
		(*LSC_factor)(&*x);
		y = LSC_New(11, NIL, *x);
		y->type = (*x)->type;
		y->size = (*x)->size;
		*x = y;
	} else if (LSC_sym == 28) {
		LSS_Get(&LSC_sym);
		LSC_constructor(&*x);
	} else {
		LSS_Mark((CHAR*)"bad factor", 11);
	}
}

static void LSC_term (LSB_Item *x)
{
	LSB_Item y = NIL, z = NIL;
	INT16 op;
	(*LSC_factor)(&*x);
	while ((LSC_sym >= 2 && LSC_sym <= 4)) {
		if (LSC_sym == 4) {
			op = 12;
		} else if (LSC_sym == 2) {
			op = 13;
		} else if (LSC_sym == 3) {
			op = 14;
		}
		LSS_Get(&LSC_sym);
		(*LSC_factor)(&y);
		z = LSC_New(op, *x, y);
		LSC_CheckTypes(*x, y, z);
		*x = z;
	}
}

static void LSC_SimpleExpression (LSB_Item *x)
{
	LSB_Item y = NIL, z = NIL;
	INT16 op;
	if (LSC_sym == 6) {
		LSS_Get(&LSC_sym);
		LSC_term(&y);
		if (y->tag == 4) {
			*x = y;
			(*x)->val = -y->val;
		} else {
			*x = LSC_New(18, NIL, y);
			(*x)->type = y->type;
			(*x)->size = y->size;
		}
	} else if (LSC_sym == 5) {
		LSS_Get(&LSC_sym);
		LSC_term(&*x);
	} else {
		LSC_term(&*x);
	}
	while ((LSC_sym >= 5 && LSC_sym <= 8)) {
		if (LSC_sym == 7) {
			op = 15;
		} else if (LSC_sym == 8) {
			op = 16;
		} else if (LSC_sym == 5) {
			op = 17;
		} else if (LSC_sym == 6) {
			op = 18;
		}
		LSS_Get(&LSC_sym);
		LSC_term(&y);
		z = LSC_New(op, *x, y);
		LSC_CheckTypes(*x, y, z);
		*x = z;
	}
}

static void LSC_UncondExpression (LSB_Item *x)
{
	LSB_Item y = NIL, z = NIL;
	INT16 rel;
	LSC_SimpleExpression(&*x);
	if ((LSC_sym >= 10 && LSC_sym <= 15)) {
		if (LSC_sym == 10) {
			rel = 20;
		} else if (LSC_sym == 11) {
			rel = 21;
		} else if (LSC_sym == 12) {
			rel = 22;
		} else if (LSC_sym == 15) {
			rel = 23;
		} else if (LSC_sym == 13) {
			rel = 24;
		} else {
			rel = 25;
		}
		LSS_Get(&LSC_sym);
		LSC_SimpleExpression(&y);
		z = LSC_New(rel, *x, y);
		LSC_CheckTypes(*x, y, z);
		z->type = LSB_bitType;
		*x = z;
	}
}

static void LSC_expression0 (LSB_Item *x)
{
	LSB_Item y = NIL, z = NIL, w = NIL;
	LSC_UncondExpression(&*x);
	if (LSC_sym == 24) {
		if ((*x)->type != LSB_bitType) {
			LSS_Mark((CHAR*)"Boolean\?", 9);
		}
		LSS_Get(&LSC_sym);
		(*LSC_expression)(&y);
		if (LSC_sym == 20) {
			LSS_Get(&LSC_sym);
			(*LSC_expression)(&z);
			w = LSC_New(31, y, z);
			LSC_CheckTypes(y, z, w);
			*x = LSC_New(30, *x, w);
			(*x)->type = w->type;
			(*x)->size = w->size;
		} else {
			LSS_Mark((CHAR*)"colon \?", 8);
		}
	}
}

static void LSC_CheckAssign (LSB_Item x, LSB_Item y)
{
	LSB_Type xtyp = NIL, ytyp = NIL;
	xtyp = x->type;
	ytyp = y->type;
	if (xtyp != ytyp) {
		if (xtyp == LSB_bitType) {
			if (ytyp != LSB_integer || y->val >= 2) {
				LSC_Err(70);
			}
		} else if (__ISP(xtyp, LSB_ArrayTypeDesc, 1)) {
			if (__GUARDP(xtyp, LSB_ArrayTypeDesc, 1)->eltyp == LSB_bitType) {
				if ((__ISP(ytyp, LSB_ArrayTypeDesc, 1) && __GUARDP(xtyp, LSB_ArrayTypeDesc, 1)->eltyp == LSB_bitType)) {
					if (xtyp->size != ytyp->size) {
						LSC_Err(71);
					}
				} else if (ytyp == LSB_integer) {
					if (xtyp->size < LSC_Log(y->val)) {
						LSC_Err(72);
					}
				} else if (ytyp == LSB_string) {
					if (xtyp->size != y->size) {
						LSC_Err(73);
					}
				} else {
					LSC_Err(74);
				}
			} else {
				LSC_Err(74);
			}
		}
	}
}

static void LSC_Param (LSB_Object fpar, LSB_Item *apar)
{
	LSB_Item y = NIL, z = NIL;
	(*LSC_expression)(&y);
	*apar = LSC_New(33, NIL, y);
	LSC_CheckAssign((void*)fpar, y);
	if (__IN(fpar->val, 0x18, 32)) {
		if (!__IN(y->tag, 0x88, 32)) {
			LSS_Mark((CHAR*)"bad actual param", 17);
		} else if (y->b == NIL) {
			y->b = (LSB_Item)LSC_undef;
		}
	}
}

static void LSC_Statement (void)
{
	LSB_Item w = NIL, x = NIL, y = NIL, z = NIL, apar = NIL, npar = NIL;
	LSB_UnitType unit = NIL;
	LSB_Object fpar = NIL;
	if (LSC_sym < 31) {
		LSS_Mark((CHAR*)"bad factor", 11);
		do {
			LSS_Get(&LSC_sym);
		} while (!(LSC_sym >= 31));
	}
	if (LSC_sym == 31) {
		x = (LSB_Item)LSC_ThisObj(LSS_id);
		z = x;
		LSS_Get(&LSC_sym);
		LSC_selector(&z);
		if (LSC_sym == 30) {
			LSS_Get(&LSC_sym);
			if (x->val >= 5) {
				LSS_Mark((CHAR*)"assignment to read-only", 24);
			}
			if ((x->b != NIL && !__ISP(x->type, LSB_ArrayTypeDesc, 1))) {
				LSS_Mark((CHAR*)"mult assign", 12);
			}
			(*LSC_expression)(&y);
			LSC_CheckAssign(z, y);
			x->b = y;
			if (z != x) {
				x->a = z->b;
				x->val = 1;
			}
		} else if (LSC_sym == 26) {
			LSS_Get(&LSC_sym);
			if (__ISP(x->type, LSB_UnitTypeDesc, 1)) {
				unit = __GUARDP(x->type, LSB_UnitTypeDesc, 1);
				fpar = unit->firstobj;
				if (LSC_sym != 21) {
					LSC_Param(fpar, &apar);
					x->b = apar;
					fpar = fpar->next;
					while (LSC_sym != 21) {
						if (LSC_sym == 19) {
							LSS_Get(&LSC_sym);
						}
						LSC_Param(fpar, &npar);
						if (fpar->tag >= 3) {
							fpar = fpar->next;
							apar->a = npar;
							apar = npar;
						} else {
							LSS_Mark((CHAR*)"too many params", 16);
						}
					}
					if (fpar->val >= 3) {
						LSS_Mark((CHAR*)"too few params", 15);
					}
				}
				if (LSC_sym == 21) {
					LSS_Get(&LSC_sym);
				} else {
					LSS_Mark((CHAR*)"rparen \?", 9);
				}
			} else {
				LSS_Mark((CHAR*)"not a module", 13);
			}
		} else {
			LSS_Mark((CHAR*)"bad statement", 14);
		}
	} else if (LSC_sym == 33) {
		LSS_Get(&LSC_sym);
		if (LSC_sym == 26) {
			LSS_Get(&LSC_sym);
		} else {
			LSS_Mark((CHAR*)"( missing", 10);
		}
		if (LSC_sym == 31) {
			x = (LSB_Item)LSC_ThisObj(LSS_id);
			x->b = (LSB_Item)LSC_undef;
			if (x->val != 5) {
				LSS_Mark((CHAR*)"not INOUT", 10);
			}
			LSS_Get(&LSC_sym);
			if (LSC_sym == 19) {
				LSS_Get(&LSC_sym);
			}
			if (LSC_sym == 31) {
				y = (LSB_Item)LSC_ThisObj(LSS_id);
				LSC_CheckAssign(x, y);
				y->b = (LSB_Item)LSC_undef;
			}
			LSS_Get(&LSC_sym);
			if (LSC_sym == 19) {
				LSS_Get(&LSC_sym);
			}
			(*LSC_expression)(&z);
			if ((z->tag == 4 && z->val <= 1)) {
				z->type = LSB_bitType;
			}
			LSC_CheckAssign(x, z);
			LSS_Get(&LSC_sym);
			if (LSC_sym == 19) {
				LSS_Get(&LSC_sym);
			}
			(*LSC_expression)(&w);
			if (w->type != LSB_bitType) {
				LSC_CheckAssign(x, w);
			}
			w = LSC_New(33, z, w);
			x->b = LSC_New(32, y, w);
			if (LSC_sym == 21) {
				LSS_Get(&LSC_sym);
			} else {
				LSS_Mark((CHAR*)") missing", 10);
			}
		}
	}
}

static void LSC_StatSequence (void)
{
	LSC_Statement();
	while (LSC_sym <= 40) {
		if (LSC_sym < 40) {
			LSS_Mark((CHAR*)"semicolon missing\?", 19);
		}
		while (LSC_sym == 40) {
			LSS_Get(&LSC_sym);
		}
		LSC_Statement();
	}
	if (LSC_sym == 41) {
		LSS_Get(&LSC_sym);
	} else {
		LSS_Mark((CHAR*)"END \?", 6);
	}
}

static void LSC_ConstDeclaration (void)
{
	LSB_Object obj = NIL;
	if (LSC_sym == 31) {
		obj = LSC_NewObj(1);
		LSS_Get(&LSC_sym);
		if (LSC_sym == 30 || LSC_sym == 10) {
			LSS_Get(&LSC_sym);
		} else {
			LSS_Mark((CHAR*)":= \?", 5);
		}
		(*LSC_expression)(&obj->b);
		obj->type = LSB_integer;
		if (LSC_sym == 40) {
			LSS_Get(&LSC_sym);
		} else {
			LSS_Mark((CHAR*)"semicolon \?", 12);
		}
	} else {
		LSS_Mark((CHAR*)"ident \?", 8);
	}
}

static void LSC_Type0 (LSB_Type *type)
{
	LSB_Object obj = NIL;
	INT32 len, size;
	LSB_Type eltyp = NIL;
	LSB_ArrayType arrtyp = NIL;
	len = 1;
	if (LSC_sym == 27) {
		LSS_Get(&LSC_sym);
		if (LSC_sym == 32) {
			len = LSS_val;
			LSS_Get(&LSC_sym);
		} else if (LSC_sym == 31) {
			obj = LSC_ThisObj(LSS_id);
			len = obj->val;
		}
		if (LSC_sym == 22) {
			LSS_Get(&LSC_sym);
		} else {
			LSS_Mark((CHAR*)"rbrak \?", 8);
		}
		LSC_Type0(&eltyp);
		__NEW(arrtyp, LSB_ArrayTypeDesc);
		size = eltyp->size * len;
		arrtyp->eltyp = eltyp;
		*type = (LSB_Type)arrtyp;
		(*type)->len = len;
		(*type)->size = size;
	} else if (LSC_sym == 31) {
		obj = LSC_ThisObj(LSS_id);
		LSS_Get(&LSC_sym);
		if (obj != NIL) {
			if (obj->tag == 2) {
				*type = obj->type;
			} else {
				LSS_Mark((CHAR*)"not a type", 11);
				*type = LSB_bitType;
			}
		} else {
			LSS_Mark((CHAR*)"type \?", 7);
		}
	} else {
		*type = LSB_bitType;
		LSS_Mark((CHAR*)"ident or [", 11);
	}
}

static void LSC_TypeDeclaration (void)
{
	LSB_Object obj = NIL;
	LSB_UnitType utyp = NIL;
	if (LSC_sym == 31) {
		obj = LSC_NewObj(2);
		LSS_Get(&LSC_sym);
		if (LSC_sym == 30 || LSC_sym == 10) {
			LSS_Get(&LSC_sym);
		} else {
			LSS_Mark((CHAR*)":= \?", 5);
		}
		if (LSC_sym == 59) {
			LSS_Get(&LSC_sym);
			__NEW(utyp, LSB_UnitTypeDesc);
			(*LSC_Unit)(&utyp->firstobj);
			obj->type = (LSB_Type)utyp;
			obj->type->typobj = obj;
		} else {
			LSC_Type0(&obj->type);
		}
		if (LSC_sym == 40) {
			LSS_Get(&LSC_sym);
		} else {
			LSS_Mark((CHAR*)"semicolon \?", 12);
		}
	} else {
		LSS_Mark((CHAR*)"ident \?", 8);
	}
}

static void LSC_VarList (INT16 kind, LSB_Item clk)
{
	LSB_Object first = NIL, new = NIL, obj = NIL;
	LSB_Type type = NIL;
	obj = NIL;
	while (LSC_sym == 31) {
		new = LSC_NewObj(3);
		__MOVE(LSS_id, new->name, 32);
		new->val = kind;
		first = new;
		LSS_Get(&LSC_sym);
		if (LSC_sym == 19) {
			LSS_Get(&LSC_sym);
		} else if (LSC_sym == 31) {
			LSS_Mark((CHAR*)"comma missing", 14);
		}
		while (LSC_sym == 31) {
			new = LSC_NewObj(3);
			__MOVE(LSS_id, new->name, 32);
			new->val = kind;
			LSS_Get(&LSC_sym);
			if (LSC_sym == 19) {
				LSS_Get(&LSC_sym);
			} else if (LSC_sym == 31) {
				LSS_Mark((CHAR*)"comma missing", 14);
			}
		}
		if (LSC_sym == 20) {
			LSS_Get(&LSC_sym);
			LSC_Type0(&type);
			obj = first;
			while (obj != LSC_bot) {
				obj->type = type;
				obj->a = clk;
				obj = obj->next;
			}
		} else {
			LSS_Mark((CHAR*)"colon \?", 8);
		}
		if (LSC_sym == 40) {
			LSS_Get(&LSC_sym);
		} else if (LSC_sym != 21) {
			LSS_Mark((CHAR*)"semicolon or rparen missing", 28);
		}
	}
}

static void LSC_ParamList (void)
{
	INT16 kind;
	if (LSC_sym == 57) {
		LSS_Get(&LSC_sym);
		kind = 6;
	} else if (LSC_sym == 55) {
		LSS_Get(&LSC_sym);
		if (LSC_sym == 53) {
			LSS_Get(&LSC_sym);
			kind = 4;
		} else {
			kind = 3;
		}
	} else if (LSC_sym == 56) {
		LSS_Get(&LSC_sym);
		kind = 5;
	}
	LSC_VarList(kind, NIL);
}

static void LSC_Traverse (LSB_Item x)
{
	if (x != NIL) {
		if (__ISP(x, LSB_ObjDesc, 1)) {
			if ((x->tag == 3 && x->val >= 2)) {
				if (__GUARDP(x, LSB_ObjDesc, 1)->marked) {
					Texts_WriteString(&LSC_W, Texts_Writer__typ, __GUARDP(x, LSB_ObjDesc, 1)->name, 32);
					Texts_Write(&LSC_W, Texts_Writer__typ, ' ');
					LSC_err = 1;
				} else if (x->b != NIL) {
					__GUARDP(x, LSB_ObjDesc, 1)->marked = 1;
					LSC_Traverse(x->b);
				}
				__GUARDP(x, LSB_ObjDesc, 1)->marked = 0;
			}
		} else {
			LSC_Traverse(x->a);
			LSC_Traverse(x->b);
		}
	}
}

static void LSC_Unit0 (LSB_Object *locals)
{
	LSB_Object obj = NIL, oldtop = NIL;
	INT16 kind;
	LSB_Item clock = NIL;
	oldtop = LSC_top->next;
	LSC_top->next = LSB_root;
	if (LSC_sym == 26) {
		LSS_Get(&LSC_sym);
	} else {
		LSS_Mark((CHAR*)"lparen \?", 9);
	}
	while ((LSC_sym == 57 || LSC_sym == 55) || LSC_sym == 56) {
		LSC_ParamList();
	}
	if (LSC_sym == 21) {
		LSS_Get(&LSC_sym);
	} else {
		LSS_Mark((CHAR*)"rparen \?", 9);
	}
	if (LSC_sym == 8) {
		LSS_Get(&LSC_sym);
		*locals = LSC_top->next;
	} else {
		if (LSC_sym == 40) {
			LSS_Get(&LSC_sym);
		} else {
			LSS_Mark((CHAR*)"semicolon \?", 12);
		}
		if (LSC_sym == 51) {
			LSS_Get(&LSC_sym);
			while (LSC_sym == 31) {
				LSC_ConstDeclaration();
			}
		}
		if (LSC_sym == 52) {
			LSS_Get(&LSC_sym);
			while (LSC_sym == 31) {
				LSC_TypeDeclaration();
			}
		}
		while (LSC_sym == 54 || LSC_sym == 53) {
			if (LSC_sym == 54) {
				LSS_Get(&LSC_sym);
				while (LSC_sym == 31) {
					LSC_VarList(2, NIL);
				}
			} else {
				kind = 0;
				LSS_Get(&LSC_sym);
				if (LSC_sym == 26) {
					LSS_Get(&LSC_sym);
					(*LSC_expression)(&clock);
					if (clock->type != LSB_bitType) {
						LSS_Mark((CHAR*)"clock must be bitType", 22);
					}
					if ((__ISP(clock, LSB_ObjDesc, 1) && __STRCMP(__GUARDP(clock, LSB_ObjDesc, 1)->name, "clk") == 0)) {
						kind = 1;
						clock = NIL;
					}
					if (LSC_sym == 21) {
						LSS_Get(&LSC_sym);
					} else {
						LSS_Mark((CHAR*)"rparen \?", 9);
					}
				} else {
					LSS_Mark((CHAR*)"lparen expected", 16);
					clock = (LSB_Item)LSC_undef;
				}
				while (LSC_sym == 31) {
					LSC_VarList(kind, clock);
				}
			}
		}
		*locals = LSC_top->next;
		if (LSC_sym == 58) {
			LSS_Get(&LSC_sym);
			LSC_StatSequence();
		}
		obj = *locals;
		LSC_err = 0;
		while (obj != LSB_root) {
			if ((obj->tag == 3 && obj->val < 5)) {
				if ((obj->b == NIL && obj->val < 4)) {
					Texts_WriteString(&LSC_W, Texts_Writer__typ, obj->name, 32);
					Texts_Write(&LSC_W, Texts_Writer__typ, ' ');
					LSC_err = 1;
				} else if (obj->b == (void *) LSC_undef) {
					obj->b = NIL;
				}
			}
			obj = obj->next;
		}
		if (LSC_err) {
			Texts_WriteString(&LSC_W, Texts_Writer__typ, (CHAR*)" unassigned", 12);
			Texts_WriteLn(&LSC_W, Texts_Writer__typ);
		} else {
			obj = *locals;
			LSC_err = 0;
			while (obj != LSB_root) {
				if (obj->tag == 3) {
					obj->marked = 1;
					LSC_Traverse(obj->b);
					obj->marked = 0;
				}
				obj = obj->next;
			}
			if (LSC_err) {
				Texts_WriteString(&LSC_W, Texts_Writer__typ, (CHAR*)"in loop", 8);
				Texts_WriteLn(&LSC_W, Texts_Writer__typ);
			}
		}
	}
	if (LSC_err) {
		Texts_Append(Oberon_Log, LSC_W.buf);
	}
	LSC_top->next = oldtop;
}

static void LSC_Module (Texts_Text T, INT32 pos)
{
	LSB_Object root = NIL;
	CHAR modname[32];
	Texts_WriteString(&LSC_W, Texts_Writer__typ, (CHAR*)"compiling Lola: ", 17);
	LSC_bot = LSB_root;
	LSC_top->next = LSC_bot;
	LSS_Init(T, pos);
	LSS_Get(&LSC_sym);
	if (LSC_sym == 59) {
		LSS_Get(&LSC_sym);
		if (LSC_sym == 31) {
			__MOVE(LSS_id, modname, 32);
			Texts_WriteString(&LSC_W, Texts_Writer__typ, LSS_id, 32);
			LSS_Get(&LSC_sym);
			Texts_WriteLn(&LSC_W, Texts_Writer__typ);
			Texts_Append(Oberon_Log, LSC_W.buf);
		} else {
			LSS_Mark((CHAR*)"ident \?", 8);
		}
		(*LSC_Unit)(&root);
		if (LSC_sym == 31) {
			LSS_Get(&LSC_sym);
			if (__STRCMP(LSS_id, modname) != 0) {
				LSS_Mark((CHAR*)"no match", 9);
			}
		}
		if (LSC_sym != 18) {
			LSS_Mark((CHAR*)"period \?", 9);
		}
		if (!LSS_error) {
			LSB_Register(modname, 32, root);
		} else {
			Texts_WriteString(&LSC_W, Texts_Writer__typ, (CHAR*)"compilation failed", 19);
			Texts_WriteLn(&LSC_W, Texts_Writer__typ);
			LSB_Register((CHAR*)"", 1, LSB_root);
		}
	} else {
		LSS_Mark((CHAR*)"module \?", 9);
	}
	Texts_Append(Oberon_Log, LSC_W.buf);
}

void LSC_Compile (void)
{
	INT32 beg, end, time;
	Texts_Scanner S;
	Texts_Text T = NIL;
	Texts_OpenScanner(&S, Texts_Scanner__typ, Oberon_Par->text, Oberon_Par->pos);
	Texts_Scan(&S, Texts_Scanner__typ);
	if (S.class == 6) {
		if (S.c == '*') {
		} else if (S.c == '@') {
			Oberon_GetSelection(&T, &beg, &end, &time);
			if (time >= 0) {
				LSC_Module(T, beg);
			}
		}
	} else if (S.class == 1) {
		__NEW(T, Texts_TextDesc);
		Texts_Open(T, S.s, 64);
		LSC_Module(T, 0);
	}
	Oberon_Par->pos = Texts_Pos((void*)&S, Texts_Scanner__typ);
	Texts_Append(Oberon_Log, LSC_W.buf);
}

static void EnumPtrs(void (*P)(void*))
{
	P(LSC_top);
	P(LSC_bot);
	P(LSC_undef);
	__ENUMR(&LSC_W, Texts_Writer__typ, 56, 1, P);
}


export void *LSC__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(LSB);
	__MODULE_IMPORT(LSS);
	__MODULE_IMPORT(Oberon);
	__MODULE_IMPORT(Texts);
	__REGMOD("LSC", EnumPtrs);
	__REGCMD("Compile", LSC_Compile);
/* BEGIN */
	Texts_OpenWriter(&LSC_W, Texts_Writer__typ);
	Texts_WriteString(&LSC_W, Texts_Writer__typ, (CHAR*)"Lola compiler; NW 6.7.2015", 27);
	Texts_WriteLn(&LSC_W, Texts_Writer__typ);
	__NEW(LSC_top, LSB_ObjDesc);
	LSC_bot = LSB_root;
	__NEW(LSC_undef, LSB_ObjDesc);
	LSC_undef->tag = 2;
	LSC_undef->type = LSB_bitType;
	LSC_Unit = LSC_Unit0;
	LSC_factor = LSC_factor0;
	LSC_expression = LSC_expression0;
	__ENDMOD;
}
