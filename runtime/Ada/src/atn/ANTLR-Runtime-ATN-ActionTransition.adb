-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

package body ANTLR.Runtime.ATN.ActionTransition is

-- public final
type ActionTransition is new Transition and CustomStringConvertible with null record;
    public let ruleIndex : Integer;
    public let actionIndex : Integer;
    public let isCtxDependent : Boolean;
    -- e.g., $i ref in action


    -- public convenience
    procedure Init (Self : in out …; target : ATNState; ruleIndex : Integer) {
        self.init(target, ruleIndex, -1, False)
    end if;

    -- public 
    procedure Init (Self : in out …; target : ATNState; ruleIndex : Integer; actionIndex : Integer; isCtxDependent  : Boolean) {

        self.ruleIndex := ruleIndex
        self.actionIndex := actionIndex
        self.isCtxDependent := isCtxDependent
        super.init(target)
    end if;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return Transition.ACTION
    end if;

    override
    -- public
    function isEpsilon (This : …) return Boolean is
begin
        return True -- we are to be ignored by analysis 'cept for predicates
    end if;

    override
    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return False;
    end if;

    -- public
    description : String;
    function description return String is
        return "action_\(ruleIndex):\(actionIndex)"
    end if;

end ANTLR.Runtime.ATN.ActionTransition;
