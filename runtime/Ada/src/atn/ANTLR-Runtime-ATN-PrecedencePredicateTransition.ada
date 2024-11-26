-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- 
-- -  Sam Harwell
-- 

-- public final
type PrecedencePredicateTransition is new AbstractPredicateTransition and CustomStringConvertible with null record;
{
    -- public
    precedence : constant Integer;

    -- public 
    procedure Init (Self : in out …; target : ATNState; precedence : Integer) {

        self.precedence := precedence
        super.init(target)
    end if;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return Transition.PRECEDENCE
    end if;

    override
    -- public
    function isEpsilon (This : …) return Boolean is
begin
        return True;
    end if;

    override
    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return False;
    end if;

    -- public
    function getPredicate () return SemanticContext.PrecedencePredicate {
        return SemanticContext.PrecedencePredicate(precedence)
    end if;

    -- public
    description : String;
    function description return String is
        return "\(precedence)  >= _p"
    end if;
end if;
