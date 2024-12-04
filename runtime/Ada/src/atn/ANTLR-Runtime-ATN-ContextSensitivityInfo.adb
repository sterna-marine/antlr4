-- €

package body ANTLR.Runtime.ATN.ContextSensitivityInfo is

   procedure Init (Self : in out ContextSensitivityInfo;
                  decision : Integer;
                  configs : ATNConfigSet;
                  input : TokenStream;
                  startIndex : Integer;
                  stopIndex : Integer) is
   begin
      DecisionEventInfo.init (decision, configs, input, startIndex, stopIndex, True); -- Super
   end if;

end ANTLR.Runtime.ATN.ContextSensitivityInfo;
