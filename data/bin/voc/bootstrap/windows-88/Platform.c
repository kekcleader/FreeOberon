/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"

typedef
	struct Platform_FileIdentity {
		INT32 volume, indexhigh, indexlow, mtimehigh, mtimelow;
	} Platform_FileIdentity;

typedef
	void (*Platform_SignalHandler)(INT32);


export BOOLEAN Platform_LittleEndian;
export INT16 Platform_PID;
export CHAR Platform_CWD[4096];
static INT32 Platform_TimeStart;
export INT16 Platform_SeekSet, Platform_SeekCur, Platform_SeekEnd;
export INT64 Platform_StdIn, Platform_StdOut, Platform_StdErr;
export CHAR Platform_NL[3];

export ADDRESS *Platform_FileIdentity__typ;

export BOOLEAN Platform_Absent (INT16 e);
export INT16 Platform_Chdir (CHAR *n, ADDRESS n__len);
export INT16 Platform_Close (INT64 h);
export BOOLEAN Platform_ConnectionFailed (INT16 e);
export void Platform_Delay (INT32 ms);
export BOOLEAN Platform_DifferentFilesystems (INT16 e);
static void Platform_EnableVT100 (void);
export INT16 Platform_Error (void);
export void Platform_Exit (INT32 code);
export void Platform_GetClock (INT32 *t, INT32 *d);
export void Platform_GetEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len);
export void Platform_GetTimeOfDay (INT32 *sec, INT32 *usec);
export INT16 Platform_Identify (INT64 h, Platform_FileIdentity *identity, ADDRESS *identity__typ);
export INT16 Platform_IdentifyByName (CHAR *n, ADDRESS n__len, Platform_FileIdentity *identity, ADDRESS *identity__typ);
export BOOLEAN Platform_Inaccessible (INT16 e);
export BOOLEAN Platform_Interrupted (INT16 e);
export BOOLEAN Platform_IsConsole (INT64 h);
export void Platform_MTimeAsClock (Platform_FileIdentity i, INT32 *t, INT32 *d);
export INT16 Platform_MaxNameLength (void);
export INT16 Platform_MaxPathLength (void);
export INT16 Platform_New (CHAR *n, ADDRESS n__len, INT64 *h);
export BOOLEAN Platform_NoSuchDirectory (INT16 e);
export INT64 Platform_OSAllocate (INT64 size);
export void Platform_OSFree (INT64 address);
export INT16 Platform_OldRO (CHAR *n, ADDRESS n__len, INT64 *h);
export INT16 Platform_OldRW (CHAR *n, ADDRESS n__len, INT64 *h);
export INT16 Platform_Read (INT64 h, INT64 p, INT32 l, INT32 *n);
export INT16 Platform_ReadBuf (INT64 h, SYSTEM_BYTE *b, ADDRESS b__len, INT32 *n);
export INT16 Platform_Rename (CHAR *o, ADDRESS o__len, CHAR *n, ADDRESS n__len);
export BOOLEAN Platform_SameFile (Platform_FileIdentity i1, Platform_FileIdentity i2);
export BOOLEAN Platform_SameFileTime (Platform_FileIdentity i1, Platform_FileIdentity i2);
export INT16 Platform_Seek (INT64 h, INT32 o, INT16 r);
export void Platform_SetBadInstructionHandler (Platform_SignalHandler handler);
export void Platform_SetMTime (Platform_FileIdentity *target, ADDRESS *target__typ, Platform_FileIdentity source);
export INT16 Platform_Size (INT64 h, INT32 *l);
export INT16 Platform_Sync (INT64 h);
export INT16 Platform_System (CHAR *cmd, ADDRESS cmd__len);
static void Platform_TestLittleEndian (void);
export INT32 Platform_Time (void);
export BOOLEAN Platform_TimedOut (INT16 e);
export BOOLEAN Platform_TooManyFiles (INT16 e);
export INT16 Platform_Truncate (INT64 h, INT32 limit);
export INT16 Platform_Unlink (CHAR *n, ADDRESS n__len);
export INT16 Platform_Write (INT64 h, INT64 p, INT32 l);
static void Platform_YMDHMStoClock (INT16 ye, INT16 mo, INT16 da, INT16 ho, INT16 mi, INT16 se, INT32 *t, INT32 *d);
export BOOLEAN Platform_getEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len);

