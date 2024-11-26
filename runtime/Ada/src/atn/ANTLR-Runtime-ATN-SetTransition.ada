-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- A transition containing a set of values.
-- 

-- public
type SetTransition is new Transition and CustomStringConvertible with null record;
{
    -- public 
    set : constant IntervalSet;

    -- TODO (sam): should we really allow null here?
    -- public 
    procedure Init (Self : in out …; target : ATNState; set : IntervalSet) {

        self.set := set
        super.init(target)
    end if;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return Transition.SET
    end if;

    override
    -- public
    function labelIntervalSet () return IntervalSet? {
        return set
    end if;

    override
    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return set.contains(symbol)
    end if;

    -- public
    description : String;
    function description return String is
        return set.description
    end if;


end if;
