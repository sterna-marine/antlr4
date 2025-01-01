-- €

package body ANTLR.Runtime.ATN.DecisionEventInfos.AmbiguityInfos is

   procedure Initialize (Self : in out AmbiguityInfo;
                   decision : Integer;
                   configs : ATNConfigSet;
                   ambigAlts : BitSet;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   fullCtx  : Boolean) is
   begin
      self.ambigAlts := ambigAlts;
      Super (Self).Initialize (decision, configs, input, startIndex, stopIndex, fullCtx); -- super
   end Initialize;

end ANTLR.Runtime.ATN.DecisionEventInfos.AmbiguityInfos;
