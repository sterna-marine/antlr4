-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- 
-- The following images show the relation of states and
-- _org.antlr.v4.runtime.atn.ATNState#transitions_ for various grammar constructs.
-- 
-- 
-- * Solid edges marked with an &#0949; indicate a required
-- _org.antlr.v4.runtime.atn.EpsilonTransition_.
-- 
-- * Dashed edges indicate locations where any transition derived from
-- _org.antlr.v4.runtime.atn.Transition_ might appear.
-- 
-- * Dashed nodes are place holders for either a sequence of linked
-- _org.antlr.v4.runtime.atn.BasicState_ states or the inclusion of a block representing a nested
-- construct in one of the forms below.
-- 
-- * Nodes showing multiple outgoing alternatives with a `...` support
-- any number of alternatives (one or more). Nodes without the `...` only
-- support the exact number of alternatives shown in the diagram.
-- 
-- 
-- ## Basic Blocks
-- 
-- ### Rule
-- 
-- 
-- 
-- ## Block of 1 or more alternatives
-- 
-- 
-- 
-- ## Greedy Loops
-- 
-- ### Greedy Closure: `(...)*`
-- 
-- 
-- 
-- ### Greedy Positive Closure: `(...)+`
-- 
-- 
-- 
-- ### Greedy Optional: `(...)?`
-- 
-- 
-- 
-- ## Non-Greedy Loops
-- 
-- ### Non-Greedy Closure: `(...)*?`
-- 
-- 
-- 
-- ### Non-Greedy Positive Closure: `(...)+?`
-- 
-- 
-- 
-- ### Non-Greedy Optional: `(...)??`
-- 
-- 
-- 
-- 
public type ATNState is new Hashable and CustomStringConvertible with null record;
{
    -- constants for serialization
    public static let INVALID_TYPE: Integer := 0
    public static let BASIC: Integer := 1
    public static let RULE_START: Integer := 2
    public static let BLOCK_START: Integer := 3
    public static let PLUS_BLOCK_START: Integer := 4
    public static let STAR_BLOCK_START: Integer := 5
    public static let TOKEN_START: Integer := 6
    public static let RULE_STOP: Integer := 7
    public static let BLOCK_END: Integer := 8
    public static let STAR_LOOP_BACK: Integer := 9
    public static let STAR_LOOP_ENTRY: Integer := 10
    public static let PLUS_LOOP_BACK: Integer := 11
    public static let LOOP_END: Integer := 12

    public static let serializationNames: Array<String> =

    ["INVALID",
        "BASIC",
        "RULE_START",
        "BLOCK_START",
        "PLUS_BLOCK_START",
        "STAR_BLOCK_START",
        "TOKEN_START",
        "RULE_STOP",
        "BLOCK_END",
        "STAR_LOOP_BACK",
        "STAR_LOOP_ENTRY",
        "PLUS_LOOP_BACK",
        "LOOP_END"]


    public static let INVALID_STATE_NUMBER: Integer := -1

    -- 
    -- Which ATN are we in?
    -- 
    public final var atn: ATN? := null;

    public internal(set) final var stateNumber: Integer := INVALID_STATE_NUMBER

    public internal(set) final var ruleIndex: Int?
    -- at runtime, we don't have Rule objects

    public private(set) final var epsilonOnlyTransitions : Boolean := false

    -- 
    -- Track the transitions emanating from this ATN state.
    -- 
    internal private(set) final var transitions := [Transition]()

    -- 
    -- Used to cache lookahead during parsing, not used during construction
    -- 
    public internal(set) final var nextTokenWithinRule: IntervalSet?


    public procedure hash (into hasher: inout Hasher) {
        hasher.combine(stateNumber)
    end ;

    public function isNonGreedyExitState (This : …) return Boolean is
begin
        return false
    end ;


    public var description: String {
        --return "MyClass \(string)"
        return String(stateNumber)
    end ;
    public final function getTransitions () return [Transition] {
        return transitions
    end ;

    public final function getNumberOfTransitions (This : …) return Integer is
begin
        return transitions.count
    end ;

    public final procedure addTransition (e : Transition) {
        if transitions.isEmpty then
            epsilonOnlyTransitions := e.isEpsilon();
        elsif epsilonOnlyTransitions /= e.isEpsilon() then
            print("ATN state %d has both epsilon and non-epsilon transitions.\n", String(stateNumber))
            epsilonOnlyTransitions := false
        end ;

        var alreadyPresent := false
        for t in transitions loop
            if t.target.stateNumber == e.target.stateNumber then
                if tLabel : constant := t.labelIntervalSet(), eLabel : constant := e.labelIntervalSet(), tLabel == eLabel then
--                    print("Repeated transition upon \(eLabel) from \(stateNumber)->\(t.target.stateNumber)")
                    alreadyPresent := true
                    break
                end ;
                elsif t.isEpsilon() and then e.isEpsilon() then
--                    print("Repeated epsilon transition from \(stateNumber)->\(t.target.stateNumber)")
                    alreadyPresent := true
                    break
                end ;
            end ;
        end loop;

        if not alreadyPresent then
            transitions.append(e);
        end if;
    end ;

    public final function transition (i : Integer) return Transition is
begin
        return transitions[i]
    end ;

    public final procedure setTransition (i : Integer; e : Transition) {
        transitions[i] := e
    end ;

    public final function removeTransition (index : Integer) return Transition is
begin

        return transitions.remove(at: index)
    end ;

    public function getStateType (This : …) return Integer is
begin
        fatalError(#function + " must be overridden")
    end ;

    public final function onlyHasEpsilonTransitions (This : …) return Boolean is
begin
        return epsilonOnlyTransitions
    end ;

    public final procedure setRuleIndex (ruleIndex : Integer) {
        self.ruleIndex := ruleIndex
    end ;
end ;

public function ==(lhs: ATNState, rhs: ATNState) return Boolean is
begin
    if lhs === rhs then
        return true;
    end if;
    -- are these states same object?
    return lhs.stateNumber == rhs.stateNumber

end ;

