-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.DecisionState;

use ANTLR.Runtime.ATN.ATNStates;
use ANTLR.Runtime.ATN.DecisionState;

package ANTLR.Runtime.ATN.States.DecisionStates.TokensStartStates is

   --
   -- The Tokens rule start state linking to each lexer rule start state
   --

   -- public final
   type TokensStartState is new DecisionState with null record;

   subtype Object is TokensStartState;
   subtype Super is DecisionState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   overriding
   function getStateType (This : TokensStartState) return State
      is (TOKEN_START);

end ANTLR.Runtime.ATN.States.DecisionStates.TokensStartStates;
