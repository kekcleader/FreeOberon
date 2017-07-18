(*-----------------------------------------------------------------------
Make topologically sorts a set of Oberon source file names according to their import relationships
so that they are in a correct compilation order. The generated list can be prepended with the
command Compiler.Compile and can be compiled.

Make.Order {filename} ~
  reads a list of file names describing Oberon modules. The import relationships of these
  modules are inspected and the modules are sorted accordingly. The sorted list of file names
  is written to the standard output.
-----------------------------------------------------------------------*)
(* taken from trianus system source ; -- noch *)

MODULE vmake;  (*HM 94-06-22 /  *)
IMPORT Texts, In := compatIn, Out := Console;

TYPE
  ModuleName = ARRAY 64 OF CHAR;
  Import = POINTER TO ImportDesc;
  Module = POINTER TO ModuleDesc;
  ModuleDesc = RECORD
    name: ModuleName;
    imports: Import;
    ref: INTEGER;
    next: Module
  END ;
  ImportDesc = RECORD
    mod: Module;
    next: Import;
  END ;

PROCEDURE showhelp;
BEGIN
Out.String ("vmake topologically sorts a set of Oberon source file names according to their import relationships"); Out.Ln;
Out.String ("so that they are in a correct compilation order. The generated list can be prepended with the"); Out.Ln;
Out.String ("command voc and can be compiled"); Out.Ln;
Out.Ln;
Out.String ("vmake {filename} ~"); Out.Ln;
Out.String ("reads a list of file names describing Oberon modules. The import relationships of these"); Out.Ln;
Out.String ("modules are inspected and the modules are sorted accordingly. The sorted list of file names"); Out.Ln;
Out.String ("is written to the standard output."); Out.Ln;
Out.String ("in case modules in different directories must be checked, it is also possible to use MODULES environment variable"); Out.Ln;
Out.String ("which may contain module paths."); Out.Ln

END showhelp;


PROCEDURE Append (VAR name: ModuleName; ext: ARRAY OF CHAR);
  VAR i, j: INTEGER;
BEGIN
  i := 0; WHILE name[i] # 0X DO INC(i) END ;
  j := 0; WHILE ext[j] # 0X DO name[i] := ext[j]; INC(i); INC(j) END ;
  name[i] := 0X
END Append;

PROCEDURE ReadModuleList (VAR list: Module);
  VAR m: Module; name: ModuleName;
BEGIN
  In.Open; list := NIL; In.Name(name);
  IF ~In.Done THEN showhelp
  ELSE
     WHILE In.Done DO
       NEW(m); m.name := name; m.imports := NIL; m.ref := 0; m.next := list; list := m;
       In.Name(name)
     END
  END
END ReadModuleList;

PROCEDURE Find (list: Module; name: ModuleName; VAR m: Module);
BEGIN
  m := list;
  WHILE (m # NIL) & (m.name # name) DO m := m.next END
END Find;

PROCEDURE FindTop (list: Module; VAR m, prev: Module);
BEGIN
  m := list; prev := NIL;
  WHILE (m # NIL) & (m.ref # 0) DO prev := m; m := m.next END
END FindTop;

PROCEDURE FindImports (m, list: Module);
  VAR t: Texts.Text; s: Texts.Scanner; p: Module; imp: Import; name: ModuleName;
BEGIN
  NEW(t); Texts.Open(t, m.name);
  IF t.len > 0 THEN
    Texts.OpenScanner(s, t, 0);
    REPEAT Texts.Scan(s) UNTIL s.eot OR (s.class = Texts.Name) & (s.s = "IMPORT");
    IF ~ s.eot THEN
      REPEAT
        Texts.Scan(s);
        IF s.class = Texts.Name THEN
          COPY(s.s, name); Texts.Scan(s);
          IF (s.class = Texts.Char) & (s.c = ":") THEN Texts.Scan(s); Texts.Scan(s); COPY(s.s, name) END ;
          Append(name, ".Mod");
          Find(list, name, p);
          IF p = NIL THEN NEW(p); p.name := name; p.imports := NIL; p.ref := 0 END ;
          INC(p.ref);
          NEW(imp); imp.mod := p;
          imp.next := m.imports; m.imports := imp
        END
      UNTIL (s.class = Texts.Char) & (s.c = ";")
    END
  END
END FindImports;

PROCEDURE Print (VAR list: Module);
  VAR m, prev: Module; imp: Import;
BEGIN
  IF list # NIL THEN
    FindTop(list, m, prev);
    IF prev = NIL THEN list := m.next ELSE prev.next := m.next END ;
    imp := m.imports; WHILE imp # NIL DO DEC(imp.mod.ref); imp := imp.next END ;
    Print(list);
    Out.String(m.name); (*Out.String(" -s");*) Out.Ln
  END
END Print;

PROCEDURE Order*;
  VAR list, imports, p, m, last: Module;
BEGIN
  ReadModuleList(list);
  m := list;
  WHILE m # NIL DO FindImports(m, list); m := m.next END ;
  Print(list)
END Order;

BEGIN
Order

END vmake.

Make.Order
POPB.Mod
POPC.Mod
POPdump.Mod
POPL.Mod
POPM.Mod
POPP.Mod
POPS.Mod
POPT.Mod
POPV.Mod
~
