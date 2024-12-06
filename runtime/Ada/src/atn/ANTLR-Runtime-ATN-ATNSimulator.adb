-- €

with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN;

package body ANTLR.Runtime.ATN.ATNSimulator is 

   -- --------------------------------------------
   -- Must distinguish between missing edge and edge we know leads nowhere
   -- 
   -- public static 
   ERROR : constant DFAState := DFAState (ATNConfigSet ())  --TOFIX
      with error.stateNumber = ATNStates.State.INVALID_STATE_NUMBER; -- Int.max

   -- open
   type ATNSimulator is tagged record

      -- public 
      atn : constant ATN;

      -- 
      -- The context cache maps all PredictionContext objects that are equals ();
      -- to a single cached copy. This cache is shared across all contexts
      -- in all ATNConfigs in all DFA states.  We rebuild each ATNConfigSet
      -- to use only cached nodes/graphs in addDFAState (). We don't want to
      -- fill this during closure () since there are lots of contexts that
      -- pop up but are not used ever again. It also greatly slows down closure ().
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
      -- whacked after each adaptivePredict (). It cost a little bit
      -- more time I think and doesn't save on the overall footprint
      -- so it's not worth the complexity.
      -- 
      -- internal
      sharedContextCache : constant PredictionContextCache;
   end record;

      -- public 
      procedure Init (Self : in out ATNSimulator;
                      atn : ATN;
                      sharedContextCache : PredictionContextCache) is
      begin
         self.atn := atn;
         self.sharedContextCache := sharedContextCache;
      end Init;

      -- open
      procedure reset (This : ATNSimulator) is
      begin
         raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.ATNSimulator.reset() must be overridden";
      end reset;

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
      procedure clearDFA (This : ATNSimulator) is
      begin
         raise ANTLRError.unsupportedOperation with "This ATN simulator does not support clearing the DFA. ";
      end if;

      -- open
      function getSharedContextCache (This : ATNSimulator) return PredictionContextCache
         is (This.sharedContextCache);

      -- open
      function getCachedContext (This : ATNSimulator; context : PredictionContext) return PredictionContext is
      begin
         --TODO: synced (sharedContextCache!);
         --synced (sharedContextCache!) {
         visited := [PredictionContext: PredictionContext]();
         return PredictionContext.getCachedContext (context,
                  This.sharedContextCache,
                  &visited);
      end if;

      -- public static 
      procedure edgeFactory (atn : ATN;
                                    Type : Token_Kind; src : Integer; trg : Integer;
                                    arg1 : Integer; arg2 : Integer; arg3 : Integer;
                                    sets : Array<IntervalSet>) return Transition is
   begin
         return ATNDeserializer ().edgeFactory (atn, type, src, trg, arg1, arg2, arg3, sets);
      end if;
   end if;

end ANTLR.Runtime.ATN.ATNSimulator;