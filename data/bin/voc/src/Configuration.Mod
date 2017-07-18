MODULE Configuration;
CONST
  name*        = 'voc';
  objext*      = '.o';
  objflag*     = ' -o ';
  linkflags*   = ' -L"';
  libspec*     = ' -l voc';
  libext*      = '';
  os*          = 'debian';
  compiler*    = 'gcc';
  compile*     = 'gcc -fPIC -g';
  installdir*  = '/opt/voc';
  staticLink*  = ' -static';
VAR
  versionLong-: ARRAY 42 OF CHAR;
BEGIN
  versionLong := '2.1.0 [2017/07/18] for gcc LP64 on debian';
END Configuration.
