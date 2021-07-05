/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "OPB.h"
#include "OPM.h"
#include "OPS.h"
#include "OPT.h"

struct OPP__1 {
	INT32 low, high;
};

typedef
	struct OPP__1 OPP_CaseTable[128];


static INT8 OPP_sym, OPP_level;
static INT16 OPP_LoopLevel;
static OPT_Node OPP_TDinit, OPP_lastTDinit;
static INT16 OPP_nofFwdPtr;
static OPT_Struct OPP_FwdPtr[64];

export ADDRESS *OPP__1__typ;

static void OPP_ActualParameters (OPT_Node *aparlist, OPT_Object fpar);
static void OPP_ArrayType (OPT_Struct *typ, OPT_Struct *banned);
static void OPP_Block (OPT_Node *procdec, OPT_Node *statseq);
static void OPP_CaseLabelList (OPT_Node *lab, OPT_Struct LabelTyp, INT16 *n, OPP_CaseTable tab);
static void OPP_CheckMark (INT8 *vis);
static void OPP_CheckSym (INT16 s);
static void OPP_CheckSysFlag (INT16 *sysflag, INT16 default_);
static void OPP_ConstExpression (OPT_Node *x);
static void OPP_Element (OPT_Node *x);
static void OPP_Expression (OPT_Node *x);
static BOOLEAN OPP_Extends (OPT_Struct x, OPT_Struct b);
static void OPP_Factor (OPT_Node *x);
static void OPP_FormalParameters (OPT_Object *firstPar, OPT_Struct *resTyp);
export void OPP_Module (OPT_Node *prog, UINT32 opt);
static void OPP_PointerType (OPT_Struct *typ);
static void OPP_ProcedureDeclaration (OPT_Node *x);
static void OPP_Receiver (INT8 *mode, OPS_Name name, OPT_Struct *typ, OPT_Struct *rec);
static void OPP_RecordType (OPT_Struct *typ, OPT_Struct *banned);
static void OPP_Sets (OPT_Node *x);
static void OPP_SimpleExpression (OPT_Node *x);
static void OPP_StandProcCall (OPT_Node *x);
static void OPP_StatSeq (OPT_Node *stat);
static void OPP_Term (OPT_Node *x);
static void OPP_Type (OPT_Struct *typ, OPT_Struct *banned);
static void OPP_TypeDecl (OPT_Struct *typ, OPT_Struct *banned);
static void OPP_err (INT16 n);
static void OPP_qualident (OPT_Object *id);
static void OPP_selector (OPT_Node *x);


static void OPP_err (INT16 n)
{
	OPM_err(n);
}

static void OPP_CheckSym (INT16 s)
{
	if ((INT16)OPP_sym == s) {
		OPS_Get(&OPP_sym);
	} else {
		OPM_err(s);
	}
}

static void OPP_qualident (OPT_Object *id)
{
	OPT_Object obj = NIL;
	INT8 lev;
	OPT_Find(&obj);
	OPS_Get(&OPP_sym);
	if ((((OPP_sym == 18 && obj != NIL)) && obj->mode == 11)) {
		OPS_Get(&OPP_sym);
		if (OPP_sym == 38) {
			OPT_FindImport(obj, &obj);
			OPS_Get(&OPP_sym);
		} else {
			OPP_err(38);
			obj = NIL;
		}
	}
	if (obj == NIL) {
		OPP_err(0);
		obj = OPT_NewObj();
		obj->mode = 1;
		obj->typ = OPT_undftyp;
		obj->adr = 0;
	} else {
		lev = obj->mnolev;
		if ((__IN(obj->mode, 0x06, 32) && lev != OPP_level)) {
			obj->leaf = 0;
			if (lev > 0) {
				OPB_StaticLink(OPP_level - lev);
			}
		}
	}
	*id = obj;
}

static void OPP_ConstExpression (OPT_Node *x)
{
	OPP_Expression(&*x);
	if ((*x)->class != 7) {
		OPP_err(50);
		*x = OPB_NewIntConst(1);
	}
}

static void OPP_CheckMark (INT8 *vis)
{
	OPS_Get(&OPP_sym);
	if (OPP_sym == 1 || OPP_sym == 7) {
		if (OPP_level > 0) {
			OPP_err(47);
		}
		if (OPP_sym == 1) {
			*vis = 1;
		} else {
			*vis = 2;
		}
		OPS_Get(&OPP_sym);
	} else {
		*vis = 0;
	}
}

static void OPP_CheckSysFlag (INT16 *sysflag, INT16 default_)
{
	OPT_Node x = NIL;
	INT64 sf;
	if (OPP_sym == 31) {
		OPS_Get(&OPP_sym);
		if (!OPT_SYSimported) {
			OPP_err(135);
		}
		OPP_ConstExpression(&x);
		if (x->typ->form == 4) {
			sf = x->conval->intval;
			if (sf < 0 || sf > 1) {
				OPP_err(220);
				sf = 0;
			}
		} else {
			OPP_err(51);
			sf = 0;
		}
		*sysflag = OPM_Integer(sf);
		OPP_CheckSym(23);
	} else {
		*sysflag = default_;
	}
}

static void OPP_RecordType (OPT_Struct *typ, OPT_Struct *banned)
{
	OPT_Object fld = NIL, first = NIL, last = NIL, base = NIL;
	OPT_Struct ftyp = NIL;
	INT16 sysflag;
	*typ = OPT_NewStr(13, 4);
	(*typ)->BaseTyp = NIL;
	OPP_CheckSysFlag(&sysflag, -1);
	if (OPP_sym == 30) {
		OPS_Get(&OPP_sym);
		if (OPP_sym == 38) {
			OPP_qualident(&base);
			if ((base->mode == 5 && base->typ->comp == 4)) {
				if (base->typ == *banned) {
					OPP_err(58);
				} else {
					base->typ->pvused = 1;
					(*typ)->BaseTyp = base->typ;
					(*typ)->extlev = base->typ->extlev + 1;
					(*typ)->sysflag = base->typ->sysflag;
				}
			} else {
				OPP_err(52);
			}
		} else {
			OPP_err(38);
		}
		OPP_CheckSym(22);
	}
	if (sysflag >= 0) {
		(*typ)->sysflag = sysflag;
	}
	OPT_OpenScope(0, NIL);
	first = NIL;
	last = NIL;
	for (;;) {
		if (OPP_sym == 38) {
			for (;;) {
				if (OPP_sym == 38) {
					if ((*typ)->BaseTyp != NIL) {
						OPT_FindField(OPS_name, (*typ)->BaseTyp, &fld);
						if (fld != NIL) {
							OPP_err(1);
						}
					}
					OPT_Insert(OPS_name, &fld);
					OPP_CheckMark(&fld->vis);
					fld->mode = 4;
					fld->link = NIL;
					fld->typ = OPT_undftyp;
					if (first == NIL) {
						first = fld;
					}
					if (last == NIL) {
						(*typ)->link = fld;
					} else {
						last->link = fld;
					}
					last = fld;
				} else {
					OPP_err(38);
				}
				if (OPP_sym == 19) {
					OPS_Get(&OPP_sym);
				} else if (OPP_sym == 38) {
					OPP_err(19);
				} else {
					break;
				}
			}
			OPP_CheckSym(20);
			OPP_Type(&ftyp, &*banned);
			ftyp->pvused = 1;
			if (ftyp->comp == 3) {
				ftyp = OPT_undftyp;
				OPP_err(88);
			}
			while (first != NIL) {
				first->typ = ftyp;
				first = first->link;
			}
		}
		if (OPP_sym == 39) {
			OPS_Get(&OPP_sym);
		} else if (OPP_sym == 38) {
			OPP_err(39);
		} else {
			break;
		}
	}
	OPT_CloseScope();
}

