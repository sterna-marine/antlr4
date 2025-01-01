-- €

with Ada.Containers.Hashed_Maps;

package ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates is

--
-- The start of a regular `( .. )` block.
--

   -- public
   type BlockStartState is new DecisionState with
   record
      -- public
      endState : Optional_BlockEndState;
   end record;

   subtype Object is BlockStartState;
   subtype Super is DecisionState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function Hash (Key : BlockStartState) return Ada.Containers.Hash_Type;

   function Equivalent_Keys (Left, Right : BlockStartState) return Boolean
      is Hash (Left) = Hash (Right); --TOFIX

   function "=" (Left, Right : Integer) return Boolean
      is Left = Right; --TOFIX

   package BlockStartState_Maps is new Ada.Containers.Hashed_Maps (
      Key_Type => BlockStartState,
      Element_Type => Integer,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype BlockStartState_Map is BlockStartState_Maps.Map;

end ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates;