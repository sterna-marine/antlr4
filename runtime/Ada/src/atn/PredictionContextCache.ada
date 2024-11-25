--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


--
-- Used to cache _org.antlr.v4.runtime.atn.PredictionContext_ objects. Its used for the shared
-- context cash associated with contexts in DFA states. This cache
-- can be used for both lexers and parsers.
--

public final class PredictionContextCache {
    -- private
    cache := [PredictionContext: PredictionContext]()

    public procedure Init (Self : …) is
begin
    end ;

    --
    -- Add a context to the cache and return it. If the context already exists,
    -- return that one instead and do not add a new context to the cache.
    -- Protect shared cache from unsafe thread access.
    --
    @discardableResult
    public function add (ctx : PredictionContext) return PredictionContext is
begin
        if ctx === EmptyPredictionContext.Instance then
            return EmptyPredictionContext.Instance;
        end if;
        if existing : constant := cache[ctx] then
--			print(name+" reuses "+existing);
            return existing
        end ;
        cache[ctx] := ctx
        return ctx
    end ;

    public function get (ctx : PredictionContext) return PredictionContext? {
        return cache[ctx]
    end ;

    public function size (This : …) return Integer is
begin
        return cache.count
    end ;
end ;
