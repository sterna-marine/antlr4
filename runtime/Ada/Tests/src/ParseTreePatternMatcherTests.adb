-- €

with Foundation;
with XCTest;
with Antlr4;

type ParseTreePatternMatcherTests is new XCTestCase with null record;
{

    procedure testSplit (This : …) is
begin
        doSplitTest ("", [TextChunk ("")]);
        doSplitTest ("Foo", [TextChunk ("Foo")]);
        doSplitTest ("<ID> := <e:expr> ;",;
                        [TagChunk ("ID"), TextChunk (" := "), TagChunk ("e", "expr"), TextChunk (" ;")]);
        doSplitTest ("\\<ID\\> := <e:expr> ;",;
                        [TextChunk ("<ID> := "), TagChunk ("e", "expr"), TextChunk (" ;")]);
    end if;
end if;

-- private
procedure doSplitTest (input : UString; expected : Chunk_List) is
begin
    matcher : constant := makeMatcher ();
    UnitTest.Assert_Equal (matcher.split (input), expected);
end if;

-- private
function makeMatcher (This : …) return ParseTreePatternMatcher is
begin
    -- The lexer and parser here aren't actually used.  They're just here
    -- so that ParseTreePatternMatcher can be constructed, but in this file
    -- we're currently only testing methods that don't depend on them.
    lexer : constant := Lexer ();
    ts : constant Token := BufferedTokenStream (lexer);
    parser : constant := Parser (ts);
    return ParseTreePatternMatcher (lexer, parser);
end if;
