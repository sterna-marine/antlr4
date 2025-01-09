-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.SemanticContext;
with ANTLR.Runtime.ATN.States;

use ANTLR.Runtime.ATN.SemanticContext;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions;

package ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions.PredicateTransitions is

   use ANTLR.Runtime.ATN.Transitions;

   --
   -- TODO: this is old comment:
   -- A tree of semantic predicates from the grammar AST if label = SEMPRED.
   -- In the ATN, labels will always be exactly one predicate, but the DFA
   -- may have to combine a bunch of them as it collects predicates from
   -- multiple ATN configurations into a single DFA state.
   --

   -- public final
   type PredicateTransition is new AbstractPredicateTransition with
   record
      -- public
      ruleIndex : Integer; -- constant
      -- public
      predIndex : Integer; -- constant
      -- public
      isCtxDependent : Boolean; -- constant
      -- e.g., $i ref in pred
   end record;

   subtype Object is PredicateTransition;
   subtype Super is AbstractPredicateTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out PredicateTransition;
                   target : ATNState;
                   ruleIndex : Integer;
                   predIndex : Integer;
                   isCtxDependent : Boolean);

   overriding
   -- public
   function getSerializationType (This : PredicateTransition) return ATNTransition.Transition
      is (Transitions.PREDICATE);

   overriding
   -- public
   function isEpsilon (This : PredicateTransition) return Boolean
      is (True);

   overriding
   -- public
   function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (False);

   -- public
   function getPredicate (This : PredicateTransition) return SemanticContext.Predicate
      is (SemanticContext.Predicate (This.ruleIndex, This.predIndex, This.isCtxDependent));

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_PredicateTransition (S : in out Sink'Class; X : PredicateTransition);
   for PredicateTransition'Put_Image use Put_Image_PredicateTransition;
   -- public
   function Description (This : PredicateTransition) return UString
      is ("pred_" & This.ruleIndex'Image & ':' & This.predIndex'Image);

end ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions.PredicateTransitions;
