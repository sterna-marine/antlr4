-- €

package body ANTLR.Runtime.ATN.PredicateTransition is 

   -- 
   -- TODO: this is old comment:
   -- A tree of semantic predicates from the grammar AST if label = SEMPRED.
   -- In the ATN, labels will always be exactly one predicate, but the DFA
   -- may have to combine a bunch of them as it collects predicates from
   -- multiple ATN configurations into a single DFA state.
   -- 

   procedure Init (Self : in out PredicateTransition;
                   target : ATNState;
                   ruleIndex : Integer;
                   predIndex : Integer;
                   isCtxDependent : Boolean) is
   begin
      Self.ruleIndex := ruleIndex;
      Self.predIndex := predIndex;
      Self.isCtxDependent := isCtxDependent;
      AbstractPredicateTransition.Init (target); -- Super
   end Init;

end ANTLR.Runtime.ATN.PredicateTransition;
