/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Heap.h"
#include "Out.h"
#include "Platform.h"
#include "Strings.h"

typedef
	struct Files_FileDesc *Files_File;

typedef
	struct Files_BufDesc {
		Files_File f;
		BOOLEAN chg;
		INT32 org, size;
		SYSTEM_BYTE data[4096];
	} Files_BufDesc;

typedef
	Files_BufDesc *Files_Buffer;

typedef
	CHAR Files_FileName[256];

typedef
	struct Files_FileDesc {
		Files_FileName workName, registerName;
		BOOLEAN tempFile;
		Platform_FileIdentity identity;
		INT64 fd;
		INT32 len, pos;
		Files_Buffer bufs[4];
		INT16 swapper, state;
		struct Files_FileDesc *next;
	} Files_FileDesc;

typedef
	struct Files_Rider {
		INT32 res;
		BOOLEAN eof;
		Files_Buffer buf;
		INT32 org, offset;
	} Files_Rider;


export INT16 Files_MaxPathLength, Files_MaxNameLength;
static Files_FileDesc *Files_files;
static INT16 Files_tempno;
static CHAR Files_HOME[1024];
static struct {
	ADDRESS len[1];
	CHAR data[1];
} *Files_SearchPath;

export ADDRESS *Files_FileDesc__typ;
export ADDRESS *Files_BufDesc__typ;
export ADDRESS *Files_Rider__typ;

static void Files_Assert (BOOLEAN truth);
export Files_File Files_Base (Files_Rider *r, ADDRESS *r__typ);
static Files_File Files_CacheEntry (Platform_FileIdentity identity);
export void Files_ChangeDirectory (CHAR *path, ADDRESS path__len, INT16 *res);
export void Files_Close (Files_File f);
static void Files_CloseOSFile (Files_File f);
static void Files_Create (Files_File f);
export void Files_Delete (CHAR *name, ADDRESS name__len, INT16 *res);
static void Files_Deregister (CHAR *name, ADDRESS name__len);
static void Files_Err (CHAR *s, ADDRESS s__len, Files_File f, INT16 errcode);
static void Files_Finalize (SYSTEM_PTR o);
static void Files_FlipBytes (SYSTEM_BYTE *src, ADDRESS src__len, SYSTEM_BYTE *dest, ADDRESS dest__len);
static void Files_Flush (Files_Buffer buf);
export void Files_GetDate (Files_File f, INT32 *t, INT32 *d);
export void Files_GetName (Files_File f, CHAR *name, ADDRESS name__len);
static void Files_GetTempName (CHAR *finalName, ADDRESS finalName__len, CHAR *name, ADDRESS name__len);
static BOOLEAN Files_HasDir (CHAR *name, ADDRESS name__len);
export INT32 Files_Length (Files_File f);
static void Files_MakeFileName (CHAR *dir, ADDRESS dir__len, CHAR *name, ADDRESS name__len, CHAR *dest, ADDRESS dest__len);
export Files_File Files_New (CHAR *name, ADDRESS name__len);
export Files_File Files_Old (CHAR *name, ADDRESS name__len);
export INT32 Files_Pos (Files_Rider *r, ADDRESS *r__typ);
export void Files_Purge (Files_File f);
export void Files_Read (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x);
export void Files_ReadBool (Files_Rider *R, ADDRESS *R__typ, BOOLEAN *x);
export void Files_ReadBytes (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x, ADDRESS x__len, INT32 n);
export void Files_ReadInt (Files_Rider *R, ADDRESS *R__typ, INT16 *x);
export void Files_ReadLInt (Files_Rider *R, ADDRESS *R__typ, INT32 *x);
export void Files_ReadLReal (Files_Rider *R, ADDRESS *R__typ, LONGREAL *x);
export void Files_ReadLine (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len);
export void Files_ReadNum (Files_Rider *R, ADDRESS *R__typ, SYSTEM_BYTE *x, ADDRESS x__len);
export void Files_ReadReal (Files_Rider *R, ADDRESS *R__typ, REAL *x);
export void Files_ReadSet (Files_Rider *R, ADDRESS *R__typ, UINT32 *x);
export void Files_ReadString (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len);
export void Files_Register (Files_File f);
export void Files_Rename (CHAR *old, ADDRESS old__len, CHAR *new, ADDRESS new__len, INT16 *res);
static void Files_ScanPath (INT16 *pos, CHAR *dir, ADDRESS dir__len);
export void Files_Set (Files_Rider *r, ADDRESS *r__typ, Files_File f, INT32 pos);
export void Files_SetSearchPath (CHAR *path, ADDRESS path__len);
export void Files_Write (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE x);
export void Files_WriteBool (Files_Rider *R, ADDRESS *R__typ, BOOLEAN x);
export void Files_WriteBytes (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x, ADDRESS x__len, INT32 n);
export void Files_WriteInt (Files_Rider *R, ADDRESS *R__typ, INT16 x);
export void Files_WriteLInt (Files_Rider *R, ADDRESS *R__typ, INT32 x);
export void Files_WriteLReal (Files_Rider *R, ADDRESS *R__typ, LONGREAL x);
export void Files_WriteNum (Files_Rider *R, ADDRESS *R__typ, INT64 x);
export void Files_WriteReal (Files_Rider *R, ADDRESS *R__typ, REAL x);
export void Files_WriteSet (Files_Rider *R, ADDRESS *R__typ, UINT32 x);
export void Files_WriteString (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len);

