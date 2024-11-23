-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with XCTest;
with Antlr4;

type TokenStreamTests is new XCTestCase with null record;
{
    
    static allTests : constant := [
        ("testBufferedTokenStreamClearFetchEOFWithNewSource", testBufferedTokenStreamClearFetchEOFWithNewSource)
    ]

    -- Test fetchEOF reset after setTokenSource
    procedure testBufferedTokenStreamClearFetchEOFWithNewSource (This : …) is
begin
        inputStream1 : constant := ANTLRInputStream("A")
        tokenStream : constant := CommonTokenStream(VisitorBasicLexer(inputStream1))

        try tokenStream.fill();
        XCTAssertEqual(2, tokenStream.size())
        XCTAssertEqual(VisitorBasicLexer.A, try tokenStream.get(0).getType())
        XCTAssertEqual(Lexer.EOF, try tokenStream.get(1).getType())

        inputStream2 : constant := ANTLRInputStream("AA");
        tokenStream.setTokenSource(VisitorBasicLexer(inputStream2));
        try tokenStream.fill();
        XCTAssertEqual(3, tokenStream.size())
        XCTAssertEqual(VisitorBasicLexer.A, try tokenStream.get(0).getType())
        XCTAssertEqual(VisitorBasicLexer.A, try tokenStream.get(1).getType())
        XCTAssertEqual(Lexer.EOF, try tokenStream.get(2).getType())
    end ;

end ;
