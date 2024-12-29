-- €

with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN.ATNStates;

package ANTLR.Runtime.ATN.DecisionInfo is

   -- public
   type DecisionState is new ATNState with
   record
      -- public
      decision : State := INVALID_STATE_NUMBER;
      -- public
      nonGreedy : Boolean := False;
   end record;

   function Equal (Left, Right : DecisionState)
      is (Left.decision = Right.decision and Left.nonGreedy = Right.nonGreedy);
   package DecisionState is new Ada.Cantainer.Vectors (
         Index_Type => Natural;
         Element_Type => DecisionState
         "=" => Equal);

   package Option_DecisionState is new Option (DecisionState);
   subtype Optional_DecisionState is Option_DecisionState.Optional; -- renames

end ANTLR.Runtime.ATN.DecisionInfo;
