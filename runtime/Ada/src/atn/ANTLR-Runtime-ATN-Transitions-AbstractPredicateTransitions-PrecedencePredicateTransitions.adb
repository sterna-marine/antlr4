-- €

use ANTLR.Runtime.ATN;

package body ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions.PrecedencePredicateTransitions is

   procedure Initialize (Self : in out PrecedencePredicateTransition; target : ATNStates.ATNState; precedence : Integer) is
   begin
      Self.precedence := precedence;
      AbstractPredicateTransition.init (Target); -- Super
   end Initialize;

end ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions.PrecedencePredicateTransitions;
