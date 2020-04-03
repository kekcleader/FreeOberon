MODULE Signals;
(* Copyright 2017-2020 Arthur Yefimov

This file is part of Free Oberon.

Free Oberon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Free Oberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*)
IMPORT Semaphore, Out;

TYPE
  Signal* = RECORD
    sem: Semaphore.Sem; (*sem must be aligned*)
    ok: BOOLEAN
  END;

PROCEDURE Wait*(VAR s: Signal);
BEGIN
  IF ~s.ok OR (Semaphore.Wait(s.sem) # 0) THEN
    Out.String("Error in Signals: Wait failed."); Out.Ln
  END
END Wait;

(* Returns TRUE if signaled, FALSE if timed out. *)
PROCEDURE TimedWait*(VAR s: Signal; n: INTEGER): BOOLEAN;
VAR x: INTEGER;
  r: BOOLEAN;
BEGIN
  IF ~s.ok THEN r := FALSE;
    Out.String("Error in Signals: Could not TimedWait."); Out.Ln
  ELSE
    x := Semaphore.TimedWait(s.sem, n);
    IF x = -1 THEN r := FALSE;
      (*Out.String("Error in Signals: TimedWait failed."); Out.Ln*)(*!FIXME*)
    ELSE r := x = 0
    END
  END;
RETURN r END TimedWait;

PROCEDURE Send*(VAR s: Signal);
BEGIN
  (*Out.String("SENDSIGNAL");Out.Ln;*)
  IF ~s.ok OR (Semaphore.Post(s.sem) # 0) THEN
    Out.String("Error in Signals: Send failed."); Out.Ln
  END
END Send;

PROCEDURE Init*(VAR s: Signal);
BEGIN
  IF Semaphore.Init(s.sem, 0, 0) # 0 THEN
    s.ok := FALSE;
    Out.String("Error in Signals: Init failed."); Out.Ln
  ELSE s.ok := TRUE
  END
END Init;

PROCEDURE Close*(VAR s: Signal);
BEGIN
  (*!TODO*)
END Close;

END Signals.
