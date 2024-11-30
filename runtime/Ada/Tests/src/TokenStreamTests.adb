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
        XCTAssertEqual (2, tokenStream.size ());
        XCTAssertEqual (VisitorBasicLexer.A, tokenStream.get (0).getType ());
        XCTAssertEqual (Lexer.EOF, tokenStream.get (1).getType ());

        inputStream2 : constant := ANTLRInputStream ("AA");
        tokenStream.setTokenSource (VisitorBasicLexer (inputStream2));
        tokenStream.fill ();
        XCTAssertEqual (3, tokenStream.size ());
        XCTAssertEqual (VisitorBasicLexer.A, tokenStream.get (0).getType ());
        XCTAssertEqual (VisitorBasicLexer.A, tokenStream.get (1).getType ());
        XCTAssertEqual (Lexer.EOF, tokenStream.get (2).getType ());
    end if;

end TokenStreamTests;
