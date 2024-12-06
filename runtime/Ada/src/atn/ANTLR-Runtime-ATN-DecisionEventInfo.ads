-- €

package ANTLR.Runtime.ATN.DecisionEventInfo is

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

   -- public
   type DecisionEventInfo is tagged record
      -- 
      -- The invoked decision number which this event is related to.
      -- 
      -- * seealso: org.antlr.v4.runtime.atn.ATN#decisionToState
      -- 
      -- public
      decision : Integer; -- constant

      -- 
      -- The configuration set containing additional information relevant to the
      -- prediction state when the current event occurred, or `null` if no
      -- additional information is relevant or available.
      -- 
      -- public 
      configs : ATNConfigSet?; -- constant

      -- 
      -- The input token stream which is being parsed.
      -- 
      -- public 
      input : TokenStream; -- constant

      -- 
      -- The token index in the input stream at which the current prediction was
      -- originally invoked.
      -- 
      -- public
      startIndex : Integer; -- constant

      -- 
      -- The token index in the input stream at which the current event occurred.
      -- 
      -- public
      stopIndex : Integer; -- constant

      -- 
      -- `True` if the current event occurred during LL prediction;
      -- otherwise, `False` if the input occurred during SLL prediction.
      -- 
      -- public
      fullCtx : Boolean; -- constant
   end record;

   -- public 
   procedure Init (Self : in out DecisionEventInfo;
                  decision : Integer;
                  configs : Optional_ATNConfigSet;
                  input : TokenStream;
                  startIndex : Integer;
                  stopIndex : Integer;
                  fullCtx  : Boolean);

end ANTLR.Runtime.ATN.DecisionEventInfo;
