-- €

package body ANTLR.Runtime.Tree.ParseTreeVisitors is

   function visit (ParseTreeVisitor; tree : ParseTree) return Optional_ParseTreeVisitor_T is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Tree.ParseTreeVisitor.visit() must be overridden";
   end visit;

   function visitChildren (ParseTreeVisitor; node : RuleNode) return Optional_ParseTreeVisitor_T is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Tree.ParseTreeVisitor.visitChildren() must be overridden";
   end visitChildren;

   function visitTerminal (ParseTreeVisitor; node : TerminalNode) return Optional_ParseTreeVisitor_T is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Tree.ParseTreeVisitor.visitTerminal() must be overridden";
   end visitTerminal;

   function visitErrorNode (ParseTreeVisitor; node : ErrorNode) return Optional_ParseTreeVisitor_T is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Tree.ParseTreeVisitor.visitErrorNode() must be overridden";
   end visitErrorNode;

end ANTLR.Runtime.Tree.ParseTreeVisitors;
