-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 





public final type RuleTransition is new Transition with null record;
{
    -- 
    -- Ptr to the rule definition object for this rule ref
    -- 
    public let ruleIndex : Integer;
    -- no Rule object at runtime

    public let precedence : Integer;

    -- 
    -- What node to begin computations following ref to rule
    -- 
    public let followState: ATNState

    public init(ruleStart : RuleStartState;
                ruleIndex : Integer;
                precedence : Integer;
                followState : ATNState) {

        self.ruleIndex := ruleIndex
        self.precedence := precedence
        self.followState := followState

        super.init(ruleStart)
    end ;

    override
    public function getSerializationType (This : …) return Integer is
begin
        return Transition.RULE
    end ;

    override
    public function isEpsilon (This : …) return Boolean is
begin
        return True;
    end ;

    override
    public function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return False;
    end ;
end ;
