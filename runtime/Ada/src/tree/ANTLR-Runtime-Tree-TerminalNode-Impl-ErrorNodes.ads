-- €

with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.Tree.ParseTreeVisitors;

use ANTLR.Runtime.Token_Protocol;
use ANTLR.Runtime.Tree.ParseTreeVisitors;
use ANTLR.Runtime.Tree;

package ANTLR.Runtime.Tree.TerminalNode.Impl.ErrorNodes is

   -- Represents a token that was consumed during resynchronization
   -- rather than during a valid match operation. For example,
   -- we will create this kind of a node during single token insertion
   -- and deletion as well as during "consume until error recovery set"
   -- upon no viable alternative exceptions.
   --
   -- public
   type ErrorNode is new TerminalNode.Impl with null record;

   -- public
   overriding
   procedure Initialize (Self : in out ErrorNode; token : Token);

   package ParseTreeVisitors_T is new ParseTreeVisitors (T);
   subtype ParseTreeVisitor_T is ParseTreeVisitors_T.ParseTreeVisitor;

   overriding
   -- public
   function accept_T (This : ErrorNode; visitor : ParseTreeVisitor_T) return Optional_T
      is (visitor.visitErrorNode (This));

end ANTLR.Runtime.Tree.TerminalNode.Impl.ErrorNode;
