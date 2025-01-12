-- €

package body ANTLR.Runtime.ATN.DecisionEventInfos.ErrorInfos is

   function "=" (Left, Right : ErrorInfo) return Boolean is
   begin
      False; --TOFIX
   end "=";

   procedure Initialize (Self : in out ErrorInfo;
                   decision : Integer;
                   configs : ATNConfigSet;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   fullCtx  : Boolean) is
   begin
      Super (Self).Initialize (decision, configs, input, startIndex, stopIndex, fullCtx); -- Super
   end Initialize;

end ANTLR.Runtime.ATN.DecisionEventInfos.ErrorInfos;
