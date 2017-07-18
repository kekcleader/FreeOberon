/* voc 2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8. xtspaSF */

#ifndef VT100__h
#define VT100__h

#include "SYSTEM.h"


import CHAR VT100_CSI[5];


import void VT100_CHA (INT16 n);
import void VT100_CNL (INT16 n);
import void VT100_CPL (INT16 n);
import void VT100_CUB (INT16 n);
import void VT100_CUD (INT16 n);
import void VT100_CUF (INT16 n);
import void VT100_CUP (INT16 n, INT16 m);
import void VT100_CUU (INT16 n);
import void VT100_DECTCEMh (void);
import void VT100_DECTCEMl (void);
import void VT100_DSR (INT16 n);
import void VT100_ED (INT16 n);
import void VT100_EL (INT16 n);
import void VT100_HVP (INT16 n, INT16 m);
import void VT100_IntToStr (INT32 int_, CHAR *str, ADDRESS str__len);
import void VT100_RCP (void);
import void VT100_SCP (void);
import void VT100_SD (INT16 n);
import void VT100_SGR (INT16 n);
import void VT100_SGR2 (INT16 n, INT16 m);
import void VT100_SU (INT16 n);
import void VT100_SetAttr (CHAR *attr, ADDRESS attr__len);
import void *VT100__init(void);


#endif // VT100