static void OPP_ArrayType (OPT_Struct *typ, OPT_Struct *banned)
{
	OPT_Node x = NIL;
	INT64 n;
	INT16 sysflag;
	OPP_CheckSysFlag(&sysflag, 0);
	if (OPP_sym == 25) {
		*typ = OPT_NewStr(13, 3);
		(*typ)->mno = 0;
		(*typ)->sysflag = sysflag;
		OPS_Get(&OPP_sym);
		OPP_Type(&(*typ)->BaseTyp, &*banned);
		(*typ)->BaseTyp->pvused = 1;
		if ((*typ)->BaseTyp->comp == 3) {
			(*typ)->n = (*typ)->BaseTyp->n + 1;
		} else {
			(*typ)->n = 0;
		}
	} else {
		*typ = OPT_NewStr(13, 2);
		(*typ)->sysflag = sysflag;
		OPP_ConstExpression(&x);
		if (x->typ->form == 4) {
			n = x->conval->intval;
			if (n <= 0 || n > OPM_MaxIndex) {
				OPP_err(63);
				n = 1;
			}
		} else {
			OPP_err(51);
			n = 1;
		}
		(*typ)->n = OPM_Longint(n);
		if (OPP_sym == 25) {
			OPS_Get(&OPP_sym);
			OPP_Type(&(*typ)->BaseTyp, &*banned);
			(*typ)->BaseTyp->pvused = 1;
		} else if (OPP_sym == 19) {
			OPS_Get(&OPP_sym);
			if (OPP_sym != 25) {
				OPP_ArrayType(&(*typ)->BaseTyp, &*banned);
			}
		} else {
			OPP_err(35);
		}
		if ((*typ)->BaseTyp->comp == 3) {
			(*typ)->BaseTyp = OPT_undftyp;
			OPP_err(88);
		}
	}
}

static void OPP_PointerType (OPT_Struct *typ)
{
	OPT_Object id = NIL;
	*typ = OPT_NewStr(11, 1);
	OPP_CheckSysFlag(&(*typ)->sysflag, 0);
	OPP_CheckSym(28);
	if (OPP_sym == 38) {
		OPT_Find(&id);
		if (id == NIL) {
			if (OPP_nofFwdPtr < 64) {
				OPP_FwdPtr[__X(OPP_nofFwdPtr, 64)] = *typ;
				OPP_nofFwdPtr += 1;
			} else {
				OPP_err(224);
			}
			(*typ)->link = OPT_NewObj();
			__COPY(OPS_name, (*typ)->link->name, 256);
			(*typ)->BaseTyp = OPT_undftyp;
			OPS_Get(&OPP_sym);
		} else {
			OPP_qualident(&id);
			if (id->mode == 5) {
				if (__IN(id->typ->comp, 0x1c, 32)) {
					(*typ)->BaseTyp = id->typ;
				} else {
					(*typ)->BaseTyp = OPT_undftyp;
					OPP_err(57);
				}
			} else {
				(*typ)->BaseTyp = OPT_undftyp;
				OPP_err(52);
			}
		}
	} else {
		OPP_Type(&(*typ)->BaseTyp, &OPT_notyp);
		if (!__IN((*typ)->BaseTyp->comp, 0x1c, 32)) {
			(*typ)->BaseTyp = OPT_undftyp;
			OPP_err(57);
		}
	}
}

static void OPP_FormalParameters (OPT_Object *firstPar, OPT_Struct *resTyp)
{
	INT8 mode;
	OPT_Object par = NIL, first = NIL, last = NIL, res = NIL;
	OPT_Struct typ = NIL;
	first = NIL;
	last = *firstPar;
	if (OPP_sym == 38 || OPP_sym == 60) {
		for (;;) {
			if (OPP_sym == 60) {
				OPS_Get(&OPP_sym);
				mode = 2;
			} else {
				mode = 1;
			}
			for (;;) {
				if (OPP_sym == 38) {
					OPT_Insert(OPS_name, &par);
					OPS_Get(&OPP_sym);
					par->mode = mode;
					par->link = NIL;
					if (first == NIL) {
						first = par;
					}
					if (*firstPar == NIL) {
						*firstPar = par;
					} else {
						last->link = par;
					}
					last = par;
				} else {
					OPP_err(38);
				}
				if (OPP_sym == 19) {
					OPS_Get(&OPP_sym);
				} else if (OPP_sym == 38) {
					OPP_err(19);
				} else if (OPP_sym == 60) {
					OPP_err(19);
					OPS_Get(&OPP_sym);
				} else {
					break;
				}
			}
			OPP_CheckSym(20);
			OPP_Type(&typ, &OPT_notyp);
			if (((typ->comp == 2 || typ->comp == 4) && typ->strobj == NIL)) {
				OPP_err(-309);
			}
			if (mode == 1) {
				typ->pvused = 1;
			}
			while (first != NIL) {
				first->typ = typ;
				first = first->link;
			}
			if (OPP_sym == 39) {
				OPS_Get(&OPP_sym);
			} else if (OPP_sym == 38) {
				OPP_err(39);
			} else {
				break;
			}
		}
	}
	OPP_CheckSym(22);
	if (OPP_sym == 20) {
		OPS_Get(&OPP_sym);
		*resTyp = OPT_undftyp;
		if (OPP_sym == 38) {
			OPP_qualident(&res);
			if (res->mode == 5) {
				if (res->typ->form < 13) {
					*resTyp = res->typ;
				} else {
					OPP_err(54);
				}
			} else {
				OPP_err(52);
			}
		} else {
			OPP_err(38);
		}
	} else {
		*resTyp = OPT_notyp;
	}
}

static void OPP_TypeDecl (OPT_Struct *typ, OPT_Struct *banned)
{
	OPT_Object id = NIL;
	*typ = OPT_undftyp;
	if (OPP_sym < 30) {
		OPP_err(12);
		do {
			OPS_Get(&OPP_sym);
		} while (!(OPP_sym >= 30));
	}
	if (OPP_sym == 38) {
		OPP_qualident(&id);
		if (id->mode == 5) {
			if (id->typ == *banned) {
				OPP_err(58);
			} else {
				*typ = id->typ;
			}
		} else {
			OPP_err(52);
		}
	} else if (OPP_sym == 54) {
		OPS_Get(&OPP_sym);
		OPP_ArrayType(&*typ, &*banned);
	} else if (OPP_sym == 55) {
		OPS_Get(&OPP_sym);
		OPP_RecordType(&*typ, &*banned);
		OPB_Inittd(&OPP_TDinit, &OPP_lastTDinit, *typ);
		OPP_CheckSym(41);
	} else if (OPP_sym == 56) {
		OPS_Get(&OPP_sym);
		OPP_PointerType(&*typ);
	} else if (OPP_sym == 61) {
		OPS_Get(&OPP_sym);
		*typ = OPT_NewStr(12, 1);
		OPP_CheckSysFlag(&(*typ)->sysflag, 0);
		if (OPP_sym == 30) {
			OPS_Get(&OPP_sym);
			OPT_OpenScope(OPP_level, NIL);
			OPP_FormalParameters(&(*typ)->link, &(*typ)->BaseTyp);
			OPT_CloseScope();
		} else {
			(*typ)->BaseTyp = OPT_notyp;
			(*typ)->link = NIL;
		}
	} else {
		OPP_err(12);
	}
	for (;;) {
		if (((OPP_sym >= 39 && OPP_sym <= 42) || OPP_sym == 22) || OPP_sym == 64) {
			break;
		}
		OPP_err(15);
		if (OPP_sym == 38) {
			break;
		}
		OPS_Get(&OPP_sym);
	}
}

