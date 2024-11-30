-- €

package ANTLR.Runtime.ATN.BlockStartState is

-- 
-- The start of a regular `( .. )` block.
-- 

   -- public
   type BlockStartState is new DecisionState with 
   record
      -- public
      endState : Optional_BlockEndState;
   end record;

end ANTLR.Runtime.ATN.BlockStartState;