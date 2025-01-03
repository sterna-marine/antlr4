-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.States;

package ANTLR.Runtime.ATN.States.LoopEndStates is

   --
   -- Mark the end of a * or + loop.
   --

   -- public final
   type LoopEndState is new ATNState with
   record
      -- public
      loopBackState : Optional_ATNState;
   end record;

   subtype Object is LoopEndState;
   subtype Super is ATNState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function Hash (Key : LoopEndState) return Ada.Containers.Hash_Type;

   function Equivalent_Keys (Left, Right : LoopEndState) return Boolean
      is (Hash (Left) = Hash (Right)); --TOFIX

   function "=" (Left, Right : Integer) return Boolean
      is (Left = Right); --TOFIX

   package LoopEndState_Maps is new Ada.Containers.Hashed_Maps (
      Key_Type => LoopEndState,
      Element_Type => Integer,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype LoopEndState_Map is LoopEndState_Maps.Map;

   overriding
   -- public
   function getStateType (This : LoopEndState) return ATNStates.State
      is (ATNStates.LOOP_END);

end ANTLR.Runtime.ATN.States.LoopEndStates;
