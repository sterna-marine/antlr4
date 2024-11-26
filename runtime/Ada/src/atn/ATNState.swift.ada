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
-- * Nodes showing multiple outgoing alternatives with a ` .. ` support
-- any number of alternatives (one or more). Nodes without the ` .. ` only
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
-- ### Greedy Closure: `( .. )*`
-- 
-- 
-- 
-- ### Greedy Positive Closure: `( .. )+`
-- 
-- 
-- 
-- ### Greedy Optional: `( .. )?`
-- 
-- 
-- 
-- ## Non-Greedy Loops
-- 
-- ### Non-Greedy Closure: `( .. )*?`
-- 
-- 
-- 
-- ### Non-Greedy Positive Closure: `( .. )+?`
-- 
-- 
-- 
-- ### Non-Greedy Optional: `( .. )??`
-- 
-- 
-- 
-- 
-- public
type ATNState is new Hashable and CustomStringConvertible with null record;
{
    -- constants for serialization
    -- public static 
    INVALID_TYPE : constant Integer := 0;
    -- public static 
    BASIC : constant Integer := 1;
    -- public static 
    RULE_START : constant Integer := 2;
    -- public static 
    BLOCK_START : constant Integer := 3;
    -- public static 
    PLUS_BLOCK_START : constant Integer := 4;
    -- public static 
    STAR_BLOCK_START : constant Integer := 5;
    -- public static 
    TOKEN_START : constant Integer := 6;
    -- public static 
    RULE_STOP : constant Integer := 7;
    -- public static 
    BLOCK_END : constant Integer := 8;
    -- public static 
    STAR_LOOP_BACK : constant Integer := 9;
    -- public static 
    STAR_LOOP_EN : constant Integer := 10;
    -- public static 
    PLUS_LOOP_BACK : constant Integer := 11;
    -- public static 
    LOOP_END : constant Integer := 12;

    -- public static 
    serializationNames : constant Array<String> =;

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


    -- public static 
    INVALID_STATE_NUMBER : constant Integer := -1;

    -- 
    -- Which ATN are we in?
    -- 
    -- public final 
     atn: Optional_ATN; := null;

    public internal(set) final var stateNumber: Integer := INVALID_STATE_NUMBER

    public internal(set) final var ruleIndex: Optional_Int;
    -- at runtime, we don't have Rule objects

    -- public private(set) final var
    epsilonOnlyTransitions : Boolean := False;

    -- 
    -- Track the transitions emanating from this ATN state.
    -- 
    -- internal private(set) final
    transitions := [Transition]()

    -- 
    -- Used to cache lookahead during parsing, not used during construction
    -- 
    public internal(set) final var nextTokenWithinRule: Optional_IntervalSet;


    -- public
    procedure hash (into hasher: inout Hasher) is
    begin
        hasher.combine(stateNumber)
    end if;

    -- public
    function isNonGreedyExitState (This : …) return Boolean is
begin
        return False;
    end if;


    -- public
    description : String;
    function description return String is
        --return "MyClass \(string)"
        return String(stateNumber)
    end if;
    -- public final
    function getTransitions () return [Transition] {
        return transitions
    end if;

    -- public final
    function getNumberOfTransitions (This : …) return Integer is
begin
        return transitions.count
    end if;

    -- public final
    procedure addTransition (e : Transition) is
    begin
        if transitions.isEmpty then
            epsilonOnlyTransitions := e.isEpsilon();
        elsif epsilonOnlyTransitions /= e.isEpsilon() then
            print("ATN state %d has both epsilon and non-epsilon transitions.\n", String(stateNumber))
            epsilonOnlyTransitions := False;
        end if;

        var alreadyPresent := False;
        for t in transitions loop
            if t.target.stateNumber = e.target.stateNumber then
                if tLabel : constant := t.labelIntervalSet(), eLabel : constant := e.labelIntervalSet(), tLabel = eLabel then
--                    print("Repeated transition upon \(eLabel) from \(stateNumber)->\(t.target.stateNumber)")
                    alreadyPresent := True;
                    exit when True;
                end if;
                elsif t.isEpsilon() and then e.isEpsilon() then
--                    print("Repeated epsilon transition from \(stateNumber)->\(t.target.stateNumber)")
                    alreadyPresent := True;
                    exit when True;
                end if;
            end if;
        end loop;

        if not alreadyPresent then
            transitions.append(e);
        end if;
    end if;

    -- public final
    function transition (i : Integer) return Transition is
begin
        return transitions[i]
    end if;

    -- public final
    procedure setTransition (i : Integer; e : Transition) is
    begin
        transitions[i] := e
    end if;

    -- public final
    function removeTransition (index : Integer) return Transition is
begin

        return transitions.remove(at: index)
    end if;

    -- public
    function getStateType (This : …) return Integer is
begin
        fatalError(#function + " must be overridden")
    end if;

    -- public final
    function onlyHasEpsilonTransitions (This : …) return Boolean is
begin
        return epsilonOnlyTransitions
    end if;

    -- public final
    procedure setRuleIndex (ruleIndex : Integer) is
    begin
        self.ruleIndex := ruleIndex
    end if;
end if;

-- public
function "=" (lhs: ATNState, rhs: ATNState) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;
    -- are these states same object?
    return lhs.stateNumber = rhs.stateNumber

end if;

