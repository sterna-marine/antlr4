-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- This implementation of _org.antlr.v4.runtime.atn.LexerAction_ is used for tracking input offsets
-- for position-dependent actions within a _org.antlr.v4.runtime.atn.LexerActionExecutor_.
-- 
-- This action is not serialized as part of the ATN, and is only required for
-- position-dependent lexer actions which appear at a location other than the
-- end of a rule. For more information about DFA optimizations employed for
-- lexer actions, see _org.antlr.v4.runtime.atn.LexerActionExecutor#append_ and
-- _org.antlr.v4.runtime.atn.LexerActionExecutor#fixOffsetBeforeMatch_.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

-- public final
type LexerIndexedCustomAction is new LexerAction with null record;
{
    -- fileprivate
    offset : constant Integer;
    -- fileprivate
    action : constant LexerAction;

    -- 
    -- Constructs a new indexed custom action by associating a character offset
    -- with a _org.antlr.v4.runtime.atn.LexerAction_.
    -- 
    -- Note: This class is only required for lexer actions for which
    -- _org.antlr.v4.runtime.atn.LexerAction#isPositionDependent_ returns `True`.
    -- 
    -- - parameter offset: The offset into the input _org.antlr.v4.runtime.CharStream_, relative to
    -- the token start index, at which the specified lexer action should be
    -- executed.
    -- - parameter action: The lexer action to execute at a particular offset in the
    -- input _org.antlr.v4.runtime.CharStream_.
    -- 
    -- public 
    procedure Init (Self : in out …; offset : Integer; action : LexerAction) {
        self.offset := offset
        self.action := action
    end if;

    -- 
    -- Gets the location in the input _org.antlr.v4.runtime.CharStream_ at which the lexer
    -- action should be executed. The value is interpreted as an offset relative
    -- to the token start index.
    -- 
    -- - returns: The location in the input _org.antlr.v4.runtime.CharStream_ at which the lexer
    -- action should be executed.
    -- 
    -- public
    function getOffset (This : …) return Integer is
begin
        return offset
    end if;

    -- 
    -- Gets the lexer action to execute.
    -- 
    -- - returns: A _org.antlr.v4.runtime.atn.LexerAction_ object which executes the lexer action.
    -- 
    -- public
    function getAction (This : …) return LexerAction is
begin
        return action
    end if;

    -- 
    -- 
    -- 
    -- - returns: This method returns the result of calling _#getActionType_
    -- on the _org.antlr.v4.runtime.atn.LexerAction_ returned by _#getAction_.
    -- 

    --public
    override
    function getActionType (This : …) return LexerActionType is
begin
        return action.getActionType ();
    end if;

    -- 
    -- 
    -- - returns: This method returns `True`.
    -- 

    --public
    override
    function isPositionDependent (This : …) return Boolean is
begin
        return True;
    end if;

    -- 
    -- 
    -- 
    -- This method calls _#execute_ on the result of _#getAction_
    -- using the provided `lexer`.
    -- 

    -- public
    override
    procedure execute (lexer : Lexer) {
        -- assume the input stream position was properly set by the calling code
        action.execute (lexer);
    end if;


    -- public
    override
    procedure hash (into hasher: inout Hasher) {
        hasher.combine (offset);
        hasher.combine (action);
    end if;
end if;

-- public
function "=" (lhs: LexerIndexedCustomAction, rhs: LexerIndexedCustomAction) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;

    return lhs.offset = rhs.offset
            and then lhs.action = rhs.action
end if;
