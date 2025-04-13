MODULE Config;
IMPORT Platform;
CONST
  isWindows* = Platform.Windows;
  pathDelimiter* = Platform.PathDelimiter;
  stdPath* = 'Programs/';
  startInFullscreen* = TRUE; (** TRUE if Free Oberon should start in full screen *)

  version* = '1.1.0-alpha.8';
  year* = 2025;

VAR
  debug*: BOOLEAN;

PROCEDURE SetDebug*(deb: BOOLEAN);
BEGIN debug := deb
END SetDebug;

BEGIN
  debug := FALSE
END Config.
