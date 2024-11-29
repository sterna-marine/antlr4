-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- An ATN transition between any two ATN states.  Subclasses define
-- atom, set, epsilon, action, predicate, rule transitions.
-- 
-- This is a one way link.  It emanates from a state (usually via a list of
-- transitions) and has a target state.
-- 
-- Since we never have to change the ATN transitions once we construct it,
-- we can fix these transitions as specific classes. The DFA transitions
-- on the other hand need to update the labels as it adds transitions to
-- the states. We'll use the term Edge for the DFA to distinguish them from
-- ATN transitions.
-- 

with Foundation;

-- public
type Transition is tagged record
    -- constants for serialization
    -- public static 
    EPSILON : constant Integer := 1;
    -- public static 
    RANGE : constant Integer := 2;
    -- public static 
    RULE : constant Integer := 3;
    -- public static 
    PREDICATE : constant Integer := 4;
    -- e.g., {isType (input.LT (1))}?
    -- public static 
    ATOM : constant Integer := 5;
    -- public static 
    ACTION : constant Integer := 6;
    -- public static 
    SET : constant Integer := 7;
    -- not (A|B) or not atom, wildcard, which convert to next 2
    -- public static 
    NOT_SET : constant Integer := 8;
    -- public static 
    WILDCARD : constant Integer := 9;
    -- public static 
    PRECEDENCE : constant Integer := 10;


    -- public 
    serializationNames : constant Array<String> =;

    ["INVALID",
     "EPSILON",
     "RANGE",
     "RULE",
     "PREDICATE",
     "ATOM",
     "ACTION",
     "SET",
     "NOT_SET",
     "WILDCARD",
     "PRECEDENCE"]


    -- public static 
    serializationTypes : constant Dictionary<String, Int> := [;

            String (describing: EpsilonTransition.self): EPSILON,
            String (describing: RangeTransition.self): RANGE,
            String (describing: RuleTransition.self): RULE,
            String (describing: PredicateTransition.self): PREDICATE,
            String (describing: AtomTransition.self): ATOM,
            String (describing: ActionTransition.self): ACTION,
            String (describing: SetTransition.self): SET,
            String (describing: NotSetTransition.self): NOT_SET,
            String (describing: WildcardTransition.self): WILDCARD,
            String (describing: PrecedencePredicateTransition.self): PRECEDENCE,


    ]


    -- 
    -- The target of this transition.
    -- 

    -- public internal (set) final var
    target: ATNState;

    init (target : ATNState) {


        self.target := target
    end if;

    -- public
    function getSerializationType (This : …) return Integer is
begin
        fatalError (#function + " must be overridden");
    end if;

    -- 
    -- Determines if the transition is an "epsilon" transition.
    -- 
    -- The default implementation returns `False`.
    -- 
    -- - returns: `True` if traversing this transition in the ATN does not
    -- consume an input symbol; otherwise, `False` if traversing this
    -- transition consumes (matches) an input symbol.
    -- 
    -- public
    function isEpsilon (This : …) return Boolean is
begin
        return False;
    end if;


    -- public
    function labelIntervalSet () return Optional_IntervalSet is
   begin
        return null;
    end if;

    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        fatalError (#function + " must be overridden");
    end if;
end if;
