-- €

with Ada.Finalization;

package body ANTLR.Runtime.Tree.ParseTreeWalkers is

   procedure walk (This : ParseTreeWalker; listener : ParseTreeListener; t : ParseTree) is
      errNode : constant Optional_ErrorNode := Maybe (t);
      termNode : constant TerminalNode := TerminalNode (t);
      r : constant RuleNode := RuleNode (t);
   begin
      if Is_Valid (errNode) then
         listener.visitErrorNode (errNode);
      elsif Is_Valid (termNode) then
         listener.visitTerminal (termNode);
      elsif Is_Valid (r) then
         enterRule (listener, r);
         n : constant := r.getChildCount;
         for i in 0 .. n - 1 loop
            walk (listener, r.Element (i));
         end loop;
         exitRule (listener, r);
      else
         This.preconditionFailure;
      end if;
   end walk;

   procedure enterRule (listener : ParseTreeListener; r : RuleNode) is
      ctx : constant ParserRuleContext := ParserRuleContext (r.getRuleContext);
   begin
      listener.enterEveryRule (ctx);
      ctx.enterRule (listener);
   end enterRule;

   procedure exitRule (listener : ParseTreeListener; r : RuleNode) is
      ctx : constant ParserRuleContext := ParserRuleContext (r.getRuleContext);
   begin
      ctx.exitRule (listener);
      listener.exitEveryRule (ctx);
   end exitRule;

end ANTLR.Runtime.Tree.ParseTreeWalkers;
