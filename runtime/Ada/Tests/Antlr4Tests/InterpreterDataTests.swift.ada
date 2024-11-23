-- Copyright (c) 2021 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with XCTest;
with Antlr4;

type InterpreterDataTests is new XCTestCase with null record;
{

    -- https:--stackoverflow.com/a/57713176
    sourceDir : constant := URL(fileURLWithPath:#file).deletingLastPathComponent()

    procedure testLexerA (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        interpPath : constant := sourceDir.appendingPathComponent("gen/LexerA.interp").path
        data : constant := try InterpreterDataReader(interpPath)
        lexer : constant := try data.createLexer(input:input)
        stream : constant := CommonTokenStream(lexer)
        try stream.fill()
        result : constant := try stream.getText()
        expecting : constant := "abc"
        XCTAssertEqual(expecting, result)
    end ;

    procedure testLexerB (This : …) is
begin
        input : constant := ANTLRInputStream("x := 3 * 0 + 2 * 0;")
        interpPath : constant := sourceDir.appendingPathComponent("gen/LexerB.interp").path
        data : constant := try InterpreterDataReader(interpPath)
        lexer : constant := try data.createLexer(input:input)
        stream : constant := CommonTokenStream(lexer)
        try stream.fill()
        result : constant := try stream.getText()
        expecting : constant := "x := 3 * 0 + 2 * 0;"
        XCTAssertEqual(expecting, result)
    end ;

    procedure testCalculator (This : …) is
begin
        input : constant := "2 + 8 / 2"
        lexerInterpPath : constant := sourceDir.appendingPathComponent("gen/VisitorCalcLexer.interp").path
        lexerInterpData : constant := try InterpreterDataReader(lexerInterpPath)
        lexer : constant := try lexerInterpData.createLexer(input:ANTLRInputStream(input))
        parserInterpPath : constant := sourceDir.appendingPathComponent("gen/VisitorCalc.interp").path
        parserInterpData : constant := try InterpreterDataReader(parserInterpPath)
        parser : constant := try parserInterpData.createParser(input:CommonTokenStream(lexer))

        context : constant := try parser.parse(parser.getRuleIndex("s"))
        XCTAssertEqual("(s (expr (expr 2) + (expr (expr 8) / (expr 2))) <EOF>)", context.toStringTree(parser))
    end ;

end ;