#define Files_IdxTrap()	__HALT(-1)

static void Files_Assert (BOOLEAN truth)
{
	if (!truth) {
		Out_Ln();
		__ASSERT(truth, 0);
	}
}

static void Files_Err (CHAR *s, ADDRESS s__len, Files_File f, INT16 errcode)
{
	__DUP(s, s__len, CHAR);
	Out_Ln();
	Out_String((CHAR*)"-- ", 4);
	Out_String(s, s__len);
	Out_String((CHAR*)": ", 3);
	if (f != NIL) {
		if (f->registerName[0] != 0x00) {
			Out_String(f->registerName, 256);
		} else {
			Out_String(f->workName, 256);
		}
		if (f->fd != 0) {
			Out_String((CHAR*)", f.fd = ", 10);
			Out_Int(f->fd, 1);
		}
	}
	if (errcode != 0) {
		Out_String((CHAR*)", errcode = ", 13);
		Out_Int(errcode, 1);
	}
	Out_Ln();
	__HALT(99);
	__DEL(s);
}

static void Files_MakeFileName (CHAR *dir, ADDRESS dir__len, CHAR *name, ADDRESS name__len, CHAR *dest, ADDRESS dest__len)
{
	INT16 i, j, ld, ln;
	__DUP(dir, dir__len, CHAR);
	__DUP(name, name__len, CHAR);
	ld = Strings_Length(dir, dir__len);
	ln = Strings_Length(name, name__len);
	while ((ld > 0 && dir[__X(ld - 1, dir__len)] == '/')) {
		ld -= 1;
	}
	if (((ld + ln) + 2) > dest__len) {
		Files_Err((CHAR*)"File name too long", 19, NIL, 0);
	}
	i = 0;
	while (i < ld) {
		dest[__X(i, dest__len)] = dir[__X(i, dir__len)];
		i += 1;
	}
	if (i > 0) {
		dest[__X(i, dest__len)] = '/';
		i += 1;
	}
	j = 0;
	while (j < ln) {
		dest[__X(i, dest__len)] = name[__X(j, name__len)];
		i += 1;
		j += 1;
	}
	dest[__X(i, dest__len)] = 0x00;
	__DEL(dir);
	__DEL(name);
}

static void Files_GetTempName (CHAR *finalName, ADDRESS finalName__len, CHAR *name, ADDRESS name__len)
{
	INT16 i, n;
	__DUP(finalName, finalName__len, CHAR);
	if (finalName[0] == '/') {
		__COPY(finalName, name, name__len);
	} else {
		Files_MakeFileName(Platform_CWD, 4096, finalName, finalName__len, (void*)name, name__len);
	}
	i = Strings_Length(name, name__len) - 1;
	while ((i > 0 && name[__X(i, name__len)] != '/')) {
		i -= 1;
	}
	if ((i + 16) >= name__len) {
		Files_Err((CHAR*)"File name too long", 19, NIL, 0);
	}
	Files_tempno += 1;
	n = Files_tempno;
	name[__X(i + 1, name__len)] = '.';
	name[__X(i + 2, name__len)] = 't';
	name[__X(i + 3, name__len)] = 'm';
	name[__X(i + 4, name__len)] = 'p';
	name[__X(i + 5, name__len)] = '.';
	i += 6;
	while (n > 0) {
		name[__X(i, name__len)] = __CHR((int)__MOD(n, 10) + 48);
		n = __DIV(n, 10);
		i += 1;
	}
	name[__X(i, name__len)] = '.';
	i += 1;
	n = Platform_PID;
	while (n > 0) {
		name[__X(i, name__len)] = __CHR((int)__MOD(n, 10) + 48);
		n = __DIV(n, 10);
		i += 1;
	}
	name[__X(i, name__len)] = 0x00;
	__DEL(finalName);
}

