MODULE extTools;

IMPORT Strings, Out, Configuration, Platform, Modules, Heap, OPM;

TYPE CommandString = ARRAY 4096 OF CHAR;

VAR CFLAGS: CommandString;


PROCEDURE execute(title: ARRAY OF CHAR; cmd: ARRAY OF CHAR);
  VAR r, status, exitcode: INTEGER; fullcmd: CommandString;
BEGIN
  IF OPM.verbose IN OPM.Options THEN
    Out.String("  "); Out.String(cmd); Out.Ln
  END;

  (* Hack to suppress unwanted filename display by Microsoft C compiler on successful compilations. *)
  IF Configuration.compiler = "MSC" THEN
    fullcmd := "cmd /c ";
    Strings.Append(cmd, fullcmd);
    Strings.Append(" >msc-listing || type msc-listing", fullcmd)
  ELSE
    COPY(cmd, fullcmd);
  END;

  (* Get GC to run file finalizers closing generated C files as otherwise Microsoft C cannot open them. *)
  Heap.GC(FALSE);

  r := Platform.System(fullcmd);

  status := r MOD 128; exitcode := r DIV 256;
  IF exitcode > 127 THEN exitcode := exitcode - 256 END; (* Handle signed exit code *)

  IF r # 0 THEN
    Out.String(title); Out.String(cmd); Out.Ln;
    Out.String("-- failed: status "); Out.Int(status,1);
    Out.String(", exitcode ");        Out.Int(exitcode,1);
    Out.String("."); Out.Ln;
    IF (status = 0) & (exitcode = 127) THEN
      Out.String("Is the C compiler in the current command path?"); Out.Ln
    END;
    IF status # 0 THEN Modules.Halt(status) ELSE Modules.Halt(exitcode) END
  END;
END execute;


PROCEDURE InitialiseCompilerCommand(VAR s: ARRAY OF CHAR);
BEGIN
  COPY(Configuration.compile, s);
  Strings.Append(' -I "', s);
  Strings.Append(OPM.ResourceDir, s);
  Strings.Append('/include" ', s);
  Platform.GetEnv("CFLAGS", CFLAGS);
  Strings.Append (CFLAGS, s);
  Strings.Append (" ", s);
END InitialiseCompilerCommand;


PROCEDURE Assemble*(moduleName: ARRAY OF CHAR);
  VAR
    cmd: CommandString;
  BEGIN
    InitialiseCompilerCommand(cmd);
    Strings.Append("-c ",      cmd);
    Strings.Append(moduleName, cmd);
    Strings.Append(".c",       cmd);
    execute("C compile: ", cmd);
  END Assemble;


PROCEDURE LinkMain*(VAR moduleName: ARRAY OF CHAR; statically: BOOLEAN; additionalopts: ARRAY OF CHAR);
  VAR
    cmd: CommandString;
  BEGIN
    InitialiseCompilerCommand(cmd);
    Strings.Append(moduleName,                   cmd);
    Strings.Append(".c ",                        cmd);
    Strings.Append(additionalopts,               cmd);
    IF statically THEN
      IF Configuration.os = "darwin" THEN
        Strings.Append(OPM.InstallDir,           cmd);
        Strings.Append('/lib/lib',               cmd);
        Strings.Append(Configuration.name,       cmd);
        Strings.Append('-O',                     cmd);
        Strings.Append(OPM.Model,                cmd);
        Strings.Append('.a',                     cmd);
      ELSE
        Strings.Append(Configuration.staticLink, cmd)
      END
    END;
    Strings.Append(Configuration.objflag,        cmd);
    Strings.Append(moduleName,                   cmd);
    IF (~statically) OR ~(Configuration.os = "darwin") THEN
      Strings.Append(Configuration.linkflags,      cmd);
      Strings.Append(OPM.InstallDir,               cmd);
      Strings.Append('/lib"',                      cmd);
      Strings.Append(Configuration.libspec,        cmd);
      Strings.Append('-O',                         cmd);
      Strings.Append(OPM.Model,                    cmd);
      Strings.Append(Configuration.libext,         cmd)
    END;
    execute("C compile and link: ", cmd);

    IF (Configuration.os = "darwin") & ~statically THEN
      (* Darwin requires an extra command to set the library directory into the binary *)
      cmd := "install_name_tool -change lib";
      Strings.Append(Configuration.name,   cmd);
      Strings.Append('-O',                 cmd);
      Strings.Append(OPM.Model,            cmd);
      Strings.Append('.dylib "',           cmd);
      Strings.Append(OPM.InstallDir,       cmd);
      Strings.Append('/lib/lib',           cmd);
      Strings.Append(Configuration.name,   cmd);
      Strings.Append('-O',                 cmd);
      Strings.Append(OPM.Model,            cmd);
      Strings.Append('.dylib" ',           cmd);
      Strings.Append(moduleName,           cmd);
      execute("Set library directory: ",   cmd)
    END
  END LinkMain;


END extTools.
