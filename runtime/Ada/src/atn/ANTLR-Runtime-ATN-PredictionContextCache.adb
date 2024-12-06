-- €

package ANTLR.Runtime.ATN.PredictionContextCache is 

   procedure Init (Self : PredictionContextCache) is
   begin
      null;
   end Init;

   function add (This : PredictionContextCache; ctx : PredictionContext) return PredictionContext is
   begin
      if ctx === EmptyPredictionContext.Instance then
            return EmptyPredictionContext.Instance;
      end if;
      existing : constant := This.cache.Element (ctx)
      if Is_Valid (existing) then
         -- print (name & " reuses " & existing);
         return existing;
      else
         This.cache[ctx] := ctx;
         return ctx;
      end if;
   end add;

end ANTLR.Runtime.ATN.PredictionContextCache;
