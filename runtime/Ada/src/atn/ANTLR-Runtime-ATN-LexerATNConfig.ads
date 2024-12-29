-- €

with ANTLR.Runtime.ATN.ATNConfig;
with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.LexerATNConfig;

   type LexerATNConfig is new ATNConfig with private;

   -- public
   procedure Initialize (Self : in out LexerATNConfig;
                   state : ATNStates.ATNState;
                   alt : Integer;
                   context : PredictionContext);

    -- public
   procedure Initialize (Self : in out LexerATNConfig;
                   state : ATNStates.ATNState;
                   alt : Integer;
                   context : PredictionContext;
                   lexerActionExecutor : Optional_LexerActionExecutor);

   -- public
   procedure Initialize (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState);

   -- public
   procedure Initialize (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState;
                   lexerActionExecutor : Optional_LexerActionExecutor);

   -- public
   procedure Initialize (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState;
                   context : PredictionContext);

   --
   -- Gets the _org.antlr.v4.runtime.atn.LexerActionExecutor_ capable of executing the embedded
   -- action (s) for the current configuration.
   --
   -- public final
   function getLexerActionExecutor (This : LexerATNConfig) return Optional_LexerActionExecutor
      is (lexerActionExecutor);

   -- public final
   function hasPassedThroughNonGreedyDecision (This : LexerATNConfig) return Boolean
      is (passedThroughNonGreedyDecision);

   -- public
   overriding
   procedure hash (This : LexerATNConfig; hasher : in out Hasher);

   --useless
   -- public
   function "=" (Lhs, Rhs : LexerATNConfig) return Boolean;

private

   -- public
   type LexerATNConfig is new ATNConfig with
   record
      --
      -- This is the backing field for _#getLexerActionExecutor_.
      --
      -- private
      lexerActionExecutor : constant Optional_LexerActionExecutor;

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