static void Files_Deregister (CHAR *name, ADDRESS name__len)
{
	Platform_FileIdentity identity;
	Files_File osfile = NIL;
	INT16 error;
	__DUP(name, name__len, CHAR);
	if (Platform_IdentifyByName(name, name__len, &identity, Platform_FileIdentity__typ) == 0) {
		osfile = (Files_File)Files_files;
		while ((osfile != NIL && !Platform_SameFile(osfile->identity, identity))) {
			osfile = (Files_File)osfile->next;
		}
		if (osfile != NIL) {
			__ASSERT(!osfile->tempFile, 0);
			__ASSERT(osfile->fd >= 0, 0);
			__MOVE(osfile->workName, osfile->registerName, 256);
			Files_GetTempName(osfile->registerName, 256, (void*)osfile->workName, 256);
			osfile->tempFile = 1;
			osfile->state = 0;
			error = Platform_Rename((void*)osfile->registerName, 256, (void*)osfile->workName, 256);
			if (error != 0) {
				Files_Err((CHAR*)"Couldn't rename previous version of file being registered", 58, osfile, error);
			}
		}
	}
	__DEL(name);
}

static void Files_Create (Files_File f)
{
	BOOLEAN done;
	INT16 error;
	CHAR err[32];
	if (f->fd == -1) {
		if (f->state == 1) {
			Files_GetTempName(f->registerName, 256, (void*)f->workName, 256);
			f->tempFile = 1;
		} else {
			__ASSERT(f->state == 2, 0);
			Files_Deregister(f->registerName, 256);
			__MOVE(f->registerName, f->workName, 256);
			f->registerName[0] = 0x00;
			f->tempFile = 0;
		}
		error = Platform_Unlink((void*)f->workName, 256);
		error = Platform_New((void*)f->workName, 256, &f->fd);
		done = error == 0;
		if (done) {
			f->next = Files_files;
			Files_files = f;
			Heap_FileCount += 1;
			Heap_RegisterFinalizer((void*)f, Files_Finalize);
			f->state = 0;
			f->pos = 0;
			error = Platform_Identify(f->fd, &f->identity, Platform_FileIdentity__typ);
		} else {
			if (Platform_NoSuchDirectory(error)) {
				__MOVE("no such directory", err, 18);
			} else if (Platform_TooManyFiles(error)) {
				__MOVE("too many files open", err, 20);
			} else {
				__MOVE("file not created", err, 17);
			}
			Files_Err(err, 32, f, error);
		}
	}
}

static void Files_Flush (Files_Buffer buf)
{
	INT16 error;
	Files_File f = NIL;
	if (buf->chg) {
		f = buf->f;
		Files_Create(f);
		if (buf->org != f->pos) {
			error = Platform_Seek(f->fd, buf->org, Platform_SeekSet);
		}
		error = Platform_Write(f->fd, (ADDRESS)buf->data, buf->size);
		if (error != 0) {
			Files_Err((CHAR*)"error writing file", 19, f, error);
		}
		f->pos = buf->org + buf->size;
		buf->chg = 0;
		error = Platform_Identify(f->fd, &f->identity, Platform_FileIdentity__typ);
		if (error != 0) {
			Files_Err((CHAR*)"error identifying file", 23, f, error);
		}
	}
}

void Files_Close (Files_File f)
{
	INT32 i;
	INT16 error;
	if (f->state != 1 || f->registerName[0] != 0x00) {
		Files_Create(f);
		i = 0;
		while ((i < 4 && f->bufs[__X(i, 4)] != NIL)) {
			Files_Flush(f->bufs[__X(i, 4)]);
			i += 1;
		}
	}
}

INT32 Files_Length (Files_File f)
{
	return f->len;
}

Files_File Files_New (CHAR *name, ADDRESS name__len)
{
	Files_File f = NIL;
	__DUP(name, name__len, CHAR);
	__NEW(f, Files_FileDesc);
	f->workName[0] = 0x00;
	__COPY(name, f->registerName, 256);
	f->fd = -1;
	f->state = 1;
	f->len = 0;
	f->pos = 0;
	f->swapper = -1;
	__DEL(name);
	return f;
}

static void Files_ScanPath (INT16 *pos, CHAR *dir, ADDRESS dir__len)
{
	INT16 i;
	CHAR ch;
	i = 0;
	if (Files_SearchPath == NIL) {
		if (*pos == 0) {
			dir[0] = '.';
			i = 1;
			*pos += 1;
		}
	} else {
		ch = (Files_SearchPath->data)[__X(*pos, Files_SearchPath->len[0])];
		while (ch == ' ' || ch == ';') {
			*pos += 1;
			ch = (Files_SearchPath->data)[__X(*pos, Files_SearchPath->len[0])];
		}
		if (ch == '~') {
			*pos += 1;
			ch = (Files_SearchPath->data)[__X(*pos, Files_SearchPath->len[0])];
			while (Files_HOME[__X(i, 1024)] != 0x00) {
				dir[__X(i, dir__len)] = Files_HOME[__X(i, 1024)];
				i += 1;
			}
			if ((((((ch != '/' && ch != 0x00)) && ch != ';')) && ch != ' ')) {
				while ((i > 0 && dir[__X(i - 1, dir__len)] != '/')) {
					i -= 1;
				}
			}
		}
		while ((ch != 0x00 && ch != ';')) {
			dir[__X(i, dir__len)] = ch;
			i += 1;
			*pos += 1;
			ch = (Files_SearchPath->data)[__X(*pos, Files_SearchPath->len[0])];
		}
		while ((i > 0 && dir[__X(i - 1, dir__len)] == ' ')) {
			i -= 1;
		}
	}
	dir[__X(i, dir__len)] = 0x00;
}

