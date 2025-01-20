-- €

package body ANTLR.Runtime.ATN.DecisionEventInfos is

   procedure Initialize (Self : in out DecisionEventInfo;
                  decision : State;
                  configs : Optional_ATNConfigSet;
                  input : TokenStream;
                  startIndex, stopIndex : Integer;
                  fullCtx  : Boolean) is
   begin
      self.decision := decision;
      self.fullCtx := fullCtx;
      self.stopIndex := stopIndex;
      self.input := input;
      self.startIndex := startIndex;
      self.configs := configs;
   end Initialize;

end ANTLR.Runtime.ATN.DecisionEventInfos;
