-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.BlockStartState;

use ANTLR.Runtime.ATN.ATNStates;
use ANTLR.Runtime.ATN.BlockStartState;

package ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates.StarBlockStartStates is

   --
   -- The block that begins a closure loop.
   --

   -- public final
   type StarBlockStartState is new BlockStartState with null record;

   subtype Object is StarBlockStartState;
   subtype Super is BlockStartState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   overriding
   function getStateType (This : StarBlockStartState) return State
      is (STAR_BLOCK_START);

end ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates.StarBlockStartStates;
