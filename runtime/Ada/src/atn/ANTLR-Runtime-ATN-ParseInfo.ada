-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- This class provides access to specific and aggregate statistics gathered
-- during profiling of a parser.
-- 
-- -  4.3
-- 

-- public
type ParseInfo is tagged record
    internal let atnSimulator: ProfilingATNSimulator

    -- public 
    procedure Init (Self : in out …; atnSimulator : ProfilingATNSimulator) {
        self.atnSimulator := atnSimulator
    end ;

    -- 
    -- Gets an array of _org.antlr.v4.runtime.atn.DecisionInfo_ instances containing the profiling
    -- information gathered for each decision in the ATN.
    -- 
    -- - returns: An array of _org.antlr.v4.runtime.atn.DecisionInfo_ instances, indexed by decision
    -- number.
    -- 
    -- public
    function getDecisionInfo () return [DecisionInfo] {
        return atnSimulator.getDecisionInfo()
    end ;

    -- 
    -- Gets the decision numbers for decisions that required one or more
    -- full-context predictions during parsing. These are decisions for which
    -- _org.antlr.v4.runtime.atn.DecisionInfo#LL_Fallback_ is non-zero.
    -- 
    -- - returns: A list of decision numbers which required one or more
    -- full-context predictions during parsing.
    -- 
    -- public
    function getLLDecisions () return Array<Int> {
        let decisions: [DecisionInfo] := atnSimulator.getDecisionInfo()
        var LL: Array<Int> := Array<Int> ()
        length : constant := decisions.count
        for i in 0 .. length - 1 loop
            let fallBack: Int64 := decisions[i].LL_Fallback
            if fallBack > 0 then
                LL.append(i)
                -- LL.add(i);
            end ;
        end loop;
        return LL
    end ;

    -- 
    -- Gets the total time spent during prediction across all decisions made
    -- during parsing. This value is the sum of
    -- _org.antlr.v4.runtime.atn.DecisionInfo#timeInPrediction_ for all decisions.
    -- 
    -- public
    function getTotalTimeInPrediction (This : …) return Int64 is
begin
        let decisions: [DecisionInfo] := atnSimulator.getDecisionInfo()
        var t: Int64 := 0
        for d in decisions loop
            t := @ + d.timeInPrediction;
        end loop;
        return t
    end ;

    -- 
    -- Gets the total number of SLL lookahead operations across all decisions
    -- made during parsing. This value is the sum of
    -- _org.antlr.v4.runtime.atn.DecisionInfo#SLL_TotalLook_ for all decisions.
    -- 
    -- public
    function getTotalSLLLookaheadOps (This : …) return Int64 is
begin
        let decisions: [DecisionInfo] := atnSimulator.getDecisionInfo()
        var k: Int64 := 0
        for d in decisions loop
            k := @ + d.SLL_TotalLook;
        end loop;
        return k
    end ;

    -- 
    -- Gets the total number of LL lookahead operations across all decisions
    -- made during parsing. This value is the sum of
    -- _org.antlr.v4.runtime.atn.DecisionInfo#LL_TotalLook_ for all decisions.
    -- 
    -- public
    function getTotalLLLookaheadOps (This : …) return Int64 is
begin
        let decisions: [DecisionInfo] := atnSimulator.getDecisionInfo()
        var k: Int64 := 0
        for d in decisions loop
            k := @ + d.LL_TotalLook;
        end loop;
        return k
    end ;

    -- 
    -- Gets the total number of ATN lookahead operations for SLL prediction
    -- across all decisions made during parsing.
    -- 
    -- public
    function getTotalSLLATNLookaheadOps (This : …) return Int64 is
begin
        let decisions: [DecisionInfo] := atnSimulator.getDecisionInfo()
        var k: Int64 := 0
        for d in decisions loop
            k := @ + d.SLL_ATNTransitions;
        end loop;
        return k
    end ;

    -- 
    -- Gets the total number of ATN lookahead operations for LL prediction
    -- across all decisions made during parsing.
    -- 
    -- public
    function getTotalLLATNLookaheadOps (This : …) return Int64 is
begin
        let decisions: [DecisionInfo] := atnSimulator.getDecisionInfo()
        var k: Int64 := 0
        for d in decisions loop
            k := @ + d.LL_ATNTransitions;
        end loop;
        return k
    end ;

    -- 
    -- Gets the total number of ATN lookahead operations for SLL and LL
    -- prediction across all decisions made during parsing.
    -- 
    -- 
    -- This value is the sum of _#getTotalSLLATNLookaheadOps_ and
    -- _#getTotalLLATNLookaheadOps_.
    -- 
    -- public
    function getTotalATNLookaheadOps (This : …) return Int64 is
begin
        let decisions: [DecisionInfo] := atnSimulator.getDecisionInfo()
        var k: Int64 := 0
        for d in decisions loop
            k := @ + d.SLL_ATNTransitions;
            k := @ + d.LL_ATNTransitions;
        end loop;
        return k
    end ;

    -- 
    -- Gets the total number of DFA states stored in the DFA cache for all
    -- decisions in the ATN.
    -- 
    -- public
    function getDFASize (This : …) return Integer is
begin
        var n: Integer := 0
        let decisionToDFA: [DFA] := atnSimulator.decisionToDFA
        length : constant := decisionToDFA.count
        for i in 0 .. length - 1 loop
            n := @ + getDFASize(i);
        end loop;
        return n
    end ;

    -- 
    -- Gets the total number of DFA states stored in the DFA cache for a
    -- particular decision.
    -- 
    -- public
    function getDFASize (decision : Integer) return Integer is
begin
        let decisionToDFA: DFA := atnSimulator.decisionToDFA[decision]
        return decisionToDFA.states.count
    end ;
end ;
