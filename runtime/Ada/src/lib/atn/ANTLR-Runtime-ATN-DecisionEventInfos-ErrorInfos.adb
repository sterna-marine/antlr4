-- €

package body ANTLR.Runtime.ATN.DecisionEventInfos.ErrorInfos is

   function "=" (Left, Right : ErrorInfo) return Boolean is
   begin
      False; --TOFIX
   end "=";

   procedure Initialize (Self : in out ErrorInfo;
                   decision : State;
                   configs : ATNConfigSet;
                   input : TokenStream;
                   startIndex, stopIndex : Integer;
                   fullCtx  : Boolean) is
   begin
      Super (Self).Initialize (decision, configs, input, startIndex, stopIndex, fullCtx); -- Super
   end Initialize;

   function Initialize (decision : State;
                        configs : ATNConfigSet;
                        input : TokenStream;
                        startIndex, stopIndex : Integer;
                        fullCtx  : Boolean)
                        return ErrorInfo is
      Self : ErrorInfo;   
   begin
      Self.Initialize (decision,
                       configs,
                       input,
                       startIndex,
                       stopIndex,
                       fullCtx);
      return Self;
   end Initialize;

end ANTLR.Runtime.ATN.DecisionEventInfos.ErrorInfos;
