-- €

with ANTLR.Runtime.ATN.LexerAction;

use ANTLR.Runtime.ATN.LexerAction;

package ANTLR.Runtime.ATN.LexerActions.LexerModeActions is

   --
   -- Implements the `mode` lexer action by calling _org.antlr.v4.runtime.Lexer#mode_ with
   -- the assigned mode.
   --

   -- public final
   type LexerModeAction is new LexerAction with
   record
      -- fileprivate
      mode : Integer; -- constant
   end record;

   subtype Object is LexerModeAction;
   subtype Super is LexerAction;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   --
   -- Constructs a new `mode` action with the specified mode value.
   -- * parameter mode: The mode value to pass to _org.antlr.v4.runtime.Lexer#mode_.
   --
   -- public
   procedure Initialize (Self : in out LexerModeAction; mode : Lexer_Mode);

   --
   -- Get the lexer mode this action should transition the lexer to.
   --
   -- * returns: The lexer mode for this `mode` command.
   --
   -- public
   function getMode (This : LexerModeAction) return Integer
      is (This.mode);

   --
   --
   -- * returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#MODE_.
   --
   --public
   overriding
   function getActionType (This : LexerModeAction) return LexerActionType
      is (This.LexerActionType.mode);

   --
   --
   -- * returns: This method returns `False`.
   --
   --public
   overriding
   function isPositionDependent (This : LexerModeAction) return Boolean
      is (False);

   --
   --
   --
   -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#mode_ with the
   -- value provided by _#getMode_.
   --
   overriding
   -- public
   procedure execute (This : LexerModeAction; lexer : Lexer);

   -- public
   overriding
   procedure hash (This : LexerModeAction; hasher : in out Hasher);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_LexerModeAction (S : in out Sink'Class; X : LexerModeAction);
   for LexerModeAction'Put_Image use Put_Image_LexerModeAction;
   function Description (This : LexerModeAction) return UString
      is ("mode (" & This.mode'Image & ")");

   -- public
   function "=" (Lhs, Rhs : LexerModeAction) return Boolean;

end ANTLR.Runtime.ATN.LexerActions.LexerModeActions;
