/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"

typedef
	struct Platform_FileIdentity {
		INT32 volume, index, mtime;
	} Platform_FileIdentity;

typedef
	void (*Platform_SignalHandler)(INT32);


export BOOLEAN Platform_LittleEndian;
export INT16 Platform_PID;
export CHAR Platform_CWD[256];
static INT32 Platform_TimeStart;
export INT16 Platform_SeekSet, Platform_SeekCur, Platform_SeekEnd;
export CHAR Platform_NL[3];

export ADDRESS *Platform_FileIdentity__typ;

export BOOLEAN Platform_Absent (INT16 e);
export INT16 Platform_Chdir (CHAR *n, ADDRESS n__len);
export INT16 Platform_Close (INT32 h);
export BOOLEAN Platform_ConnectionFailed (INT16 e);
export void Platform_Delay (INT32 ms);
export BOOLEAN Platform_DifferentFilesystems (INT16 e);
export INT16 Platform_Error (void);
export void Platform_Exit (INT32 code);
export void Platform_GetClock (INT32 *t, INT32 *d);
export void Platform_GetEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len);
export void Platform_GetTimeOfDay (INT32 *sec, INT32 *usec);
export INT16 Platform_Identify (INT32 h, Platform_FileIdentity *identity, ADDRESS *identity__typ);
export INT16 Platform_IdentifyByName (CHAR *n, ADDRESS n__len, Platform_FileIdentity *identity, ADDRESS *identity__typ);
export BOOLEAN Platform_Inaccessible (INT16 e);
export BOOLEAN Platform_Interrupted (INT16 e);
export BOOLEAN Platform_IsConsole (INT32 h);
export void Platform_MTimeAsClock (Platform_FileIdentity i, INT32 *t, INT32 *d);
export INT16 Platform_MaxNameLength (void);
export INT16 Platform_MaxPathLength (void);
export INT16 Platform_New (CHAR *n, ADDRESS n__len, INT32 *h);
export BOOLEAN Platform_NoSuchDirectory (INT16 e);
export INT64 Platform_OSAllocate (INT64 size);
export void Platform_OSFree (INT64 address);
export INT16 Platform_OldRO (CHAR *n, ADDRESS n__len, INT32 *h);
export INT16 Platform_OldRW (CHAR *n, ADDRESS n__len, INT32 *h);
export INT16 Platform_Read (INT32 h, INT64 p, INT32 l, INT32 *n);
export INT16 Platform_ReadBuf (INT32 h, SYSTEM_BYTE *b, ADDRESS b__len, INT32 *n);
export INT16 Platform_Rename (CHAR *o, ADDRESS o__len, CHAR *n, ADDRESS n__len);
export BOOLEAN Platform_SameFile (Platform_FileIdentity i1, Platform_FileIdentity i2);
export BOOLEAN Platform_SameFileTime (Platform_FileIdentity i1, Platform_FileIdentity i2);
export INT16 Platform_Seek (INT32 h, INT32 offset, INT16 whence);
export void Platform_SetBadInstructionHandler (Platform_SignalHandler handler);
export void Platform_SetInterruptHandler (Platform_SignalHandler handler);
export void Platform_SetMTime (Platform_FileIdentity *target, ADDRESS *target__typ, Platform_FileIdentity source);
export void Platform_SetQuitHandler (Platform_SignalHandler handler);
export INT16 Platform_Size (INT32 h, INT32 *l);
export INT16 Platform_Sync (INT32 h);
export INT16 Platform_System (CHAR *cmd, ADDRESS cmd__len);
static void Platform_TestLittleEndian (void);
export INT32 Platform_Time (void);
export BOOLEAN Platform_TimedOut (INT16 e);
export BOOLEAN Platform_TooManyFiles (INT16 e);
export INT16 Platform_Truncate (INT32 h, INT32 l);
export INT16 Platform_Unlink (CHAR *n, ADDRESS n__len);
export INT16 Platform_Write (INT32 h, INT64 p, INT32 l);
static void Platform_YMDHMStoClock (INT32 ye, INT32 mo, INT32 da, INT32 ho, INT32 mi, INT32 se, INT32 *t, INT32 *d);
export BOOLEAN Platform_getEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len);

