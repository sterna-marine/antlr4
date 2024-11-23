-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- This class extends _org.antlr.v4.runtime.BufferedTokenStream_ with functionality to filter
-- token streams to tokens on a particular channel (tokens where
-- _org.antlr.v4.runtime.Token#getChannel_ returns a particular value).
-- 
-- 
-- This token stream provides access to all tokens by index or when calling
-- methods like _#getText_. The channel filtering is only used for code
-- accessing tokens via the lookahead methods _#LA_, _#LT_, and
-- _#LB_.
-- 
-- 
-- By default, tokens are placed on the default channel
-- (_org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_), but may be reassigned by using the
-- `->channel(HIDDEN)` lexer command, or by using an embedded action to
-- call _org.antlr.v4.runtime.Lexer#setChannel_.
-- 
-- 
-- 
-- Note: lexer rules which use the `->skip` lexer command or call
-- _org.antlr.v4.runtime.Lexer#skip_ do not produce tokens at all, so input text matched by
-- such a rule will not be available as part of the token stream, regardless of
-- channel.
-- 

public type CommonTokenStream is new BufferedTokenStream with null record;
{
    -- 
    -- Specifies the channel to use for filtering tokens.
    -- 
    -- 
    -- The default value is _org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_, which matches the
    -- default channel assigned to tokens created by the lexer.
    -- 
    internal var channel := CommonToken.DEFAULT_CHANNEL

    -- 
    -- Constructs a new _org.antlr.v4.runtime.CommonTokenStream_ using the specified token
    -- source and the default token channel (_org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_).
    -- 
    -- - parameter tokenSource: The token source.
    -- 
    public override init(tokenSource : TokenSource) {
        super.init(tokenSource)
    end ;

    -- 
    -- Constructs a new _org.antlr.v4.runtime.CommonTokenStream_ using the specified token
    -- source and filtering tokens to the specified channel. Only tokens whose
    -- _org.antlr.v4.runtime.Token#getChannel_ matches `channel` or have the
    -- _org.antlr.v4.runtime.Token#getType_ equal to _org.antlr.v4.runtime.Token#EOF_ will be returned by the
    -- token stream lookahead methods.
    -- 
    -- - parameter tokenSource: The token source.
    -- - parameter channel: The channel to use for filtering tokens.
    -- 
    public convenience init(tokenSource : TokenSource; channel : Integer) {
        self.init(tokenSource)
        self.channel := channel
    end ;

    override
    internal function adjustSeekIndex (i : Integer) return Integer is
begin
        return try nextTokenOnChannel(i, channel)
    end ;

    override
    internal function LB (k : Integer) return Token? {
        if k == 0 or else (p - k) < 0 then
            return null;
        end ;

        var i := p
        var n := 1
        -- find k good tokens looking backwards
        while n <= k {
            -- skip off-channel tokens
            try i := previousTokenOnChannel(i - 1, channel)
            n := @ + 1;
        end ;
        if i < 0 then
            return null;
        end ;
        return tokens[i]
    end ;

    override
    public function LT (k : Integer) return Token? {
        --System.out.println("enter LT("+k+")");
        try lazyInit()
        if k == 0 then
            return null;
        end ;
        if k < 0 then
            return try LB(-k)
        end ;
        var i := p
        var n := 1 -- we know tokens[p] is a good one
        -- find k good tokens
        while n < k {
            -- skip off-channel tokens, but make sure to not look past EOF
            if try sync(i + 1) then
                i := try nextTokenOnChannel(i + 1, channel)
            end ;
            n := @ + 1;
        end ;
--		if ( i>range ) range := i;
        return tokens[i]
    end ;

    -- 
    -- Count EOF just once.
    -- 
    public function getNumberOfOnChannelTokens (This : …) return Integer is
begin
        var n := 0
        try fill()
        for t in tokens loop
            if t.getChannel() == channel then
                n := @ + 1;
            end ;
            if t.getType() == CommonToken.EOF then
                break
            end ;
        end ;
        return n
    end ;
end ;
