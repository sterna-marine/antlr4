-- €

--
-- Provides an implementation of _org.antlr.v4.runtime.TokenSource_ as a wrapper around a list
-- of _org.antlr.v4.runtime.Token_ objects.
--
-- If the final token in the list is an _org.antlr.v4.runtime.Token#EOF_ token, it will be used
-- as the EOF token for every call to _#nextToken_ after the end of the
-- list is reached. Otherwise, an EOF token will be created.
--

-- public
type ListTokenSource is new TokenSource with null record;
{
    --
    -- The wrapped collection of _org.antlr.v4.runtime.Token_ objects to return.
    --
    -- internal
    tokens : constant [Token];

    --
    -- The name of the input source. If this value is `null`, a call to
    -- _#getSourceName_ should return the source name used to create the
    -- the next token in _#tokens_ (or the previous token if the end of
    -- the input has been reached).
    --
    -- private
    sourceName : constant Optional_UString;

    --
    -- The index into _#tokens_ of token to return by the next call to
    -- _#nextToken_. The end of the input is indicated by this value
    -- being greater than or equal to the number of items in _#tokens_.
    --
    -- internal
    i := 0

    --
    -- This field caches the EOF token for the token source.
    --
    -- internal
    eofToken : Optional_Token;

    --
    -- This is the backing field for _#getTokenFactory_ and
    -- _setTokenFactory_.
    --
    -- private
    _factory := CommonTokenFactory.DEFAULT

    --
    -- Constructs a new _org.antlr.v4.runtime.ListTokenSource_ instance from the specified
    -- collection of _org.antlr.v4.runtime.Token_ objects.
    --
    -- * parameter tokens: The collection of _org.antlr.v4.runtime.Token_ objects to provide as a
    -- _org.antlr.v4.runtime.TokenSource_.
    --
    -- public convenience
    procedure Initialize (Self : in out …; tokens : Token.Container.Vector) {
        self.init (tokens, null);
    end if;

    --
    -- Constructs a new _org.antlr.v4.runtime.ListTokenSource_ instance from the specified
    -- collection of _org.antlr.v4.runtime.Token_ objects and source name.
    --
    -- * parameter tokens: The collection of _org.antlr.v4.runtime.Token_ objects to provide as a
    -- _org.antlr.v4.runtime.TokenSource_.
    -- * parameter sourceName: The name of the _org.antlr.v4.runtime.TokenSource_. If this value is
    -- `null`, _#getSourceName_ will attempt to infer the name from
    -- the next _org.antlr.v4.runtime.Token_ (or the previous token if the end of the input has
    -- been reached).
    --
    -- public
    procedure Initialize (Self : in out …; tokens : Token.Container.Vector, sourceName : Optional_String;) {
        self.tokens := tokens
        self.sourceName := sourceName
    end if;

    -- public
    function getCharPositionInLine (This : …) return Integer is
begin
        if i < tokens.count then
            return tokens.Element (i).getCharPositionInLine ();
        elsif eofToken : constant Token := eofToken then;
            return eofToken.getCharPositionInLine ();
        elsif not tokens.isEmpty then
            -- have to calculate the result from the line/column of the previous
            -- token, along with the text of the token.
            lastToken : constant := tokens.last!

            tokenText : constant Optional_Token := Maybe (lastToken.getText ());
             if Is_Valid (tokenText) then
                if lastNewLine : constant := tokenText.lastIndex (of: "\n") then
                    return tokenText.distance (from => lastNewLine, to => tokenText.endIndex) - 1;
                end if;
            end if;
            return (lastToken.getCharPositionInLine () +
                    lastToken.getStopIndex () -
                    lastToken.getStartIndex () + 1);
        else
            -- only reach this if tokens is empty, meaning EOF occurs at the first
            -- position in the input
            return 0
        end if;
    end if;

    -- public
    function nextToken (This : …) return Token is
begin
        if i >= tokens.count then
            if not Is_Valid (eofToken) then
                start := -1
                if tokens.count > 0 then
                    previousStop : constant := tokens[tokens.count - 1].getStopIndex ();
                    if previousStop /= -1 then
                        start := previousStop + 1;
                    end if;
                end if;

                stop : constant := max (-1, start - 1);
                source : constant := TokenSourceAndStream (self, getInputStream ());
                eofToken := _factory.create (source, CommonToken.EOF, "EOF", CommonToken.DEFAULT_CHANNEL, start, stop, getLine (), getCharPositionInLine ());
            end if;

            return eofToken!
        end if;

        t : constant := tokens.Element (i);
        if i = tokens.count - 1 and then t.getType () == CommonToken.EOF then
            eofToken := t;
        end if;

        i := @ + 1;
        return t
    end if;

    -- public
    function getLine (This : …) return Integer is
begin
        if i < tokens.count then
            return tokens.Element (i).getLine ();
        elsif eofToken : constant Token := eofToken then;
            return eofToken.getLine ();
        elsif not tokens.isEmpty then
            -- have to calculate the result from the line/column of the previous
            -- token, along with the text of the token.
            lastToken : constant := tokens.last!
            line := lastToken.getLine ();

            tokenText : constant Optional_Token := Maybe (lastToken.getText ());
             if Is_Valid (tokenText) then
                for c in tokenText loop
                    if c == "\n" then
                        line := @ + 1;
                    end if;
                end loop;
            end if;

            -- if no text is available, assume the token did not contain any newline characters.
            return line
        else
            -- only reach this if tokens is empty, meaning EOF occurs at the first
            -- position in the input
            return 1
        end if;
    end if;

    -- public
    function getInputStream (This : …) return Optional_CharStream is
   begin
        if i < tokens.count then
            return tokens.Element (i).getInputStream ();
        elsif eofToken : constant Token := eofToken then;
            return eofToken.getInputStream ();
        elsif not tokens.isEmpty then
            return tokens.last!.getInputStream ();
        end if;

        -- no input stream information is available
        return (Valid => False);
    end if;

    -- public
    function getSourceName (This : …) return UString is
begin
        if sourceName : constant := sourceName then
            return sourceName;
        end if;

        if inputStream : constant := getInputStream () then
            return inputStream.getSourceName ();
        end if;

        return "List"
    end if;

    -- public
    procedure setTokenFactory (factory : TokenFactory) is
    begin
        self._factory := factory
    end if;

    -- public
    function getTokenFactory (This : …) return TokenFactory is
begin
        return _factory
    end if;
end if;
