-- €

package body ANTLR.Runtime.ATN.DecisionEventInfos.ContextSensitivityInfos is

   function "=" (Left, Right : ContextSensitivityInfo) return Boolean is
   begin
      return False; --TOFIX
   end "=";

   procedure Initialize (Self : in out ContextSensitivityInfo;
                  decision : Integer;
                  configs : ATNConfigSet;
                  input : TokenStream;
                  startIndex : Integer;
                  stopIndex : Integer) is
   begin
      Super (Self).Initialize (decision, configs, input, startIndex, stopIndex, True); -- Super
   end if;

end ANTLR.Runtime.ATN.DecisionEventInfos.ContextSensitivityInfos;
