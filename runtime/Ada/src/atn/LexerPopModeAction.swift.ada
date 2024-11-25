-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- Implements the `popMode` lexer action by calling _org.antlr.v4.runtime.Lexer#popMode_.
-- 
-- The `popMode` command does not have any parameters, so this action is
-- implemented as a singleton instance exposed by _#INSTANCE_.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

public final type LexerPopModeAction is new LexerAction and CustomStringConvertible with null record;
{
    -- 
    -- Provides a singleton instance of this parameterless lexer action.
    -- 
    -- public static 
    INSTANCE : constant LexerPopModeAction := LexerPopModeAction();

    -- 
    -- Constructs the singleton instance of the lexer `popMode` command.
    -- 
    private override procedure Init (Self : …) is
begin
    end ;

    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#popMode_.
    -- 
    override
    public function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.popMode
    end ;

    -- 
    -- 
    -- - returns: This method returns `False`.
    -- 

    public override function isPositionDependent (This : …) return Boolean is
begin
        return False;
    end ;

    -- 
    -- 
    -- 
    -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#popMode_.
    -- 

    public override procedure execute (lexer : Lexer) {
        lexer.popMode();
    end ;


    public override procedure hash (into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    end ;

    -- public
    description : String;
    function description return String is
        return "popMode"
    end ;
end ;

-- public
function "=" (lhs: LexerPopModeAction, rhs: LexerPopModeAction) return Boolean is
begin
    return lhs === rhs
end ;
