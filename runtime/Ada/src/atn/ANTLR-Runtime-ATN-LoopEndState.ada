-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- Mark the end of a * or + loop.
-- 

-- public final
type LoopEndState is new ATNState with null record;
{
    -- public
    loopBackState : Optional_ATNState;

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.LOOP_END
    end if;
end if;
