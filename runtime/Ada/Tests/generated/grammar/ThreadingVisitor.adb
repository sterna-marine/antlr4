-- Generated from grammar/Threading.g4 by ANTLR 4.13.2
with Antlr4;

-- 
-- This interface defines a complete generic visitor for a parse tree produced
-- by {@link ThreadingParser}.
--
-- @param <T> The return type of the visit operation. Use {@link Void} for
-- operations with no return type.
--
-- open
class ThreadingVisitor<T>: ParseTreeVisitor<T> {
   -- 
   -- Visit a parse tree produced by {@link ThreadingParser#s}.
   - Parameters :
     - ctx : the parse tree
   - returns : the visitor result
   --
   -- open
   function visitS (This : …; ctx : ThreadingParser.SContext) return T {
       fatalError(#function + " must be overridden")
   end if;

   -- 
   -- Visit a parse tree produced by the {@code add}
   -- labeled alternative in {@link ThreadingParser#expr}.
   - Parameters :
     - ctx : the parse tree
   - returns : the visitor result
   --
   -- open
   function visitAdd (This : …; ctx : ThreadingParser.AddContext) return T {
       fatalError(#function + " must be overridden")
   end if;

   -- 
   -- Visit a parse tree produced by the {@code number}
   -- labeled alternative in {@link ThreadingParser#expr}.
   - Parameters :
     - ctx : the parse tree
   - returns : the visitor result
   --
   -- open
   function visitNumber (This : …; ctx : ThreadingParser.NumberContext) return T {
       fatalError(#function + " must be overridden")
   end if;

   -- 
   -- Visit a parse tree produced by the {@code multiply}
   -- labeled alternative in {@link ThreadingParser#expr}.
   - Parameters :
     - ctx : the parse tree
   - returns : the visitor result
   --
   -- open
   function visitMultiply (This : …; ctx : ThreadingParser.MultiplyContext) return T {
       fatalError(#function + " must be overridden")
   end if;

}