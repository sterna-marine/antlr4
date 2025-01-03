-- €

with ANTLR.Runtime.ATN.States.RuleStopStates;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.States.RuleStopStates;

package ANTLR.Runtime.ATN.States.RuleStartStates is

   -- public final
   type RuleStartState is new ATNState with
   record
      -- public
      stopState : Optional_RuleStopState;
      -- public
      isPrecedenceRule : Boolean := False;
      --Synonymous with rule being left recursive; consider renaming.
   end record;

   subtype Object is RuleStartState;
   subtype Super is ATNState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   overriding
   -- public
   function getStateType (This : RuleStartState) return State
      is (RULE_START);

end ANTLR.Runtime.ATN.States.RuleStartStates;
