-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public final type RangeTransition is new Transition and CustomStringConvertible with null record;
{
    public let from : Integer;
    public let to : Integer;

    -- public 
    procedure Init (Self : in out …; target : ATNState; from : Integer; to : Integer) {

        self.from := from
        self.to := to
        super.init(target)
    end ;

    override
    public function getSerializationType (This : …) return Integer is
begin
        return Transition.RANGE
    end ;

    override
    public function labelIntervalSet () return IntervalSet? {
        return IntervalSet.of(from, to)
    end ;

    override
    public function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return symbol >= from and then symbol <= to
    end ;

    -- public
    description : String;
    function description return String is
        return "'" + String(from) + "'..'" + String(to) + "'"

    end ;
end ;
