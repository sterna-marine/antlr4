-- €

with ANTLR.Runtime.Tree.ParseTree_Protocol;

use ANTLR.Runtime.Tree.ParseTree_Protocol;

package ANTLR.Runtime.Tree.RuleNode_Protocol is

   -- public
   type RuleNode is interface and ParseTree;

   function getRuleContext (This : RuleNode) return RuleContext;

end ANTLR.Runtime.Tree.RuleNode_Protocol;
