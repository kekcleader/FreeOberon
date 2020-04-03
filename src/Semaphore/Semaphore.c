#include "Semaphore.h"

#include <stdio.h>
#include <time.h>

static int NN = 0;

int my_sem_timedwait(sem_t *sem, int ms) {
  int res, a, s, diff;
  struct timespec ts;

  clock_t start, end;
  double T;

  if (clock_gettime(CLOCK_REALTIME, &ts) == 0) {
    s = ms / 1000;
    ms = ms % 1000;
    ts.tv_nsec += ms * 1000000;
    diff = ts.tv_nsec - 1000000000;
    if (diff >= 0) {
      ts.tv_nsec = diff;
      ts.tv_sec += 1 + s;
    } else {
      ts.tv_sec += s;
    }
    
    start = clock();

    while ((res = sem_timedwait(sem, &ts)) == -1 && errno == EINTR) {
      puts("EINTR\n");
    }

    end = clock();
    T = ((double)(end - start)) / CLOCKS_PER_SEC;
    //if (T > 1.0/50)
    //printf("WAIT END %f   :: %d\n", T, NN); NN++;

    if (res == -1 && errno == ETIMEDOUT) res = 1;
  } else {
    res = -1;
  }
  return res;
}
