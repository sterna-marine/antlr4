-- €

with ANTLR.Runtime.ATN.LexerActionTypes;
with ANTLR.Runtime.Recognizers.Lexers;

use ANTLR.Runtime.ATN.LexerActionTypes;
use ANTLR.Runtime.Recognizers.Lexers;

package ANTLR.Runtime.ATN.LexerActions.LexerIndexedCustomActions is

   use ANTLR.Runtime.ATN.LexerActions;

   --
   -- This implementation of _org.antlr.v4.runtime.atn.LexerAction_ is used for tracking input offsets
   -- for position-dependent actions within a _org.antlr.v4.runtime.atn.LexerActionExecutor_.
   --
   -- This action is not serialized as part of the ATN, and is only required for
   -- position-dependent lexer actions which appear at a location other than the
   -- end of a rule. For more information about DFA optimizations employed for
   -- lexer actions, see _org.antlr.v4.runtime.atn.LexerActionExecutor#append_ and
   -- _org.antlr.v4.runtime.atn.LexerActionExecutor#fixOffsetBeforeMatch_.
   --

   -- public final
   type LexerIndexedCustomAction is new LexerAction with
   record
      -- fileprivate
      offset : Integer; -- constant
      -- fileprivate
      action : LexerAction; -- constant
   end record;

   subtype Object is LexerIndexedCustomAction;
   subtype Super is LexerAction;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   function "=" (Lhs, Rhs : LexerIndexedCustomAction) return Boolean;
    -- public
    overriding
    procedure hash (This : LexerIndexedCustomAction; hasher : in out Hasher);

    --
    -- Constructs a new indexed custom action by associating a character offset
    -- with a _org.antlr.v4.runtime.atn.LexerAction_.
    --
    -- Note: This class is only required for lexer actions for which
    -- _org.antlr.v4.runtime.atn.LexerAction#isPositionDependent_ returns `True`.
    --
    -- * parameter offset: The offset into the input _org.antlr.v4.runtime.CharStream_, relative to
    -- the token start index, at which the specified lexer action should be
    -- executed.
    -- * parameter action: The lexer action to execute at a particular offset in the
    -- input _org.antlr.v4.runtime.CharStream_.
    --
    -- public
    procedure Initialize (Self : in out LexerIndexedCustomAction; offset : Integer; action : LexerAction);

    --
    -- Gets the location in the input _org.antlr.v4.runtime.CharStream_ at which the lexer
    -- action should be executed. The value is interpreted as an offset relative
    -- to the token start index.
    --
    -- * returns: The location in the input _org.antlr.v4.runtime.CharStream_ at which the lexer
    -- action should be executed.
    --
    -- public
    function getOffset (This : LexerIndexedCustomAction) return Integer
      is (This.offset);

    --
    -- Gets the lexer action to execute.
    --
    -- * returns: A _org.antlr.v4.runtime.atn.LexerAction_ object which executes the lexer action.
    --
    -- public
    function getAction (This : LexerIndexedCustomAction) return LexerAction
      is (This.action);

    --
    --
    --
    -- * returns: This method returns the result of calling _#getActionType_
    -- on the _org.antlr.v4.runtime.atn.LexerAction_ returned by _#getAction_.
    --

    --public
    overriding
    function getActionType (This : LexerIndexedCustomAction) return LexerActionType
      is (This.action.getActionType);

    --
    --
    -- * returns: This method returns `True`.
    --
    --public
    overriding
    function isPositionDependent (This : LexerIndexedCustomAction) return Boolean
      is (True);

    --
    --
    --
    -- This method calls _#execute_ on the result of _#getAction_
    -- using the provided `lexer`.
    --
    -- public
    overriding
    procedure execute (This : LexerIndexedCustomAction; lexer : Lexer);

end ANTLR.Runtime.ATN.LexerActions.LexerIndexedCustomActions;
