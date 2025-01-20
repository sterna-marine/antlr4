-- €

with Ada.Finalization;
with ANTLR.Runtime.Parsers;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.Tree.ParseTree_Protocol;
with ANTLR.Runtime.Tree_Protocol;

use ANTLR.Runtime.Parsers;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Token_Protocol;
use ANTLR.Runtime.Tree.ParseTree_Protocol;
use ANTLR.Runtime.Tree_Protocol;

package ANTLR.Runtime.Tree.Trees is

   -- A set of utility routines useful for all kinds of ANTLR trees.

   -- public
   type Trees is new Ada.Finalization.Controlled with null record;

   --  public class 
   --  procedure getPS (t : Tree;
   --                   ruleNames : array (<>) of UString;
   --                   fontName : UString;
   --                   fontSize : Integer)
   --                   return UString;

   --  public class
   --  function getPS (t: Tree, ruleNames : array (<>) of UString) return UString;

   --TODO: write to file
   --  public class
   --  procedure writePS (t: Tree,
   --                     ruleNames : array (<>) of UString;
   --                     fileName : UString;
   --                     fontName : UString;
   --                     fontSize : Integer);

   --  public class
   --  procedure writePS (t: Tree;
   --                     ruleNames : array (<>) of UString;
   --                     fileName : UString);

   -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
   -- node payloads to get the text for the nodes.  Detect
   -- parse trees and extract data appropriately.
   --
   -- public static
   function toStringTree (t : Tree) return UString;

   -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
   -- node payloads to get the text for the nodes.  Detect
   -- parse trees and extract data appropriately.
   --
   -- public static
   function toStringTree (t : Tree; recog : Optional_Parser) return UString;

   -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
   -- node payloads to get the text for the nodes.  Detect
   -- parse trees and extract data appropriately.
   --
   -- public static
   function toStringTree (t : Tree; ruleNames : array (<>) of UString?) return UString;

   -- public static
   function getNodeText (t : Tree; recog : Optional_Parser) return UString
      is getNodeText (t, recog?.getRuleNames);

   -- public static
   function getNodeText (t : Tree; ruleNames : array (<>) of UString?) return UString;

   -- Return ordered list of all children of this node
   -- public static
   function getChildren (t : Tree) return Tree_List;

   -- Return a list of all ancestors of this node.  The first node of
   -- list is the root and the last is the parent of this node.
   --

   -- public static
   function getAncestors (t : Tree) return Tree_List;

   -- public static
   function findAllTokenNodes (t : ParseTree; tType : Token_Kind) return ParseTree_List
      is (findAllNodes (t, ttype, True));

   -- public static
   function findAllRuleNodes (t : ParseTree; ruleIndex : Integer) return ParseTree_List
      is (findAllNodes (t, ruleIndex, False));

   -- public static
   function findAllNodes (t : ParseTree; index : Integer; findTokens  : Boolean) return ParseTree_List;

   -- public static
   procedure findAllNodes_2 (t : ParseTree;
                             index : Integer;
                             findTokens : Boolean;
                             nodes : in out ParseTree_List);

   -- public static
   function descendants (t : ParseTree) return ParseTree_List;

   -- Find smallest subtree of t enclosing range startTokenIndex .. stopTokenIndex
   -- inclusively using postorder traversal.  Recursive depth-first-search.
   --
   -- public static
   procedure getRootOfSubtreeEnclosingRegion (t : ParseTree;
                                             startTokenIndex, stopTokenIndex : Integer)
                                             return Optional_ParserRuleContext;

   -- private
   overriding
   procedure Initialize (Self : in out Trees);

end ANTLR.Runtime.Tree.Trees;
