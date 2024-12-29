-- €

package body ANTLR.Runtime.ATN.LexerModeAction is

   procedure Initialize (Self : in out LexerModeAction; mode : Lexer_Mode) is
   begin
      self.mode := mode;
   end Initialize;

   overriding
   procedure execute (This : LexerModeAction; lexer : Lexer) is
   begin
      lexer.mode (This.mode);
   end execute;

   overriding
   procedure hash (This : LexerModeAction; hasher : in out Hasher) is
   begin
      hasher.combine (This.mode);
   end hash;

   function "=" (Lhs, Rhs : LexerModeAction) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.mode = rhs.mode;
   end "=";

end ANTLR.Runtime.ATN.LexerModeAction;
