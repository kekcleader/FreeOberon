/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpa */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Oberon.h"
#include "Texts.h"

typedef
	struct LSB_ArrayTypeDesc *LSB_ArrayType;

typedef
	struct LSB_ObjDesc *LSB_Object;

typedef
	struct LSB_TypeDesc {
		INT32 len, size;
		LSB_Object typobj;
	} LSB_TypeDesc;

typedef
	LSB_TypeDesc *LSB_Type;

typedef
	struct LSB_ArrayTypeDesc { /* LSB_TypeDesc */
		INT32 len, size;
		LSB_Object typobj;
		LSB_Type eltyp;
	} LSB_ArrayTypeDesc;

typedef
	struct LSB_ItemDesc *LSB_Item;

typedef
	struct LSB_ItemDesc {
		INT16 tag;
		LSB_Type type;
		INT32 val, size;
		LSB_Item a, b;
	} LSB_ItemDesc;

typedef
	struct LSB_ObjDesc { /* LSB_ItemDesc */
		INT16 tag;
		LSB_Type type;
		INT32 val, size;
		LSB_Item a, b;
		LSB_Object next;
		CHAR name[32];
		BOOLEAN marked;
	} LSB_ObjDesc;

typedef
	struct LSB_UnitTypeDesc *LSB_UnitType;

typedef
	struct LSB_UnitTypeDesc { /* LSB_TypeDesc */
		INT32 len, size;
		LSB_Object typobj;
		LSB_Object firstobj;
	} LSB_UnitTypeDesc;


export LSB_Object LSB_root, LSB_top;
export LSB_Type LSB_bitType, LSB_integer, LSB_string;
export LSB_ArrayType LSB_byteType, LSB_wordType;
export CHAR LSB_modname[32];

export ADDRESS *LSB_ItemDesc__typ;
export ADDRESS *LSB_ObjDesc__typ;
export ADDRESS *LSB_TypeDesc__typ;
export ADDRESS *LSB_ArrayTypeDesc__typ;
export ADDRESS *LSB_UnitTypeDesc__typ;

export void LSB_Register (CHAR *name, ADDRESS name__len, LSB_Object list);


void LSB_Register (CHAR *name, ADDRESS name__len, LSB_Object list)
{
	__DUP(name, name__len, CHAR);
	__COPY(name, LSB_modname, 32);
	LSB_top = list;
	__DEL(name);
}

static void EnumPtrs(void (*P)(void*))
{
	P(LSB_root);
	P(LSB_top);
	P(LSB_bitType);
	P(LSB_integer);
	P(LSB_string);
	P(LSB_byteType);
	P(LSB_wordType);
}

__TDESC(LSB_ItemDesc, 1, 3) = {__TDFLDS("ItemDesc", 24), {4, 16, 20, -16}};
__TDESC(LSB_ObjDesc, 1, 4) = {__TDFLDS("ObjDesc", 64), {4, 16, 20, 24, -20}};
__TDESC(LSB_TypeDesc, 1, 1) = {__TDFLDS("TypeDesc", 12), {8, -8}};
__TDESC(LSB_ArrayTypeDesc, 1, 2) = {__TDFLDS("ArrayTypeDesc", 16), {8, 12, -12}};
__TDESC(LSB_UnitTypeDesc, 1, 2) = {__TDFLDS("UnitTypeDesc", 16), {8, 12, -12}};

export void *LSB__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Oberon);
	__MODULE_IMPORT(Texts);
	__REGMOD("LSB", EnumPtrs);
	__INITYP(LSB_ItemDesc, LSB_ItemDesc, 0);
	__INITYP(LSB_ObjDesc, LSB_ItemDesc, 1);
	__INITYP(LSB_TypeDesc, LSB_TypeDesc, 0);
	__INITYP(LSB_ArrayTypeDesc, LSB_TypeDesc, 1);
	__INITYP(LSB_UnitTypeDesc, LSB_TypeDesc, 1);
/* BEGIN */
	__NEW(LSB_bitType, LSB_TypeDesc);
	LSB_bitType->len = 0;
	LSB_bitType->size = 1;
	__NEW(LSB_integer, LSB_TypeDesc);
	__NEW(LSB_string, LSB_TypeDesc);
	__NEW(LSB_byteType, LSB_ArrayTypeDesc);
	LSB_byteType->len = 8;
	LSB_byteType->size = 8;
	LSB_byteType->eltyp = LSB_bitType;
	__NEW(LSB_wordType, LSB_ArrayTypeDesc);
	LSB_wordType->len = 32;
	LSB_wordType->size = 32;
	LSB_wordType->eltyp = LSB_bitType;
	__NEW(LSB_root, LSB_ObjDesc);
	LSB_root->tag = 2;
	__MOVE("WORD", LSB_root->name, 5);
	LSB_root->type = (LSB_Type)LSB_wordType;
	LSB_root->next = NIL;
	__NEW(LSB_top, LSB_ObjDesc);
	LSB_top->tag = 2;
	__MOVE("BYTE", LSB_top->name, 5);
	LSB_top->type = (LSB_Type)LSB_byteType;
	LSB_top->next = LSB_root;
	LSB_root = LSB_top;
	__NEW(LSB_top, LSB_ObjDesc);
	LSB_top->tag = 2;
	__MOVE("BIT", LSB_top->name, 4);
	LSB_top->type = LSB_bitType;
	LSB_top->next = LSB_root;
	LSB_root = LSB_top;
	__ENDMOD;
}
