// WindowsWrapper.h
//
// Includes Windows.h while avoiding conflicts with Oberon types.


#define BOOLEAN _BOOLEAN
#define CHAR    _CHAR
#include <windows.h>
#undef BOOLEAN
#undef CHAR
