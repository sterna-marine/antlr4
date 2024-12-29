-- €

package body ANTLR.Runtime.ATN.LexerActions.LexerChannelActions is

   procedure Initialize (Self : in out LexerChannelAction; channel : Channel_Number) is
      self.channel := channel;
   end Initialize;

   procedure execute (This : LexerChannelAction; lexer : Lexer) is
   begin
      lexer.setChannel (This.channel);
   end execute;

   overriding
   procedure hash (This : LexerChannelAction; hasher : in out Hasher) is
   begin
      hasher.combine (getActionType ());
      hasher.combine (This.channel);
   end hash;

   function "=" (Lhs, Rhs : LexerChannelAction) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.channel = rhs.channel;
   end "=";

end ANTLR.Runtime.ATN.LexerActions.LexerChannelActions;