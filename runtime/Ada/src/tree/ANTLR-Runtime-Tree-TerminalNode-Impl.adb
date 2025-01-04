-- €

package ANTLR.Runtime.Tree.TerminalNode.Impl is

   -- public
   type TerminalNodeImpl is new TerminalNode with
   record
      -- public
      symbol : Token;
      -- public weak
      parent : Optional_ParseTree;
   end record;

   -- public
   procedure Initialize (Self : in out TerminalNodeImpl; symbol : Token) is
   begin
      self.symbol := symbol;
   end Initialize;


   -- public
   function getChild (i : Integer) return Optional_Tree
      is (Valid => False);

   -- open 
   subscript (index : Integer) return ParseTree is
   begin
      preconditionFailure ("Index out of range (TerminalNode never has children)");
   end if;

   -- public
   function getSymbol (This : TerminalNodeImpl) return Optional_Token
      is (This.symbol);

   -- public
   function getParent (This : TerminalNodeImpl) return Optional_Tree
      is (This.parent);

   -- public
   procedure setParent (This : TerminalNodeImpl; parent : RuleContext) is
   begin
      This.parent := parent;
   end setParent;

   -- public
   function getPayload (This : TerminalNodeImpl) return AnyObject
      is (This.symbol);

   -- public
   function getSourceInterval (This : TerminalNodeImpl) return Interval is
   begin
      --if   not Is_Valid (symbol)   { return Interval.INVALID; }
      tokenIndex : constant Integer := symbol.getTokenIndex ();
      return Interval (tokenIndex, tokenIndex);
   end getSourceInterval;

    -- public
    function getChildCount (This : TerminalNodeImpl) return Integer
      is (0);

   package ParseTreeVisitors_T is new ParseTreeVisitors (T);
   -- public
   function accept_T (visitor : ParseTreeVisitors_T.ParseTreeVisitor) return Optional_T is
   begin
      return visitor.visitTerminal (self);
   end accept_T;

   -- public
   function getText (This : TerminalNodeImpl) return UString
   is (symbol.getText ())!;

   -- public
   function toStringTree (This : TerminalNodeImpl; parser : Parser) return UString
   is (This'Image);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_TerminalNodeImpl (S : in out Sink'Class; X : TerminalNodeImpl);
   for TerminalNodeImpl'Put_Image use Put_Image_TerminalNodeImpl;
   function Description (This : TerminalNodeImpl) return UString is
   begin
      --TODO: not Is_Valid (symbol)?
      --if    not Is_Valid (symbol)   {return "<null>"; }
      if symbol.getType () == CommonToken.EOF then
         return "<EOF>";
      else
         return symbol.getText ()!;
      end if;
   end Description;

   -- public
   function debugDescription (This : TerminalNodeImpl) return UString
      is (Description (This));

   -- public
   function toStringTree (This : TerminalNodeImpl) return UString
      is (This'Image);

end ANTLR.Runtime.Tree.TerminalNode.Impl;
