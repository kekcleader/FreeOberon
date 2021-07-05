/* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpa */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Oberon.h"
#include "Texts.h"

typedef
	CHAR LSS_Ident[32];


export INT32 LSS_val;
export LSS_Ident LSS_id;
export BOOLEAN LSS_error;
static CHAR LSS_ch;
static INT32 LSS_errpos;
static Texts_Reader LSS_R;
static Texts_Writer LSS_W;
static LSS_Ident LSS_key[11];
static INT16 LSS_symno[11];


export void LSS_Get (INT16 *sym);
export void LSS_Init (Texts_Text T, INT32 pos);
export void LSS_Mark (CHAR *msg, ADDRESS msg__len);
static void LSS_Number (INT16 *sym);
static void LSS_comment (void);
static void LSS_identifier (INT16 *sym);


void LSS_Mark (CHAR *msg, ADDRESS msg__len)
{
	INT32 p;
	__DUP(msg, msg__len, CHAR);
	p = Texts_Pos(&LSS_R, Texts_Reader__typ);
	if (p > LSS_errpos + 2) {
		Texts_WriteString(&LSS_W, Texts_Writer__typ, (CHAR*)"  pos ", 7);
		Texts_WriteInt(&LSS_W, Texts_Writer__typ, p, 1);
		Texts_WriteString(&LSS_W, Texts_Writer__typ, (CHAR*)"  err:  ", 9);
		Texts_WriteString(&LSS_W, Texts_Writer__typ, msg, msg__len);
		Texts_WriteLn(&LSS_W, Texts_Writer__typ);
		Texts_Append(Oberon_Log, LSS_W.buf);
	}
	LSS_errpos = p;
	LSS_error = 1;
	__DEL(msg);
}

static void LSS_identifier (INT16 *sym)
{
	INT16 i;
	i = 0;
	do {
		if (i < 32) {
			LSS_id[__X(i, 32)] = LSS_ch;
			i += 1;
		}
		Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
	} while (!(((LSS_ch < '0' || (LSS_ch > '9' && LSS_ch < 'A')) || (LSS_ch > 'Z' && LSS_ch < 'a')) || LSS_ch > 'z'));
	if (LSS_ch == '\'') {
		if (i < 32) {
			LSS_id[__X(i, 32)] = LSS_ch;
			i += 1;
		}
		Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
	}
	if (i == 32) {
		LSS_Mark((CHAR*)"ident too long", 15);
		LSS_id[31] = 0x00;
	} else {
		LSS_id[__X(i, 32)] = 0x00;
	}
	i = 0;
	while ((i < 11 && __STRCMP(LSS_id, LSS_key[__X(i, 11)]) != 0)) {
		i += 1;
	}
	if (i < 11) {
		*sym = LSS_symno[__X(i, 11)];
	} else {
		*sym = 31;
	}
}

static void LSS_Number (INT16 *sym)
{
	INT32 i, k, h, n, d;
	BOOLEAN hex;
	INT32 dig[16];
	*sym = 32;
	i = 0;
	k = 0;
	n = 0;
	hex = 0;
	do {
		if (n < 16) {
			d = (INT16)LSS_ch - 48;
			if (d >= 10) {
				hex = 1;
				d = d - 7;
			}
			dig[__X(n, 16)] = d;
			n += 1;
		} else {
			LSS_Mark((CHAR*)"too many digits", 16);
			n = 0;
		}
		Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
	} while (!((LSS_ch < '0' || (LSS_ch > '9' && LSS_ch < 'A')) || LSS_ch > 'F'));
	if (LSS_ch == 'H') {
		do {
			h = dig[__X(i, 16)];
			k = __ASHL(k, 4) + h;
			i += 1;
		} while (!(i == n));
		Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
	} else {
		if (hex) {
			LSS_Mark((CHAR*)"illegal hex digit", 18);
		}
		do {
			k = k * 10 + dig[__X(i, 16)];
			i += 1;
		} while (!(i == n));
	}
	LSS_val = k;
}

static void LSS_comment (void)
{
	Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
	do {
		while ((!LSS_R.eot && LSS_ch != '*')) {
			if (LSS_ch == '(') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				if (LSS_ch == '*') {
					LSS_comment();
				}
			} else {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
			}
		}
		while (LSS_ch == '*') {
			Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
		}
	} while (!(LSS_ch == ')' || LSS_R.eot));
	if (!LSS_R.eot) {
		Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
	} else {
		LSS_Mark((CHAR*)"comment not terminated", 23);
	}
}

