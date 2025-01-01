-- €

with ANTLR.Runtime.Tree.ParseTreeVisitors;

use ANTLR.Runtime.Tree.ParseTreeVisitors;

package ANTLR.Runtime.Tree.TerminalNode.Impl.ErrorNode is

   -- Represents a token that was consumed during resynchronization
   -- rather than during a valid match operation. For example,
   -- we will create this kind of a node during single token insertion
   -- and deletion as well as during "consume until error recovery set"
   -- upon no viable alternative exceptions.
   --
   -- public
   type ErrorNode is new TerminalNodeImpl with null record;

   -- public
   overriding
   procedure Initialize (Self : in out ErrorNode; token : Token) is
   begin
      Super (Self).Initialize (token);
   end Initialize;

   package ParseTreeVisitors_T is new ParseTreeVisitors (T);

   overriding
   -- public
   function accept_T (This : ErrorNode; visitor : ParseTreeVisitors_T.ParseTreeVisitor) return Optional_T is
   begin
      return visitor.visitErrorNode (self);
   end accept_T;

end ANTLR.Runtime.Tree.TerminalNode.Impl.ErrorNode;
