-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.DecisionState;

use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.PlusLoopbackState is 

   -- 
   -- Decision state for `A+` and `(A|B)+`.  It has two transitions:
   -- one to the loop back to start of the block and one to exit.
   -- 

   -- public final
   type PlusLoopbackState is new DecisionState with null record;

   package Option_PlusLoopbackState is new Option (PlusLoopbackState);

   override
   -- public
   function getStateType (This : PlusLoopbackState) return ATNStates.State
      is ATNStates.PLUS_LOOP_BACK;

end ANTLR.Runtime.ATN.PlusLoopbackState;
