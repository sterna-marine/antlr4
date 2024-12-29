-- €

package body ANTLR.Runtime.ATN.LexerPopModeAction is

   overriding
   procedure execute (This : LexerPopModeAction; lexer : Lexer) is
   begin
      lexer.popMode (This);
   end execute;

   overriding
   procedure hash (This : LexerPopModeAction; hasher : in out Hasher) is
   begin
      hasher.combine (ObjectIdentifier (This));
   end hash;

   function "=" (Lhs, Rhs : LexerPopModeAction) return Boolean is
   begin
      return lhs === rhs;
   end "=";

end ANTLR.Runtime.ATN.LexerPopModeAction;
