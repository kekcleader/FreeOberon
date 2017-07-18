/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpa */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Files.h"
#include "LSB.h"
#include "Oberon.h"
#include "Texts.h"


static Texts_Writer LSV_W;
static INT16 LSV_nofgen;
static void (*LSV_Constructor)(LSB_Item*);
static Files_File LSV_F;
static Files_Rider LSV_R;
static CHAR LSV_C[64][6];


static void LSV_ActParam (LSB_Item *x, LSB_Object fpar);
static void LSV_BitArrLen (LSB_Type typ);
static void LSV_Constructor0 (LSB_Item *x);
static void LSV_Declaration (LSB_Object obj);
static void LSV_Elem (LSB_Item *x);
static void LSV_Expression (LSB_Item x);
export void LSV_List (void);
static void LSV_ObjList0 (LSB_Object obj);
static void LSV_ObjList1 (LSB_Object obj);
static void LSV_ObjList2 (LSB_Object obj);
static void LSV_Type (LSB_Type typ);
static void LSV_Write (CHAR ch);
static void LSV_WriteHex (INT32 x);
static void LSV_WriteInt (INT32 x);
static void LSV_WriteLn (void);
static void LSV_WriteString (CHAR *s, ADDRESS s__len);


static void LSV_Write (CHAR ch)
{
	Files_Write(&LSV_R, Files_Rider__typ, ch);
}

static void LSV_WriteLn (void)
{
	Files_Write(&LSV_R, Files_Rider__typ, 0x0d);
	Files_Write(&LSV_R, Files_Rider__typ, 0x0a);
}

static void LSV_WriteInt (INT32 x)
{
	INT16 i;
	INT32 d[14];
	i = 0;
	if (x < 0) {
		Files_Write(&LSV_R, Files_Rider__typ, '-');
		x = -x;
	}
	do {
		d[__X(i, 14)] = (int)__MOD(x, 10);
		x = __DIV(x, 10);
		i += 1;
	} while (!(x == 0));
	do {
		i -= 1;
		Files_Write(&LSV_R, Files_Rider__typ, (CHAR)(d[__X(i, 14)] + 48));
	} while (!(i == 0));
}

static void LSV_WriteHex (INT32 x)
{
	INT16 i;
	INT32 d[8];
	i = 0;
	do {
		d[__X(i, 8)] = __MASK(x, -16);
		x = __ASHR(x, 4);
		i += 1;
	} while (!(x == 0 || i == 8));
	do {
		i -= 1;
		if (d[__X(i, 8)] >= 10) {
			Files_Write(&LSV_R, Files_Rider__typ, (CHAR)(d[__X(i, 8)] + 55));
		} else {
			Files_Write(&LSV_R, Files_Rider__typ, (CHAR)(d[__X(i, 8)] + 48));
		}
	} while (!(i == 0));
}

static void LSV_WriteString (CHAR *s, ADDRESS s__len)
{
	INT16 i;
	__DUP(s, s__len, CHAR);
	i = 0;
	while (s[__X(i, s__len)] != 0x00) {
		Files_Write(&LSV_R, Files_Rider__typ, s[__X(i, s__len)]);
		i += 1;
	}
	__DEL(s);
}

static void LSV_Type (LSB_Type typ)
{
	LSB_Object obj = NIL;
	if (__ISP(typ, LSB_ArrayTypeDesc, 1)) {
		if (__GUARDP(typ, LSB_ArrayTypeDesc, 1)->eltyp != LSB_bitType) {
			LSV_Write('[');
			LSV_WriteInt(typ->len - 1);
			LSV_WriteString((CHAR*)":0]", 4);
			LSV_Type(__GUARDP(typ, LSB_ArrayTypeDesc, 1)->eltyp);
		}
	} else if (__ISP(typ, LSB_UnitTypeDesc, 1)) {
	}
}