static void OPP_Type (OPT_Struct *typ, OPT_Struct *banned)
{
	OPP_TypeDecl(&*typ, &*banned);
	if (((((*typ)->form == 11 && (*typ)->BaseTyp == OPT_undftyp)) && (*typ)->strobj == NIL)) {
		OPP_err(0);
	}
}

static void OPP_selector (OPT_Node *x)
{
	OPT_Object obj = NIL, proc = NIL;
	OPT_Node y = NIL;
	OPT_Struct typ = NIL;
	OPS_Name name;
	for (;;) {
		if (OPP_sym == 31) {
			OPS_Get(&OPP_sym);
			for (;;) {
				if (((*x)->typ != NIL && (*x)->typ->form == 11)) {
					OPB_DeRef(&*x);
				}
				OPP_Expression(&y);
				OPB_Index(&*x, y);
				if (OPP_sym == 19) {
					OPS_Get(&OPP_sym);
				} else {
					break;
				}
			}
			OPP_CheckSym(23);
		} else if (OPP_sym == 18) {
			OPS_Get(&OPP_sym);
			if (OPP_sym == 38) {
				__MOVE(OPS_name, name, 256);
				OPS_Get(&OPP_sym);
				if ((*x)->typ != NIL) {
					if ((*x)->typ->form == 11) {
						OPB_DeRef(&*x);
					}
					if ((*x)->typ->comp == 4) {
						OPT_FindField(name, (*x)->typ, &obj);
						OPB_Field(&*x, obj);
						if ((obj != NIL && obj->mode == 13)) {
							if (OPP_sym == 17) {
								OPS_Get(&OPP_sym);
								y = (*x)->left;
								if (y->class == 3) {
									y = y->left;
								}
								if (y->obj != NIL) {
									proc = OPT_topScope;
									while ((proc->link != NIL && proc->link->mode != 13)) {
										proc = proc->left;
									}
									if (proc->link == NIL || proc->link->link != y->obj) {
										OPP_err(75);
									}
									typ = y->obj->typ;
									if (typ->form == 11) {
										typ = typ->BaseTyp;
									}
									OPT_FindField((*x)->obj->name, typ->BaseTyp, &proc);
									if (proc != NIL) {
										(*x)->subcl = 1;
									} else {
										OPP_err(74);
									}
								} else {
									OPP_err(75);
								}
							}
							if ((obj->typ != OPT_notyp && OPP_sym != 30)) {
								OPP_err(30);
							}
						}
					} else {
						OPP_err(53);
					}
				} else {
					OPP_err(52);
				}
			} else {
				OPP_err(38);
			}
		} else if (OPP_sym == 17) {
			OPS_Get(&OPP_sym);
			OPB_DeRef(&*x);
		} else if ((((((OPP_sym == 30 && (*x)->class < 7)) && (*x)->typ->form != 12)) && ((*x)->obj == NIL || (*x)->obj->mode != 13))) {
			OPS_Get(&OPP_sym);
			if (OPP_sym == 38) {
				OPP_qualident(&obj);
				if (obj->mode == 5) {
					OPB_TypTest(&*x, obj, 1);
				} else {
					OPP_err(52);
				}
			} else {
				OPP_err(38);
			}
			OPP_CheckSym(22);
		} else {
			break;
		}
	}
}

static void OPP_ActualParameters (OPT_Node *aparlist, OPT_Object fpar)
{
	OPT_Node apar = NIL, last = NIL;
	*aparlist = NIL;
	last = NIL;
	if (OPP_sym != 22) {
		for (;;) {
			OPP_Expression(&apar);
			if (fpar != NIL) {
				OPB_Param(apar, fpar);
				OPB_Link(&*aparlist, &last, apar);
				fpar = fpar->link;
			} else {
				OPP_err(64);
			}
			if (OPP_sym == 19) {
				OPS_Get(&OPP_sym);
			} else if ((30 <= OPP_sym && OPP_sym <= 38)) {
				OPP_err(19);
			} else {
				break;
			}
		}
	}
	if (fpar != NIL) {
		OPP_err(65);
	}
}

static void OPP_StandProcCall (OPT_Node *x)
{
	OPT_Node y = NIL;
	INT8 m;
	INT16 n;
	m = __SHORT(__SHORT((*x)->obj->adr, 32768), 128);
	n = 0;
	if (OPP_sym == 30) {
		OPS_Get(&OPP_sym);
		if (OPP_sym != 22) {
			for (;;) {
				if (n == 0) {
					OPP_Expression(&*x);
					OPB_StPar0(&*x, m);
					n = 1;
				} else if (n == 1) {
					OPP_Expression(&y);
					OPB_StPar1(&*x, y, m);
					n = 2;
				} else {
					OPP_Expression(&y);
					OPB_StParN(&*x, y, m, n);
					n += 1;
				}
				if (OPP_sym == 19) {
					OPS_Get(&OPP_sym);
				} else if ((30 <= OPP_sym && OPP_sym <= 38)) {
					OPP_err(19);
				} else {
					break;
				}
			}
			OPP_CheckSym(22);
		} else {
			OPS_Get(&OPP_sym);
		}
		OPB_StFct(&*x, m, n);
	} else {
		OPP_err(30);
	}
	if ((OPP_level > 0 && (m == 1 || m == 30))) {
		OPT_topScope->link->leaf = 0;
	}
}

static void OPP_Element (OPT_Node *x)
{
	OPT_Node y = NIL;
	OPP_Expression(&*x);
	if (OPP_sym == 21) {
		OPS_Get(&OPP_sym);
		OPP_Expression(&y);
		OPB_SetRange(&*x, y);
	} else {
		OPB_SetElem(&*x);
	}
}

static void OPP_Sets (OPT_Node *x)
{
	OPT_Node y = NIL;
	if (OPP_sym != 24) {
		OPP_Element(&*x);
		for (;;) {
			if (OPP_sym == 19) {
				OPS_Get(&OPP_sym);
			} else if ((30 <= OPP_sym && OPP_sym <= 38)) {
				OPP_err(19);
			} else {
				break;
			}
			OPP_Element(&y);
			OPB_Op(6, &*x, y);
		}
	} else {
		*x = OPB_EmptySet();
	}
	OPP_CheckSym(24);
}

