-- €

package body ANTLR.Runtime.ATN.DecisionEventInfo is

   procedure Initialize (Self : in out DecisionEventInfo;
                  decision : Integer;
                  configs : Optional_ATNConfigSet;
                  input : TokenStream;
                  startIndex : Integer;
                  stopIndex : Integer;
                  fullCtx  : Boolean) is
   begin
      self.decision := decision;
      self.fullCtx := fullCtx;
      self.stopIndex := stopIndex;
      self.input := input;
      self.startIndex := startIndex;
      self.configs := configs;
   end Initialize;

end ANTLR.Runtime.ATN.DecisionEventInfo;
