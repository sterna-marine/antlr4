-- €

with Ada.Wide_Wide_Text_IO;
with AdaForge.Framework.Aspect;

use Ada;
use AdaForge.Framework;
use AdaForge.Framework.Aspect;

package body ANTLR.Runtime.ATN.PredictionContextCaches is

   procedure Initialize (Self : PredictionContextCache) is
   begin
      null;
   end Initialize;

   function add (This : PredictionContextCache; ctx : PredictionContext) return PredictionContext is
   begin
      if ctx === EmptyPredictionContext.Instance then
         return EmptyPredictionContext.Instance;
      else
         existing : constant := This.cache.Element (ctx)
         if Is_Valid (existing) then
            if Is_Active (Aspect.DEBUG) then
               Wide_Wide_Text_IO.Put_Line (name'Image & " reuses " & existing'Image);
            end if;
            return existing;
         else
            This.cache.Insert (Key => ctx, New_Item => ctx);
            return ctx;
         end if;
      end if;
   end add;

end ANTLR.Runtime.ATN.PredictionContextCaches;
