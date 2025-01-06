-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.DFA.States;

use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.DFA.States;

package ANTLR.Runtime.ATN.Simulators is

   --
   -- Must distinguish between missing edge and edge we know leads nowhere
   --
   -- public static
   function ERROR return DFAState;

   -- open
   type ATNSimulator is new Ada.Finalization.Controlled with record

      -- public
      atn : ATN; -- constant

      --
      -- The context cache maps all PredictionContext objects that are This.equals;
      -- to a single cached copy. This cache is shared across all contexts
      -- in all ATNConfigs in all DFA states.  We rebuild each ATNConfigSet
      -- to use only cached nodes/graphs in This.addDFAState. We don't want to
      -- fill this during This.closure since there are lots of contexts that
      -- pop up but are not used ever again. It also greatly slows down This.closure.
      --
      -- This cache makes a huge difference in memory and a little bit in speed.
      -- For the Java grammar on java.*, it dropped the memory requirements
      -- at the end from 25M to 16M. We don't store any of the full context
      -- graphs in the DFA because they are limited to local context only,
      -- but apparently there's a lot of repetition there as well. We optimize
      -- the config contexts before storing the config set in the DFA states
      -- by literally rebuilding them with cached subgraphs only.
      --
      -- I tried a cache for use during closure operations, that was
      -- whacked after each This.adaptivePredict. It cost a little bit
      -- more time I think and doesn't save on the overall footprint
      -- so it's not worth the complexity.
      --
      -- internal
      sharedContextCache : PredictionContextCache; -- constant
   end record;

   subtype Object is ATNSimulator;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out ATNSimulator;
                   atn : ATN;
                   sharedContextCache : PredictionContextCache);

   -- open
   procedure reset (This : ATNSimulator);

   --
   -- Clear the DFA cache used by the current instance. Since the DFA cache may
   -- be shared by multiple ATN simulators, this method may affect the
   -- performance (but not accuracy) of other parsers which are being used
   -- concurrently.
   --
   -- * throws: ANTLRError.unsupportedOperation if the current instance does not
   -- support clearing the DFA.
   --
   -- open
   procedure clearDFA (This : ATNSimulator);

   -- open
   function getSharedContextCache (This : ATNSimulator) return PredictionContextCache
      is (This.sharedContextCache);

   -- open
   function getCachedContext (This : ATNSimulator; context : PredictionContext) return PredictionContext;

   -- public static
   function edgeFactory (atn : ATN;
                         Token_Type : Token_Kind;
                         src : Integer;
                         trg : Integer;
                         arg1 : Integer;
                         arg2 : Integer;
                         arg3 : Integer;
                         sets : IntervalSet_List)
                         return Transition
      is (ATNDeserializer.edgeFactory (atn, Token_Type, src, trg, arg1, arg2, arg3, sets));

end ANTLR.Runtime.ATN.Simulators;