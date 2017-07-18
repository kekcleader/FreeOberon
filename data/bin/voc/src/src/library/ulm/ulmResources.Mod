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
   $Id: Resources.om,v 1.2 1998/03/24 22:51:29 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Resources.om,v $
   Revision 1.2  1998/03/24  22:51:29  borchert
   bug fix: do not create a relationship to dead or unreferenced objects
            but propagate terminations immediately to dependants

   Revision 1.1  1996/01/04  16:44:44  borchert
   Initial revision

   ----------------------------------------------------------------------------
*)

MODULE ulmResources;

   (* general interface for objects which are shared and need
      some cooperative termination/cleanup handling
   *)

   IMPORT Disciplines := ulmDisciplines, Events := ulmEvents, Objects := ulmObjects, SYSTEM;

   TYPE
      Resource* = Disciplines.Object;

   (* notification of state changes:
      initially, resources are alive;
      later the communication to an object may be temporarily
      stopped (communicationStopped) and resumed (communicationResumed) --
      the effect of calling operations during the communicationStopped
      state is undefined: possible variants are (1) immediate failure
      and (2) being blocked until the state changes to communicationResumed;
      unreferenced objects are still alive but no longer in use by
      our side -- some cleanup actions may be associated with this state change;
      terminated objects are no longer alive and all operations for
      them will fail
   *)
   CONST
      (* state changes *)
      terminated* = 0;
      unreferenced* = 1;
      communicationStopped* = 2;
      communicationResumed* = 3;
      (* states *)
      alive = 4; (* private extension *)
   TYPE
      StateChange* = SHORTINT; (* terminated..communicationResumed *)
      State = SHORTINT; (* alive, unreferenced, or alive *)
         (* whether objects are stopped or not is maintained separately *)
      Event* = POINTER TO EventRec; (* notification of state changes *)
      EventRec* =
         RECORD
            (Events.EventRec)
            change*: StateChange; (* new state *)
            resource*: Resource;
         END;

   TYPE
      Key* = POINTER TO KeyRec;
      KeyRec* =
         RECORD
            (Objects.ObjectRec)
            valid: BOOLEAN;
            resource: Resource;
         END;

   TYPE
      List = POINTER TO ListRec;
      ListRec =
         RECORD
            resource: Resource;
            next: List;
         END;
      Discipline = POINTER TO DisciplineRec;
      DisciplineRec =
         RECORD
            (Disciplines.DisciplineRec)
            state: State;           (* alive, unreferenced, or terminated *)
            stopped: BOOLEAN;       (* may be TRUE, if alive or unreferenced *)
            refcnt: LONGINT;        (* # of Attach - # of Detach *)
            eventType: Events.EventType; (* may be NIL *)
            dependants: List;       (* list of resources which depends on us *)
            dependsOn: Resource;    (* we depend on this resource *)
            key: Key;               (* attach key for dependsOn *)
         END;
   VAR
      discID: Disciplines.Identifier;

   (* === private procedures ============================================ *)

   PROCEDURE GetDisc(resource: Resource; VAR disc: Discipline);
     VAR d: Disciplines.Discipline;
   BEGIN
      IF Disciplines.Seek(resource, discID, d) THEN
         disc := d(Discipline)
      ELSE
         NEW(disc); disc.id := discID;
         disc.state := alive; disc.refcnt := 0;
         disc.eventType := NIL;
         disc.dependants := NIL; disc.dependsOn := NIL;
         Disciplines.Add(resource, disc);
      END;
   END GetDisc;

   PROCEDURE GenEvent(resource: Resource; change: StateChange);
      VAR
         disc: Discipline;
         event: Event;
   BEGIN
      GetDisc(resource, disc);
      IF disc.eventType # NIL THEN
         NEW(event);
         event.type := disc.eventType;
         event.message := "Resources: state change notification";
         event.change := change;
         event.resource := resource;
         Events.Raise(event);
      END;
   END GenEvent;

   PROCEDURE ^ Detach*(resource: Resource; key: Key);

   PROCEDURE Unlink(dependant, resource: Resource);
      (* undo DependsOn operation *)
      VAR
         dependantDisc, resourceDisc: Discipline;
         prev, member: List;
   BEGIN
      GetDisc(resource, resourceDisc);
      IF resourceDisc.state = terminated THEN
         (* no necessity for clean up *)
         RETURN
      END;
      GetDisc(dependant, dependantDisc);

      prev := NIL; member := resourceDisc.dependants;
      WHILE member.resource # dependant DO
         prev := member; member := member.next;
      END;
      IF prev = NIL THEN
         resourceDisc.dependants := member.next;
      ELSE
         prev.next := member.next;
      END;

      (* Detach reference from dependant to resource *)
      Detach(dependantDisc.dependsOn, dependantDisc.key);
      dependantDisc.dependsOn := NIL; dependantDisc.key := NIL;
   END Unlink;

   PROCEDURE InternalNotify(resource: Resource; change: StateChange);
      VAR
         disc: Discipline;
         event: Event;
         dependant: List;
   BEGIN
      GetDisc(resource, disc);
      CASE change OF
      | communicationResumed: disc.stopped := FALSE;
      | communicationStopped: disc.stopped := TRUE;
      | terminated:           disc.stopped := FALSE; disc.state := terminated;
      ELSE (* Explicitly ignore unhandled values of change *)
      END;
      GenEvent(resource, change);

      (* notify all dependants *)
      dependant := disc.dependants;
      WHILE dependant # NIL DO
         InternalNotify(dependant.resource, change);
         dependant := dependant.next;
      END;

      (* remove dependency relation in case of termination, if present *)
      IF (change = terminated) & (disc.dependsOn # NIL) THEN
         Unlink(resource, disc.dependsOn);
      END;
   END InternalNotify;

   (* === exported procedures =========================================== *)

   PROCEDURE TakeInterest*(resource: Resource; VAR eventType: Events.EventType);
      (* return resource specific event type for state notifications;
         eventType is guaranteed to be # NIL even if
         the given resource is already terminated
      *)
      VAR
         disc: Discipline;
   BEGIN
      GetDisc(resource, disc);
      IF disc.eventType = NIL THEN
         Events.Define(disc.eventType);
         Events.Ignore(disc.eventType);
      END;
      eventType := disc.eventType;
   END TakeInterest;

   PROCEDURE Attach*(resource: Resource; VAR key: Key);
      (* mark the resource as being used until Detach gets called *)
      VAR
         disc: Discipline;
   BEGIN
      GetDisc(resource, disc);
      IF disc.state IN {terminated, unreferenced} THEN
         key := NIL;
      ELSE
         INC(disc.refcnt); NEW(key); key.valid := TRUE;
         key.resource := resource;
      END;
   END Attach;

   PROCEDURE Detach*(resource: Resource; key: Key);
      (* mark the resource as unused; the returned key of Attach must
         be given -- this allows to check for proper balances
         of Attach/Detach calls;
         the last Detach operation causes a state change to unreferenced
      *)
      VAR
         disc: Discipline;
   BEGIN
      IF (key # NIL) & key.valid & (key.resource = resource) THEN
         GetDisc(resource, disc);
         IF disc.state # terminated THEN
            key.valid := FALSE; DEC(disc.refcnt);
            IF disc.refcnt = 0 THEN
               GenEvent(resource, unreferenced);
               disc.state := unreferenced;
               IF disc.dependsOn # NIL THEN
                  Unlink(resource, disc.dependsOn);
               END;
            END;
         END;
      END;
   END Detach;

   PROCEDURE Notify*(resource: Resource; change: StateChange);
      (* notify all interested parties about the new state;
         only valid state changes are accepted:
         - Notify doesn't accept any changes after termination
         - unreferenced is generated conditionally by Detach only
         - communicationResumed is valid after communicationStopped only
         valid notifications are propagated to all dependants (see below);
      *)
      VAR
         disc: Discipline;
         event: Event;
         dependant: List;
   BEGIN
      IF change # unreferenced THEN
         GetDisc(resource, disc);
         IF (disc.state # terminated) & (disc.state # change) &
               ((change # communicationResumed) OR disc.stopped) THEN
            InternalNotify(resource, change);
         END;
      END;
   END Notify;

   PROCEDURE DependsOn*(dependant, resource: Resource);
      (* states that `dependant' depends entirely on `resource' --
         this is usually the case if operations on `dependant'
         are delegated to `resource';
         only one call of DependsOn may be given per `dependant' while
         several DependsOn for one resource are valid;
         DependsOn calls implicitly Attach for resource and
         detaches if the dependant becomes unreferenced;
         all other state changes propagate from `resource' to
         `dependant'
      *)
      VAR
         dependantDisc, resourceDisc: Discipline;
         member: List;
   BEGIN
      GetDisc(resource, resourceDisc);
      IF resourceDisc.state <= unreferenced THEN
         (* do not create a relationship to dead or unreferenced objects
            but propagate a termination immediately to dependant
         *)
         IF resourceDisc.state = terminated THEN
            Notify(dependant, resourceDisc.state);
         END;
         RETURN
      END;

      GetDisc(dependant, dependantDisc);
      IF dependantDisc.dependsOn # NIL THEN
         (* don't accept changes *)
         RETURN
      END;
      dependantDisc.dependsOn := resource;

      NEW(member); member.resource := dependant;
      member.next := resourceDisc.dependants;
      resourceDisc.dependants := member;
      Attach(resource, dependantDisc.key);
   END DependsOn;

   PROCEDURE Alive*(resource: Resource) : BOOLEAN;
      (* returns TRUE if the resource is not yet terminated
         and ready for communication (i.e. not communicationStopped)
      *)
      VAR
         disc: Discipline;
   BEGIN
      GetDisc(resource, disc);
      RETURN ~disc.stopped & (disc.state IN {alive, unreferenced})
   END Alive;

   PROCEDURE Stopped*(resource: Resource) : BOOLEAN;
      (* returns TRUE if the object is currently not responsive
         and not yet terminated
      *)
      VAR
         disc: Discipline;
   BEGIN
      GetDisc(resource, disc);
      RETURN disc.stopped
   END Stopped;

   PROCEDURE Terminated*(resource: Resource) : BOOLEAN;
      (* returns TRUE if the resource is terminated *)
      VAR
         disc: Discipline;
   BEGIN
      GetDisc(resource, disc);
      RETURN disc.state = terminated
   END Terminated;

BEGIN
   discID := Disciplines.Unique();
END ulmResources.
