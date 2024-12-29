-- €

package body ANTLR.Runtime.ATN.LexerSkipAction is

   overriding
   procedure execute (This : LexerSkipAction; lexer : Lexer) is
   begin
      lexer.skip (This);
   end execute;

   overriding
   procedure hash (This : LexerSkipAction; hasher : in out Hasher) is
   begin
      hasher.combine (ObjectIdentifier (This));
   end hash;

   function "=" (Lhs, Rhs : LexerSkipAction) return Boolean is
   begin
      return lhs === rhs;
   end "=";

end ANTLR.Runtime.ATN.LexerSkipAction;
