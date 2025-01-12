-- €
with Ada.Containers.Vectors;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.TokenStream_Protocol;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.TokenStream_Protocol;
use ANTLR.Runtime.ATN.DecisionEventInfos;

package ANTLR.Runtime.ATN.DecisionEventInfos.ContextSensitivityInfos is

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

   subtype Object is ContextSensitivityInfo;
   subtype Super is DecisionEventInfo;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function "=" (Left, Right : ContextSensitivityInfo) return Boolean;

   package ContextSensitivityInfo_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => ContextSensitivityInfo,
      "=" => "=");
   subtype ContextSensitivityInfo_List is ContextSensitivityInfo_Container.Vector;

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

end ANTLR.Runtime.ATN.DecisionEventInfos.ContextSensitivityInfos;
