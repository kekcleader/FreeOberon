(* 	$Id: Channel.Mod,v 1.10 1999/10/31 13:35:12 ooc-devel Exp $	 *)
MODULE oocChannel;
(*  Provides abstract data types Channel, Reader, and Writer for stream I/O.
    Copyright (C) 1997-1999  Michael van Acken

    This module is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public License
    as published by the Free Software Foundation; either version 2 of
    the License, or (at your option) any later version.

    This module is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with OOC. If not, write to the Free Software Foundation,
    59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*)

(*
Note 0: 
All types and procedures declared in this module have to be considered
abstract, i.e., they are never instanciated or called.  The provided procedure
bodies are nothing but hints how a specific channel could start implementing
them.

Note 1: 
A module implementing specific channels (e.g., files, or TCP streams) will
provide the procedures
  PROCEDURE New* (...): Channel;
and (optionally)
  PROCEDURE Old* (...): Channel.

For channels that correspond to a piece of data that can be both read
and changed, the first procedure will create a new channel for the
given data location, deleting all data previously contained in it.
The latter will open a channel to the existing data.

For channels representing a unidirectional byte stream (like output to
/ input from terminal, or a TCP stream), only a procedure New is
provided.  It will create a connection with the designated location.

The formal parameters of these procedures will include some kind of
reference to the data being opened (e.g. a file name) and, optionally,
flags that modify the way the channel is opened (e.g. read-only,
write-only, etc).  Their interface therefore depends on the channel
and is not part of this specification.  The standard way to create new
channels is to call the type-bound procedures Locator.New and
Locator.Old (which in turn will call the above mentioned procedures).

Note 2:
A channel implementation should state how many channels can be open 
simultaneously.  It's common for the OS to support just so many open files or
so many open sockets at the same time.  Since this value isn't a constant, it's
only required to give a statement on the number of open connections for the 
best case, and which factors can lower this number.

Note 3:
A number of record fields in Channel, Reader, and Writer are exported
with write permissions.  This is done to permit specializations of the
classes to change these fields.  The user should consider them
read-only.
*)

IMPORT 
  SYSTEM, Strings := oocStrings, Time := oocTime, Msg := oocMsg;
  

TYPE
  Result* = Msg.Msg;
  