#include <errno.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#define Platform_EACCES()	EACCES
#define Platform_EAGAIN()	EAGAIN
#define Platform_ECONNABORTED()	ECONNABORTED
#define Platform_ECONNREFUSED()	ECONNREFUSED
#define Platform_EHOSTUNREACH()	EHOSTUNREACH
#define Platform_EINTR()	EINTR
#define Platform_EMFILE()	EMFILE
#define Platform_ENETUNREACH()	ENETUNREACH
#define Platform_ENFILE()	ENFILE
#define Platform_ENOENT()	ENOENT
#define Platform_EROFS()	EROFS
#define Platform_ETIMEDOUT()	ETIMEDOUT
#define Platform_EXDEV()	EXDEV
#define Platform_NAMEMAX()	NAME_MAX
#define Platform_PATHMAX()	PATH_MAX
#define Platform_allocate(size)	(ADDRESS)((void*)malloc((size_t)size))
#define Platform_chdir(n, n__len)	chdir((char*)n)
#define Platform_closefile(fd)	close(fd)
#define Platform_err()	errno
#define Platform_exit(code)	exit((int)code)
#define Platform_free(address)	free((void*)address)
#define Platform_fstat(fd)	fstat(fd, &s)
#define Platform_fsync(fd)	fsync(fd)
#define Platform_ftruncate(fd, l)	ftruncate(fd, l)
#define Platform_getcwd(cwd, cwd__len)	getcwd((char*)cwd, cwd__len)
#define Platform_getenv(var, var__len)	getenv((char*)var)
#define Platform_getpid()	(INTEGER)getpid()
#define Platform_gettimeval()	struct timeval tv; gettimeofday(&tv,0)
#define Platform_isatty(fd)	isatty(fd)
#define Platform_lseek(fd, o, w)	lseek(fd, o, w)
#define Platform_nanosleep(s, ns)	struct timespec req, rem; req.tv_sec = s; req.tv_nsec = ns; nanosleep(&req, &rem)
#define Platform_opennew(n, n__len)	open((char*)n, O_CREAT | O_TRUNC | O_RDWR, 0664)
#define Platform_openro(n, n__len)	open((char*)n, O_RDONLY)
#define Platform_openrw(n, n__len)	open((char*)n, O_RDWR)
#define Platform_readfile(fd, p, l)	(LONGINT)read(fd, (void*)(ADDRESS)(p), l)
#define Platform_rename(o, o__len, n, n__len)	rename((char*)o, (char*)n)
#define Platform_sectotm(s)	struct tm *time = localtime((time_t*)&s)
#define Platform_seekcur()	SEEK_CUR
#define Platform_seekend()	SEEK_END
#define Platform_seekset()	SEEK_SET
#define Platform_sethandler(s, h)	SystemSetHandler(s, (ADDRESS)h)
#define Platform_stat(n, n__len)	stat((char*)n, &s)
#define Platform_statdev()	(LONGINT)s.st_dev
#define Platform_statino()	(LONGINT)s.st_ino
#define Platform_statmtime()	(LONGINT)s.st_mtime
#define Platform_statsize()	(ADDRESS)s.st_size
#define Platform_structstats()	struct stat s
#define Platform_system(str, str__len)	system((char*)str)
#define Platform_tmhour()	(LONGINT)time->tm_hour
#define Platform_tmmday()	(LONGINT)time->tm_mday
#define Platform_tmmin()	(LONGINT)time->tm_min
#define Platform_tmmon()	(LONGINT)time->tm_mon
#define Platform_tmsec()	(LONGINT)time->tm_sec
#define Platform_tmyear()	(LONGINT)time->tm_year
#define Platform_tvsec()	tv.tv_sec
#define Platform_tvusec()	tv.tv_usec
#define Platform_unlink(n, n__len)	unlink((char*)n)
#define Platform_writefile(fd, p, l)	write(fd, (void*)(ADDRESS)(p), l)

BOOLEAN Platform_TooManyFiles (INT16 e)
{
	return e == Platform_EMFILE() || e == Platform_ENFILE();
}

BOOLEAN Platform_NoSuchDirectory (INT16 e)
{
	return e == Platform_ENOENT();
}

BOOLEAN Platform_DifferentFilesystems (INT16 e)
{
	return e == Platform_EXDEV();
}

BOOLEAN Platform_Inaccessible (INT16 e)
{
	return (e == Platform_EACCES() || e == Platform_EROFS()) || e == Platform_EAGAIN();
}

BOOLEAN Platform_Absent (INT16 e)
{
	return e == Platform_ENOENT();
}

BOOLEAN Platform_TimedOut (INT16 e)
{
	return e == Platform_ETIMEDOUT();
}

BOOLEAN Platform_ConnectionFailed (INT16 e)
{
	return ((e == Platform_ECONNREFUSED() || e == Platform_ECONNABORTED()) || e == Platform_ENETUNREACH()) || e == Platform_EHOSTUNREACH();
}

