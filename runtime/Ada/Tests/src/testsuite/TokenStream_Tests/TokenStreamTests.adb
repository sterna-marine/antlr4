-- €

with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.Lexers;
with ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams;
with AdaForge.DevTools.TestTools.UnitTest;

use AdaForge.DevTools.TestTools.UnitTest;

package body TokenStreamTests is

   overriding
   procedure Initialize (T : in out Test) is
   begin
      Set_Name (T, "TokenStream Tests");

      UnitTest.Add_Test_Routine (T, testBufferedTokenStreamClearFetchEOFWithNewSource'Access, "Test fetchEOF reset after setTokenSource");
   end Initialize;

    -- Test fetchEOF reset after setTokenSource
    procedure testBufferedTokenStreamClearFetchEOFWithNewSource is
    begin
        inputStream1 : constant ANTLRInputStream := ANTLR.Runtime.InputStreams.ANTLRInputStream ("A");
        tokenStream : constant Token := CommonTokenStream (VisitorBasicLexer (inputStream1));

        tokenStream.fill ();
        UnitTest.Assert_Equal (2, tokenStream.size ());
        UnitTest.Assert_Equal (VisitorBasicLexer.A, tokenStream.get (0).getType ());
        UnitTest.Assert_Equal (Lexer.EOF, tokenStream.get (1).getType ());

        inputStream2 : constant := ANTLR.Runtime.InputStreams.ANTLRInputStream ("AA");
        tokenStream.setTokenSource (VisitorBasicLexer (inputStream2));
        tokenStream.fill ();
        UnitTest.Assert_Equal (3, tokenStream.size ());
        UnitTest.Assert_Equal (VisitorBasicLexer.A, tokenStream.get (0).getType ());
        UnitTest.Assert_Equal (VisitorBasicLexer.A, tokenStream.get (1).getType ());
        UnitTest.Assert_Equal (Lexer.EOF, tokenStream.get (2).getType ());
    end testBufferedTokenStreamClearFetchEOFWithNewSource;

end TokenStreamTests;
