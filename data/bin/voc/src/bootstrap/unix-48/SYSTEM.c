/*
*   The body prefix file of the voc(jet backend) runtime system, Version 1.0
*
*   Copyright (c) Software Templ, 1994, 1995
*
*   Module SYSTEM is subject to change any time without prior notification.
*   Software Templ disclaims all warranties with regard to module SYSTEM,
*   in particular shall Software Templ not be liable for any damage resulting
*   from inappropriate use or modification of module SYSTEM.
*
*   Version 1.1  jt, 24.11.95  fixes for correct pointer arithmetic on Cray computers
*   jt 31.1.2007  ANSI prototypes for malloc and exit in order to avoid cc warnings
*
*/

#include "SYSTEM.h"
#include "stdarg.h"
#include <signal.h>


// Procedure verions of SYSTEM.H versions used when a multiply accessed
// parameter has side effects.




INT64 SYSTEM_DIV(INT64 x, INT64 y)
{
  if (x == 0) return 0;
  if (x >= 0)
    if (y >= 0) {return x/y;}
    else        {return -((x-y-1)/(-y));}
  else
    if (y >= 0) {return -((y-x-1)/y);}
    else        {return (-x)/(-y);}
}

INT64 SYSTEM_MOD(INT64 x, INT64 y)
{
  if (x == 0) return 0;
  if (x >= 0)
    if (y >= 0) {return x % y;}
    else        {return (y+1) + ((x-1) % (-y));}
  else
    if (y >= 0) {return (y-1) - ((-x-1) % y);}
    else        {return -((-x) % (-y));}
}

INT64 SYSTEM_ENTIER(double x)
{
    INT64 y;
    if (x >= 0)
        return (INT64)x;
    else {
        y = (INT64)x;
        if (y <= x) return y; else return y - 1;
    }
}



void SYSTEM_INHERIT(ADDRESS *t, ADDRESS *t0)
{
    t -= __TPROC0OFF;
    t0 -= __TPROC0OFF;
    while (*t0 != __EOM) {*t = *t0; t--; t0--;}
}


void SYSTEM_ENUMP(void *adr, ADDRESS n, void (*P)())
{
    while (n > 0) {
        P((ADDRESS)(*((void**)(adr))));
        adr = ((void**)adr) + 1;
        n--;
    }
}

void SYSTEM_ENUMR(void *adr, ADDRESS *typ, ADDRESS size, ADDRESS n, void (*P)())
{
    ADDRESS *t, off;
    typ++;
    while (n > 0) {
        t = typ;
        off = *t;
        while (off >= 0) {P(*(ADDRESS*)((char*)adr+off)); t++; off = *t;}
        adr = ((char*)adr) + size;
        n--;
    }
}

extern void Heap_Lock();
extern void Heap_Unlock();

