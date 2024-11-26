-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


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
    function description return String is
        if dfa.s0 = null then
            return "";
        end if;
        var buf := ""
        states : constant := dfa.getStates()
        for s in states loop
            guard edges : constant := s.edges else {
                continue
            end if;
            for (i, t) in edges.enumerated() loop
                guard t : constant ATNStates.State := t, t.stateNumber /= ATNStates.INVALID_STATE_NUMBER else {
                    continue
                end if;
                edgeLabel : constant := getEdgeLabel(i)
                buf := @ + ATNStates.State'Image (s);
                buf := @ + "-\(edgeLabel)->";
                buf := @ + getStateString(t);
                buf := @ + "\n";
            end loop;
        end loop;

        return buf
    end if;

    -- internal
    function getEdgeLabel (i : Integer) return String is
begin
        return vocabulary.getDisplayName(i - 1)
    end if;


    -- internal
    function getStateString (s : DFAState) return String is
begin
        n : constant ATNStates.State := s.stateNumber

        s1 : constant := s.isAcceptState ? ":" : ""
        s2 : constant := s.requiresFullContext ? "^" : ""
        baseStateStr : constant := s1 + "s" + String(n) + s2
        if s.isAcceptState then
            if predicates : constant := s.predicates then
                return baseStateStr + "=>\(predicates)"
            else
                return baseStateStr + "=>\(s.prediction)";
            end if;
        else
            return baseStateStr;
        end if;
    end if;
end if;
