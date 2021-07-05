MODULE Configuration;
CONST
  name*        = 'voc';
  objext*      = '.o';
  objflag*     = ' -o ';
  linkflags*   = ' -L"';
  libspec*     = ' -lvoc';
  libext*      = '';
  os*          = 'ubuntu';
  compiler*    = 'gcc';
  compile*     = 'gcc -fPIC -g';
  installdir*  = '/opt/voc';
  staticLink*  = ' -static';
VAR
  versionLong-: ARRAY 42 OF CHAR;
BEGIN
  versionLong := '2.1.0 [2021/07/05] for gcc LP64 on ubuntu';
END Configuration.
