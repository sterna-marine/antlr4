-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.LexerActionTypes;
with ANTLR.Runtime.Recognizers.Lexers;

use ANTLR.Runtime.ATN.LexerActionTypes;
use ANTLR.Runtime.Recognizers.Lexers;

package ANTLR.Runtime.ATN.LexerActions.LexerPushModeActions is

   use ANTLR.Runtime.ATN.LexerActions;

   --
   -- Implements the `pushMode` lexer action by calling
   -- _org.antlr.v4.runtime.Lexer#pushMode_ with the assigned mode.
   --

   -- public final
   type LexerPushModeAction is new LexerAction with
   record
      -- fileprivate
      mode : Lexer_Mode; -- constant
   end record;

   subtype Object is LexerPushModeAction;
   subtype Super is LexerAction;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   function "=" (Lhs, Rhs : LexerPushModeAction) return Boolean;
   
   -- public
   overriding
   procedure hash (This : LexerPushModeAction; hasher : in out Hasher);

   --
   -- Constructs a new `pushMode` action with the specified mode value.
   -- * parameter mode: The mode value to pass to _org.antlr.v4.runtime.Lexer#pushMode_.
   --
   -- public
   procedure Initialize (Self : in out LexerPushModeAction; mode : Lexer_Mode);

   --
   -- Get the lexer mode this action should transition the lexer to.
   --
   -- * returns: The lexer mode for this `pushMode` command.
   --
   -- public
   function getMode (This : LexerPushModeAction) return Integer
      is (This.mode);

   --
   --
   -- * returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#pushMode_.
   --
   --public
   overriding
   function getActionType (This : LexerPushModeAction) return LexerActionType
      is (This.LexerActionType.pushMode);

   --
   --
   -- * returns: This method returns `False`.
   --
   --public
   overriding
   function isPositionDependent (This : LexerPushModeAction) return Boolean
      is (False);

   --
   --
   --
   -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#pushMode_ with the
   -- value provided by _#getMode_.
   --
   overriding
   -- public
   procedure execute (This : LexerPushModeAction; lexer : Lexer);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_LexerPushModeAction (S : in out Sink'Class; X : LexerPushModeAction);
   for LexerPushModeAction'Put_Image use Put_Image_LexerPushModeAction;
   -- public
   function Description (This : LexerPushModeAction) return UString
      is ("pushMode (" & mode'Image & ')');

end ANTLR.Runtime.ATN.LexerActions.LexerPushModeActions;
