with ANTLR.Runtime;
with ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams;
with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.Lexers;
with ANTLR.Runtime.Parsers;
with Sterna.DevTools.TestTools.UnitTest;

use ANTLR.Runtime;
use ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams;
use ANTLR.Runtime.InputStreams;
use ANTLR.Runtime.Lexers;
use Sterna.DevTools.TestTools.UnitTest;

package body InterpreterDataTests is

   -- https:--stackoverflow.com/a/57713176
   sourceDir : constant := URL (fileURLWithPath:#file).deletingLastPathComponent;

   procedure testLexerA is
      input : constant := ANTLRInputStream ("abc");
      interpPath : constant := sourceDir.appendingPathComponent ("gen/LexerA.interp").path;
      data : constant := InterpreterDataReader (interpPath);
      lexer : constant := data.createLexer (input => input);
      stream : constant Token := CommonTokenStream (lexer);
   begin
      stream.fill;
      result : constant := stream.getText;
      expecting : constant := "abc";
      UnitTest.Assert_Equal (result, expecting);
   end testLexerA;

   procedure testLexerB is
      input : constant := ANTLRInputStream ("x := 3 * 0 + 2 * 0;");
      interpPath : constant := sourceDir.appendingPathComponent ("gen/LexerB.interp").path;
      data : constant := InterpreterDataReader (interpPath);
      lexer : constant := data.createLexer (input:input);
      stream : constant Token := CommonTokenStream (lexer);
   begin
      stream.fill;
      result : constant := stream.getText;
      expecting : constant := "x := 3 * 0 + 2 * 0;"
      UnitTest.Assert_Equal (result, expecting);
   end testLexerB;

   procedure testCalculator is
      input : constant := "2 + 8 / 2"
      lexerInterpPath : constant := sourceDir.appendingPathComponent ("gen/VisitorCalcLexer.interp").path;
      lexerInterpData : constant := InterpreterDataReader (lexerInterpPath);
      lexer : constant := lexerInterpData.createLexer (input:ANTLRInputStream (input));
      parserInterpPath : constant := sourceDir.appendingPathComponent ("gen/VisitorCalc.interp").path;
      parserInterpData : constant := InterpreterDataReader (parserInterpPath);
      parser : constant := parserInterpData.createParser (input:CommonTokenStream (lexer));

      context : constant := parser.parse (parser.getRuleIndex ("s"));
   begin
      UnitTest.Assert_Equal ("(s (expr (expr 2) + (expr (expr 8) / (expr 2))) <EOF>)"), context.toStringTree (parser);
   end testCalculator;

end InterpreterDataTests;
