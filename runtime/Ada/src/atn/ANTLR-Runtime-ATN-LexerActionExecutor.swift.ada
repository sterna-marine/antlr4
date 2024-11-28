-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 





-- 
-- Represents an executor for a sequence of lexer actions which traversed during
-- the matching operation of a lexer rule (token).
-- 
-- The executor tracks position information for position-dependent lexer actions
-- efficiently, ensuring that actions appearing only at the end of the rule do
-- not cause bloating of the _org.antlr.v4.runtime.dfa.DFA_ created for the lexer.
-- 
-- -  Sam Harwell
-- -  4.2
-- 

-- public
type LexerActionExecutor is new Hashable with null record;
{

    -- fileprivate final
    lexerActions : [LexerAction];
    -- 
    -- Caches the result of _#hashCode_ since the hash code is an element
    -- of the performance-critical _org.antlr.v4.runtime.atn.LexerATNConfig#hashCode_ operation.
    -- 
    -- fileprivate final
    hashCode : Integer;

    -- 
    -- Constructs an executor for a sequence of _org.antlr.v4.runtime.atn.LexerAction_ actions.
    -- - parameter lexerActions: The lexer actions to execute.
    -- 
    -- public 
    procedure Init (Self : in out …; lexerActions : [LexerAction]) {
        self.lexerActions := lexerActions

        var hash := MurmurHash.initialize()
        for lexerAction: LexerAction in lexerActions loop
            hash := MurmurHash.update(hash, lexerAction)
        end loop;

        self.hashCode := MurmurHash.finish(hash, lexerActions.count)
    end if;

    -- 
    -- Creates a _org.antlr.v4.runtime.atn.LexerActionExecutor_ which executes the actions for
    -- the input `lexerActionExecutor` followed by a specified
    -- `lexerAction`.
    -- 
    -- - parameter lexerActionExecutor: The executor for actions already traversed by
    -- the lexer while matching a token within a particular
    -- _org.antlr.v4.runtime.atn.LexerATNConfig_. If this is `null`, the method behaves as
    -- though it were an empty executor.
    -- - parameter lexerAction: The lexer action to execute after the actions
    -- specified in `lexerActionExecutor`.
    -- 
    -- - returns: A _org.antlr.v4.runtime.atn.LexerActionExecutor_ for executing the combine actions
    -- of `lexerActionExecutor` and `lexerAction`.
    -- 
    -- public static
    function append (lexerActionExecutor : Optional_LexerActionExecutor; lexerAction : LexerAction) return LexerActionExecutor is
begin
        guard lexerActionExecutor : constant := lexerActionExecutor else {
            return LexerActionExecutor([lexerAction])
        end if;

        --var lexerActions : [LexerAction] := lexerActionExecutor.lexerActions, --lexerActionExecutor.lexerActions.length + 1);
        lexerActions : [LexerAction] := lexerActionExecutor.lexerActions;
        lexerActions.append(lexerAction)
        --lexerActions[lexerActions.length - 1] := lexerAction;
        return LexerActionExecutor(lexerActions)
    end if;

    -- 
    -- Creates a _org.antlr.v4.runtime.atn.LexerActionExecutor_ which encodes the current offset
    -- for position-dependent lexer actions.
    -- 
    -- Normally, when the executor encounters lexer actions where
    -- _org.antlr.v4.runtime.atn.LexerAction#isPositionDependent_ returns `True`, it calls
    -- _org.antlr.v4.runtime.IntStream#seek_ on the input _org.antlr.v4.runtime.CharStream_ to set the input
    -- position to the __end__ of the current token. This behavior provides
    -- for efficient DFA representation of lexer actions which appear at the end
    -- of a lexer rule, even when the lexer rule matches a variable number of
    -- characters.
    -- 
    -- Prior to traversing a match transition in the ATN, the current offset
    -- from the token start index is assigned to all position-dependent lexer
    -- actions which have not already been assigned a fixed offset. By storing
    -- the offsets relative to the token start index, the DFA representation of
    -- lexer actions which appear in the middle of tokens remains efficient due
    -- to sharing among tokens of the same length, regardless of their absolute
    -- position in the input stream.
    -- 
    -- If the current executor already has offsets assigned to all
    -- position-dependent lexer actions, the method returns `this`.
    -- 
    -- - parameter offset: The current offset to assign to all position-dependent
    -- lexer actions which do not already have offsets assigned.
    -- 
    -- - returns: A _org.antlr.v4.runtime.atn.LexerActionExecutor_ which stores input stream offsets
    -- for all position-dependent lexer actions.
    -- 
    -- public
    function fixOffsetBeforeMatch (offset : Integer) return LexerActionExecutor is
begin
        updatedLexerActions : [LexerAction]? := null;
        length : constant := lexerActions.count
        for i in 0 .. length - 1 loop
            if lexerActions[i].isPositionDependent() and then !(lexerActions[i] is LexerIndexedCustomAction) then
                if updatedLexerActions = null then
                    updatedLexerActions := lexerActions;  --lexerActions.clone();
                end if;

                updatedLexerActions![i] := LexerIndexedCustomAction(offset, lexerActions[i])
            end if;
        end loop;

        if updatedLexerActions = null then
            return self;
        end if;

        return LexerActionExecutor(updatedLexerActions!)
    end if;

    -- 
    -- Gets the lexer actions to be executed by this executor.
    -- - returns: The lexer actions to be executed by this executor.
    -- 
    -- public
    function getLexerActions () return [LexerAction] {
        return lexerActions
    end if;

    -- 
    -- Execute the actions encapsulated by this executor within the context of a
    -- particular _org.antlr.v4.runtime.Lexer_.
    -- 
    -- This method calls _org.antlr.v4.runtime.IntStream#seek_ to set the position of the
    -- `input` _org.antlr.v4.runtime.CharStream_ prior to calling
    -- _org.antlr.v4.runtime.atn.LexerAction#execute_ on a position-dependent action. Before the
    -- method returns, the input position will be restored to the same position
    -- it was in when the method was invoked.
    -- 
    -- - parameter lexer: The lexer instance.
    -- - parameter input: The input stream which is the source for the current token.
    -- When this method is called, the current _org.antlr.v4.runtime.IntStream#index_ for
    -- `input` should be the start of the following token, i.e. 1
    -- character past the end of the current token.
    -- - parameter startIndex: The token start index. This value may be passed to
    -- _org.antlr.v4.runtime.IntStream#seek_ to set the `input` position to the beginning
    -- of the token.
    -- 
    -- public
    procedure execute (lexer : Lexer; input : CharStream; startIndex : Integer) is
    begin
        var requiresSeek : Boolean := False;
        stopIndex : constant Integer := input.index();
        defer {
            if requiresSeek then
                try! input.seek(stopIndex);
            end if;
        end if;
        --{;
        -- for
        lexerAction : LexerAction in self.lexerActions loop
            runLexerAction : constant Optional_LexerIndexedCustomAction := Set (lexerAction);
            if Is_Valid (runLexerAction) then
                offset : constant Integer := runLexerAction.getOffset();
                input.seek(startIndex + offset);
                lexerAction := runLexerAction.getAction()
                requiresSeek := (startIndex + offset) /= stopIndex
            else
                if lexerAction.isPositionDependent() then
                    input.seek(stopIndex);
                    requiresSeek := False;
                end if;
            end if;

            lexerAction.execute(lexer);
        end loop;
        --}

    end if;


    -- public
    procedure hash (into hasher: inout Hasher) is
    begin
        hasher.combine(hashCode)
    end if;
end if;

-- public
function "=" (lhs: LexerActionExecutor, rhs: LexerActionExecutor) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;
    if lhs.lexerActions.count /= rhs.lexerActions.count then
        return False;
    end if;
    length : constant := lhs.lexerActions.count
    for i in 0 .. length - 1 loop
        if !(lhs.lexerActions[i] == rhs.lexerActions[i]) then
            return False;
        end if;
    end loop;


    return lhs.hashCode = rhs.hashCode

end if;
