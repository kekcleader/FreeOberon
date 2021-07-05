MODULE beep;
IMPORT Files, rm:=oocRealMath, Platform;

CONST pi2=6.28318;
(*pi2 = 6.2831802368164062;*)
rate=44.1E3;
lf=20.0;
seconds=2.0;

VAR t,a,b,freq,xkm1,ykm1,est,gf:REAL; 
    i,e:LONGINT;
    ai:INTEGER;
    outvar: Files.File;
    outfile: Files.Rider;
    first: BOOLEAN;

PROCEDURE highpass(t,fhp,xk:REAL;VAR yk:REAL);
BEGIN
IF first THEN 
   est:=rm.exp(-pi2*fhp*t);
   gf:=(1+est)/(1-est);first:=FALSE; 
END(*IF*);

yk:=(xk-xkm1)/2;
xkm1:=xk; 
xk:=yk;
yk:=est*ykm1+(1-est)*xk;
ykm1:=yk;
yk:=gf*yk;
END highpass;

BEGIN
t:=1.0/rate; xkm1:=0.0; ykm1:=0.0; first:=TRUE;

outvar:=Files.New("beepfile");
IF outvar # NIL THEN
   Files.Set(outfile, outvar, 0);
ELSE
   HALT(1)
END;

e:=ENTIER(rate*seconds);freq:=1000;

FOR i:=1 TO e DO
   a:=3000*rm.sin(pi2*freq*i/rate);
(*   highpass(t,lf,a,b);*)
(*   ai:=SHORT(ENTIER(b));*)
   ai:=SHORT(ENTIER(a));
   IF i>ENTIER(rate*10/lf)THEN
      Files.WriteInt(outfile, ai);;
   END;
END;

Files.Register(outvar);
i:=Platform.System("oggenc -r -C 1 beepfile");
i:=Platform.System("ogg123 beepfile.ogg");
END beep.

