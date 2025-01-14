-- Generated from grammar/VisitorCalc.g4 by ANTLR 4.13.2
with Antlr4;

-- 
-- This interface defines a complete listener for a parse tree produced by
-- {@link VisitorCalcParser}.
--
-- public
protocol VisitorCalcListener : ParseTreeListener {
   -- 
   -- Enter a parse tree produced by {@link VisitorCalcParser#s}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterS (This : …; ctx : VisitorCalcParser.SContext)
   -- 
   -- Exit a parse tree produced by {@link VisitorCalcParser#s}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitS (This : …; ctx : VisitorCalcParser.SContext)
   -- 
   -- Enter a parse tree produced by the {@code add}
   -- labeled alternative in {@link VisitorCalcParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterAdd (This : …; ctx : VisitorCalcParser.AddContext)
   -- 
   -- Exit a parse tree produced by the {@code add}
   -- labeled alternative in {@link VisitorCalcParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitAdd (This : …; ctx : VisitorCalcParser.AddContext)
   -- 
   -- Enter a parse tree produced by the {@code number}
   -- labeled alternative in {@link VisitorCalcParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterNumber (This : …; ctx : VisitorCalcParser.NumberContext)
   -- 
   -- Exit a parse tree produced by the {@code number}
   -- labeled alternative in {@link VisitorCalcParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitNumber (This : …; ctx : VisitorCalcParser.NumberContext)
   -- 
   -- Enter a parse tree produced by the {@code multiply}
   -- labeled alternative in {@link VisitorCalcParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure enterMultiply (This : …; ctx : VisitorCalcParser.MultiplyContext)
   -- 
   -- Exit a parse tree produced by the {@code multiply}
   -- labeled alternative in {@link VisitorCalcParser#expr}.
    - Parameters :
      - ctx : the parse tree
   --
   procedure exitMultiply (This : …; ctx : VisitorCalcParser.MultiplyContext)
}