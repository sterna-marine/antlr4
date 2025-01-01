-- €

with Ada.Strings;
with ANTLR.Runtime.Tree.SyntaxTree_Protocol;

use ANTLR.Runtime.Tree.SyntaxTree_Protocol;

package ANTLR.Runtime.Tree.ParseTree_Protocol is

   -- An interface to access the tree of _org.antlr.v4.runtime.RuleContext_ objects created
   -- during a parse that makes the data structure look like a simple parse tree.
   -- This node represents both internal nodes, rule invocations,
   -- and leaf nodes, token matches.
   --
   -- The payload is either a _org.antlr.v4.runtime.Token_ or a _org.antlr.v4.runtime.RuleContext_ object.
   --
   -- public
   type ParseTree is interface and SyntaxTree;
   
   -- Set the parent for this leaf node.
   procedure setParent (Some : ParseTree; parent : RuleContext);

   -- The _org.antlr.v4.runtime.tree.ParseTreeVisitor_ needs a double dispatch method.
   function accept<T> (Some : ParseTree; visitor : ParseTreeVisitor<T>) return Optional_T;

   -- Return the combined text of all leaf nodes. Does not get any
   -- off-channel tokens (if any) so won't return whitespace and
   -- comments if they are sent to parser on hidden channel.
   function getText (Some : ParseTree) return UString;

   -- Specialize toStringTree so that it can print out more information
   -- based upon the parser.
   function toStringTree (Some : ParseTree; parser : Parser) return UString;

   -- Equivalent to `getChild (index)! as! ParseTree`
   function subscript (index : Integer) return ParseTree is
   begin 
      get;
   end subscript;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ParseTree (S : in out Sink'Class; X : ParseTree);
   for ParseTree'Put_Image use Put_Image_ParseTree;

   function Description (Some : ParseTree) return UString

end ANTLR.Runtime.Tree.ParseTree_Protocol;
