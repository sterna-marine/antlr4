-- €

with Ada.Wide_Wide_Text_IO;

use Ada;

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
-- `->channel (HIDDEN)` lexer command, or by using an embedded action to
-- call _org.antlr.v4.runtime.Lexer#setChannel_.
--
--
--
-- Note: lexer rules which use the `->skip` lexer command or call
-- _org.antlr.v4.runtime.Lexer#skip_ do not produce tokens at all, so input text matched by
-- such a rule will not be available as part of the token stream, regardless of
-- channel.
--

-- public
type CommonTokenStream is new BufferedTokenStream with null record;
{
    --
    -- Specifies the channel to use for filtering tokens.
    --
    --
    -- The default value is _org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_, which matches the
    -- default channel assigned to tokens created by the lexer.
    --
    -- internal
    channel := DEFAULT_CHANNEL

    --
    -- Constructs a new _org.antlr.v4.runtime.CommonTokenStream_ using the specified token
    -- source and the default token channel (_org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_).
    --
    -- * parameter tokenSource: The token source.
    --
    -- public
    overriding
    procedure Initialize (Self : in out …; tokenSource : TokenSource) {
        super.Initialize (Self, tokenSource);
    end if;

    --
    -- Constructs a new _org.antlr.v4.runtime.CommonTokenStream_ using the specified token
    -- source and filtering tokens to the specified channel. Only tokens whose
    -- _org.antlr.v4.runtime.Token#getChannel_ matches `channel` or have the
    -- _org.antlr.v4.runtime.Token#getType_ equal to _org.antlr.v4.runtime.Token#EOF_ will be returned by the
    -- token stream lookahead methods.
    --
    -- * parameter tokenSource: The token source.
    -- * parameter channel: The channel to use for filtering tokens.
    --
    -- public convenience
    procedure Initialize (Self : in out …; tokenSource : TokenSource; Channel : Channel_Number) {
        Self.Initialize (tokenSource);
        self.channel := channel
    end if;

    overriding
    -- internal
    function adjustSeekIndex (i : Integer) return Integer is
begin
        return nextTokenOnChannel (i, channel);
    end if;

    overriding
    -- internal
    function LB (k : Integer) return Optional_Token is
   begin
        if k = 0 or else (p - k) < 0 then
            return (Valid => False);
        end if;

        i := p
        n := 1
        -- find k good tokens looking backwards
        while n <= k loop
            -- skip off-channel tokens
            i := previousTokenOnChannel (i - 1, channel);
            n := @ + 1;
        end loop;
        if i < 0 then
            return (Valid => False);
        end if;
        return tokens.Element (i);
    end if;

    overriding
    -- public
    function LT (k : Integer) return Optional_Token is
   begin
        -- Ada.Wide_Wide_Text_IO.Put_Line ("enter LT (" & k'Image & ')');
        This.lazyInit;
        if k = 0 then
            return (Valid => False);
        end if;
        if k < 0 then
            return LB (-k);
        end if;
        i := p
        n := 1 -- we know tokens.Element (p) is a good one
        -- find k good tokens
        while n < k loop
            -- skip off-channel tokens, but make sure to not look past EOF
            if sync (i + 1) then
                i := nextTokenOnChannel (i + 1, channel);
            end if;
            n := @ + 1;
        end loop;
--      if ( i>range ) range := i;
        return tokens.Element (i);
    end if;

    --
    -- Count EOF just once.
    --
    -- public
    function getNumberOfOnChannelTokens (This : …) return Integer is
begin
        n := 0
        This.fill;
        for t of tokens loop
            if t.getChannel = channel then
                n := @ + 1;
            end if;
            exit when t.getType = EOF;
        end loop;
        return n;
    end if;
end if;
