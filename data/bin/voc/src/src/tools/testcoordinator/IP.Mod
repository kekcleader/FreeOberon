MODULE IP;

IMPORT SYSTEM, Platform, Console;

CONST
  FDcount- = 1024;  (* Number of FDs in FD set *)

TYPE
  SocketAddress* = RECORD
                    length-: LONGINT;
                    buf:     ARRAY 28 OF SYSTEM.BYTE;        (* Sufficient for IPv4 and IPv6. *)
                   END;
  FDset*         = ARRAY 128 OF SYSTEM.BYTE;    (* Exposes C fd_set *)

  InAddr     = POINTER TO InAddrDesc;
  InAddrDesc = RECORD
                 addr: ARRAY 128 OF SYSTEM.BYTE;
                 next: InAddr
               END;

VAR
  v4-:       LONGINT;  (* AF_INET  *)
  v6-:       LONGINT;  (* AF_INET6 *)
  Stream-:   LONGINT;  (* SOCK_STREAM *)
  Datagram-: LONGINT;  (* SOCK_DGRAM *)


  (* Testing *)

  addr: InAddr;
  err:  Platform.ErrorCode;


  PROCEDURE -AAincludetypes  "#include <sys/types.h>";
  PROCEDURE -AAincludetime   "#include <sys/time.h>";
  PROCEDURE -AAincludesocket "#include <sys/socket.h>";
  PROCEDURE -AAincludeselect "#include <sys/select.h>";
  PROCEDURE -AAincludenetdb  "#include <netdb.h>";


  PROCEDURE -AICANONNAME  (): LONGINT "AI_CANONNAME";
  PROCEDURE -AIPASSIVE    (): LONGINT "AI_PASSIVE  ";
  PROCEDURE -AFUNSPEC     (): LONGINT "AF_UNSPEC";
  PROCEDURE -AFINET       (): LONGINT "AF_INET";
  PROCEDURE -AFINET6      (): LONGINT "AF_INET6";
  PROCEDURE -SOCKSTREAM   (): LONGINT "SOCK_STREAM";
  PROCEDURE -SOCKDGRAM    (): LONGINT "SOCK_DGRAM";
  PROCEDURE -NINUMERICHOST(): LONGINT "NI_NUMERICHOST";
  PROCEDURE -NINUMERICSERV(): LONGINT "NI_NUMERICSERV";
  PROCEDURE -EAISYSTEM    (): LONGINT "EAI_SYSTEM";
  PROCEDURE -EAIFAIL      (): LONGINT "EAI_FAIL";


