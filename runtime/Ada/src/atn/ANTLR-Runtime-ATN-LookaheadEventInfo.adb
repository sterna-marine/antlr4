-- €

package body ANTLR.Runtime.ATN.LookaheadEventInfo is

   overriding
   procedure Initialize (Self : in out LookaheadEventInfo;
                   decision : Integer;
                   configs : Optional_ATNConfigSet;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   fullCtx  : Boolean) is
   begin
      DecisionEventInfo.init (Self, decision, configs, input, startIndex, stopIndex, fullCtx); -- super
   end Initialize;

end ANTLR.Runtime.ATN.LookaheadEventInfo;
