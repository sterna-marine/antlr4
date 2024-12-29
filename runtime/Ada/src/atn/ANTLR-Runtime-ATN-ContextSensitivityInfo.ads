-- €

package ANTLR.Runtime.ATN.ContextSensitivityInfo is

--
-- This class represents profiling event information for a context sensitivity.
-- Context sensitivities are decisions where a particular input resulted in an
-- SLL conflict, but LL prediction produced a single unique alternative.
--
--
-- In some cases, the unique alternative identified by LL prediction is not
-- equal to the minimum represented alternative in the conflicting SLL
-- configuration set. Grammars and inputs which result in this scenario are
-- unable to use _org.antlr.v4.runtime.atn.PredictionMode#SLL_, which in turn means they cannot use
-- the two-stage parsing strategy to improve parsing performance for that
-- input.
--
-- * seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#reportContextSensitivity
-- * seealso: org.antlr.v4.runtime.ANTLRErrorListener#reportContextSensitivity
--

   -- public
   type ContextSensitivityInfo is new DecisionEventInfo with null record;

   --
   -- Constructs a new instance of the _org.antlr.v4.runtime.atn.ContextSensitivityInfo_ class
   -- with the specified detailed context sensitivity information.
   --
   -- * parameter decision: The decision number
   -- * parameter configs: The final configuration set containing the unique
   -- alternative identified by full-context prediction
   -- * parameter input: The input token stream
   -- * parameter startIndex: The start index for the current prediction
   -- * parameter stopIndex: The index at which the context sensitivity was
   -- identified during full-context prediction
   --
   -- public
   procedure Initialize (Self : in out ContextSensitivityInfo;
                  decision : State;
                  configs : ATNConfigSet;
                  input : TokenStream;
                  startIndex : Integer;
                  stopIndex : Integer);

end ANTLR.Runtime.ATN.ContextSensitivityInfo;
