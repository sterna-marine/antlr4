-- €

package body ANTLR.Runtime.ATN.LexerTypeAction is

   procedure Initialize (Self : in out LexerTypeAction; Type_of_Action: Token_Kind) is
   begin
      Self.Type_of_Action := Type_of_Action;
   end Initialize;

   overriding
   procedure execute (This : LexerTypeAction; lexer : Lexer) is
   begin
      lexer.setType (This.Type_of_Action);
   end execute;

   overriding
   procedure hash (This : LexerTypeAction; hasher : in out Hasher) is
   begin
      hasher.combine (This.Type_of_Action);
   end hash;

   -- public
   function "=" (Lhs, Rhs : LexerTypeAction) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.This.Type_of_Action = rhs.This.Type_of_Action;
   end "=";

end ANTLR.Runtime.ATN.LexerTypeAction;
