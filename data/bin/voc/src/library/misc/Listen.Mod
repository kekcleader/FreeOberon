(*
 Module taken from http://www.dg.bnv-bamberg.de/seiten/faecher/informat/oberon/aachen/listen.htm 
Author: zita@pegasus.dvz.fh-aachen.de

*)

MODULE Listen;
TYPE
 Element* = POINTER TO ElementDesc;
 ElementDesc* = RECORD END;
 Liste* = POINTER TO ListDesc;
 ListDesc = RECORD
   e:    Element;
   rest: Liste
 END;

        CompareProc=PROCEDURE(e1,e2:Element):BOOLEAN;

        PROCEDURE Concat*(head: Element; tail: Liste): Liste;
        VAR temp:Liste;
        BEGIN
                NEW(temp); temp.e := head; temp.rest := tail;
                RETURN temp
        END Concat;

        PROCEDURE Head* (l:Liste):Element;
        BEGIN
                RETURN l.e
        END Head;

        PROCEDURE Tail* (l:Liste):Liste;
        BEGIN
                RETURN l.rest
        END Tail;

         PROCEDURE Append* (list: Liste; e: Element): Liste;
        BEGIN
          IF list = NIL THEN
          RETURN Concat(e, NIL) ELSE
          RETURN Concat(Head(list),Append(Tail(list),e))
          END;
        END Append;


        PROCEDURE IsElement*(e:Element;l:Liste;equal:CompareProc):BOOLEAN;
        BEGIN
                IF l = NIL THEN RETURN FALSE
                ELSIF equal(e,Head(l)) THEN RETURN TRUE
                ELSE RETURN IsElement(e,Tail(l),equal)
                END
        END IsElement;

        PROCEDURE Find*(e:Element;l:Liste;equal:CompareProc):Element;
        BEGIN
                IF l = NIL THEN RETURN NIL
                ELSIF equal(e,Head(l)) THEN RETURN Head(l)
                ELSE RETURN Find(e,Tail(l),equal)
                END
        END Find;

END Listen.
