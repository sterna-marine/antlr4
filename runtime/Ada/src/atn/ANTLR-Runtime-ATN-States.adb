-- €

with Ada.Containers;
with Ada.Wide_Wide_Text_IO;
with Aspect;

use Ada;
use Aspect;

package body ANTLR.Runtime.ATN.States is

   function Hash (Element : ATNState) return Ada.Containers.Hash_Type is
   begin
      return 0; --TOFIX
   end Hash;

   function Equivalent_Elements (Left, Right : ATNState) return Boolean is
   begin
      return Hash (Left) = Hash (Right); 
   end Equivalent_Elements;

   function "=" (Left, Right : ATNState) return Boolean is
   begin
      return Left = Right; --TOFIX
   end "=";

   procedure hash (This : ATNState; Some_Hasher : in out Hasher) is
   begin
      Some_Hasher.combine (This.stateNumber);
   end hash;

   procedure addTransition (This : ATNState; e : ATNTransition'Class) is
      alreadyPresent :Boolean := False;
   begin
      if Transitions_List.isEmpty (This.Transitions) then
         This.epsilonOnlyTransitions := e.isEpsilon;
      elsif This.epsilonOnlyTransitions /= e.isEpsilon then
         This.epsilonOnlyTransitions := False;
         Wide_Wide_Text_IO.Put_Line ("ATN state " & This.stateNumber'Image & " has both epsilon and non-epsilon transitions.");
      end if;

      for t of This.Transitions loop
         if t.target.stateNumber = e.target.stateNumber then
            declare
               tLabel : constant IntervalSet := t.labelIntervalSet;
               eLabel : constant IntervalSet := e.labelIntervalSet;
            begin
               if Is_Valid (tLabel) and Is_Valid (eLabel) and tLabel = eLabel then
                  alreadyPresent := True;
                  if Is_Active (Aspect.DEBUG) then
                     Wide_Wide_Text_IO.Put_Line ("Repeated transition upon " & eLabel'Image & " from " & stateNumber'Image & "->" & t.target.stateNumber'Image);
                  end if;
                  exit when True;
               elsif t.isEpsilon and then e.isEpsilon then
                  alreadyPresent := True;
                  if Is_Active (Aspect.DEBUG) then
                     Wide_Wide_Text_IO.Put_Line ("Repeated epsilon transition from " & stateNumber'Image & "->" & t.target.stateNumber'Image);
                  end if;
                  exit when True;
               end if;
            end;
         end if;
      end loop;

      if not alreadyPresent then
         Transitions_List.Append (Container => This.transitions, New_Item => e);
      end if;
   end addTransition;

   procedure setTransition (This : ATNState; i : Transitions_List_Index; e : ATNTransition) is
   begin
      Transitions_List.Replace_Element (
         Container => This.transitions,
         Index => i,
         New_Item => e);
   end setTransition;

   -- public final
   function removeTransition (This : ATNState; Index : Transitions_List_Index) return Transition is
      Element : ATNTransition;
   begin
      Element := Transitions_List.Element (Container => This.transitions, Index => Index);
      Transitions_List.Delete (Container => This.transitions,
         Index => Index);
      return Element;
   end removeTransition;

    -- public
   function getStateType (This : ATNState) return Integer is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.States.getStateType() must be overridden";
   end getStateType;

    -- public final
    procedure setRuleIndex (This : ATNState; ruleIndex : Integer) is
    begin
        This.ruleIndex := ruleIndex;
    end setRuleIndex;

   -- public
   function "=" (Lhs, Rhs : ATNState) return Boolean is
   begin
      --  if Lhs === Rhs then
      --     return True;
      --  else
         -- are these states same object?
      return Lhs.StateNumber = Rhs.StateNumber;
      --  end if;
   end "=";

end ANTLR.Runtime.ATN.States;