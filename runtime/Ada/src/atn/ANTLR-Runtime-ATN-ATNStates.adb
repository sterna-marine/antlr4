-- €

with Ada.Containers;

use ANTLR.Runtime.Misc;
use ANTLR.Runtime.ATN;

package body ANTLR.Runtime.ATN.ATNStates is

   procedure hash (This : ATNState; Some_Hasher : in out Hasher) is
   begin
      Some_Hasher.combine (This.stateNumber);
   end hash;

   procedure addTransition (This : ATNState; e : Transition'Class) is
      alreadyPresent :Boolean := False;
   begin
      if Transitions.Container.isEmpty (This.Transitions) then
         This.epsilonOnlyTransitions := e.isEpsilon;
      elsif This.epsilonOnlyTransitions /= e.isEpsilon then
         This.epsilonOnlyTransitions := False;
         Text_IO.Put_Line ("ATN state " & This.stateNumber'Image & " has both epsilon and non-epsilon transitions.");
      end if;

      for t of This.Transitions loop
         if t.target.stateNumber = e.target.stateNumber then
            declare
               tLabel : constant IntervalSet := t.labelIntervalSet;
               eLabel : constant IntervalSet := e.labelIntervalSet;
               if Is_Valid (tLabel) and Is_Valid (eLabel) and tLabel = eLabel then
                  alreadyPresent := True;
                  -- Text_IO.Put_Line ("Repeated transition upon " & eLabel'Image & " from " & stateNumber'Image & "->" & t.target.stateNumber'Image);
                  exit when True;
               elsif t.isEpsilon () and then e.isEpsilon () then
                  alreadyPresent := True;
                  -- Text_IO.Put_Line ("Repeated epsilon transition from " & stateNumber'Image & "->" & t.target.stateNumber'Image);
                  exit when True;
               end if;
            end;
         end if;
      end loop;

      if not alreadyPresent then
         Transitions.Container.Append (Container => This.transitions, New_Item => e);
      end if;
   end addTransition;

   procedure setTransition (This : ATNState; i : Transitions.Container_Index; e : Transition) is
   begin
      Transitions.Container.Replace_Element (
         Container => This.transitions,
         Index => i,
         New_Item => e);
   end setTransition;

   -- public final
   function removeTransition (This : ATNState; Index : Transitions.Container_Index) return Transition is
      Element : Transition;
   begin
      Element := Transitions.Container.Element (Container => This.transitions, Index => Index);
      Transitions.Container.Delete (
         Container => This.transitions,
         Index => Index)
      return Element;
   end removeTransition;

    -- public
   function getStateType (This : ATNState) return Integer is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.ATNStates.getStateType() must be overridden";
   end getStateType;

    -- public final
    procedure setRuleIndex (This : ATNState; ruleIndex : Integer) is
    begin
        This.ruleIndex := ruleIndex;
    end if;

   -- public
   function "=" (Lhs : ATNState; Rhs : ATNState) return Boolean is
   begin
      --  if Lhs === Rhs then
      --     return True;
      --  else
         -- are these states same object?
      return Lhs.StateNumber = Rhs.StateNumber;
      --  end if;
   end "=";

end ANTLR.Runtime.ATN.ATNStates;