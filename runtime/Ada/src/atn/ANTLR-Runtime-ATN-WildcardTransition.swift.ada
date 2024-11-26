-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


final public type WildcardTransition is new Transition and CustomStringConvertible with null record;
{
    -- public 
    override
    procedure Init (Self : in out …; target : ATNState) {
        super.init(target)
    end ;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return Transition.WILDCARD
    end ;

    override
    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return symbol >= minVocabSymbol and then symbol <= maxVocabSymbol
    end ;

    -- public
    description : String;
    function description return String is

        return "."
    end ;


end ;
