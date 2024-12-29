-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.Transitions;

use ANTLR.Runtime.ATN.ATNStates;
use ANTLR.Runtime.ATN.Transitions;

package ANTLR.Runtime.ATN.WildcardTransition is

   -- final public
   type WildcardTransition is new ATNTransition and CustomStringConvertible with null record;

   -- public
   overriding
   procedure Initialize (Self : in out WildcardTransition; target : ATNState);

   overriding
   -- public
   function getSerializationType (This : WildcardTransition) return Integer
      is (Transition.WILDCARD);

   overriding
   -- public
   function matches (This : WildcardTransition; symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (symbol >= minVocabSymbol and then symbol <= maxVocabSymbol)

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_WildcardTransition (S : in out Sink'Class; X : WildcardTransition);
   for WildcardTransition'Put_Image use Put_Image_WildcardTransition;
   function Description (This : WildcardTransition) return UString
      is (".");

end ANTLR.Runtime.ATN.WildcardTransition;
