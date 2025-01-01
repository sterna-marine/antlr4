-- €

package ANTLR.Runtime.Tree_Protocol is

   -- The basic notion of a tree has a parent, a payload, and a list of children.
   -- It is the most abstract interface for all the trees used by ANTLR.
   --

   -- public
   type Tree is interface;

   package Option_Tree is new Option (Tree);
   subtype Optional_Tree is Option_Tree.Optional;

   -- The parent of this node. If the return value is null, then this
   -- node is the root of the tree.
   --
   function getParent (Some : Tree) return Optional_Tree;

   --
   -- This method returns whatever object represents the data at this note. For
   -- example, for parse trees, the payload can be a _org.antlr.v4.runtime.Token_ representing
   -- a leaf node or a _org.antlr.v4.runtime.RuleContext_ object representing a rule
   -- invocation. For abstract syntax trees (ASTs), this is a _org.antlr.v4.runtime.Token_
   -- object.
   --
   function getPayload (Some : Tree) return AnyObject;

   -- If there are children, get the `i`th value indexed from 0.
   function getChild (Some : Tree; i : Integer) return Optional_Tree

   -- How many children are there? If there is none, then this
   -- node represents a leaf node.
   --
   function getChildCount (Some : Tree) return Natural;

   -- Print out a whole tree, not just a node, in LISP format
   -- `(root child1 .. childN)`. Print just a node if this is a leaf.
   --
   function toStringTree (Some : Tree) return UString;

end ANTLR.Runtime.Tree_Protocol;
