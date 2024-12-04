-- €

package body ANTLR.Runtime.ATN.ErrorInfo is

   procedure Init (Self : in out ErrorInfo;
                   decision : Integer;
                   configs : ATNConfigSet;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   fullCtx  : Boolean) is
   begin
      DecisionEventInfo.Init (decision, configs, input, startIndex, stopIndex, fullCtx); -- Super
   end Init;

end ANTLR.Runtime.ATN.ErrorInfo;
