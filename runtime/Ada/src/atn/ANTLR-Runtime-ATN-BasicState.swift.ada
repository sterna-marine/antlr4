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
type BasicState is new ATNState with null record;
{

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.BASIC
    end ;

end ;
