(*	$Id: JulianDay.Mod,v 1.4 1999/09/02 13:08:31 acken Exp $	*)
MODULE oocJulianDay;

(*
    JulianDay - convert to/from day/month/year and modified Julian days.       
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

CONST
  daysPerYear  = 365.25D0;        (* used in Julian date calculations *)
  daysPerMonth = 30.6001D0; 
  startMJD* = 2400000.5D0;        (* zero basis for modified Julian Day in Julian days *)
  startTJD* = startMJD+40000.0D0; (* zero basis for truncated modified Julian Day *)

VAR
  UseGregorian-: BOOLEAN;         (* TRUE when Gregorian calendar is in use *)          
  startGregor: LONGREAL;          (* start of the Gregorian calendar in Julian days *)       


(* ------------------------------------------------------------- *)
(* Conversion functions *)

PROCEDURE DateToJD * (day, month: SHORTINT; year: INTEGER) : LONGREAL;
(* Returns a Julian date in days for the given `day', `month',
   and `year' at 0000 UTC.  Any date with a positive year is valid. 
   Algorithm by William H. Jefferys (with some modifications) at: 
   http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html *)
VAR
  A, B, C: LONGINT; JD: LONGREAL;
BEGIN
  IF month<3 THEN DEC(year); INC(month, 12) END;
  IF UseGregorian THEN A:=year DIV 100; B:=A DIV 4; C:=2-A+B
  ELSE C:=0
  END;
  JD:=C+day+ENTIER(daysPerYear*(year+4716))+ENTIER(daysPerMonth*(month+1))-1524.5D0;
  IF UseGregorian & (JD>=startGregor) THEN RETURN JD
  ELSE RETURN JD-C
  END
END DateToJD;

PROCEDURE DateToDays * (day, month: SHORTINT; year: INTEGER) : LONGINT;
(* Returns a modified Julian date in days for the given `day', `month',
   and `year' at 0000 UTC.  Any date with a positive year is valid.  
   The returned value is the number of days since 17 November 1858. *)
BEGIN
  RETURN ENTIER(DateToJD(day, month, year)-startMJD)
END DateToDays;

PROCEDURE DateToTJD * (day, month: SHORTINT; year: INTEGER) : LONGINT;
(* Returns a truncated modified Julian date in days for the given `day',
  `month', and `year' at 0000 UTC.  Any date with a positive year is
  valid.  The returned value is the *)
BEGIN
  RETURN ENTIER(DateToJD(day, month, year)-startTJD)
END DateToTJD;

PROCEDURE JDToDate * (jd: LONGREAL; VAR day, month: SHORTINT; VAR year: INTEGER);
(* Converts a Julian date in days to a date given by the `day', `month', and 
   `year'.  Algorithm by William H. Jefferys (with some modifications) at 
   http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html *)
VAR
  W, D, B: LONGINT;
BEGIN
  jd:=jd+0.5;
  IF UseGregorian & (jd>=startGregor) THEN
    W:=ENTIER((jd-1867216.25D0)/36524.25D0);
    B:=ENTIER(jd+1525+W-ENTIER(W/4.0D0))
  ELSE B:=ENTIER(jd+1524)
  END;
  year:=SHORT(ENTIER((B-122.1D0)/daysPerYear));
  D:=ENTIER(daysPerYear*year);
  month:=SHORT(SHORT(ENTIER((B-D)/daysPerMonth)));
  day:=SHORT(SHORT(B-D-ENTIER(daysPerMonth*month)));
  IF month>13 THEN DEC(month, 13) ELSE DEC(month) END;  
  IF month<3 THEN DEC(year, 4715) ELSE DEC(year, 4716) END  
END JDToDate;

PROCEDURE DaysToDate * (jd: LONGINT; VAR day, month: SHORTINT; VAR year: INTEGER);
(* Converts a modified Julian date in days to a date given by the `day',
   `month', and `year'. *)
BEGIN
  JDToDate(jd+startMJD, day, month, year) 
END DaysToDate;

PROCEDURE TJDToDate * (jd: LONGINT; VAR day, month: SHORTINT; VAR year: INTEGER);
(* Converts a truncated modified Julian date in days to a date given by the `day',
   `month', and `year'. *)
BEGIN
  JDToDate(jd+startTJD, day, month, year) 
END TJDToDate;

PROCEDURE SetGregorianStart * (day, month: SHORTINT; year: INTEGER);
(* Sets the start date when the Gregorian calendar was first used
   where the date in `d' is in the Julian calendar.  The default
   date used is 3 Sep 1752 (when the calendar correction occurred
   according to the Julian calendar).
   
   The Gregorian calendar was introduced in 4 Oct 1582 by Pope 
   Gregory XIII but was not adopted by many Protestant countries
   until 2 Sep 1752.  In all cases, to make up for an inaccuracy
   in the calendar, 10 days were skipped during adoption of the 
   new calendar. *)
VAR
  gFlag: BOOLEAN;
BEGIN
  gFlag:=UseGregorian; UseGregorian:=FALSE;  (* use Julian calendar *)
  startGregor:=DateToJD(day, month, year);
  UseGregorian:=gFlag                        (* back to default *)
END SetGregorianStart;

BEGIN
  (* by default we use the Gregorian calendar *)
  UseGregorian:=TRUE; startGregor:=0;

  (* Gregorian calendar default start date *)
  SetGregorianStart(3, 9, 1752)
END oocJulianDay.
