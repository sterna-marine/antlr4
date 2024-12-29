-- €

with ANTLR.Runtime.ATN.LexerAction;

use ANTLR.Runtime.ATN.LexerAction;

package ANTLR.Runtime.ATN.LexerCustomAction is

   --
   -- Executes a custom lexer action by calling _org.antlr.v4.runtime.Recognizer#action_ with the
   -- rule and action indexes assigned to the custom action. The implementation of
   -- a custom action is added to the generated code for the lexer in an override
   -- of _org.antlr.v4.runtime.Recognizer#action_ when the grammar is compiled.
   --
   -- This class may represent embedded actions created with the { LexerCustomAction }
   -- syntax in ANTLR 4, as well as actions created for lexer commands where the
   -- command argument could not be evaluated when the grammar was compiled.
   --


   -- public final
   type LexerCustomAction is new LexerAction with
   record
      -- fileprivate
      ruleIndex : Integer; -- constant
      -- fileprivate
      actionIndex : Integer; -- constant
   end record;

   --
   -- Constructs a custom lexer action with the specified rule and action
   -- indexes.
   --
   -- * parameter ruleIndex: The rule index to use for calls to
   -- _org.antlr.v4.runtime.Recognizer#action_.
   -- * parameter actionIndex: The action index to use for calls to
   -- _org.antlr.v4.runtime.Recognizer#action_.
   --
   -- public
   procedure Initialize (Self : in out LexerCustomAction; ruleIndex : Integer; actionIndex : Integer);

   --
   -- Gets the rule index to use for calls to _org.antlr.v4.runtime.Recognizer#action_.
   --
   -- * returns: The rule index for the custom action.
   --
   -- public
   function getRuleIndex (This : LexerCustomAction) return Integer
      is (This.ruleIndex);

   --
   -- Gets the action index to use for calls to _org.antlr.v4.runtime.Recognizer#action_.
   --
   -- * returns: The action index for the custom action.
   --
   -- public
   function getActionIndex (This : LexerCustomAction) return Integer
      is (This.actionIndex);

   --
   --
   --
   -- * returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#CUSTOM_.
   --
   --public
   overriding
   function getActionType (This : LexerCustomAction) return LexerActionType
      is (LexerActionType.custom);

   --
   -- Gets whether the lexer action is position-dependent. Position-dependent
   -- actions may have different semantics depending on the _org.antlr.v4.runtime.CharStream_
   -- index at the time the action is executed.
   --
   -- Custom actions are position-dependent since they may represent a
   -- user-defined embedded action which makes calls to methods like
   -- _org.antlr.v4.runtime.Lexer#getText_.
   --
   -- * returns: This method returns `True`.
   --
   overriding
   -- public
   function isPositionDependent (This : LexerCustomAction) return Boolean
      is (True);

   --
   --
   --
   -- Custom actions are implemented by calling _org.antlr.v4.runtime.Lexer#action_ with the
   -- appropriate rule and action indexes.
   --
   overriding
   -- public
   procedure execute (This : LexerCustomAction; lexer : Lexer);

   -- public
   overriding
   procedure hash (This : LexerCustomAction; hasher: in out Hasher);

   -- public
   function "=" (Lhs, Rhs : LexerCustomAction) return Boolean;

end ANTLR.Runtime.ATN.LexerCustomAction;
