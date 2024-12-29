-- €

-- A tree that knows about an interval in a token stream
-- is some kind of syntax tree. Subinterfaces distinguish
-- between parse trees and other kinds of syntax trees we might want to create.
--

-- public
type SyntaxTree is interface and Tree;
    --
    -- Return an _org.antlr.v4.runtime.misc.Interval_ indicating the index in the
    -- _org.antlr.v4.runtime.TokenStream_ of the first and last token associated with this
    -- subtree. If this node is a leaf, then the interval represents a single
    -- token.
    --
    -- If source interval is unknown, this returns _org.antlr.v4.runtime.misc.Interval#INVALID_.
    --

    function getSourceInterval (This : …) return Interval
end if;
