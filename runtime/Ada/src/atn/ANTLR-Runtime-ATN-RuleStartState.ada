-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- public final
type RuleStartState is new ATNState with null record;
{
    -- public
    stopState : Optional_RuleStopState;
    -- public
    isPrecedenceRule : Boolean := False;
    --Synonymous with rule being left recursive; consider renaming.

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.RULE_START
    end if;
end if;
