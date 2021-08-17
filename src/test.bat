@CLS
@CALL make
@IF ERRORLEVEL 1 GOTO ERR
@CD..
FreeOberon --window
@CD src
@GOTO QUIT
:ERR
@EXIT/B 1
:QUIT
