/* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpa */

#ifndef LSS__h
#define LSS__h

#include "SYSTEM.h"
#include "Texts.h"

typedef
	CHAR LSS_Ident[32];


import INT32 LSS_val;
import LSS_Ident LSS_id;
import BOOLEAN LSS_error;


import void LSS_Get (INT16 *sym);
import void LSS_Init (Texts_Text T, INT32 pos);
import void LSS_Mark (CHAR *msg, ADDRESS msg__len);
import void *LSS__init(void);


#endif // LSS
