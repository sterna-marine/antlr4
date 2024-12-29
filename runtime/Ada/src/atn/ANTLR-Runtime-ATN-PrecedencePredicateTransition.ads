-- €

with ANTLR.Runtime.ATN.AbstractPredicateTransition;
with ANTLR.Runtime.ATN.Transitions;
with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.PredicateTransition is

   -- public final
   type PrecedencePredicateTransition is new AbstractPredicateTransition and CustomStringConvertible with
   record
      -- public
      precedence : constant Integer;
   end record;

   -- public
   procedure Initialize (Self : in out PrecedencePredicateTransition; target : ATNStates.ATNState; precedence : Integer);

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

   -- public
   function Description (This : …) return UString
      is (precedence'Image & "  >= _p");

end ANTLR.Runtime.ATN.PredicateTransition;
