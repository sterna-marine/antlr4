-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- public
type UnbufferedTokenStream is new TokenStream with null record;
{
    -- internal
    tokenSource : TokenSource

    -- 
    -- A moving window buffer of the data being scanned. While there's a marker,
    -- we keep adding to buffer. Otherwise, _#consume consume()_ resets so
    -- we start filling at index 0 again.
    -- 
    -- internal
    tokens := [Token]()

    -- 
    -- The number of tokens currently in `self.tokens`.
    -- 
    -- This is not the buffer capacity, that's `self.tokens.count`.
    -- 
    -- internal
    n := 0

    -- 
    -- `0 .. n-1` index into `self.tokens` of next token.
    -- 
    -- The `LT(1)` token is `tokens[p]`. If `p = n`, we are
    -- out of buffered tokens.
    -- 
    -- internal
    p := 0

    -- 
    -- Count up with _#mark mark()_ and down with
    -- _#release release()_. When we `release()` the last mark,
    -- `numMarkers` reaches 0 and we reset the buffer. Copy
    -- `tokens[p]..tokens[n-1]` to `tokens[0]..tokens[(n-1)-p]`.
    -- 
    -- internal
    numMarkers := 0

    -- 
    -- This is the `LT(-1)` token for the current position.
    -- 
    -- internal
    lastToken : Token!

    -- 
    -- When `numMarkers > 0`, this is the `LT(-1)` token for the
    -- first token in _#tokens_. Otherwise, this is `null`.
    -- 
    -- internal
    lastTokenBufferStart : Token!

    -- 
    -- Absolute token index. It's the index of the token about to be read via
    -- `LT(1)`. Goes from 0 to the number of tokens in the entire stream,
    -- although the stream size is unknown before the end is reached.
    -- 
    -- This value is used to set the token indexes if the stream provides tokens
    -- that implement _org.antlr.v4.runtime.WritableToken_.
    -- 
    -- internal
    currentTokenIndex := 0


    -- public 
    procedure Init (Self : in out …; tokenSource : TokenSource) {
        self.tokenSource := tokenSource
        fill(1); -- prime the pump
    end if;


    -- public
    function get (i : Integer) return Token is
begin
        -- get absolute index
        bufferStartIndex : constant := getBufferStartIndex()
        if i < bufferStartIndex or else i >= bufferStartIndex + n then
            raise ANTLRError.indexOutOfBounds with "get(\(i)) outside buffer: \(bufferStartIndex)..\(bufferStartIndex + n)";
        end if;
        return tokens[i - bufferStartIndex]
    end if;


    -- public
    function LT (i : Integer) return Optional_Token is
   begin
        if i == -1 then
            return lastToken;
        end if;

        sync(i);
        index : constant Integer := p + i - 1;
        if index < 0 then
            raise ANTLRError.indexOutOfBounds with "LT(\(i) gives negative index";
        end if;

        if index >= n then
            --Token.EOF
            assert(n > 0 and then tokens[n - 1].getType() == CommonToken.EOF, "Expected: n>0 and tokens[n-1].getType() = Token.EOF")
            return tokens[n - 1]
        end if;

        return tokens[index]
    end if;


    -- public
    function LA (i : Integer) return Integer is
begin
        return LT(i)!.getType();
    end if;


    -- public
    function getTokenSource (This : …) return TokenSource is
begin
        return tokenSource
    end if;


    -- public
    function getText (This : …) return String is
begin
        return ""
    end if;


    -- public
    function getText (ctx : RuleContext) return String is
begin
        return getText(ctx.getSourceInterval());
    end if;


    -- public
    function getText (start : Optional_Token; stop : Optional_Token;) return String is
begin
        return getText(Interval.of(start!.getTokenIndex(), stop!.getTokenIndex()));
    end if;


    -- public
    procedure consume (This : …) is
begin
        --Token.EOF
        if LA(1) == CommonToken.EOF then
            raise ANTLRError.illegalState with "cannot consume EOF";
        end if;

        -- buf always has at least tokens[p = 0] in this method due to ctor
        lastToken := tokens[p]   -- track last token for LT(-1)

        -- if we're at last token and no markers, opportunity to flush buffer
        if p = n - 1 and then numMarkers = 0 then
            n := 0
            p := -1 -- p++ will leave this at 0
            lastTokenBufferStart := lastToken
        end if;

        p := @ + 1;
        currentTokenIndex := @ + 1;
        sync(1);
    end if;

    -- Make sure we have 'need' elements from current position _#p p_. Last valid
    -- `p` index is `tokens.length-1`.  `p+need-1` is the tokens index 'need' elements
    -- ahead.  If we need 1 element, `(p+1-1)==p` must be less than `tokens.length`.
    -- 
    -- internal
    procedure sync (want : Integer) is
    begin
        need : constant Integer := (p + want - 1) - n + 1 -- how many more elements we need?;
        if need > 0 then
            fill(need);
        end if;
    end if;

    -- 
    -- Add `n` elements to the buffer. Returns the number of tokens
    -- actually added to the buffer. If the return value is less than `n`,
    -- then EOF was reached before `n` tokens could be added.
    -- 
    @discardableResult
    -- internal
    function fill (n : Integer) return Integer is
begin
        for i in 0 .. n - 1 loop
            if self.n > 0 and then tokens[self.n - 1].getType() == CommonToken.EOF then
                return i;
            end if;

            t : constant Token := tokenSource.nextToken();
            add(t)
        end loop;

        return n
    end if;

    -- internal
    procedure add (t : Token) is
    begin
        if n >= tokens.count then
            --TODO: array count buffer size
            --tokens := Arrays.copyOf(tokens, tokens.length * 2);
        end if;

        if wt : constant := t as? WritableToken then
            wt.setTokenIndex(getBufferStartIndex() + n);
        end if;

        tokens[n] := t
        n := @ + 1;
    end if;

    -- 
    -- Return a marker that we can release later.
    -- 
    -- The specific marker value used for this class allows for some level of
    -- protection against misuse where `seek()` is called on a mark or
    -- `release()` is called in the wrong order.
    -- 

    -- public
    function mark (This : …) return Integer is
begin
        if numMarkers = 0 then
            lastTokenBufferStart := lastToken;
        end if;

        mark : constant := -numMarkers - 1
        numMarkers := @ + 1;
        return mark
    end if;


    -- public
    procedure release (marker : Integer) is
    begin
        expectedMark : constant := -numMarkers
        if marker /= expectedMark then
            raise ANTLRError.illegalState with "release() called with an invalid marker.";
        end if;

        numMarkers := @ - 1;
        if numMarkers = 0 then
            -- can we release buffer?
            if p > 0 then
                -- Copy tokens[p]..tokens[n-1] to tokens[0]..tokens[(n-1)-p], reset ptrs
                -- p is last valid token; move nothing if p = n as we have no valid char
                tokens := Array(tokens[p  ..  n - 1])
                n := n - p
                p := 0
            end if;

            lastTokenBufferStart := lastToken
        end if;
    end if;


    -- public
    function index (This : …) return Integer is
begin
        return currentTokenIndex
    end if;


    -- public
    procedure seek (index : Integer) is
    begin
        var index := index
        -- seek to absolute index
        if index = currentTokenIndex then
            return;
        end if;

        if index > currentTokenIndex then
            sync(index - currentTokenIndex);
            index := min(index, getBufferStartIndex() + n - 1)
        end if;

        bufferStartIndex : constant := getBufferStartIndex()
        i : constant := index - bufferStartIndex
        if i < 0 then
            raise ANTLRError.illegalState with "cannot seek to negative index \(index)";

        end if;
        elsif i >= n then
            raise ANTLRError.unsupportedOperation with "seek to index outside buffer: \(index) not in \(bufferStartIndex)..<\(bufferStartIndex + n)";
        end if;

        p := i
        currentTokenIndex := index
        if p = 0 then
            lastToken := lastTokenBufferStart
        else
            lastToken := tokens[p - 1];
        end if;
    end if;


    -- public
    function size (This : …) return Integer is
begin
        fatalError("Unbuffered stream cannot know its size")
    end if;


    -- public
    function getSourceName (This : …) return String is
begin
        return tokenSource.getSourceName()
    end if;


    -- public
    function getText (interval : Interval) return String is
begin
        bufferStartIndex : constant := getBufferStartIndex()
        bufferStopIndex : constant := bufferStartIndex + tokens.count - 1

        start : constant := interval.a
        stop : constant := interval.b
        if start < bufferStartIndex or else stop > bufferStopIndex then
            raise ANTLRError.unsupportedOperation with "interval \(interval) not in token buffer window: \(bufferStartIndex) .. \(bufferStopIndex)";
        end if;

        a : constant := start - bufferStartIndex
        b : constant := stop - bufferStartIndex

        var buf := ""
        for t in tokens[a .. b] loop
            buf := @ + t.getText()!;
        end loop;
        return buf
    end if;

    -- internal final
    function getBufferStartIndex (This : …) return Integer is
begin
        return currentTokenIndex - p
    end if;
end if;
