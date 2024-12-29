-- €

package body ANTLR.Runtime.ATN.ErrorInfo is

   procedure Initialize (Self : in out ErrorInfo;
                   decision : Integer;
                   configs : ATNConfigSet;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   fullCtx  : Boolean) is
   begin
      DecisionEventInfo.Init (Self, decision, configs, input, startIndex, stopIndex, fullCtx); -- Super
   end Initialize;

end ANTLR.Runtime.ATN.ErrorInfo;
