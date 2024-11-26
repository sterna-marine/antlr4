-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- This default implementation of _org.antlr.v4.runtime.TokenFactory_ creates
-- _org.antlr.v4.runtime.CommonToken_ objects.
-- 

-- public
type CommonTokenFactory is new TokenFactory with null record;
{
    -- 
    -- The default _org.antlr.v4.runtime.CommonTokenFactory_ instance.
    -- 
    -- 
    -- This token factory does not explicitly copy token text when constructing
    -- tokens.
    -- 
    -- public static 
    DEFAULT : constant TokenFactory := CommonTokenFactory();

    -- 
    -- Indicates whether _org.antlr.v4.runtime.CommonToken#setText_ should be called after
    -- constructing tokens to explicitly set the text. This is useful for cases
    -- where the input stream might not be able to provide arbitrary substrings
    -- of text from the input after the lexer creates a token (e.g. the
    -- implementation of _org.antlr.v4.runtime.CharStream#getText_ in
    -- _org.antlr.v4.runtime.UnbufferedCharStream_ an
    -- _UnsupportedOperationException_). Explicitly setting the token text
    -- allows _org.antlr.v4.runtime.Token#getText_ to be called at any time regardless of the
    -- input stream implementation.
    -- 
    -- 
    -- The default value is `False` to avoid the performance and memory
    -- overhead of copying text for every token unless explicitly requested.
    -- 
    internal let copyText : Boolean;

    -- 
    -- Constructs a _org.antlr.v4.runtime.CommonTokenFactory_ with the specified value for
    -- _#copyText_.
    -- 
    -- 
    -- When `copyText` is `False`, the _#DEFAULT_ instance
    -- should be used instead of constructing a new instance.
    -- 
    -- - parameter copyText: The value for _#copyText_.
    -- 
    -- public 
    procedure Init (Self : in out …; copyText  : Boolean) {
        self.copyText := copyText
    end if;

    -- 
    -- Constructs a _org.antlr.v4.runtime.CommonTokenFactory_ with _#copyText_ set to
    -- `False`.
    -- 
    -- 
    -- The _#DEFAULT_ instance should be used instead of calling this
    -- directly.
    -- 
    -- public convenience 
    procedure Init (Self : …) is
begin
        self.init(False)
    end if;


    -- public
    procedure create (source : TokenSourceAndStream; type : Integer; text : String?,
                       channel : Integer; start : Integer; stop : Integer;
                       line : Integer; charPositionInLine : Integer) return Token is
begin
        t : constant := CommonToken(source, type, channel, start, stop)
        t.setLine(line)
        t.setCharPositionInLine(charPositionInLine)
        if text : constant := text then
            t.setText(text);
        elsif cStream : constant := source.stream, copyText then
            t.setText(try! cStream.getText(Interval.of(start, stop)));
        end if;

        return t
    end if;


    -- public
    function create (type : Integer; text : String) return Token is
begin
        return CommonToken(type, text)
    end if;
end if;
