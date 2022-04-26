MODULE Config;
IMPORT Platform;
CONST
  isWindows* = Platform.Windows;
  stdPath* = 'Programs/';

  version* = '1.1.0-alpha.6';
  year* = 2022;

VAR
  debug*: BOOLEAN;

PROCEDURE SetDebug*(deb: BOOLEAN);
BEGIN debug := deb
END SetDebug;

BEGIN
  debug := FALSE
END Config.
