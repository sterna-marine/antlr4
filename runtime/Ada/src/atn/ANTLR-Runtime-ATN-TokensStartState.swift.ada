-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- The Tokens rule start state linking to each lexer rule start state
-- 

-- public final
type TokensStartState is new DecisionState with null record;
{

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.TOKEN_START
    end ;
end ;
