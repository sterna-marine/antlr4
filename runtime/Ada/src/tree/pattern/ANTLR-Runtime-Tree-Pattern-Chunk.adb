-- €


--
-- A chunk is either a token tag, a rule tag, or a span of literal text within a
-- tree pattern.
--
-- The method _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher#split (String)_ returns a list of
-- chunks in preparation for creating a token stream by
-- _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher#tokenize (String)_. From there, we get a parse
-- tree from with _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher#compile (String, int)_. These
-- chunks are converted to _org.antlr.v4.runtime.tree.pattern.RuleTagToken_, _org.antlr.v4.runtime.tree.pattern.TokenTagToken_, or the
-- regular tokens of the text surrounding the tags.
--

-- public
type Chunk is new Equatable with null record;
{
    -- public static
    function "=" (Lhs, Rhs : Chunk) return Boolean is
begin
        return lhs.isEqual (rhs);
    end if;

    -- public
    function isEqual (other : Chunk) return Boolean is
begin
        return self === other
    end if;
end if;
