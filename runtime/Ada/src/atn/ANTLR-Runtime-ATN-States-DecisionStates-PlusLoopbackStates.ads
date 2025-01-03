-- €

with Option;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.States;

package ANTLR.Runtime.ATN.States.DecisionStates.PlusLoopbackStates is

   --
   -- Decision state for `A+` and `(A|B)+`.  It has two transitions:
   -- one to the loop back to start of the block and one to exit.
   --

   -- public final
   type PlusLoopbackState is new DecisionState with null record;

   package Option_PlusLoopbackState is new Option (PlusLoopbackState);
   subtype Optional_PlusLoopbackState is Option_PlusLoopbackState.Optional; -- renames

   overriding
   -- public
   function getStateType (This : PlusLoopbackState) return State
      is (PLUS_LOOP_BACK);

end ANTLR.Runtime.ATN.States.DecisionStates.PlusLoopbackStates;
