-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.BlockStartState;
with ANTLR.Runtime.ATN.PlusLoopbackState;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.BlockStartState;
use ANTLR.Runtime.ATN.PlusLoopbackState;

package ANTLR.Runtime.ATN.PlusBlockStartState is

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

   overriding
   -- public
   function getStateType (This : PlusBlockStartState) return State
      is (PLUS_BLOCK_START);

end ANTLR.Runtime.ATN.PlusBlockStartState;
