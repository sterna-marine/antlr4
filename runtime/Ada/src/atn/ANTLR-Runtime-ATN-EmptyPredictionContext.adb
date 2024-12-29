-- €

package body ANTLR.Runtime.ATN.EmptyPredictionContext is

   -- public
   procedure Initialize (Self : EmptyPredictionContext) is
   begin
      SingletonPredictionContext.init (Self, null, PredictionContext.EMPTY_RETURN_STATE); -- Super
   end Initialize;

   -- public
   function "=" (Lhs, Rhs : EmptyPredictionContext) return Boolean is
   begin
      if lhs === rhs then
         return True;
      else
         return False;
      end if;
   end "=";

end ANTLR.Runtime.ATN.EmptyPredictionContext;
