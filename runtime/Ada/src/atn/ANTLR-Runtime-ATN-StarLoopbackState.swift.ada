-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- public final
type StarLoopbackState is new ATNState with null record;
{
    -- public
    function getLoopEntryState (This : …) return StarLoopEntryState is
begin
        return transition(0).target as! StarLoopEntryState
    end ;

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.STAR_LOOP_BACK
    end ;
end ;
