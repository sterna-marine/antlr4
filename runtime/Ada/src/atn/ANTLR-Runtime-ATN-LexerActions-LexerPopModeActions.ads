-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.LexerActionTypes;
with ANTLR.Runtime.Recognizers.Lexers;

use ANTLR.Runtime.ATN.LexerActionTypes;
use ANTLR.Runtime.Recognizers.Lexers;

package ANTLR.Runtime.ATN.LexerActions.LexerPopModeActions is

   use ANTLR.Runtime.ATN.LexerActions;

   --
   -- Implements the `popMode` lexer action by calling _org.antlr.v4.runtime.Lexer#popMode_.
   --
   -- The `popMode` command does not have any parameters, so this action is
   -- implemented as a singleton instance exposed by _#INSTANCE_.
   --

   --
   -- Provides a singleton instance of this parameterless lexer action.
   --
   -- public static
   INSTANCE : constant LexerPopModeAction := This.LexerPopModeAction;

   -- public final
   type LexerPopModeAction is new LexerAction with null record;

   subtype Object is LexerPopModeAction;
   subtype Super is LexerAction;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   function "=" (Lhs, Rhs : LexerPopModeAction) return Boolean;
   -- public
   overriding
   procedure hash (This : LexerPopModeAction; hasher : in out Hasher);

   --
   -- Constructs the singleton instance of the lexer `popMode` command.
   --
   -- private
   overriding
   procedure Initialize (Self : LexerPopModeAction) is null;

   --
   --
   -- * returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#popMode_.
   --
   overriding
   -- public
   function getActionType (This : LexerPopModeAction) return LexerActionType
      is (This.LexerActionType.popMode);

   --
   --
   -- * returns: This method returns `False`.
   --
   --public
   overriding
   function isPositionDependent (This : LexerPopModeAction) return Boolean
      is (False);

   --
   --
   --
   -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#popMode_.
   --
   -- public
   overriding
   procedure execute (This : LexerPopModeAction; lexer : Lexer);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_LexerPopModeAction (S : in out Sink'Class; X : LexerPopModeAction);
   for LexerPopModeAction'Put_Image use Put_Image_LexerPopModeAction;
   -- public
   function Description (This : LexerPopModeAction) return UString
      is ("popMode");
   
end ANTLR.Runtime.ATN.LexerActions.LexerPopModeActions;
