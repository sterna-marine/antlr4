-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- Implements the `channel` lexer action by calling
-- _org.antlr.v4.runtime.Lexer#setChannel_ with the assigned channel.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

-- public final
type LexerChannelAction is new LexerAction and CustomStringConvertible with null record;
{
    fileprivate let channel : Integer;

    -- 
    -- Constructs a new `channel` action with the specified channel value.
    -- - parameter channel: The channel value to pass to _org.antlr.v4.runtime.Lexer#setChannel_.
    -- 
    -- public 
    procedure Init (Self : in out …; channel : Integer) {
        self.channel := channel
    end ;

    -- 
    -- Gets the channel to use for the _org.antlr.v4.runtime.Token_ created by the lexer.
    -- 
    -- - returns: The channel to use for the _org.antlr.v4.runtime.Token_ created by the lexer.
    -- 
    -- public
    function getChannel (This : …) return Integer is
begin
        return channel
    end ;

    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#CHANNEL_.
    -- 

    --public
    override
    function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.channel
    end ;

    -- 
    -- 
    -- - returns: This method returns `False`.
    -- 

    --public
    override
    function isPositionDependent (This : …) return Boolean is
begin
        return False;
    end ;

    -- 
    -- 
    -- 
    -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#setChannel_ with the
    -- value provided by _#getChannel_.
    -- 

    -- public
    override
    procedure execute (lexer : Lexer) {
        lexer.setChannel(channel)
    end ;


    -- public
    override
    procedure hash (into hasher: inout Hasher) {
        hasher.combine(getActionType())
        hasher.combine(channel)
    end ;

    -- public
    description : String;
    function description return String is
        return "channel\(channel)"
    end ;

end ;


-- public
function "=" (lhs: LexerChannelAction, rhs: LexerChannelAction) return Boolean is
begin

    if lhs === rhs then
        return True;
    end if;


    return lhs.channel = rhs.channel
end ;