static BOOLEAN Files_HasDir (CHAR *name, ADDRESS name__len)
{
	INT16 i;
	CHAR ch;
	i = 0;
	ch = name[0];
	while ((ch != 0x00 && ch != '/')) {
		i += 1;
		ch = name[__X(i, name__len)];
	}
	return ch == '/';
}

static Files_File Files_CacheEntry (Platform_FileIdentity identity)
{
	Files_File f = NIL;
	INT16 i, error;
	f = (Files_File)Files_files;
	while (f != NIL) {
		if (Platform_SameFile(identity, f->identity)) {
			if (!Platform_SameFileTime(identity, f->identity)) {
				i = 0;
				while (i < 4) {
					if (f->bufs[__X(i, 4)] != NIL) {
						f->bufs[__X(i, 4)]->org = -1;
						f->bufs[__X(i, 4)] = NIL;
					}
					i += 1;
				}
				f->swapper = -1;
				f->identity = identity;
				error = Platform_Size(f->fd, &f->len);
			}
			return f;
		}
		f = (Files_File)f->next;
	}
	return NIL;
}

Files_File Files_Old (CHAR *name, ADDRESS name__len)
{
	Files_File f = NIL;
	INT64 fd;
	INT16 pos;
	BOOLEAN done;
	CHAR dir[256], path[256];
	INT16 error;
	Platform_FileIdentity identity;
	__DUP(name, name__len, CHAR);
	if (name[0] != 0x00) {
		if (Files_HasDir((void*)name, name__len)) {
			dir[0] = 0x00;
			__COPY(name, path, 256);
		} else {
			pos = 0;
			Files_ScanPath(&pos, (void*)dir, 256);
			Files_MakeFileName(dir, 256, name, name__len, (void*)path, 256);
			Files_ScanPath(&pos, (void*)dir, 256);
		}
		for (;;) {
			error = Platform_OldRW((void*)path, 256, &fd);
			done = error == 0;
			if ((!done && Platform_TooManyFiles(error))) {
				Files_Err((CHAR*)"too many files open", 20, f, error);
			}
			if ((!done && Platform_Inaccessible(error))) {
				error = Platform_OldRO((void*)path, 256, &fd);
				done = error == 0;
			}
			if ((!done && !Platform_Absent(error))) {
				Out_String((CHAR*)"Warning: Files.Old ", 20);
				Out_String(name, name__len);
				Out_String((CHAR*)" error = ", 10);
				Out_Int(error, 0);
				Out_Ln();
			}
			if (done) {
				error = Platform_Identify(fd, &identity, Platform_FileIdentity__typ);
				f = Files_CacheEntry(identity);
				if (f != NIL) {
					error = Platform_Close(fd);
					__DEL(name);
					return f;
				} else {
					__NEW(f, Files_FileDesc);
					Heap_RegisterFinalizer((void*)f, Files_Finalize);
					f->fd = fd;
					f->state = 0;
					f->pos = 0;
					f->swapper = -1;
					error = Platform_Size(fd, &f->len);
					__COPY(name, f->workName, 256);
					f->registerName[0] = 0x00;
					f->tempFile = 0;
					f->identity = identity;
					f->next = Files_files;
					Files_files = f;
					Heap_FileCount += 1;
					__DEL(name);
					return f;
				}
			} else if (dir[0] == 0x00) {
				__DEL(name);
				return NIL;
			} else {
				Files_MakeFileName(dir, 256, name, name__len, (void*)path, 256);
				Files_ScanPath(&pos, (void*)dir, 256);
			}
		}
	} else {
		__DEL(name);
		return NIL;
	}
	__RETCHK;
}

void Files_Purge (Files_File f)
{
	INT16 i;
	Platform_FileIdentity identity;
	INT16 error;
	i = 0;
	while (i < 4) {
		if (f->bufs[__X(i, 4)] != NIL) {
			f->bufs[__X(i, 4)]->org = -1;
			f->bufs[__X(i, 4)] = NIL;
		}
		i += 1;
	}
	if (f->fd != -1) {
		error = Platform_Truncate(f->fd, 0);
		error = Platform_Seek(f->fd, 0, Platform_SeekSet);
	}
	f->pos = 0;
	f->len = 0;
	f->swapper = -1;
	error = Platform_Identify(f->fd, &identity, Platform_FileIdentity__typ);
	Platform_SetMTime(&f->identity, Platform_FileIdentity__typ, identity);
}

