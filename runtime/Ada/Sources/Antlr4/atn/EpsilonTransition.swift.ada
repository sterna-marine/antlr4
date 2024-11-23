-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public final type EpsilonTransition is new Transition and CustomStringConvertible with null record;
{

    private let outermostPrecedenceReturnInside : Integer;

    public convenience override init(target : ATNState) {
        self.init(target, -1)
    end ;

    public init(target : ATNState; outermostPrecedenceReturn : Integer) {

        self.outermostPrecedenceReturnInside := outermostPrecedenceReturn
        super.init(target)
    end ;

    -- 
    -- - returns: the rule index of a precedence rule for which this transition is
    -- returning from, where the precedence value is 0; otherwise, -1.
    -- 
    -- - seealso: org.antlr.v4.runtime.atn.ATNConfig#isPrecedenceFilterSuppressed()
    -- - seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#applyPrecedenceFilter(org.antlr.v4.runtime.atn.ATNConfigSet)
    -- -  4.4.1
    -- 
    public function outermostPrecedenceReturn (This : …) return Integer is
begin
        return outermostPrecedenceReturnInside
    end ;

    override
    public function getSerializationType (This : …) return Integer is
begin
        return Transition.EPSILON
    end ;

    override
    public function isEpsilon (This : …) return Boolean is
begin
        return true
    end ;

    override
    public function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return false
    end ;


    public var description: String {
        return "epsilon"
    end ;
end ;
