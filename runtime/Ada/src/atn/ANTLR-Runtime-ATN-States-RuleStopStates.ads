-- €

use ANTLR.Runtime.ATN.States;

package ANTLR.Runtime.ATN.States.RuleStopStates is

   --
   -- The last node in the ATN for a rule, unless that rule is the start symbol.
   -- In that case, there is one transition to EOF. Later, we might encode
   -- references to all calls to this rule to compute FOLLOW sets for
   -- error handling.
   --

   -- public final
   type RuleStopState is new ATNState with null record;

   subtype Object is RuleStopState;
   subtype Super is ATNState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   overriding
   function getStateType (This : RuleStopState) return State
      is (RULE_STOP);

end ANTLR.Runtime.ATN.States.RuleStopStates;
