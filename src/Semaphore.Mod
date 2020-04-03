MODULE Semaphore;
(* Copyright 2020 Arthur Yefimov

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

CONST sizeOfSem = 320;

TYPE
  Sem* = RECORD
    padding: ARRAY sizeOfSem OF CHAR
  END;

  TimeSpec* = RECORD
  END;

PROCEDURE -AAIncludeSemaphoreh0* '#include "Semaphore/Semaphore.h"';

PROCEDURE -Close*(VAR s: Sem): INTEGER
  "sem_close((sem_t *)s)";

PROCEDURE -Destroy*(VAR s: Sem): INTEGER
  "sem_destroy((sem_t *)s)";

PROCEDURE -GetValue*(VAR s: Sem; VAR value: INTEGER): INTEGER
  "sem_getvalue((sem_t *)s, (int *)value)";

PROCEDURE -Init*(VAR s: Sem; a, b: INTEGER): INTEGER
  "sem_init((sem_t *)s, (int)a, (unsigned int)b)";

PROCEDURE -Post*(VAR s: Sem): INTEGER
  "sem_post((sem_t *)s)";

PROCEDURE -TryWait*(VAR s: Sem): INTEGER
  "sem_trywait((sem_t *)s)";

PROCEDURE -Wait*(VAR s: Sem): INTEGER
  "sem_wait((sem_t *)s)";

PROCEDURE -TimedWait*(VAR s: Sem; ms: INTEGER): INTEGER
  "my_sem_timedwait((sem_t *)s, (int)ms)";

END Semaphore.
