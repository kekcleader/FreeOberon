#if defined(__APPLE__)
#include <mach-o/dyld.h>
#include <string.h>
#include <libgen.h>
#endif

void get_app_dir_mac(char *dir, int size) {
  dir[0] = '\0';
#if defined(__APPLE__)
  char path[4096];
  uint32_t bufsize = sizeof(path);
  if (_NSGetExecutablePath(path, &bufsize) == 0) {
    path[sizeof(path) - 1] = '\0';
    int i = 0;
    while (path[i] != '\0') i++;
    while (i != -1 && path[i] != '/') i--;
    i++;
    if (i != 0) {
      path[i] = '\0';
      char search[] = ".app/Contents/MacOS/";
      if (i > sizeof(search) &&
          strncmp(&path[i - sizeof(search) + 1], search, sizeof(search)) == 0)
      {
          path[i - sizeof(search) + 15] = '\0'; // 15 = length of ".app/Contents/" + 1
          strcat(path, "Resources/");
      }
      if ((int)strlen(path) < size) strcpy(dir, path);
    }
  }
#endif
}