static void LSV_BitArrLen (LSB_Type typ)
{
	LSB_Type eltyp = NIL;
	if (__ISP(typ, LSB_ArrayTypeDesc, 1)) {
		eltyp = __GUARDP(typ, LSB_ArrayTypeDesc, 1)->eltyp;
		while (__ISP(eltyp, LSB_ArrayTypeDesc, 1)) {
			typ = eltyp;
			eltyp = __GUARDP(typ, LSB_ArrayTypeDesc, 1)->eltyp;
		}
		if (eltyp == LSB_bitType) {
			LSV_Write('[');
			LSV_WriteInt(typ->len - 1);
			LSV_WriteString((CHAR*)":0] ", 5);
		}
	}
}

static void LSV_Expression (LSB_Item x)
{
	LSB_Item z = NIL;
	if (x != NIL) {
		if (__ISP(x, LSB_ObjDesc, 1)) {
			LSV_WriteString(__GUARDP(x, LSB_ObjDesc, 1)->name, 32);
		} else if (x->tag == 9) {
			LSV_Write('{');
			(*LSV_Constructor)(&x);
			LSV_Write('}');
		} else {
			if (x->tag == 10) {
				LSV_Write('{');
				LSV_WriteInt(x->b->val);
				LSV_Write('{');
				LSV_Expression(x->a);
				LSV_Write('}');
				LSV_Write('}');
			} else {
				if ((x->tag >= 12 && x->tag <= 25)) {
					LSV_Write('(');
				}
				LSV_Expression(x->a);
				if (x->tag == 7) {
					LSV_Write('[');
					LSV_Expression(x->b);
					LSV_Write(']');
				} else if (x->tag == 4) {
					if (x->size != 0) {
						LSV_WriteInt(x->size);
						LSV_Write('\'');
						LSV_Write('h');
						LSV_WriteHex(x->val);
					} else {
						LSV_WriteInt(x->val);
					}
				} else {
					LSV_WriteString(LSV_C[__X(x->tag, 64)], 6);
					LSV_Expression(x->b);
				}
				if ((x->tag >= 12 && x->tag <= 25)) {
					LSV_Write(')');
				}
			}
		}
	}
}

static void LSV_Elem (LSB_Item *x)
{
	if ((*x)->tag == 10) {
		LSV_Write('{');
		LSV_WriteInt((*x)->b->val);
		LSV_Write('{');
		LSV_Expression((*x)->a);
		LSV_WriteString((CHAR*)"}}", 3);
	} else {
		LSV_Expression(*x);
	}
}

static void LSV_Constructor0 (LSB_Item *x)
{
	if ((*x)->tag == 9) {
		(*LSV_Constructor)(&(*x)->a);
		LSV_WriteString((CHAR*)", ", 3);
		LSV_Elem(&(*x)->b);
	} else {
		LSV_Elem(&*x);
	}
}

static void LSV_Declaration (LSB_Object obj)
{
	LSB_Item apar = NIL;
	LSB_Type typ = NIL;
	typ = obj->type;
	if (__ISP(obj->type, LSB_UnitTypeDesc, 1)) {
		LSV_WriteString((CHAR*)"unit ", 6);
	} else {
		LSV_Type(obj->type);
	}
	if (obj->tag == 3) {
		if (__ISP(obj->type, LSB_UnitTypeDesc, 1)) {
			apar = obj->a;
			LSV_WriteLn();
			LSV_Write('[');
			while (apar != NIL) {
				LSV_Expression(apar->b);
				apar = apar->a;
			}
			LSV_Write(']');
		}
	} else if (obj->tag == 1) {
		LSV_WriteString((CHAR*)" = ", 4);
		LSV_WriteInt(obj->val);
	}
}

