-- €

with Ada.Containers.Vectors;

package ANTLR.Runtime.Tree_Protocol is

   -- The basic notion of a tree has a parent, a payload, and a list of children.
   -- It is the most abstract interface for all the trees used by ANTLR.
   --

   -- public
   type Tree is interface;

   package Option_Tree is new Option (Tree);
   subtype Optional_Tree is Option_Tree.Optional;

   function "=" (Left, Right : Tree) return Boolean;

   package Tree_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Item_Type  => Tree,
      "=" => "=");
   subtype Tree_List is Tree_Container.Vector;

   -- The parent of this node. If the return value is null, then this
   -- node is the root of the tree.
   --
   function getParent (This :Tree) return Optional_Tree is abstract;

   --
   -- This method returns whatever object represents the data at this note. For
   -- example, for parse trees, the payload can be a _org.antlr.v4.runtime.Token_ representing
   -- a leaf node or a _org.antlr.v4.runtime.RuleContext_ object representing a rule
   -- invocation. For abstract syntax trees (ASTs), this is a _org.antlr.v4.runtime.Token_
   -- object.
   --
   function getPayload (This :Tree) return AnyObject is abstract;

   -- If there are children, get the `i`th value indexed from 0.
   function getChild (This :Tree; i : Integer) return Optional_Tree is abstract;

   -- How many children are there? If there is none, then this
   -- node represents a leaf node.
   --
   function getChildCount (This :Tree) return Natural is abstract;

   -- Print out a whole tree, not just a node, in LISP format
   -- `(root child1 .. childN)`. Print just a node if this is a leaf.
   --
   function toStringTree (This :Tree) return UString is abstract;

end ANTLR.Runtime.Tree_Protocol;