(* Console output convenience APIs *)

  PROCEDURE cs (s: ARRAY OF CHAR); BEGIN Console.String(s) END cs;
  PROCEDURE csl(s: ARRAY OF CHAR); BEGIN Console.String(s); Console.Ln END csl;
  PROCEDURE ci (i,w: LONGINT);     BEGIN Console.Int(i,w) END ci;
  PROCEDURE ch (i: LONGINT);       BEGIN Console.Hex(i) END ch;
  PROCEDURE cc (c: CHAR);          BEGIN Console.Char(c) END cc;
  PROCEDURE cl ();                 BEGIN Console.Ln END cl;
  PROCEDURE hex(i: INTEGER): CHAR;
  BEGIN IF i < 10 THEN RETURN CHR(i+48) ELSE RETURN CHR(i+55) END END hex;
  PROCEDURE cb (b: SYSTEM.BYTE);
  VAR v: INTEGER;
  BEGIN
    v := SYSTEM.VAL(INTEGER, b); cc(hex(v DIV 16)); cc(hex(v MOD 16));
  END cb;


  PROCEDURE -getnameinfo(sa, salen, flags: LONGINT; VAR host, serv: ARRAY OF CHAR): INTEGER
    "(INTEGER)getnameinfo((const struct sockaddr*)sa, salen, host, host__len, serv, serv__len, flags)";

  PROCEDURE WriteSocketAddress*(s: SocketAddress);
  VAR host, service: ARRAY 4096 OF CHAR; IPv6: BOOLEAN;
  BEGIN
    IPv6 := s.length > 20;  (* IPv4 len = 16, IPv6 len = 28 *)
    IF getnameinfo(SYSTEM.ADR(s.buf), s.length, NINUMERICHOST(), host, service) >= 0 THEN
      IF IPv6 THEN cc('[') END;  cs(host);  IF IPv6 THEN cs("]:") ELSE cc(':') END;
      cs(service)
    END
  END WriteSocketAddress;

  PROCEDURE SameAddress*(s1, s2: SocketAddress): BOOLEAN;
  (* True if same IP address, independent of port number *)
  VAR host1, host2, service: ARRAY 4096 OF CHAR; i: INTEGER; result: BOOLEAN;
  BEGIN
    result := getnameinfo(SYSTEM.ADR(s1.buf), s1.length, NINUMERICHOST(), host1, service) >= 0;
    IF result THEN result := getnameinfo(SYSTEM.ADR(s2.buf), s2.length, NINUMERICHOST(), host2, service) >= 0 END;
    cs("host1: '"); cs(host1); cs("', host2: '"); cs(host2); csl("'.");
    IF result THEN
      i := 0;
      WHILE (host1[i] # 0X) & (host2[i] # 0X) & (host1[i] = host2[i]) DO INC(i) END;
      result := host1[i] = host2[i]
    END;
    RETURN result;
  END SameAddress;

  PROCEDURE -aiFlags     (p: LONGINT): LONGINT "(LONGINT)((struct addrinfo*)p)->ai_flags";
  PROCEDURE -aiFamily    (p: LONGINT): LONGINT "(LONGINT)((struct addrinfo*)p)->ai_family";
  PROCEDURE -aiSocketType(p: LONGINT): LONGINT "(LONGINT)((struct addrinfo*)p)->ai_socktype";
  PROCEDURE -aiProtocol  (p: LONGINT): LONGINT "(LONGINT)((struct addrinfo*)p)->ai_protocol";
  PROCEDURE -aiAddrLen   (p: LONGINT): LONGINT "(LONGINT)((struct addrinfo*)p)->ai_addrlen";
  PROCEDURE -aiSockAddr  (p: LONGINT): LONGINT "(LONGINT)((struct addrinfo*)p)->ai_addr";
  PROCEDURE -aiCanonName (p: LONGINT): LONGINT "(LONGINT)((struct addrinfo*)p)->ai_canonname";
  PROCEDURE -aiNext      (p: LONGINT): LONGINT "(LONGINT)((struct addrinfo*)p)->ai_next";


  PROCEDURE -caddrinfo(family, socktype, protocol, flags: LONGINT) "struct addrinfo ai={flags,family,socktype,protocol,0}";
  PROCEDURE -caddrinfoptr "struct addrinfo *pai";
  PROCEDURE -getaddrinfo(host, service: LONGINT): INTEGER
    "(INTEGER)getaddrinfo((char*)host, (char*)service, &ai, &pai)";
  PROCEDURE -pai(): LONGINT "(LONGINT)pai";
  PROCEDURE -freeaddrinfo(addrinfo: LONGINT) "freeaddrinfo((struct addrinfo*)addrinfo)";


  (* To get a local receiving address, past host as an empty string. *)
  PROCEDURE Lookup*(host, service: ARRAY OF CHAR; family, socktype: LONGINT; VAR addr: SocketAddress): Platform.ErrorCode;
  VAR addrinfo, hostptr, flags: LONGINT; result: Platform.ErrorCode;
  BEGIN
    IF host[0] = 0X THEN
      hostptr := 0; flags := AIPASSIVE();
    ELSE
      hostptr := SYSTEM.ADR(host); flags := 0;
    END;
    caddrinfo(family, socktype, 0, flags);
    caddrinfoptr;
    result := getaddrinfo(hostptr, SYSTEM.ADR(service));
    IF result = EAISYSTEM() THEN RETURN Platform.Error() END;
    (* Return getaddrinfo specific reslts as negative numbers to avoid clash with OS error codes. *)
    IF result # 0 THEN RETURN -ABS(result) END;

    addrinfo := pai(); addr.length := aiAddrLen(addrinfo);
    IF (addrinfo = 0) OR (addr.length <= 0) THEN RETURN SHORT(-ABS(EAIFAIL())) END;

    ASSERT(addr.length <= LEN(addr.buf));
    SYSTEM.MOVE(aiSockAddr(addrinfo), SYSTEM.ADR(addr.buf), addr.length);

    freeaddrinfo(addrinfo);

    RETURN result;
  END Lookup;




  PROCEDURE -socket(domain, type, protocol: LONGINT): LONGINT
    "(LONGINT)socket((int)domain, (int)type, (int)protocol)";

  PROCEDURE Socket*(domain, type: LONGINT; VAR fd: LONGINT): Platform.ErrorCode;
  BEGIN
    fd := socket(domain, type, 0); (* No supported domain needs a non-zero protocol *)
    IF fd < 0 THEN RETURN Platform.Error() END;
    RETURN 0;
  END Socket;




  PROCEDURE -bind(sockfd: LONGINT; addr, addrlen: LONGINT): INTEGER
    "(INTEGER)bind((int)sockfd, (const struct sockaddr*)addr, (socklen_t)addrlen)";

  PROCEDURE Bind*(sockfd: LONGINT; address: SocketAddress): Platform.ErrorCode;
  BEGIN
    IF bind(sockfd, SYSTEM.ADR(address.buf), address.length) < 0 THEN RETURN Platform.Error() END;
    RETURN 0;
  END Bind;




  PROCEDURE -listen(sockfd, backlog: LONGINT): INTEGER
    "(INTEGER)listen((int)sockfd, (int)backlog)";

  PROCEDURE Listen*(sockfd, backlog: LONGINT): INTEGER;
  BEGIN RETURN listen(sockfd, backlog)
  END Listen;




  PROCEDURE -accept(sockfd: LONGINT; addr, addrlen: LONGINT): LONGINT
    "(LONGINT)accept((int)sockfd, (struct sockaddr*)addr, (socklen_t*)addrlen)";

  PROCEDURE Accept*(sockfd: LONGINT; VAR address: SocketAddress; VAR newfd: LONGINT): Platform.ErrorCode;
  BEGIN
    address.length := LEN(address.buf);
    newfd := accept(sockfd, SYSTEM.ADR(address.buf), SYSTEM.ADR(address.length));
    IF newfd < 0 THEN RETURN Platform.Error() END;
    RETURN 0
  END Accept;




  PROCEDURE -connect(sockfd, addr, length: LONGINT): INTEGER
    "(INTEGER)connect((int)sockfd, (struct sockaddr*)addr, (socklen_t)length)";

  PROCEDURE Connect*(sockfd: LONGINT; addr: SocketAddress): Platform.ErrorCode;
  BEGIN
    IF connect(sockfd, SYSTEM.ADR(addr.buf), addr.length) < 0 THEN RETURN Platform.Error() END;
    RETURN 0;
  END Connect;




  PROCEDURE -recvfrom(sockfd, buf, buflen, flags, saddr: LONGINT; socklen: LONGINT): INTEGER
    "(INTEGER)recvfrom((int)sockfd, (void*)buf, (size_t)buflen, (int)flags, (struct sockaddr*)saddr, (socklen_t*)socklen)";

  PROCEDURE ReceiveFrom*(
    sockfd: LONGINT;
    VAR buf: ARRAY OF SYSTEM.BYTE; VAR length: LONGINT;
    flags: LONGINT;
    VAR sockaddr: SocketAddress
  ): Platform.ErrorCode;
  BEGIN
    sockaddr.length := LEN(sockaddr.buf);
    length := recvfrom(
      sockfd,
      SYSTEM.ADR(buf), LEN(buf),
      flags,
      SYSTEM.ADR(sockaddr.buf), SYSTEM.ADR(sockaddr.length)
    );
    IF length < 0 THEN RETURN Platform.Error() END;
    RETURN 0;
  END ReceiveFrom;



  PROCEDURE -sendto(sockfd, buf, len, flags, addr, addrlen: LONGINT): LONGINT
    "(LONGINT)sendto((int)sockfd, (void*)buf, (size_t)len, (int)flags, (struct sockaddr*)addr, (socklen_t)addrlen)";

  PROCEDURE SendTo*(sockfd: LONGINT; VAR buf: ARRAY OF SYSTEM.BYTE; buflen, flags: LONGINT; addr: SocketAddress): Platform.ErrorCode;
  BEGIN
    IF sendto(sockfd, SYSTEM.ADR(buf), buflen, flags, SYSTEM.ADR(addr.buf), addr.length) < 0 THEN
      RETURN Platform.Error()
    ELSE
      RETURN 0
    END
  END SendTo;




  PROCEDURE -FDZERO(VAR fds: FDset) "FD_ZERO((fd_set*)fds)";
  PROCEDURE ZeroFDs*(VAR fds: FDset); BEGIN FDZERO(fds) END ZeroFDs;

  PROCEDURE -FDCLR(i: LONGINT; VAR fds: FDset) "FD_CLR((int)i, (fd_set*)fds)";
  PROCEDURE ClearFD*(i: LONGINT; VAR fds: FDset); BEGIN FDCLR(i, fds) END ClearFD;

  PROCEDURE -FDSET(i: LONGINT; VAR fds: FDset) "FD_SET((int)i, (fd_set*)fds)";
  PROCEDURE SetFD*(i: LONGINT; VAR fds: FDset); BEGIN FDSET(i, fds) END SetFD;

  PROCEDURE -FDISSET(i: LONGINT; VAR fds: FDset): INTEGER "(INTEGER)FD_ISSET((int)i, (fd_set*)fds)";
  PROCEDURE FDisSet*(i: LONGINT; VAR fds: FDset): BOOLEAN;
  BEGIN RETURN FDISSET(i, fds) # 0 END FDisSet;

  PROCEDURE -SizeofFdSet(): LONGINT "(LONGINT)sizeof(fd_set)";


  PROCEDURE -timeval(ms: LONGINT) "struct timeval tv = {ms/1000, (ms%1000)*1000}";
  PROCEDURE -select(socketLimit: LONGINT; VAR read, write, except: FDset): LONGINT
    "select((int)socketLimit, (fd_set*)read, (fd_set*)write, (fd_set*)except, &tv)";

  PROCEDURE Select*(socketLimit: LONGINT; VAR read, write, except: FDset; ms: LONGINT; VAR readycount: LONGINT): Platform.ErrorCode;
  BEGIN
    timeval(ms);
    readycount := select(socketLimit, read, write, except);
    IF readycount < 0 THEN readycount := 0; RETURN Platform.Error() END;
    RETURN 0
  END Select;




BEGIN
  ASSERT(SIZE(FDset) >= SizeofFdSet());
  v4       := AFINET();
  v6       := AFINET6();
  Stream   := SOCKSTREAM();
  Datagram := SOCKDGRAM();
END IP.
