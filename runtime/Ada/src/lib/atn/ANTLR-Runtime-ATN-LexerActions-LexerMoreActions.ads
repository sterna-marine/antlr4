-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.LexerActionTypes;
with ANTLR.Runtime.Lexers;

use ANTLR.Runtime.ATN.LexerActionTypes;
use ANTLR.Runtime.Lexers;

package ANTLR.Runtime.ATN.LexerActions.LexerMoreActions is

   use ANTLR.Runtime.ATN.LexerActions;

   --
   -- Implements the `more` lexer action by calling _org.antlr.v4.runtime.Lexer#more_.
   --
   -- The `more` command does not have any parameters, so this action is
   -- implemented as a singleton instance exposed by _#INSTANCE_.
   --


   -- public final
   type LexerMoreAction is new LexerAction with
   record
      --
      -- Provides a singleton instance of this parameterless lexer action.
      --
      -- public static
      INSTANCE : LexerMoreAction := This.LexerMoreAction; -- constant
   end record;

   subtype Object is LexerMoreAction;
   subtype Super is LexerAction;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   function "=" (Lhs, Rhs : LexerMoreAction) return Boolean;
   -- public
   overriding
   procedure hash (This : LexerMoreAction; hasher : in out Hasher);

   --
   -- Constructs the singleton instance of the lexer `more` command.
   --
   -- private
   overriding
   procedure Initialize (Self : LexerMoreAction) is null;

   --
   --
   -- * returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#MORE_.
   --
   overriding
   -- public
   function getActionType (This : LexerMoreAction) return LexerActionType
      is (This.LexerActionType.more);

   --
   --
   -- * returns: This method returns `False`.
   --
   overriding
   -- public
   function isPositionDependent (This : LexerMoreAction) return Boolean
      is (False);

   --
   --
   --
   -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#more_.
   --
   overriding
   -- public
   procedure execute (This : LexerMoreAction; lexer : Lexer);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_LexerMoreAction (S : in out Sink'Class; X : LexerMoreAction);
   for LexerMoreAction'Put_Image use Put_Image_LexerMoreAction;
   -- public
   function Description (This : LexerMoreAction) return UString
      is ("more");

end ANTLR.Runtime.ATN.LexerActions.LexerMoreActions;
