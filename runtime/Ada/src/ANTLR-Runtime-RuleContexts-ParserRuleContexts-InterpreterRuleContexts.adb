-- €

package body ANTLR.Runtime.RuleContexts.ParserRuleContexts.InterpreterRuleContexts is

   overriding
   procedure Initialize (Self : in out InterpreterRuleContext) is
   begin
      Super (Self).Initialize;
   end Initialize;

   procedure Initialize (Self : in out InterpreterRuleContext;
                         parent : Optional_ParserRuleContext;
                         invokingStateNumber : ATNStates.State;
                         ruleIndex : Integer) is
   begin
      self.ruleIndex := ruleIndex;
      Super (Self).Initialize (parent, invokingStateNumber);
   end Initialize;

   overriding
   function getRuleIndex (This : InterpreterRuleContext) return Integer
      is (This.ruleIndex);

   function fromParserRuleContext (ctx : Optional_ParserRuleContext) return Optional_InterpreterRuleContext is
   begin
      if not Is_Valid (ctx) then
            return (Valid => False);
      else
         return dup : InterpreterRuleContext do
            dup := This.InterpreterRuleContext;
            dup.copyFrom (ctx);
            dup.ruleIndex := ctx.getRuleIndex;
            dup.parent := fromParserRuleContext (Optional_ParserRuleContext (ctx.getParent));
         end return; 
      end if;
   end fromParserRuleContext;

end ANTLR.Runtime.RuleContexts.ParserRuleContexts.InterpreterRuleContexts;
