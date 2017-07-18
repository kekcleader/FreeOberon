/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpa */

#ifndef LSB__h
#define LSB__h

#include "SYSTEM.h"

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


import LSB_Object LSB_root, LSB_top;
import LSB_Type LSB_bitType, LSB_integer, LSB_string;
import LSB_ArrayType LSB_byteType, LSB_wordType;
import CHAR LSB_modname[32];

import ADDRESS *LSB_ItemDesc__typ;
import ADDRESS *LSB_ObjDesc__typ;
import ADDRESS *LSB_TypeDesc__typ;
import ADDRESS *LSB_ArrayTypeDesc__typ;
import ADDRESS *LSB_UnitTypeDesc__typ;

import void LSB_Register (CHAR *name, ADDRESS name__len, LSB_Object list);
import void *LSB__init(void);


#endif // LSB