static void OPP_Factor (OPT_Node *x)
{
	OPT_Object fpar = NIL, id = NIL;
	OPT_Node apar = NIL;
	if (OPP_sym < 30) {
		OPP_err(13);
		do {
			OPS_Get(&OPP_sym);
		} while (!(OPP_sym >= 30));
	}
	if (OPP_sym == 38) {
		OPP_qualident(&id);
		*x = OPB_NewLeaf(id);
		OPP_selector(&*x);
		if (((*x)->class == 9 && (*x)->obj->mode == 8)) {
			OPP_StandProcCall(&*x);
		} else if (OPP_sym == 30) {
			OPS_Get(&OPP_sym);
			OPB_PrepCall(&*x, &fpar);
			OPP_ActualParameters(&apar, fpar);
			OPB_Call(&*x, apar, fpar);
			OPP_CheckSym(22);
			if (OPP_level > 0) {
				OPT_topScope->link->leaf = 0;
			}
		}
	} else if (OPP_sym == 35) {
		switch (OPS_numtyp) {
			case 1: 
				*x = OPB_NewIntConst(OPS_intval);
				(*x)->typ = OPT_chartyp;
				break;
			case 2: 
				*x = OPB_NewIntConst(OPS_intval);
				break;
			case 3: 
				*x = OPB_NewRealConst(OPS_realval, OPT_realtyp);
				break;
			case 4: 
				*x = OPB_NewRealConst(OPS_lrlval, OPT_lrltyp);
				break;
			default: 
				OPM_LogWStr((CHAR*)"unhandled case in OPP.Factor, OPS.numtyp = ", 44);
				OPM_LogWNum(OPS_numtyp, 0);
				OPM_LogWLn();
				break;
		}
		OPS_Get(&OPP_sym);
	} else if (OPP_sym == 37) {
		*x = OPB_NewString(OPS_str, OPS_intval);
		OPS_Get(&OPP_sym);
	} else if (OPP_sym == 36) {
		*x = OPB_Nil();
		OPS_Get(&OPP_sym);
	} else if (OPP_sym == 30) {
		OPS_Get(&OPP_sym);
		OPP_Expression(&*x);
		OPP_CheckSym(22);
	} else if (OPP_sym == 31) {
		OPS_Get(&OPP_sym);
		OPP_err(30);
		OPP_Expression(&*x);
		OPP_CheckSym(22);
	} else if (OPP_sym == 32) {
		OPS_Get(&OPP_sym);
		OPP_Sets(&*x);
	} else if (OPP_sym == 33) {
		OPS_Get(&OPP_sym);
		OPP_Factor(&*x);
		OPB_MOp(33, &*x);
	} else {
		OPP_err(13);
		OPS_Get(&OPP_sym);
		*x = NIL;
	}
	if (*x == NIL) {
		*x = OPB_NewIntConst(1);
		(*x)->typ = OPT_undftyp;
	}
}

static void OPP_Term (OPT_Node *x)
{
	OPT_Node y = NIL;
	INT8 mulop;
	OPP_Factor(&*x);
	while ((1 <= OPP_sym && OPP_sym <= 5)) {
		mulop = OPP_sym;
		OPS_Get(&OPP_sym);
		OPP_Factor(&y);
		OPB_Op(mulop, &*x, y);
	}
}

static void OPP_SimpleExpression (OPT_Node *x)
{
	OPT_Node y = NIL;
	INT8 addop;
	if (OPP_sym == 7) {
		OPS_Get(&OPP_sym);
		OPP_Term(&*x);
		OPB_MOp(7, &*x);
	} else if (OPP_sym == 6) {
		OPS_Get(&OPP_sym);
		OPP_Term(&*x);
		OPB_MOp(6, &*x);
	} else {
		OPP_Term(&*x);
	}
	while ((6 <= OPP_sym && OPP_sym <= 8)) {
		addop = OPP_sym;
		OPS_Get(&OPP_sym);
		OPP_Term(&y);
		OPB_Op(addop, &*x, y);
	}
}

static void OPP_Expression (OPT_Node *x)
{
	OPT_Node y = NIL;
	OPT_Object obj = NIL;
	INT8 relation;
	OPP_SimpleExpression(&*x);
	if ((9 <= OPP_sym && OPP_sym <= 14)) {
		relation = OPP_sym;
		OPS_Get(&OPP_sym);
		OPP_SimpleExpression(&y);
		OPB_Op(relation, &*x, y);
	} else if (OPP_sym == 15) {
		OPS_Get(&OPP_sym);
		OPP_SimpleExpression(&y);
		OPB_In(&*x, y);
	} else if (OPP_sym == 16) {
		OPS_Get(&OPP_sym);
		if (OPP_sym == 38) {
			OPP_qualident(&obj);
			if (obj->mode == 5) {
				OPB_TypTest(&*x, obj, 0);
			} else {
				OPP_err(52);
			}
		} else {
			OPP_err(38);
		}
	}
}

static void OPP_Receiver (INT8 *mode, OPS_Name name, OPT_Struct *typ, OPT_Struct *rec)
{
	OPT_Object obj = NIL;
	*typ = OPT_undftyp;
	*rec = NIL;
	if (OPP_sym == 60) {
		OPS_Get(&OPP_sym);
		*mode = 2;
	} else {
		*mode = 1;
	}
	__MOVE(OPS_name, name, 256);
	OPP_CheckSym(38);
	OPP_CheckSym(20);
	if (OPP_sym == 38) {
		OPT_Find(&obj);
		OPS_Get(&OPP_sym);
		if (obj == NIL) {
			OPP_err(0);
		} else if (obj->mode != 5) {
			OPP_err(72);
		} else {
			*typ = obj->typ;
			*rec = *typ;
			if ((*rec)->form == 11) {
				*rec = (*rec)->BaseTyp;
			}
			if (!((((*mode == 1 && (*typ)->form == 11)) && (*rec)->comp == 4) || (*mode == 2 && (*typ)->comp == 4))) {
				OPP_err(70);
				*rec = NIL;
			}
			if ((*rec != NIL && (*rec)->mno != OPP_level)) {
				OPP_err(72);
				*rec = NIL;
			}
		}
	} else {
		OPP_err(38);
	}
	OPP_CheckSym(22);
	if (*rec == NIL) {
		*rec = OPT_NewStr(13, 4);
		(*rec)->BaseTyp = NIL;
	}
}

static BOOLEAN OPP_Extends (OPT_Struct x, OPT_Struct b)
{
	if ((b->form == 11 && x->form == 11)) {
		b = b->BaseTyp;
		x = x->BaseTyp;
	}
	if ((b->comp == 4 && x->comp == 4)) {
		do {
			x = x->BaseTyp;
		} while (!(x == NIL || x == b));
	}
	return x == b;
}

static struct ProcedureDeclaration__16 {
	OPT_Node *x;
	OPT_Object *proc, *fwd;
	OPS_Name *name;
	INT8 *mode, *vis;
	BOOLEAN *forward;
	struct ProcedureDeclaration__16 *lnk;
} *ProcedureDeclaration__16_s;

static void Body__17 (void);
static void GetCode__19 (void);
static void GetParams__21 (void);
static void TProcDecl__23 (void);

static void GetCode__19 (void)
{
	OPT_ConstExt ext = NIL;
	INT16 n;
	INT64 c;
	ext = OPT_NewExt();
	(*ProcedureDeclaration__16_s->proc)->conval->ext = ext;
	n = 0;
	if (OPP_sym == 37) {
		while (OPS_str[__X(n, 256)] != 0x00) {
			(*ext)[__X(n + 1, 256)] = OPS_str[__X(n, 256)];
			n += 1;
		}
		(*ext)[0] = __CHR(n);
		OPS_Get(&OPP_sym);
	} else {
		for (;;) {
			if (OPP_sym == 35) {
				c = OPS_intval;
				n += 1;
				if ((c < 0 || c > 255) || n == 256) {
					OPP_err(64);
					c = 1;
					n = 1;
				}
				OPS_Get(&OPP_sym);
				(*ext)[__X(n, 256)] = __CHR(c);
			}
			if (OPP_sym == 19) {
				OPS_Get(&OPP_sym);
			} else if (OPP_sym == 35) {
				OPP_err(19);
			} else {
				(*ext)[0] = __CHR(n);
				break;
			}
		}
	}
	(*ProcedureDeclaration__16_s->proc)->conval->setval |= __SETOF(1,64);
}

