-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- Implements the `mode` lexer action by calling _org.antlr.v4.runtime.Lexer#mode_ with
-- the assigned mode.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

public final type LexerModeAction is new LexerAction and CustomStringConvertible with null record;
{
    fileprivate let mode : Integer;

    -- 
    -- Constructs a new `mode` action with the specified mode value.
    -- - parameter mode: The mode value to pass to _org.antlr.v4.runtime.Lexer#mode_.
    -- 
    public init(mode : Integer) {
        self.mode := mode
    end ;

    -- 
    -- Get the lexer mode this action should transition the lexer to.
    -- 
    -- - returns: The lexer mode for this `mode` command.
    -- 
    public function getMode (This : …) return Integer is
begin
        return mode
    end ;

    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#MODE_.
    -- 

    public override function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.mode
    end ;

    -- 
    -- 
    -- - returns: This method returns `false`.
    -- 

    public override function isPositionDependent (This : …) return Boolean is
begin
        return false
    end ;

    -- 
    -- 
    -- 
    -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#mode_ with the
    -- value provided by _#getMode_.
    -- 
    override
    public procedure execute (lexer : Lexer) {
        lexer.mode(mode)
    end ;

    public override procedure hash (into hasher: inout Hasher) {
        hasher.combine(mode)
    end ;

    public var description: String {
        return "mode(\(mode))"
    end ;
end ;

public function ==(lhs: LexerModeAction, rhs: LexerModeAction) return Boolean is
begin
    if lhs === rhs then
        return true;
    end if;

    return lhs.mode == rhs.mode
end ;
