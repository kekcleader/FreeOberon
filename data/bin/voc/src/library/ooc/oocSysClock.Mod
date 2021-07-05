MODULE oocSysClock; 
IMPORT SYSTEM, Platform;
  
PROCEDURE CanGetClock*(): BOOLEAN; BEGIN RETURN TRUE END CanGetClock;

PROCEDURE GetTimeOfDay* (VAR sec, usec: LONGINT): LONGINT;
(* PRIVAT.  Don't use this.  Take Time.GetTime instead.  
   Equivalent to the C function `gettimeofday'.  The return value is `0' on 
   success and `-1' on failure; in the latter case `sec' and `usec' are set to
   zero.  *)
BEGIN
  Platform.GetTimeOfDay(sec, usec); RETURN 0;
END GetTimeOfDay;

END oocSysClock.
