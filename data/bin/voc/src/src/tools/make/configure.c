// Test platform supportability and establish build configuration:
//
// Writes the configuration parameters to these two files:
//
//   Configuration.Mod  - settings to compile into the compiler binary
//   Configuration.make - makefile variable settings for this configuration
//
// Derived from vocparam.c originally by J. Templ 23.6.95


#define O_VER 2.1.0   // Version number to be reported by compiler.
#define O_NAME voc    // Compiler name used for binary, install dir and references in text.


#include "SYSTEM.h"


#ifdef _WIN32
  #define strncasecmp _strnicmp
  char* getcwd(char* buf, size_t size);
#else
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <sys/utsname.h>
  #include <unistd.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>


void fail(char *msg) {fprintf(stderr, "Error: %s\n", msg); exit(1);}
void assert(int truth, char *complaint) {if (!truth) fail(complaint);}




char builddate[256];
char installdir[256];
char versionstring[256];
char osrelease[1024];
char cwd[1024];
char libspec[1024];

#define macrotostringhelper(s) #s
#define macrotostring(s) macrotostringhelper(s)
char *version     = macrotostring(O_VER);
char *objext      = ".o";
char *objflag     = " -o ";
char *linkflags   = " -L\"";
char *libext      = "";
char *oname       = NULL;  // From O_NAME env var if present, or O_NAME macro otherwise.
char *dynext      = ".so";
char *dataModel   = NULL;
char *compiler    = NULL;
char *cc          = NULL;
char *os          = NULL;
char *platform    = NULL;
char *binext      = NULL;
char *staticlink  = NULL;  // Static compilation option - none on darwin / windows.
int   alignment   = 0;
int   addressSize = 0;
int   intsize     = 0;
int   bsd         = 0;
int   termux      = 0;
int   bootstrap   = 0;    // 1 iff generating a bootstrap compiler.



void ParseOsRelease(FILE *fd) {
  while (fgets(osrelease, sizeof(osrelease), fd) != NULL) {
    if (strncasecmp(osrelease, "id=", 3) == 0) {
      int i=3;
      while (osrelease[i] == '"') {i++;}
      int j=i;
      while (osrelease[j] > '"') {j++;}
      if (j>i) {
        osrelease[j] = 0;
        os = osrelease + i;
      }
      break;
    }
  }
  fclose(fd);
}


void determineLinuxVariant() {
  FILE *fd = NULL;
  os = "linux";

  if ((fd = fopen("/etc/os-release", "r"))) {ParseOsRelease(fd); return;}
  // Hack for centos without /etc/os-release
  if ((fd = fopen("/etc/centos-release", "r"))) {os = "centos"; fclose(fd); return;}
  // Hack to detect running in termux in android
  if ((fd = fopen("/data/data/com.termux/files/usr/bin/bash", "r"))) {os = "termux"; staticlink = ""; termux = 1; fclose(fd); return;}
}


void determineOS() {
  #ifdef _WIN32
    os = "windows";  platform = "windows";  binext = ".exe"; staticlink = "";
  #else
    os = "unknown";  platform = "unix";     binext = "";     staticlink = " -static";

    struct utsname sys;
    if (uname(&sys)<0) fail("Couldn't get sys name - uname() failed.");

    if      (strncasecmp(sys.sysname, "cygwin",  6) == 0) {os = "cygwin";  binext = ".exe";}
    else if (strncasecmp(sys.sysname, "linux",   5) == 0) {determineLinuxVariant();}
    else if (strncasecmp(sys.sysname, "freebsd", 5) == 0) {os = "freebsd"; bsd = 1;}
    else if (strncasecmp(sys.sysname, "openbsd", 5) == 0) {os = "openbsd"; bsd = 1;}
    else if (strncasecmp(sys.sysname, "darwin",  5) == 0) {os = "darwin";  staticlink = ""; dynext = ".dylib";}
    else {
      fprintf(stderr, "\n\n** Unrecognised utsname.sysname '%s' returned by uname().\n", sys.sysname);
      fprintf(stderr, "** Please add a test for this OS in src/buildtools/configure.c\n");
      fprintf(stderr, "** in function determineOS() near line %d.\n\n", __LINE__-3);
      fail("Unrecognised OS architecture name (sysname) returned by uname.");
    }
  #endif
}