static void LSV_ObjList0 (LSB_Object obj)
{
	LSB_Object obj1 = NIL;
	BOOLEAN param;
	param = 1;
	while (obj != LSB_root) {
		if ((obj->tag == 3 && !__ISP(obj->type, LSB_UnitTypeDesc, 1))) {
			if (obj->val <= 1) {
				LSV_WriteString((CHAR*)"reg ", 5);
			} else if (obj->val == 2) {
				LSV_WriteString((CHAR*)"wire ", 6);
			} else if (obj->val == 3) {
				LSV_WriteString((CHAR*)"output ", 8);
			} else if (obj->val == 4) {
				LSV_WriteString((CHAR*)"output reg ", 12);
			} else if (obj->val == 5) {
				LSV_WriteString((CHAR*)"inout ", 7);
			} else if (obj->val == 6) {
				LSV_WriteString((CHAR*)"input ", 7);
			} else {
				LSV_WriteString((CHAR*)"\?\?\? ", 5);
			}
			LSV_BitArrLen(obj->type);
			LSV_WriteString(obj->name, 32);
			obj1 = obj->next;
			while ((((obj1 != LSB_top && obj1->type == obj->type)) && obj1->val == obj->val)) {
				LSV_WriteString((CHAR*)", ", 3);
				obj = obj1;
				LSV_WriteString(obj->name, 32);
				obj1 = obj->next;
			}
			if ((((param && obj->val >= 3)) && obj1->val < 3)) {
				param = 0;
				LSV_Write(')');
			}
			if ((obj->type != LSB_bitType && __GUARDP(obj->type, LSB_ArrayTypeDesc, 1)->eltyp != LSB_bitType)) {
				LSV_Type(obj->type);
			}
			if (param) {
				LSV_Write(',');
			} else {
				LSV_Write(';');
			}
			LSV_WriteLn();
		} else if (obj->tag == 1) {
		}
		obj = obj->next;
	}
}

static void LSV_ActParam (LSB_Item *x, LSB_Object fpar)
{
	LSV_Write('.');
	LSV_WriteString(fpar->name, 32);
	LSV_Write('(');
	LSV_Expression(*x);
	LSV_Write(')');
}

