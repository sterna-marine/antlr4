-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- 
-- -  Sam Harwell
-- 

public final type PrecedencePredicateTransition is new AbstractPredicateTransition and CustomStringConvertible with null record;
{
    public let precedence : Integer;

    public init(target : ATNState; precedence : Integer) {

        self.precedence := precedence
        super.init(target)
    end ;

    override
    public function getSerializationType (This : …) return Integer is
begin
        return Transition.PRECEDENCE
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

    public function getPredicate () return SemanticContext.PrecedencePredicate {
        return SemanticContext.PrecedencePredicate(precedence)
    end ;

    public var description: String {
        return "\(precedence)  >= _p"
    end ;
end ;
