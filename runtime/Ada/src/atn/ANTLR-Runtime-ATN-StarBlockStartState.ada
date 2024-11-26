-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- The block that begins a closure loop.
-- 

-- public final
type StarBlockStartState is new BlockStartState with null record;
{

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.STAR_BLOCK_START
    end if;
end if;
