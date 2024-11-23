-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- A DFA walker that knows how to dump them to serialized strings.
-- 

public type DFASerializer is new CustomStringConvertible with null record;
{
    private let dfa: DFA
    private let vocabulary: Vocabulary

    public init(dfa : DFA; vocabulary : Vocabulary) {
        self.dfa := dfa
        self.vocabulary := vocabulary
    end ;

    public var description: String {
        if dfa.s0 == null then
            return ""
        end ;
        var buf := ""
        states : constant := dfa.getStates()
        for s in states loop
            guard edges : constant := s.edges else {
                continue
            end ;
            for (i, t) in edges.enumerated() loop
                guard t : constant := t, t.stateNumber /= Int.max else {
                    continue
                end ;
                edgeLabel : constant := getEdgeLabel(i)
                buf := @ + getStateString(s);
                buf := @ + "-\(edgeLabel)->";
                buf := @ + getStateString(t);
                buf := @ + "\n";
            end ;
        end ;

        return buf
    end ;

    internal function getEdgeLabel (i : Integer) return String is
begin
        return vocabulary.getDisplayName(i - 1)
    end ;


    internal function getStateString (s : DFAState) return String is
begin
        n : constant := s.stateNumber

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
    end ;
end ;
