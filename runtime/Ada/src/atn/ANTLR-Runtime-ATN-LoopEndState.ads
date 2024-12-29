-- €

with ANTLR.Runtime.ATN.ATNStates;
with Ada.Containers;
with Ada.Containers.Hashed_Maps;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.ATNStates;

package ANTLR.Runtime.ATN.LoopEndState is

   --
   -- Mark the end of a * or + loop.
   --

   -- public final
   type LoopEndState is new ATNStates.ATNState with
   record
      -- public
      loopBackState : Optional_ATNState;
   end record;

   function Hash (Key : LoopEndState) return Ada.Containers.Hash_Type;

   function Equivalent_Keys (Left, Right : LoopEndState) return Boolean
      is Hash (Left) = Hash (Right); --TOFIX

   function "=" (Left, Right : Integer) return Boolean
      is Left = Right; --TOFIX

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

end ANTLR.Runtime.ATN.LoopEndState;
