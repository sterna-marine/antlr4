-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.States;

use ANTLR.Runtime.ATN.States;

package ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions.PrecedencePredicateTransitions is

   -- public final
   type PrecedencePredicateTransition is new AbstractPredicateTransition with
   record
      -- public
      precedence : Integer; -- constant
   end record;

   subtype Object is PrecedencePredicateTransition;
   subtype Super is AbstractPredicateTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out PrecedencePredicateTransition; target : ATNState; precedence : Integer);

   overriding
   -- public
   function getSerializationType (This : PrecedencePredicateTransition) return Transitions.Transition
      is (Transitions.PRECEDENCE);

   overriding
   -- public
   function isEpsilon (This : PrecedencePredicateTransition) return Boolean
      is (True);

   overriding
   -- public
   function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (False);

   -- public
   function getPredicate (This : PrecedencePredicateTransition) return SemanticContext.PrecedencePredicate
      is (SemanticContext.PrecedencePredicate (This.precedence));

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_PrecedencePredicateTransition (S : in out Sink'Class; X : PrecedencePredicateTransition);
   for PrecedencePredicateTransition'Put_Image use Put_Image_PrecedencePredicateTransition;
-- public
   function Description (This : PrecedencePredicateTransition) return UString
      is (precedence'Image & "  >= _p");

end ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions.PrecedencePredicateTransitions;
