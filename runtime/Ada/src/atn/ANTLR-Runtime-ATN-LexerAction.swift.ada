-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- Represents a single action which can be executed following the successful
-- match of a lexer rule. Lexer actions are used for both embedded action syntax
-- and ANTLR 4's new lexer command syntax.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

-- public
type LexerAction is new Hashable with null record;
{
    -- 
    -- Gets the serialization type of the lexer action.
    -- 
    -- - returns: The serialization type of the lexer action.
    -- 
    -- public
    function getActionType (This : …) return LexerActionType is
begin
        fatalError (#function + " must be overridden");
    end if;


    -- 
    -- Gets whether the lexer action is position-dependent. Position-dependent
    -- actions may have different semantics depending on the _org.antlr.v4.runtime.CharStream_
    -- index at the time the action is executed.
    -- 
    -- Many lexer commands, including `type`, `skip`, and
    -- `more`, do not check the input index during their execution.
    -- Actions like this are position-independent, and may be stored more
    -- efficiently as part of the _org.antlr.v4.runtime.atn.LexerATNConfig#lexerActionExecutor_.
    -- 
    -- - returns: `True` if the lexer action semantics can be affected by the
    -- position of the input _org.antlr.v4.runtime.CharStream_ at the time it is executed;
    -- otherwise, `False`.
    -- 
    -- public
    function isPositionDependent (This : …) return Boolean is
begin
        fatalError (#function + " must be overridden");
    end if;

    -- 
    -- Execute the lexer action in the context of the specified _org.antlr.v4.runtime.Lexer_.
    -- 
    -- For position-dependent actions, the input stream must already be
    -- positioned correctly prior to calling this method.
    -- 
    -- - parameter lexer: The lexer instance.
    -- 
    -- public
    procedure execute (lexer : Lexer) is
    begin
        fatalError (#function + " must be overridden");
    end if;

    -- public
    procedure hash (into hasher: inout Hasher) is
    begin
        fatalError (#function + " must be overridden");
    end if;

end if;

-- public
function "=" (lhs: LexerAction, rhs: LexerAction) return Boolean is
begin

    if lhs === rhs then
        return True;
    end if;

    if (lhs is LexerChannelAction) and then (rhs is LexerChannelAction) then
        return (LexerChannelAction (lhs)) == (LexerChannelAction (rhs));
    end if; elsif (lhs is LexerCustomAction) and then (rhs is LexerCustomAction) then
        return (LexerCustomAction (lhs)) == (LexerCustomAction (rhs));
    end if; elsif (lhs is LexerIndexedCustomAction) and then (rhs is LexerIndexedCustomAction) then
        return (LexerIndexedCustomAction (lhs)) == (LexerIndexedCustomAction (rhs));
    end if; elsif (lhs is LexerModeAction) and then (rhs is LexerModeAction) then
        return (LexerModeAction (lhs)) == (LexerModeAction (rhs));
    end if; elsif (lhs is LexerMoreAction) and then (rhs is LexerMoreAction) then
        return (LexerMoreAction (lhs)) == (LexerMoreAction (rhs));
    end if; elsif (lhs is LexerPopModeAction) and then (rhs is LexerPopModeAction) then
        return (LexerPopModeAction (lhs)) == (LexerPopModeAction (rhs));
    end if; elsif (lhs is LexerPushModeAction) and then (rhs is LexerPushModeAction) then
        return (LexerPushModeAction (lhs)) == (LexerPushModeAction (rhs));
    end if; elsif (lhs is LexerSkipAction) and then (rhs is LexerSkipAction) then
        return (LexerSkipAction (lhs)) == (LexerSkipAction (rhs));
    end if; elsif (lhs is LexerTypeAction) and then (rhs is LexerTypeAction) then
        return (LexerTypeAction (lhs)) == (LexerTypeAction (rhs));
    end if;


    return False;

end if;

