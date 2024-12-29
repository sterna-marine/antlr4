-- €

package body ANTLR.Runtime.ATN.LexerCustomAction is

   procedure Initialize (Self : in out LexerCustomAction; ruleIndex : Integer; actionIndex : Integer) is
   begin
      self.ruleIndex := ruleIndex;
      self.actionIndex := actionIndex;
   end Initialize;

   overriding
   procedure execute (This : LexerCustomAction; lexer : Lexer) is
   begin
      lexer.action (This, (Valid => False), ruleIndex, actionIndex);
   end execute;

   overriding
   procedure hash (This : LexerCustomAction; hasher: in out Hasher) is
   begin
      hasher.combine (ruleIndex);
      hasher.combine (actionIndex);
   end hash;

   function "=" (Lhs, Rhs : LexerCustomAction) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.ruleIndex = rhs.ruleIndex
               and then lhs.actionIndex = rhs.actionIndex;
   end "=";

end ANTLR.Runtime.ATN.LexerCustomAction;
