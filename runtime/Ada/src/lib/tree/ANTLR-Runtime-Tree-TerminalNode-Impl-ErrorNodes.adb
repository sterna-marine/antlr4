-- €

package body ANTLR.Runtime.Tree.TerminalNode.Impl.ErrorNodes is

   overriding
   procedure Initialize (Self : in out ErrorNode; token : Token) is
   begin
      Super (Self).Initialize (token);
   end Initialize;

end ANTLR.Runtime.Tree.TerminalNode.Impl.ErrorNode;
