(* This module is obsolete.  Don't use it. *)
MODULE oocFilenames;
(* Note: It is not checked whether the concatenated strings fit into the
   variables given for them or not *)

IMPORT 
  Strings := oocStrings, Strings2 := oocStrings2, Rts := oocRts;


PROCEDURE LocateCharLast(str: ARRAY OF CHAR; ch: CHAR): INTEGER;
(* Result is the position of the last occurence of 'ch' in the string 'str'.
   If 'ch' does not occur in 'str', then -1 is returned *)
  VAR 
    pos: INTEGER;
  BEGIN
    pos:=Strings.Length(str);
    WHILE (pos >= 0) DO
      IF (str[pos] = ch) THEN
        RETURN(pos);
      ELSE
        DEC(pos);
      END; (* IF *)
    END; (* WHILE *)
    RETURN -1
  END LocateCharLast;

PROCEDURE SplitRChar(str: ARRAY OF CHAR; VAR str1, str2: ARRAY OF CHAR; ch: CHAR);
(* pre : 'str' contains the string to be splited after the rightmost 'ch' *)
(* post: 'str1' contains the left part (including 'ch') of 'str',
         iff occurs(ch,str), otherwise "",
         'str2' contains the right part of 'str'.
*)
(*
  example:
            str = "/aksdf/asdf/gasdfg/esscgd.asdfg"
    result: str2 = "esscgd.asdfg"
            str1 = "/aksdf/asdf/gasdfg/"
*)

  VAR 
    len,pos: INTEGER;
  BEGIN
    len:=Strings.Length(str);
 
    (* search for the rightmost occurence of 'ch' and
       store it's position in 'pos' *)
    pos:=LocateCharLast(str,ch);
    
    COPY(str,str2); (* that has to be done all time *)
    IF (pos >= 0) THEN 
      (* 'ch' occurs in 'str', (str[pos]=ch)=TRUE *)
      COPY(str,str1); (* copy the whole string 'str' to 'str1' *)
      INC(pos); (* we want to split _after_ 'ch' *)
      Strings.Delete(str2,0,pos); (* remove left part from 'str2' *)
      Strings.Delete(str1,pos,(len-pos)); (* remove right part from 'str1' *)
    ELSE (* there is no pathinfo in 'file' *)
      COPY("",str1); (* make 'str1' the empty string *)
    END; (* IF *)
  END SplitRChar;

(******************************)
(* decomposition of filenames *)
(******************************)

PROCEDURE GetPath*(full: ARRAY OF CHAR; VAR path, file: ARRAY OF CHAR);
(*
  pre : "full" contains the (maybe) absolute path to a file.
  post: "file" contains only the filename, "path" the path for it.
  
  example:
    pre : full = "/aksdf/asdf/gasdfg/esscgd.asdfg"
    post: file = "esscgd.asdfg"
          path = "/aksdf/asdf/gasdfg/"
*)

  BEGIN
    SplitRChar(full,path,file,Rts.pathSeperator);
  END GetPath;

PROCEDURE GetExt*(full: ARRAY OF CHAR; VAR file, ext: ARRAY OF CHAR);
  BEGIN
    IF (LocateCharLast(full,Rts.pathSeperator) < LocateCharLast(full,".")) THEN
      (* there is a "real" extension *)
      SplitRChar(full,file,ext,".");
      Strings.Delete(file,Strings.Length(file)-1,1); (* delete "." at the end of 'file' *)
    ELSE
      COPY(full,file);
      COPY("",ext);
    END; (* IF *)
  END GetExt;

PROCEDURE GetFile*(full: ARRAY OF CHAR; VAR file: ARRAY OF CHAR);
(* removes both path & extension from 'full' and stores the result in 'file' *)
(* example:
   GetFile("/tools/public/o2c-1.2/lib/Filenames.Mod",myname)
     results in 
   myname="Filenames"
*)
  VAR 
    dummy: ARRAY 256 OF CHAR; (* that should be enough... *)
  BEGIN
    GetPath(full,dummy,file);
    GetExt(file,file,dummy);
  END GetFile;


(****************************)
(* composition of filenames *)
(****************************)

PROCEDURE AddExt*(VAR full: ARRAY OF CHAR; file, ext: ARRAY OF CHAR);
(* pre : 'file' is a filename
         'ext' is some extension
*)
(* post: 'full' contains 'file'"."'ext', iff 'ext'#"",
         otherwise 'file'
*)
  BEGIN
    COPY(file,full);    
    IF (ext[0] # 0X) THEN 
      (* we only append 'real', i.e. nonempty extensions *)
      Strings2.AppendChar(".", full);
      Strings.Append(ext, full);
    END; (* IF *)
  END AddExt;

PROCEDURE AddPath*(VAR full: ARRAY OF CHAR; path, file: ARRAY OF CHAR);
(* pre : 'file' is a filename
         'path' is a path (will not be interpreted) or ""
*)
(* post: 'full' will contain the contents of 'file' with
         addition of 'path' at the beginning.
*)
  BEGIN
    COPY(file,full);
    IF (path[0] # 0X) THEN
      (* we only add something if there is something... *)
      IF (path[Strings.Length(path) - 1] # Rts.pathSeperator) THEN 
        (* add a seperator, if none is at the end of 'path' *)
        Strings.Insert(Rts.pathSeperator, 0, full);
      END; (* IF *)
      Strings.Insert(path, 0, full)
    END; (* IF *)
  END AddPath;

PROCEDURE BuildFilename*(VAR full: ARRAY OF CHAR; path, file, ext: ARRAY OF CHAR);
(* pre : 'file' is the name of a file, 
         'path' is its path and
         'ext' is the extension to be added 
*)
(* post: 'full' contains concatenation of 'path' with ('file' with 'ext')
*)
 BEGIN
   AddExt(full,file,ext);
   AddPath(full,path,full);
  END BuildFilename;

PROCEDURE ExpandPath*(VAR full: ARRAY OF CHAR; path: ARRAY OF CHAR);
(* Expands "~/" and "~user/" at the beginning of 'path' to it's
   intended strings.
   "~/" will result in the path to the current user's home,
   "~user" will result in the path of "user"'s home. *)
  VAR
    len, posSep, posSuffix: INTEGER;
    suffix, userpath: ARRAY 256 OF CHAR;
    username: ARRAY 32 OF CHAR;
  BEGIN
    COPY (path, full);
    IF (path[0] = "~") THEN (* we have to expand something *)
      posSep := Strings2.PosChar (Rts.pathSeperator, path);
      len := Strings.Length (path);
      IF (posSep < 0) THEN   (* no '/' in file name, just the path *)
        posSep := len;
        posSuffix := len
      ELSE
        posSuffix := posSep+1
      END;
      Strings.Extract (path, posSuffix, len-posSuffix, suffix);
      Strings.Extract (path, 1, posSep-1, username);
      Rts.GetUserHome (userpath, username);
      IF (userpath[0] # 0X) THEN         (* sucessfull search *)
        AddPath (full, userpath, suffix)
      END
    END
  END ExpandPath;

END oocFilenames.

