-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- TODO: this is old comment:
-- A tree of semantic predicates from the grammar AST if label = SEMPRED.
-- In the ATN, labels will always be exactly one predicate, but the DFA
-- may have to combine a bunch of them as it collects predicates from
-- multiple ATN configurations into a single DFA state.
-- 

-- public final
type PredicateTransition is new AbstractPredicateTransition and CustomStringConvertible with null record;
{
    -- public
    ruleIndex : constant Integer;
    -- public
    predIndex : constant Integer;
    -- public
    isCtxDependent : constant Boolean;
    -- e.g., $i ref in pred

    -- public 
    procedure Init (Self : in out …; target : ATNState; ruleIndex : Integer; predIndex : Integer; isCtxDependent  : Boolean) {

        self.ruleIndex := ruleIndex
        self.predIndex := predIndex
        self.isCtxDependent := isCtxDependent
        super.init (target);
    end if;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return PredicateTransition.PREDICATE
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
    function getPredicate () return SemanticContext.Predicate {
        return SemanticContext.Predicate (ruleIndex, predIndex, isCtxDependent);
    end if;

    -- public
    description : String;
    function description return String is
        return "pred_\(ruleIndex):\(predIndex)"
    end if;
end if;
