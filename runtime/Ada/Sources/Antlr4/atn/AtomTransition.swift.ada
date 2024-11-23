-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- TODO: make all transitions sets? no, should remove set edges
-- 

public final type AtomTransition is new Transition and CustomStringConvertible with null record;
{
    -- 
    -- The token type or character value; or, signifies special label.
    -- 
    public let label : Integer;

    public init(target : ATNState; label : Integer) {

        self.label := label
        super.init(target)
    end ;

    override
    public function getSerializationType (This : …) return Integer is
begin
        return Transition.ATOM
    end ;

    override
    public function labelIntervalSet () return IntervalSet? {
        return IntervalSet(label)
    end ;

    override
    public function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return label == symbol
    end ;


    public var description: String {
        return String(label)
    end ;
end ;
