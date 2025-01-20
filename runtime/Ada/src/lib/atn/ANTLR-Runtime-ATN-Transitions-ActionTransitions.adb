-- €

package body ANTLR.Runtime.ATN.Transitions.ActionTransitions is

   procedure Initialize (Self : in out ActionTransition; target : ATNState; ruleIndex : Integer) is
   begin
      Self.Initialize (target, ruleIndex, -1, False);
   end Initialize;

   procedure Initialize (Self : in out ActionTransition;
                   target : ATNState;
                   ruleIndex : Integer;
                   actionIndex : Integer;
                   isCtxDependent  : Boolean) is
   begin
      self.ruleIndex := ruleIndex;
      self.actionIndex := actionIndex;
      self.isCtxDependent := isCtxDependent;
      Transition.init (target);
   end Initialize;

end ANTLR.Runtime.ATN.Transitions.ActionTransitions;
