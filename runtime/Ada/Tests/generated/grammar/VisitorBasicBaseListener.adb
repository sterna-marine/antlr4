-- Generated from grammar/VisitorBasic.g4 by ANTLR 4.13.2

with Antlr4;


-- 
-- This class provides an empty implementation of {@link VisitorBasicListener},
-- which can be extended to create a listener which only needs to handle a subset
-- of the available methods.
--
-- open
type VisitorBasicBaseListener is new VisitorBasicListener with null record;
     -- public
      procedure Initialize (Self : …) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterS (This : …; ctx : VisitorBasicParser.SContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitS (This : …; ctx : VisitorBasicParser.SContext) is null;

   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterEveryRule (This : …; ctx : ParserRuleContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitEveryRule (This : …; ctx : ParserRuleContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure visitTerminal (This : …; node : TerminalNode) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure visitErrorNode (This : …; node : ErrorNode) is null;
}