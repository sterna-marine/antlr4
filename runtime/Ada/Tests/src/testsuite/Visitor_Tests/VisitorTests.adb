-- €

with ANTLR.Runtime;
with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.Lexers;
with ANTLR.Runtime.Parsers;
with ANTLR.Runtime.BaseErrorListener;
with ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;

with VisitorBasicLexer; -- generated
with VisitorBasicParser; -- generated
with VisitorBasicBaseVisitor; -- generated

with AdaForge.DevTools.TestTools.UnitTest;

use AdaForge.DevTools.TestTools.UnitTest;
use ANTLR.Runtime;

package body VisitorTests is

   overriding
   procedure Initialize (T : in out Test) is
   begin
      Set_Name (T, "Visitor Tests");

      UnitTest.Add_Test_Routine (T, testCalculatorVisitor'Access, "Verifies that the visitor correctly dispatches calls for labeled outer alternatives.");
      UnitTest.Add_Test_Routine (T, testShouldNotVisitTerminal'Access, "Verifies that 'AbstractParseTreeVisitor#shouldVisitNextChild' is called before visiting the first child. It also verifies that 'AbstractParseTreeVisitors.defaultResult' provides the default return value for visiting a tree.");
      UnitTest.Add_Test_Routine (T, testShouldNotVisitEOF'Access, "Verifies that 'AbstractParseTreeVisitors.visitChildren' does not call 'ParseTreeVisitor.visit' after 'AbstractParseTreeVisitors.shouldVisitNextChild' returns 'False'.");
      UnitTest.Add_Test_Routine (T, testVisitErrorNode'Access, "Verifies the basic behavior of visitors, with an emphasis on 'AbstractParseTreeVisitors.visitErrorNode.");
      UnitTest.Add_Test_Routine (T, testVisitTerminalNode'Access, "Verifies the basic behavior of visitors, with an emphasis on 'AbstractParseTreeVisitors.visitTerminal'.");
   end Initialize;

   --
   -- This test verifies the basic behavior of visitors, with an emphasis on
   -- {@link AbstractParseTreeVisitor#visitTerminal}.
   --
   procedure testVisitTerminalNode is

      type Visitor is new VisitorBasicBaseVisitor<UString> with null record;

      lexer   : ANTLR.Runtime.Lexers.Lexer;
      parser  : ANTLR.Runtime.Parsers.Parser;
      context : ANTLR.Runtime.RuleContexts.ParserRuleContexts.Optional_ParserRuleContext;
      This_visitor : Visitor;
      result :  visitor.visit (context);

      overriding
      function visitTerminal (node : TerminalNode) return Optional_String is
      begin
            return Value (node.getSymbol ()) & "\n";
      end visitTerminal;

      overriding
      function defaultResult return Optional_String is
      begin
            return "";
      end defaultResult;

      overriding
      function aggregateResult (aggregate : Optional_UString; nextResult : Optional_UString) return Optional_UString is
      begin
         return Value (aggregate) & Value (nextResult);
      end aggregateResult;

      expected : constant UString :=
         "[@0,0:0='A',<1>,1:0]\n" &
         "[@1,1:0='<EOF>',<-1>,1:1]\n"
   begin
      lexer  := VisitorBasicLexer (ANTLR.Runtime.ANTLRInputStreamr.Initialize ("A"));
      parser := VisitorBasicParser (ANTLR.Runtime.CommonTokenStreams.Initialize (lexer));
      context := parser.getContext;

      UnitTest.Assert_Equal ("(s A <EOF>)", context.toStringTree (parser));

      This_visitor := Visitor.Initialize;
      result : constant := visitor.visit (context);
      UnitTest.Assert_Equal (expected, result);
   end testVisitTerminalNode;

   --
   -- This test verifies the basic behavior of visitors, with an emphasis on
   -- {@link AbstractParseTreeVisitor#visitErrorNode}.
   --
   procedure testVisitErrorNode is
      lexer   : ANTLR.Runtime.Lexers.Lexer;
      parser  : ANTLR.Runtime.Parsers.Parser;
      context : ANTLR.Runtime.RuleContexts.ParserRuleContexts.Optional_ParserRuleContext;
   begin
      lexer  := VisitorBasicLexer (ANTLR.Runtime.ANTLRInputStreams.Initialize (""));
      parser := VisitorBasicParser (ANTLR.Runtime.CommonTokenStreams.Initialize (lexer));

      type ErrorListener is new ANTLR.Runtime.BaseErrorListener with null record;

         overriding
         procedure Initialize (Self : in out ErrorListener) is
         begin
               ANTLR.Runtime.BaseErrorListener (Self).Initialize;
         end Initialize;

         errors : UString_List;

         overriding
         procedure syntaxError<T> (recognizer : Recognizer<T>,
                                   offendingSymbol : Optional_AnyObject;
                                   line : Integer;
                                   charPositionInLine : Integer;
                                   msg : UString;
                                   e : Optional_AnyObject) is
         begin
            errors.append ("line " & line'Image & ":" & charPositionInLine'Image & " " & msg'Image);
         end syntaxError;

      parser.removeErrorListeners ();
      errorListener : constant := This.ErrorListener;
      parser.addErrorListener (errorListener);

      context : constant := parser.s ();
      errors : constant := errorListener.errors;
      UnitTest.Assert_Equal ("(s <missing 'A'> <EOF>)", context.toStringTree (parser));
      UnitTest.Assert_Equal (1, errors.count);
      UnitTest.Assert_Equal ("line 1:0 missing 'A' at '<EOF>'", errors.Element (0));

      type Visitor is new VisitorBasicBaseVisitor<UString> with null record;

         overriding
         function visitErrorNode (node : ErrorNode) return Optional_String is
         begin
               return "Error encountered: " & Value (node.getSymbol ())
         end visitErrorNode;

         overriding
         function defaultResult return Optional_String is
         begin
               return "";
         end defaultResult;

         overriding
         function aggregateResult (aggregate : Optional_UString; nextResult : Optional_UString) return Optional_String is
         begin
               return Value (aggregate) + Value (nextResult);
         end aggregateResult;

      visitor : constant := This.Visitor;
      result : constant := visitor.visit (context);
      expected : constant := "Error encountered: [@-1,-1:-1='<missing 'A'>',<1>,1:0]";
      UnitTest.Assert_Equal (expected, result);
   end testVisitErrorNode;

   --
   -- This test verifies that {@link AbstractParseTreeVisitor#visitChildren} does not call
   -- {@link ParseTreeVisitor#visit} after {@link AbstractParseTreeVisitor#shouldVisitNextChild} returns
   -- {@code False}.
   --
   procedure testShouldNotVisitEOF is
      input   : constant UString := "A";
      lexer   : ANTLR.Runtime.Lexers.Lexer;
      parser  : ANTLR.Runtime.Parsers.Parser;
      context : ANTLR.Runtime.RuleContexts.ParserRuleContexts.Optional_ParserRuleContext;
   begin
      lexer  := VisitorBasicLexer (ANTLR.Runtime.ANTLRInputStreams.Initialize (input));
      parser := VisitorBasicParser (ANTLR.Runtime.CommonTokenStreams.Initialize (lexer));

      context := parser.s ();
      UnitTest.Assert_Equal ("(s A <EOF>)", context.toStringTree (parser));

      type Visitor is new VisitorBasicBaseVisitor<UString> with null record;

         overriding
         function visitTerminal (node : TerminalNode) return Optional_String is
         begin
               return Value (node.getSymbol ()) & "\n";
         end visitTerminal;

         overriding
         function shouldVisitNextChild (node : RuleNode; currentResult : Optional_UString) return Boolean is
         begin
               return not Is_Valid (currentResult) or else currentResult!.isEmpty;
         end shouldVisitNextChild;

      visitor : constant := This.Visitor;
      result : constant := visitor.visit (context);
      expected : constant := "[@0,0:0='A',<1>,1:0]\n";
      UnitTest.Assert_Equal (expected, result);
   end testShouldNotVisitEOF;

   --
   -- This test verifies that {@link AbstractParseTreeVisitor#shouldVisitNextChild} is called before visiting the first
   -- child. It also verifies that {@link AbstractParseTreeVisitor#defaultResult} provides the default return value for
   -- visiting a tree.
   --
   procedure testShouldNotVisitTerminal is
      input : constant UString := "A";
      lexer   : ANTLR.Runtime.Lexers.Lexer;
      parser  : ANTLR.Runtime.Parsers.Parser;
      context : ANTLR.Runtime.RuleContexts.ParserRuleContexts.Optional_ParserRuleContext;
   begin
      lexer  := VisitorBasicLexer (ANTLR.Runtime.ANTLRInputStreams.Initialize (input));
      parser := VisitorBasicParser (ANTLR.Runtime.CommonTokenStreams.Initialize (lexer));

      context := parser.s ();
      UnitTest.Assert_Equal ("(s A <EOF>)", context.toStringTree (parser));

      type Visitor is new VisitorBasicBaseVisitor<UString> with null record;

         overriding
         function visitTerminal (node : TerminalNode) return Optional_String is
         begin
               UnitTest.Fail ();
               return (Valid => False);
         end visitTerminal;

         overriding
         function defaultResult return Optional_String is
         begin
               return "default result";
         end defaultResult;

         overriding
         function shouldVisitNextChild (node : RuleNode; currentResult : Optional_UString) return Boolean is
         begin
               return False;
         end shouldVisitNextChild;

      visitor : constant := This.Visitor;
      result : constant := visitor.visit (context);
      expected : constant := "default result";
      UnitTest.Assert_Equal (expected, result);
   end testShouldNotVisitTerminal;

   --
   -- This test verifies that the visitor correctly dispatches calls for labeled outer alternatives.
   --
   procedure testCalculatorVisitor is
      input : constant UString := "2 + 8 / 2";
      lexer   : ANTLR.Runtime.Lexers.Lexer;
      parser  : ANTLR.Runtime.Parsers.Parser;
      context : ANTLR.Runtime.RuleContexts.ParserRuleContexts.Optional_ParserRuleContext;
   begin
      lexer  := VisitorCalcLexer (ANTLR.Runtime.ANTLRInputStream.Initialize (input));
      parser := VisitorCalcParser (ANTLR.Runtime.CommonTokenStream.Initialize (lexer));

      context : constant := parser.s ();
      UnitTest.Assert_Equal ("(s (expr (expr 2) + (expr (expr 8) / (expr 2))) <EOF>)", context.toStringTree (parser));

      type Visitor is new VisitorCalcBaseVisitor<Int> with null record;

         overriding
         function visitS (ctx : VisitorCalcParser.SContext) return Optional_Integer is
         begin
               return visit (ctx.expr ()!);
         end visitS;

         overriding
         function visitNumber (ctx : VisitorCalcParser.NumberContext) return Optional_Integer is
         begin
               return Integer ((ctx.INT ()?.getText ())!);
         end visitNumber;

         overriding
         function visitMultiply (ctx : VisitorCalcParser.MultiplyContext) return Optional_Integer is
         begin
               left : constant := Value (visit (ctx.expr (0))); -- !
               right : constant := Value (visit (ctx.expr (1))); -- !
               if Is_Valid (ctx.MUL ()) then
                  return left * right;
               else
                  return left / right;
               end if;
         end visitMultiply;

         overriding
         function visitAdd (ctx : VisitorCalcParser.AddContext) return Optional_Integer is
         begin
               left : constant := Value (visit (ctx.expr (0))); -- !
               right : constant := Value (visit (ctx.expr (1))); -- !
               if Is_Valid (ctx.ADD ()) then
                  return left + right;
               else
                  return left - right;
               end if;
         end visitAdd;

      visitor : constant := This.Visitor;
      result : constant := visitor.visit (context);
      expected : constant := 6;
      UnitTest.Assert_Equal (expected, result!);
   end testCalculatorVisitor;

end VisitorTests;
