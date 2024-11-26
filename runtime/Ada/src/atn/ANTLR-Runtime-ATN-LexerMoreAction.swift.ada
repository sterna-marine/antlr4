-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- Implements the `more` lexer action by calling _org.antlr.v4.runtime.Lexer#more_.
-- 
-- The `more` command does not have any parameters, so this action is
-- implemented as a singleton instance exposed by _#INSTANCE_.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

-- public final
type LexerMoreAction is new LexerAction and CustomStringConvertible with null record;
{
    -- 
    -- Provides a singleton instance of this parameterless lexer action.
    -- 
    -- public static 
    INSTANCE : constant LexerMoreAction := LexerMoreAction();

    -- 
    -- Constructs the singleton instance of the lexer `more` command.
    -- 
    -- private
    override
    procedure Init (Self : …) is
begin
    end if;

    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#MORE_.
    -- 
    override
    -- public
    function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.more
    end if;

    -- 
    -- 
    -- - returns: This method returns `False`.
    -- 
    override
    -- public
    function isPositionDependent (This : …) return Boolean is
begin
        return False;
    end if;

    -- 
    -- 
    -- 
    -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#more_.
    -- 
    override
    -- public
    procedure execute (lexer : Lexer) is
    begin
        lexer.more()
    end if;


    -- public
    override
    procedure hash (into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    end if;

    -- public
    description : String;
    function description return String is
        return "more"
    end if;
end if;

-- public
function "=" (lhs: LexerMoreAction, rhs: LexerMoreAction) return Boolean is
begin
    return lhs === rhs
end if;
