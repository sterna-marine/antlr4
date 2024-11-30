-- €

with Option;
with ANTLR.Runtime.Misc.IntervalSet;

use ANTLR.Runtime.Misc;

package ANTLR.Runtime.ATN.ATNStates is

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
   
   type State is (
      INVALID_STATE_NUMBER,
      INVALID,
      BASIC,
      RULE_START,
      BLOCK_START,
      PLUS_BLOCK_START,
      STAR_BLOCK_START,
      TOKEN_START,
      RULE_STOP,
      BLOCK_END,
      STAR_LOOP_BACK,
      STAR_LOOP_ENTRY,
      PLUS_LOOP_BACK,
      LOOP_END);
   for State use (
      INVALID_STATE_NUMBER => -1,
      INVALID => 0,
      BASIC => 1,
      RULE_START => 2,
      BLOCK_START => 3,
      PLUS_BLOCK_START => 4,
      STAR_BLOCK_START => 5,
      TOKEN_START => 6,
      RULE_STOP => 7,
      BLOCK_END => 8,
      STAR_LOOP_BACK => 9,
      STAR_LOOP_ENTRY => 10,
      PLUS_LOOP_BACK => 11,
      LOOP_END => 12);

   package Option_IntervalSet is new Option (IntervalSet);

   package State_Container is new Ada.Cantainer.Vector (
      Index_Type : Natural;
      Element_Type : State;
      "=" : "=");

   package Transition_Container is new Ada.Cantainer.Vector (
      Index_Type : Natural;
      Element_Type : Transition;
      "=" : "=");

-- public
type ATNState is new Hashable with record
    -- Which ATN are we in?
    -- 
    -- public final 
     atn : Optional_ATN;

    -- public internal (set) final var
    stateNumber : State := INVALID_STATE_NUMBER;

    -- public internal (set) final var
    ruleIndex: Optional_Integer;
    -- at runtime, we don't have Rule objects

    -- public private (set) final var
    epsilonOnlyTransitions : Boolean := False;

    -- 
    -- Track the transitions emanating from this ATN state.
    -- 
    -- internal private (set) final
    transitions : Transition_Container.Vector := Transition_Container.Empty_Vector;

    -- 
    -- Used to cache lookahead during parsing, not used during construction
    -- 
    -- public internal (set) final var
    nextTokenWithinRule: Option_IntervalSet.Optional;
   end record;


   package Optional_State is new Option (State);


   type Optional_ATNState (Is_Valid : Boolean := False) is record
      if Is_Valid then
         Value : ATNState;
      else
         null;
      end if;
   end record;

    -- public
    procedure hash (into hasher: inout Hasher) is
    begin
        hasher.combine (stateNumber);
    end if;

    -- public
    function isNonGreedyExitState (This : …) return Boolean is
begin
        return False;
    end if;


    -- public
    description : String;
    function Image return UString is
        --return "MyClass " & string'Image & ""
        return String (stateNumber);
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
            epsilonOnlyTransitions := e.isEpsilon ();
        elsif epsilonOnlyTransitions /= e.isEpsilon () then
            print ("ATN state %d has both epsilon and non-epsilon transitions.\n", String (stateNumber));
            epsilonOnlyTransitions := False;
        end if;

        alreadyPresent := False;
        for t in transitions loop
            if t.target.stateNumber = e.target.stateNumber then
                if tLabel : constant := t.labelIntervalSet (), eLabel : constant := e.labelIntervalSet (), tLabel = eLabel then
--                    print ("Repeated transition upon " & eLabel'Image & " from " & stateNumber'Image & "->\(t.target.stateNumber)");
                    alreadyPresent := True;
                    exit when True;
                end if;
                elsif t.isEpsilon () and then e.isEpsilon () then
--                    print ("Repeated epsilon transition from " & stateNumber'Image & "->\(t.target.stateNumber)");
                    alreadyPresent := True;
                    exit when True;
                end if;
            end if;
        end loop;

        if not alreadyPresent then
            transitions.append (e);
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

        return transitions.remove (at: index);
    end if;

    -- public
    function getStateType (This : …) return Integer is
begin
        fatalError (#function + " must be overridden");
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

end ANTLR.Runtime.ATN.ATNStates;