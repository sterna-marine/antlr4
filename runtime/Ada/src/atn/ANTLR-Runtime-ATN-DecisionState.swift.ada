-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- public
type DecisionState is new ATNState with null record;
{
    -- public
    decision : Integer := -1
    -- public
    nonGreedy : Boolean := False;
end if;