void LSS_Get (INT16 *sym)
{
	do {
		while ((!LSS_R.eot && LSS_ch <= ' ')) {
			Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
		}
		if (LSS_R.eot) {
			*sym = 60;
		} else if (LSS_ch < 'A') {
			if (LSS_ch < '0') {
				if (LSS_ch == '!') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 29;
				} else if (LSS_ch == '#') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 11;
				} else if (LSS_ch == '$') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 0;
				} else if (LSS_ch == '&') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 4;
				} else if (LSS_ch == '\'') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 17;
				} else if (LSS_ch == '(') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					if (LSS_ch == '*') {
						*sym = 0;
						LSS_comment();
					} else {
						*sym = 26;
					}
				} else if (LSS_ch == ')') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 21;
				} else if (LSS_ch == '*') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 2;
				} else if (LSS_ch == '+') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 5;
				} else if (LSS_ch == ',') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 19;
				} else if (LSS_ch == '-') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					if (LSS_ch == '>') {
						Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
						*sym = 24;
					} else {
						*sym = 6;
					}
				} else if (LSS_ch == '.') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 18;
				} else if (LSS_ch == '/') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 3;
				} else {
					*sym = 0;
				}
			} else if (LSS_ch <= '9') {
				LSS_Number(&*sym);
			} else if (LSS_ch == ':') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				if (LSS_ch == '=') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 30;
				} else {
					*sym = 20;
				}
			} else if (LSS_ch == ';') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				*sym = 40;
			} else if (LSS_ch == '<') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				if (LSS_ch == '=') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 13;
				} else {
					*sym = 12;
				}
			} else if (LSS_ch == '=') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				*sym = 10;
			} else if (LSS_ch == '>') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				if (LSS_ch == '=') {
					Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
					*sym = 15;
				} else {
					*sym = 14;
				}
			} else if (LSS_ch == '\?') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				*sym = 24;
			} else if (LSS_ch == '@') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				*sym = 16;
			} else {
				*sym = 0;
			}
		} else if (LSS_ch <= 'Z') {
			LSS_identifier(&*sym);
		} else if (LSS_ch < 'a') {
			if (LSS_ch == '[') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				*sym = 27;
			} else if (LSS_ch == ']') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				*sym = 22;
			} else if (LSS_ch == '^') {
				Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
				*sym = 8;
			} else {
				*sym = 0;
			}
		} else if (LSS_ch <= 'z') {
			LSS_identifier(&*sym);
		} else if (LSS_ch <= '{') {
			Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
			*sym = 28;
		} else if (LSS_ch <= '|') {
			Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
			*sym = 7;
		} else if (LSS_ch <= '}') {
			Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
			*sym = 23;
		} else if (LSS_ch <= '~') {
			Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
			*sym = 9;
		} else {
			*sym = 0;
		}
	} while (!(*sym != 0));
}

void LSS_Init (Texts_Text T, INT32 pos)
{
	LSS_error = 0;
	LSS_errpos = pos;
	Texts_OpenReader(&LSS_R, Texts_Reader__typ, T, pos);
	Texts_Read(&LSS_R, Texts_Reader__typ, &LSS_ch);
}

static void EnumPtrs(void (*P)(void*))
{
	__ENUMR(&LSS_R, Texts_Reader__typ, 72, 1, P);
	__ENUMR(&LSS_W, Texts_Writer__typ, 56, 1, P);
}


export void *LSS__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Oberon);
	__MODULE_IMPORT(Texts);
	__REGMOD("LSS", EnumPtrs);
/* BEGIN */
	Texts_OpenWriter(&LSS_W, Texts_Writer__typ);
	__MOVE("BEGIN", LSS_key[0], 6);
	LSS_symno[0] = 58;
	__MOVE("CONST", LSS_key[1], 6);
	LSS_symno[1] = 51;
	__MOVE("END", LSS_key[2], 4);
	LSS_symno[2] = 41;
	__MOVE("IN", LSS_key[3], 3);
	LSS_symno[3] = 57;
	__MOVE("INOUT", LSS_key[4], 6);
	LSS_symno[4] = 56;
	__MOVE("MODULE", LSS_key[5], 7);
	LSS_symno[5] = 59;
	__MOVE("OUT", LSS_key[6], 4);
	LSS_symno[6] = 55;
	__MOVE("REG", LSS_key[7], 4);
	LSS_symno[7] = 53;
	__MOVE("TYPE", LSS_key[8], 5);
	LSS_symno[8] = 52;
	__MOVE("VAR", LSS_key[9], 4);
	LSS_symno[9] = 54;
	__MOVE("TS", LSS_key[10], 3);
	LSS_symno[10] = 33;
	__ENDMOD;
}
