-- €

with ANTLR.Runtime.ATN.LexerAction;

use ANTLR.Runtime.ATN.LexerAction;

package ANTLR.Runtime.ATN.LexerActions.LexerSkipActions is

   --
   -- Implements the `skip` lexer action by calling _org.antlr.v4.runtime.Lexer#skip_.
   --
   -- The `skip` command does not have any parameters, so this action is
   -- implemented as a singleton instance exposed by _#INSTANCE_.
   --

   -- public final
   type LexerSkipAction is new LexerAction with
   record
      --
      -- Provides a singleton instance of this parameterless lexer action.
      --
      -- public static
      INSTANCE : LexerSkipAction := This.LexerSkipAction; --  constant
   end record;

   subtype Object is LexerSkipAction;
   subtype Super is LexerAction;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   --
   -- Constructs the singleton instance of the lexer `skip` command.
   --
   -- private
   overriding
   procedure Initialize (Self : LexerSkipAction) is null;

   --
   --
   -- * returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#SKIP_.
   --
   overriding
   -- public
   function getActionType (This : LexerSkipAction) return LexerActionType
         is (This.LexerActionType.skip);

   --
   --
   -- * returns: This method returns `False`.
   --
   overriding
   -- public
   function isPositionDependent (This : LexerSkipAction) return Boolean
      is False;

   --
   --
   --
   -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#skip_.
   --
   overriding
   -- public
   procedure execute (This : LexerSkipAction; lexer : Lexer);

   -- public
   overriding
   procedure hash (This : LexerSkipAction; hasher : in out Hasher);

   -- public
   function Description (This : …) return UString
      is ("skip");

   -- public
   function "=" (Lhs, Rhs : LexerSkipAction) return Boolean;

end ANTLR.Runtime.ATN.LexerActions.LexerSkipActions;