void Files_GetDate (Files_File f, INT32 *t, INT32 *d)
{
	Platform_FileIdentity identity;
	INT16 error;
	Files_Create(f);
	error = Platform_Identify(f->fd, &identity, Platform_FileIdentity__typ);
	Platform_MTimeAsClock(identity, &*t, &*d);
}

INT32 Files_Pos (Files_Rider *r, ADDRESS *r__typ)
{
	Files_Assert((*r).offset <= 4096);
	return (*r).org + (*r).offset;
}

void Files_Set (Files_Rider *r, ADDRESS *r__typ, Files_File f, INT32 pos)
{
	INT32 org, offset, i, n;
	Files_Buffer buf = NIL;
	INT16 error;
	if (f != NIL) {
		if (pos > f->len) {
			pos = f->len;
		} else if (pos < 0) {
			pos = 0;
		}
		offset = __MASK(pos, -4096);
		org = pos - offset;
		i = 0;
		while ((((i < 4 && f->bufs[__X(i, 4)] != NIL)) && org != f->bufs[__X(i, 4)]->org)) {
			i += 1;
		}
		if (i < 4) {
			if (f->bufs[__X(i, 4)] == NIL) {
				__NEW(buf, Files_BufDesc);
				buf->chg = 0;
				buf->org = -1;
				buf->f = f;
				f->bufs[__X(i, 4)] = buf;
			} else {
				buf = f->bufs[__X(i, 4)];
			}
		} else {
			f->swapper = __MASK(f->swapper + 1, -4);
			buf = f->bufs[__X(f->swapper, 4)];
			Files_Flush(buf);
		}
		if (buf->org != org) {
			if (org == f->len) {
				buf->size = 0;
			} else {
				Files_Create(f);
				if (f->pos != org) {
					error = Platform_Seek(f->fd, org, Platform_SeekSet);
				}
				error = Platform_ReadBuf(f->fd, (void*)buf->data, 4096, &n);
				if (error != 0) {
					Files_Err((CHAR*)"read from file not done", 24, f, error);
				}
				f->pos = org + n;
				buf->size = n;
			}
			buf->org = org;
			buf->chg = 0;
		}
	} else {
		buf = NIL;
		org = 0;
		offset = 0;
	}
	Files_Assert(offset <= 4096);
	(*r).buf = buf;
	(*r).org = org;
	(*r).offset = offset;
	(*r).eof = 0;
	(*r).res = 0;
}

void Files_Read (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x)
{
	INT32 offset;
	Files_Buffer buf = NIL;
	buf = (*r).buf;
	offset = (*r).offset;
	if ((*r).org != buf->org) {
		Files_Set(&*r, r__typ, buf->f, (*r).org + offset);
		buf = (*r).buf;
		offset = (*r).offset;
	}
	Files_Assert(offset <= buf->size);
	if (offset < buf->size) {
		*x = buf->data[__X(offset, 4096)];
		(*r).offset = offset + 1;
	} else if ((*r).org + offset < buf->f->len) {
		Files_Set(&*r, r__typ, (*r).buf->f, (*r).org + offset);
		*x = (*r).buf->data[0];
		(*r).offset = 1;
	} else {
		*x = 0x00;
		(*r).eof = 1;
	}
}

void Files_ReadBytes (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x, ADDRESS x__len, INT32 n)
{
	INT32 xpos, min, restInBuf, offset;
	Files_Buffer buf = NIL;
	if (n > x__len) {
		Files_IdxTrap();
	}
	xpos = 0;
	buf = (*r).buf;
	offset = (*r).offset;
	while (n > 0) {
		if ((*r).org != buf->org || offset >= 4096) {
			Files_Set(&*r, r__typ, buf->f, (*r).org + offset);
			buf = (*r).buf;
			offset = (*r).offset;
		}
		restInBuf = buf->size - offset;
		if (restInBuf == 0) {
			(*r).res = n;
			(*r).eof = 1;
			return;
		} else if (n > restInBuf) {
			min = restInBuf;
		} else {
			min = n;
		}
		__MOVE((ADDRESS)&buf->data[__X(offset, 4096)], (ADDRESS)&x[__X(xpos, x__len)], min);
		offset += min;
		(*r).offset = offset;
		xpos += min;
		n -= min;
		Files_Assert(offset <= 4096);
	}
	(*r).res = 0;
	(*r).eof = 0;
}

Files_File Files_Base (Files_Rider *r, ADDRESS *r__typ)
{
	return (*r).buf->f;
}