BOOLEAN Platform_Interrupted (INT16 e)
{
	return e == Platform_EINTR();
}

INT16 Platform_MaxNameLength (void)
{
	return Platform_NAMEMAX();
}

INT16 Platform_MaxPathLength (void)
{
	return Platform_PATHMAX();
}

INT64 Platform_OSAllocate (INT64 size)
{
	return Platform_allocate(size);
}

void Platform_OSFree (INT64 address)
{
	Platform_free(address);
}

typedef
	CHAR (*EnvPtr__83)[1024];

BOOLEAN Platform_getEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len)
{
	EnvPtr__83 p = NIL;
	__DUP(var, var__len, CHAR);
	p = (EnvPtr__83)(ADDRESS)Platform_getenv(var, var__len);
	if (p != NIL) {
		__COPY(*p, val, val__len);
	}
	__DEL(var);
	return p != NIL;
}

void Platform_GetEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len)
{
	__DUP(var, var__len, CHAR);
	if (!Platform_getEnv(var, var__len, (void*)val, val__len)) {
		val[0] = 0x00;
	}
	__DEL(var);
}

void Platform_SetInterruptHandler (Platform_SignalHandler handler)
{
	Platform_sethandler(2, handler);
}

void Platform_SetQuitHandler (Platform_SignalHandler handler)
{
	Platform_sethandler(3, handler);
}

void Platform_SetBadInstructionHandler (Platform_SignalHandler handler)
{
	Platform_sethandler(4, handler);
}

static void Platform_YMDHMStoClock (INT32 ye, INT32 mo, INT32 da, INT32 ho, INT32 mi, INT32 se, INT32 *t, INT32 *d)
{
	*d = (__ASHL((int)__MOD(ye, 100), 9) + __ASHL(mo + 1, 5)) + da;
	*t = (__ASHL(ho, 12) + __ASHL(mi, 6)) + se;
}

void Platform_GetClock (INT32 *t, INT32 *d)
{
	Platform_gettimeval();
	Platform_sectotm(Platform_tvsec());
	Platform_YMDHMStoClock(Platform_tmyear(), Platform_tmmon(), Platform_tmmday(), Platform_tmhour(), Platform_tmmin(), Platform_tmsec(), &*t, &*d);
}

void Platform_GetTimeOfDay (INT32 *sec, INT32 *usec)
{
	Platform_gettimeval();
	*sec = Platform_tvsec();
	*usec = Platform_tvusec();
}

INT32 Platform_Time (void)
{
	INT32 ms;
	Platform_gettimeval();
	ms = (int)__DIVF(Platform_tvusec(), 1000) + Platform_tvsec() * 1000;
	return (int)__MOD(ms - Platform_TimeStart, 2147483647);
}

void Platform_Delay (INT32 ms)
{
	INT32 s, ns;
	s = __DIV(ms, 1000);
	ns = (int)__MOD(ms, 1000) * 1000000;
	Platform_nanosleep(s, ns);
}

INT16 Platform_System (CHAR *cmd, ADDRESS cmd__len)
{
	__DUP(cmd, cmd__len, CHAR);
	__DEL(cmd);
	return Platform_system(cmd, cmd__len);
}

INT16 Platform_Error (void)
{
	return Platform_err();
}

INT16 Platform_OldRO (CHAR *n, ADDRESS n__len, INT32 *h)
{
	INT16 fd;
	fd = Platform_openro(n, n__len);
	if (fd < 0) {
		return Platform_err();
	} else {
		*h = fd;
		return 0;
	}
	__RETCHK;
}

INT16 Platform_OldRW (CHAR *n, ADDRESS n__len, INT32 *h)
{
	INT16 fd;
	fd = Platform_openrw(n, n__len);
	if (fd < 0) {
		return Platform_err();
	} else {
		*h = fd;
		return 0;
	}
	__RETCHK;
}