#define optimize "" // " -O1"

void determineCCompiler() {
  snprintf(libspec, sizeof(libspec), " -l %s", oname);
  #if defined(__MINGW32__)
    compiler = "mingw";
    if (sizeof (void*) == 4) {
      cc = "i686-w64-mingw32-gcc -g" optimize;
    } else {
      cc = "x86_64-w64-mingw32-gcc -g" optimize;
    }
  #elif defined(__clang__)
    compiler = "clang";
    cc       = "clang -fPIC -g" optimize;
  #elif defined(__GNUC__)
    compiler = "gcc";
    if (strncasecmp(os, "cygwin",  6) == 0) {
      // Avoid cygwin specific warning that -fPIC is ignored.
      cc = "gcc -g" optimize;
    } else {
      cc = "gcc -fPIC -g" optimize;
    }
  #elif defined(_MSC_VER)
    compiler  = "msc";
    cc        = "cl /nologo";
    objext    = ".obj";
    objflag   = " -Fe";
    linkflags = " -link -libpath:\"";
    snprintf(libspec, sizeof(libspec), " lib%s", oname);
    libext    = ".lib";
  #else
    fail("Unrecognised C compiler.");
  #endif
}



void determineInstallDirectory() {
  if (bootstrap) {
    installdir[0] = 0;
  } else {
    char *env = getenv("INSTALLDIR");
    if (env) {
      strncpy(installdir, env, sizeof(installdir));
    } else {
      #if defined(_MSC_VER) || defined(__MINGW32__)
        if (sizeof (void*) == 8) {
          snprintf(installdir, sizeof(installdir), "%s\\%s", getenv("ProgramFiles"), oname);
        } else {
          snprintf(installdir, sizeof(installdir), "%s\\%s", getenv("ProgramFiles(x86)"), oname);
        }
        #if defined(__MINGW32__)
          int i; for(i=0; installdir[i]; i++) if (installdir[i] == '\\') installdir[i] = '/';
        #endif
      #else
        if (bsd) {
          snprintf(installdir, sizeof(installdir), "/usr/local/share/%s", oname);
        } else if (termux) {
          snprintf(installdir, sizeof(installdir), "/data/data/com.termux/files/opt/%s", oname);
        } else {
          snprintf(installdir, sizeof(installdir), "/opt/%s", oname);
        }
      #endif
    }
  }
}




void determineBuildDate() {
  time_t t = time(0);
  strftime(builddate, sizeof(builddate), "%Y/%m/%d", localtime(&t));
}



struct {char ch; CHAR      x;}    c;
struct {char ch; BOOLEAN   x;}    b;
//struct {char ch; SHORTINT  x;}    si;
//struct {char ch; INTEGER   x;}    i;
//struct {char ch; LONGINT   x;}    li;
//struct {char ch; SET       x;}    s;
struct {char ch; REAL      x;}    r;
struct {char ch; LONGREAL  x;}    lr;
struct {char ch; void*     x;}    p;
struct {char ch; void    (*x)();} f;
struct {char ch; int       x;}    in;
struct {char ch; long      x;}    lo;
struct {char ch; long long x;}    ll;
struct {char ch; char      x[1];} a1;
struct {char ch; char      x[2];} a2;
struct {char ch; char      x[4];} a4;
struct {char ch; char      x[8];} a8;

struct s1 {char ch;};     struct {char ch; struct s1 x;} s1;
struct s2 {char ch[2];};  struct {char ch; struct s2 x;} s2;
struct s4 {char ch[4];};  struct {char ch; struct s4 x;} s4;
struct s8 {char ch[8];};  struct {char ch; struct s8 x;} s8;

struct {char ch;}    rec0;
struct {char x[65];} rec2;




// Pass any parameter to configure and it will report sizes and alignments
// instead of generating configuration files.