void Files_Write (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE x)
{
	Files_Buffer buf = NIL;
	INT32 offset;
	buf = (*r).buf;
	offset = (*r).offset;
	Files_Assert(offset <= 4096);
	if ((*r).org != buf->org || offset >= 4096) {
		Files_Set(&*r, r__typ, buf->f, (*r).org + offset);
		buf = (*r).buf;
		offset = (*r).offset;
	}
	Files_Assert(offset < 4096);
	buf->data[__X(offset, 4096)] = x;
	buf->chg = 1;
	if (offset == buf->size) {
		buf->size += 1;
		buf->f->len += 1;
	}
	(*r).offset = offset + 1;
	(*r).res = 0;
}

void Files_WriteBytes (Files_Rider *r, ADDRESS *r__typ, SYSTEM_BYTE *x, ADDRESS x__len, INT32 n)
{
	INT32 xpos, min, restInBuf, offset;
	Files_Buffer buf = NIL;
	if (n > x__len) {
		Files_IdxTrap();
	}
	xpos = 0;
	buf = (*r).buf;
	offset = (*r).offset;
	while (n > 0) {
		Files_Assert(offset <= 4096);
		if ((*r).org != buf->org || offset >= 4096) {
			Files_Set(&*r, r__typ, buf->f, (*r).org + offset);
			buf = (*r).buf;
			offset = (*r).offset;
		}
		Files_Assert(offset <= 4096);
		restInBuf = 4096 - offset;
		if (n > restInBuf) {
			min = restInBuf;
		} else {
			min = n;
		}
		__MOVE((ADDRESS)&x[__X(xpos, x__len)], (ADDRESS)&buf->data[__X(offset, 4096)], min);
		offset += min;
		(*r).offset = offset;
		Files_Assert(offset <= 4096);
		if (offset > buf->size) {
			buf->f->len += offset - buf->size;
			buf->size = offset;
		}
		xpos += min;
		n -= min;
		buf->chg = 1;
	}
	(*r).res = 0;
}

void Files_Delete (CHAR *name, ADDRESS name__len, INT16 *res)
{
	__DUP(name, name__len, CHAR);
	Files_Deregister(name, name__len);
	*res = Platform_Unlink((void*)name, name__len);
	__DEL(name);
}

void Files_Rename (CHAR *old, ADDRESS old__len, CHAR *new, ADDRESS new__len, INT16 *res)
{
	INT64 fdold, fdnew;
	INT32 n;
	INT16 error, ignore;
	Platform_FileIdentity oldidentity, newidentity;
	CHAR buf[4096];
	__DUP(old, old__len, CHAR);
	__DUP(new, new__len, CHAR);
	error = Platform_IdentifyByName(old, old__len, &oldidentity, Platform_FileIdentity__typ);
	if (error == 0) {
		error = Platform_IdentifyByName(new, new__len, &newidentity, Platform_FileIdentity__typ);
		if ((error != 0 && !Platform_SameFile(oldidentity, newidentity))) {
			Files_Delete(new, new__len, &error);
		}
		error = Platform_Rename((void*)old, old__len, (void*)new, new__len);
		if (!Platform_DifferentFilesystems(error)) {
			*res = error;
			__DEL(old);
			__DEL(new);
			return;
		} else {
			error = Platform_OldRO((void*)old, old__len, &fdold);
			if (error != 0) {
				*res = 2;
				__DEL(old);
				__DEL(new);
				return;
			}
			error = Platform_New((void*)new, new__len, &fdnew);
			if (error != 0) {
				error = Platform_Close(fdold);
				*res = 3;
				__DEL(old);
				__DEL(new);
				return;
			}
			error = Platform_Read(fdold, (ADDRESS)buf, 4096, &n);
			while (n > 0) {
				error = Platform_Write(fdnew, (ADDRESS)buf, n);
				if (error != 0) {
					ignore = Platform_Close(fdold);
					ignore = Platform_Close(fdnew);
					Files_Err((CHAR*)"cannot move file", 17, NIL, error);
				}
				error = Platform_Read(fdold, (ADDRESS)buf, 4096, &n);
			}
			ignore = Platform_Close(fdold);
			ignore = Platform_Close(fdnew);
			if (n == 0) {
				error = Platform_Unlink((void*)old, old__len);
				*res = 0;
			} else {
				Files_Err((CHAR*)"cannot move file", 17, NIL, error);
			}
		}
	} else {
		*res = 2;
	}
	__DEL(old);
	__DEL(new);
}

void Files_Register (Files_File f)
{
	INT16 idx, errcode;
	Files_File f1 = NIL;
	if ((f->state == 1 && f->registerName[0] != 0x00)) {
		f->state = 2;
	}
	Files_Close(f);
	if (f->registerName[0] != 0x00) {
		Files_Deregister(f->registerName, 256);
		Files_Rename(f->workName, 256, f->registerName, 256, &errcode);
		if (errcode != 0) {
			Files_Err((CHAR*)"Couldn't rename temp name as register name", 43, f, errcode);
		}
		__MOVE(f->registerName, f->workName, 256);
		f->registerName[0] = 0x00;
		f->tempFile = 0;
	}
}

