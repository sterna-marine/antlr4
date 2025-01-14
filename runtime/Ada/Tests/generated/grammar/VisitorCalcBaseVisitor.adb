-- Generated from grammar/VisitorCalc.g4 by ANTLR 4.13.2
with Antlr4;

-- 
-- This class provides an empty implementation of {@link VisitorCalcVisitor},
-- which can be extended to create a visitor which only needs to handle a subset
-- of the available methods.
--
-- @param <T> The return type of the visit operation. Use {@link Void} for
-- operations with no return type.
--
-- open
class VisitorCalcBaseVisitor<T>: AbstractParseTreeVisitor<T> {
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation returns the result of calling
   -- {@link #visitChildren} on {@code ctx}.</p>
   --
   -- open
   function visitS (This : …; ctx : VisitorCalcParser.SContext) return Optional_T { return visitChildren(ctx) }
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation returns the result of calling
   -- {@link #visitChildren} on {@code ctx}.</p>
   --
   -- open
   function visitAdd (This : …; ctx : VisitorCalcParser.AddContext) return Optional_T { return visitChildren(ctx) }
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation returns the result of calling
   -- {@link #visitChildren} on {@code ctx}.</p>
   --
   -- open
   function visitNumber (This : …; ctx : VisitorCalcParser.NumberContext) return Optional_T { return visitChildren(ctx) }
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation returns the result of calling
   -- {@link #visitChildren} on {@code ctx}.</p>
   --
   -- open
   function visitMultiply (This : …; ctx : VisitorCalcParser.MultiplyContext) return Optional_T { return visitChildren(ctx) }
}