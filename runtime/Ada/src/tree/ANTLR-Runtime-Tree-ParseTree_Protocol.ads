-- €

with Ada.Containers;
with Ada.Containers.Hashed_Map;
with Ada.Containers.Vectors;
with Ada.Strings;
with ANTLR.Runtime.Parsers;
with ANTLR.Runtime.RuleContexts;
with ANTLR.Runtime.Tree.ParseTreeVisitors;
with ANTLR.Runtime.Tree.SyntaxTree_Protocol;
with Option;

use ANTLR.Runtime.Parsers;
use ANTLR.Runtime.RuleContexts;
use ANTLR.Runtime.Tree.ParseTreeVisitors;
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
   
   function "=" (Left, Right : ParseTree) return Boolean;

   package ParseTree_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Item_Type  => ParseTree,
      "=" => "=");
   subtype ParseTree_List is ParseTree_Container.Vector;

   function Hash (Key : UString) return Ada.Containers.Hash_Type;

   function Equivalent_Keys (Left, Right : Key_Type)
      is (Hash (Left) = Hash (Right));

   package ParseTree_Dictonary is new Ada.Containers.Hashed_Map (
      Key_Type => UString,
      Element_Type => ParseTree,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype ParseTree_MultiMap is ParseTree_Dictonary.Map;

   -- Set the parent for this leaf node.
   procedure setParent (This : ParseTree; parent : RuleContext) is abstract;

   -- The _org.antlr.v4.runtime.tree.ParseTreeVisitor_ needs a double dispatch method.
   generic
      type T is private;
      package ParseTreeVisitor_T is new ParseTreeVisitor (T);
      package Option_T is new Option (T);
      subtype Optional_T is Option_T.Optional;
   function accept (This : ParseTree; visitor : ParseTreeVisitor_T) return Optional_T is abstract;

   -- Return the combined text of all leaf nodes. Does not get any
   -- off-channel tokens (if any) so won't return whitespace and
   -- comments if they are sent to parser on hidden channel.
   function getText (This : ParseTree) return UString is abstract;

   -- Specialize toStringTree so that it can print out more information
   -- based upon the parser.
   function toStringTree (This : ParseTree; parser : Parser) return UString is abstract;

   -- Equivalent to `getChild (index)! as! ParseTree`
   function subscript (index : Integer) return ParseTree;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ParseTree (S : in out Sink'Class; X : ParseTree) is abstract;
   for ParseTree'Put_Image use Put_Image_ParseTree;
   
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ParseTree (S : in out Sink'Class; X : ParseTree);
   for ParseTree'Put_Image use Put_Image_ParseTree;
   function Description (This : ParseTree) return UString is abstract;

end ANTLR.Runtime.Tree.ParseTree_Protocol;
