-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.RuleStopState;

use ANTLR.Runtime.ATN.ATNStates;
use ANTLR.Runtime.ATN.RuleStopState;

package ANTLR.Runtime.ATN.RuleStartState is

   -- public final
   type RuleStartState is new ATNState with
   record
      -- public
      stopState : Optional_RuleStopState;
      -- public
      isPrecedenceRule : Boolean := False;
      --Synonymous with rule being left recursive; consider renaming.
   end record;

   overriding
   -- public
   function getStateType (This : RuleStartState) return State
      is (RULE_START);

end ANTLR.Runtime.ATN.RuleStartState;