static void GetParams__21 (void)
{
	(*ProcedureDeclaration__16_s->proc)->vis = *ProcedureDeclaration__16_s->vis;
	(*ProcedureDeclaration__16_s->proc)->mode = *ProcedureDeclaration__16_s->mode;
	(*ProcedureDeclaration__16_s->proc)->typ = OPT_notyp;
	(*ProcedureDeclaration__16_s->proc)->conval = OPT_NewConst();
	(*ProcedureDeclaration__16_s->proc)->conval->setval = 0x0;
	if (OPP_sym == 30) {
		OPS_Get(&OPP_sym);
		OPP_FormalParameters(&(*ProcedureDeclaration__16_s->proc)->link, &(*ProcedureDeclaration__16_s->proc)->typ);
	}
	if (*ProcedureDeclaration__16_s->fwd != NIL) {
		OPB_CheckParameters((*ProcedureDeclaration__16_s->proc)->link, (*ProcedureDeclaration__16_s->fwd)->link, 1);
		if ((*ProcedureDeclaration__16_s->proc)->typ != (*ProcedureDeclaration__16_s->fwd)->typ) {
			OPP_err(117);
		}
		*ProcedureDeclaration__16_s->proc = *ProcedureDeclaration__16_s->fwd;
		OPT_topScope = (*ProcedureDeclaration__16_s->proc)->scope;
		if (*ProcedureDeclaration__16_s->mode == 10) {
			(*ProcedureDeclaration__16_s->proc)->mode = 10;
		}
	}
}

static void Body__17 (void)
{
	OPT_Node procdec = NIL, statseq = NIL;
	INT32 c;
	c = OPM_errpos;
	(*ProcedureDeclaration__16_s->proc)->conval->setval |= __SETOF(1,64);
	OPP_CheckSym(39);
	OPP_Block(&procdec, &statseq);
	OPB_Enter(&procdec, statseq, *ProcedureDeclaration__16_s->proc);
	*ProcedureDeclaration__16_s->x = procdec;
	(*ProcedureDeclaration__16_s->x)->conval = OPT_NewConst();
	(*ProcedureDeclaration__16_s->x)->conval->intval = c;
	if (OPP_sym == 38) {
		if (__STRCMP(OPS_name, (*ProcedureDeclaration__16_s->proc)->name) != 0) {
			OPP_err(4);
		}
		OPS_Get(&OPP_sym);
	} else {
		OPP_err(38);
	}
}

static void TProcDecl__23 (void)
{
	OPT_Object baseProc = NIL;
	OPT_Struct objTyp = NIL, recTyp = NIL;
	INT8 objMode;
	OPS_Name objName;
	OPS_Get(&OPP_sym);
	*ProcedureDeclaration__16_s->mode = 13;
	if (OPP_level > 0) {
		OPP_err(73);
	}
	OPP_Receiver(&objMode, objName, &objTyp, &recTyp);
	if (OPP_sym == 38) {
		__MOVE(OPS_name, *ProcedureDeclaration__16_s->name, 256);
		OPP_CheckMark(&*ProcedureDeclaration__16_s->vis);
		OPT_FindField(*ProcedureDeclaration__16_s->name, recTyp, &*ProcedureDeclaration__16_s->fwd);
		OPT_FindField(*ProcedureDeclaration__16_s->name, recTyp->BaseTyp, &baseProc);
		if ((baseProc != NIL && baseProc->mode != 13)) {
			baseProc = NIL;
		}
		if (*ProcedureDeclaration__16_s->fwd == baseProc) {
			*ProcedureDeclaration__16_s->fwd = NIL;
		}
		if ((*ProcedureDeclaration__16_s->fwd != NIL && (*ProcedureDeclaration__16_s->fwd)->mnolev != OPP_level)) {
			*ProcedureDeclaration__16_s->fwd = NIL;
		}
		if ((((*ProcedureDeclaration__16_s->fwd != NIL && (*ProcedureDeclaration__16_s->fwd)->mode == 13)) && !__IN(1, (*ProcedureDeclaration__16_s->fwd)->conval->setval, 64))) {
			*ProcedureDeclaration__16_s->proc = OPT_NewObj();
			(*ProcedureDeclaration__16_s->proc)->leaf = 1;
			if ((*ProcedureDeclaration__16_s->fwd)->vis != *ProcedureDeclaration__16_s->vis) {
				OPP_err(118);
			}
		} else {
			if (*ProcedureDeclaration__16_s->fwd != NIL) {
				OPP_err(1);
				*ProcedureDeclaration__16_s->fwd = NIL;
			}
			OPT_OpenScope(0, NIL);
			OPT_topScope->right = recTyp->link;
			OPT_Insert(*ProcedureDeclaration__16_s->name, &*ProcedureDeclaration__16_s->proc);
			recTyp->link = OPT_topScope->right;
			OPT_CloseScope();
		}
		OPP_level += 1;
		OPT_OpenScope(OPP_level, *ProcedureDeclaration__16_s->proc);
		OPT_Insert(objName, &(*ProcedureDeclaration__16_s->proc)->link);
		(*ProcedureDeclaration__16_s->proc)->link->mode = objMode;
		(*ProcedureDeclaration__16_s->proc)->link->typ = objTyp;
		GetParams__21();
		if (baseProc != NIL) {
			if (objMode != baseProc->link->mode || !OPP_Extends(objTyp, baseProc->link->typ)) {
				OPP_err(115);
			}
			OPB_CheckParameters((*ProcedureDeclaration__16_s->proc)->link->link, baseProc->link->link, 0);
			if ((*ProcedureDeclaration__16_s->proc)->typ != baseProc->typ) {
				OPP_err(117);
			}
			if ((((((baseProc->vis == 1 && (*ProcedureDeclaration__16_s->proc)->vis == 0)) && recTyp->strobj != NIL)) && recTyp->strobj->vis == 1)) {
				OPP_err(109);
			}
			(*ProcedureDeclaration__16_s->proc)->conval->setval |= __SETOF(2,64);
		}
		if (!*ProcedureDeclaration__16_s->forward) {
			Body__17();
		}
		OPP_level -= 1;
		OPT_CloseScope();
	} else {
		OPP_err(38);
	}
}

static void OPP_ProcedureDeclaration (OPT_Node *x)
{
	OPT_Object proc = NIL, fwd = NIL;
	OPS_Name name;
	INT8 mode, vis;
	BOOLEAN forward;
	struct ProcedureDeclaration__16 _s;
	_s.x = x;
	_s.proc = &proc;
	_s.fwd = &fwd;
	_s.name = (void*)name;
	_s.mode = &mode;
	_s.vis = &vis;
	_s.forward = &forward;
	_s.lnk = ProcedureDeclaration__16_s;
	ProcedureDeclaration__16_s = &_s;
	proc = NIL;
	forward = 0;
	*x = NIL;
	mode = 6;
	if ((OPP_sym != 38 && OPP_sym != 30)) {
		if (OPP_sym == 1) {
		} else if (OPP_sym == 17) {
			forward = 1;
		} else if (OPP_sym == 6) {
			mode = 10;
		} else if (OPP_sym == 7) {
			mode = 9;
		} else {
			OPP_err(38);
		}
		if ((__IN(mode, 0x0600, 32) && !OPT_SYSimported)) {
			OPP_err(135);
		}
		OPS_Get(&OPP_sym);
	}
	if (OPP_sym == 30) {
		TProcDecl__23();
	} else if (OPP_sym == 38) {
		OPT_Find(&fwd);
		__MOVE(OPS_name, name, 256);
		OPP_CheckMark(&vis);
		if ((vis != 0 && mode == 6)) {
			mode = 7;
		}
		if ((fwd != NIL && (fwd->mnolev != OPP_level || fwd->mode == 8))) {
			fwd = NIL;
		}
		if ((((fwd != NIL && __IN(fwd->mode, 0xc0, 32))) && !__IN(1, fwd->conval->setval, 64))) {
			proc = OPT_NewObj();
			proc->leaf = 1;
			if (fwd->vis != vis) {
				OPP_err(118);
			}
		} else {
			if (fwd != NIL) {
				OPP_err(1);
				fwd = NIL;
			}
			OPT_Insert(name, &proc);
		}
		if ((mode != 6 && OPP_level > 0)) {
			OPP_err(73);
		}
		OPP_level += 1;
		OPT_OpenScope(OPP_level, proc);
		proc->link = NIL;
		GetParams__21();
		if (mode == 9) {
			GetCode__19();
		} else if (!forward) {
			Body__17();
		}
		OPP_level -= 1;
		OPT_CloseScope();
	} else {
		OPP_err(38);
	}
	ProcedureDeclaration__16_s = _s.lnk;
}

