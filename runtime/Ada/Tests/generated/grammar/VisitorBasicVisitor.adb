-- Generated from grammar/VisitorBasic.g4 by ANTLR 4.13.2
with Antlr4;

-- 
-- This interface defines a complete generic visitor for a parse tree produced
-- by {@link VisitorBasicParser}.
--
-- @param <T> The return type of the visit operation. Use {@link Void} for
-- operations with no return type.
--
-- open
class VisitorBasicVisitor<T>: ParseTreeVisitor<T> {
   -- 
   -- Visit a parse tree produced by {@link VisitorBasicParser#s}.
   - Parameters :
     - ctx : the parse tree
   - returns : the visitor result
   --
   -- open
   function visitS (This : …; ctx : VisitorBasicParser.SContext) return T {
       fatalError(#function + " must be overridden")
   end if;

}