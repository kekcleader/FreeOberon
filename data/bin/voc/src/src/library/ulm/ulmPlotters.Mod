(* Ulm's Oberon Library
   Copyright (C) 1989-2004 by University of Ulm, SAI, D-89069 Ulm, Germany
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
   $Id: Plotters.om,v 1.1 2004/04/08 12:30:29 borchert Exp borchert $
   ----------------------------------------------------------------------------
   $Log: Plotters.om,v $
   Revision 1.1  2004/04/08 12:30:29  borchert
   Initial revision

   ----------------------------------------------------------------------------
*)

MODULE ulmPlotters;

   IMPORT Events := ulmEvents, Objects := ulmObjects, Resources := ulmResources, Services := ulmServices, SYS := ulmSYSTEM, Types := ulmTypes;

   TYPE
      Plotter* = POINTER TO PlotterRec;

   CONST
      solid* = 0;
      dotted* = 1;
      dotdashed* = 2;
      shortdashed* = 3;
      longdashed* = 4;
      lineModes* = 5;
   TYPE
      LineMode* = Types.Int8; (* solid ... *)

   CONST
      setspace* = 0;
      erase* = 1;
      string* = 2;
      linemodes* = 3;
      linewidth* = 4;
   TYPE
      CapabilitySet* = Types.Set; (* OF setspace, erase ... *)

   TYPE
      Description* = POINTER TO DescriptionRec;
      DescriptionRec* =
	 RECORD
	    (Objects.ObjectRec)
	    xmin*, ymin, xmax, ymax: Types.Int32; (* maximal supported range *)
	 END;

   TYPE
      GetSpaceProc* = PROCEDURE (
	 plotter: Plotter;
	 VAR xmin, ymin, xmax, ymax: Types.Int32);
      SetSpaceProc* = PROCEDURE (
	 plotter: Plotter;
	 xmin, ymin, xmax, ymax: Types.Int32);
      EraseProc* = PROCEDURE (plotter: Plotter);
      MoveProc* = PROCEDURE (plotter: Plotter; xto, yto: Types.Int32);
      LineProc* = PROCEDURE (plotter: Plotter; xfrom, yfrom, xto, yto: Types.Int32);
      ArcProc* = PROCEDURE (
	 plotter: Plotter;
	 xcenter, ycenter, xstart, ystart, xend, yend: Types.Int32);
      CircleProc* = PROCEDURE (
         plotter: Plotter; xcenter, ycenter, radius: Types.Int32);
      StringProc* = PROCEDURE (plotter: Plotter; str: ARRAY OF CHAR);
      SetLineModeProc* = PROCEDURE (plotter: Plotter; mode: LineMode);
      SetLineWidthProc* = PROCEDURE (plotter: Plotter; width: Types.Int32);
      CloseProc* = PROCEDURE (plotter: Plotter);
   TYPE
      Interface* = POINTER TO InterfaceRec;
      InterfaceRec* =
	 RECORD
	    (Objects.ObjectRec)
	    setSpace*: SetSpaceProc;
	    erase*: EraseProc;
	    move*: MoveProc;
	    cont*: MoveProc;
	    point*: MoveProc;
	    line*: LineProc;
	    arc*: ArcProc;
	    circle*: CircleProc;
	    string*: StringProc;
	    setLineMode*: SetLineModeProc;
	    setLineWidth*: SetLineWidthProc;
	    close*: CloseProc;
	 END;

   TYPE
      PlotterRec* =
	 RECORD
	    (Services.ObjectRec)
	    if: Interface;
	    caps: CapabilitySet;
	    desc: Description;
	    xmin, ymin, xmax, ymax: Types.Int32; (* current range *)
	    terminated: BOOLEAN;
	 END;
   VAR
      plotterType: Services.Type;

   PROCEDURE InitModule;
   BEGIN
      Services.CreateType(plotterType, "Plotters.Plotter", "");
   END InitModule;

   PROCEDURE ^ Close*(plotter: Plotter);

   PROCEDURE TerminationHandler(event: Events.Event);
      VAR
	 plotter: Plotter;
   BEGIN
      WITH event: Resources.Event DO
	 IF event.change IN {Resources.terminated, Resources.unreferenced} THEN
	    Close(event.resource(Plotter));
	 END;
      END;
   END TerminationHandler;

   PROCEDURE Init*(plotter: Plotter; if: Interface;
		  caps: CapabilitySet; desc: Description);
      VAR
	 eventType: Events.EventType;
   BEGIN
      ASSERT((if # NIL) & (if.move # NIL) & (if.cont # NIL) &
	 (if.point # NIL) & (if.line # NIL) & (if.arc # NIL) &
	 (if.circle # NIL));
      ASSERT(~(setspace IN caps) OR (if.setSpace # NIL));
      ASSERT(~(erase IN caps) OR (if.erase # NIL));
      ASSERT(~(string IN caps) OR (if.string # NIL));
      ASSERT(~(linemodes IN caps) OR (if.setLineMode # NIL));
      ASSERT(~(linewidth IN caps) OR (if.setLineWidth # NIL));
      ASSERT((desc.xmin < desc.xmax) & (desc.ymin < desc.ymax));
      plotter.if := if;
      plotter.caps := caps;
      plotter.desc := desc;
      plotter.xmin := desc.xmin;
      plotter.xmax := desc.xmax;
      plotter.ymin := desc.ymin;
      plotter.ymax := desc.ymax;
      plotter.terminated := FALSE;
      Resources.TakeInterest(plotter, eventType);
      Events.Handler(eventType, TerminationHandler);
   END Init;

   PROCEDURE GetCapabilities*(plotter: Plotter) : CapabilitySet;
   BEGIN
      RETURN plotter.caps
   END GetCapabilities;

   PROCEDURE GetSpace*(plotter: Plotter;
                      VAR xmin, ymin,
		      xmax, ymax: Types.Int32);
   BEGIN
      xmin := plotter.xmin;
      xmax := plotter.xmax;
      ymin := plotter.ymin;
      ymax := plotter.ymax;
   END GetSpace;

   PROCEDURE GetMaxSpace*(plotter: Plotter;
                         VAR xmin, ymin,
		         xmax, ymax: Types.Int32);
   BEGIN
      xmin := plotter.desc.xmin;
      xmax := plotter.desc.xmax;
      ymin := plotter.desc.ymin;
      ymax := plotter.desc.ymax;
   END GetMaxSpace;

   PROCEDURE SetSpace*(plotter: Plotter;
                      xmin, ymin,
		      xmax, ymax: Types.Int32);
   BEGIN
      ASSERT((xmin < xmax) & (ymin < ymax));
      ASSERT((xmin >= plotter.desc.xmin) &
             (xmax <= plotter.desc.xmax) &
	     (ymin >= plotter.desc.ymin) &
	     (ymax <= plotter.desc.ymax));
      ASSERT(setspace IN plotter.caps);
      plotter.if.setSpace(plotter, xmin, ymin, xmax, ymax);
      plotter.xmin := xmin;
      plotter.ymin := ymin;
      plotter.xmax := xmax;
      plotter.ymax := ymax;
   END SetSpace;
		     
   PROCEDURE Erase*(plotter: Plotter);
   BEGIN
      ASSERT(erase IN plotter.caps);
      plotter.if.erase(plotter);
   END Erase;

   PROCEDURE Move*(plotter: Plotter; xto, yto: Types.Int32);
   BEGIN
      plotter.if.move(plotter, xto, yto);
   END Move;

   PROCEDURE Cont*(plotter: Plotter; xto, yto: Types.Int32);
   BEGIN
      plotter.if.cont(plotter, xto, yto);
   END Cont;

   PROCEDURE Point*(plotter: Plotter; xpoint, ypoint: Types.Int32);
   BEGIN
      plotter.if.point(plotter, xpoint, ypoint);
   END Point;

   PROCEDURE Line*(plotter: Plotter; xfrom, yfrom, xto, yto: Types.Int32);
   BEGIN
      plotter.if.line(plotter, xfrom, yfrom, xto, yto);
   END Line;

   PROCEDURE Arc*(plotter: Plotter;
                 xcenter, ycenter, xstart, ystart, xend, yend: Types.Int32);
   BEGIN
      plotter.if.arc(plotter, xcenter, ycenter, xstart, ystart, xend, yend);
   END Arc;

   PROCEDURE Circle*(plotter: Plotter; xcenter, ycenter, radius: Types.Int32);
   BEGIN
      plotter.if.circle(plotter, xcenter, ycenter, radius);
   END Circle;

   PROCEDURE String*(plotter: Plotter; str: ARRAY OF CHAR);
   BEGIN
      ASSERT(string IN plotter.caps);
      plotter.if.string(plotter, str);
   END String;

   PROCEDURE SetLineMode*(plotter: Plotter; mode: LineMode);
   BEGIN
      ASSERT((linemodes IN plotter.caps) & (mode >= 0) & (mode < lineModes));
      plotter.if.setLineMode(plotter, mode);
   END SetLineMode;

   PROCEDURE SetLineWidth*(plotter: Plotter; width: Types.Int32);
   BEGIN
      ASSERT((linewidth IN plotter.caps) & (width > 0));
      plotter.if.setLineWidth(plotter, width);
   END SetLineWidth;

   PROCEDURE Close*(plotter: Plotter);
   BEGIN
      IF ~SYS.TAS(plotter.terminated) THEN
	 IF plotter.if.close # NIL THEN
	    plotter.if.close(plotter);
	 END;
	 Resources.Notify(plotter, Resources.terminated);
	 plotter.if := NIL; plotter.desc := NIL;
      END;
   END Close;

BEGIN
   InitModule;
END ulmPlotters.
