-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- This class represents profiling event information for tracking the lookahead
-- depth required in order to make a prediction.
-- 
-- -  4.3
-- 

-- public
type LookaheadEventInfo is new DecisionEventInfo with null record;
{
    -- 
    -- Constructs a new instance of the _org.antlr.v4.runtime.atn.LookaheadEventInfo_ class with
    -- the specified detailed lookahead information.
    -- 
    -- - parameter decision: The decision number
    -- - parameter configs: The final configuration set containing the necessary
    -- information to determine the result of a prediction, or `null` if
    -- the final configuration set is not available
    -- - parameter input: The input token stream
    -- - parameter startIndex: The start index for the current prediction
    -- - parameter stopIndex: The index at which the prediction was finally made
    -- - parameter fullCtx: `True` if the current lookahead is part of an LL
    -- prediction; otherwise, `False` if the current lookahead is part of
    -- an SLL prediction
    -- 
    -- public 
    override
    procedure Init (Self : in out …; decision : Integer;
                         configs : ATNConfigSet?,
                         input : TokenStream; startIndex : Integer; stopIndex : Integer;
                         fullCtx  : Boolean) {
        super.init(decision, configs, input, startIndex, stopIndex, fullCtx)
    end ;
end ;
