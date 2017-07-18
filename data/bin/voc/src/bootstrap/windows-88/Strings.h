/* voc 2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8. xtspaSF */

#ifndef Strings__h
#define Strings__h

#include "SYSTEM.h"




import void Strings_Append (CHAR *extra, ADDRESS extra__len, CHAR *dest, ADDRESS dest__len);
import void Strings_Cap (CHAR *s, ADDRESS s__len);
import void Strings_Delete (CHAR *s, ADDRESS s__len, INT16 pos, INT16 n);
import void Strings_Extract (CHAR *source, ADDRESS source__len, INT16 pos, INT16 n, CHAR *dest, ADDRESS dest__len);
import void Strings_Insert (CHAR *source, ADDRESS source__len, INT16 pos, CHAR *dest, ADDRESS dest__len);
import INT16 Strings_Length (CHAR *s, ADDRESS s__len);
import BOOLEAN Strings_Match (CHAR *string, ADDRESS string__len, CHAR *pattern, ADDRESS pattern__len);
import INT16 Strings_Pos (CHAR *pattern, ADDRESS pattern__len, CHAR *s, ADDRESS s__len, INT16 pos);
import void Strings_Replace (CHAR *source, ADDRESS source__len, INT16 pos, CHAR *dest, ADDRESS dest__len);
import void Strings_StrToLongReal (CHAR *s, ADDRESS s__len, LONGREAL *r);
import void Strings_StrToReal (CHAR *s, ADDRESS s__len, REAL *r);
import void *Strings__init(void);


#endif // Strings
