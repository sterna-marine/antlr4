-- €

with ANTLR.Runtime.ATN.States.DecisionStates.PlusLoopbackStates;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates;
use ANTLR.Runtime.ATN.States.DecisionStates.PlusLoopbackStates;

package ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates.PlusBlockStartStates is

   --
   -- Start of `(A|B| .. )+` loop. Technically a decision state, but
   -- we don't use for code generation; somebody might need it, so I'm defining
   -- it for completeness. In reality, the _org.antlr.v4.runtime.atn.PlusLoopbackState_ node is the
   -- real decision-making note for `A+`.
   --

   -- public final
   type PlusBlockStartState is new BlockStartState with
   record
      -- public
      loopBackState : Optionaal_PlusLoopbackState;
   end record;

   subtype Object is PlusBlockStartState;
   subtype Super is BlockStartState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   overriding
   -- public
   function getStateType (This : PlusBlockStartState) return State
      is (PLUS_BLOCK_START);

end ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates.PlusBlockStartStates;
