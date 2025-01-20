-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.LexerActionTypes;
with ANTLR.Runtime.Misc.Extensions.TokenExtensions;
with ANTLR.Runtime.Lexers;

use ANTLR.Runtime.ATN.LexerActionTypes;
use ANTLR.Runtime.Misc.Extensions.TokenExtensions;
use ANTLR.Runtime.Lexers;

package ANTLR.Runtime.ATN.LexerActions.LexerChannelActions is

   use ANTLR.Runtime.ATN.LexerActions;

   --
   -- Implements the `channel` lexer action by calling
   -- _org.antlr.v4.runtime.Lexer#setChannel_ with the assigned channel.
   --

   -- public final
   type LexerChannelAction is new LexerAction with --
   record
      -- fileprivate
      channel : Channel_Number; -- constant
   end record;

   subtype Object is LexerChannelAction;
   subtype Super is LexerAction;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   function "=" (Lhs, Rhs : LexerChannelAction) return Boolean;

   --
   -- Constructs a new `channel` action with the specified channel value.
   -- * parameter channel: The channel value to pass to _org.antlr.v4.runtime.Lexer#setChannel_.
   --
   -- public
   procedure Initialize (Self : in out LexerChannelAction; channel : Channel_Number);

   --
   -- Gets the channel to use for the _org.antlr.v4.runtime.Token_ created by the lexer.
   --
   -- * returns: The channel to use for the _org.antlr.v4.runtime.Token_ created by the lexer.
   --
   -- public
   function getChannel (This : LexerChannelAction) return Channel_Number
      is (This.channel);

   --
   -- * returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#CHANNEL_.
   --
   --public
   overriding
   function getActionType (This : LexerChannelAction) return LexerActionType
      is (LexerActionType.This.channel);

   --
   --
   -- * returns: This method returns `False`.
   --
   --public
   overriding
   function isPositionDependent (This : LexerChannelAction) return Boolean
      is (False);

   --
   --
   --
   -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#setChannel_ with the
   -- value provided by _#getChannel_.
   --

   -- public
   overriding
   procedure execute (This : LexerChannelAction; lexer : Lexer);

   -- public
   overriding
   procedure hash (This : LexerChannelAction; hasher : in out Hasher);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_LexerChannelAction (S : in out Sink'Class; X : LexerChannelAction);
   for LexerChannelAction'Put_Image use Put_Image_LexerChannelAction;
   -- public
   function Description (This : LexerChannelAction) return UString
      is ("channel" & This.channel'Image);

end ANTLR.Runtime.ATN.LexerActions.LexerChannelActions;