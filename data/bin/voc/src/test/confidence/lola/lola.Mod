MODULE Lola; (* Command line runner for Lola to verilog compilation *)
  IMPORT LSB, LSC, LSV, Modules, Console;
BEGIN
  IF Modules.ArgCount < 3 THEN
    Console.String("Lola - compile lola source to verilog source."); Console.Ln; Console.Ln;
    Console.String("usage:"); Console.Ln; Console.Ln;
    Console.String("  lola lola-source-file verilog-source-file"); Console.Ln; Console.Ln;
  ELSE
    LSC.Compile;
    IF LSB.modname # "" THEN LSV.List END
  END
END Lola.
