-- €

with ANTLR.Runtime.ATN.Configs;
with ANTLR.Runtime.ATN.States;

use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.Configs.LexerConfigs is

   type LexerATNConfig is new ATNConfig with private;

   subtype Object is LexerATNConfig;
   subtype Super is ATNConfig;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   --useless
   -- public
   function "=" (Lhs, Rhs : LexerATNConfig) return Boolean;

   -- public
   overriding
   procedure hash (This : LexerATNConfig; hasher : in out Hasher);

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

end ANTLR.Runtime.ATN.Configs.LexerConfigs;
