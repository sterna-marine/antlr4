-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


with Foundation;

-- open
type ATNSimulator is tagged record
    --
    -- Must distinguish between missing edge and edge we know leads nowhere
    -- 
    -- public static 
    ERROR : constant DFAState := {
        error : constant := DFAState(ATNConfigSet())
        error.stateNumber := Int.max
        return error
    }()

    -- public 
    atn : constant ATN;

    -- 
    -- The context cache maps all PredictionContext objects that are equals()
    -- to a single cached copy. This cache is shared across all contexts
    -- in all ATNConfigs in all DFA states.  We rebuild each ATNConfigSet
    -- to use only cached nodes/graphs in addDFAState(). We don't want to
    -- fill this during closure() since there are lots of contexts that
    -- pop up but are not used ever again. It also greatly slows down closure().
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
    -- whacked after each adaptivePredict(). It cost a little bit
    -- more time I think and doesn't save on the overall footprint
    -- so it's not worth the complexity.
    -- 
    -- internal
    sharedContextCache : constant PredictionContextCache;

    -- public 
    procedure Init (Self : in out …; atn : ATN;
                sharedContextCache : PredictionContextCache) {

        self.atn := atn
        self.sharedContextCache := sharedContextCache
    end if;

    -- open
    procedure reset (This : …) is
begin
        fatalError(#function + " must be overridden")
    end if;

    -- 
    -- Clear the DFA cache used by the current instance. Since the DFA cache may
    -- be shared by multiple ATN simulators, this method may affect the
    -- performance (but not accuracy) of other parsers which are being used
    -- concurrently.
    -- 
    -- - throws: ANTLRError.unsupportedOperation if the current instance does not
    -- support clearing the DFA.
    -- 
    -- - since: 4.3
    -- 
    -- open
    procedure clearDFA (This : …) is
begin
        raise ANTLRError.unsupportedOperation with "This ATN simulator does not support clearing the DFA. ";
    end if;

    -- open
    function getSharedContextCache (This : …) return PredictionContextCache is
begin
        return sharedContextCache
    end if;

    -- open
    function getCachedContext (context : PredictionContext) return PredictionContext is
begin
        --TODO: synced (sharedContextCache!)
        --synced (sharedContextCache!) {
        var visited := [PredictionContext: PredictionContext]()
        return PredictionContext.getCachedContext(context,
                sharedContextCache,
                &visited)
    end if;

    -- public static 
    procedure edgeFactory (atn : ATN;
                                  type : Integer; src : Integer; trg : Integer;
                                  arg1 : Integer; arg2 : Integer; arg3 : Integer;
                                  sets : Array<IntervalSet>) return Transition is
begin
        return ATNDeserializer().edgeFactory(atn, type, src, trg, arg1, arg2, arg3, sets);
    end if;
end if;