static void OPP_CaseLabelList (OPT_Node *lab, OPT_Struct LabelTyp, INT16 *n, OPP_CaseTable tab)
{
	OPT_Node x = NIL, y = NIL, lastlab = NIL;
	INT16 i, f;
	INT32 xval, yval;
	*lab = NIL;
	lastlab = NIL;
	for (;;) {
		OPP_ConstExpression(&x);
		f = x->typ->form;
		if (__IN(f, 0x18, 32)) {
			xval = OPM_Longint(x->conval->intval);
		} else {
			OPP_err(61);
			xval = 1;
		}
		if (f == 4) {
			if (!(LabelTyp->form == 4) || LabelTyp->size < x->typ->size) {
				OPP_err(60);
			}
		} else if ((INT16)LabelTyp->form != f) {
			OPP_err(60);
		}
		if (OPP_sym == 21) {
			OPS_Get(&OPP_sym);
			OPP_ConstExpression(&y);
			yval = OPM_Longint(y->conval->intval);
			if (((INT16)y->typ->form != f && !((f == 4 && y->typ->form == 4)))) {
				OPP_err(60);
			}
			if (yval < xval) {
				OPP_err(63);
				yval = xval;
			}
		} else {
			yval = xval;
		}
		x->conval->intval2 = yval;
		i = *n;
		if (i < 128) {
			for (;;) {
				if (i == 0) {
					break;
				}
				if (tab[__X(i - 1, 128)].low <= yval) {
					if (tab[__X(i - 1, 128)].high >= xval) {
						OPP_err(62);
					}
					break;
				}
				tab[__X(i, 128)] = tab[__X(i - 1, 128)];
				i -= 1;
			}
			tab[__X(i, 128)].low = xval;
			tab[__X(i, 128)].high = yval;
			*n += 1;
		} else {
			OPP_err(213);
		}
		OPB_Link(&*lab, &lastlab, x);
		if (OPP_sym == 19) {
			OPS_Get(&OPP_sym);
		} else if (OPP_sym == 35 || OPP_sym == 38) {
			OPP_err(19);
		} else {
			break;
		}
	}
}

static struct StatSeq__30 {
	INT32 *pos;
	struct StatSeq__30 *lnk;
} *StatSeq__30_s;

static void CasePart__31 (OPT_Node *x);
static void CheckBool__33 (OPT_Node *x);
static void SetPos__35 (OPT_Node x);

static void CasePart__31 (OPT_Node *x)
{
	INT16 n;
	INT32 low, high;
	BOOLEAN e;
	OPP_CaseTable tab;
	OPT_Node cases = NIL, lab = NIL, y = NIL, lastcase = NIL;
	OPP_Expression(&*x);
	*StatSeq__30_s->pos = OPM_errpos;
	if ((*x)->class == 8 || (*x)->class == 9) {
		OPP_err(126);
	} else if (!__IN((*x)->typ->form, 0x18, 32)) {
		OPP_err(125);
	}
	OPP_CheckSym(25);
	cases = NIL;
	lastcase = NIL;
	n = 0;
	for (;;) {
		if (OPP_sym < 40) {
			OPP_CaseLabelList(&lab, (*x)->typ, &n, tab);
			OPP_CheckSym(20);
			OPP_StatSeq(&y);
			OPB_Construct(17, &lab, y);
			OPB_Link(&cases, &lastcase, lab);
		}
		if (OPP_sym == 40) {
			OPS_Get(&OPP_sym);
		} else {
			break;
		}
	}
	if (n > 0) {
		low = tab[0].low;
		high = tab[__X(n - 1, 128)].high;
		if (high - low > 512) {
			OPP_err(209);
		}
	} else {
		low = 1;
		high = 0;
	}
	e = OPP_sym == 42;
	if (e) {
		OPS_Get(&OPP_sym);
		OPP_StatSeq(&y);
	} else {
		y = NIL;
		OPM_Mark(-307, OPM_curpos);
	}
	OPB_Construct(16, &cases, y);
	OPB_Construct(21, &*x, cases);
	cases->conval = OPT_NewConst();
	cases->conval->intval = low;
	cases->conval->intval2 = high;
	if (e) {
		cases->conval->setval = 0x02;
	} else {
		cases->conval->setval = 0x0;
	}
}

static void SetPos__35 (OPT_Node x)
{
	x->conval = OPT_NewConst();
	x->conval->intval = *StatSeq__30_s->pos;
}

static void CheckBool__33 (OPT_Node *x)
{
	if ((*x)->class == 8 || (*x)->class == 9) {
		OPP_err(126);
		*x = OPB_NewBoolConst(0);
	} else if ((*x)->typ->form != 2) {
		OPP_err(120);
		*x = OPB_NewBoolConst(0);
	}
	*StatSeq__30_s->pos = OPM_errpos;
}