#include "WindowsWrapper.h"
#define Platform_ECONNABORTED()	WSAECONNABORTED
#define Platform_ECONNREFUSED()	WSAECONNREFUSED
#define Platform_EHOSTUNREACH()	WSAEHOSTUNREACH
#define Platform_EINTR()	WSAEINTR
#define Platform_ENETUNREACH()	WSAENETUNREACH
#define Platform_ERRORACCESSDENIED()	ERROR_ACCESS_DENIED
#define Platform_ERRORFILENOTFOUND()	ERROR_FILE_NOT_FOUND
#define Platform_ERRORNOTREADY()	ERROR_NOT_READY
#define Platform_ERRORNOTSAMEDEVICE()	ERROR_NOT_SAME_DEVICE
#define Platform_ERRORPATHNOTFOUND()	ERROR_PATH_NOT_FOUND
#define Platform_ERRORSHARINGVIOLATION()	ERROR_SHARING_VIOLATION
#define Platform_ERRORTOOMANYOPENFILES()	ERROR_TOO_MANY_OPEN_FILES
#define Platform_ERRORWRITEPROTECT()	ERROR_WRITE_PROTECT
#define Platform_ETIMEDOUT()	WSAETIMEDOUT
#define Platform_GetConsoleMode(h, m)	GetConsoleMode((HANDLE)h, (DWORD*)m)
#define Platform_GetTickCount()	(LONGINT)(UINT32)GetTickCount()
#define Platform_MAXPATH()	MAX_PATH
#define Platform_SetConsoleMode(h, m)	SetConsoleMode((HANDLE)h, (DWORD)m)
#define Platform_SetInterruptHandler(h)	SystemSetInterruptHandler((ADDRESS)h)
#define Platform_SetQuitHandler(h)	SystemSetQuitHandler((ADDRESS)h)
#define Platform_allocate(size)	(ADDRESS)((void*)HeapAlloc(GetProcessHeap(), 0, (size_t)size))
#define Platform_bhfiIndexHigh()	(LONGINT)bhfi.nFileIndexHigh
#define Platform_bhfiIndexLow()	(LONGINT)bhfi.nFileIndexLow
#define Platform_bhfiMtimeHigh()	(LONGINT)bhfi.ftLastWriteTime.dwHighDateTime
#define Platform_bhfiMtimeLow()	(LONGINT)bhfi.ftLastWriteTime.dwLowDateTime
#define Platform_bhfiVsn()	(LONGINT)bhfi.dwVolumeSerialNumber
#define Platform_byHandleFileInformation()	BY_HANDLE_FILE_INFORMATION bhfi
#define Platform_cleanupProcess()	CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
#define Platform_closeHandle(h)	(INTEGER)CloseHandle((HANDLE)h)
#define Platform_createProcess(str, str__len)	(INTEGER)CreateProcess(0, (char*)str, 0,0,0,0,0,0,&si,&pi)
#define Platform_deleteFile(n, n__len)	(INTEGER)DeleteFile((char*)n)
#define Platform_err()	(INTEGER)GetLastError()
#define Platform_exit(code)	ExitProcess((UINT)code)
#define Platform_fileTimeToSysTime()	SYSTEMTIME st; FileTimeToSystemTime(&ft, &st)
#define Platform_flushFileBuffers(h)	(INTEGER)FlushFileBuffers((HANDLE)h)
#define Platform_free(address)	HeapFree(GetProcessHeap(), 0, (void*)address)
#define Platform_ftToUli()	ULARGE_INTEGER ul; ul.LowPart=ft.dwLowDateTime; ul.HighPart=ft.dwHighDateTime
#define Platform_getCurrentDirectory(n, n__len)	GetCurrentDirectory(n__len, (char*)n)
#define Platform_getExitCodeProcess(exitcode)	GetExitCodeProcess(pi.hProcess, (DWORD*)exitcode);
#define Platform_getFileInformationByHandle(h)	(INTEGER)GetFileInformationByHandle((HANDLE)h, &bhfi)
#define Platform_getFilePos(h, r, rc)	LARGE_INTEGER liz = {0}; *rc = (INTEGER)SetFilePointerEx((HANDLE)h, liz, &li, FILE_CURRENT); *r = (LONGINT)li.QuadPart
#define Platform_getFileSize(h)	(INTEGER)GetFileSizeEx((HANDLE)h, &li)
#define Platform_getLocalTime()	SYSTEMTIME st; GetLocalTime(&st)
#define Platform_getenv(name, name__len, buf, buf__len)	(INTEGER)GetEnvironmentVariable((char*)name, (char*)buf, buf__len)
#define Platform_getpid()	(INTEGER)GetCurrentProcessId()
#define Platform_getstderrhandle()	(ADDRESS)GetStdHandle(STD_ERROR_HANDLE)
#define Platform_getstdinhandle()	(ADDRESS)GetStdHandle(STD_INPUT_HANDLE)
#define Platform_getstdouthandle()	(ADDRESS)GetStdHandle(STD_OUTPUT_HANDLE)
#define Platform_identityToFileTime(i)	FILETIME ft; ft.dwHighDateTime = i.mtimehigh; ft.dwLowDateTime = i.mtimelow
#define Platform_invalidHandleValue()	((ADDRESS)INVALID_HANDLE_VALUE)
#define Platform_largeInteger()	LARGE_INTEGER li
#define Platform_liLongint()	(LONGINT)li.QuadPart
#define Platform_moveFile(o, o__len, n, n__len)	(INTEGER)MoveFileEx((char*)o, (char*)n, MOVEFILE_REPLACE_EXISTING)
#define Platform_opennew(n, n__len)	(ADDRESS)CreateFile((char*)n, GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_SHARE_DELETE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
#define Platform_openro(n, n__len)	(ADDRESS)CreateFile((char*)n, GENERIC_READ              , FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
#define Platform_openrw(n, n__len)	(ADDRESS)CreateFile((char*)n, GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
#define Platform_processInfo()	PROCESS_INFORMATION pi = {0};
#define Platform_readfile(fd, p, l, n)	(INTEGER)ReadFile((HANDLE)fd, (void*)p, (DWORD)l, (DWORD*)n, 0)
#define Platform_seekcur()	FILE_CURRENT
#define Platform_seekend()	FILE_END
#define Platform_seekset()	FILE_BEGIN
#define Platform_setCurrentDirectory(n, n__len)	(INTEGER)SetCurrentDirectory((char*)n)
#define Platform_setEndOfFile(h)	(INTEGER)SetEndOfFile((HANDLE)h)
#define Platform_setFilePointerEx(h, o, r, rc)	li.QuadPart=o; *rc = (INTEGER)SetFilePointerEx((HANDLE)h, li, 0, (DWORD)r)
#define Platform_sleep(ms)	Sleep((DWORD)ms)
#define Platform_stToFt()	FILETIME ft; SystemTimeToFileTime(&st, &ft)
#define Platform_startupInfo()	STARTUPINFO si = {0}; si.cb = sizeof(si);
#define Platform_sthour()	(INTEGER)st.wHour
#define Platform_stmday()	(INTEGER)st.wDay
#define Platform_stmin()	(INTEGER)st.wMinute
#define Platform_stmon()	(INTEGER)st.wMonth
#define Platform_stmsec()	(INTEGER)st.wMilliseconds
#define Platform_stsec()	(INTEGER)st.wSecond
#define Platform_styear()	(INTEGER)st.wYear
#define Platform_tous1970()	ul.QuadPart = (ul.QuadPart - 116444736000000000ULL)/10LL
#define Platform_ulSec()	(LONGINT)(ul.QuadPart / 1000000LL)
#define Platform_uluSec()	(LONGINT)(ul.QuadPart % 1000000LL)
#define Platform_waitForProcess()	(INTEGER)WaitForSingleObject(pi.hProcess, INFINITE)
#define Platform_writefile(fd, p, l, n)	(INTEGER)WriteFile((HANDLE)fd, (void*)(p), (DWORD)l, (DWORD*)n, 0)

