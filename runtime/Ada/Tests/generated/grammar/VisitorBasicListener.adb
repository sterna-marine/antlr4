-- Generated from grammar/VisitorBasic.g4 by ANTLR 4.13.2
with Antlr4;

-- 
-- This interface defines a complete listener for a parse tree produced by
-- {@link VisitorBasicParser}.
--
-- public
protocol VisitorBasicListener : ParseTreeListener {
   -- 
   -- Enter a parse tree produced by {@link VisitorBasicParser#s}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterS (This : …; ctx : VisitorBasicParser.SContext)
   -- 
   -- Exit a parse tree produced by {@link VisitorBasicParser#s}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitS (This : …; ctx : VisitorBasicParser.SContext)
}