-- Copyright (c) 2012-2021 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with XCTest;
with Antlr4;

type ThreadingTests is new XCTestCase with null record;
{
    static allTests : constant := [
        ("testParallelExecution", testParallelExecution),
    ]

    --
    -- This test verifies parallel execution of the parser
    --
    procedure testParallelExecution (This : …) is
begin
        input : constant := [
            "2 * 8 - 4",
            "2 + 8 / 4",
            "2 - 8 - 4",
            "2 * 8 * 4",
            "2 / 8 / 4",
            "2 + 8 + 4",
            "890",
        ]
        exp : constant := expectation(description: "Waiting on async-task")
        exp.expectedFulfillmentCount := 100
        for i in 1...100 loop
            DispatchQueue.global().async {
                lexer : constant := ThreadingLexer(ANTLRInputStream(input[i % 7]))
                tokenStream : constant := CommonTokenStream(lexer)
                parser : constant := try? ThreadingParser(tokenStream)

                _ : constant := try? parser?.s()

                exp.fulfill()
            end ;
        end loop;

        waitForExpectations(timeout: 30.0) { (_) in
            print("Completed")
        end ;
    end ;
end ;