BOOLEAN Platform_TooManyFiles (INT16 e)
{
	return e == Platform_ERRORTOOMANYOPENFILES();
}

BOOLEAN Platform_NoSuchDirectory (INT16 e)
{
	return e == Platform_ERRORPATHNOTFOUND();
}

BOOLEAN Platform_DifferentFilesystems (INT16 e)
{
	return e == Platform_ERRORNOTSAMEDEVICE();
}

BOOLEAN Platform_Inaccessible (INT16 e)
{
	return ((e == Platform_ERRORACCESSDENIED() || e == Platform_ERRORWRITEPROTECT()) || e == Platform_ERRORNOTREADY()) || e == Platform_ERRORSHARINGVIOLATION();
}

BOOLEAN Platform_Absent (INT16 e)
{
	return e == Platform_ERRORFILENOTFOUND() || e == Platform_ERRORPATHNOTFOUND();
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
	return Platform_MAXPATH();
}

INT16 Platform_MaxPathLength (void)
{
	return Platform_MAXPATH();
}

INT64 Platform_OSAllocate (INT64 size)
{
	return Platform_allocate(size);
}

void Platform_OSFree (INT64 address)
{
	Platform_free(address);
}

BOOLEAN Platform_getEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len)
{
	CHAR buf[4096];
	INT16 res;
	__DUP(var, var__len, CHAR);
	res = Platform_getenv(var, var__len, (void*)buf, 4096);
	if ((res > 0 && res < 4096)) {
		__COPY(buf, val, val__len);
		__DEL(var);
		return 1;
	} else {
		__DEL(var);
		return 0;
	}
	__RETCHK;
}

