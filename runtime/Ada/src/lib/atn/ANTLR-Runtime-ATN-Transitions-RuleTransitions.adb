-- €

package body ANTLR.Runtime.ATN.Transitions.RuleTransitions is

   procedure Initialize (Self : in out RuleTransition;
                   ruleStart : RuleStartState;
                   ruleIndex : Integer;
                   precedence : Integer;
                   followState : ATNState) is
   begin
      self.ruleIndex := ruleIndex;
      self.precedence := precedence;
      self.followState := followState;
      Super (Self).Initialize (ruleStart); -- super
   end Initialize;

end ANTLR.Runtime.ATN.Transitions.RuleTransitions;
