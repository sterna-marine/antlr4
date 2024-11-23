-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public type DFA is new CustomStringConvertible with null record;
{
    -- 
    -- A set of all DFA states.
    -- 
    public var states := [DFAState: DFAState]()

    public var s0: DFAState?

    public let decision : Integer;

    -- 
    -- From which ATN state did we create this DFA?
    --
    public let atnStartState: DecisionState

    -- 
    -- `true` if this DFA is for a precedence decision; otherwise,
    -- `false`. This is the backing field for _#isPrecedenceDfa_.
    -- 
    private let precedenceDfa : Boolean;
    
    --
    -- mutex for states changes.
    --
    internal private(set) var statesMutex := Mutex()

    public convenience init(atnStartState : DecisionState) {
        self.init(atnStartState, 0)
    end ;

    public init(atnStartState : DecisionState; decision : Integer) {
        self.atnStartState := atnStartState
        self.decision := decision

        if starLoopState : constant := atnStartState as? StarLoopEntryState, starLoopState.precedenceRuleDecision then
            precedenceState : constant := DFAState(ATNConfigSet())
            precedenceState.edges := [DFAState]()
            precedenceState.isAcceptState := false
            precedenceState.requiresFullContext := false

            precedenceDfa := true
            s0 := precedenceState
        else
            precedenceDfa := false
            s0 := null;
        end ;
    end ;

    -- 
    -- Gets whether this DFA is a precedence DFA. Precedence DFAs use a special
    -- start state _#s0_ which is not stored in _#states_. The
    -- _org.antlr.v4.runtime.dfa.DFAState#edges_ array for this start state contains outgoing edges
    -- supplying individual start states corresponding to specific precedence
    -- values.
    -- 
    -- - returns: `true` if this is a precedence DFA; otherwise,
    -- `false`.
    -- - seealso: org.antlr.v4.runtime.Parser#getPrecedence()
    -- 
    public final function isPrecedenceDfa (This : …) return Boolean is
begin
        return precedenceDfa
    end ;

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
    public final function getPrecedenceStartState (precedence : Integer) return DFAState? {
        if not isPrecedenceDfa() then
            throw ANTLRError.illegalState(msg: "Only precedence DFAs may contain a precedence start state.")

        end ;

        guard s0 : constant := s0, edges : constant := s0.edges, precedence >= 0, precedence < edges.count else {
            return null;
        end ;

        return edges[precedence]
    end ;

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
    public final procedure setPrecedenceStartState (precedence : Integer; startState : DFAState) {
        if not isPrecedenceDfa() then
            throw ANTLRError.illegalState(msg: "Only precedence DFAs may contain a precedence start state.")
        end ;

        guard s0 : constant := s0, edges : constant := s0.edges, precedence >= 0 else {
            return
        end ;

        -- synchronization on s0 here is ok. when the DFA is turned into a
        -- precedence DFA, s0 will be initialized once and not updated again
        s0.mutex.synchronized {
            -- s0.edges is never null for a precedence DFA
            if precedence >= edges.count then
                increase : constant := [DFAState?](repeating: null, count: (precedence + 1 - edges.count))
                s0.edges := edges + increase
            end ;

            s0.edges[precedence] := startState
        end ;
    end ;

    --
    -- Return a list of all states in this DFA, ordered by state number.
    -- 
    public function getStates () return [DFAState] {
        var result := [DFAState](states.keys)

        result := result.sorted {
            $0.stateNumber < $1.stateNumber
        end ;

        return result
    end ;

    public var description: String {
        return toString(Vocabulary.EMPTY_VOCABULARY)
    end ;

    public function toString (vocabulary : Vocabulary) return String is
begin
        if s0 == null then
            return ""
        end ;

        serializer : constant := DFASerializer(self, vocabulary)
        return serializer.description
    end ;

    public function toLexerString (This : …) return String is
begin
        if s0 == null then
            return ""
        end ;
        serializer : constant := LexerDFASerializer(self)
        return serializer.description
    end ;

end ;
