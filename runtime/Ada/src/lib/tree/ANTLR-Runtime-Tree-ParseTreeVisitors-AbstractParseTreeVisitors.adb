-- €

package body ANTLR.Runtime.Tree.ParseTreeVisitors.AbstractParseTreeVisitors is

   overriding
   procedure Initialize (Self : in out AbstractParseTreeVisitor) is
   begin
      Super (Self).Initialize;
   end Initialize;

   overriding
   function visit (This : AbstractParseTreeVisitor; tree : ParseTree) return Optional_T is
   begin
      return tree.accept_T (This);
   end visit;

   overriding
   function visitChildren (This : AbstractParseTreeVisitor; node : RuleNode) return Optional_T is
      result : Optional_T := This.defaultResult;
      n : constant := node.getChildCount;
   begin
      for i in 0 .. n - 1 loop
         exit when not shouldVisitNextChild (node, result);

         c : constant := node.Element (i);
         childResult : constant := c.accept_T (self);
         result := aggregateResult (result, childResult);
      end loop;

      return result;
   end visitChildren;

   overriding
   function visitTerminal (This : AbstractParseTreeVisitor; node : TerminalNode) return Optional_T is
   begin
      return This.defaultResult;
   end visitTerminal;

   overriding
   function visitErrorNode (This : AbstractParseTreeVisitor; node : ErrorNode) return Optional_T is
   begin
      return This.defaultResult;
   end visitErrorNode;

   function defaultResult (This : AbstractParseTreeVisitor) return Optional_T
      is (Valid => False);

   function aggregateResult (This : AbstractParseTreeVisitor; aggregate : Optional_T; nextResult : Optional_T) return Optional_T
      is (nextResult);

   function shouldVisitNextChild (This : AbstractParseTreeVisitor; node : RuleNode; currentResult : Optional_T) return Boolean
       is (True);

end ANTLR.Runtime.Tree.ParseTreeVisitors.AbstractParseTreeVisitors;
