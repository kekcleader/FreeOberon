MODULE s;

IMPORT sockets, types, Out := Console, SYSTEM, Platform, Strings;


PROCEDURE DoSmth(sock: Platform.FileHandle);
VAR 
  str, aff: ARRAY 256 OF CHAR;
  n:   LONGINT;
BEGIN
  aff := "Affirmative, Dave";
(*  IF Platform.Read(sock, SYSTEM.ADR(str), 256, n) # 0 THEN *)
  IF Platform.ReadBuf(sock, str, n) # 0 THEN
    Out.String("error reading from socket"); Out.Ln;
  ELSE
    str[n] := 0X; (* Make sure that received message is zero terminated *)
    Out.String("received message is "); Out.String(str); Out.Ln;
    
    IF Platform.Write(sock, SYSTEM.ADR(aff), Strings.Length(aff)) # 0 THEN
      Out.String("error writing to socket"); Out.Ln
    END;
  END;
END DoSmth;



PROCEDURE -includeunistd "#include <unistd.h>";
PROCEDURE -fork(): LONGINT "(LONGINT)fork()";


PROCEDURE serve;
CONST  
  Port     = 2055;
  MaxQueue = 5;
VAR 
  sockfd:      LONGINT;
  newsockfd:   LONGINT;
  ServAddr:    sockets.SockAddrIn;
  pid:         LONGINT;
  res:         Platform.ErrorCode;
  sockaddrlen: LONGINT;
BEGIN
  sockfd := sockets.Socket(sockets.AfInet, sockets.SockStream, 0);
  IF sockfd < 0 THEN
    Out.String("error opening socket")
  ELSE
    Out.String("socket created.")
  END;
  Out.Ln;

  sockets.SetSockAddrIn(sockets.AfInet, Port, 0, ServAddr);
  IF sockets.Bind(sockfd, SYSTEM.VAL(sockets.SockAddr, ServAddr), SIZE(sockets.SockAddr)) < 0 THEN
    Out.String("error on binding")
  ELSE
    Out.String("binding completed.")
  END;
  Out.Ln;
    
  IF sockets.Listen(sockfd, MaxQueue) # 0 THEN
    Out.String("listen() failed");
  ELSE
    Out.String("listen okay");
  END;
  Out.Ln;

  LOOP
    sockaddrlen := SIZE(sockets.SockAddrIn);
    newsockfd := sockets.Accept(sockfd, SYSTEM.VAL(sockets.SockAddr, ServAddr), sockaddrlen);
    IF newsockfd < 0 THEN
      Out.String("error on accept")
    ELSE
      Out.String("accept okay")
    END;
    Out.Ln;

    pid := fork();
    IF pid < 0 THEN
      Out.String("error on fork")
    ELSIF pid = 0 THEN
      Out.String("forked okay"); Out.Ln;
      res := Platform.Close(sockfd);
      DoSmth(newsockfd);
      EXIT
    ELSE
      res := Platform.Close(newsockfd)
    END
  END
END serve;


BEGIN

serve;

END s.
