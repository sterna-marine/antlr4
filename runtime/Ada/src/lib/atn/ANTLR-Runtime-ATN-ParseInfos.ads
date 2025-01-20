-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.Simulators.Parsers.Profilings;
with ANTLR.Runtime.DFA;
with Interfaces;

use ANTLR.Runtime.ATN.Simulators.Parsers.Profilings;
use ANTLR.Runtime.DFA;
use Interfaces;

package ANTLR.Runtime.ATN.ParseInfos is

   --
   -- This class provides access to specific and aggregate statistics gathered
   -- during profiling of a parser.
   --

   -- public
   type ParseInfo is new Ada.Finalization.Controlled with record
      -- internal
      atnSimulator : ProfilingATNSimulator; -- constant
   end record;

   subtype Object is ParseInfo;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out ParseInfo; atnSimulator : ProfilingATNSimulator);

   --
   -- Gets an array of _org.antlr.v4.runtime.atn.DecisionInfo_ instances containing the profiling
   -- information gathered for each decision in the ATN.
   --
   -- * returns: An array of _org.antlr.v4.runtime.atn.DecisionInfo_ instances, indexed by decision
   -- number.
   --
   -- public
   function getDecisionInfo (This : ParseInfo) return DecisionInfo_List
      is (This.atnSimulator.getDecisionInfo);

   --
   -- Gets the decision numbers for decisions that required one or more
   -- full-context predictions during parsing. These are decisions for which
   -- _org.antlr.v4.runtime.atn.DecisionInfo#LL_Fallback_ is non-zero.
   --
   -- * returns: A list of decision numbers which required one or more
   -- full-context predictions during parsing.
   --
   -- public
   function getLLDecisions (This : ParseInfo) return Integer_List;

   --
   -- Gets the total time spent during prediction across all decisions made
   -- during parsing. This value is the sum of
   -- _org.antlr.v4.runtime.atn.DecisionInfo#timeInPrediction_ for all decisions.
   --
   -- public
   function getTotalTimeInPrediction (This : ParseInfo) return Real_Time.Time_Span;

   --
   -- Gets the total number of SLL lookahead operations across all decisions
   -- made during parsing. This value is the sum of
   -- _org.antlr.v4.runtime.atn.DecisionInfo#SLL_TotalLook_ for all decisions.
   --
   -- public
   function getTotalSLLLookaheadOps (This : ParseInfo) return Long_Long_Integer;

   --
   -- Gets the total number of LL lookahead operations across all decisions
   -- made during parsing. This value is the sum of
   -- _org.antlr.v4.runtime.atn.DecisionInfo#LL_TotalLook_ for all decisions.
   --
   -- public
   function getTotalLLLookaheadOps (This : ParseInfo) return Long_Long_Integer;

   --
   -- Gets the total number of ATN lookahead operations for SLL prediction
   -- across all decisions made during parsing.
   --
   -- public
   function getTotalSLLATNLookaheadOps (This : ParseInfo) return Long_Long_Integer;

   --
   -- Gets the total number of ATN lookahead operations for LL prediction
   -- across all decisions made during parsing.
   --
   -- public
   function getTotalLLATNLookaheadOps (This : ParseInfo) return Long_Long_Integer;

   --
   -- Gets the total number of ATN lookahead operations for SLL and LL
   -- prediction across all decisions made during parsing.
   --
   --
   -- This value is the sum of _#getTotalSLLATNLookaheadOps_ and
   -- _#getTotalLLATNLookaheadOps_.
   --
   -- public
   function getTotalATNLookaheadOps (This : ParseInfo) return Long_Long_Integer;

   --
   -- Gets the total number of DFA states stored in the DFA cache for all
   -- decisions in the ATN.
   --
   -- public
   function getDFASize (This : ParseInfo) return Integer;

   --
   -- Gets the total number of DFA states stored in the DFA cache for a
   -- particular decision.
   --
   -- public
   function getDFASize (This : ParseInfo; decision : State) return Integer;

end ANTLR.Runtime.ATN.ParseInfos;
