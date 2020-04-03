MODULE Pthread;
(* Copyright 2019-2020 Arthur Yefimov

This file is part of Free Oberon.

Free Oberon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Free Oberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*)
IMPORT SYSTEM;

(* PROCEDURE Pr(a: Pthread.Args): Pthread.ReturnValue;
BEGIN
RETURN NIL END Pr;
IF Pthread.Create(th, NIL, Pr, NIL) # 0 THEN END
*)

CONST
  sizeOfPthread = 8;
  sizeOfMutex = 40;
  sizeOfCond = 48;

TYPE
  Args* = SYSTEM.PTR;
  Attr* = SYSTEM.PTR;
  MutexAttr* = SYSTEM.PTR;
  CondAttr* = SYSTEM.PTR;
  ReturnValue* = SYSTEM.PTR;
  Thread* = RECORD
    padding: ARRAY sizeOfPthread OF CHAR
  END;
  Routine* = PROCEDURE(args: Args): SYSTEM.PTR;

  Mutex* = RECORD
    padding: ARRAY sizeOfMutex OF CHAR
  END;

  Cond* = RECORD
    padding: ARRAY sizeOfCond OF CHAR
  END;

PROCEDURE -AAIncludePthreadh0* '#include "Pthread.h0"';

(* Threads *)

PROCEDURE -Create*(VAR t: Thread; attr: Attr;
  routine: Routine; args: Args): INTEGER
  "pthread_create((pthread_t *)t, attr, routine, args)";

PROCEDURE -Join*(t: Thread)
  "pthread_join((pthread_t *)t: Thread; VAR status: SYSTEM.ADDRESS)";

PROCEDURE -Detatch*(t: Thread)
  "pthread_detatch((pthread_t *)t)";

PROCEDURE -Exit*(t: Thread)
  "pthread_detatch((pthread_t *)t)";

PROCEDURE -Cancel*(t: Thread)
  "pthread_cancel((pthread_t *)t)";

(* Mutexes *)

PROCEDURE -MutexInit*(VAR m: Mutex; attr: MutexAttr): INTEGER
  "pthread_mutex_init((pthread_mutex_t *)m, attr)";

PROCEDURE -MutexDestroy*(VAR m: Mutex): INTEGER
  "pthread_mutex_destroy((pthread_mutex_t *)m)";

PROCEDURE -MutexLock*(VAR m: Mutex)
  "pthread_mutex_lock((pthread_mutex_t *)m)";

PROCEDURE -MutexUnlock*(VAR m: Mutex)
  "pthread_mutex_unlock((pthread_mutex_t *)m)";

(* Condition Variables *)

PROCEDURE -CondInit*(VAR c: Cond; attr: CondAttr): INTEGER
  "pthread_cond_init((pthread_cond_t *)c, (pthread_condattr_t *)attr)";

PROCEDURE -CondDestroy*(VAR c: Cond; attr: CondAttr): INTEGER
  "pthread_cond_destroy((pthread_cond_t *)c)";

PROCEDURE -CondWait*(VAR c: Cond; VAR m: Mutex): INTEGER
  "pthread_cond_wait((pthread_cond_t *)c, (pthread_mutex_t *)m)";

PROCEDURE -CondTimedWait*(VAR c: Cond; VAR m: Mutex): INTEGER
  "pthread_cond_timedwait((pthread_cond_t *)c, (pthread_mutex_t *)m)";

PROCEDURE -CondSignal*(VAR c: Cond): INTEGER
  "pthread_cond_signal((pthread_cond_t *)c)";

PROCEDURE -CondBroadcast*(VAR c: Cond): INTEGER
  "pthread_cond_broadcast((pthread_cond_t *)c)";

END Pthread.
