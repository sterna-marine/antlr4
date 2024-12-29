-- €

with ANTLR.Runtime.ATN.Transitions;

use ANTLR.Runtime.ATN.Transitions;

package ANTLR.Runtime.ATN.RuleTransition is

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

end ANTLR.Runtime.ATN.RuleTransition;
