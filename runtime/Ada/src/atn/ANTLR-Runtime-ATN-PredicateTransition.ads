-- €

with ANTLR.Runtime.ATN.AbstractPredicateTransition;
with ANTLR.Runtime.ATN.Transitions;
with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.SemanticContext;

use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.PredicateTransition is 


-- 
-- TODO: this is old comment:
-- A tree of semantic predicates from the grammar AST if label = SEMPRED.
-- In the ATN, labels will always be exactly one predicate, but the DFA
-- may have to combine a bunch of them as it collects predicates from
-- multiple ATN configurations into a single DFA state.
-- 

   -- public final
   type PredicateTransition is new AbstractPredicateTransition and CustomStringConvertible with
   record
      -- public
      ruleIndex : Integer; -- constant
      -- public
      predIndex : Integer; -- constant
      -- public
      isCtxDependent : Boolean; -- constant
      -- e.g., $i ref in pred
   end record;

   -- public 
   procedure Init (Self : in out PredicateTransition;
                   target : ATNState;
                   ruleIndex : Integer;
                   predIndex : Integer;
                   isCtxDependent : Boolean);

   override
   -- public
   function getSerializationType (This : PredicateTransition) return ATNTransition.Transition
      is (Transitions.PREDICATE);

   override
   -- public
   function isEpsilon (This : PredicateTransition) return Boolean
      is (True);

   override
   -- public
   function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (False);

   -- public
   function getPredicate (This : PredicateTransition) return SemanticContext.Predicate
      is (SemanticContext.Predicate (This.ruleIndex, This.predIndex, This.isCtxDependent));

   -- public
   function Image return UString
      is ("pred_" & ruleIndex'Image & ":" & predIndex'Image);

end ANTLR.Runtime.ATN.PredicateTransition;
