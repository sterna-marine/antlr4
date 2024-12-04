-- €

with ANTLR.Runtime.ATN.ATNConfig;
with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN;

package body ANTLR.Runtime.ATN.LexerATNConfig;

   type LexerATNConfig is new ATNConfig with private;

   -- public 
   procedure Init (Self : in out LexerATNConfig;
                   state : ATNStates.ATNState;
                   alt : Integer;
                   context : PredictionContext);

    -- public 
   procedure Init (Self : in out LexerATNConfig;
                   state : ATNStates.ATNState;
                   alt : Integer;
                   context : PredictionContext;
                   lexerActionExecutor : Optional_LexerActionExecutor);

   -- public 
   procedure Init (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState);

   -- public 
   procedure Init (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState;
                   lexerActionExecutor : Optional_LexerActionExecutor);

   -- public 
   procedure Init (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState;
                   context : PredictionContext);

   -- --------------------------------------------
   -- Gets the _org.antlr.v4.runtime.atn.LexerActionExecutor_ capable of executing the embedded
   -- action (s) for the current configuration.
   -- --------------------------------------------
   -- public final
   function getLexerActionExecutor (This : LexerATNConfig) return Optional_LexerActionExecutor
      is (lexerActionExecutor);
   
   -- public final
   function hasPassedThroughNonGreedyDecision (This : LexerATNConfig) return Boolean
      is (passedThroughNonGreedyDecision);
   
   -- public
   override
   procedure hash (This : LexerATNConfig; hasher : in out Hasher);

   --useless
   -- public
   function "=" (lhs: LexerATNConfig; rhs: LexerATNConfig) return Boolean;

private

   -- public
   type LexerATNConfig is new ATNConfig with
   record
      -- --------------------------------------------
      -- This is the backing field for _#getLexerActionExecutor_.
      -- --------------------------------------------
      -- private 
      lexerActionExecutor : constant LexerActionExecutor?;

      -- fileprivate
      passedThroughNonGreedyDecision : constant Boolean;
   end record;

   -- private static
   function checkNonGreedyDecision (source : LexerATNConfig; target : ATNStates.ATNState) return Boolean;
   begin
      return source.passedThroughNonGreedyDecision
             or else target is DecisionState 
             and then (DecisionState (target)).nonGreedy
   end checkNonGreedyDecision;

end ANTLR.Runtime.ATN.LexerATNConfig;
