/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#ifndef OPB__h
#define OPB__h

#include "SYSTEM.h"
#include "OPS.h"
#include "OPT.h"




import void OPB_Assign (OPT_Node *x, OPT_Node y);
import void OPB_Call (OPT_Node *x, OPT_Node apar, OPT_Object fp);
import void OPB_CheckParameters (OPT_Object fp, OPT_Object ap, BOOLEAN checkNames);
import void OPB_Construct (INT8 class, OPT_Node *x, OPT_Node y);
import void OPB_DeRef (OPT_Node *x);
import OPT_Node OPB_EmptySet (void);
import void OPB_Enter (OPT_Node *procdec, OPT_Node stat, OPT_Object proc);
import void OPB_Field (OPT_Node *x, OPT_Object y);
import void OPB_In (OPT_Node *x, OPT_Node y);
import void OPB_Index (OPT_Node *x, OPT_Node y);
import void OPB_Inittd (OPT_Node *inittd, OPT_Node *last, OPT_Struct typ);
import void OPB_Link (OPT_Node *x, OPT_Node *last, OPT_Node y);
import void OPB_MOp (INT8 op, OPT_Node *x);
import OPT_Node OPB_NewBoolConst (BOOLEAN boolval);
import OPT_Node OPB_NewIntConst (INT64 intval);
import OPT_Node OPB_NewLeaf (OPT_Object obj);
import OPT_Node OPB_NewRealConst (LONGREAL realval, OPT_Struct typ);
import OPT_Node OPB_NewString (OPS_String str, INT64 len);
import OPT_Node OPB_Nil (void);
import void OPB_Op (INT8 op, OPT_Node *x, OPT_Node y);
import void OPB_OptIf (OPT_Node *x);
import void OPB_Param (OPT_Node ap, OPT_Object fp);
import void OPB_PrepCall (OPT_Node *x, OPT_Object *fpar);
import void OPB_Return (OPT_Node *x, OPT_Object proc);
import void OPB_SetElem (OPT_Node *x);
import void OPB_SetRange (OPT_Node *x, OPT_Node y);
import void OPB_StFct (OPT_Node *par0, INT8 fctno, INT16 parno);
import void OPB_StPar0 (OPT_Node *par0, INT16 fctno);
import void OPB_StPar1 (OPT_Node *par0, OPT_Node x, INT8 fctno);
import void OPB_StParN (OPT_Node *par0, OPT_Node x, INT16 fctno, INT16 n);
import void OPB_StaticLink (INT8 dlev);
import void OPB_TypTest (OPT_Node *x, OPT_Object obj, BOOLEAN guard);
import void *OPB__init(void);


#endif // OPB
