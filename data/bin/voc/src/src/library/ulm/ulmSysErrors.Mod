MODULE ulmSysErrors;

   IMPORT Errors := ulmErrors, Events := ulmEvents, Priorities := ulmPriorities, RelatedEvents := ulmRelatedEvents, Streams := ulmStreams, Strings := ulmStrings, Sys := ulmSys, Types := ulmTypes;

   CONST
      perm*		= 1;
      noent*		= 2;
      srch*		= 3;
      intr*		= 4;
      io*		= 5;
      nxio*		= 6;
      toobig*		= 7;
      noexec*		= 8;
      badf*		= 9;
      child*		= 10;
      again*		= 11;
      nomem*		= 12;
      acces*		= 13;
      fault*		= 14;
      notblk*		= 15;
      busy*		= 16;
      exist*		= 17;
      xdev*		= 18;
      nodev*		= 19;
      notdir*		= 20;
      isdir*		= 21;
      inval*		= 22;
      nfile*		= 23;
      mfile*		= 24;
      notty*		= 25;
      txtbsy*		= 26;
      fbig*		= 27;
      nospc*		= 28;
      spipe*		= 29;
      rofs*		= 30;
      mlink*		= 31;
      pipe*		= 32;
      dom*		= 33;
      range*		= 34;
      deadlk*		= 35;
      nametoolong*	= 36;
      nolck*		= 37;
      nosys*		= 38;
      notempty*		= 39;
      loop*		= 40;
      wouldblock*	= again;
      nomsg*		= 42;
      idrm*		= 43;
      chrng*		= 44;
      l2nsync*		= 45;
      l3hlt*		= 46;
      l3rst*		= 47;
      lnrng*		= 48;
      unatch*		= 49;
      nocsi*		= 50;
      l2hlt*		= 51;
      bade*		= 52;
      badr*		= 53;
      xfull*		= 54;
      noano*		= 55;
      badrqc*		= 56;
      badslt*		= 57;
      deadlock*		= deadlk;
      bfont*		= 59;
      nostr*		= 60;
      nodata*		= 61;
      time*		= 62;
      nosr*		= 63;
      nonet*		= 64;
      nopkg*		= 65;
      remote*		= 66;
      nolink*		= 67;
      adv*		= 68;
      srmnt*		= 69;
      comm*		= 70;
      proto*		= 71;
      multihop*		= 72;
      dotdot*		= 73;
      badmsg*		= 74;
      overflow*		= 75;
      notuniq*		= 76;
      badfd*		= 77;
      remchg*		= 78;
      libacc*		= 79;
      libbad*		= 80;
      libscn*		= 81;
      libmax*		= 82;
      libexec*		= 83;
      ilseq*		= 84;
      restart*		= 85;
      strpipe*		= 86;
      users*		= 87;
      notsock*		= 88;
      destaddrreq*	= 89;
      msgsize*		= 90;
      prototype*		= 91;
      noprotoopt*	= 92;
      protonosupport*	= 93;
      socktnosupport*	= 94;
      opnotsupp*		= 95;
      pfnosupport*	= 96;
      afnosupport*	= 97;
      addrinuse*		= 98;
      addrnotavail*	= 99;
      netdown*		= 100;
      netunreach*	= 101;
      netreset*		= 102;
      connaborted*	= 103;
      connreset*		= 104;
      nobufs*		= 105;
      isconn*		= 106;
      notconn*		= 107;
      shutdown*		= 108;
      toomanyrefs*	= 109;
      timedout*		= 110;
      connrefused*	= 111;
      hostdown*		= 112;
      hostunreach*	= 113;
      already*		= 114;
      inprogress*	= 115;
      stale*		= 116;
      uclean*		= 117;
      notnam*		= 118;
      navail*		= 119;
      isnam*		= 120;
      remoteio*		= 121;
      dquot*		= 122;
      nomedium*		= 123;
      mediumtype*	= 124;

      ncodes*         = 126;   (* number of error codes *)
      
      textlen* = 512;

   TYPE
      Name* = ARRAY 20 OF CHAR;
      Event* = POINTER TO EventRec;
      EventRec* =
	 RECORD
	    (Events.EventRec)
	    errno*: (*Types.Int32*)Types.Int32;
	    syscall*: (*Types.Int32*)Types.Int32; (* number of system call *)
	    text*: ARRAY textlen OF CHAR;
	 END;

   VAR
      message*: ARRAY ncodes OF Events.Message;
      name*: ARRAY ncodes OF Name;
      syserrors*: Events.EventType;
      syserror*: ARRAY ncodes OF Events.EventType;

   PROCEDURE Raise*(errors: RelatedEvents.Object;
		   errno, syscall: (*Types.Int32*)Types.Int32; text: ARRAY OF CHAR); (* in ulm's system Types.Int32 and Types.Int32 have the same size *)
      (* raises the events syserrors and syserrors[syscall];
	 `text' contains additional information (e.g. filenames);
	 further, the syserrors[syscall] event is passed to
	 RelatedEvents if object # NIL
      *)
      VAR
	 event: Event;

      PROCEDURE InitEvent(VAR event: Event; type: Events.EventType);
      BEGIN
	 NEW(event);
	 event.type := type;
	 event.message := message[errno];
	 event.errno := errno;
	 event.syscall := syscall;
	 COPY(text, event.text);
      END InitEvent;

   BEGIN
      IF (errno > 0) & (errno < ncodes) THEN
	 InitEvent(event, syserrors); Events.Raise(event);
	 InitEvent(event, syserror[errno]); Events.Raise(event);
	 IF errors # NIL THEN
	    InitEvent(event, syserrors);
	    RelatedEvents.Raise(errors, event);
	 END;
      END;
   END Raise;

   PROCEDURE Write(s: Streams.Stream; event: Events.Event);

      PROCEDURE WriteString(txt: ARRAY OF CHAR);
      BEGIN
	 IF ~Streams.WritePart(s, txt, 0, Strings.Len(txt)) THEN END;
      END WriteString;

      PROCEDURE Write(ch: CHAR);
      BEGIN
	 IF ~Streams.WriteByte(s, ch) THEN END;
      END Write;

      PROCEDURE WriteInt(intval: Types.Int32);
	 VAR
	    rest: Types.Int32;
      BEGIN
	 rest := intval DIV 10;
	 IF rest > 0 THEN
	    WriteInt(rest);
	 END;
	 Write(CHR(ORD("0") + intval MOD 10));
      END WriteInt;

   BEGIN
      IF event IS Event THEN
	 WITH event: Event DO
	    IF event.text[0] # 0X THEN
	       WriteString(event.text);
	       WriteString(": ");
	    END;
	    IF event.errno = 0 THEN
	       WriteString("no error (");
	       WriteString(Sys.name[event.syscall]); Write(")");
	    ELSIF (event.errno >= ncodes) OR (message[event.errno][0] = 0X) THEN
	       WriteString("unknown error (");
	       WriteString(Sys.name[event.syscall]);
	       WriteString(": "); WriteInt(event.errno); Write(")");
	    ELSE
	       WriteString(message[event.errno]);
	       WriteString(" (");
	       WriteString(Sys.name[event.syscall]); WriteString(": ");
	       WriteString(name[event.errno]); Write(")");
	    END;
	 END;
      ELSE
	 WriteString(event.message);
      END;
   END Write;

   PROCEDURE InitEvents;
      VAR
	 errno: Types.Int32;
   BEGIN
      syserror[0] := NIL;
      errno := 1;
      WHILE errno < ncodes DO
	 Events.Define(syserror[errno]);
	 Events.Ignore(syserror[errno]);
	 Events.SetPriority(syserror[errno], Priorities.syserrors);
	 INC(errno);
      END;
      Events.Define(syserrors);
      Events.Ignore(syserrors);
      Events.SetPriority(syserrors, Priorities.syserrors);
      Errors.AssignWriteProcedure(syserrors, Write);
   END InitEvents;

BEGIN
   InitEvents;
   name[perm] := "EPERM";
   message[perm] := "Operation not permitted";
   name[noent] := "ENOENT";
   message[noent] := "No such file or directory";
   name[srch] := "ESRCH";
   message[srch] := "No such process";
   name[intr] := "EINTR";
   message[intr] := "Interrupted system call";
   name[io] := "EIO";
   message[io] := "I/O error";
   name[nxio] := "ENXIO";
   message[nxio] := "No such device or address";
   name[toobig] := "E2BIG";
   message[toobig] := "Arg list too long";
   name[noexec] := "ENOEXEC";
   message[noexec] := "Exec format error";
   name[badf] := "EBADF";
   message[badf] := "Bad file number";
   name[child] := "ECHILD";
   message[child] := "No child processes";
   name[again] := "EAGAIN";
   message[again] := "Try again";
   name[nomem] := "ENOMEM";
   message[nomem] := "Out of memory";
   name[acces] := "EACCES";
   message[acces] := "Permission denied";
   name[fault] := "EFAULT";
   message[fault] := "Bad address";
   name[notblk] := "ENOTBLK";
   message[notblk] := "Block device required";
   name[busy] := "EBUSY";
   message[busy] := "Device or resource busy";
   name[exist] := "EEXIST";
   message[exist] := "File exists";
   name[xdev] := "EXDEV";
   message[xdev] := "Cross-device link";
   name[nodev] := "ENODEV";
   message[nodev] := "No such device";
   name[notdir] := "ENOTDIR";
   message[notdir] := "Not a directory";
   name[isdir] := "EISDIR";
   message[isdir] := "Is a directory";
   name[inval] := "EINVAL";
   message[inval] := "Invalid argument";
   name[nfile] := "ENFILE";
   message[nfile] := "File table overflow";
   name[mfile] := "EMFILE";
   message[mfile] := "Too many open files";
   name[notty] := "ENOTTY";
   message[notty] := "Not a typewriter";
   name[txtbsy] := "ETXTBSY";
   message[txtbsy] := "Text file busy";
   name[fbig] := "EFBIG";
   message[fbig] := "File too large";
   name[nospc] := "ENOSPC";
   message[nospc] := "No space left on device";
   name[spipe] := "ESPIPE";
   message[spipe] := "Illegal seek";
   name[rofs] := "EROFS";
   message[rofs] := "Read-only file system";
   name[mlink] := "EMLINK";
   message[mlink] := "Too many links";
   name[pipe] := "EPIPE";
   message[pipe] := "Broken pipe";
   name[dom] := "EDOM";
   message[dom] := "Math argument out of domain of func";
   name[range] := "ERANGE";
   message[range] := "Math result not representable";
   name[deadlk] := "EDEADLK";
   message[deadlk] := "Resource deadlock would occur";
   name[nametoolong] := "ENAMETOOLONG";
   message[nametoolong] := "File name too long";
   name[nolck] := "ENOLCK";
   message[nolck] := "No record locks available";
   name[nosys] := "ENOSYS";
   message[nosys] := "Function not implemented";
   name[notempty] := "ENOTEMPTY";
   message[notempty] := "Directory not empty";
   name[loop] := "ELOOP";
   message[loop] := "Too many symbolic links encountered";
   name[nomsg] := "ENOMSG";
   message[nomsg] := "No message of desired type";
   name[idrm] := "EIDRM";
   message[idrm] := "Identifier removed";
   name[chrng] := "ECHRNG";
   message[chrng] := "Channel number out of range";
   name[l2nsync] := "EL2NSYNC";
   message[l2nsync] := "Level 2 not synchronized";
   name[l3hlt] := "EL3HLT";
   message[l3hlt] := "Level 3 halted";
   name[l3rst] := "EL3RST";
   message[l3rst] := "Level 3 reset";
   name[lnrng] := "ELNRNG";
   message[lnrng] := "Link number out of range";
   name[unatch] := "EUNATCH";
   message[unatch] := "Protocol driver not attached";
   name[nocsi] := "ENOCSI";
   message[nocsi] := "No CSI structure available";
   name[l2hlt] := "EL2HLT";
   message[l2hlt] := "Level 2 halted";
   name[bade] := "EBADE";
   message[bade] := "Invalid exchange";
   name[badr] := "EBADR";
   message[badr] := "Invalid request descriptor";
   name[xfull] := "EXFULL";
   message[xfull] := "Exchange full";
   name[noano] := "ENOANO";
   message[noano] := "No anode";
   name[badrqc] := "EBADRQC";
   message[badrqc] := "Invalid request code";
   name[badslt] := "EBADSLT";
   message[badslt] := "Invalid slot";
   name[bfont] := "EBFONT";
   message[bfont] := "Bad font file format";
   name[nostr] := "ENOSTR";
   message[nostr] := "Device not a stream";
   name[nodata] := "ENODATA";
   message[nodata] := "No data available";
   name[time] := "ETIME";
   message[time] := "Timer expired";
   name[nosr] := "ENOSR";
   message[nosr] := "Out of streams resources";
   name[nonet] := "ENONET";
   message[nonet] := "Machine is not on the network";
   name[nopkg] := "ENOPKG";
   message[nopkg] := "Package not installed";
   name[remote] := "EREMOTE";
   message[remote] := "Object is remote";
   name[nolink] := "ENOLINK";
   message[nolink] := "Link has been severed";
   name[adv] := "EADV";
   message[adv] := "Advertise error";
   name[srmnt] := "ESRMNT";
   message[srmnt] := "Srmount error";
   name[comm] := "ECOMM";
   message[comm] := "Communication error on send";
   name[proto] := "EPROTO";
   message[proto] := "Protocol error";
   name[multihop] := "EMULTIHOP";
   message[multihop] := "Multihop attempted";
   name[dotdot] := "EDOTDOT";
   message[dotdot] := "RFS specific error";
   name[badmsg] := "EBADMSG";
   message[badmsg] := "Not a data message";
   name[overflow] := "EOVERFLOW";
   message[overflow] := "Value too large for defined data type";
   name[notuniq] := "ENOTUNIQ";
   message[notuniq] := "Name not unique on network";
   name[badfd] := "EBADFD";
   message[badfd] := "File descriptor in bad state";
   name[remchg] := "EREMCHG";
   message[remchg] := "Remote address changed";
   name[libacc] := "ELIBACC";
   message[libacc] := "Can not access a needed shared library";
   name[libbad] := "ELIBBAD";
   message[libbad] := "Accessing a corrupted shared library";
   name[libscn] := "ELIBSCN";
   message[libscn] := ".lib section in a.out corrupted";
   name[libmax] := "ELIBMAX";
   message[libmax] := "Attempting to link in too many shared libraries";
   name[libexec] := "ELIBEXEC";
   message[libexec] := "Cannot exec a shared library directly";
   name[ilseq] := "EILSEQ";
   message[ilseq] := "Illegal byte sequence";
   name[restart] := "ERESTART";
   message[restart] := "Interrupted system call should be restarted";
   name[strpipe] := "ESTRPIPE";
   message[strpipe] := "Streams pipe error";
   name[users] := "EUSERS";
   message[users] := "Too many users";
   name[notsock] := "ENOTSOCK";
   message[notsock] := "Socket operation on non-socket";
   name[destaddrreq] := "EDESTADDRREQ";
   message[destaddrreq] := "Destination address required";
   name[msgsize] := "EMSGSIZE";
   message[msgsize] := "Message too long";
   name[prototype] := "EPROTOTYPE";
   message[prototype] := "Protocol wrong type for socket";
   name[noprotoopt] := "ENOPROTOOPT";
   message[noprotoopt] := "Protocol not available";
   name[protonosupport] := "EPROTONOSUPPORT";
   message[protonosupport] := "Protocol not supported";
   name[socktnosupport] := "ESOCKTNOSUPPORT";
   message[socktnosupport] := "Socket type not supported";
   name[opnotsupp] := "EOPNOTSUPP";
   message[opnotsupp] := "Operation not supported on transport endpoint";
   name[pfnosupport] := "EPFNOSUPPORT";
   message[pfnosupport] := "Protocol family not supported";
   name[afnosupport] := "EAFNOSUPPORT";
   message[afnosupport] := "Address family not supported by protocol";
   name[addrinuse] := "EADDRINUSE";
   message[addrinuse] := "Address already in use";
   name[addrnotavail] := "EADDRNOTAVAIL";
   message[addrnotavail] := "Cannot assign requested address";
   name[netdown] := "ENETDOWN";
   message[netdown] := "Network is down";
   name[netunreach] := "ENETUNREACH";
   message[netunreach] := "Network is unreachable";
   name[netreset] := "ENETRETypes.Set";
   message[netreset] := "Network dropped connection because of reset";
   name[connaborted] := "ECONNABORTED";
   message[connaborted] := "Software caused connection abort";
   name[connreset] := "ECONNRETypes.Set";
   message[connreset] := "Connection reset by peer";
   name[nobufs] := "ENOBUFS";
   message[nobufs] := "No buffer space available";
   name[isconn] := "EISCONN";
   message[isconn] := "Transport endpoint is already connected";
   name[notconn] := "ENOTCONN";
   message[notconn] := "Transport endpoint is not connected";
   name[shutdown] := "ESHUTDOWN";
   message[shutdown] := "Cannot send after transport endpoint shutdown";
   name[toomanyrefs] := "ETOOMANYREFS";
   message[toomanyrefs] := "Too many references: cannot splice";
   name[timedout] := "ETIMEDOUT";
   message[timedout] := "Connection timed out";
   name[connrefused] := "ECONNREFUSED";
   message[connrefused] := "Connection refused";
   name[hostdown] := "EHOSTDOWN";
   message[hostdown] := "Host is down";
   name[hostunreach] := "EHOSTUNREACH";
   message[hostunreach] := "No route to host";
   name[already] := "EALREADY";
   message[already] := "Operation already in progress";
   name[inprogress] := "EINPROGRESS";
   message[inprogress] := "Operation now in progress";
   name[stale] := "ESTALE";
   message[stale] := "Stale NFS file handle";
   name[uclean] := "EUCLEAN";
   message[uclean] := "Structure needs cleaning";
   name[notnam] := "ENOTNAM";
   message[notnam] := "Not a XENIX named type file";
   name[navail] := "ENAVAIL";
   message[navail] := "No XENIX semaphores available";
   name[isnam] := "EISNAM";
   message[isnam] := "Is a named type file";
   name[remoteio] := "EREMOTEIO";
   message[remoteio] := "Remote I/O error";
   name[dquot] := "EDQUOT";
   message[dquot] := "Quota exceeded";
   name[nomedium] := "ENOMEDIUM";
   message[nomedium] := "No medium found";
   name[mediumtype] := "EMEDIUMTYPE";
   message[mediumtype] := "Wrong medium type";
END ulmSysErrors.
