-- €

package body ANTLR.Runtime.Tree.TerminalNode.Impl is

   procedure Initialize (Self : in out TerminalNodeImpl; symbol : Token) is
   begin
      self.symbol := symbol;
   end Initialize;

   function subscript (index : Integer) return ParseTree is
   begin
      This.preconditionFailure ("Index out of range (TerminalNode never has children)");
   end subscript;

   procedure setParent (This : TerminalNodeImpl; parent : RuleContext) is
   begin
      This.parent := parent;
   end setParent;

   function getSourceInterval (This : TerminalNodeImpl) return Interval is
   begin
      --  if not Is_Valid (symbol)   { return Interval.INVALID; }
      tokenIndex : constant Integer := symbol.getTokenIndex;
      return Interval (tokenIndex, tokenIndex);
   end getSourceInterval;

   function Description (This : TerminalNodeImpl) return UString is
   begin
      --TODO: not Is_Valid (symbol)?
      --if    not Is_Valid (symbol)   {return "<null>"; }
      if symbol.getType = EOF then
         return "<EOF>";
      else
         return Value (symbol.getText);
      end if;
   end Description;

end ANTLR.Runtime.Tree.TerminalNode.Impl;
