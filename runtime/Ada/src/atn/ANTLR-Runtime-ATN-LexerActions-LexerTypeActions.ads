-- €

with ANTLR.Runtime.ATN.LexerActionTypes;
with ANTLR.Runtime.Recognizers.Lexers;

use ANTLR.Runtime.Recognizers.Lexers;
use ANTLR.Runtime.ATN.LexerActionTypes;

package ANTLR.Runtime.ATN.LexerActions.LexerTypeActions is

   use ANTLR.Runtime.ATN.LexerActions;

   --
   -- Implements the `type` lexer action by calling _org.antlr.v4.runtime.Lexer#setType_
   -- with the assigned type.
   --

   -- public
   type LexerTypeAction is new LexerAction with
   record
      -- fileprivate
      Type_of_Action : constant Integer;
   end record;

   subtype Object is LexerTypeAction;
   subtype Super is LexerAction;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   function "=" (Lhs, Rhs : LexerTypeAction) return Boolean;

   -- public
   overriding
   procedure hash (This : LexerTypeAction; hasher : in out Hasher);

   --
   -- Constructs a new `type` action with the specified token type value.
   -- * parameter type: The type to assign to the token using _org.antlr.v4.runtime.Lexer#setType_.
   --
   -- public
   procedure Initialize (Self : in out LexerTypeAction; Type_of_Action: Token_Kind);

   --
   -- Gets the type to assign to a token created by the lexer.
   -- * returns: The type to assign to a token created by the lexer.
   --
   -- public
   function getType (This : LexerTypeAction) return Integer
      is (This.Type_of_Action);

   --
   --
   -- * returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#TYPE_.
   --
   --public
   overriding
   function getActionType (This : LexerTypeAction) return LexerActionType
      is (This.LexerActionType.Type_of_Action);

   --
   --
   -- * returns: This method returns `False`.
   --
   overriding
   -- public
   function isPositionDependent (This : LexerTypeAction) return Boolean
      is (False);

   --
   --
   --
   -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#setType_ with the
   -- value provided by _#getType_.
   --
   -- public
   overriding
   procedure execute (This : LexerTypeAction; lexer : Lexer);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_LexerTypeAction (S : in out Sink'Class; X : LexerTypeAction);
   for LexerTypeAction'Put_Image use Put_Image_LexerTypeAction;
   function Description (This : LexerTypeAction) return UString
      is ("type (" & This.Type_of_Action'Image & ")");

end ANTLR.Runtime.ATN.LexerActions.LexerTypeActions;
