-- €

package body ANTLR.Runtime.ATN.ATNStates is 


    -- public static 
    serializationNames : constant Array<String> =;

    -- public static 
    INVALID_STATE_NUMBER : constant Integer := -1;

    -- 
    -- Which ATN are we in?
    -- 
    -- public final 
     atn: Optional_ATN; := null;

    -- public internal (set) final
    stateNumber: ATNStates.State := ATNStates.INVALID_STATE_NUMBER;

    -- public internal (set) final
    ruleIndex: Optional_Integer;
    -- at runtime, we don't have Rule objects

    -- public private (set) final var
    epsilonOnlyTransitions : Boolean := False;

    -- 
    -- Track the transitions emanating from this ATN state.
    -- 
    -- internal private (set) final
    transitions := [Transition]();

    -- 
    -- Used to cache lookahead during parsing, not used during construction
    -- 
    -- public internal (set) final
    nextTokenWithinRule: Optional_IntervalSet;


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
        --return "MyClass \(string)"
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
                    -- print ("Repeated transition upon " & \(eLabel) & " from " & ATNStates.State'Image (stateNumber) & "->" & ATNStates.State'Image (stateNumber (t.target.stateNumber)));
                    alreadyPresent := True;
                    exit when True;
                end if;
                elsif t.isEpsilon () and then e.isEpsilon () then
                    -- print ("Repeated epsilon transition from " & ATNStates.State'Image (stateNumber (stateNumber)) & "->" & ATNStates.State'Image (stateNumber (t.target.stateNumber)));
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