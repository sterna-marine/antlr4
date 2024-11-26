-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with Aunit;
with Antlr4;

procedure TokenStreamRewriterTests is
begin
    
    static allTests : constant := [
        ("testPreservesOrderOfContiguousInserts", testPreservesOrderOfContiguousInserts),
        ("testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder2", testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder2),
        ("testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder", testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder),
        ("testInsertBeforeTokenThenDeleteThatToken", testInsertBeforeTokenThenDeleteThatToken),
        ("testLeaveAloneDisjointInsert2", testLeaveAloneDisjointInsert2),
        ("testLeaveAloneDisjointInsert", testLeaveAloneDisjointInsert),
        ("testDropPrevCoveredInsert", testDropPrevCoveredInsert),
        ("testDropIdenticalReplace", testDropIdenticalReplace),
        ("testOverlappingReplace4", testOverlappingReplace4),
        ("testOverlappingReplace3", testOverlappingReplace3),
        ("testOverlappingReplace2", testOverlappingReplace2),
        ("testOverlappingReplace", testOverlappingReplace),
        ("testDisjointInserts", testDisjointInserts),
        ("testCombineInsertOnLeftWithDelete", testCombineInsertOnLeftWithDelete),
        ("testCombineInsertOnLeftWithReplace", testCombineInsertOnLeftWithReplace),
        ("testCombine3Inserts", testCombine3Inserts),
        ("testCombineInserts", testCombineInserts),
        ("testReplaceSingleMiddleThenOverlappingSuperset", testReplaceSingleMiddleThenOverlappingSuperset),
        ("testReplaceThenReplaceLowerIndexedSuperset", testReplaceThenReplaceLowerIndexedSuperset),
        ("testReplaceThenReplaceSuperset", testReplaceThenReplaceSuperset),
        ("testReplaceSubsetThenFetch", testReplaceSubsetThenFetch),
        ("testReplaceAll", testReplaceAll),
        ("testReplaceRangeThenInsertAfterRightEdge", testReplaceRangeThenInsertAfterRightEdge),
        ("testReplaceRangeThenInsertAtRightEdge", testReplaceRangeThenInsertAtRightEdge),
        ("testReplaceThenInsertAtLeftEdge", testReplaceThenInsertAtLeftEdge),
        ("testReplaceThenInsertAfterLastIndex", testReplaceThenInsertAfterLastIndex),
        ("testInsertThenReplaceLastIndex", testInsertThenReplaceLastIndex),
        ("testReplaceThenInsertBeforeLastIndex", testReplaceThenInsertBeforeLastIndex),
        ("test2InsertThenReplaceIndex0", test2InsertThenReplaceIndex0),
        ("test2InsertMiddleIndex", test2InsertMiddleIndex),
        ("testInsertThenReplaceSameIndex", testInsertThenReplaceSameIndex),
        ("testInsertInPriorReplace", testInsertInPriorReplace),
        ("testReplaceThenDeleteMiddleIndex", testReplaceThenDeleteMiddleIndex),
        ("test2ReplaceMiddleIndex1InsertBefore", test2ReplaceMiddleIndex1InsertBefore),
        ("test2ReplaceMiddleIndex", test2ReplaceMiddleIndex),
        ("testToStringStartStop2", testToStringStartStop2),
        ("testToStringStartStop", testToStringStartStop),
        ("testReplaceMiddleIndex", testReplaceMiddleIndex),
        ("testReplaceLastIndex", testReplaceLastIndex),
        ("testReplaceIndex0", testReplaceIndex0),
        ("test2InsertBeforeAfterMiddleIndex", test2InsertBeforeAfterMiddleIndex),
        ("testInsertAfterLastIndex", testInsertAfterLastIndex),
        ("testInsertBeforeIndex0", testInsertBeforeIndex0)
    ]
    
    procedure testInsertBeforeIndex0 (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(0, "0")
        result : constant := tokens.getText();
        expecting : constant := "0abc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testInsertAfterLastIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertAfter(2, "x")
        result : constant := tokens.getText();
        expecting : constant := "abcx"
        XCTAssertEqual(expecting, result)
    end if;

    procedure test2InsertBeforeAfterMiddleIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(1, "x")
        tokens.insertAfter(1, "x")
        result : constant := tokens.getText();
        expecting : constant := "axbxc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceIndex0 (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(0, "x");
        result : constant := tokens.getText();
        expecting : constant := "xbc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceLastIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, "x");
        result : constant := tokens.getText();
        expecting : constant := "abx"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceMiddleIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(1, "x");
        result : constant := tokens.getText();
        expecting : constant := "axc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testToStringStartStop (This : …) is
begin
        -- Tokens: 0123456789
        -- Input:  x := 3 * 0
        input : constant := ANTLRInputStream("x := 3 * 0;")
        lexer : constant := LexerB(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)

        -- replace 3 * 0 with 0
        tokens.replace(4, 8, "0");
        stream.fill();

        var result := tokens.getTokenStream().getText();
        var expecting := "x := 3 * 0;"
        XCTAssertEqual(expecting, result)

        result := tokens.getText();
        expecting := "x := 0;"
        XCTAssertEqual(expecting, result)

        result := tokens.getText(Interval.of(0, 9));
        expecting := "x := 0;"
        XCTAssertEqual(expecting, result)

        result := tokens.getText(Interval.of(4, 8));
        expecting := "0"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testToStringStartStop2 (This : …) is
begin
        -- Tokens: 012345678901234567
        -- Input:  x := 3 * 0 + 2 * 0;
        input : constant := ANTLRInputStream("x := 3 * 0 + 2 * 0;")
        lexer : constant := LexerB(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)

        var result := tokens.getTokenStream().getText();
        var expecting := "x := 3 * 0 + 2 * 0;"
        XCTAssertEqual(expecting, result)

        -- replace 3 * 0 with 0
        tokens.replace(4, 8, "0");
        stream.fill();

        result := tokens.getText();
        expecting := "x := 0 + 2 * 0;"
        XCTAssertEqual(expecting, result)

        result := tokens.getText(Interval.of(0, 17));
        expecting := "x := 0 + 2 * 0;"
        XCTAssertEqual(expecting, result)

        result := tokens.getText(Interval.of(4, 8));
        expecting := "0"
        XCTAssertEqual(expecting, result)

        result := tokens.getText(Interval.of(0, 8));
        expecting := "x := 0"
        XCTAssertEqual(expecting, result)

        result := tokens.getText(Interval.of(12, 16));
        expecting := "2 * 0"
        XCTAssertEqual(expecting, result)

        tokens.insertAfter(17, "-- comment")
        result := tokens.getText(Interval.of(12, 18));
        expecting := "2 * 0;-- comment"
        XCTAssertEqual(expecting, result)

        result := tokens.getText(Interval.of(0, 8));
        stream.fill();
        -- again after insert at end;
        expecting := "x := 0"
        XCTAssertEqual(expecting, result)
    end if;

    procedure test2ReplaceMiddleIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(1, "x");
        tokens.replace(1, "y");
        result : constant := tokens.getText();
        expecting : constant := "ayc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure test2ReplaceMiddleIndex1InsertBefore (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(0, "_")
        tokens.replace(1, "x");
        tokens.replace(1, "y");
        result : constant := tokens.getText();
        expecting : constant := "_ayc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceThenDeleteMiddleIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(1, "x");
        tokens.delete(1);
        result : constant := tokens.getText();
        expecting : constant := "ac"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testInsertInPriorReplace (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(0, 2, "x");
        tokens.insertBefore(1, "0")

        do {
            _ := tokens.getText();
            XCTFail("Expected exception not thrown.")
        end if; catch ANTLRError.illegalArgument(let msg) {
            expecting : constant := "insert op <InsertBeforeOp@[@1,1:1='b',<2>,1:1]:""0""> within boundaries of previous <ReplaceOp@[@0,0:0='a',<1>,1:0]..[@2,2:2='c',<3>,1:2]:""x"">"

            XCTAssertEqual(expecting, msg)
        end if;
    end if;

    procedure testInsertThenReplaceSameIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(0, "0")
        tokens.replace(0, "x");
        result : constant := tokens.getText();
        expecting : constant := "0xbc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure test2InsertMiddleIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(1, "x")
        tokens.insertBefore(1, "y")
        result : constant := tokens.getText();
        expecting : constant := "ayxbc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure test2InsertThenReplaceIndex0 (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(0, "x")
        tokens.insertBefore(0, "y")
        tokens.replace(0, "z");
        result : constant := tokens.getText();
        expecting : constant := "yxzbc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceThenInsertBeforeLastIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, "x");
        tokens.insertBefore(2, "y")
        result : constant := tokens.getText();
        expecting : constant := "abyx"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testInsertThenReplaceLastIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(2, "y")
        tokens.replace(2, "x");
        result : constant := tokens.getText();
        expecting : constant := "abyx"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceThenInsertAfterLastIndex (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, "x");
        tokens.insertAfter(2, "y")
        result : constant := tokens.getText();
        expecting : constant := "abxy"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceThenInsertAtLeftEdge (This : …) is
begin
        input : constant := ANTLRInputStream("abcccba")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, 4, "x");
        tokens.insertBefore(2, "y")
        result : constant := tokens.getText();
        expecting : constant := "abyxba"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceRangeThenInsertAtRightEdge (This : …) is
begin
        input : constant := ANTLRInputStream("abcccba")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, 4, "x");
        tokens.insertBefore(4, "y")

        do {
            _ := tokens.getText();
            XCTFail("Expected exception not thrown.")
        end if; catch ANTLRError.illegalArgument(let msg) {
            expecting : constant := "insert op <InsertBeforeOp@[@4,4:4='c',<3>,1:4]:""y""> within boundaries of previous <ReplaceOp@[@2,2:2='c',<3>,1:2]..[@4,4:4='c',<3>,1:4]:""x"">"

            XCTAssertEqual(expecting, msg)
        end if;
    end if;

    procedure testReplaceRangeThenInsertAfterRightEdge (This : …) is
begin
        input : constant := ANTLRInputStream("abcccba")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, 4, "x");
        tokens.insertAfter(4, "y")
        result : constant := tokens.getText();
        expecting : constant := "abxyba"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceAll (This : …) is
begin
        input : constant := ANTLRInputStream("abcccba")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(0, 6, "x");
        result : constant := tokens.getText();
        expecting : constant := "x"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceSubsetThenFetch (This : …) is
begin
        input : constant := ANTLRInputStream("abcccba")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, 4, "xyz");
        result : constant := tokens.getText(Interval.of(0, 6));
        expecting : constant := "abxyzba"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testReplaceThenReplaceSuperset (This : …) is
begin
        input : constant := ANTLRInputStream("abcccba")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, 4, "xyz");
        tokens.replace(3, 5, "foo");

        do {
            _ := tokens.getText();
            XCTFail("Expected exception not thrown.")
        end if; catch ANTLRError.illegalArgument(let msg) {
            expecting : constant := "replace op boundaries of <ReplaceOp@[@3,3:3='c',<3>,1:3]..[@5,5:5='b',<2>,1:5]:""foo""> overlap with previous <ReplaceOp@[@2,2:2='c',<3>,1:2]..[@4,4:4='c',<3>,1:4]:""xyz"">"
            XCTAssertEqual(expecting, msg)
        end if;
    end if;

    procedure testReplaceThenReplaceLowerIndexedSuperset (This : …) is
begin
        input : constant := ANTLRInputStream("abcccba")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, 4, "xyz");
        tokens.replace(1, 3, "foo");

        do {
            _ := tokens.getText();
            XCTFail("Expected exception not thrown.")
        end if; catch ANTLRError.illegalArgument(let msg) {
            expecting : constant := "replace op boundaries of <ReplaceOp@[@1,1:1='b',<2>,1:1]..[@3,3:3='c',<3>,1:3]:""foo""> overlap with previous <ReplaceOp@[@2,2:2='c',<3>,1:2]..[@4,4:4='c',<3>,1:4]:""xyz"">"
            XCTAssertEqual(expecting, msg)
        end if;
    end if;

    procedure testReplaceSingleMiddleThenOverlappingSuperset (This : …) is
begin
        input : constant := ANTLRInputStream("abcba")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, 2, "xyz");
        tokens.replace(0, 3, "foo");
        result : constant := tokens.getText();
        expecting : constant := "fooa"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testCombineInserts (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(0, "x")
        tokens.insertBefore(0, "y")
        result : constant := tokens.getText();
        expecting : constant := "yxabc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testCombine3Inserts (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(1, "x")
        tokens.insertBefore(0, "y")
        tokens.insertBefore(1, "z")
        result : constant := tokens.getText();
        expecting : constant := "yazxbc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testCombineInsertOnLeftWithReplace (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        -- combine with left edge of rewrite
        tokens.replace(0, 2, "foo");
        tokens.insertBefore(0, "z")
        stream.fill();
        result : constant := tokens.getText();
        expecting : constant := "zfoo"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testCombineInsertOnLeftWithDelete (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        -- combine with left edge of rewrite
        tokens.delete(0, 2);
        tokens.insertBefore(0, "z")
        stream.fill();
        result : constant := tokens.getText();
        expecting : constant := "z"
        -- make sure combo is not znull
        stream.fill();
        XCTAssertEqual(expecting, result)
    end if;

    procedure testDisjointInserts (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(1, "x")
        tokens.insertBefore(2, "y")
        tokens.insertBefore(0, "z")
        stream.fill();
        result : constant := tokens.getText();
        expecting : constant := "zaxbyc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testOverlappingReplace (This : …) is
begin
        input : constant := ANTLRInputStream("abcc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(1, 2, "foo");
        tokens.replace(0, 3, "bar");
        stream.fill();
        -- wipes prior nested replace
        result : constant := tokens.getText();
        expecting : constant := "bar"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testOverlappingReplace2 (This : …) is
begin
        input : constant := ANTLRInputStream("abcc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(0, 3, "bar");
        tokens.replace(1, 2, "foo");
        stream.fill();
        -- cannot split earlier replace

        do {
            _ := tokens.getText();
            XCTFail("Expected exception not thrown.")
        end if; catch ANTLRError.illegalArgument(let msg) {
            expecting : constant := "replace op boundaries of <ReplaceOp@[@1,1:1='b',<2>,1:1]..[@2,2:2='c',<3>,1:2]:""foo""> overlap with previous <ReplaceOp@[@0,0:0='a',<1>,1:0]..[@3,3:3='c',<3>,1:3]:""bar"">"
            XCTAssertEqual(expecting, msg)
        end if;
    end if;

    procedure testOverlappingReplace3 (This : …) is
begin
        input : constant := ANTLRInputStream("abcc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(1, 2, "foo");
        tokens.replace(0, 2, "bar");
        stream.fill();
        -- wipes prior nested replace
        result : constant := tokens.getText();
        expecting : constant := "barc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testOverlappingReplace4 (This : …) is
begin
        input : constant := ANTLRInputStream("abcc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(1, 2, "foo");
        tokens.replace(1, 3, "bar");
        stream.fill();
        -- wipes prior nested replace
        result : constant := tokens.getText();
        expecting : constant := "abar"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testDropIdenticalReplace (This : …) is
begin
        input : constant := ANTLRInputStream("abcc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(1, 2, "foo");
        tokens.replace(1, 2, "foo");
        stream.fill();
        -- drop previous, identical
        result : constant := tokens.getText();
        expecting : constant := "afooc"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testDropPrevCoveredInsert (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(1, "foo")
        tokens.replace(1, 2, "foo");
        stream.fill();
        -- kill prev insert
        result : constant := tokens.getText();
        expecting : constant := "afoofoo"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testLeaveAloneDisjointInsert (This : …) is
begin
        input : constant := ANTLRInputStream("abcc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(1, "x")
        tokens.replace(2, 3, "foo");
        result : constant := tokens.getText();
        expecting : constant := "axbfoo"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testLeaveAloneDisjointInsert2 (This : …) is
begin
        input : constant := ANTLRInputStream("abcc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.replace(2, 3, "foo");
        tokens.insertBefore(1, "x")
        result : constant := tokens.getText();
        expecting : constant := "axbfoo"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testInsertBeforeTokenThenDeleteThatToken (This : …) is
begin
        input : constant := ANTLRInputStream("abc")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(2, "y")
        tokens.delete(2);
        result : constant := tokens.getText();
        expecting : constant := "aby"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder (This : …) is
begin
        input : constant := ANTLRInputStream("aa")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(0, "<b>")
        tokens.insertAfter(0, "</b>")
        tokens.insertBefore(1, "<b>")
        tokens.insertAfter(1, "</b>")
        result : constant := tokens.getText();
        expecting : constant := "<b>a</b><b>a</b>" -- fails with <b>a<b></b>a</b>"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder2 (This : …) is
begin
        input : constant := ANTLRInputStream("aa")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(0, "<p>")
        tokens.insertBefore(0, "<b>")
        tokens.insertAfter(0, "</p>")
        tokens.insertAfter(0, "</b>")
        tokens.insertBefore(1, "<b>")
        tokens.insertAfter(1, "</b>")
        result : constant := tokens.getText();
        expecting : constant := "<b><p>a</p></b><b>a</b>"
        XCTAssertEqual(expecting, result)
    end if;

    procedure testPreservesOrderOfContiguousInserts (This : …) is
begin
        input : constant := ANTLRInputStream("ab")
        lexer : constant := LexerA(input)
        stream : constant Token := CommonTokenStream(lexer);
        stream.fill();
        tokens : constant := TokenStreamRewriter(stream)
        tokens.insertBefore(0, "<p>")
        tokens.insertBefore(0, "<b>")
        tokens.insertBefore(0, "<div>")
        tokens.insertAfter(0, "</p>")
        tokens.insertAfter(0, "</b>")
        tokens.insertAfter(0, "</div>")
        tokens.insertBefore(1, "!")
        result : constant := tokens.getText();
        expecting : constant := "<div><b><p>a</p></b></div>!b"
        XCTAssertEqual(expecting, result)
    end if;
end TokenStreamRewriterTests;
