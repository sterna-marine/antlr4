-- €

with ANTLR.Runtime.Tree.ParseTree_Protocol;

use ANTLR.Runtime.Tree.ParseTree_Protocol;

package ANTLR.Runtime.Tree.TerminalNode_Protocol is

   -- public
   type TerminalNode is interface and ParseTree;

   function getSymbol (This : TerminalNode) return Optional_Token;

end ANTLR.Runtime.Tree.TerminalNode_Protocol;
