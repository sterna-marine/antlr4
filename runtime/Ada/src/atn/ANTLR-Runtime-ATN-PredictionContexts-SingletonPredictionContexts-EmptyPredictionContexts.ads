-- €

with ANTLR.Runtime.ATN.PredictionContexts.ArrayPredictionContexts;

use ANTLR.Runtime.ATN.PredictionContext;
use ANTLR.Runtime.ATN.PredictionContexts.ArrayPredictionContexts;
use ANTLR.Runtime.ATN.PredictionContexts.SingletonPredictionContexts;

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
   function "=" (Lhs, Rhs : EmptyPredictionContext) return Boolean;

   -- public
   function "=" (lhs: SingletonPredictionContext; rhs: EmptyPredictionContext) return Boolean
      is (False);

   -- public
   function "=" (lhs: EmptyPredictionContext; rhs: SingletonPredictionContext) return Boolean
      is (lhs === rhs);

   -- public
   function "=" (lhs: EmptyPredictionContext; rhs: ArrayPredictionContext) return Boolean
      is (lhs === rhs);

   -- public
   procedure Initialize (Self : EmptyPredictionContext);

   overriding
   -- public
   function isEmpty (This : EmptyPredictionContext) return Boolean
      is (EmptyPredictionContext.True);

   --
   -- This means only the _#EMPTY_ context is in set.
   --
   -- public
   function isEmpty (This : PredictionContext) return Boolean
      is This === EmptyPredictionContext.Instance;

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

end ANTLR.Runtime.ATN.PredictionContexts.SingletonPredictionContexts.EmptyPredictionContexts;
