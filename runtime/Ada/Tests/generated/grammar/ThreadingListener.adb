-- Generated from grammar/Threading.g4 by ANTLR 4.13.2
with Antlr4;

-- 
-- This interface defines a complete listener for a parse tree produced by
-- {@link ThreadingParser}.
--
-- public
protocol ThreadingListener : ParseTreeListener {
   -- 
   -- Enter a parse tree produced by {@link ThreadingParser#s}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterS (This : …; ctx : ThreadingParser.SContext)
   -- 
   -- Exit a parse tree produced by {@link ThreadingParser#s}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitS (This : …; ctx : ThreadingParser.SContext)
   -- 
   -- Enter a parse tree produced by the {@code add}
   -- labeled alternative in {@link ThreadingParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterAdd (This : …; ctx : ThreadingParser.AddContext)
   -- 
   -- Exit a parse tree produced by the {@code add}
   -- labeled alternative in {@link ThreadingParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitAdd (This : …; ctx : ThreadingParser.AddContext)
   -- 
   -- Enter a parse tree produced by the {@code number}
   -- labeled alternative in {@link ThreadingParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterNumber (This : …; ctx : ThreadingParser.NumberContext)
   -- 
   -- Exit a parse tree produced by the {@code number}
   -- labeled alternative in {@link ThreadingParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitNumber (This : …; ctx : ThreadingParser.NumberContext)
   -- 
   -- Enter a parse tree produced by the {@code multiply}
   -- labeled alternative in {@link ThreadingParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterMultiply (This : …; ctx : ThreadingParser.MultiplyContext)
   -- 
   -- Exit a parse tree produced by the {@code multiply}
   -- labeled alternative in {@link ThreadingParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitMultiply (This : …; ctx : ThreadingParser.MultiplyContext)
}