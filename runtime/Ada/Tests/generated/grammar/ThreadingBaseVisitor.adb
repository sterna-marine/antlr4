-- Generated from grammar/Threading.g4 by ANTLR 4.13.2
with Antlr4;

-- 
-- This class provides an empty implementation of {@link ThreadingVisitor},
-- which can be extended to create a visitor which only needs to handle a subset
-- of the available methods.
--
-- @param <T> The return type of the visit operation. Use {@link Void} for
-- operations with no return type.
--
-- open
class ThreadingBaseVisitor<T>: AbstractParseTreeVisitor<T> {
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation returns the result of calling
   -- {@link #visitChildren} on {@code ctx}.</p>
   --
   -- open
   function visitS (This : …; ctx : ThreadingParser.SContext) return Optional_T { return visitChildren(ctx) }
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation returns the result of calling
   -- {@link #visitChildren} on {@code ctx}.</p>
   --
   -- open
   function visitAdd (This : …; ctx : ThreadingParser.AddContext) return Optional_T { return visitChildren(ctx) }
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation returns the result of calling
   -- {@link #visitChildren} on {@code ctx}.</p>
   --
   -- open
   function visitNumber (This : …; ctx : ThreadingParser.NumberContext) return Optional_T { return visitChildren(ctx) }
   -- 
   -- {@inheritDoc}
   --
   -- <p>The default implementation returns the result of calling
   -- {@link #visitChildren} on {@code ctx}.</p>
   --
   -- open
   function visitMultiply (This : …; ctx : ThreadingParser.MultiplyContext) return Optional_T { return visitChildren(ctx) }
}