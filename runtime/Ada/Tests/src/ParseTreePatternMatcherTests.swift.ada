-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with Foundation;
with XCTest;
with Antlr4;

type ParseTreePatternMatcherTests is new XCTestCase with null record;
{

    procedure testSplit (This : …) is
begin
        doSplitTest("", [TextChunk("")]);
        doSplitTest("Foo", [TextChunk("Foo")]);
        doSplitTest("<ID> := <e:expr> ;",;
                        [TagChunk("ID"), TextChunk(" := "), TagChunk("e", "expr"), TextChunk(" ;")])
        doSplitTest("\\<ID\\> := <e:expr> ;",;
                        [TextChunk("<ID> := "), TagChunk("e", "expr"), TextChunk(" ;")])
    end if;
end if;

-- private
procedure doSplitTest (input : String; expected : [Chunk]) is
begin
    matcher : constant := makeMatcher();
    XCTAssertEqual(matcher.split(input), expected);
end if;

-- private
function makeMatcher (This : …) return ParseTreePatternMatcher is
begin
    -- The lexer and parser here aren't actually used.  They're just here
    -- so that ParseTreePatternMatcher can be constructed, but in this file
    -- we're currently only testing methods that don't depend on them.
    lexer : constant := Lexer()
    ts : constant Token := BufferedTokenStream(lexer);
    parser : constant := Parser(ts);
    return ParseTreePatternMatcher(lexer, parser)
end if;
