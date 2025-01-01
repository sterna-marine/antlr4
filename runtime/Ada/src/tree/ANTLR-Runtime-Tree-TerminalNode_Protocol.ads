-- €

with ANTLR.Runtime.Tree.ParseTree_Protocol;
with ANTLR.Runtime.Token_Protocol;

use ANTLR.Runtime.Tree.ParseTree_Protocol;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.Tree.TerminalNode_Protocol is

   -- public
   type TerminalNode is interface and ParseTree;

   function getSymbol (Some : TerminalNode) return Optional_Token;

end ANTLR.Runtime.Tree.TerminalNode_Protocol;
