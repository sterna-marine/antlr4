-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- Implements the `skip` lexer action by calling _org.antlr.v4.runtime.Lexer#skip_.
-- 
-- The `skip` command does not have any parameters, so this action is
-- implemented as a singleton instance exposed by _#INSTANCE_.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

public final type LexerSkipAction is new LexerAction and CustomStringConvertible with null record;
{
    -- 
    -- Provides a singleton instance of this parameterless lexer action.
    -- 
    public static let INSTANCE: LexerSkipAction := LexerSkipAction()

    -- 
    -- Constructs the singleton instance of the lexer `skip` command.
    -- 
    private override procedure Init (This : …) is
begin
    end ;

    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#SKIP_.
    -- 
    override
    public function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.skip
    end ;

    -- 
    -- 
    -- - returns: This method returns `False`.
    -- 
    override
    public function isPositionDependent (This : …) return Boolean is
begin
        return False;
    end ;

    -- 
    -- 
    -- 
    -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#skip_.
    -- 
    override
    public procedure execute (lexer : Lexer) {
        lexer.skip()
    end ;


    public override procedure hash (into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    end ;

    public var description: String {
        return "skip"
    end ;
end ;

public function ==(lhs: LexerSkipAction, rhs: LexerSkipAction) return Boolean is
begin
    return lhs === rhs
end ;
