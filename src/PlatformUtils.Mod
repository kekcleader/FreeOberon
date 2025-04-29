MODULE [foreign] PlatformUtils;
IMPORT SYSTEM;

TYPE CHAR8* = SHORTCHAR;

(** On macOS, puts in `buf` path to the application with a trailing "/". If the application
    is inside located at the path that ends with ".app/Contents/MacOS/", swaps that to
    ".app/Contents/Resources/". On other platforms puts an empty string in buf. *)
PROCEDURE GetAppDirMac* ["get_app_dir_mac"]
  (VAR buf: ARRAY OF CHAR8; len: INTEGER);

END PlatformUtils.