SYSTEM_PTR SYSTEM_NEWARR(ADDRESS *typ, ADDRESS elemsz, int elemalgn, int nofdim, int nofdyn, ...)
{
    ADDRESS nofelems, size, dataoff, n, nptr, *x, *p, nofptrs, i, *ptab, off;
    va_list ap;
    va_start(ap, nofdyn);
    nofelems = 1;
    while (nofdim > 0) {
        nofelems = nofelems * va_arg(ap, ADDRESS); nofdim--;
        if (nofelems <= 0) __HALT(-20);
    }
    va_end(ap);
    dataoff = nofdyn * sizeof(ADDRESS);
    if (elemalgn > sizeof(ADDRESS)) {
        n = dataoff % elemalgn;
        if (n != 0) dataoff += elemalgn - n;
    }
    size = dataoff + nofelems * elemsz;
    Heap_Lock();
    if (typ == NIL) {
        /* element typ does not contain pointers */
        x = Heap_NEWBLK(size);
    }
    else if (typ == (ADDRESS*)POINTER__typ) {
        /* element type is a pointer */
        x = Heap_NEWBLK(size + nofelems * sizeof(ADDRESS));
        p = (ADDRESS*)(ADDRESS)x[-1];
        p[-nofelems] = *p;  /* build new type desc in situ: 1. copy block size; 2. setup ptr tab; 3. set sentinel; 4. patch tag */
        p -= nofelems - 1; n = 1;   /* n =1 for skipping the size field */
        while (n <= nofelems) {*p = n*sizeof(ADDRESS); p++; n++;}
        *p = - (nofelems + 1) * sizeof(ADDRESS);    /* sentinel */
        x[-1] -= nofelems * sizeof(ADDRESS);
    }
    else {
        /* element type is a record that contains pointers */
        ptab = typ + 1; nofptrs = 0;
        while (ptab[nofptrs] >= 0) {nofptrs++;} /* number of pointers per element */
        nptr = nofelems * nofptrs;  /* total number of pointers */
        x = Heap_NEWBLK(size + nptr * sizeof(ADDRESS));
        p = (ADDRESS*)(ADDRESS)x[- 1];
        p[-nptr] = *p;  /* build new type desc in situ; 1. copy block size; 2. setup ptr tab; 3. set sentinel; 4. patch tag */
        p -= nptr - 1; n = 0; off = dataoff;
        while (n < nofelems) {i = 0;
            while (i < nofptrs) {*p = off + ptab[i]; p++; i++;}
            off += elemsz; n++;
        }
        *p = - (nptr + 1) * sizeof(ADDRESS);    /* sentinel */
        x[-1] -= nptr * sizeof(ADDRESS);
    }
    if (nofdyn != 0) {
        /* setup len vector for index checks */
        va_start(ap, nofdyn);
        p = x;
        while (nofdyn > 0) {*p = va_arg(ap, ADDRESS); p++, nofdyn--;}
        va_end(ap);
    }
    Heap_Unlock();
    return x;
}




typedef void (*SystemSignalHandler)(INT32); // = Platform_SignalHandler

#ifndef _WIN32

    SystemSignalHandler handler[3] = {0};

    // Provide signal handling for Unix based systems
    void signalHandler(int s) {
        if (s >= 2  &&  s <= 4) handler[s-2](s);
        // (Ignore other signals)
    }

    void SystemSetHandler(int s, ADDRESS h) {
        if (s >= 2 && s <= 4) {
            int needtosetsystemhandler = handler[s-2] == 0;
            handler[s-2] = (SystemSignalHandler)h;
            if (needtosetsystemhandler) {signal(s, signalHandler);}
        }
    }

#else

    // Provides Windows callback handlers for signal-like scenarios
    #include "WindowsWrapper.h"

    SystemSignalHandler SystemInterruptHandler = 0;
    SystemSignalHandler SystemQuitHandler      = 0;
    BOOL ConsoleCtrlHandlerSet = FALSE;

    BOOL WINAPI SystemConsoleCtrlHandler(DWORD ctrlType) {
        if ((ctrlType == CTRL_C_EVENT) || (ctrlType == CTRL_BREAK_EVENT)) {
            if (SystemInterruptHandler) {
                SystemInterruptHandler(2); // SIGINT
                return TRUE;
            }
        } else { // Close, logoff or shutdown
            if (SystemQuitHandler) {
                SystemQuitHandler(3); // SIGQUIT
                return TRUE;
            }
        }
        return FALSE;
    }

    void EnsureConsoleCtrlHandler() {
        if (!ConsoleCtrlHandlerSet) {
        SetConsoleCtrlHandler(SystemConsoleCtrlHandler, TRUE);
            ConsoleCtrlHandlerSet = TRUE;
        }
    }

    void SystemSetInterruptHandler(ADDRESS h) {
        EnsureConsoleCtrlHandler();
        SystemInterruptHandler = (SystemSignalHandler)h;
    }

    void SystemSetQuitHandler(ADDRESS h) {
        EnsureConsoleCtrlHandler();
        SystemQuitHandler = (SystemSignalHandler)h;
    }

#endif
