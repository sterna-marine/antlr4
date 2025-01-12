-- €

with Ada.Containers.Vectors;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.Misc.BitSets;
with ANTLR.Runtime.TokenStream_Protocol;

use ANTLR.Runtime.ATN.DecisionEventInfos;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.Misc.BitSets;
use ANTLR.Runtime.TokenStream_Protocol;

package ANTLR.Runtime.ATN.DecisionEventInfos.AmbiguityInfos is

   --
   -- This class represents profiling event information for an ambiguity.
   -- Ambiguities are decisions where a particular input resulted in an SLL
   -- conflict, followed by LL prediction also reaching a conflict state
   -- (indicating a True ambiguity in the grammar).
   --
   --
   -- This event may be reported during SLL prediction in cases where the
   -- conflicting SLL configuration set provides sufficient information to
   -- determine that the SLL conflict is truly an ambiguity. For example, if none
   -- of the ATN configurations in the conflicting SLL configuration set have
   -- traversed a global follow transition (i.e.
   -- _org.antlr.v4.runtime.atn.ATNConfig#reachesIntoOuterContext_ is 0 for all configurations), then
   -- the result of SLL prediction for that input is known to be equivalent to the
   -- result of LL prediction for that input.
   --
   --
   -- In some cases, the minimum represented alternative in the conflicting LL
   -- configuration set is not equal to the minimum represented alternative in the
   -- conflicting SLL configuration set. Grammars and inputs which result in this
   -- scenario are unable to use _org.antlr.v4.runtime.atn.PredictionMode#SLL_, which in turn means
   -- they cannot use the two-stage parsing strategy to improve parsing performance
   -- for that input.
   --
   -- * seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#reportAmbiguity
   -- * seealso: org.antlr.v4.runtime.ANTLRErrorListener#reportAmbiguity
   --

   -- public
   type AmbiguityInfo is new DecisionEventInfo with
   record
      --
      -- The set of alternative numbers for this decision event that lead to a valid parse.
      --
      -- public
      ambigAlts : BitSet;
   end record;

   subtype Object is AmbiguityInfo;
   subtype Super is DecisionEventInfo;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function "=" (Left, Right : AmbiguityInfo) return Boolean;

   package AmbiguityInfo_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => AmbiguityInfo,
      "=" => "=");
   subtype AmbiguityInfo_List is AmbiguityInfo_Container.Vector;

   --
   -- Constructs a new instance of the _org.antlr.v4.runtime.atn.AmbiguityInfo_ class with the
   -- specified detailed ambiguity information.
   --
   -- * parameter decision: The decision number
   -- * parameter configs: The final configuration set identifying the ambiguous
   -- alternatives for the current input
   -- * parameter ambigAlts: The set of alternatives in the decision that lead to a valid parse.
   -- * parameter input: The input token stream
   -- * parameter startIndex: The start index for the current prediction
   -- * parameter stopIndex: The index at which the ambiguity was identified during
   -- prediction
   -- * parameter fullCtx: `True` if the ambiguity was identified during LL
   -- prediction; otherwise, `False` if the ambiguity was identified
   -- during SLL prediction
   --
   -- public
   procedure Initialize (Self : in out AmbiguityInfo;
                   decision : State;
                   configs : ATNConfigSet;
                   ambigAlts : BitSet;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   fullCtx  : Boolean);

end ANTLR.Runtime.ATN.DecisionEventInfos.AmbiguityInfos;
