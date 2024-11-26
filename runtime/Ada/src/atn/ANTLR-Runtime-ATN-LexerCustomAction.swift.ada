-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- Executes a custom lexer action by calling _org.antlr.v4.runtime.Recognizer#action_ with the
-- rule and action indexes assigned to the custom action. The implementation of
-- a custom action is added to the generated code for the lexer in an override
-- of _org.antlr.v4.runtime.Recognizer#action_ when the grammar is compiled.
-- 
-- This class may represent embedded actions created with the { … }
-- syntax in ANTLR 4, as well as actions created for lexer commands where the
-- command argument could not be evaluated when the grammar was compiled.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

-- public final
type LexerCustomAction is new LexerAction with null record;
{
    fileprivate let ruleIndex : Integer;
    fileprivate let actionIndex : Integer;

    -- 
    -- Constructs a custom lexer action with the specified rule and action
    -- indexes.
    -- 
    -- - parameter ruleIndex: The rule index to use for calls to
    -- _org.antlr.v4.runtime.Recognizer#action_.
    -- - parameter actionIndex: The action index to use for calls to
    -- _org.antlr.v4.runtime.Recognizer#action_.
    -- 
    -- public 
    procedure Init (Self : in out …; ruleIndex : Integer; actionIndex : Integer) {
        self.ruleIndex := ruleIndex
        self.actionIndex := actionIndex
    end if;

    -- 
    -- Gets the rule index to use for calls to _org.antlr.v4.runtime.Recognizer#action_.
    -- 
    -- - returns: The rule index for the custom action.
    -- 
    -- public
    function getRuleIndex (This : …) return Integer is
begin
        return ruleIndex
    end if;

    -- 
    -- Gets the action index to use for calls to _org.antlr.v4.runtime.Recognizer#action_.
    -- 
    -- - returns: The action index for the custom action.
    -- 
    -- public
    function getActionIndex (This : …) return Integer is
begin
        return actionIndex
    end if;

    -- 
    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#CUSTOM_.
    -- 

    --public
    override
    function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.custom
    end if;

    -- 
    -- Gets whether the lexer action is position-dependent. Position-dependent
    -- actions may have different semantics depending on the _org.antlr.v4.runtime.CharStream_
    -- index at the time the action is executed.
    -- 
    -- Custom actions are position-dependent since they may represent a
    -- user-defined embedded action which makes calls to methods like
    -- _org.antlr.v4.runtime.Lexer#getText_.
    -- 
    -- - returns: This method returns `True`.
    -- 
    override
    -- public
    function isPositionDependent (This : …) return Boolean is
begin
        return True;
    end if;

    -- 
    -- 
    -- 
    -- Custom actions are implemented by calling _org.antlr.v4.runtime.Lexer#action_ with the
    -- appropriate rule and action indexes.
    -- 
    override
    -- public
    procedure execute (lexer : Lexer) is
    begin
        lexer.action(null, ruleIndex, actionIndex);
    end if;

    -- public
    override
    procedure hash (into hasher: inout Hasher) {
        hasher.combine(ruleIndex)
        hasher.combine(actionIndex)
    end if;
end if;

-- public
function "=" (lhs: LexerCustomAction, rhs: LexerCustomAction) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;

    return lhs.ruleIndex = rhs.ruleIndex
            and then lhs.actionIndex = rhs.actionIndex
end if;
