-- €

with ANTLR.Runtime.Tree.ParseTree_Protocol;
with ANTLR.Runtime.RuleContexts;

use ANTLR.Runtime.Tree.ParseTree_Protocol;
use ANTLR.Runtime.RuleContexts;

package ANTLR.Runtime.Tree.RuleNode_Protocol is

   -- public
   type RuleNode is interface and ParseTree;

   function getRuleContext (Some : RuleNode) return RuleContext;

end ANTLR.Runtime.Tree.RuleNode_Protocol;
