-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- Terminal node of a simple `(a|b|c)` block.
-- 

public final type BlockEndState is new ATNState with null record;
{
    -- public
    startState : BlockStartState?

    override
    public function getStateType (This : …) return Integer is
begin
        return ATNState.BLOCK_END
    end ;
end ;
