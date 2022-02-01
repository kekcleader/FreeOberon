MODULE TestWriter;
IMPORT Out, Texts;
VAR
  T: Texts.Text;
  W: Texts.Writer;
  R: Texts.Reader;
BEGIN
  NEW(T); Texts.Open(T, 'MYTEXT.TXT');
  Texts.OpenWriter(W);
  Texts.WriteString(W, 'HELLO');
  Texts.WriteLn(W);
  Texts.WriteString(W, 'WORLD');
  Texts.WriteInt(W, 1512, 6);
  Texts.Write(W, '*');
  Texts.WriteInt(W, -1512, 6);
  Texts.Write(W, '*');
  Texts.WriteLn(W);
  Texts.Insert(T, 17, W.buf);
  Texts.Close(T)
END TestWriter.