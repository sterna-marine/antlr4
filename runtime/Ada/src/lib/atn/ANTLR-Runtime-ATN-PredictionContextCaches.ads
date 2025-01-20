-- €

with Ada.Finalization;

package ANTLR.Runtime.ATN.PredictionContextCaches is

   --
   -- Used to cache _org.antlr.v4.runtime.atn.PredictionContext_ objects. Its used for the shared
   -- context cash associated with contexts in DFA states. This cache
   -- can be used for both lexers and parsers.
   --

   -- public final
   type PredictionContextCache is new Ada.Finalization.Controlled with record
      -- private
      cache : PredictionContext_2_Map;
   end record;

   -- public
   procedure Initialize (Self : PredictionContextCache);

   --
   -- Add a context to the cache and return it. If the context already exists,
   -- return that one instead and do not add a new context to the cache.
   -- Protect shared cache from unsafe thread access.
   --
   -- @discardableResult
   -- public
   function add (This : PredictionContextCache; ctx : PredictionContext) return PredictionContext;

   -- public
   function get (This : PredictionContextCache; ctx : PredictionContext) return Optional_PredictionContext
      is (This.cache.Element (ctx));

   -- public
   function size (This : PredictionContextCache) return Integer
      is (This.cache.Length);

end ANTLR.Runtime.ATN.PredictionContextCaches;
