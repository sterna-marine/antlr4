-- €

use ANTLR.Runtime.ATN.States;

package ANTLR.Runtime.ATN.States.DecisionStates is

   -- public
   type DecisionState is new ATNState with
   record
      -- public
      decision : State := INVALID_STATE_NUMBER;
      -- public
      nonGreedy : Boolean := False;
   end record;

   subtype Object is DecisionState;
   subtype Super is ATNState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function Equal (Left, Right : DecisionState) return Boolean
      is (Left.decision = Right.decision and Left.nonGreedy = Right.nonGreedy);
   package DecisionState is new Ada.Cantainer.Vectors (
         Index_Type => Natural,
         Element_Type => DecisionState,
         "=" => Equal);

   package Option_DecisionState is new Option (DecisionState);
   subtype Optional_DecisionState is Option_DecisionState.Optional; -- renames

end ANTLR.Runtime.ATN.States.DecisionStates;
