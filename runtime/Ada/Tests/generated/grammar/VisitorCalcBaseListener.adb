-- Generated from grammar/VisitorCalc.g4 by ANTLR 4.13.2

with Antlr4;


-- 
-- This class provides an empty implementation of {@link VisitorCalcListener},
-- which can be extended to create a listener which only needs to handle a subset
-- of the available methods.
--
-- open
type VisitorCalcBaseListener is new VisitorCalcListener with null record;
     -- public
      procedure Initialize (Self : …) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterS (This : …; ctx : VisitorCalcParser.SContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitS (This : …; ctx : VisitorCalcParser.SContext) is null;

   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterAdd (This : …; ctx : VisitorCalcParser.AddContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitAdd (This : …; ctx : VisitorCalcParser.AddContext) is null;

   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterNumber (This : …; ctx : VisitorCalcParser.NumberContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitNumber (This : …; ctx : VisitorCalcParser.NumberContext) is null;

   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure enterMultiply (This : …; ctx : VisitorCalcParser.MultiplyContext) is null;
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation does nothing.</p>
   --
   -- open
   procedure exitMultiply (This : …; ctx : VisitorCalcParser.MultiplyContext) is null;

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