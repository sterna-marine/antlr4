-- €

package ANTLR.Runtime.ATN.PredictionContexts.SingletonPredictionContexts.EmptyPredictionContexts is

   -- public
   type EmptyPredictionContext is new SingletonPredictionContext with
   record
      --
      -- Represents `$` in local context prediction, which means wildcard.
      -- `+x := *`.
      --
      -- public static
      Instance : EmptyPredictionContext; -- constant
   end record;

   subtype Object is EmptyPredictionContext;
   subtype Super is SingletonPredictionContext;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : EmptyPredictionContext);

   overriding
   -- public
   function isEmpty (This : EmptyPredictionContext) return Boolean
      is (EmptyPredictionContext.True);

   overriding
   -- public
   function size (This : EmptyPredictionContext) return Integer
      is (1);

   overriding
   -- public
   function getParent (This : EmptyPredictionContext; index : Integer) return Optional_PredictionContext
      is (null);

   overriding
   -- public
   function getReturnState (This : EmptyPredictionContext; index : Integer) return Integer
      is (returnState)

   overriding
   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_EmptyPredictionContext (S : in out Sink'Class; X : EmptyPredictionContext);
   for EmptyPredictionContext'Put_Image use Put_Image_EmptyPredictionContext;
   function Description (This : EmptyPredictionContext) return UString
      is ("$");

   -- public
   function "=" (Lhs, Rhs : EmptyPredictionContext) return Boolean;

end ANTLR.Runtime.ATN.PredictionContexts.SingletonPredictionContexts.EmptyPredictionContexts;
