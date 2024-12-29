-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.DecisionState;

use ANTLR.Runtime.ATN.ATNStates;
use ANTLR.Runtime.ATN.DecisionState;

package ANTLR.Runtime.ATN.TokensStartState is

   --
   -- The Tokens rule start state linking to each lexer rule start state
   --

   -- public final
   type TokensStartState is new DecisionState with null record;

   -- public
   overriding
   function getStateType (This : TokensStartState) return State
      is (TOKEN_START);

end ANTLR.Runtime.ATN.TokensStartState;
