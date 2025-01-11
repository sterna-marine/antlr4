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
   procedure Initialize (Self : in out TerminalNodeImpl; symbol : Token);

   -- public
   function getChild (i : Integer) return Optional_Tree
      is (Valid => False);

   -- open 
   function subscript (index : Integer) return ParseTree;

   -- public
   function getSymbol (This : TerminalNodeImpl) return Optional_Token
      is (This.symbol);

   -- public
   function getParent (This : TerminalNodeImpl) return Optional_Tree
      is (This.parent);

   -- public
   procedure setParent (This : TerminalNodeImpl; parent : RuleContext);

   -- public
   function getPayload (This : TerminalNodeImpl) return AnyObject
      is (This.symbol);

   -- public
   function getSourceInterval (This : TerminalNodeImpl) return Interval;

    -- public
    function getChildCount (This : TerminalNodeImpl) return Integer
      is (0);

   package ParseTreeVisitors_T is new ParseTreeVisitors (T);
   subtype ParseTreeVisitor_T is ParseTreeVisitors_T.ParseTreeVisitor;

   -- public
   function accept_T (visitor : ParseTreeVisitor_T) return Optional_T
      is (visitor.visitTerminal (This));

   -- public
   function getText (This : TerminalNodeImpl) return UString
      is (symbol.getText)!;

   -- public
   function toStringTree (This : TerminalNodeImpl; parser : Parser) return UString
      is (This'Image);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_TerminalNodeImpl (S : in out Sink'Class; X : TerminalNodeImpl);
   for TerminalNodeImpl'Put_Image use Put_Image_TerminalNodeImpl;
   -- public
   function Description (This : TerminalNodeImpl) return UString;

   -- public
   function debugDescription (This : TerminalNodeImpl) return UString
      is (Description (This));

   -- public
   function toStringTree (This : TerminalNodeImpl) return UString
      is (This'Image);

end ANTLR.Runtime.Tree.TerminalNode.Impl;
