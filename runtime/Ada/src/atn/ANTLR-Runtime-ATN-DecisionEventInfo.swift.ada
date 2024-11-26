-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- This is the base class for gathering detailed information about prediction
-- events which occur during parsing.
-- 
-- Note that we could record the parser call stack at the time this event
-- occurred but in the presence of left recursive rules, the stack is kind of
-- meaningless. It's better to look at the individual configurations for their
-- individual stacks. Of course that is a _org.antlr.v4.runtime.atn.PredictionContext_ object
-- not a parse tree node and so it does not have information about the extent
-- (start .. stop) of the various subtrees. Examining the stack tops of all
-- configurations provide the return states for the rule invocations.
-- From there you can get the enclosing rule.
-- 
-- -  4.3
-- 

-- public
type DecisionEventInfo is tagged record
    -- 
    -- The invoked decision number which this event is related to.
    -- 
    -- - seealso: org.antlr.v4.runtime.atn.ATN#decisionToState
    -- 
    -- public
    decision : constant Integer;

    -- 
    -- The configuration set containing additional information relevant to the
    -- prediction state when the current event occurred, or `null` if no
    -- additional information is relevant or available.
    -- 
    -- public 
    configs : constant ATNConfigSet?;

    -- 
    -- The input token stream which is being parsed.
    -- 
    -- public 
    input : constant TokenStream;

    -- 
    -- The token index in the input stream at which the current prediction was
    -- originally invoked.
    -- 
    -- public
    startIndex : constant Integer;

    -- 
    -- The token index in the input stream at which the current event occurred.
    -- 
    -- public
    stopIndex : constant Integer;

    -- 
    -- `True` if the current event occurred during LL prediction;
    -- otherwise, `False` if the input occurred during SLL prediction.
    -- 
    -- public
    fullCtx : constant Boolean;

    -- public 
    procedure Init (Self : in out …; decision : Integer;
                configs : Optional_ATNConfigSet;
                input : TokenStream;
                startIndex : Integer;
                stopIndex : Integer;
                fullCtx  : Boolean) {
        self.decision := decision
        self.fullCtx := fullCtx
        self.stopIndex := stopIndex
        self.input := input
        self.startIndex := startIndex
        self.configs := configs
    end if;
end if;
