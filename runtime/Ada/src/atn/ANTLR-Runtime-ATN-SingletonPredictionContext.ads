-- €

with ANTLR.Runtime.ATN.PredictionContext;

use with ANTLR.Runtime.ATN.PredictionContext;

package ANTLR.Runtime.ATN.SingletonPredictionContext is

   -- public
   type SingletonPredictionContext is new PredictionContext with
   record
      -- public final
      parent : Optional_PredictionContext; -- constant
      -- public final
      returnState : Integer; -- constant
   end record;

   procedure Initialize (Self : SingletonPredictionContext;
                   parent : Optional_PredictionContext;
                   returnState : ATStates.State);

   -- public static
   function create (parent : Optional_PredictionContext;
                    returnState : ATStates.State)
                    return SingletonPredictionContext;

   overriding
   -- public
   function size (This : SingletonPredictionContext) return Integer
      is (1);

   overriding
   -- public
   function getParent (This : SingletonPredictionContext;
                       index : Integer)
                       return Optional_PredictionContext;

   overriding
   -- public
   function getReturnState (This : SingletonPredictionContext;
                            index : Integer)
                            return Integer;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_SingletonPredictionContext (S : in out Sink'Class; X : SingletonPredictionContext);
   for SingletonPredictionContext'Put_Image use Put_Image_SingletonPredictionContext;
   -- public
   overriding
   function Description (This : SingletonPredictionContext) return UString;

   -- public
   function "=" (Lhs, Rhs : SingletonPredictionContext) return Boolean;

end ANTLR.Runtime.ATN.SingletonPredictionContext;
