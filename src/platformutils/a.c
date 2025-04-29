#include "platformutils.h"
#include <stdio.h>

int main() {
  FILE *fp = fopen("/tmp/PR", "w");
  char s[1024];
  GetAppDir(s, 1024);
  fprintf(fp, "[%s]\n", s);
  fclose(fp);
}
