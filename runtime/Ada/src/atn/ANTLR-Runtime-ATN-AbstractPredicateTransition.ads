-- €

with ANTLR.Runtime.ATN.Transitions;
with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.ATNStates;
use ANTLR.Runtime.ATN.Transitions;

package ANTLR.Runtime.ATN.AbstractPredicateTransition is

   -- public
   type AbstractPredicateTransition is new ATNTransition with null record;

   --public override
   procedure Initialize (Self : in out AbstractPredicateTransition; target : ATNState);

end ANTLR.Runtime.ATN.AbstractPredicateTransition;
