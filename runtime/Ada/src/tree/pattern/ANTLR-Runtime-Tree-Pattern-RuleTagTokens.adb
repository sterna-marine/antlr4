-- €

package body ANTLR.Runtime.Tree.Pattern.RuleTagTokens is

   procedure Initialize (Self : in out RuleTagToken;
                         ruleName : UString;
                         bypassTokenType : Token_Kind) is
   begin
      Self.Initialize (ruleName, bypassTokenType, label => (Valid => False));
   end Initialize;

   procedure Initialize (Self : in out RuleTagToken;
                         ruleName : UString;
                         bypassTokenType : Token_Kind;
                         label : Optional_UString) is
   begin
      self.ruleName := ruleName;
      self.bypassTokenType := bypassTokenType;
      self.label := label;
   end Initialize;

   function getText (This : RuleTagToken) return Optional_UString is
   begin
      if Is_Valid (This.label) then
         return '<' & This.label'Image & ':' & This.ruleName'Image & '>';
      else
         return '<' & This.ruleName'Image & '>';
      end if;
   end getText;

end ANTLR.Runtime.Tree.Pattern.RuleTagTokens;
