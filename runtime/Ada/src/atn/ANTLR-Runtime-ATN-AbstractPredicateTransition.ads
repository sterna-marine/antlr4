-- €

with ANTLR.Runtime.ATN.Transition;
with ANTLR.Runtime.ATN.ATNState;
use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.AbstractPredicateTransition is

   -- public
   type AbstractPredicateTransition is new Transition with null record;

   --public override 
   procedure Init (Self : in out AbstractPredicateTransition; target : ATNState);

end ANTLR.Runtime.ATN.AbstractPredicateTransition;