void ReportSizesAndAlignments() {
  printf("Type      Size   Align\n");
  printf("CHAR      %4zd    %4td\n", sizeof(CHAR),      (char*)&c.x  - (char*)&c);
  printf("BOOLEAN   %4zd    %4td\n", sizeof(BOOLEAN),   (char*)&b.x  - (char*)&b);
//printf("SHORTINT  %4zd    %4td\n", sizeof(SHORTINT),  (char*)&si.x - (char*)&si);
//printf("INTEGER   %4zd    %4td\n", sizeof(INTEGER),   (char*)&i.x  - (char*)&i);
//printf("LONGINT   %4zd    %4td\n", sizeof(LONGINT),   (char*)&li.x - (char*)&li);
//printf("SET       %4zd    %4td\n", sizeof(SET),       (char*)&s.x  - (char*)&s);
  printf("REAL      %4zd    %4td\n", sizeof(REAL),      (char*)&r.x  - (char*)&r);
  printf("LONGREAL  %4zd    %4td\n", sizeof(LONGREAL),  (char*)&lr.x - (char*)&lr);
  printf("void*     %4zd    %4td\n", sizeof(void*),     (char*)&p.x  - (char*)&p);
  printf("int       %4zd    %4td\n", sizeof(int),       (char*)&in.x - (char*)&in);
  printf("long      %4zd    %4td\n", sizeof(long),      (char*)&lo.x - (char*)&lo);
  printf("long long %4zd    %4td\n", sizeof(long long), (char*)&ll.x - (char*)&ll);
  printf("char[1]   %4zd    %4td\n", sizeof(a1.x),      (char*)&a1.x - (char*)&a1);
  printf("char[2]   %4zd    %4td\n", sizeof(a2.x),      (char*)&a2.x - (char*)&a2);
  printf("char[4]   %4zd    %4td\n", sizeof(a4.x),      (char*)&a4.x - (char*)&a4);
  printf("char[8]   %4zd    %4td\n", sizeof(a8.x),      (char*)&a8.x - (char*)&a8);
  printf("struct s1 %4zd    %4td\n", sizeof(struct s1), (char*)&s1.x - (char*)&s1);
  printf("struct s2 %4zd    %4td\n", sizeof(struct s2), (char*)&s2.x - (char*)&s2);
  printf("struct s4 %4zd    %4td\n", sizeof(struct s4), (char*)&s4.x - (char*)&s4);
  printf("struct s8 %4zd    %4td\n", sizeof(struct s8), (char*)&s8.x - (char*)&s8);
}



#define MIN(a,b) (((a)<(b)) ? (a) : (b))

void determineCDataModel() {
  addressSize = sizeof(void*);
  alignment = (char*)&lr.x - (char*)&lr;   // Base alignment measure on largest type.

  if      (addressSize == 4  &&  sizeof(int)  == 4) dataModel = "ILP32";  // Unix/Linux and modern Win32
  else if (addressSize == 8  &&  sizeof(long) == 4) dataModel = "LLP64";  // Windows/mingw 64 bit
  else if (addressSize == 8  &&  sizeof(long) == 8) dataModel = "LP64";   // Unix/Linux 64 bit
  else fail("Unsupported combination of address size and int/long size.");

  // Check for supported address sie and alignment

  if (addressSize == 4) {
    assert(alignment == 4  ||  alignment == 8, "Aligment neither 4 nor 8 when address size is 4.");
  } else {
    assert(addressSize == 8, "Address size neither 4 nor 8.");
    assert(alignment == 8, "Alignemnt not 8 when address size is 8.");
  }

  // Define 'LARGE' to get 32 bit INTEGER and 64 bit LONGINT even on 32 bit systems.
  // Note that plenty of the library source files do not expect this.

  #ifdef LARGE
    intsize = 4;
  #else
    intsize = (addressSize == 4) ? 2 : 4;
  #endif
}