static void OPP_StatSeq (OPT_Node *stat)
{
	OPT_Object fpar = NIL, id = NIL, t = NIL, obj = NIL;
	OPT_Struct idtyp = NIL;
	BOOLEAN e;
	OPT_Node s = NIL, x = NIL, y = NIL, z = NIL, apar = NIL, last = NIL, lastif = NIL;
	INT32 pos;
	OPS_Name name;
	struct StatSeq__30 _s;
	_s.pos = &pos;
	_s.lnk = StatSeq__30_s;
	StatSeq__30_s = &_s;
	*stat = NIL;
	last = NIL;
	for (;;) {
		x = NIL;
		if (OPP_sym < 38) {
			OPP_err(14);
			do {
				OPS_Get(&OPP_sym);
			} while (!(OPP_sym >= 38));
		}
		if (OPP_sym == 38) {
			OPP_qualident(&id);
			x = OPB_NewLeaf(id);
			OPP_selector(&x);
			if (OPP_sym == 34) {
				OPS_Get(&OPP_sym);
				OPP_Expression(&y);
				OPB_Assign(&x, y);
			} else if (OPP_sym == 9) {
				OPP_err(34);
				OPS_Get(&OPP_sym);
				OPP_Expression(&y);
				OPB_Assign(&x, y);
			} else if ((x->class == 9 && x->obj->mode == 8)) {
				OPP_StandProcCall(&x);
				if ((x != NIL && x->typ != OPT_notyp)) {
					OPP_err(55);
				}
			} else {
				OPB_PrepCall(&x, &fpar);
				if (OPP_sym == 30) {
					OPS_Get(&OPP_sym);
					OPP_ActualParameters(&apar, fpar);
					OPP_CheckSym(22);
				} else {
					apar = NIL;
					if (fpar != NIL) {
						OPP_err(65);
					}
				}
				OPB_Call(&x, apar, fpar);
				if (x->typ != OPT_notyp) {
					OPP_err(55);
				}
				if (OPP_level > 0) {
					OPT_topScope->link->leaf = 0;
				}
			}
			pos = OPM_errpos;
		} else if (OPP_sym == 45) {
			OPS_Get(&OPP_sym);
			OPP_Expression(&x);
			CheckBool__33(&x);
			OPP_CheckSym(26);
			OPP_StatSeq(&y);
			OPB_Construct(15, &x, y);
			SetPos__35(x);
			lastif = x;
			while (OPP_sym == 43) {
				OPS_Get(&OPP_sym);
				OPP_Expression(&y);
				CheckBool__33(&y);
				OPP_CheckSym(26);
				OPP_StatSeq(&z);
				OPB_Construct(15, &y, z);
				SetPos__35(y);
				OPB_Link(&x, &lastif, y);
			}
			if (OPP_sym == 42) {
				OPS_Get(&OPP_sym);
				OPP_StatSeq(&y);
			} else {
				y = NIL;
			}
			OPB_Construct(20, &x, y);
			OPP_CheckSym(41);
			OPB_OptIf(&x);
			pos = OPM_errpos;
		} else if (OPP_sym == 46) {
			OPS_Get(&OPP_sym);
			CasePart__31(&x);
			OPP_CheckSym(41);
		} else if (OPP_sym == 47) {
			OPS_Get(&OPP_sym);
			OPP_Expression(&x);
			CheckBool__33(&x);
			OPP_CheckSym(27);
			OPP_StatSeq(&y);
			OPB_Construct(22, &x, y);
			OPP_CheckSym(41);
		} else if (OPP_sym == 48) {
			OPS_Get(&OPP_sym);
			OPP_StatSeq(&x);
			if (OPP_sym == 44) {
				OPS_Get(&OPP_sym);
				OPP_Expression(&y);
				CheckBool__33(&y);
			} else {
				OPP_err(44);
			}
			OPB_Construct(23, &x, y);
		} else if (OPP_sym == 49) {
			OPS_Get(&OPP_sym);
			if (OPP_sym == 38) {
				OPP_qualident(&id);
				if (!(id->typ->form == 4)) {
					OPP_err(68);
				}
				OPP_CheckSym(34);
				OPP_Expression(&y);
				pos = OPM_errpos;
				x = OPB_NewLeaf(id);
				OPB_Assign(&x, y);
				SetPos__35(x);
				OPP_CheckSym(28);
				OPP_Expression(&y);
				pos = OPM_errpos;
				if (y->class != 7) {
					__MOVE("@@", name, 3);
					OPT_Insert(name, &t);
					__MOVE("@for", t->name, 5);
					t->mode = 1;
					t->typ = x->left->typ;
					obj = OPT_topScope->scope;
					if (obj == NIL) {
						OPT_topScope->scope = t;
					} else {
						while (obj->link != NIL) {
							obj = obj->link;
						}
						obj->link = t;
					}
					z = OPB_NewLeaf(t);
					OPB_Assign(&z, y);
					SetPos__35(z);
					OPB_Link(&*stat, &last, z);
					y = OPB_NewLeaf(t);
				} else if (!(y->typ->form == 4) || y->typ->size > x->left->typ->size) {
					OPP_err(113);
				}
				OPB_Link(&*stat, &last, x);
				if (OPP_sym == 29) {
					OPS_Get(&OPP_sym);
					OPP_ConstExpression(&z);
				} else {
					z = OPB_NewIntConst(1);
				}
				pos = OPM_errpos;
				x = OPB_NewLeaf(id);
				if (z->conval->intval > 0) {
					OPB_Op(12, &x, y);
				} else if (z->conval->intval < 0) {
					OPB_Op(14, &x, y);
				} else {
					OPP_err(63);
					OPB_Op(14, &x, y);
				}
				OPP_CheckSym(27);
				OPP_StatSeq(&s);
				y = OPB_NewLeaf(id);
				OPB_StPar1(&y, z, 13);
				SetPos__35(y);
				if (s == NIL) {
					s = y;
				} else {
					z = s;
					while (z->link != NIL) {
						z = z->link;
					}
					z->link = y;
				}
				OPP_CheckSym(41);
				OPB_Construct(22, &x, s);
			} else {
				OPP_err(38);
			}
		} else if (OPP_sym == 50) {
			OPS_Get(&OPP_sym);
			OPP_LoopLevel += 1;
			OPP_StatSeq(&x);
			OPP_LoopLevel -= 1;
			OPB_Construct(24, &x, NIL);
			OPP_CheckSym(41);
			pos = OPM_errpos;
		} else if (OPP_sym == 51) {
			OPS_Get(&OPP_sym);
			idtyp = NIL;
			x = NIL;
			for (;;) {
				if (OPP_sym == 38) {
					OPP_qualident(&id);
					y = OPB_NewLeaf(id);
					if ((((id != NIL && id->typ->form == 11)) && (id->mode == 2 || !id->leaf))) {
						OPP_err(245);
					}
					OPP_CheckSym(20);
					if (OPP_sym == 38) {
						OPP_qualident(&t);
						if (t->mode == 5) {
							if (id != NIL) {
								idtyp = id->typ;
								OPB_TypTest(&y, t, 0);
								id->typ = t->typ;
							} else {
								OPP_err(130);
							}
						} else {
							OPP_err(52);
						}
					} else {
						OPP_err(38);
					}
				} else {
					OPP_err(38);
				}
				pos = OPM_errpos;
				OPP_CheckSym(27);
				OPP_StatSeq(&s);
				OPB_Construct(15, &y, s);
				SetPos__35(y);
				if (idtyp != NIL) {
					id->typ = idtyp;
					idtyp = NIL;
				}
				if (x == NIL) {
					x = y;
					lastif = x;
				} else {
					OPB_Link(&x, &lastif, y);
				}
				if (OPP_sym == 40) {
					OPS_Get(&OPP_sym);
				} else {
					break;
				}
			}
			e = OPP_sym == 42;
			if (e) {
				OPS_Get(&OPP_sym);
				OPP_StatSeq(&s);
			} else {
				s = NIL;
			}
			OPB_Construct(27, &x, s);
			OPP_CheckSym(41);
			if (e) {
				x->subcl = 1;
			}
		} else if (OPP_sym == 52) {
			OPS_Get(&OPP_sym);
			if (OPP_LoopLevel == 0) {
				OPP_err(46);
			}
			OPB_Construct(25, &x, NIL);
			pos = OPM_errpos;
		} else if (OPP_sym == 53) {
			OPS_Get(&OPP_sym);
			if (OPP_sym < 39) {
				OPP_Expression(&x);
			}
			if (OPP_level > 0) {
				OPB_Return(&x, OPT_topScope->link);
			} else {
				OPB_Return(&x, NIL);
			}
			pos = OPM_errpos;
		}
		if (x != NIL) {
			SetPos__35(x);
			OPB_Link(&*stat, &last, x);
		}
		if (OPP_sym == 39) {
			OPS_Get(&OPP_sym);
		} else if (OPP_sym <= 38 || (45 <= OPP_sym && OPP_sym <= 53)) {
			OPP_err(39);
		} else {
			break;
		}
	}
	StatSeq__30_s = _s.lnk;
}

