MODULE Term;
(* Copyright 2017 Arthur Yefimov

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
IMPORT SYSTEM;

PROCEDURE -AAIncludeTermh* '#include "term/term.h"';

PROCEDURE -StartProcess*
  (cmd: ARRAY OF CHAR): BOOLEAN
  "StartProcess(cmd)";

PROCEDURE -ProcessFinished*(VAR err: INTEGER): BOOLEAN
  "ProcessFinished(err)";

PROCEDURE -WriteToProcess*
  (buf: ARRAY OF CHAR; len: INTEGER)
  "WriteToProcess(buf, len)";

PROCEDURE -ReadFromProcess*
  (VAR buf: ARRAY OF CHAR; VAR len: INTEGER; limit: INTEGER)
  "ReadFromProcess(buf, len, limit)";

PROCEDURE -RunProcess*
  (cmd: ARRAY OF CHAR; VAR buf: ARRAY OF CHAR;
  limit: INTEGER; VAR len, err: INTEGER): INTEGER
  "(int)RunProcess((char *)cmd, (char *)buf, limit, len, err)";

PROCEDURE -SearchPath*
  (filename: ARRAY OF CHAR; VAR result: ARRAY OF CHAR): LONGINT
  "(int)MySearchPath((char *)filename, (char *)result, result__len)";

END Term.
