-- €

package ANTLR.Runtime.Tree.ParseTreeListener_Protocol is

   -- This interface describes the minimal core of methods triggered
   -- by _org.antlr.v4.runtime.tree.ParseTreeWalker_. E.g.,
   --
   -- ParseTreeWalker walker := new ParseTreeWalker ();
   -- walker.walk (myParseTreeListener, myParseTree); <-- triggers events in your listener
   --
   -- If you want to trigger events in multiple listeners during a single
   -- tree walk, you can use the ParseTreeDispatcher object available at
   --
   -- https:--github.com/antlr/antlr4/issues/841
   --

   -- public
   type ParseTreeListener is interface;

    procedure visitTerminal (This :ParseTreeListener; node : TerminalNode);

    procedure visitErrorNode (This :ParseTreeListener; node : ErrorNode);

    procedure enterEveryRule (This :ParseTreeListener; ctx : ParserRuleContext);

    procedure exitEveryRule (This :ParseTreeListener; ctx : ParserRuleContext);

end ANTLR.Runtime.Tree.ParseTreeListener_Protocol;
