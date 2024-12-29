-- €

package body ANTLR.Runtime.ATN.Transitions.SetTransitions.NotSetTransitions is

   overriding
   procedure Initialize (Self : in out NotSetTransition;
                   Target : ATNState;
                   Set : in out Optional_IntervalSet) is
   begin
      SetTransition.init (Self, Target, Set); -- Super
   end Initialize;

   overriding
   function matches (This : NotSetTransition;
                     symbol : Integer;
                     minVocabSymbol : Integer;
                     maxVocabSymbol : Integer)
                     return Boolean is
   begin
      return symbol >= minVocabSymbol
             and then symbol <= maxVocabSymbol
             and then not SetTransition.matches (SetTransition (This), symbol, minVocabSymbol, maxVocabSymbol); -- TOFIX super
   end matches;

end ANTLR.Runtime.ATN.Transitions.SetTransitions.NotSetTransitions;
