-- €

package body ANTLR.Runtime.ATN.DecisionEventInfos.PredicateEvalInfos is

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
      DecisionEventInfo.init (decision, This.ATNConfigSet, input, startIndex, stopIndex, fullCtx); -- Super
   end Initialize;

end package body ANTLR.Runtime.ATN.DecisionEventInfos.PredicateEvalInfos;
