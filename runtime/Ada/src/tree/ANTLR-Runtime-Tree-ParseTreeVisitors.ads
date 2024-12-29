-- €

with Ada.Finalization;
with Option;

use Option;

generic
   type T is private;
package ANTLR.Runtime.Tree.ParseTreeVisitors is

   --
   -- This interface defines the basic notion of a parse tree visitor. Generated
   -- visitors implement this interface and the `XVisitor` interface for
   -- grammar `X`.
   --
   -- * Parameter <T>: The return type of the visit operation. Use _Void_ for
   -- operations with no return type.
   --

   -- open
   type ParseTreeVisitor is new Ada.Finalization.Controlled with null record;

   subtype Object is ParseTreeVisitor;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   package Option_ParseTreeVisitor_T is new Option (T);
   subtype Optional_ParseTreeVisitor_T is Option_ParseTreeVisitor_T.Optional; -- renames

   -- public
   procedure Initialize (Self : ParseTreeVisitor) is null;

   -- typealias T
   --
   -- Visit a parse tree, and return a user-defined result of the operation.
   --
   -- * Parameter tree: The _org.antlr.v4.runtime.tree.ParseTree_ to visit.
   -- * Returns: The result of visiting the parse tree.
   --
   -- open
   function visit (ParseTreeVisitor; tree : ParseTree) return Optional_ParseTreeVisitor_T;

   --
   -- Visit the children of a node, and return a user-defined result of the
   -- operation.
   --
   -- * Parameter node: The _org.antlr.v4.runtime.tree.RuleNode_ whose children should be visited.
   -- * Returns: The result of visiting the children of the node.
   --
   -- open
   function visitChildren (ParseTreeVisitor; node : RuleNode) return Optional_ParseTreeVisitor_T;

   --
   -- Visit a terminal node, and return a user-defined result of the operation.
   --
   -- * Parameter node: The _org.antlr.v4.runtime.tree.TerminalNode_ to visit.
   -- * Returns: The result of visiting the node.
   --
   -- open
   function visitTerminal (ParseTreeVisitor; node : TerminalNode) return Optional_ParseTreeVisitor_T;

   --
   -- Visit an error node, and return a user-defined result of the operation.
   --
   -- * Parameter node: The _org.antlr.v4.runtime.tree.ErrorNode_ to visit.
   -- * Returns: The result of visiting the node.
   --
   -- open
   function visitErrorNode (ParseTreeVisitor; node : ErrorNode) return Optional_ParseTreeVisitor_T;

end ANTLR.Runtime.Tree.ParseTreeVisitors;