void Platform_GetEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len)
{
	__DUP(var, var__len, CHAR);
	if (!Platform_getEnv(var, var__len, (void*)val, val__len)) {
		val[0] = 0x00;
	}
	__DEL(var);
}

void Platform_SetBadInstructionHandler (Platform_SignalHandler handler)
{
}

static void Platform_YMDHMStoClock (INT16 ye, INT16 mo, INT16 da, INT16 ho, INT16 mi, INT16 se, INT32 *t, INT32 *d)
{
	*d = (__ASHL((int)__MOD(ye, 100), 9) + __ASHL((mo + 1), 5)) + da;
	*t = (__ASHL(ho, 12) + __ASHL(mi, 6)) + se;
}

void Platform_GetClock (INT32 *t, INT32 *d)
{
	Platform_getLocalTime();
	Platform_YMDHMStoClock(Platform_styear(), Platform_stmon(), Platform_stmday(), Platform_sthour(), Platform_stmin(), Platform_stsec(), &*t, &*d);
}

INT32 Platform_Time (void)
{
	INT32 ms;
	ms = Platform_GetTickCount();
	return (int)__MOD(ms - Platform_TimeStart, 2147483647);
}

void Platform_Delay (INT32 ms)
{
	while (ms > 30000) {
		Platform_sleep(30000);
		ms = ms - 30000;
	}
	if (ms > 0) {
		Platform_sleep(ms);
	}
}

void Platform_GetTimeOfDay (INT32 *sec, INT32 *usec)
{
	Platform_getLocalTime();
	Platform_stToFt();
	Platform_ftToUli();
	Platform_tous1970();
	*sec = Platform_ulSec();
	*usec = Platform_uluSec();
}

INT16 Platform_System (CHAR *cmd, ADDRESS cmd__len)
{
	INT16 result;
	__DUP(cmd, cmd__len, CHAR);
	result = 127;
	Platform_startupInfo();
	Platform_processInfo();
	if (Platform_createProcess(cmd, cmd__len) != 0) {
		if (Platform_waitForProcess() == 0) {
			Platform_getExitCodeProcess(&result);
		}
		Platform_cleanupProcess();
	}
	__DEL(cmd);
	return __ASHL(result, 8);
}

