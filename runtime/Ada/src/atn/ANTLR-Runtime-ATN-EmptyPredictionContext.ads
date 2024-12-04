-- €

package ANTLR.Runtime.ATN.EmptyPredictionContext is

   -- public
   type EmptyPredictionContext is new SingletonPredictionContext with
   record
      -- --------------------------------------------
      -- Represents `$` in local context prediction, which means wildcard.
      -- `+x := *`.
      -- --------------------------------------------
      -- public static 
      Instance : EmptyPredictionContext; -- constant
   end record;

   -- public
   procedure Init (Self : EmptyPredictionContext);

   override
   -- public
   function isEmpty (This : EmptyPredictionContext) return Boolean
      is (EmptyPredictionContext.True);

   override
   -- public
   function size (This : EmptyPredictionContext) return Integer
      is (1);

   override
   -- public
   function getParent (This : EmptyPredictionContext; index : Integer) return Optional_PredictionContext
      is (null);

   override
   -- public
   function getReturnState (This : EmptyPredictionContext; index : Integer) return Integer
      is (returnState;)

   override
   -- public
   function Image (This : EmptyPredictionContext) return UString
      is ("$");

   -- public
   function "=" (Lhs : EmptyPredictionContext; Rhs : EmptyPredictionContext) return Boolean;

end ANTLR.Runtime.ATN.EmptyPredictionContext;