void Files_ChangeDirectory (CHAR *path, ADDRESS path__len, INT16 *res)
{
	__DUP(path, path__len, CHAR);
	*res = Platform_Chdir((void*)path, path__len);
	__DEL(path);
}

static void Files_FlipBytes (SYSTEM_BYTE *src, ADDRESS src__len, SYSTEM_BYTE *dest, ADDRESS dest__len)
{
	INT32 i, j;
	if (!Platform_LittleEndian) {
		i = src__len;
		j = 0;
		while (i > 0) {
			i -= 1;
			dest[__X(j, dest__len)] = src[__X(i, src__len)];
			j += 1;
		}
	} else {
		__MOVE((ADDRESS)src, (ADDRESS)dest, src__len);
	}
}

void Files_ReadBool (Files_Rider *R, ADDRESS *R__typ, BOOLEAN *x)
{
	Files_Read(&*R, R__typ, (CHAR*)(void*)&*x);
}

void Files_ReadInt (Files_Rider *R, ADDRESS *R__typ, INT16 *x)
{
	CHAR b[2];
	Files_ReadBytes(&*R, R__typ, (void*)b, 2, 2);
	*x = (INT16)b[0] + __ASHL((INT16)b[1], 8);
}

void Files_ReadLInt (Files_Rider *R, ADDRESS *R__typ, INT32 *x)
{
	CHAR b[4];
	Files_ReadBytes(&*R, R__typ, (void*)b, 4, 4);
	*x = (((INT16)b[0] + __ASHL((INT16)b[1], 8)) + __ASHL(b[2], 16)) + __ASHL(b[3], 24);
}

void Files_ReadSet (Files_Rider *R, ADDRESS *R__typ, UINT32 *x)
{
	CHAR b[4];
	INT32 l;
	Files_ReadBytes(&*R, R__typ, (void*)b, 4, 4);
	l = (((INT16)b[0] + __ASHL((INT16)b[1], 8)) + __ASHL(b[2], 16)) + __ASHL(b[3], 24);
	*x = (UINT32)l;
}

void Files_ReadReal (Files_Rider *R, ADDRESS *R__typ, REAL *x)
{
	CHAR b[4];
	Files_ReadBytes(&*R, R__typ, (void*)b, 4, 4);
	Files_FlipBytes((void*)b, 4, (void*)&*x, 4);
}

void Files_ReadLReal (Files_Rider *R, ADDRESS *R__typ, LONGREAL *x)
{
	CHAR b[8];
	Files_ReadBytes(&*R, R__typ, (void*)b, 8, 8);
	Files_FlipBytes((void*)b, 8, (void*)&*x, 8);
}

void Files_ReadString (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len)
{
	INT16 i;
	CHAR ch;
	i = 0;
	do {
		Files_Read(&*R, R__typ, (void*)&ch);
		x[__X(i, x__len)] = ch;
		i += 1;
	} while (!(ch == 0x00));
}

void Files_ReadLine (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len)
{
	INT16 i;
	i = 0;
	do {
		Files_Read(&*R, R__typ, (void*)&x[__X(i, x__len)]);
		i += 1;
	} while (!(x[__X(i - 1, x__len)] == 0x00 || x[__X(i - 1, x__len)] == 0x0a));
	if (x[__X(i - 1, x__len)] == 0x0a) {
		i -= 1;
	}
	if ((i > 0 && x[__X(i - 1, x__len)] == 0x0d)) {
		i -= 1;
	}
	x[__X(i, x__len)] = 0x00;
}

void Files_ReadNum (Files_Rider *R, ADDRESS *R__typ, SYSTEM_BYTE *x, ADDRESS x__len)
{
	INT8 s, b;
	INT64 q;
	s = 0;
	q = 0;
	Files_Read(&*R, R__typ, (void*)&b);
	while (b < 0) {
		q += (INT64)__ASH(((INT16)b + 128), s);
		s += 7;
		Files_Read(&*R, R__typ, (void*)&b);
	}
	q += (INT64)__ASH((__MASK(b, -64) - __ASHL(__ASHR(b, 6), 6)), s);
	Files_Assert(x__len <= 8);
	__MOVE((ADDRESS)&q, (ADDRESS)x, x__len);
}

void Files_WriteBool (Files_Rider *R, ADDRESS *R__typ, BOOLEAN x)
{
	Files_Write(&*R, R__typ, __VAL(CHAR, x));
}

void Files_WriteInt (Files_Rider *R, ADDRESS *R__typ, INT16 x)
{
	CHAR b[2];
	b[0] = __CHR(x);
	b[1] = __CHR(__ASHR(x, 8));
	Files_WriteBytes(&*R, R__typ, (void*)b, 2, 2);
}