static void LSV_ObjList1 (LSB_Object obj)
{
	LSB_Item apar = NIL, x = NIL;
	LSB_Object fpar = NIL;
	INT32 size;
	while (obj != LSB_root) {
		if (obj->tag == 3 || obj->tag == 1) {
			if (__ISP(obj->type, LSB_UnitTypeDesc, 1)) {
				LSV_WriteString(obj->type->typobj->name, 32);
				LSV_Write(' ');
				LSV_WriteString(obj->name, 32);
				apar = obj->b;
				fpar = __GUARDP(obj->type, LSB_UnitTypeDesc, 1)->firstobj;
				LSV_Write('(');
				LSV_ActParam(&apar->b, fpar);
				apar = apar->a;
				fpar = fpar->next;
				while (apar != NIL) {
					LSV_WriteString((CHAR*)", ", 3);
					LSV_ActParam(&apar->b, fpar);
					apar = apar->a;
					fpar = fpar->next;
				}
				LSV_Write(')');
				LSV_Write(';');
				LSV_WriteLn();
			} else if ((obj->b != NIL && obj->val == 5)) {
				size = obj->type->size;
				x = obj->b;
				if (x->tag == 32) {
					if (obj->type == LSB_bitType) {
						LSV_WriteString((CHAR*)"IOBUF block", 12);
						LSV_nofgen += 1;
						LSV_WriteInt(LSV_nofgen);
						LSV_WriteString((CHAR*)" (.IO(", 7);
						LSV_WriteString(obj->name, 32);
						LSV_WriteString((CHAR*)"), .O(", 7);
						LSV_WriteString(__GUARDP(x->a, LSB_ObjDesc, 1)->name, 32);
						LSV_WriteString((CHAR*)"), .I(", 7);
						x = x->b;
						if (x->a->type == LSB_bitType) {
							LSV_Expression(x->a);
						} else {
							LSV_WriteString(__GUARDP(x->a, LSB_ObjDesc, 1)->name, 32);
						}
						LSV_WriteString((CHAR*)"), .T(", 7);
						if (x->b->type == LSB_bitType) {
							LSV_Expression(x->b);
						} else {
							LSV_WriteString(__GUARDP(x->b, LSB_ObjDesc, 1)->name, 32);
						}
						LSV_WriteString((CHAR*)"));", 4);
					} else {
						if (LSV_nofgen == 0) {
							LSV_WriteString((CHAR*)"genvar i;", 10);
							LSV_WriteLn();
						}
						LSV_nofgen += 1;
						LSV_WriteString((CHAR*)"generate", 9);
						LSV_WriteLn();
						LSV_WriteString((CHAR*)"for (i = 0; i < ", 17);
						LSV_WriteInt(size);
						LSV_WriteString((CHAR*)"; i = i+1) begin : bufblock", 28);
						LSV_WriteInt(LSV_nofgen);
						LSV_WriteLn();
						LSV_WriteString((CHAR*)"IOBUF block (.IO(", 18);
						LSV_WriteString(obj->name, 32);
						LSV_WriteString((CHAR*)"[i]), .O(", 10);
						LSV_WriteString(__GUARDP(x->a, LSB_ObjDesc, 1)->name, 32);
						LSV_WriteString((CHAR*)"[i]), .I(", 10);
						x = x->b;
						LSV_WriteString(__GUARDP(x->a, LSB_ObjDesc, 1)->name, 32);
						LSV_WriteString((CHAR*)"[i]), .T(", 10);
						if (x->b->type == LSB_bitType) {
							LSV_Expression(x->b);
						} else {
							LSV_WriteString(__GUARDP(x->b, LSB_ObjDesc, 1)->name, 32);
							LSV_WriteString((CHAR*)"[i]", 4);
						}
						LSV_WriteString((CHAR*)"));", 4);
						LSV_WriteLn();
						LSV_WriteString((CHAR*)"end", 4);
						LSV_WriteLn();
						LSV_WriteString((CHAR*)"endgenerate", 12);
					}
					LSV_WriteLn();
				}
			} else if ((obj->b != NIL && obj->val >= 2)) {
				LSV_WriteString((CHAR*)"assign ", 8);
				LSV_WriteString(obj->name, 32);
				if (obj->a != NIL) {
					LSV_Write('[');
					LSV_Expression(obj->a);
					LSV_Write(']');
				}
				LSV_WriteString((CHAR*)" = ", 4);
				LSV_Expression(obj->b);
				LSV_Write(';');
				LSV_WriteLn();
			}
		} else if (obj->tag == 2) {
		}
		obj = obj->next;
	}
}

static void LSV_ObjList2 (LSB_Object obj)
{
	LSB_Item apar = NIL;
	INT32 kind;
	LSB_Item clk = NIL;
	while (obj != LSB_root) {
		if ((((obj->tag == 3 && !__ISP(obj->type, LSB_UnitTypeDesc, 1))) && obj->val < 2)) {
			LSV_WriteString((CHAR*)"always @ (posedge ", 19);
			kind = obj->val;
			if (kind == 0) {
				LSV_Expression(obj->a);
			} else {
				LSV_WriteString((CHAR*)"clk", 4);
			}
			LSV_WriteString((CHAR*)") begin ", 9);
			do {
				LSV_WriteString(obj->name, 32);
				if ((kind == 1 && obj->a != NIL)) {
					LSV_Write('[');
					LSV_Expression(obj->a);
					LSV_Write(']');
				}
				LSV_WriteString((CHAR*)" <= ", 5);
				LSV_Expression(obj->b);
				LSV_Write(';');
				LSV_WriteLn();
				obj = obj->next;
			} while (!(obj == LSB_top || obj->val != kind));
			LSV_WriteString((CHAR*)"end", 4);
			LSV_WriteLn();
		} else {
			obj = obj->next;
		}
	}
}

