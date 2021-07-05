MODULE newttest2;

IMPORT newt, oocIntStr;
VAR i, j, k : newt.Int32;
str : ARRAY 32 OF CHAR;
form, b1, b2, comp: newt.Component;
BEGIN
i := newt.Init();
newt.Cls();

str := "hello world!";
i := newt.OpenWindow(10, 5, 40, 6, "Button Sample");

b1 := newt.Button(10, 1, "OK");
b2 := newt.CompactButton(22, 2, "Cancel");


form := newt.Form(NIL, "aaa", 0);
newt.FormAddComponent(form, b1);
newt.FormAddComponent(form, b2);
comp := newt.RunForm(form);
newt.WaitForKey();
newt.Delay(3000);
newt.FormDestroy(form);
i := newt.Finished();
END newttest2.