void testSystemDotH() {
  /* test the __ASHR macro */
  assert(__ASHR(-1, 1) == -1, "ASH(-1, -1) # -1.");
  assert(__ASHR(-2, 1) == -1, "ASH(-2, -1) # -1.");
  assert(__ASHR(0, 1)  ==  0, "ASH(0, 1) #  0.");
  assert(__ASHR(1, 1)  ==  0, "ASH(1, 1) #  0.");
  assert(__ASHR(2, 1)  ==  1, "ASH(2, 1) #  1.");

  /* test the __SETRNG macro */
  long x = 0;
  long y;
  y=31; assert(__SETRNG(x, y, 32) == -1, "SETRNG(0, MAX(SET), 32) != -1.");
  y=63; assert(__SETRNG(x, y, 64) == -1, "SETRNG(0, MAX(SET), 32) != -1.");
//  long y = sizeof(SET)*8 - 1;
//  if (sizeof(SET) == 4)
//    assert(__SETRNG(x, y, 32) == -1, "SETRNG(0, MAX(SET)) != -1.");
//  else
//    assert(__SETRNG(x, y, 64) == -1, "SETRNG(0, MAX(SET)) != -1.");

  /* test string comparison for extended ascii */
  {char a[10], b[10];
    a[0] = (CHAR)128; a[1] = 0;
    b[0] = 0;
    assert(__STRCMP(a, b) >= 0, "__STRCMP(a, b) with extended ascii charcters; should be unsigned.");
  }

  // Check the sizes of the Oberon basic types as defined in SYSTEM.h.
  // By design all but INTEGER and LONGINT are fixed across all supported platfroms.

  assert(sizeof(CHAR)     == 1, "Size of CHAR not 1.");
  assert(sizeof(BOOLEAN)  == 1, "Size of BOOLEAN not 1.");
//assert(sizeof(SHORTINT) == 1, "Size of SHORTINT not 1.");
//assert(sizeof(INTEGER)  == 2
//    || sizeof(INTEGER)  == 4, "Size of INTEGER neither 2 nor 4 bytes.");
//assert(sizeof(LONGINT)  == 4
//    || sizeof(LONGINT)  == 8, "Size of LONGINT neither 4 nor 8 bytes.");
//assert(sizeof(SET) == sizeof(LONGINT), "Size of SET differs from size of LONGINT.");
  assert(sizeof(REAL)     == 4, "Size of REAL not 4 bytes.");
  assert(sizeof(LONGREAL) == 8, "Size of LONGREAL not 8 bytes.");
  assert(sizeof(f.x) == sizeof(p.x), "Size of function pointer differs from size of data pointer.");

  assert((alignment == 4) || (alignment == 8), "Alignment of LONGINT neither 4 nor 8 bytes.");

  assert(((char*)&c.x  - (char*)&c)  == 1, "Alignment of CHAR not 1.");
  assert(((char*)&b.x  - (char*)&b)  == 1, "Alignment of BOOLEAN not 1.");
//assert(((char*)&si.x - (char*)&si) == 1, "Alignment of SHORTINT not 1.");
//assert(((char*)&i.x  - (char*)&i)  == 4, "Alignment of INTEGER not 4 bytes.");
  assert(((char*)&r.x  - (char*)&r)  == 4, "Alignment of REAL not 4 bytes.");
  assert(((char*)&lr.x - (char*)&lr) >= 4, "Alignment of LONGREAL less than 4 bytes.");
//assert(((char*)&s.x  - (char*)&s)  == MIN(alignment, sizeof(SET)), "Alignment of SET differs from alignmnet of LONGINT.");
  assert(((char*)&p.x  - (char*)&p)  == addressSize, "Alignment of data pointer differs from address size.");
  assert(((char*)&f.x  - (char*)&f)  == addressSize, "Alignment of data pointer differs from address size.");
  assert(((char*)&lr.x - (char*)&lr) == ((char*)&ll.x - (char*)&ll), "Alignment of LONGREAL differs from alignment of long long.");

  assert(sizeof(rec0) ==  1, "CHAR wrapped in record aligns differently to CHAR alone.");
  assert(sizeof(rec2) == 65, "CHAR array wrapped in record aligns differently to CHAR array alone.");

//assert(sizeof(LONGINT) >= sizeof(p.x), "LONGINT should have at least the same size as data pointers.");
//assert(sizeof(LONGINT) >= sizeof(f.x), "LONGINT should have at least the same size as function pointers.");

  if (((sizeof(rec2)==65) == (sizeof(rec0)==1)) && ((sizeof(rec2)-64) != sizeof(rec0)))
    printf("error: unsupported record layout  sizeof(rec0) = %lu  sizeof(rec2) = %lu\n", (long)sizeof(rec0), (long)sizeof(rec2));

  x = 1;
  assert(*(char*)&x == 1, "C compiler does not store multibyte numeric values in little-endian order.");
}




