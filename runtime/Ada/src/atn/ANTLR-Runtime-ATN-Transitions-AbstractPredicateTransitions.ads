-- €

with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.ATNStates;

package ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions is

   use ANTLR.Runtime.ATN.Transitions;

   -- public
   type AbstractPredicateTransition is new ATNTransition with null record;

   subtype Object is AbstractPredicateTransition;
   subtype Super is ATNTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   --public
   override
   procedure Initialize (Self : in out AbstractPredicateTransition; target : ATNState);

end ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions;
