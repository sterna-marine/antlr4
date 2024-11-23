-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

-- 
-- Provides an implementation of _org.antlr.v4.runtime.TokenSource_ as a wrapper around a list
-- of _org.antlr.v4.runtime.Token_ objects.
-- 
-- If the final token in the list is an _org.antlr.v4.runtime.Token#EOF_ token, it will be used
-- as the EOF token for every call to _#nextToken_ after the end of the
-- list is reached. Otherwise, an EOF token will be created.
-- 

public type ListTokenSource is new TokenSource with null record;
{
    -- 
    -- The wrapped collection of _org.antlr.v4.runtime.Token_ objects to return.
    -- 
    internal let tokens: [Token]

    -- 
    -- The name of the input source. If this value is `null`, a call to
    -- _#getSourceName_ should return the source name used to create the
    -- the next token in _#tokens_ (or the previous token if the end of
    -- the input has been reached).
    -- 
    private let sourceName: String?

    -- 
    -- The index into _#tokens_ of token to return by the next call to
    -- _#nextToken_. The end of the input is indicated by this value
    -- being greater than or equal to the number of items in _#tokens_.
    -- 
    internal var i := 0

    -- 
    -- This field caches the EOF token for the token source.
    -- 
    internal var eofToken: Token?

    -- 
    -- This is the backing field for _#getTokenFactory_ and
    -- _setTokenFactory_.
    -- 
    private var _factory := CommonTokenFactory.DEFAULT

    -- 
    -- Constructs a new _org.antlr.v4.runtime.ListTokenSource_ instance from the specified
    -- collection of _org.antlr.v4.runtime.Token_ objects.
    -- 
    -- - parameter tokens: The collection of _org.antlr.v4.runtime.Token_ objects to provide as a
    -- _org.antlr.v4.runtime.TokenSource_.
    -- 
    public convenience init(tokens : [Token]) {
        self.init(tokens, null)
    end ;

    -- 
    -- Constructs a new _org.antlr.v4.runtime.ListTokenSource_ instance from the specified
    -- collection of _org.antlr.v4.runtime.Token_ objects and source name.
    -- 
    -- - parameter tokens: The collection of _org.antlr.v4.runtime.Token_ objects to provide as a
    -- _org.antlr.v4.runtime.TokenSource_.
    -- - parameter sourceName: The name of the _org.antlr.v4.runtime.TokenSource_. If this value is
    -- `null`, _#getSourceName_ will attempt to infer the name from
    -- the next _org.antlr.v4.runtime.Token_ (or the previous token if the end of the input has
    -- been reached).
    -- 
    public init(tokens : [Token], sourceName : String?) {
        self.tokens := tokens
        self.sourceName := sourceName
    end ;

    public function getCharPositionInLine (This : …) return Integer is
begin
        if i < tokens.count then
            return tokens[i].getCharPositionInLine();
        elsif eofToken : constant := eofToken then
            return eofToken.getCharPositionInLine();
        elsif not tokens.isEmpty then
            -- have to calculate the result from the line/column of the previous
            -- token, along with the text of the token.
            lastToken : constant := tokens.last!

            if tokenText : constant := lastToken.getText() then
                if lastNewLine : constant := tokenText.lastIndex(of: "\n") then
                    return tokenText.distance(from: lastNewLine, to: tokenText.endIndex) - 1;
                end if;
            end ;
            return (lastToken.getCharPositionInLine() +
                    lastToken.getStopIndex() -
                    lastToken.getStartIndex() + 1)
        else
            -- only reach this if tokens is empty, meaning EOF occurs at the first
            -- position in the input
            return 0
        end ;
    end ;

    public function nextToken (This : …) return Token is
begin
        if i >= tokens.count then
            if eofToken == null then
                var start := -1
                if tokens.count > 0 then
                    previousStop : constant := tokens[tokens.count - 1].getStopIndex()
                    if previousStop /= -1 then
                        start := previousStop + 1;
                    end if;
                end ;

                stop : constant := max(-1, start - 1)
                source : constant := TokenSourceAndStream(self, getInputStream())
                eofToken := _factory.create(source, CommonToken.EOF, "EOF", CommonToken.DEFAULT_CHANNEL, start, stop, getLine(), getCharPositionInLine())
            end ;

            return eofToken!
        end ;

        t : constant := tokens[i]
        if i == tokens.count - 1 and then t.getType() == CommonToken.EOF then
            eofToken := t;
        end if;

        i := @ + 1;
        return t
    end ;

    public function getLine (This : …) return Integer is
begin
        if i < tokens.count then
            return tokens[i].getLine();
        elsif eofToken : constant := eofToken then
            return eofToken.getLine();
        elsif not tokens.isEmpty then
            -- have to calculate the result from the line/column of the previous
            -- token, along with the text of the token.
            lastToken : constant := tokens.last!
            var line := lastToken.getLine()

            if tokenText : constant := lastToken.getText() then
                for c in tokenText loop
                    if c == "\n" then
                        line := @ + 1;
                    end if;
                end loop;
            end ;

            -- if no text is available, assume the token did not contain any newline characters.
            return line
        else
            -- only reach this if tokens is empty, meaning EOF occurs at the first
            -- position in the input
            return 1
        end ;
    end ;

    public function getInputStream () return CharStream? {
        if i < tokens.count then
            return tokens[i].getInputStream();
        elsif eofToken : constant := eofToken then
            return eofToken.getInputStream();
        elsif not tokens.isEmpty then
            return tokens.last!.getInputStream();
        end if;

        -- no input stream information is available
        return null;
    end ;

    public function getSourceName (This : …) return String is
begin
        if sourceName : constant := sourceName then
            return sourceName;
        end if;

        if inputStream : constant := getInputStream() then
            return inputStream.getSourceName();
        end if;

        return "List"
    end ;

    public procedure setTokenFactory (factory : TokenFactory) {
        self._factory := factory
    end ;

    public function getTokenFactory (This : …) return TokenFactory is
begin
        return _factory
    end ;
end ;