void LSV_List (void)
{
	Texts_Scanner S;
	Texts_OpenScanner(&S, Texts_Scanner__typ, Oberon_Par->text, Oberon_Par->pos);
	Texts_Scan(&S, Texts_Scanner__typ);
	if (S.class == 1 || S.class == 2) {
		Texts_WriteString(&LSV_W, Texts_Writer__typ, LSB_modname, 32);
		Texts_WriteString(&LSV_W, Texts_Writer__typ, (CHAR*)" translating to  ", 18);
		Texts_WriteString(&LSV_W, Texts_Writer__typ, S.s, 64);
		LSV_F = Files_New(S.s, 64);
		Files_Set(&LSV_R, Files_Rider__typ, LSV_F, 0);
		LSV_WriteString((CHAR*)"`timescale 1ns / 1 ps", 22);
		LSV_WriteLn();
		LSV_nofgen = 0;
		LSV_WriteString((CHAR*)"module ", 8);
		LSV_WriteString(LSB_modname, 32);
		LSV_WriteString((CHAR*)"(   // translated from Lola", 28);
		LSV_WriteLn();
		LSV_ObjList0(LSB_top);
		LSV_ObjList1(LSB_top);
		LSV_ObjList2(LSB_top);
		LSV_WriteString((CHAR*)"endmodule", 10);
		LSV_WriteLn();
		Files_Register(LSV_F);
		Texts_WriteString(&LSV_W, Texts_Writer__typ, (CHAR*)" done", 6);
		Texts_WriteLn(&LSV_W, Texts_Writer__typ);
		Texts_Append(Oberon_Log, LSV_W.buf);
	}
}

static void EnumPtrs(void (*P)(void*))
{
	__ENUMR(&LSV_W, Texts_Writer__typ, 36, 1, P);
	P(LSV_F);
	__ENUMR(&LSV_R, Files_Rider__typ, 20, 1, P);
}


export void *LSV__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Files);
	__MODULE_IMPORT(LSB);
	__MODULE_IMPORT(Oberon);
	__MODULE_IMPORT(Texts);
	__REGMOD("LSV", EnumPtrs);
	__REGCMD("List", LSV_List);
/* BEGIN */
	Texts_OpenWriter(&LSV_W, Texts_Writer__typ);
	LSV_Constructor = LSV_Constructor0;
	__MOVE("CONST", LSV_C[1], 6);
	__MOVE("TYPE", LSV_C[2], 5);
	__MOVE("VAR", LSV_C[3], 4);
	__MOVE("LIT", LSV_C[4], 4);
	__MOVE("SEL", LSV_C[7], 4);
	__MOVE(":", LSV_C[8], 2);
	__MOVE(",", LSV_C[9], 2);
	__MOVE(" | ", LSV_C[15], 4);
	__MOVE(" ^ ", LSV_C[16], 4);
	__MOVE(" & ", LSV_C[12], 4);
	__MOVE("~", LSV_C[11], 2);
	__MOVE(" + ", LSV_C[17], 4);
	__MOVE(" - ", LSV_C[18], 4);
	__MOVE(" * ", LSV_C[13], 4);
	__MOVE(" / ", LSV_C[14], 4);
	__MOVE(" == ", LSV_C[20], 5);
	__MOVE(" != ", LSV_C[21], 5);
	__MOVE(" <  ", LSV_C[22], 5);
	__MOVE(" >= ", LSV_C[23], 5);
	__MOVE(" <= ", LSV_C[24], 5);
	__MOVE(" >  ", LSV_C[25], 5);
	__MOVE(" \? ", LSV_C[30], 4);
	__MOVE(" : ", LSV_C[31], 4);
	__MOVE("TS", LSV_C[32], 3);
	__MOVE("--", LSV_C[33], 3);
	__ENDMOD;
}
