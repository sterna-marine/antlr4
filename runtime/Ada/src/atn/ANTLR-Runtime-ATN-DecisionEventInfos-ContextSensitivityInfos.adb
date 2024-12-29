-- €

package body ANTLR.Runtime.ATN.DecisionEventInfos.ContextSensitivityInfos is

   procedure Initialize (Self : in out ContextSensitivityInfo;
                  decision : Integer;
                  configs : ATNConfigSet;
                  input : TokenStream;
                  startIndex : Integer;
                  stopIndex : Integer) is
   begin
      DecisionEventInfo.init (Self, decision, configs, input, startIndex, stopIndex, True); -- Super
   end if;

end ANTLR.Runtime.ATN.DecisionEventInfos.ContextSensitivityInfos;
