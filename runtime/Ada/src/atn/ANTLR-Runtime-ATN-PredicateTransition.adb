-- €

package body ANTLR.Runtime.ATN.PredicateTransition is

   procedure Initialize (Self : in out PredicateTransition;
                   target : ATNState;
                   ruleIndex : Integer;
                   predIndex : Integer;
                   isCtxDependent : Boolean) is
   begin
      Self.ruleIndex := ruleIndex;
      Self.predIndex := predIndex;
      Self.isCtxDependent := isCtxDependent;
      AbstractPredicateTransition.Init (target); -- Super
   end Initialize;

end ANTLR.Runtime.ATN.PredicateTransition;