void Files_WriteLInt (Files_Rider *R, ADDRESS *R__typ, INT32 x)
{
	CHAR b[4];
	b[0] = __CHR(x);
	b[1] = __CHR(__ASHR(x, 8));
	b[2] = __CHR(__ASHR(x, 16));
	b[3] = __CHR(__ASHR(x, 24));
	Files_WriteBytes(&*R, R__typ, (void*)b, 4, 4);
}

void Files_WriteSet (Files_Rider *R, ADDRESS *R__typ, UINT32 x)
{
	CHAR b[4];
	INT32 i;
	i = (INT32)x;
	b[0] = __CHR(i);
	b[1] = __CHR(__ASHR(i, 8));
	b[2] = __CHR(__ASHR(i, 16));
	b[3] = __CHR(__ASHR(i, 24));
	Files_WriteBytes(&*R, R__typ, (void*)b, 4, 4);
}

void Files_WriteReal (Files_Rider *R, ADDRESS *R__typ, REAL x)
{
	CHAR b[4];
	Files_FlipBytes((void*)&x, 4, (void*)b, 4);
	Files_WriteBytes(&*R, R__typ, (void*)b, 4, 4);
}

void Files_WriteLReal (Files_Rider *R, ADDRESS *R__typ, LONGREAL x)
{
	CHAR b[8];
	Files_FlipBytes((void*)&x, 8, (void*)b, 8);
	Files_WriteBytes(&*R, R__typ, (void*)b, 8, 8);
}

void Files_WriteString (Files_Rider *R, ADDRESS *R__typ, CHAR *x, ADDRESS x__len)
{
	INT16 i;
	i = 0;
	while (x[__X(i, x__len)] != 0x00) {
		i += 1;
	}
	Files_WriteBytes(&*R, R__typ, (void*)x, x__len * 1, i + 1);
}

void Files_WriteNum (Files_Rider *R, ADDRESS *R__typ, INT64 x)
{
	while (x < -64 || x > 63) {
		Files_Write(&*R, R__typ, __CHR(__MASK(x, -128) + 128));
		x = __ASHR(x, 7);
	}
	Files_Write(&*R, R__typ, __CHR(__MASK(x, -128)));
}

void Files_GetName (Files_File f, CHAR *name, ADDRESS name__len)
{
	__COPY(f->workName, name, name__len);
}

static void Files_CloseOSFile (Files_File f)
{
	Files_File prev = NIL;
	INT16 error;
	if (Files_files == (void *) f) {
		Files_files = f->next;
	} else {
		prev = (Files_File)Files_files;
		while ((prev != NIL && prev->next != (void *) f)) {
			prev = (Files_File)prev->next;
		}
		if (prev->next != NIL) {
			prev->next = f->next;
		}
	}
	error = Platform_Close(f->fd);
	f->fd = -1;
	f->state = 1;
	Heap_FileCount -= 1;
}

static void Files_Finalize (SYSTEM_PTR o)
{
	Files_File f = NIL;
	INT32 res;
	f = (Files_File)(ADDRESS)o;
	if (f->fd >= 0) {
		Files_CloseOSFile(f);
		if (f->tempFile) {
			res = Platform_Unlink((void*)f->workName, 256);
		}
	}
}

void Files_SetSearchPath (CHAR *path, ADDRESS path__len)
{
	__DUP(path, path__len, CHAR);
	if (Strings_Length(path, path__len) != 0) {
		Files_SearchPath = __NEWARR(NIL, 1, 1, 1, 1, ((ADDRESS)((Strings_Length(path, path__len) + 1))));
		__COPY(path, Files_SearchPath->data, Files_SearchPath->len[0]);
	} else {
		Files_SearchPath = NIL;
	}
	__DEL(path);
}

static void EnumPtrs(void (*P)(void*))
{
	P(Files_SearchPath);
}

__TDESC(Files_FileDesc, 1, 4) = {__TDFLDS("FileDesc", 600), {552, 560, 568, 576, -40}};
__TDESC(Files_BufDesc, 1, 1) = {__TDFLDS("BufDesc", 4120), {0, -16}};
__TDESC(Files_Rider, 1, 1) = {__TDFLDS("Rider", 24), {8, -16}};

export void *Files__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Heap);
	__MODULE_IMPORT(Out);
	__MODULE_IMPORT(Platform);
	__MODULE_IMPORT(Strings);
	__REGMOD("Files", EnumPtrs);
	__INITYP(Files_FileDesc, Files_FileDesc, 0);
	__INITYP(Files_BufDesc, Files_BufDesc, 0);
	__INITYP(Files_Rider, Files_Rider, 0);
/* BEGIN */
	Files_tempno = -1;
	Heap_FileCount = 0;
	Files_HOME[0] = 0x00;
	Platform_GetEnv((CHAR*)"HOME", 5, (void*)Files_HOME, 1024);
	Files_MaxPathLength = Platform_MaxPathLength();
	Files_MaxNameLength = Platform_MaxNameLength();
	__ENDMOD;
}
