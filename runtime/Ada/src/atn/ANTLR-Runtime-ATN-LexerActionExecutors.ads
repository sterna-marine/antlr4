-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.LexerActions;
with ANTLR.Runtime.Lexers;

use ANTLR.Runtime.ATN.LexerActions;
use ANTLR.Runtime.Lexers;

package ANTLR.Runtime.ATN.LexerActionExecutors is

   --
   -- Represents an executor for a sequence of lexer actions which traversed during
   -- the matching operation of a lexer rule (token).
   --
   -- The executor tracks position information for position-dependent lexer actions
   -- efficiently, ensuring that actions appearing only at the end of the rule do
   -- not cause bloating of the _org.antlr.v4.runtime.dfa.DFA_ created for the lexer.
   --

   -- public
   type LexerActionExecutor is new Ada.Finalization.Controlled with -- and Hashable
   record
      -- fileprivate final
      lexerActions : LexerAction_List;
      --
      -- Caches the result of _#hashCode_ since the hash code is an element
      -- of the performance-critical _org.antlr.v4.runtime.atn.LexerATNConfig#hashCode_ operation.
      --
      -- fileprivate final
      hashCode : Ada.Containers.Hash_Type;
   end record;

   subtype Object is LexerActionExecutor;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   function "=" (lhs, rhs : LexerActionExecutor) return Boolean;
   -- public
   procedure hash (This : LexerActionExecutor; hasher: in out Hasher);

   package Option_LexerActionExecutor is new AdaForge.Util.Optionals (LexerActionExecutor);
   subtype Optional_LexerActionExecutor is Option_ILexerActionExecutor.Optional; -- renames

   --
   -- Constructs an executor for a sequence of _org.antlr.v4.runtime.atn.LexerAction_ actions.
   -- * parameter lexerActions: The lexer actions to execute.
   --
   -- public
   procedure Initialize (Self : in out LexerActionExecutor; lexerActions : LexerAction_List);

   --
   -- Creates a _org.antlr.v4.runtime.atn.LexerActionExecutor_ which executes the actions for
   -- the input `lexerActionExecutor` followed by a specified
   -- `lexerAction`.
   --
   -- * parameter lexerActionExecutor: The executor for actions already traversed by
   --   the lexer while matching a token within a particular
   --   _org.antlr.v4.runtime.atn.LexerATNConfig_. If this is `null`, the method behaves as
   --   though it were an empty executor.
   -- * parameter lexerAction: The lexer action to execute after the actions
   --   specified in `lexerActionExecutor`.
   --
   -- * returns: A _org.antlr.v4.runtime.atn.LexerActionExecutor_ for executing the combine actions
   --   of `lexerActionExecutor` and `lexerAction`.
   --
   -- public static
   function append (This : LexerActionExecutor;
                    lexerActionExecutor : Optional_LexerActionExecutor;
                    lexerAction : LexerAction)
                    return LexerActionExecutor;

   --
   -- Creates a _org.antlr.v4.runtime.atn.LexerActionExecutor_ which encodes the current offset
   -- for position-dependent lexer actions.
   --
   -- Normally, when the executor encounters lexer actions where
   -- _org.antlr.v4.runtime.atn.LexerAction#isPositionDependent_ returns `True`, it calls
   -- _org.antlr.v4.runtime.IntStream#seek_ on the input _org.antlr.v4.runtime.CharStream_ to set the input
   -- position to the __end__ of the current token. This behavior provides
   -- for efficient DFA representation of lexer actions which appear at the end
   -- of a lexer rule, even when the lexer rule matches a variable number of
   -- characters.
   --
   -- Prior to traversing a match transition in the ATN, the current offset
   -- from the token start index is assigned to all position-dependent lexer
   -- actions which have not already been assigned a fixed offset. By storing
   -- the offsets relative to the token start index, the DFA representation of
   -- lexer actions which appear in the middle of tokens remains efficient due
   -- to sharing among tokens of the same length, regardless of their absolute
   -- position in the input stream.
   --
   -- If the current executor already has offsets assigned to all
   -- position-dependent lexer actions, the method returns `this`.
   --
   -- * parameter offset: The current offset to assign to all position-dependent
   --   lexer actions which do not already have offsets assigned.
   --
   -- * returns: A _org.antlr.v4.runtime.atn.LexerActionExecutor_ which stores input stream offsets
   --   for all position-dependent lexer actions.
   --
   -- public
   function fixOffsetBeforeMatch (This : LexerActionExecutor; offset : Integer) return LexerActionExecutor;

   --
   -- Gets the lexer actions to be executed by this executor.
   -- * returns: The lexer actions to be executed by this executor.
   --
   -- public
   function getLexerActions (This : LexerActionExecutor) return LexerAction_Container.Vector
      is (This.lexerActions);

   --
   -- Execute the actions encapsulated by this executor within the context of a
   -- particular _org.antlr.v4.runtime.Lexer_.
   --
   -- This method calls _org.antlr.v4.runtime.IntStream#seek_ to set the position of the
   -- `input` _org.antlr.v4.runtime.CharStream_ prior to calling
   -- _org.antlr.v4.runtime.atn.LexerAction#execute_ on a position-dependent action. Before the
   -- method returns, the input position will be restored to the same position
   -- it was in when the method was invoked.
   --
   -- * parameter lexer: The lexer instance.
   -- * parameter input: The input stream which is the source for the current token.
   --   When this method is called, the current _org.antlr.v4.runtime.IntStream#index_ for
   --   `input` should be the start of the following token, i.e. 1
   --   character past the end of the current token.
   -- * parameter startIndex: The token start index. This value may be passed to
   --   _org.antlr.v4.runtime.IntStream#seek_ to set the `input` position to the beginning
   --   of the token.
   --

   -- public
   procedure execute (This : LexerActionExecutor;
                      lexer : Lexer;
                      input : CharStream;
                      startIndex : Integer);

end ANTLR.Runtime.ATN.LexerActionExecutors;
