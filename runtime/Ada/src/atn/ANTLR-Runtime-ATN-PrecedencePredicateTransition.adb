-- €

use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.PredicateTransition is 

   procedure Init (Self : in out PrecedencePredicateTransition; target : ATNStates.ATNState; precedence : Integer) is
   begin
      Self.precedence := precedence;
      AbstractPredicateTransition.init (Target); -- Super
   end Init;

end ANTLR.Runtime.ATN.PredicateTransition;
