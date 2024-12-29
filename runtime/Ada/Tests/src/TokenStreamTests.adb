-- €

with Aunit;
with Antlr4;

procedure TokenStreamTests is
begin

    static allTests : constant := [
        ("testBufferedTokenStreamClearFetchEOFWithNewSource", testBufferedTokenStreamClearFetchEOFWithNewSource);
    ]

    -- Test fetchEOF reset after setTokenSource
    procedure testBufferedTokenStreamClearFetchEOFWithNewSource (This : …) is
begin
        inputStream1 : constant := ANTLRInputStream ("A");
        tokenStream : constant Token := CommonTokenStream (VisitorBasicLexer (inputStream1));

        tokenStream.fill ();
        UnitTest.Assert_Equal (2, tokenStream.size ());
        UnitTest.Assert_Equal (VisitorBasicLexer.A, tokenStream.get (0).getType ());
        UnitTest.Assert_Equal (Lexer.EOF, tokenStream.get (1).getType ());

        inputStream2 : constant := ANTLRInputStream ("AA");
        tokenStream.setTokenSource (VisitorBasicLexer (inputStream2));
        tokenStream.fill ();
        UnitTest.Assert_Equal (3, tokenStream.size ());
        UnitTest.Assert_Equal (VisitorBasicLexer.A, tokenStream.get (0).getType ());
        UnitTest.Assert_Equal (VisitorBasicLexer.A, tokenStream.get (1).getType ());
        UnitTest.Assert_Equal (Lexer.EOF, tokenStream.get (2).getType ());
    end if;

end TokenStreamTests;
