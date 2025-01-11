-- €

with ANTLR.Runtime.ATN.States;

use ANTLR.Runtime.ATN.States;

package ANTLR.Runtime.ATN.Transitions.RuleTransitions is

   use ANTLR.Runtime.ATN.Transitions;

   -- public final
   type RuleTransition is new ATNTransition with
   record
      --
      -- Ptr to the rule definition object for this rule ref
      --
      -- public
      ruleIndex : Integer; -- constant
      -- no Rule object at runtime

      -- public
      precedence : Integer; -- constant

      --
      -- What node to begin computations following ref to rule
      --
      -- public
      followState : ATNState; -- constant
   end record;

   subtype Object is RuleTransition;
   subtype Super is ATNTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out RuleTransition;
                   ruleStart : RuleStartState;
                   ruleIndex : Integer;
                   precedence : Integer;
                   followState : ATNState);

   -- public
   overriding
   function getSerializationType (This : RuleTransition) return Integer
      is (RULE);

   -- public
   overriding
   function isEpsilon (This : RuleTransition) return Boolean
      is (True);

   overriding
   -- public
   function matches (This : RuleTransition; symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (False);

end ANTLR.Runtime.ATN.Transitions.RuleTransitions;
