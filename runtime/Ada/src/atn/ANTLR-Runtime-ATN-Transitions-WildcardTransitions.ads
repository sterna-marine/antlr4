-- €

with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.Transitions;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.Transitions;

package ANTLR.Runtime.ATN.Transitions.WildcardTransitions is

   -- final public
   type WildcardTransition is new ATNTransition with null record;

   subtype Object is WildcardTransition;
   subtype Super is ATNTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

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

end ANTLR.Runtime.ATN.Transitions.WildcardTransitions;
