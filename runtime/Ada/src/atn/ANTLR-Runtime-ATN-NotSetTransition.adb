-- €

with ANTLR.Runtime.ATN.Transitions;

use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.NotSetTransition is

   -- public final
   type NotSetTransition is new SetTransition with null record;

--	public override 
   procedure init (Self : in out NotSetTransition;
                   Target : ATNState; 
                   Set : in out Optional_IntervalSet) is
   begin
      SetTransition.init (Self, Target, Set); -- Super
   end Init;

   override
   -- public
   function getSerializationType (This : NotSetTransition) return Transitions.Transition is
   begin
      return Transitions.NOT_SET;
   end getSerializationType;

   override
   -- public
   function matches (This : NotSetTransition;
                     symbol : Integer;
                     minVocabSymbol : Integer;
                     maxVocabSymbol : Integer)
                     return Boolean is
   begin
      return symbol >= minVocabSymbol
             and then symbol <= maxVocabSymbol
             and then not super.matches (symbol, minVocabSymbol, maxVocabSymbol); -- TOFIX
   end matches;

   override
   -- public
   function Image return UString
      is ("~" & super.description); -- TOFIX

end ANTLR.Runtime.ATN.NotSetTransition;
