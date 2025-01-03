-- €

with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.SetTransition;
with ANTLR.Runtime.ATN.Transitions;
with ANTLR.Runtime.Misc.IntervalSets;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.SetTransition;
use ANTLR.Runtime.ATN.Transitions;
use ANTLR.Runtime.Misc.IntervalSets;

package ANTLR.Runtime.ATN.Transitions.SetTransitions.NotSetTransitions is

   -- public final
   type NotSetTransition is new SetTransition with null record;

   subtype Object is NotSetTransition;
   subtype Super is SetTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   overriding
   procedure Initialize (Self : in out NotSetTransition;
                   Target : ATNState;
                   Set : in out Optional_IntervalSet);

   overriding
   -- public
   function getSerializationType (This : NotSetTransition) return Transition
      is (Transitions.NOT_SET);

   overriding
   -- public
   function matches (This : NotSetTransition;
                     symbol : Integer;
                     minVocabSymbol : Integer;
                     maxVocabSymbol : Integer)
                     return Boolean;

   overriding
   -- public
   function Description (This : …) return UString
      is ("~" & Image (SetTransition (This))); -- TOFIX super

end ANTLR.Runtime.ATN.Transitions.SetTransitions.NotSetTransitions;