void writeMakeParameters() {
  FILE *fd = fopen("Configuration.Make", "w");
  if (fd == NULL) fail("Couldn't create Configuration.make.");
  fprintf(fd, "OLANGDIR=%s\n",   cwd);
  fprintf(fd, "COMPILER=%s\n",   compiler);
  fprintf(fd, "OS=%s\n",         os);
  fprintf(fd, "VERSION=%s\n",    version);
  fprintf(fd, "ONAME=%s\n",      oname);
  fprintf(fd, "DATAMODEL=%s\n",  dataModel);
  fprintf(fd, "ADRSIZE=%d\n",    addressSize);
  fprintf(fd, "ALIGNMENT=%d\n",  alignment);
  fprintf(fd, "INSTALLDIR=%s\n", installdir);
  fprintf(fd, "PLATFORM=%s\n",   platform);
  fprintf(fd, "BINEXT=%s\n",     binext);
  fprintf(fd, "DYNEXT=%s\n",     dynext);
  fprintf(fd, "COMPILE=%s\n",    cc);
  fprintf(fd, "STATICLINK=%s\n", staticlink);
  fclose(fd);
}




void writeConfigurationMod() {
  FILE *fd = fopen("Configuration.Mod", "w");
  if (fd == NULL) fail("Couldn't create Configuration.Mod.");

  fprintf(fd, "MODULE Configuration;\n");
  fprintf(fd, "CONST\n");
  fprintf(fd, "  name*        = '%s';\n", oname);
  fprintf(fd, "  objext*      = '%s';\n", objext);
  fprintf(fd, "  objflag*     = '%s';\n", objflag);
  fprintf(fd, "  linkflags*   = '%s';\n", linkflags);
  fprintf(fd, "  libspec*     = '%s';\n", libspec);
  fprintf(fd, "  libext*      = '%s';\n", libext);
  fprintf(fd, "  os*          = '%s';\n", os);
  fprintf(fd, "  compiler*    = '%s';\n", compiler);
  fprintf(fd, "  compile*     = '%s';\n", cc);
  fprintf(fd, "  installdir*  = '%s';\n", installdir);
  fprintf(fd, "  staticLink*  = '%s';\n", staticlink);
  fprintf(fd, "VAR\n");
  fprintf(fd, "  versionLong-: ARRAY %d OF CHAR;\n", (int)strnlen(versionstring, 100)+1);
  fprintf(fd, "BEGIN\n");
  fprintf(fd, "  versionLong := '%s';\n", versionstring);
  fprintf(fd, "END Configuration.\n");

  fclose(fd);
}




int main(int argc, char *argv[])
{
  // Make sure SYSTEM.h has set up our core data types correctly.
  assert(sizeof(INT8)  == 1, "sizeof(INT8) is not 1.");
  assert(sizeof(INT16) == 2, "sizeof(INT16) is not 2.");
  assert(sizeof(INT32) == 4, "sizeof(INT32) is not 4.");
  assert(sizeof(INT64) == 8, "sizeof(INT64) is not 8.");

  oname = getenv("ONAME"); if (!oname) oname = macrotostring(O_NAME);

  if (argc>1) {
    if (strncasecmp(argv[1], "rep", 3) == 0) {
      ReportSizesAndAlignments();
      exit(0);
    } else {
      bootstrap = 1;
    }
  }

  getcwd(cwd, sizeof(cwd));
  int i; for (i=0; cwd[i]; i++) if (cwd[i]=='\\') cwd[i]='/';

  determineOS();
  determineCCompiler();
  determineCDataModel();
  determineBuildDate();
  determineInstallDirectory();

  testSystemDotH();

  if (bootstrap) {
    snprintf(versionstring, sizeof(versionstring),
             "%s [%s]. Bootstrapping compiler for address size %d, alignment %d.",
             version, builddate, addressSize, alignment);
  } else {
    snprintf(versionstring, sizeof(versionstring),
             "%s [%s] for %s %s on %s",
             version, builddate, compiler, dataModel, os);
  }

  writeConfigurationMod();
  writeMakeParameters();

  printf("Configuration: %s\n", versionstring);
  return 0;
}
