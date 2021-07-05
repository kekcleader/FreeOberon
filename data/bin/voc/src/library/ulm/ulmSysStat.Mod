(* Ulm's Oberon Library
   Copyright (C) 1989-1994 by University of Ulm, SAI, D-89069 Ulm, Germany
   ----------------------------------------------------------------------------
   Ulm's Oberon Library is free software; you can redistribute it
   and/or modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either version
   2 of the License, or (at your option) any later version.

   Ulm's Oberon Library is distributed in the hope that it will be
   useful, but WITHOUT ANY WARRANTY; without even the implied warranty
   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   ----------------------------------------------------------------------------
   E-mail contact: oberon@mathematik.uni-ulm.de
   ----------------------------------------------------------------------------
   $Id: SysStat.om,v 1.3 2000/11/12 13:02:09 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: SysStat.om,v $
   Revision 1.3  2000/11/12  13:02:09  borchert
   door file type added

   Revision 1.2  2000/11/12  12:48:07  borchert
   - conversion adapted to Solaris 2.x
   - Lstat added

   Revision 1.1  1994/02/23  08:00:48  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 9/89
   ----------------------------------------------------------------------------
*)

MODULE ulmSysStat;

   (* examine inode: stat(2) and fstat(2) *)

   IMPORT RelatedEvents := ulmRelatedEvents, Sys := ulmSys, SYS := SYSTEM, uSYS := ulmSYSTEM, SysConversions := ulmSysConversions, SysErrors := ulmSysErrors,
      SysTypes := ulmSysTypes, Types := ulmTypes;

   CONST
      (* file mode:
         bit 0 = 1<<0   bit 31 = 1<<31
    
                                user  group other
         3       1  1111   11
         1  ...  6  5432   109   876   543   210 
    +--------+------+-----+-----+-----+-----+
    | unused | type | sst | rwx | rwx | rwx |
    +--------+------+-----+-----+-----+-----+
      *)

      type* = {12..15};
      prot* = {0..8};

      (* file types; example: (stat.mode * type = dir) *)
      reg* = {15};      (* regular *)
      dir* = {14};      (* directory *)
      chr* = {13};      (* character special *)
      fifo* = {12};     (* fifo *)
      blk* = {13..14};     (* block special *)
      symlink* = {13, 15}; (* symbolic link *)
      socket* = {14, 15};  (* socket *)

      (* special *)
      setuid* = 11;     (* set user id on execution *)
      setgid* = 10;     (* set group id on execution *)
      savetext* = 9;    (* save swapped text even after use *)

      (* protection *)
      uread* = 8;    (* read permission owner *)
      uwrite* = 7;      (* write permission owner *)
      uexec* = 6;    (* execute/search permission owner *)
      gread* = 5;    (* read permission group *)
      gwrite* = 4;      (* write permission group *)
      gexec* = 3;    (* execute/search permission group *)
      oread* = 2;    (* read permission other *)
      owrite* = 1;      (* write permission other *)
      oexec* = 0;    (* execute/search permission other *)

      (* example for "r-xr-x---": (read + exec) * (owner + group) *)
      owner* = {uread, uwrite, uexec};
      group* = {gread, gwrite, gexec};
      other* = {oread, owrite, oexec};
      read* = {uread, gread, oread};
      write* = {uwrite, gwrite, owrite};
      exec* = {uexec, gexec, oexec};
      rwx* = prot;

   TYPE
      StatRec* = RECORD            (* result of stat(2) and fstat(2) *)
        device*:  SysTypes.Device; (* ID of device containing a directory entry 
                                      for this file *)
        inode*:   SysTypes.Inode;  (* inode number *)
        mode*:    Types.Set;             (* file mode; see mknod(2) *)
        nlinks*:  Types.Int32;         (* number of links *)
        uid*:     Types.Int32;         (* user id of the file's owner *)
        gid*:     Types.Int32;         (* group id of the file's group *)
        rdev*:    SysTypes.Device; (* ID of device. this entry is defined only for
                                      character special or block special files *)
        size*:    SysTypes.Offset; (* file size in bytes *)
        
        (* Blocks and blksize are not available on all platforms.
        blksize*: Types.Int32;         (* preferred blocksize *)
        blocks*:  Types.Int32;         (* # of blocks allocated *)
        *)
        
        atime*:   SysTypes.Time;   (* time of last access *)
        mtime*:   SysTypes.Time;   (* time of last data modification *)
        ctime*:   SysTypes.Time;   (* time of last file status change *)
     END;


   PROCEDURE -Aincludesysstat  '#include <sys/stat.h>';
   PROCEDURE -Aerrno           '#include <errno.h>';

   PROCEDURE -structstats            "struct stat s";
   PROCEDURE -statdev():     Types.Int32 "(INT32)s.st_dev";
   PROCEDURE -statino():     Types.Int32 "(INT32)s.st_ino";
   PROCEDURE -statmode():    Types.Int32 "(INT32)s.st_mode";
   PROCEDURE -statnlink():   Types.Int32 "(INT32)s.st_nlink";
   PROCEDURE -statuid():     Types.Int32 "(INT32)s.st_uid";
   PROCEDURE -statgid():     Types.Int32 "(INT32)s.st_gid";
   PROCEDURE -statrdev():    Types.Int32 "(INT32)s.st_rdev";
   PROCEDURE -statsize():    Types.Int32 "(INT32)s.st_size";
   PROCEDURE -statatime():   Types.Int32 "(INT32)s.st_atime";
   PROCEDURE -statmtime():   Types.Int32 "(INT32)s.st_mtime";
   PROCEDURE -statctime():   Types.Int32 "(INT32)s.st_ctime";
   
   (* Blocks and blksize are not available on all platforms.
   PROCEDURE -statblksize(): Types.Int32 "(Types.Int32)s.st_blksize";
   PROCEDURE -statblocks():  Types.Int32 "(Types.Int32)s.st_blocks";
   *)

   PROCEDURE -fstat(fd: Types.Int32):      Types.Int32 "fstat(fd, &s)";
   PROCEDURE -stat (n: ARRAY OF CHAR): Types.Int32 "stat((char*)n, &s)";

   PROCEDURE -err(): Types.Int32 "errno";

   PROCEDURE Stat*(path: ARRAY OF CHAR; VAR buf: StatRec; errors: RelatedEvents.Object): BOOLEAN;
   BEGIN
      structstats;
      IF stat(path) < 0 THEN SysErrors.Raise(errors, err(), Sys.newstat, path); RETURN FALSE END;
      buf.device  := SYS.VAL(SysTypes.Device, statdev());
      buf.inode   := SYS.VAL(SysTypes.Inode,  statino());
      buf.mode    := SYS.VAL(Types.Set,             statmode());
      buf.nlinks  := statnlink();
      buf.uid     := statuid();
      buf.gid     := statgid();
      buf.rdev    := SYS.VAL(SysTypes.Device, statrdev());
      buf.size    := SYS.VAL(SysTypes.Offset, statsize());
      (* Blocks and blksize are not available on all platforms.
      buf.blksize := statblksize();
      buf.blocks  := statblocks();
      *)
      buf.atime   := SYS.VAL(SysTypes.Time, statatime());
      buf.mtime   := SYS.VAL(SysTypes.Time, statmtime());
      buf.ctime   := SYS.VAL(SysTypes.Time, statctime());
      RETURN TRUE;
   END Stat;

   PROCEDURE Fstat*(fd: SysTypes.File; VAR buf: StatRec; errors: RelatedEvents.Object): BOOLEAN;
   BEGIN
      structstats;
      IF fstat(SYS.VAL(Types.Int32, fd)) < 0 THEN SysErrors.Raise(errors, err(), Sys.newfstat, ""); RETURN FALSE END;
      buf.device  := SYS.VAL(SysTypes.Device, statdev());
      buf.inode   := SYS.VAL(SysTypes.Inode,  statino());
      buf.mode    := SYS.VAL(Types.Set,             statmode());
      buf.nlinks  := statnlink();
      buf.uid     := statuid();
      buf.gid     := statgid();
      buf.rdev    := SYS.VAL(SysTypes.Device, statrdev());
      buf.size    := SYS.VAL(SysTypes.Offset, statsize());
      (* Blocks and blksize are not available on all platforms.
      buf.blksize := statblksize();
      buf.blocks  := statblocks();
      *)
      buf.atime   := SYS.VAL(SysTypes.Time, statatime());
      buf.mtime   := SYS.VAL(SysTypes.Time, statmtime());
      buf.ctime   := SYS.VAL(SysTypes.Time, statctime());
      RETURN TRUE;
   END Fstat;


END ulmSysStat.
