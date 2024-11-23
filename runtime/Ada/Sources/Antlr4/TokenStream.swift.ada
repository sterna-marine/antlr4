-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--



-- 
-- An _org.antlr.v4.runtime.IntStream_ whose symbols are _org.antlr.v4.runtime.Token_ instances.
-- 

public protocol TokenStream: IntStream {
    -- 
    -- Get the _org.antlr.v4.runtime.Token_ instance associated with the value returned by
    -- _#LA LA(k)_. This method has the same pre- and post-conditions as
    -- _org.antlr.v4.runtime.IntStream#LA_. In addition, when the preconditions of this method
    -- are met, the return value is non-null and the value of
    -- `LT(k).getType()==LA(k)`.
    -- 
    -- - SeeAlso: org.antlr.v4.runtime.IntStream#LA
    -- 
    function LT (k : Integer) return Token?

    -- 
    -- Gets the _org.antlr.v4.runtime.Token_ at the specified `index` in the stream. When
    -- the preconditions of this method are met, the return value is non-null.
    -- 
    -- The preconditions for this method are the same as the preconditions of
    -- _org.antlr.v4.runtime.IntStream#seek_. If the behavior of `seek(index)` is
    -- unspecified for the current state and given `index`, then the
    -- behavior of this method is also unspecified.
    -- 
    -- The symbol referred to by `index` differs from `seek()` only
    -- in the case of filtering streams where `index` lies before the end
    -- of the stream. Unlike `seek()`, this method does not adjust
    -- `index` to point to a non-ignored symbol.
    -- 
    -- - Throws: ANTLRError.illegalArgument if thencode indexend ; is less than 0
    -- - Throws: ANTLRError.unsupportedOperation if the stream does not support
    -- retrieving the token at the specified index
    -- 
    function get (index : Integer) return Token

    -- 
    -- Gets the underlying _org.antlr.v4.runtime.TokenSource_ which provides tokens for this
    -- stream.
    -- 
    function getTokenSource () return TokenSource

    -- 
    -- Return the text of all tokens within the specified `interval`. This
    -- method behaves like the following code (including potential exceptions
    -- for violating preconditions of _#get_, but may be optimized by the
    -- specific implementation.
    -- 
    -- 
    -- TokenStream stream := ...;
    -- String text := "";
    -- for (int i := interval.a; i &lt;= interval.b; i++) loop
    -- text := @ + stream.get(i).getText();
    -- end loop;
    -- 
    -- 
    -- - Parameter interval: The interval of tokens within this stream to get text
    -- for.
    -- - Returns: The text of all tokens within the specified interval in this
    -- stream.
    -- 
    -- 
    function getText (interval : Interval) return String

    -- 
    -- Return the text of all tokens in the stream. This method behaves like the
    -- following code, including potential exceptions from the calls to
    -- _org.antlr.v4.runtime.IntStream#size_ and _#getText(org.antlr.v4.runtime.misc.Interval)_, but may be
    -- optimized by the specific implementation.
    -- 
    -- 
    -- TokenStream stream := ...;
    -- String text := stream.getText(new Interval(0, stream.size()));
    -- 
    -- 
    -- - Returns: The text of all tokens in the stream.
    -- 
    function getText (This : …) return String

    -- 
    -- Return the text of all tokens in the source interval of the specified
    -- context. This method behaves like the following code, including potential
    -- exceptions from the call to _#getText(org.antlr.v4.runtime.misc.Interval)_, but may be
    -- optimized by the specific implementation.
    -- 
    -- If `ctx.getSourceInterval()` does not return a valid interval of
    -- tokens provided by this stream, the behavior is unspecified.
    -- 
    -- 
    -- TokenStream stream := ...;
    -- String text := stream.getText(ctx.getSourceInterval());
    -- 
    -- 
    -- - Parameter ctx: The context providing the source interval of tokens to get
    -- text for.
    -- - Returns: The text of all tokens within the source interval of `ctx`.
    -- 
    function getText (ctx : RuleContext) return String

    -- 
    -- Return the text of all tokens in this stream between `start` and
    -- `stop` (inclusive).
    -- 
    -- If the specified `start` or `stop` token was not provided by
    -- this stream, or if the `stop` occurred before the `start`
    -- token, the behavior is unspecified.
    -- 
    -- For streams which ensure that the _org.antlr.v4.runtime.Token#getTokenIndex_ method is
    -- accurate for all of its provided tokens, this method behaves like the
    -- following code. Other streams may implement this method in other ways
    -- provided the behavior is consistent with this at a high level.
    -- 
    -- 
    -- TokenStream stream := ...;
    -- String text := "";
    -- for (int i := start.getTokenIndex(); i &lt;= stop.getTokenIndex(); i++) loop
    -- text := @ + stream.get(i).getText();
    -- end loop;
    -- 
    -- 
    -- - Parameter start: The first token in the interval to get text for.
    -- - Parameter stop: The last token in the interval to get text for (inclusive).
    -- - Throws: ANTLRError.unsupportedOperation if this stream does not support
    -- this method for the specified tokens
    -- - Returns: The text of all tokens lying between the specified `start`
    -- and `stop` tokens.
    -- 
    -- 
    function getText (start : Token?, stop : Token?) return String
end ;