static void OPP_Block (OPT_Node *procdec, OPT_Node *statseq)
{
	OPT_Struct typ = NIL;
	OPT_Object obj = NIL, first = NIL, last = NIL;
	OPT_Node x = NIL, lastdec = NIL;
	INT16 i;
	first = NIL;
	last = NIL;
	OPP_nofFwdPtr = 0;
	for (;;) {
		if (OPP_sym == 58) {
			OPS_Get(&OPP_sym);
			while (OPP_sym == 38) {
				OPT_Insert(OPS_name, &obj);
				OPP_CheckMark(&obj->vis);
				obj->typ = OPT_sinttyp;
				obj->mode = 1;
				if (OPP_sym == 9) {
					OPS_Get(&OPP_sym);
					OPP_ConstExpression(&x);
				} else if (OPP_sym == 34) {
					OPP_err(9);
					OPS_Get(&OPP_sym);
					OPP_ConstExpression(&x);
				} else {
					OPP_err(9);
					x = OPB_NewIntConst(1);
				}
				obj->mode = 3;
				obj->typ = x->typ;
				obj->conval = x->conval;
				OPP_CheckSym(39);
			}
		}
		if (OPP_sym == 59) {
			OPS_Get(&OPP_sym);
			while (OPP_sym == 38) {
				OPT_Insert(OPS_name, &obj);
				obj->mode = 5;
				obj->typ = OPT_undftyp;
				OPP_CheckMark(&obj->vis);
				if (OPP_sym == 9) {
					if (((((((((__STRCMP(obj->name, "SHORTINT") == 0 || __STRCMP(obj->name, "INTEGER") == 0) || __STRCMP(obj->name, "LONGINT") == 0) || __STRCMP(obj->name, "HUGEINT") == 0) || __STRCMP(obj->name, "REAL") == 0) || __STRCMP(obj->name, "LONGREAL") == 0) || __STRCMP(obj->name, "SET") == 0) || __STRCMP(obj->name, "CHAR") == 0) || __STRCMP(obj->name, "TRUE") == 0) || __STRCMP(obj->name, "FALSE") == 0) {
						OPM_Mark(-310, OPM_curpos);
					}
					OPS_Get(&OPP_sym);
					OPP_TypeDecl(&obj->typ, &obj->typ);
				} else if (OPP_sym == 34 || OPP_sym == 20) {
					OPP_err(9);
					OPS_Get(&OPP_sym);
					OPP_TypeDecl(&obj->typ, &obj->typ);
				} else {
					OPP_err(9);
				}
				if (obj->typ->strobj == NIL) {
					obj->typ->strobj = obj;
				}
				if (__IN(obj->typ->comp, 0x1c, 32)) {
					i = 0;
					while (i < OPP_nofFwdPtr) {
						typ = OPP_FwdPtr[__X(i, 64)];
						i += 1;
						if (__STRCMP(typ->link->name, obj->name) == 0) {
							typ->BaseTyp = obj->typ;
							typ->link->name[0] = 0x00;
						}
					}
				}
				OPP_CheckSym(39);
			}
		}
		if (OPP_sym == 60) {
			OPS_Get(&OPP_sym);
			while (OPP_sym == 38) {
				for (;;) {
					if (OPP_sym == 38) {
						OPT_Insert(OPS_name, &obj);
						OPP_CheckMark(&obj->vis);
						obj->mode = 1;
						obj->link = NIL;
						obj->leaf = obj->vis == 0;
						obj->typ = OPT_undftyp;
						if (first == NIL) {
							first = obj;
						}
						if (last == NIL) {
							OPT_topScope->scope = obj;
						} else {
							last->link = obj;
						}
						last = obj;
					} else {
						OPP_err(38);
					}
					if (OPP_sym == 19) {
						OPS_Get(&OPP_sym);
					} else if (OPP_sym == 38) {
						OPP_err(19);
					} else {
						break;
					}
				}
				OPP_CheckSym(20);
				OPP_Type(&typ, &OPT_notyp);
				typ->pvused = 1;
				if (typ->comp == 3) {
					typ = OPT_undftyp;
					OPP_err(88);
				}
				while (first != NIL) {
					first->typ = typ;
					first = first->link;
				}
				OPP_CheckSym(39);
			}
		}
		if (OPP_sym < 58 || OPP_sym > 60) {
			break;
		}
	}
	i = 0;
	while (i < OPP_nofFwdPtr) {
		if (OPP_FwdPtr[__X(i, 64)]->link->name[0] != 0x00) {
			OPP_err(128);
		}
		OPP_FwdPtr[__X(i, 64)] = NIL;
		i += 1;
	}
	OPT_topScope->adr = OPM_errpos;
	*procdec = NIL;
	lastdec = NIL;
	while (OPP_sym == 61) {
		OPS_Get(&OPP_sym);
		OPP_ProcedureDeclaration(&x);
		if (x != NIL) {
			if (lastdec == NIL) {
				*procdec = x;
			} else {
				lastdec->link = x;
			}
			lastdec = x;
		}
		OPP_CheckSym(39);
	}
	if (OPP_sym == 57) {
		OPS_Get(&OPP_sym);
		OPP_StatSeq(&*statseq);
	} else {
		*statseq = NIL;
	}
	if ((OPP_level == 0 && OPP_TDinit != NIL)) {
		OPP_lastTDinit->link = *statseq;
		*statseq = OPP_TDinit;
	}
	OPP_CheckSym(41);
}

void OPP_Module (OPT_Node *prog, UINT32 opt)
{
	OPS_Name impName, aliasName;
	OPT_Node procdec = NIL, statseq = NIL;
	INT32 c;
	BOOLEAN done;
	OPS_Init();
	OPP_LoopLevel = 0;
	OPP_level = 0;
	OPS_Get(&OPP_sym);
	if (OPP_sym == 63) {
		OPS_Get(&OPP_sym);
	} else {
		OPP_err(16);
	}
	if (OPP_sym == 38) {
		OPM_LogCompiling(OPS_name, 256);
		OPT_Init(OPS_name, opt);
		OPS_Get(&OPP_sym);
		OPP_CheckSym(39);
		if (OPP_sym == 62) {
			OPS_Get(&OPP_sym);
			for (;;) {
				if (OPP_sym == 38) {
					__COPY(OPS_name, aliasName, 256);
					__COPY(aliasName, impName, 256);
					OPS_Get(&OPP_sym);
					if (OPP_sym == 34) {
						OPS_Get(&OPP_sym);
						if (OPP_sym == 38) {
							__COPY(OPS_name, impName, 256);
							OPS_Get(&OPP_sym);
						} else {
							OPP_err(38);
						}
					}
					OPT_Import(aliasName, impName, &done);
				} else {
					OPP_err(38);
				}
				if (OPP_sym == 19) {
					OPS_Get(&OPP_sym);
				} else if (OPP_sym == 38) {
					OPP_err(19);
				} else {
					break;
				}
			}
			OPP_CheckSym(39);
		}
		if (OPM_noerr) {
			OPP_TDinit = NIL;
			OPP_lastTDinit = NIL;
			c = OPM_errpos;
			OPP_Block(&procdec, &statseq);
			OPB_Enter(&procdec, statseq, NIL);
			*prog = procdec;
			(*prog)->conval = OPT_NewConst();
			(*prog)->conval->intval = c;
			if (OPP_sym == 38) {
				if (__STRCMP(OPS_name, OPT_SelfName) != 0) {
					OPP_err(4);
				}
				OPS_Get(&OPP_sym);
			} else {
				OPP_err(38);
			}
			if (OPP_sym != 18) {
				OPP_err(18);
			}
		}
	} else {
		OPP_err(38);
	}
	OPP_TDinit = NIL;
	OPP_lastTDinit = NIL;
}

static void EnumPtrs(void (*P)(void*))
{
	P(OPP_TDinit);
	P(OPP_lastTDinit);
	__ENUMP(OPP_FwdPtr, 64, P);
}

__TDESC(OPP__1, 1, 0) = {__TDFLDS("", 8), {-8}};

export void *OPP__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(OPB);
	__MODULE_IMPORT(OPM);
	__MODULE_IMPORT(OPS);
	__MODULE_IMPORT(OPT);
	__REGMOD("OPP", EnumPtrs);
	__INITYP(OPP__1, OPP__1, 0);
/* BEGIN */
	__ENDMOD;
}
