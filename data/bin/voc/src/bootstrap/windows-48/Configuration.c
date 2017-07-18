/* voc 2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8. xtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"


export CHAR Configuration_versionLong[76];





export void *Configuration__init(void)
{
	__DEFMOD;
	__REGMOD("Configuration", 0);
/* BEGIN */
	__MOVE("2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8.", Configuration_versionLong, 76);
	__ENDMOD;
}
