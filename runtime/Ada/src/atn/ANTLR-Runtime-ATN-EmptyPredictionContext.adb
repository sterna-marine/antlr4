-- €

package body ANTLR.Runtime.ATN.EmptyPredictionContext is

   -- public
   procedure Init (Self : EmptyPredictionContext) is
   begin
      SingletonPredictionContext.init (null, PredictionContext.EMPTY_RETURN_STATE); -- Super
   end Init;

   -- public
   function "=" (Lhs : EmptyPredictionContext; Rhs : EmptyPredictionContext) return Boolean is
   begin
      if lhs === rhs then
         return True;
      else
         return False;
      end if;
   end "=";

end ANTLR.Runtime.ATN.EmptyPredictionContext;
