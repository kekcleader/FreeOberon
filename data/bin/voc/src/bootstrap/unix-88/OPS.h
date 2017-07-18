/* voc 2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8. tspaSF */

#ifndef OPS__h
#define OPS__h

#include "SYSTEM.h"

typedef
	CHAR OPS_Name[256];

typedef
	CHAR OPS_String[256];


import OPS_Name OPS_name;
import OPS_String OPS_str;
import INT16 OPS_numtyp;
import INT64 OPS_intval;
import REAL OPS_realval;
import LONGREAL OPS_lrlval;


import void OPS_Get (INT8 *sym);
import void OPS_Init (void);
import void *OPS__init(void);


#endif // OPS
