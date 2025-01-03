-- €

with ANTLR.Runtime.ATN.PredictionContext;

use ANTLR.Runtime.ATN.PredictionContext;

package ANTLR.Runtime.ATN.PredictionContexts.ArrayPredictionContexts is

   -- public
   type ArrayPredictionContext is new PredictionContext with
   record
      --
      -- Parent can be null only if full ctx mode and we make an array
      -- from _#EMPTY_ and non-empty. We merge _#EMPTY_ by using null parent and
      -- returnState = _#EMPTY_RETURN_STATE_.
      --
      -- public private (set) final var
      parents : Optional_PredictionContext_List;

      --
      -- Sorted for merge, no duplicates; if present,
      -- _#EMPTY_RETURN_STATE_ is always last.
      --
      -- public final
      returnStates : constant Integer_List;
   end record;

   subtype Object is ArrayPredictionContext;
   subtype Super is PredictionContext;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;


   -- public convenience
   procedure Initialize (Self : in out ArrayPredictionContext; a : SingletonPredictionContext);

   -- public
   procedure Initialize (Self : in out ArrayPredictionContext;
                   parents : Optional_PredictionContext_List;
                   returnStates : Integer_List);

   overriding
   -- final public
   function isEmpty (This : ArrayPredictionContext) return Boolean
      is -- since EMPTY_RETURN_STATE can only appear in the last position, we don't need to verify that size = 1
         (This.returnStates.Element (0) = PredictionContext.EMPTY_RETURN_STATE);

   overriding
   -- final public
   function size (This : ArrayPredictionContext) return Integer
      is (This.returnStates.Length);

   overriding
   -- final public
   function getParent (This : ArrayPredictionContext; index : Integer) return Optional_PredictionContext
      is (This.parents.Element (index));

   overriding
   -- final public
   function getReturnState (This : ArrayPredictionContext; index : Integer) return Integer
      is (This.returnStates.Element (index));

   overriding
   -- public
   function Description (This : …) return UString;

   --internal final
   procedure combineCommonParents (This : ArrayPredictionContext);

   -- public
   function "=" (Lhs, Rhs : ArrayPredictionContext) return Boolean;

end ANTLR.Runtime.ATN.PredictionContexts.ArrayPredictionContexts;
