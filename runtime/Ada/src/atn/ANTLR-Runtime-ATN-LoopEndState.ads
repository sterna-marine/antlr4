-- €

with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN;

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

   override
   -- public
   function getStateType (This : LoopEndState) return ATNStates.State is
   begin
      return ATNStates.LOOP_END;
   end getStateType;

end ANTLR.Runtime.ATN.LoopEndState;
