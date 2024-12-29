-- €

package body ANTLR.Runtime.ATN.LexerActions.LexerMoreActions is

   overriding
   procedure execute (This : LexerMoreAction; lexer : Lexer) is
   begin
      This.lexer.more ();
   end execute;

   overriding
   procedure hash (This : LexerMoreAction; hasher : in out Hasher) is
   begin
      hasher.combine (ObjectIdentifier (This));
   end hash;

   function "=" (Lhs, Rhs : LexerMoreAction) return Boolean is
   begin
      return lhs === rhs;
   end "=";

end ANTLR.Runtime.ATN.LexerActions.LexerMoreActions;
