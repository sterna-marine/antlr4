-- Generated from grammar/Threading.g4 by ANTLR 4.13.2

with Antlr4;


-- 
-- This class provides an empty implementation of {@link ThreadingListener},
-- which can be extended to create a listener which only needs to handle a subset
-- of the available methods.
--
-- open
type ThreadingBaseListener is new ThreadingListener with null record;
     -- public
      procedure Initialize (Self : …) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterS (This : …; ctx : ThreadingParser.SContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitS (This : …; ctx : ThreadingParser.SContext) is null;

   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterAdd (This : …; ctx : ThreadingParser.AddContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitAdd (This : …; ctx : ThreadingParser.AddContext) is null;

   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterNumber (This : …; ctx : ThreadingParser.NumberContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitNumber (This : …; ctx : ThreadingParser.NumberContext) is null;

   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterMultiply (This : …; ctx : ThreadingParser.MultiplyContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitMultiply (This : …; ctx : ThreadingParser.MultiplyContext) is null;

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