MODULE TestWriter;
IMPORT Out, Texts;
VAR
  T: Texts.Text;
  W: Texts.Writer;
  R: Texts.Reader;
BEGIN
  NEW(T); Texts.Open(T, 'MYTEXT.TXT');
  Texts.OpenWriter(W);
  Texts.WriteString(W, 'HELLO'); Texts.WriteLn(W);
  Texts.Append(T, W.buf);
  Texts.Close(T)
END TestWriter.