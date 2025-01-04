-- €

with Option;
with Ada.Containers.Vectors;

package ANTLR.Runtime.Tree.ParseTreeListener_Protocol is

   -- This interface describes the minimal core of methods triggered
   -- by _org.antlr.v4.runtime.tree.ParseTreeWalker_. E.g.,
   --
   -- ParseTreeWalker walker := new This.ParseTreeWalker;
   -- walker.walk (myParseTreeListener, myParseTree); <-- triggers events in your listener
   --
   -- If you want to trigger events in multiple listeners during a single
   -- tree walk, you can use the ParseTreeDispatcher object available at
   --
   -- https:--github.com/antlr/antlr4/issues/841
   --

   -- public
   type ParseTreeListener is interface;

   package ParseTreeListener_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Item_Type => ParseTreeListener,
      "=" => "=");
   subtype ParseTreeListener_List is ParseTreeListener_Container.Vector;

   procedure visitTerminal (This : ParseTreeListener; node : TerminalNode) is abstract;

   procedure visitErrorNode (This : ParseTreeListener; node : ErrorNode) is abstract;

   procedure enterEveryRule (This : ParseTreeListener; ctx : ParserRuleContext) is abstract;

   procedure exitEveryRule (This : ParseTreeListener; ctx : ParserRuleContext) is abstract;

end ANTLR.Runtime.Tree.ParseTreeListener_Protocol;
