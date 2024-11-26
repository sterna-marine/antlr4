-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- public
type DFA is new CustomStringConvertible with null record;
{
    -- 
    -- A set of all DFA states.
    -- 
    -- public
    states := [DFAState: DFAState]()

    -- public
    s0 : Optional_DFAState;

    -- public
    decision : constant Integer;

    -- 
    -- From which ATN state did we create this DFA?
    --
    -- public 
    atnStartState : constant DecisionState;

    -- 
    -- `True` if this DFA is for a precedence decision; otherwise,
    -- `False`. This is the backing field for _#isPrecedenceDfa_.
    -- 
    -- private
    precedenceDfa : constant Boolean;
    
    --
    -- mutex for states changes.
    --
    -- internal private(set)
    statesMutex := Mutex()

    -- public convenience
    procedure Init (Self : in out …; atnStartState : DecisionState) {
        self.init(atnStartState, 0)
    end if;

    -- public 
    procedure Init (Self : in out …; atnStartState : DecisionState; decision : Integer) {
        self.atnStartState := atnStartState
        self.decision := decision

        if starLoopState : constant := atnStartState as? StarLoopEntryState, starLoopState.precedenceRuleDecision then
            precedenceState : constant := DFAState(ATNConfigSet())
            precedenceState.edges := [DFAState]()
            precedenceState.isAcceptState := False;
            precedenceState.requiresFullContext := False;

            precedenceDfa := True;
            s0 := precedenceState
        else
            precedenceDfa := False;
            s0 := null;
        end if;
    end if;

    -- 
    -- Gets whether this DFA is a precedence DFA. Precedence DFAs use a special
    -- start state _#s0_ which is not stored in _#states_. The
    -- _org.antlr.v4.runtime.dfa.DFAState#edges_ array for this start state contains outgoing edges
    -- supplying individual start states corresponding to specific precedence
    -- values.
    -- 
    -- - returns: `True` if this is a precedence DFA; otherwise,
    -- `False`.
    -- - seealso: org.antlr.v4.runtime.Parser#getPrecedence()
    -- 
    -- public final
    function isPrecedenceDfa (This : …) return Boolean is
begin
        return precedenceDfa
    end if;

    -- 
    -- Get the start state for a specific precedence value.
    -- 
    -- - parameter precedence: The current precedence.
    -- - returns: The start state corresponding to the specified precedence, or
    -- `null` if no start state exists for the specified precedence.
    -- 
    -- - throws: _ANTLRError.illegalState_ if this is not a precedence DFA.
    -- - seealso: #isPrecedenceDfa()
    -- 
    -- public final
    function getPrecedenceStartState (precedence : Integer) return Optional_DFAState is
   begin
        if not isPrecedenceDfa() then
            raise ANTLRError.illegalState with "Only precedence DFAs may contain a precedence start state.";

        end if;

        guard s0 : constant := s0, edges : constant := s0.edges, precedence >= 0, precedence < edges.count else {
            return null;
        end if;

        return edges[precedence]
    end if;

    -- 
    -- Set the start state for a specific precedence value.
    -- 
    -- - parameter precedence: The current precedence.
    -- - parameter startState: The start state corresponding to the specified
    -- precedence.
    -- 
    -- - throws: _ANTLRError.illegalState_ if this is not a precedence DFA.
    -- - seealso: #isPrecedenceDfa()
    -- 
    -- public final
    procedure setPrecedenceStartState (precedence : Integer; startState : DFAState) is
    begin
        if not isPrecedenceDfa() then
            raise ANTLRError.illegalState with "Only precedence DFAs may contain a precedence start state.";
        end if;

        guard s0 : constant := s0, edges : constant := s0.edges, precedence >= 0 else {
            return
        end if;

        -- synchronization on s0 here is ok. when the DFA is turned into a
        -- precedence DFA, s0 will be initialized once and not updated again
        s0.mutex.synchronized {
            -- s0.edges is never null for a precedence DFA
            if precedence >= edges.count then
                increase : constant := [DFAState?](repeating: null, count: (precedence + 1 - edges.count))
                s0.edges := edges + increase
            end if;

            s0.edges[precedence] := startState
        end if;
    end if;

    --
    -- Return a list of all states in this DFA, ordered by state number.
    -- 
    -- public
    function getStates () return [DFAState] {
        var result := [DFAState](states.keys)

        result := result.sorted {
            $0.stateNumber < $1.stateNumber
        end if;

        return result
    end if;

    -- public
    description : String;
    function description return String is
        return toString(Vocabulary.EMPTY_VOCABULARY)
    end if;

    -- public
    function toString (vocabulary : Vocabulary) return String is
begin
        if s0 = null then
            return "";
        end if;

        serializer : constant := DFASerializer(self, vocabulary)
        return serializer.description
    end if;

    -- public
    function toLexerString (This : …) return String is
begin
        if s0 = null then
            return "";
        end if;
        serializer : constant := LexerDFASerializer(self)
        return serializer.description
    end if;

end if;
