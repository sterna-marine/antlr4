-- €

package body ANTLR.Runtime.ATN.PredictionContextCache is

   procedure Initialize (Self : PredictionContextCache) is
   begin
      null;
   end Initialize;

   function add (This : PredictionContextCache; ctx : PredictionContext) return PredictionContext is
   begin
      if ctx === EmptyPredictionContext.Instance then
            return EmptyPredictionContext.Instance;
      end if;
      existing : constant := This.cache.Element (ctx)
      if Is_Valid (existing) then
         -- Text_IO.Put_Line (name & " reuses " & existing);
         return existing;
      else
         This.cache.Insert (Key => ctx, New_Item => ctx);
         return ctx;
      end if;
   end add;

end ANTLR.Runtime.ATN.PredictionContextCache;
