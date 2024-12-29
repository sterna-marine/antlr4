-- €

package body ANTLR.Runtime.ATN.LexerActions.LexerPushModeActions is

   procedure Initialize (Self : in out LexerPushModeAction; mode : Lexer_Mode) is
   begin
      self.mode := mode;
   end Initialize;

   overriding
   procedure execute (This : LexerPushModeAction; lexer : Lexer) is
   begin
      lexer.pushMode (This.mode);
   end execute;

   overriding
   procedure hash (This : LexerPushModeAction; hasher : in out Hasher) is
   begin
      hasher.combine (This.mode);
   end hash;

   function "=" (Lhs, Rhs : LexerPushModeAction) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.mode = rhs.mode;
   end "=";

end ANTLR.Runtime.ATN.LexerActions.LexerPushModeActions;
