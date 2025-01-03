-- €

with ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates;

use ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates;

package ANTLR.Runtime.ATN.States.BlockEndStates is

--
-- Terminal node of a simple `(a|b|c)` block.
--

   -- public final
   type BlockEndState is new ATNState with
   record
      -- public
      startState : Optional_BlockStartState;
   end record;

   subtype Object is BlockEndState;
   subtype Super is ATNState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   overriding
   -- public
   function getStateType (This : BlockEndState) return Integer
      is (This.ATNState.BLOCK_END);

end ANTLR.Runtime.ATN.States.BlockEndStates;
