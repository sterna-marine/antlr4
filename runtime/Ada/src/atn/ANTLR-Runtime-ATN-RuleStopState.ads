-- €

with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN.ATNStates;

package ANTLR.Runtime.ATN.RuleStopState is

   --
   -- The last node in the ATN for a rule, unless that rule is the start symbol.
   -- In that case, there is one transition to EOF. Later, we might encode
   -- references to all calls to this rule to compute FOLLOW sets for
   -- error handling.
   --

   -- public final
   type RuleStopState is new ATNState with null record;

   -- public
   overriding
   function getStateType (This : RuleStopState) return State
      is (RULE_STOP);

end ANTLR.Runtime.ATN.RuleStopState;
