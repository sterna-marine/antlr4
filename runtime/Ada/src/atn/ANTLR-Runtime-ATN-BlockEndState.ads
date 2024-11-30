-- €

package body ANTLR.Runtime.ATN.BasicEndState is

-- 
-- Terminal node of a simple `(a|b|c)` block.
-- 

   -- public final
   type BlockEndState is new ATNState with
   record;
      -- public
      startState : Optional_BlockStartState;
   end record;

   override
   -- public
   function getStateType (This : BlockEndState) return Integer
      is ( This.ATNState.BLOCK_END);

end ANTLR.Runtime.ATN.BasicEndState;
