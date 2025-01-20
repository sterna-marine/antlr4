-- €

package body ANTLR.Runtime.ATN.DecisionEventInfos.PredicateEvalInfos is

   procedure Initialize (Self : in out PredicateEvalInfo;
                         decision : State;
                         input : TokenStream;
                         startIndex, stopIndex : Integer;
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

   function Initialize (decision : State;
                        input : TokenStream;
                        startIndex, stopIndex : Integer;
                        semctx : SemanticContext;
                        evalResult : Boolean;
                        predictedAlt : Integer;
                        fullCtx  : Boolean)
                        return PredicateEvalInfo is
      Self : PredicateEvalInfo;
   begin
      Self.Initialize (decision,
                       input,
                       startIndex, stopIndex,
                       semctx,
                       evalResult,
                       predictedAlt,
                       fullCtx);
      return Self;
   end Initialize;

end ANTLR.Runtime.ATN.DecisionEventInfos.PredicateEvalInfos;
