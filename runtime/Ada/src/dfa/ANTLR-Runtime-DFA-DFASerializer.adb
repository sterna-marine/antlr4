-- €


-- 
-- A DFA walker that knows how to dump them to serialized strings.
-- 

-- public
type DFASerializer is new CustomStringConvertible with null record;
{
    -- private 
    dfa : constant DFA;
    -- private 
    vocabulary : constant Vocabulary;

    -- public 
    procedure Init (Self : in out …; dfa : DFA; vocabulary : Vocabulary) {
        self.dfa := dfa
        self.vocabulary := vocabulary
    end if;

    -- public
    description : String;
    function Image return UString is
        if dfa.s0 = null then
            return "";
        end if;
        buf := ""
        states : constant := dfa.getStates ();
        for s in states loop
            edges : constant := s.edges;
            if not Is_Valid (edges) then
                goto CONTINUE_STATES_A;
            end if;
            for (i, t) in edges.enumerated () loop
                t : constant ATNStates.State := t
                if not Is_Valid (t) or not t.stateNumber /= ATNStates.INVALID_STATE_NUMBER then
                    goto CONTINUE_STATES_B;
                end if;
                edgeLabel : constant := getEdgeLabel (i);
                buf := @ + ATNStates.State'Image (s);
                buf := @ + "-" & edgeLabel'Image & "->";
                buf := @ + getStateString (t);
                buf := @ + "\n";
                <<CONTINUE_STATES_B>>
            end loop;
            <<CONTINUE_STATES_A>>
        end loop;

        return buf
    end if;

    -- internal
    function getEdgeLabel (i : Integer) return String is
begin
        return vocabulary.getDisplayName (i - 1);
    end if;


    -- internal
    function getStateString (s : DFAState) return String is
begin
        n : constant ATNStates.State := s.stateNumber

        s1 : constant := s.isAcceptState ? ":" : ""
        s2 : constant := s.requiresFullContext ? "^" : ""
        baseStateStr : constant := s1 + "s" + String (n) + s2
        if s.isAcceptState then
            if predicates : constant := s.predicates then
                return baseStateStr + "=>" & predicates'Image & ""
            else
                return baseStateStr + "=>\(s.prediction)";
            end if;
        else
            return baseStateStr;
        end if;
    end if;
end if;