CONST
  noLength* = -1;
  (* result value of Channel.Length if the queried channel has no fixed length
     (e.g., if it models input from keybord, or output to terminal) *)
  noPosition* = -2;
  (* result value of Reader/Writer.Pos if the queried rider has no concept of
     an indexed reading resp. writing position (e.g., if it models input from 
     keybord, or output to terminal) *)
  
  
  (* Note: The below list of error codes only covers the most typical errors.
     A specific channel implementation (like Files) will define its own list 
     own codes, containing aliases for the codes below (when appropriate) plus
     error codes of its own.  Every module will provide an error context (an
     instance of Msg.Context) to translate any code into a human readable 
     message.  *)
  
  (* a `res' value of `done' means successful completion of the I/O 
     operation:  *)
  done* = NIL;
  
  (* the following values may appear in the `res.code' field of `Channel', 
     `Reader', or `Writer': *)
  (* indicates successful completion of last operation *)
  invalidChannel* = 1;
  (* the channel channel isn't valid, e.g. because it wasn't opened in the
     first place or was corrupted somehow; for a rider this refers to the
     channel in the `base' field *)
  writeError* = 2;
  (* a write error occured; usually this error happens with a writer, but for
     buffered channels this may also occur during a `Flush' or a `Close' *)
  noRoom* = 3; 
  (* set if a write operation failed because there isn't any space left on the
     device, e.g. if the disk is full or you exeeded your quota; usually this 
     error happens with a writer, but for buffered channels this may also 
     occur during a `Flush' or a `Close' *)
  
  (* symbolic values for `Reader.res.code' resp. `Writer.res.code': *)
  outOfRange* = 4;
  (* set if `SetPos' has been called with a negative argument or it has been
     called on a rider that doesn't support positioning *)
  readAfterEnd* = 5;
  (* set if a call to `ReadByte' or `ReadBytes' tries to access a byte beyond
     the end of the file (resp. channel); this means that there weren't enough
     bytes left or the read operation started at (or after) the end *)
  channelClosed* = 6;
  (* set if the rider's channel has been closed, preventing any further read or
     write operations; this means you called Channel.Close() (in which case you
     made a programming error), or the process at the other end of the channel
     closed the connection (examples for this are pipes, FIFOs, tcp streams) *)
  readError* = 7;
  (* unspecified read error *)
  invalidFormat* = 8;
  (* set by an interpreting Reader (e.g., TextRiders.Reader) if the byte stream
     at the current reading position doesn't represent an object of the 
     requested type *)
  
  (* symbolic values for `Channel.res.code': *)
  noReadAccess* = 9;
  (* set if NewReader was called to create a reader on a channel that doesn't
     allow reading access *)
  noWriteAccess* = 10;
  (* set if NewWriter was called to create a reader on a channel that doesn't 
     allow reading access *)
  closeError* = 11;
  (* set if closing the channel failed for some reason *)
  noModTime* = 12;
  (* set if no modification time is available for the given channel *)
  noTmpName* = 13;
  (* creation of a temporary file failed because the system was unable to 
     assign an unique name to it; closing or registering an existing temporary
     file beforehand might help *)
  
  freeErrorCode* = 14;
  (* specific channel implemenatations can start defining their own additional
     error codes for Channel.res, Reader.res, and Writer.res here *)


TYPE
  Channel* = POINTER TO ChannelDesc;
  ChannelDesc* = RECORD (*[ABSTRACT]*)
    res*: Result;       (* READ-ONLY *)
    (* Error flag signalling failure of a call to NewReader, NewWriter, Flush,
       or Close.  Initialized to `done' when creating the channel.  Every 
       operation sets this to `done' on success, or to a message object to 
       indicate the error source.  *)
    
    readable*: BOOLEAN;  (* READ-ONLY *)
    (* TRUE iff readers can be attached to this channel with NewReader *)
    writable*: BOOLEAN;  (* READ-ONLY *)
    (* TRUE iff writers can be attached to this channel with NewWriter *)
    
    open*: BOOLEAN;  (* READ-ONLY *)
    (* Channel status.  Set to TRUE on channel creation, set to FALSE by 
       calling Close.  Closing a channel prevents all further read or write
       operations on it.  *)
  END;

TYPE
  Reader* = POINTER TO ReaderDesc;
  ReaderDesc* = RECORD (*[ABSTRACT]*)
    base*: Channel;  (* READ-ONLY *)
    (* This field refers to the channel the Reader is connected to.  *)

    res*: Result;   (* READ-ONLY *)
    (* Error flag signalling failure of a call to ReadByte, ReadBytes, or 
       SetPos.  Initialized to `done' when creating a Reader or by calling 
       ClearError.  The first failed reading (or SetPos) operation changes this
       to indicate the error, all further calls to ReadByte, ReadBytes, or 
       SetPos will be ignored until ClearError resets this flag.  This means 
       that the successful completion of an arbitrary complex sequence of read
       operations can be ensured by asserting that `res' equals `done' 
       beforehand and also after the last operation.  *)
    
    bytesRead*: LONGINT;  (* READ-ONLY *)
    (* Set by ReadByte and ReadBytes to indicate the number of bytes that were
       successfully read.  *)
       
    positionable*: BOOLEAN;  (* READ-ONLY *)
    (* TRUE iff the Reader can be moved to another position with `SetPos'; for
       channels that can only be read sequentially, like input from keyboard, 
       this is FALSE.  *)
  END;

TYPE
  Writer* = POINTER TO WriterDesc;
  WriterDesc* = RECORD (*[ABSTRACT]*)
    base*: Channel;  (* READ-ONLY *)
    (* This field refers to the channel the Writer is connected to.  *)

    res*: Result;   (* READ-ONLY *)
    (* Error flag signalling failure of a call to WriteByte, WriteBytes, or 
       SetPos.  Initialized to `done' when creating a Writer or by calling 
       ClearError.  The first failed writing (or SetPos) operation changes this
       to indicate the error, all further calls to WriteByte, WriteBytes, or 
       SetPos will be ignored until ClearError resets this flag.  This means 
       that the successful completion of an arbitrary complex sequence of write
       operations can be ensured by asserting that `res' equals `done' 
       beforehand and also after the last operation.  Note that due to 
       buffering a write error may occur when flushing or closing the 
       underlying file, so you have to check the channel's `res' field after 
       any Flush() or the final Close(), too.  *)
     
    bytesWritten*: LONGINT;  (* READ-ONLY *)
    (* Set by WriteByte and WriteBytes to indicate the number of bytes that 
       were successfully written.  *)
       
    positionable*: BOOLEAN;  (* READ-ONLY *)
    (* TRUE iff the Writer can be moved to another position with `SetPos'; for
       channels that can only be written sequentially, like output to terminal,
       this is FALSE.  *)
  END;

TYPE
  ErrorContext = POINTER TO ErrorContextDesc;
  ErrorContextDesc* = RECORD
     (* this record is exported, so that extensions of Channel can access the
        error descriptions by extending `ErrorContextDesc' *)
    (Msg.ContextDesc)
  END;


VAR
  errorContext: ErrorContext;

PROCEDURE GetError (code: Msg.Code): Result;
  BEGIN
    RETURN Msg.New (errorContext, code)
  END GetError;

PROCEDURE (context: ErrorContext) GetTemplate* (msg: Msg.Msg; VAR templ: Msg.LString);
(* Translates this module's error codes into strings.  The string usually
   contains a short error description, possibly followed by some attributes
   to provide additional information for the problem.
   
   The method should not be called directly by the user.  It is invoked by
   `res.GetText()' or `res.GetLText'.  *)
  VAR
    str: ARRAY 128 OF CHAR;
  BEGIN
    CASE msg. code OF
    | invalidChannel: str := "Invalid channel descriptor"
    | writeError:     str := "Write error"
    | noRoom:         str := "No space left on device"
    
    | outOfRange:     str := "Trying to set invalid position"
    | readAfterEnd:   str := "Trying to read past the end of the file"
    | channelClosed:  str := "Channel has been closed"
    | readError:      str := "Read error"
    | invalidFormat:  str := "Invalid token type in input stream"
    
    | noReadAccess:   str := "No read permission for channel"
    | noWriteAccess:  str := "No write permission for channel"
    | closeError:     str := "Error while closing the channel"
    | noModTime:      str := "No modification time available"
    | noTmpName:      str := "Failed to create unique name for temporary file"
    ELSE
      str := "[unknown error code]"
    END;
    COPY (str, templ)
  END GetTemplate;



(* Reader methods 
   ------------------------------------------------------------------------ *)

PROCEDURE (r: Reader) (*[ABSTRACT]*) Pos*(): LONGINT;
(* Returns the current reading position associated with the reader `r' in
   channel `r.base', i.e. the index of the first byte that is read by the
   next call to ReadByte resp. ReadBytes.  This procedure will return 
   `noPosition' if the reader has no concept of a reading position (e.g. if it
   corresponds to input from keyboard), otherwise the result is not negative.*)
  END Pos;

PROCEDURE (r: Reader) (*[ABSTRACT]*) Available*(): LONGINT;
(* Returns the number of bytes available for the next reading operation.  For
   a file this is the length of the channel `r.base' minus the current reading
   position, for an sequential channel (or a channel designed to handle slow
   transfer rates) this is the number of bytes that can be accessed without
   additional waiting.  The result is -1 if Close() was called for the channel,
   or no more byte are available and the remote end of the channel has been
   closed.
   Note that the number of bytes returned is always a lower approximation of
   the number that could be read at once; for some channels or systems it might
   be as low as 1 even if tons of bytes are waiting to be processed.  *)
(* example: 
  BEGIN
    IF r. base. open THEN
      i := r. base. Length() - r. Pos();
      IF (i < 0) THEN
        RETURN 0
      ELSE
        RETURN i
      END
    ELSE
      RETURN -1
    END
    *)
  END Available;
  
PROCEDURE (r: Reader) (*[ABSTRACT]*) SetPos* (newPos: LONGINT);
(* Sets the reading position to `newPos'.  A negative value of `newPos' or 
   calling this procedure for a reader that doesn't allow positioning will set
   `r.res' to `outOfRange'.  A value larger than the channel's length is legal,
   but the following read operation will most likely fail with an 
   `readAfterEnd' error unless the channel has grown beyond this position in 
   the meantime.
   Calls to this procedure while `r.res # done' will be ignored, in particular
   a call with `r.res.code = readAfterEnd' error will not reset `res' to 
   `done'.  *)
(* example: 
  BEGIN
    IF (r. res = done) THEN
      IF ~r. positionable OR (newPos < 0) THEN
        r. res := GetError (outOfRange)
      ELSIF r. base. open THEN
        (* ... *)
      ELSE  (* channel has been closed *)
        r. res := GetError (channelClosed)
      END
    END
    *)
  END SetPos;
  
PROCEDURE (r: Reader) (*[ABSTRACT]*) ReadByte* (VAR x: SYSTEM.BYTE);
(* Reads a single byte from the channel `r.base' at the reading position 
   associated with `r' and places it in `x'.  The reading position is moved 
   forward by one byte on success, otherwise `r.res' is changed to indicate 
   the error cause.  Calling this procedure with the reader `r' placed at the 
   end (or beyond the end) of the channel will set `r.res' to `readAfterEnd'.
   `r.bytesRead' will be 1 on success and 0 on failure.
   Calls to this procedure while `r.res # done' will be ignored.  *)
(* example:
  BEGIN
    IF (r. res = done) THEN
      IF r. base. open THEN
        (* ... *)
      ELSE  (* channel has been closed *)
        r. res := GetError (channelClosed);
        r. bytesRead := 0
      END
    ELSE
      r. bytesRead := 0
    END
    *)
  END ReadByte;
  
PROCEDURE (r: Reader) (*[ABSTRACT]*) ReadBytes* (VAR x: ARRAY OF SYSTEM.BYTE; 
                                             start, n: LONGINT);
(* Reads `n' bytes from the channel `r.base' at the reading position associated
   with `r' and places them in `x', starting at index `start'.  The 
   reading position is moved forward by `n' bytes on success, otherwise 
   `r.res' is changed to indicate the error cause.  Calling this procedure with
   the reader `r' placed less than `n' bytes before the end of the channel will
   will set `r.res' to `readAfterEnd'.  `r.bytesRead' will hold the number of
   bytes that were actually read (being equal to `n' on success).
   Calls to this procedure while `r.res # done' will be ignored.
   pre: (n >= 0) & (0 <= start) & (start+n <= LEN (x)) *)
(* example: 
  BEGIN
    ASSERT ((n >= 0) & (0 <= start) & (start+n <= LEN (x)));
    IF (r. res = done) THEN
      IF r. base. open THEN
        (* ... *)
      ELSE  (* channel has been closed *)
        r. res := GetError (channelClosed);
        r. bytesRead := 0
      END
    ELSE
      r. bytesRead := 0
    END
    *)
  END ReadBytes;
  
PROCEDURE (r: Reader) ClearError*;
(* Sets the result flag `r.res' to `done', re-enabling further read operations
   on `r'.  *)
  BEGIN
    r. res := done
  END ClearError;




(* Writer methods 
   ------------------------------------------------------------------------ *)

PROCEDURE (w: Writer) (*[ABSTRACT]*) Pos*(): LONGINT;
(* Returns the current writing position associated with the writer `w' in
   channel `w.base', i.e. the index of the first byte that is written by the
   next call to WriteByte resp. WriteBytes.  This procedure will return 
   `noPosition' if the writer has no concept of a writing position (e.g. if it
   corresponds to output to terminal), otherwise the result is not negative. *)
  END Pos;
  
PROCEDURE (w: Writer) (*[ABSTRACT]*) SetPos* (newPos: LONGINT);
(* Sets the writing position to `newPos'.  A negative value of `newPos' or 
   calling this procedure for a writer that doesn't allow positioning will set
   `w.res' to `outOfRange'.  A value larger than the channel's length is legal,
   the following write operation will fill the gap between the end of the 
   channel and this position with zero bytes.
   Calls to this procedure while `w.res # done' will be ignored.  *)
(* example: 
  BEGIN
    IF (w. res = done) THEN
      IF ~w. positionable OR (newPos < 0) THEN
        w. res := GetError (outOfRange)
      ELSIF w. base. open THEN
        (* ... *)
      ELSE  (* channel has been closed *)
        w. res := GetError (channelClosed)
      END
    END
    *)
  END SetPos;
  
PROCEDURE (w: Writer) (*[ABSTRACT]*) WriteByte* (x: SYSTEM.BYTE);
(* Writes a single byte `x' to the channel `w.base' at the writing position 
   associated with `w'.  The writing position is moved forward by one byte on 
   success, otherwise `w.res' is changed to indicate the error cause.
   `w.bytesWritten' will be 1 on success and 0 on failure.
   Calls to this procedure while `w.res # done' will be ignored.  *)
(* example: 
  BEGIN
    IF (w. res = done) THEN
      IF w. base. open THEN
        (* ... *)
      ELSE  (* channel has been closed *)
        w. res := GetError (channelClosed);
        w. bytesWritten := 0
      END
    ELSE
      w. bytesWritten := 0
    END
    *)
  END WriteByte;
  
PROCEDURE (w: Writer) (*[ABSTRACT]*) WriteBytes* (VAR x: ARRAY OF SYSTEM.BYTE; 
                                              start, n: LONGINT);
(* Writes `n' bytes from `x', starting at position `start', to the channel 
   `w.base' at the writing position associated with `w'.  The writing position
   is moved forward by `n' bytes on success, otherwise `w.res' is changed to 
   indicate the error cause.  `w.bytesWritten' will hold the number of bytes 
   that were actually written (being equal to `n' on success).
   Calls to this procedure while `w.res # done' will be ignored.
   pre: (n >= 0) & (0 <= start) & (start+n <= LEN (x))  *)
(* example: 
  BEGIN                                  
    ASSERT ((n >= 0) & (0 <= start) & (start+n <= LEN (x)));
    IF (w. res = done) THEN
      IF w. base. open THEN
        (* ... *)
      ELSE  (* channel has been closed *)
        w. res := GetError (channelClosed);
        w. bytesWritten := 0
      END
    ELSE
      w. bytesWritten := 0
    END
    *)
  END WriteBytes;
  
PROCEDURE (w: Writer) ClearError*;
(* Sets the result flag `w.res' to `done', re-enabling further write operations
   on `w'.  *)
  BEGIN
    w. res := done
  END ClearError;

    


(* Channel methods 
   ------------------------------------------------------------------------ *)
   
PROCEDURE (ch: Channel) (*[ABSTRACT]*) Length*(): LONGINT;
(* Result is the number of bytes of data that this channel refers to.  If `ch'
   represents a file, then this value is the file's size.  If `ch' has no fixed
   length (e.g. because it's interactive), the result is `noLength'.  *)
  END Length;
  
PROCEDURE (ch: Channel) (*[ABSTRACT]*) GetModTime* (VAR mtime: Time.TimeStamp);
(* Retrieves the modification time of the data accessed by the given channel.
   If no such information is avaiblable, `ch.res' is set to `noModTime', 
   otherwise to `done'.  *)
  END GetModTime;

PROCEDURE (ch: Channel) NewReader*(): Reader;
(* Attaches a new reader to the channel `ch'.  It is placed at the very start 
   of the channel, and its `res' field is initialized to `done'.  `ch.res' is
   set to `done' on success and the new reader is returned.  Otherwise result 
   is NIL and `ch.res' is changed to indicate the error cause.  
   Note that always the same reader is returned if the channel does not support
   multiple reading positions.  *)
(* example: 
  BEGIN
    IF ch. open THEN
      IF ch. readable THEN
        (* ... *)
        ch. ClearError
      ELSE
        ch. res := noReadAccess;
        RETURN NIL
      END
    ELSE
      ch. res := channelClosed;
      RETURN NIL
    END
    *)
  BEGIN  (* default: channel does not have read access *)
    IF ch. open THEN
      ch. res := GetError (noReadAccess)
    ELSE
      ch. res := GetError (channelClosed)
    END;
    RETURN NIL
  END NewReader;
  
PROCEDURE (ch: Channel) NewWriter*(): Writer;
(* Attaches a new writer to the channel `ch'.  It is placed at the very start 
   of the channel, and its `res' field is initialized to `done'.  `ch.res' is
   set to `done' on success and the new writer is returned.  Otherwise result 
   is NIL and `ch.res' is changed to indicate the error cause.
   Note that always the same reader is returned if the channel does not support
   multiple writing positions.  *)
(* example: 
  BEGIN
    IF ch. open THEN
      IF ch. writable THEN
        (* ... *)
        ch. ClearError
      ELSE
        ch. res := GetError (noWriteAccess);
        RETURN NIL
      END
    ELSE
      ch. res := GetError (channelClosed);
      RETURN NIL
    END
    *)
  BEGIN  (* default: channel does not have write access *)
    IF ch. open THEN
      ch. res := GetError (noWriteAccess)
    ELSE
      ch. res := GetError (channelClosed)
    END;
    RETURN NIL
  END NewWriter;
  
PROCEDURE (ch: Channel) (*[ABSTRACT]*) Flush*;
(* Flushes all buffers related to this channel.  Any pending write operations
   are passed to the underlying OS and all buffers are marked as invalid.  The
   next read operation will get its data directly from the channel instead of 
   the buffer.  If a writing error occurs during flushing, the field `ch.res'
   will be changed to `writeError', otherwise it's assigned `done'.  Note that
   you have to check the channel's `res' flag after an explicit flush yourself,
   since none of the attached writers will notice any write error in this 
   case.  *)
(* example: 
  BEGIN
    (* ... *)
    IF (* write error ... *) FALSE THEN
      ch. res := GetError (writeError)
    ELSE
      ch. ClearError
    END
    *)
  END Flush;

PROCEDURE (ch: Channel) (*[ABSTRACT]*) Close*;
(* Flushes all buffers associated with `ch', closes the channel, and frees all
   system resources allocated to it.  This invalidates all riders attached to
   `ch', they can't be used further.  On success, i.e. if all read and write 
   operations (including flush) completed successfully, `ch.res' is set to 
   `done'.  An opened channel can only be closed once, successive calls of 
   `Close' are undefined.  
   Note that unlike the Oberon System all opened channels have to be closed
   explicitly.  Otherwise resources allocated to them will remain blocked.  *)
(* example: 
  BEGIN
    ch. Flush;
    IF (ch. res = done) THEN
      (* ... *)
    END;
    ch. open := FALSE
    *)
  END Close;

PROCEDURE (ch: Channel) ClearError*;
(* Sets the result flag `ch.res' to `done'.  *)
  BEGIN
    ch. res := done
  END ClearError;

BEGIN
  NEW (errorContext);
  Msg.InitContext (errorContext, "OOC:Core:Channel")
END oocChannel.
