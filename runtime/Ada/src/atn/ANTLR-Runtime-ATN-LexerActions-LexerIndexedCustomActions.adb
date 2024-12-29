-- €

package body ANTLR.Runtime.ATN.LexerActions.LexerIndexedCustomActions is

    procedure Initialize (Self : in out LexerIndexedCustomAction; offset : Integer; action : LexerAction) is
    begin
        self.offset := offset;
        self.action := action;
    end Initialize;

    overriding
    procedure execute (This : LexerIndexedCustomAction; lexer : Lexer) is
    begin
        -- assume the input stream position was properly set by the calling code
        This.action.execute (lexer);
    end execute;

    overriding
    procedure hash (This : LexerIndexedCustomAction; hasher : in out Hasher) is
    begin
        hasher.combine (offset);
        hasher.combine (action);
    end hash;

   function "=" (Lhs, Rhs : LexerIndexedCustomAction) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.offset = rhs.offset
               and then lhs.action = rhs.action;
   end "=";

end ANTLR.Runtime.ATN.LexerActions.LexerIndexedCustomActions;
