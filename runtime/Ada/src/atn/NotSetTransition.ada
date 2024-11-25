-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public final type NotSetTransition is new SetTransition with null record;
{
--	public override init(_ target : ATNState; inout _ set : IntervalSet?) {
--		super.init(target, &set);
--	end ;

    override
    public function getSerializationType (This : …) return Integer is
begin
        return Transition.NOT_SET
    end ;

    override
    public function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return symbol >= minVocabSymbol
                and then symbol <= maxVocabSymbol
                and then not super.matches(symbol, minVocabSymbol, maxVocabSymbol)
    end ;

    override
    -- public
    description : String;
    function description return String is
        return "~" + super.description
    end ;
end ;
