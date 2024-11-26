-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- This implementation of _org.antlr.v4.runtime.TokenStream_ loads tokens from a
-- _org.antlr.v4.runtime.TokenSource_ on-demand, and places the tokens in a buffer to provide
-- access to any previous token by index.
-- 
-- 
-- This token stream ignores the value of _org.antlr.v4.runtime.Token#getChannel_. If your
-- parser requires the token stream filter tokens to only those on a particular
-- channel, such as _org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_ or
-- _org.antlr.v4.runtime.Token#HIDDEN_CHANNEL_, use a filtering token stream such a
-- _org.antlr.v4.runtime.CommonTokenStream_.
--

-- public
type BufferedTokenStream is new TokenStream with null record;
{
    -- 
    -- The _org.antlr.v4.runtime.TokenSource_ from which tokens for this stream are fetched.
    -- 
    -- internal
    tokenSource : TokenSource

    -- 
    -- A collection of all tokens fetched from the token source. The list is
    -- considered a complete view of the input once _#fetchedEOF_ is set
    -- to `True`.
    -- 
    -- internal
    tokens := [Token]()

    -- 
    -- The index into _#tokens_ of the current token (next token to
    -- _#consume_). _#tokens_`[`_#p_`]` should be
    -- _#LT LT(1)_.
    -- 
    -- This field is set to -1 when the stream is first constructed or when
    -- _#setTokenSource_ is called, indicating that the first token has
    -- not yet been fetched from the token source. For additional information,
    -- see the documentation of _org.antlr.v4.runtime.IntStream_ for a description of
    -- Initializing Methods.
    -- 
    -- internal
    p := -1

    -- 
    -- Indicates whether the _org.antlr.v4.runtime.Token#EOF_ token has been fetched from
    -- _#tokenSource_ and added to _#tokens_. This field improves
    -- performance for the following cases:
    -- 
    -- * _#consume_: The lookahead check in _#consume_ to prevent
    -- consuming the EOF symbol is optimized by checking the values of
    -- _#fetchedEOF_ and _#p_ instead of calling _#LA_.
    -- 
    -- * _#fetch_: The check to prevent adding multiple EOF symbols into
    -- _#tokens_ is trivial with this field.
    -- 
    -- internal
    fetchedEOF := False;


    -- public 
    procedure Init (Self : in out …; tokenSource : TokenSource) {
        self.tokenSource := tokenSource
    end if;


    -- public
    function getTokenSource (This : …) return TokenSource is
begin
        return tokenSource
    end if;


    -- public
    function index (This : …) return Integer is
begin
        return p
    end if;


    -- public
    function mark (This : …) return Integer is
begin
        return 0
    end if;

    -- public
    procedure release (marker : Integer) is
    begin
        -- no resources to release
    end if;

    -- public
    procedure reset (This : …) is
begin
        seek(0);
    end if;


    -- public
    procedure seek (index : Integer) is
    begin
        lazyInit();
        p := adjustSeekIndex(index);
    end if;


    -- public
    function size (This : …) return Integer is
begin
        return tokens.count
    end if;


    -- public
    procedure consume (This : …) is
begin
        var skipEofCheck : Boolean;
        if p >= 0 then
            if fetchedEOF then
                -- the last token in tokens is EOF. skip check if p indexes any
                -- fetched token except the last.
                skipEofCheck := p < tokens.count - 1
            else
                -- no EOF token in tokens. skip check if p indexes a fetched token.
                skipEofCheck := p < tokens.count;
            end if;
        else
            -- not yet initialized
            skipEofCheck := False;
        end if;

        if not skipEofCheck and then LA(1) == BufferedTokenStream.EOF then;
            raise ANTLRError.illegalState with "cannot consume EOF";
        end if;

        if sync(p + 1) then;
            p := adjustSeekIndex(p + 1);
        end if;
    end if;

    -- 
    -- Make sure index `i` in tokens has a token.
    -- 
    -- - returns: `True` if a token is located at index `i`, otherwise
    -- `False`.
    -- - seealso: #get(int i)
    -- 
    @discardableResult
    -- internal
    function sync (i : Integer) return Boolean is
begin
        assert(i >= 0, "Expected: i>=0")
        n : constant := i - tokens.count + 1 -- how many more elements we need?
        --print("sync("+i+") needs "+n);
        if n > 0 then
            fetched : constant := fetch(n);
            return fetched >= n
        end if;

        return True;
    end if;

    -- 
    -- Add `n` elements to buffer.
    -- 
    -- - returns: The actual number of elements added to the buffer.
    -- 
    -- internal
    function fetch (n : Integer) return Integer is
begin
        if fetchedEOF then
            return 0;
        end if;

        for i in 0 .. n - 1 loop
            t : constant := tokenSource.nextToken();
            if wt : constant := t as? WritableToken then
                wt.setTokenIndex(tokens.count);
            end if;

            tokens.append(t)
            if t.getType() == BufferedTokenStream.EOF then
                fetchedEOF := True;
                return i + 1
            end if;
        end loop;

        return n
    end if;

    -- public
    function get (i : Integer) return Token is
begin
        guard tokens.indices.contains(i) else {
            raise ANTLRError.indexOutOfBounds with "token index \(i) out of range 0 ..< \(tokens.count)";
        end if;
        return tokens[i]
    end if;

    -- 
    -- Get all tokens from start .. stop inclusively
    -- 
    -- public
    function get (start : Integer;stop : Integer) return Array<Token>? {
        var stop := stop
        if start < 0 or else stop < 0 then
            return null;
        end if;
        lazyInit();
        var subset := [Token]()
        if stop >= tokens.count then
            stop := tokens.count - 1;
        end if;
        for i in start .. stop loop
            t : constant := tokens[i]
            exit when t.getType() == BufferedTokenStream.EOF;
            subset.append(t)
        end if;
        return subset
    end if;

    -- public
    function LA (i : Integer) return Integer is
begin
        return LT(i)!.getType();
    end if;

    -- internal
    function LB (k : Integer) return Token? {
        if (p - k) < 0 then
            return null;
        end if;
        return tokens[p - k]
    end if;


    -- public
    function LT (k : Integer) return Token? {
        lazyInit();
        if k = 0 then
            return null;
        end if;
        if k < 0 then
            return LB(-k);
        end if;

        i : constant := p + k - 1
        sync(i);
        if i >= tokens.count then
            -- return EOF token
            -- EOF must be last token
            return tokens.last!
        end if;
        return tokens[i]
    end if;

    -- 
    -- Allowed derived classes to modify the behavior of operations which change
    -- the current stream position by adjusting the target token index of a seek
    -- operation. The default implementation simply returns `i`. If an
    -- exception is thrown in this method, the current stream index should not be
    -- changed.
    -- 
    -- For example, _org.antlr.v4.runtime.CommonTokenStream_ overrides this method to ensure that
    -- the seek target is always an on-channel token.
    -- 
    -- - parameter i: The target token index.
    -- - returns: The adjusted target token index.
    -- 
    -- internal
    function adjustSeekIndex (i : Integer) return Integer is
begin
        return i
    end if;

    internal final procedure lazyInit (Self : …) is
begin
        if p == -1 then
            setup();
        end if;
    end if;

    -- internal
    procedure setup (This : …) is
begin
        sync(0);
        p := adjustSeekIndex(0);
    end if;

    -- 
    -- Reset this token stream by setting its token source.
    -- 
    -- public
    procedure setTokenSource (tokenSource : TokenSource) is
    begin
        self.tokenSource := tokenSource
        tokens.removeAll()
        p := -1
        fetchedEOF := False;
    end if;

    -- public
    function getTokens () return [Token] {
        return tokens
    end if;

    -- public
    function getTokens (start : Integer; stop : Integer) return [Token]? {
        return getTokens(start, stop, null);
    end if;

    -- 
    -- Given a start and stop index, return a List of all tokens in
    -- the token type BitSet.  Return null if no tokens were found.  This
    -- method looks at both on and off channel tokens.
    -- 
    -- public
    function getTokens (start : Integer; stop : Integer; types : Set<Int>?) return [Token]? {
        lazyInit();
        guard tokens.indices.contains(start),
              tokens.indices.contains(stop) else {
            raise ANTLRError.indexOutOfBounds with "start \(start) or stop \(stop) not in 0 ..< \(tokens.count)";

        end if;
        if start > stop then
            return null;
        end if;

        var filteredTokens := [Token]()
        for i in start .. stop loop
            t : constant := tokens[i]
            if types?.contains(t.getType()) ?? True then
                filteredTokens.append(t);
            end if;
        end loop;
        if filteredTokens.isEmpty then
            return null;
        end if;
        return filteredTokens
    end if;

    -- public
    function getTokens (start : Integer; stop : Integer; ttype : Integer) return [Token]? {
        return getTokens(start, stop, [ttype]);
    end if;

    -- 
    -- Given a starting index, return the index of the next token on channel.
    -- Return `i` if `tokens[i]` is on channel. Return the index of
    -- the EOF token if there are no tokens on channel between `i` and
    -- EOF.
    -- 
    -- internal
    function nextTokenOnChannel (i : Integer; channel : Integer) return Integer is
begin
        var i := i
        sync(i);
        if i >= size() then
            return size() - 1;
        end if;

        var token := tokens[i]
        while token.getChannel() /= channel loop
            if token.getType() == BufferedTokenStream.EOF then
                return i;
            end if;

            i := @ + 1;
            sync(i);
            token := tokens[i]
        end loop;

        return i
    end if;

    -- 
    -- Given a starting index, return the index of the previous token on
    -- channel. Return `i` if `tokens[i]` is on channel. Return -1
    -- if there are no tokens on channel between `i` and 0.
    -- 
    -- 
    -- If `i` specifies an index at or after the EOF token, the EOF token
    -- index is returned. This is due to the fact that the EOF token is treated
    -- as though it were on every channel.
    -- 
    -- internal
    function previousTokenOnChannel (i : Integer; channel : Integer) return Integer is
begin
        var i := i
        sync(i);
        if i >= size() then
            -- the EOF token is on every channel
            return size() - 1
        end if;

        while i >= 0 loop
            token : constant := tokens[i]
            if token.getType() == BufferedTokenStream.EOF or else token.getChannel() == channel then
                return i;
            end if;

            i := @ - 1;
        end loop;

        return i
    end if;

    -- 
    -- Collect all tokens on specified channel to the right of
    -- the current token up until we see a token on DEFAULT_TOKEN_CHANNEL or
    -- EOF. If channel is -1, find any non default channel token.
    -- 
    -- public
    function getHiddenTokensToRight (tokenIndex : Integer; channel : Integer := -1) return [Token]? {
        lazyInit();
        guard tokens.indices.contains(tokenIndex) else {
            raise ANTLRError.indexOutOfBounds with "\(tokenIndex) not in 0 ..< \(tokens.count)";
        end if;

        nextOnChannel : constant := nextTokenOnChannel(tokenIndex + 1, Lexer.DEFAULT_TOKEN_CHANNEL);
        from : constant := tokenIndex + 1
        let to : Integer;
        -- if none onchannel to right, nextOnChannel=-1 so set to := last token
        if nextOnChannel == -1 then
            to := size() - 1
        else
            to := nextOnChannel;
        end if;

        return filterForChannel(from, to, channel)
    end if;

    --
    -- Collect all tokens on specified channel to the left of
    -- the current token up until we see a token on DEFAULT_TOKEN_CHANNEL.
    -- If channel is -1, find any non default channel token.
    -- 
    -- public
    function getHiddenTokensToLeft (tokenIndex : Integer; channel : Integer := -1) return [Token]? {
        lazyInit();
        guard tokens.indices.contains(tokenIndex) else {
            raise ANTLRError.indexOutOfBounds with "\(tokenIndex) not in 0 ..< \(tokens.count)";
        end if;

        if tokenIndex = 0 then
            -- obviously no tokens can appear before the first token
            return null;
        end if;

        prevOnChannel : constant := previousTokenOnChannel(tokenIndex - 1, Lexer.DEFAULT_TOKEN_CHANNEL);
        if prevOnChannel = tokenIndex - 1 then
            return null;
        end if;
        -- if none onchannel to left, prevOnChannel=-1 then from=0
        from : constant := prevOnChannel + 1
        to : constant := tokenIndex - 1
        return filterForChannel(from, to, channel)
    end if;

    -- internal
    function filterForChannel (from : Integer; to : Integer; channel : Integer) return [Token]? {
        var hidden := [Token]()
        for t in tokens[from .. to] loop
            if channel == -1 then
                if t.getChannel() /= Lexer.DEFAULT_TOKEN_CHANNEL then
                    hidden.append(t);
                end if;
            else
                if t.getChannel() == channel then
                    hidden.append(t);
                end if;
            end if;
        end loop;
        if hidden.isEmpty then
            return null;
        end if;
        return hidden
    end if;


    -- public
    function getSourceName (This : …) return String is
begin
        return tokenSource.getSourceName()
    end if;

    -- 
    -- Get the text of all tokens in this buffer.
    -- 
    -- public
    function getText (This : …) return String is
begin
        return getText(Interval.of(0, size() - 1));
    end if;

    -- public
    function getText (interval : Interval) return String is
begin
        start : constant := interval.a
        if start < 0 then
            return "";
        end if;
        fill();
        stop : constant := min(tokens.count, interval.b + 1)
        var buf := ""
        for t in tokens[start ..< stop] loop
            exit when t.getType() = BufferedTokenStream.EOF;
            buf := @ + t.getText()!;
        end loop;
        return buf
    end if;


    -- public
    function getText (ctx : RuleContext) return String is
begin
        return getText(ctx.getSourceInterval());
    end if;


    -- public
    function getText (start : Token?, stop : Token?) return String is
begin
        if start : constant := start, stop : constant := stop then
            return getText(Interval.of(start.getTokenIndex(), stop.getTokenIndex()));
        end if;

        return ""
    end if;

    -- 
    -- Get all tokens from lexer until EOF
    -- 
    -- public
    procedure fill (This : …) is
begin
        lazyInit();
        blockSize : constant := 1000
        loop
            fetched : constant := fetch(blockSize);
            if fetched < blockSize then
                return;
            end if;
        end loop;
    end if;
end if;
