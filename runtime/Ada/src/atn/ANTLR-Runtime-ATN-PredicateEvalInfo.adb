-- €

package body ANTLR.Runtime.ATN.PredicateTransition is

   procedure Initialize (Self : in out PredicateEvalInfo; decision : Integer;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   semctx : SemanticContext;
                   evalResult : Boolean;
                   predictedAlt : Integer;
                   fullCtx  : Boolean) is
   begin
      self.semctx := semctx;
      self.evalResult := evalResult;
      self.predictedAlt := predictedAlt;
      DecisionEventInfo.init (decision, ATNConfigSet (), input, startIndex, stopIndex, fullCtx); -- Super
   end Initialize;

end package body ANTLR.Runtime.ATN.PredicateTransition;
