-- €

package body ANTLR.Runtime.ATN.RuleTransition is

   procedure Initialize (Self : in out RuleTransition;
                   ruleStart : RuleStartState;
                   ruleIndex : Integer;
                   precedence : Integer;
                   followState : ATNState) is
   begin
      self.ruleIndex := ruleIndex;
      self.precedence := precedence;
      self.followState := followState;
      ATNTransition.init (Self, ruleStart); -- super
   end Initialize;

end ANTLR.Runtime.ATN.RuleTransition;