INT16 Platform_Error (void)
{
	return Platform_err();
}

INT16 Platform_OldRO (CHAR *n, ADDRESS n__len, INT64 *h)
{
	INT64 fd;
	fd = Platform_openro(n, n__len);
	if (fd == Platform_invalidHandleValue()) {
		return Platform_err();
	} else {
		*h = fd;
		return 0;
	}
	__RETCHK;
}

INT16 Platform_OldRW (CHAR *n, ADDRESS n__len, INT64 *h)
{
	INT64 fd;
	fd = Platform_openrw(n, n__len);
	if (fd == Platform_invalidHandleValue()) {
		return Platform_err();
	} else {
		*h = fd;
		return 0;
	}
	__RETCHK;
}

INT16 Platform_New (CHAR *n, ADDRESS n__len, INT64 *h)
{
	INT64 fd;
	fd = Platform_opennew(n, n__len);
	if (fd == Platform_invalidHandleValue()) {
		return Platform_err();
	} else {
		*h = fd;
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Close (INT64 h)
{
	if (Platform_closeHandle(h) == 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Identify (INT64 h, Platform_FileIdentity *identity, ADDRESS *identity__typ)
{
	Platform_byHandleFileInformation();
	if (Platform_getFileInformationByHandle(h) == 0) {
		return Platform_err();
	}
	(*identity).volume = Platform_bhfiVsn();
	(*identity).indexhigh = Platform_bhfiIndexHigh();
	(*identity).indexlow = Platform_bhfiIndexLow();
	(*identity).mtimehigh = Platform_bhfiMtimeHigh();
	(*identity).mtimelow = Platform_bhfiMtimeLow();
	return 0;
}

INT16 Platform_IdentifyByName (CHAR *n, ADDRESS n__len, Platform_FileIdentity *identity, ADDRESS *identity__typ)
{
	INT64 h;
	INT16 e, i;
	__DUP(n, n__len, CHAR);
	e = Platform_OldRO((void*)n, n__len, &h);
	if (e != 0) {
		__DEL(n);
		return e;
	}
	e = Platform_Identify(h, &*identity, identity__typ);
	i = Platform_Close(h);
	__DEL(n);
	return e;
}

BOOLEAN Platform_SameFile (Platform_FileIdentity i1, Platform_FileIdentity i2)
{
	return (((i1.indexhigh == i2.indexhigh && i1.indexlow == i2.indexlow)) && i1.volume == i2.volume);
}

BOOLEAN Platform_SameFileTime (Platform_FileIdentity i1, Platform_FileIdentity i2)
{
	return (i1.mtimehigh == i2.mtimehigh && i1.mtimelow == i2.mtimelow);
}

void Platform_SetMTime (Platform_FileIdentity *target, ADDRESS *target__typ, Platform_FileIdentity source)
{
	(*target).mtimehigh = source.mtimehigh;
	(*target).mtimelow = source.mtimelow;
}

void Platform_MTimeAsClock (Platform_FileIdentity i, INT32 *t, INT32 *d)
{
	Platform_identityToFileTime(i);
	Platform_fileTimeToSysTime();
	Platform_YMDHMStoClock(Platform_styear(), Platform_stmon(), Platform_stmday(), Platform_sthour(), Platform_stmin(), Platform_stsec(), &*t, &*d);
}

INT16 Platform_Size (INT64 h, INT32 *l)
{
	Platform_largeInteger();
	if (Platform_getFileSize(h) == 0) {
		return Platform_err();
	}
	*l = Platform_liLongint();
	return 0;
}

INT16 Platform_Read (INT64 h, INT64 p, INT32 l, INT32 *n)
{
	INT16 result;
	INT32 lengthread;
	result = Platform_readfile(h, p, l, &lengthread);
	if (result == 0) {
		*n = 0;
		return Platform_err();
	} else {
		*n = lengthread;
		return 0;
	}
	__RETCHK;
}

INT16 Platform_ReadBuf (INT64 h, SYSTEM_BYTE *b, ADDRESS b__len, INT32 *n)
{
	INT16 result;
	INT32 lengthread;
	result = Platform_readfile(h, (ADDRESS)b, b__len, &lengthread);
	if (result == 0) {
		*n = 0;
		return Platform_err();
	} else {
		*n = lengthread;
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Write (INT64 h, INT64 p, INT32 l)
{
	INT32 n;
	if (Platform_writefile(h, p, l, &n) == 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Sync (INT64 h)
{
	if (Platform_flushFileBuffers(h) == 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Seek (INT64 h, INT32 o, INT16 r)
{
	INT16 rc;
	Platform_largeInteger();
	Platform_setFilePointerEx(h, o, r, &rc);
	if (rc == 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Truncate (INT64 h, INT32 limit)
{
	INT16 rc;
	INT32 oldpos;
	Platform_largeInteger();
	Platform_getFilePos(h, &oldpos, &rc);
	if (rc == 0) {
		return Platform_err();
	}
	Platform_setFilePointerEx(h, limit, Platform_seekset(), &rc);
	if (rc == 0) {
		return Platform_err();
	}
	if (Platform_setEndOfFile(h) == 0) {
		return Platform_err();
	}
	Platform_setFilePointerEx(h, oldpos, Platform_seekset(), &rc);
	if (rc == 0) {
		return Platform_err();
	}
	return 0;
}

INT16 Platform_Unlink (CHAR *n, ADDRESS n__len)
{
	if (Platform_deleteFile(n, n__len) == 0) {
		return Platform_err();
	} else {
		return 0;
	}
	__RETCHK;
}

INT16 Platform_Chdir (CHAR *n, ADDRESS n__len)
{
	INT16 r;
	r = Platform_setCurrentDirectory(n, n__len);
	if (r == 0) {
		return Platform_err();
	}
	Platform_getCurrentDirectory((void*)Platform_CWD, 4096);
	return 0;
}

INT16 Platform_Rename (CHAR *o, ADDRESS o__len, CHAR *n, ADDRESS n__len)
{
	if (Platform_moveFile(o, o__len, n, n__len) == 0) {
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

static void Platform_EnableVT100 (void)
{
	INT32 mode;
	if (Platform_GetConsoleMode(Platform_StdOut, &mode)) {
		Platform_SetConsoleMode(Platform_StdOut, mode + 4);
	}
}

BOOLEAN Platform_IsConsole (INT64 h)
{
	INT32 mode;
	return Platform_GetConsoleMode(Platform_StdOut, &mode);
}

static void Platform_TestLittleEndian (void)
{
	INT16 i;
	i = 1;
	__GET((ADDRESS)&i, Platform_LittleEndian, BOOLEAN);
}

__TDESC(Platform_FileIdentity, 1, 0) = {__TDFLDS("FileIdentity", 20), {-8}};

export void *Platform__init(void)
{
	__DEFMOD;
	__REGMOD("Platform", 0);
	__INITYP(Platform_FileIdentity, Platform_FileIdentity, 0);
/* BEGIN */
	Platform_TestLittleEndian();
	Platform_TimeStart = 0;
	Platform_TimeStart = Platform_Time();
	Platform_CWD[0] = 0x00;
	Platform_getCurrentDirectory((void*)Platform_CWD, 4096);
	Platform_PID = Platform_getpid();
	Platform_SeekSet = Platform_seekset();
	Platform_SeekCur = Platform_seekcur();
	Platform_SeekEnd = Platform_seekend();
	Platform_StdIn = Platform_getstdinhandle();
	Platform_StdOut = Platform_getstdouthandle();
	Platform_StdErr = Platform_getstderrhandle();
	Platform_EnableVT100();
	Platform_NL[0] = 0x0d;
	Platform_NL[1] = 0x0a;
	Platform_NL[2] = 0x00;
	__ENDMOD;
}