INT16 Platform_New (CHAR *n, ADDRESS n__len, INT32 *h)
{
	INT16 fd;
	fd = Platform_opennew(n, n__len);
	if (fd < 0) {
		return Platform_err();
	} else {
		*h = fd;
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Close (INT32 h)
{
	if (Platform_closefile(h) < 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

BOOLEAN Platform_IsConsole (INT32 h)
{
	return Platform_isatty(h) != 0;
}

INT16 Platform_Identify (INT32 h, Platform_FileIdentity *identity, ADDRESS *identity__typ)
{
	Platform_structstats();
	if (Platform_fstat(h) < 0) {
		return Platform_err();
	}
	(*identity).volume = Platform_statdev();
	(*identity).index = Platform_statino();
	(*identity).mtime = Platform_statmtime();
	return 0;
}

INT16 Platform_IdentifyByName (CHAR *n, ADDRESS n__len, Platform_FileIdentity *identity, ADDRESS *identity__typ)
{
	__DUP(n, n__len, CHAR);
	Platform_structstats();
	if (Platform_stat(n, n__len) < 0) {
		__DEL(n);
		return Platform_err();
	}
	(*identity).volume = Platform_statdev();
	(*identity).index = Platform_statino();
	(*identity).mtime = Platform_statmtime();
	__DEL(n);
	return 0;
}

BOOLEAN Platform_SameFile (Platform_FileIdentity i1, Platform_FileIdentity i2)
{
	return (i1.index == i2.index && i1.volume == i2.volume);
}

BOOLEAN Platform_SameFileTime (Platform_FileIdentity i1, Platform_FileIdentity i2)
{
	return i1.mtime == i2.mtime;
}

void Platform_SetMTime (Platform_FileIdentity *target, ADDRESS *target__typ, Platform_FileIdentity source)
{
	(*target).mtime = source.mtime;
}

void Platform_MTimeAsClock (Platform_FileIdentity i, INT32 *t, INT32 *d)
{
	Platform_sectotm(i.mtime);
	Platform_YMDHMStoClock(Platform_tmyear(), Platform_tmmon(), Platform_tmmday(), Platform_tmhour(), Platform_tmmin(), Platform_tmsec(), &*t, &*d);
}

INT16 Platform_Size (INT32 h, INT32 *l)
{
	Platform_structstats();
	if (Platform_fstat(h) < 0) {
		return Platform_err();
	}
	*l = Platform_statsize();
	return 0;
}

INT16 Platform_Read (INT32 h, INT64 p, INT32 l, INT32 *n)
{
	*n = Platform_readfile(h, p, l);
	if (*n < 0) {
		*n = 0;
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_ReadBuf (INT32 h, SYSTEM_BYTE *b, ADDRESS b__len, INT32 *n)
{
	*n = Platform_readfile(h, (ADDRESS)b, b__len);
	if (*n < 0) {
		*n = 0;
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Write (INT32 h, INT64 p, INT32 l)
{
	INT64 written;
	written = Platform_writefile(h, p, l);
	if (written < 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Sync (INT32 h)
{
	if (Platform_fsync(h) < 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Seek (INT32 h, INT32 offset, INT16 whence)
{
	if (Platform_lseek(h, offset, whence) < 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Truncate (INT32 h, INT32 l)
{
	if (Platform_ftruncate(h, l) < 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Unlink (CHAR *n, ADDRESS n__len)
{
	if (Platform_unlink(n, n__len) < 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Chdir (CHAR *n, ADDRESS n__len)
{
	INT16 r;
	if ((Platform_chdir(n, n__len) >= 0 && Platform_getcwd((void*)Platform_CWD, 256) != NIL)) {
		return 0;
	} else {
		return Platform_err();
	}
	__RETCHK;
}

INT16 Platform_Rename (CHAR *o, ADDRESS o__len, CHAR *n, ADDRESS n__len)
{
	if (Platform_rename(o, o__len, n, n__len) < 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

void Platform_Exit (INT32 code)
{
	Platform_exit(code);
}

static void Platform_TestLittleEndian (void)
{
	INT16 i;
	i = 1;
	__GET((ADDRESS)&i, Platform_LittleEndian, BOOLEAN);
}

__TDESC(Platform_FileIdentity, 1, 0) = {__TDFLDS("FileIdentity", 12), {-8}};

export void *Platform__init(void)
{
	__DEFMOD;
	__REGMOD("Platform", 0);
	__INITYP(Platform_FileIdentity, Platform_FileIdentity, 0);
/* BEGIN */
	Platform_TestLittleEndian();
	Platform_TimeStart = 0;
	Platform_TimeStart = Platform_Time();
	Platform_PID = Platform_getpid();
	if (Platform_getcwd((void*)Platform_CWD, 256) == NIL) {
		Platform_CWD[0] = 0x00;
	}
	Platform_SeekSet = Platform_seekset();
	Platform_SeekCur = Platform_seekcur();
	Platform_SeekEnd = Platform_seekend();
	Platform_NL[0] = 0x0a;
	Platform_NL[1] = 0x00;
	__ENDMOD;
}
