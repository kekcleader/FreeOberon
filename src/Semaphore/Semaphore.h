#ifndef Semaphore__h0
#define Semaphore__h0

#include <errno.h>
#include <time.h>
#include <semaphore.h>

extern int my_sem_timedwait(sem_t *sem, int ms);

#endif
