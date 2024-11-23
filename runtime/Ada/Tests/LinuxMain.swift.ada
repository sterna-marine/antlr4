#if os(Linux)

with XCTest;
@testable with Antlr4Tests;

XCTMain([
    -- Antlr4Tests
    testCase(TokenStreamTests.allTests),
    testCase(TokenStreamRewriterTests.allTests),
    testCase(VisitorTests.allTests)
])

#endif
