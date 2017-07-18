(*	$Id: Time.Mod,v 1.6 2000/08/05 18:39:09 ooc-devel Exp $	*)
MODULE oocTime;

(*
    Time - time and time interval manipulation.       
    Copyright (C) 1996 Michael Griebling
 
    This module is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.
 
    This module is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General Public
    License along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*)

IMPORT SysClock := oocSysClock;

CONST
  msecPerSec*  = 1000;
  msecPerMin*  = msecPerSec*60;
  msecPerHour* = msecPerMin*60;
  msecPerDay * = msecPerHour*24;
       
TYPE    
  (* The TimeStamp is a compressed date/time format with the
     advantage over the Unix time stamp of being able to 
     represent any date/time in the DateTime type.  The 
     fields are defined as follows:
     
        days  = Modified Julian days since 17 Nov 1858. 
				This quantity can be negative to represent
				dates occuring before day zero. 
        msecs = Milliseconds since 00:00.
        
     NOTE: TimeStamp is in UTC or local time when time zones
     are not supported by the local operating system.
  *)
  TimeStamp * =
    RECORD
      days-:  LONGINT;
      msecs-: LONGINT
    END;
  
  (* The Interval is a delta time measure which can be used
     to increment a Time or find the time difference between
     two Times.  The fields are defined as follows:
		
		dayInt  = numbers of days in this interval
		msecInt = the number of milliseconds in this interval
		
	  The maximum number of milliseconds in an interval will
	  be the value `msecPerDay' *)
  Interval * =
	RECORD
	  dayInt-:  LONGINT;
	  msecInt-: LONGINT
	END; 
     

(* ------------------------------------------------------------- *)
(* TimeStamp functions *)

PROCEDURE InitTimeStamp* (VAR t: TimeStamp; days, msecs: LONGINT);
(* Initialize the TimeStamp `t' with `days' days and `msecs' mS. 
   Pre: msecs>=0 *)
BEGIN
  t.msecs:=msecs MOD msecPerDay;
  t.days:=days + msecs DIV msecPerDay
END InitTimeStamp;

PROCEDURE GetTime* (VAR t: TimeStamp);
(* Set `t' to the current time of day.  In case of failure (i.e. if 
   SysClock.CanGetClock() is FALSE) the time 00:00 UTC on Jan 1 1970 is 
   returned.  This procedure is typically much faster than doing 
   SysClock.GetClock followed by Calendar.SetTimeStamp.  *)
  VAR
    res, sec, usec: LONGINT;
  BEGIN
    res := SysClock.GetTimeOfDay (sec, usec);
    t. days := 40587+sec DIV 86400;
    t. msecs := (sec MOD 86400)*msecPerSec + usec DIV 1000
  END GetTime;


PROCEDURE (VAR a: TimeStamp) Add* (b: Interval);
(* Adds the interval `b' to the time stamp `a'. *) 
BEGIN
  INC(a.msecs, b.msecInt);
  INC(a.days, b.dayInt);
  IF a.msecs>=msecPerDay THEN 
    DEC(a.msecs, msecPerDay); INC(a.days) 
  END
END Add;

PROCEDURE (VAR a: TimeStamp) Sub* (b: Interval);
(* Subtracts the interval `b' from the time stamp `a'. *) 
BEGIN
  DEC(a.msecs, b.msecInt);
  DEC(a.days, b.dayInt);
  IF a.msecs<0 THEN INC(a.msecs, msecPerDay); DEC(a.days) END
END Sub;

PROCEDURE (VAR a: TimeStamp) Delta* (b: TimeStamp; VAR c: Interval);
(* Post: c = a - b *) 
BEGIN
  c.msecInt:=a.msecs-b.msecs;
  c.dayInt:=a.days-b.days;
  IF c.msecInt<0 THEN 
    INC(c.msecInt, msecPerDay); DEC(c.dayInt)
  END
END Delta;

PROCEDURE (VAR a: TimeStamp) Cmp* (b: TimeStamp) : SHORTINT;
(* Compares 'a' to 'b'.  Result: -1: a<b;  0: a=b;  1: a>b 
   This means the comparison 
   can be directly extrapolated to a comparison between the 
   two numbers e.g.,
   
        Cmp(a,b)<0  then a<b
        Cmp(a,b)=0  then a=b
        Cmp(a,b)>0  then a>b
        Cmp(a,b)>=0 then a>=b
*)
BEGIN
  IF (a.days>b.days) OR (a.days=b.days) & (a.msecs>b.msecs) THEN RETURN 1
  ELSIF (a.days=b.days) & (a.msecs=b.msecs) THEN RETURN 0
  ELSE RETURN -1
  END
END Cmp;


(* ------------------------------------------------------------- *)
(* Interval functions *)

PROCEDURE InitInterval* (VAR int: Interval; days, msecs: LONGINT);
(* Initialize the Interval `int' with `days' days and `msecs' mS. 
   Pre: msecs>=0 *)
BEGIN
  int.dayInt:=days + msecs DIV msecPerDay;
  int.msecInt:=msecs MOD msecPerDay
END InitInterval;

PROCEDURE (VAR a: Interval) Add* (b: Interval);
(* Post: a = a + b *) 
BEGIN
  INC(a.msecInt, b.msecInt);
  INC(a.dayInt, b.dayInt);
  IF a.msecInt>=msecPerDay THEN 
    DEC(a.msecInt, msecPerDay); INC(a.dayInt)
  END
END Add;

PROCEDURE (VAR a: Interval) Sub* (b: Interval);
(* Post: a = a - b *) 
BEGIN
  DEC(a.msecInt, b.msecInt);
  DEC(a.dayInt, b.dayInt);
  IF a.msecInt<0 THEN 
    INC(a.msecInt, msecPerDay); DEC(a.dayInt)
  END
END Sub;

PROCEDURE (VAR a: Interval) Cmp* (b: Interval) : SHORTINT;
(* Compares 'a' to 'b'.  Result: -1: a<b;  0: a=b;  1: a>b 
   Above convention makes more sense since the comparison 
   can be directly extrapolated to a comparison between the 
   two numbers e.g.,
   
        Cmp(a,b)<0  then a<b
        Cmp(a,b)=0  then a=b
        Cmp(a,b)>0  then a>b
        Cmp(a,b)>=0 then a>=b
*)
BEGIN
  IF (a.dayInt>b.dayInt) OR (a.dayInt=b.dayInt)&(a.msecInt>b.msecInt) THEN RETURN 1
  ELSIF (a.dayInt=b.dayInt) & (a.msecInt=b.msecInt) THEN RETURN 0
  ELSE RETURN -1
  END
END Cmp;

PROCEDURE (VAR a: Interval) Scale* (b: LONGREAL);
(* Pre: b>=0; Post: a := a*b *)
VAR
  si: LONGREAL;
BEGIN
  si:=(a.dayInt+a.msecInt/msecPerDay)*b;
  a.dayInt:=ENTIER(si); 
  a.msecInt:=ENTIER((si-a.dayInt)*msecPerDay+0.5D0)
END Scale;

PROCEDURE (VAR a: Interval) Fraction* (b: Interval) : LONGREAL;
(* Pre: b<>0; Post: RETURN a/b *)
BEGIN
  RETURN (a.dayInt+a.msecInt/msecPerDay)/(b.dayInt+b.msecInt/msecPerDay)
END Fraction;

END oocTime.
