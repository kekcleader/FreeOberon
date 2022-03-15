MODULE Fob;
(* Copyright 2017-2022 Arthur Yefimov

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
IMPORT FoStrings, Builder, Config, Args, Strings, Out, Kernel;

PROCEDURE Usage;
VAR s: ARRAY 256 OF CHAR;
BEGIN
  Out.String('Free Oberon Compiler version ');
  Out.String(Config.version); Out.Ln;
  Out.String('Copyright (c) 2017-'); Out.Int(Config.year, 0);
  Out.String(' by Arthur Yefimov and others.'); Out.Ln;
  Out.String('Fob uses Ofront+ and GCC (MinGW).'); Out.Ln; Out.Ln;
  Out.String('Usage:'); Out.Ln; Out.String('  ');
  Args.Get(0, s); Out.String(s);

  Out.String(' sourceFile'); Out.Ln; Out.Ln;
  Out.String('Please specify a single file name - the main module source');
  Out.Ln
(*Out.String(' [options] MainModuleSourceFile'); Out.Ln; Out.Ln;
  Out.String('Options:'); Out.Ln;
  Out.String('  -o file     Name of output executable file'); Out.Ln*)
END Usage;

PROCEDURE BuildErrorCallback(fname: ARRAY OF CHAR; col, line, error: INTEGER;
    msg: ARRAY OF CHAR);
BEGIN
  IF fname[0] # 0X THEN
    Out.String(fname); Out.Char(':'); Out.Int(line, 0);
    Out.Char(':'); Out.Int(col, 0); Out.String(': error: ')
  ELSE Out.String('error: ')
  END;
  Out.String(msg); Out.Ln
END BuildErrorCallback;

PROCEDURE Do;
VAR modules: Builder.StrList;
  mainFname, modname, exename, errFname, s: ARRAY 256 OF CHAR;
  errLine, errCol, res: INTEGER;
  graph: BOOLEAN;
BEGIN
  Args.Get(1, mainFname);
  FoStrings.SetLang('en');
  Builder.SetWorkDir(mainFname);
  Builder.GetModuleName(mainFname, modname);
  modules := Builder.UsedModuleList(modname, mainFname,
    errFname, errLine, errCol, res);
  IF res = 0 THEN
    graph := Builder.ImportsGraph(modules);
    IF Builder.CompileAll(modules, graph, exename, BuildErrorCallback) THEN END
  ELSE (*res = 400-file not found or 401-file contains wrong module name*)
    FoStrings.MakeErrorStr(res, s);
    BuildErrorCallback(errFname, 1, 1, 401, s)
  END
END Do;

BEGIN
  IF Args.Count = 0 THEN Usage ELSE Do END
END Fob.
