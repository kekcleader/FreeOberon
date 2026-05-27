MODULE Fob;
(* Copyright 2017-2025 Arthur Yefimov

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
along with Free Oberon.  If not, see <http://www.gnu.org/licenses/>.
*)
IMPORT FoStrings, Builder, Config, Args, Strings, Out, Platform, Kernel;
(** Free Oberon Console Compiler. Part of Free Oberon IDE internal code *)

PROCEDURE Usage;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  Out.String('Free Oberon Compiler version ');
  Out.String(Config.version); Out.Ln;
  Out.String('Copyright (c) 2017-'); Out.Int(Config.year, 0);
  Out.String(' by Arthur Yefimov and others.'); Out.Ln;
  Out.String('Fob uses Ofront+ and GCC (MinGW).'); Out.Ln; Out.Ln;
  Out.String('Usage:'); Out.Ln; Args.Get(0, s);
  Out.String('  '); Out.String(s);
  Out.String(' [options] sourceFile [Module:Variant ...]'); Out.Ln;
  Out.Ln;
  Out.String('Options:'); Out.Ln;
  Out.String('  -o file     Name of output executable file'); Out.Ln;
  Out.String('  --lang xx   Set interface language'); Out.Ln;
  Out.String('  --debug     Enable debug mode'); Out.Ln
END Usage;

PROCEDURE BuildErrorCallback(fname: ARRAY OF CHAR; col, line, error: INTEGER;
    msg: ARRAY OF CHAR);
BEGIN
  IF fname[0] # 0X THEN
    Out.String(fname);
    IF line >= 0 THEN
      Out.Char(':'); Out.Int(line, 0); Out.Char(':'); Out.Int(col, 0)
    END;
    Out.String(': ')
  END;
  Out.String('error: '); Out.String(msg); Out.Ln
END BuildErrorCallback;

PROCEDURE ParseArgs(VAR mainFname, lang, outFname: ARRAY OF CHAR);
VAR i, count: INTEGER;
  s: ARRAY 4096 OF CHAR;
BEGIN i := 1; count := Args.Count(); lang := 'en'; outFname[0] := 0X;
  Builder.ClearVariants;
  WHILE i <= count DO
    Args.Get(i, s);
    IF s = '--lang' THEN Args.Get(i + 1, lang); INC(i)
    ELSIF s = '--debug' THEN Config.SetDebug(TRUE)
    ELSIF (s = '-o') OR (s = '--output') THEN
      IF i < count THEN INC(i); Args.Get(i, outFname) END
    ELSIF Strings.Pos(':', s, 0) > 0 THEN Builder.AddVariant(s)
    ELSE Strings.Copy(s, mainFname)
    END;
    INC(i)
  END
END ParseArgs;

PROCEDURE Do;
VAR modules: Builder.Module;
  mainFname, modname, exename, errFname, lang, outFname, s: ARRAY 256 OF CHAR;
  errLine, errCol, res: INTEGER;
  foreign, ok: BOOLEAN;
BEGIN
  ParseArgs(mainFname, lang, outFname);
  FoStrings.SetLang(lang);
  Builder.SetWorkDir(mainFname);
  Builder.GetModuleName(mainFname, modname);
  modules := Builder.UsedModuleList(modname, mainFname,
    errFname, errLine, errCol, foreign, res);
  IF foreign THEN res := 402 END;
  ok := FALSE;
  IF res = 0 THEN
    IF Builder.CompileAll(modules, exename, TRUE, BuildErrorCallback, outFname)
    THEN ok := TRUE
    END
  ELSE
    FoStrings.MakeErrorStr(res, s);
    BuildErrorCallback(errFname, -1, -1, 401, s)
  END;
  IF ~ok THEN Platform.ExitOS(1) END
END Do;

BEGIN
  IF Args.Count() = 0 THEN Usage ELSE Do END
END Fob.
