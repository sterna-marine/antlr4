-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.BlockStartState;

use ANTLR.Runtime.ATN.ATNStates;
use ANTLR.Runtime.ATN.BlockStartState;

package ANTLR.Runtime.ATN.StarBlockStartState is

   --
   -- The block that begins a closure loop.
   --

   -- public final
   type StarBlockStartState is new BlockStartState with null record;

      -- public
      overriding
      function getStateType (This : StarBlockStartState) return State
         is (STAR_BLOCK_START);

end ANTLR.Runtime.ATN.StarBlockStartState;
