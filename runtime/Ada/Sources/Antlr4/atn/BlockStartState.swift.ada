-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- The start of a regular `(...)` block.
-- 

public type BlockStartState is new DecisionState with null record;
{
    public var endState: BlockEndState?
end ;
